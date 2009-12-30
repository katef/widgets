/* $Id$ */

/*
 * An implementation of DOM3 XPath 1.0 in Javascript.
 * DOM3 XPath 1.0 (version 1.0 of the DOM3 XPath interface) uses the XPath 1.0
 * (version 1.0 of XPath itself) language.
 *
 * http://www.w3.org/TR/2004/NOTE-DOM-Level-3-XPath-20040226/
 * http://www.w3.org/TR/1999/REC-xpath-19991116
 *
 * See also:
 * http://www.w3.org/TR/REC-xml/
 * http://www.w3.org/TR/REC-xml-names/
 */

/*
 * TODO: interpret to DOM expressions on-the-fly
 * TODO: probably better to split the XPath implementation (with a native API) from the DOM3 XPath interface
 * TODO: tests: take all examples from spec
 */

XPath = new (function () {
	/*
	 * Lexemes. See S3.7
	 *
	 * Unfortunately the XPath specification's choice of production names is
	 * too elaborate for my eyes, so I've opted for less painful names here.
	 */
	const tok = {
		EOF:        1 <<  0,
		ERROR:      1 <<  1,

		NUMBER:     1 <<  2,
		LITERAL:    1 <<  3,

		COMMA:      1 <<  4,
		AXISSEP:    1 <<  5,
		OPENPRED:   1 <<  6,
		CLOSEPRED:  1 <<  7,
		OPENGROUP:  1 <<  8,
		CLOSEGROUP: 1 <<  9,

		OROP:       1 << 10,
		ADDOP:      1 << 11,
		MULOP:      1 << 12,
		ANDOP:      1 << 13,
		EQUOP:      1 << 14,
		RELOP:      1 << 15,
		SEQOP:      1 << 16,
		SETOP:      1 << 17,

		NODETYPE:   1 << 18,
		FUNCTION:   1 << 19,
		NAMETEST:   1 << 20,
		AXISNAME:   1 << 21,
		VARIABLE:   1 << 22
	};

	/* TODO: explain this is ordered by precidence (which only matters for ERROR). XXX: but longest match wins. so intersect, find longest, then highest */
	/* TODO: explain: table of regex -> value, and optional match-extraction */
	/* TODO: store previous lexeme, and spelling */
	/* TODO: remove match:; use match arrays from the regexps themselves */
	/* TODO: explain ambiguity in matching is ok here in some cases; see specialcases() */
	/* TODO: explain neither the regex nor the token value is unique (yes, really). but both together are unique */
	/* TODO: if all we end up with is mappings to tokens, flip the array to index by tok -> re */
	const lexemes = [
		{ re: /^,/,            tok: tok.COMMA      },
		{ re: /^\(/,           tok: tok.OPENGROUP  },
		{ re: /^\)/,           tok: tok.CLOSEGROUP },
		{ re: /^\[/,           tok: tok.OPENPRED   },
		{ re: /^\]/,           tok: tok.CLOSEPRED  },
		{ re: /^::/,           tok: tok.AXISSEP    },

		{ re: /^"[^"]*"/,      tok: tok.LITERAL,   }, // XXX: match: function (s) { return s.match(/^.(.*).$/)[0]; } },
		{ re: /^'[^']*'/,      tok: tok.LITERAL,   },
		{ re: /^\.\d/,         tok: tok.NUMBER,    },
		{ re: /^\d(\.\d?)?/,   tok: tok.NUMBER,    }, // XXX: match: function (s) { return Number(s);              } },

		{ re: /^or/,           tok: tok.OROP       },
		{ re: /^[+-]/,         tok: tok.ADDOP      },
		{ re: /^and/,          tok: tok.ANDOP      },
		{ re: /^(=|!=)/,       tok: tok.EQUOP      },
		{ re: /^(<|>|<=|>=)/,  tok: tok.RELOP      },
		{ re: /^(\*|div|mod)/, tok: tok.MULOP      },
		{ re: /^\//,           tok: tok.SEQOP      },
		{ re: /^\|/,           tok: tok.SETOP      },

		/*
		 * See "Namespaces in XML 1.0",
		 * [7] QName ::= PrefixedName | UnprefixedName
		 * [4] NCName ::= Name - (Char* ':' Char*)
		 *
		 * These are implemented respectively as:
		 * QNAME:  ([\w\d][\w\d.]*:)?[\w\d][\w\d.]*
		 * NCNAME: [\w\d][\w\d.]*
		 *
		 * Here I wish Javascript provided an operator to concatenate regexp
		 * objects; then these could be componentised and made clearer to read.
		 * Or, an sprintf() analogue would help, but I don't want to include
		 * one soley for this. So, the above expressions for QNAME and NCNAME
		 * are written out explicitly each time. This is where lexer generators
		 * are useful...
		 */
		/* TODO: confirm QNAME and NCNAME, esp wrt unicode */
		{ re: /^([\w\d][\w\d.]*:)?\*/,               tok: tok.NAMETEST },
		{ re: /^([\w\d][\w\d.]*:)?[\w\d][\w\d.]*/,   tok: tok.NAMETEST },
		{ re: /^([\w\d][\w\d.]*:)?[\w\d][\w\d.]*/,   tok: tok.FUNCTION },
		{ re: /^\$([\w\d][\w\d.]*:)?[\w\d][\w\d.]*/, tok: tok.VARIABLE },

		{ re: /^(comment|text|node)/,                tok: tok.NODETYPE },
		{ re: /^(processing-instruction)/,           tok: tok.NODETYPE },
		{ re: /^(following|following-sibling)/,      tok: tok.AXISNAME },
		{ re: /^(preceding|preceding-sibling)/,      tok: tok.AXISNAME },
		{ re: /^(descendant|descendant-or-self)/,    tok: tok.AXISNAME },
		{ re: /^(namespace|attribute|self|child)/,   tok: tok.AXISNAME },
		{ re: /^(ancestor|ancestor-or-self|parent)/, tok: tok.AXISNAME },

		{ re: /^$/, tok: tok.EOF   },
		{ re: /^./, tok: tok.ERROR }
	];

	function skipwhitespace(s) {
		/*
		 * See "XML 1.0",
		 * [3]: S ::= (#x20 | #x9 | #xD | #xA)+
		 */
		return s.replace(/^\s+/, '');	/* TODO: confirm \s is equivalent */
	}

	function unabbreviate(s) {
		const abbrs = [
			{ re: /^@/,    rs: "attribute::"                 },
			{ re: /^\/\//, rs: "descendant-or-self::node()/" },
			{ re: /^\.\./, rs: "parent::node()"              },
			{ re: /^\./,   rs: "self::node()"                }
		];

		for (var i in abbrs) {
			s = s.replace(abbrs[i].re, abbrs[i].rs);
		}

		return s;
	}

	/*
	 * TODO: explain we mask out things we wish to exclude
	 * TODO: explain this is equivalent to state or zones
	 */
	function specialcases(mask, prev, s) {
		var m;

		/* S3.7P4: "If there is a preceding token and the preceding token is
		 * not one of @, ::, (, [ or an Operator, then a * must be recognised
		 * as a MultiplyOperator and an NCName must be recognised as an
		 * OperatorName." */
		if (prev != null) {
			switch (prev) {
			case tok.OPENGROUP:
			case tok.OPENPRED:
			case tok.AXISSEP:
			case tok.SEQOP:
			case tok.SETOP:
			case tok.EQUOP:
			case tok.RELOP:
			case tok.ADDOP:
			case tok.MULOP:
				break;

			default:
				mask &= ~tok.FUNCTION;
				mask &= ~tok.NAMETEST;
				mask &= ~tok.AXISNAME;
				return mask;
			}
		}

		m = s.match(/[\w\d][\w\d.]*/);
		if (m != null) {
			s = s.substring(m[0].length, s.length);
			s = skipwhitespace(s);
		}

		/* S3.7P5: "If the character following an NCName (possibly after
		 * intervening ExprWhitespace) is (, then the token must be recognised
		 * as a NodeType or a FunctionName." */
		if (m != null && /^\(/.test(s)) {
			mask &= tok.NODETYPE | tok.FUNCTION;
			return mask;
		}

		/* S3.7P6: "If the two characters following an NCName (possibly after
		 * intervening ExprWhitespace) are ::, then the token must be
		 * recognised as an AxisName." */
		if (m != null && /^::/.test(s)) {
			mask &= tok.AXISNAME;
			return mask;
		}

		/* TODO: this could be made unneccessary with precidence in the lexer table */
		/* S3.7P7: "Otherwise, the token must not be recognised as a
		 * MultiplyOperator, an OperatorName, a NodeType, a FunctionName, or an
		 * AxisName. */
		mask &= ~tok.MULOP;
		mask &= ~tok.ANDOP;
		mask &= ~tok.OROP;
		mask &= ~tok.NODETYPE;
		mask &= ~tok.FUNCTION;
		mask &= ~tok.AXISNAME;

		return mask;
	}

	function getnexttoken(s, prev) {
		var mask;
		var longest;
		var l;

		s = skipwhitespace(s);
		s = unabbreviate(s);

		mask = 0;
		l    = [ ];

		for (var i in lexemes) {
			if (lexemes[i].re.test(s)) {
				mask |= lexemes[i].tok;
				l.push(lexemes[i]);
			}
		}

		mask &= specialcases(mask, prev, s);

		longest = null;

		for (var w in l) {
			var m;

			if (~mask & l[w].tok) {
				continue;
			}

			m = s.match(l[w].re);
			if (m == null) {
				return null;
			}

			if (longest == null || m[0].length > longest.m[0].length) {
				longest = {
					l: l[w],
					m: m
				};
			}
		}

		return longest;
	}

	// XXX: remove
	this.skipwhitespace = skipwhitespace;
	this.unabbreviate   = unabbreviate;
	this.specialcases   = specialcases;
	this.getnexttoken   = getnexttoken;
	this.tok = tok;

	this.setresolver = function (TODO) {
		/* TODO: NS resolver same as DOM XPath interface */
	}

	this.query = function (element, path) {
		/* TODO: this is the public interface */
	}

});

