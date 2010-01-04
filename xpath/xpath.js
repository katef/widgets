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
 * TODO: merge all enums and names-of-enums; multiple tables is silly. for (i in Object) will get the keys
 */

var XPath = new (function () {

	/*
	 * Lexical Analysis
	 */
	lexing = new (function () {
		/*
		 * Lexemes. See S3.7
		 *
		 * Unfortunately the XPath specification's choice of production names is
		 * too elaborate for my eyes, so I've opted for less painful names here.
		 */
		tok = {
			/* TODO: move these to the end, for the parsing table's convenience */
			NUMBER:     1 <<  0,
			LITERAL:    1 <<  1,

			COMMA:      1 <<  2,
			AXISSEP:    1 <<  3,
			OPENPRED:   1 <<  4,
			CLOSEPRED:  1 <<  5,
			OPENGROUP:  1 <<  6,
			CLOSEGROUP: 1 <<  7,

			OROP:       1 <<  8,
			ADDOP:      1 <<  9,
			SUBOP:      1 << 10,
			MULOP:      1 << 11,
			ANDOP:      1 << 12,
			EQUOP:      1 << 13,
			RELOP:      1 << 14,
			SEQOP:      1 << 15,
			SETOP:      1 << 16,

			NODETYPE:   1 << 17,
			PINODE:     1 << 18,
			FUNCTION:   1 << 19,
			NAMETEST:   1 << 20,
			AXISNAME:   1 << 21,
			VARIABLE:   1 << 22,

			EOF:        1 << 23,
			ERROR:      1 << 24
		};

		/* TODO: explain this is ordered by precidence (which only matters for ERROR). */
		/* TODO: but longest match wins. so intersect, find longest, then highest */
		/* TODO: explain: table of regex -> value, and optional match-extraction */
		/* TODO: store previous lexeme, and spelling */
		/* TODO: remove match:; use match arrays from the regexps themselves */
		/* TODO: explain ambiguity in matching is ok here in some cases; see specialcases() */
		/* TODO: explain neither the regex nor the token value is unique (yes, really). but both together are unique */
		/* TODO: if all we end up with is mappings to tokens, flip the array to index by tok -> re */
		/* TODO: consider coding these into an FSM */
		/* TODO: make tokens an object, with a .tostring method? handy if passing them out, or printing them */
		/* TODO: rename EOF EOI? */
		var lexemes = [
			{ re: /^,/,            tok: tok.COMMA      },
			{ re: /^\(/,           tok: tok.OPENGROUP  },
			{ re: /^\)/,           tok: tok.CLOSEGROUP },
			{ re: /^\[/,           tok: tok.OPENPRED   },
			{ re: /^\]/,           tok: tok.CLOSEPRED  },
			{ re: /^::/,           tok: tok.AXISSEP    },

			{ re: /^"[^"]*"/,      tok: tok.LITERAL    }, // XXX: match: function (s) { return s.match(/^.(.*).$/)[0]; } },
			{ re: /^'[^']*'/,      tok: tok.LITERAL    },
			{ re: /^\.\d/,         tok: tok.NUMBER     },
			{ re: /^\d(\.\d?)?/,   tok: tok.NUMBER     }, // XXX: match: function (s) { return Number(s);              } },

			{ re: /^or/,           tok: tok.OROP       },
			{ re: /^\+/,           tok: tok.ADDOP      },
			{ re: /^-/,            tok: tok.SUBOP      },
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
			{ re: /^(processing-instruction)/,           tok: tok.PINODE   },
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
			var abbrs = [
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

		/* TODO: merge into token table somehow? */
		this.tokname = function(t) {
			for (var i in tok) {
				if (tok[i] == t) {
					return i;
				}
			}

			return "?";
		}

		this.ppname = function(l) {
			return '<' + lexing.tokname(l.tok) + ' "' + l.m[0] + '">';
		}

		this.pptok = function(t) {
			return '<' + lexing.tokname(t) + '>';
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
			if (prev !== null) {
				switch (prev) {
				case tok.OPENGROUP:
				case tok.OPENPRED:
				case tok.AXISSEP:
				case tok.SEQOP:
				case tok.SETOP:
				case tok.EQUOP:
				case tok.RELOP:
				case tok.ADDOP:
				case tok.SUBOP:
				case tok.MULOP:
				case tok.ANDOP:
				case tok.OROP:
					break;

				default:
					mask &= ~tok.FUNCTION;
					mask &= ~tok.NAMETEST;
					mask &= ~tok.AXISNAME;
					return mask;
				}
			}

			m = s.match(/[\w\d][\w\d.]*/);
			if (m !== null) {
				s = s.substring(m[0].length, s.length);
				s = skipwhitespace(s);
			}

			/* S3.7P5: "If the character following an NCName (possibly after
			 * intervening ExprWhitespace) is (, then the token must be recognised
			 * as a NodeType or a FunctionName." */
			if (m !== null && /^\(/.test(s)) {
				mask &= tok.PINODE | tok.NODETYPE | tok.FUNCTION;
				return mask;
			}

			/* S3.7P6: "If the two characters following an NCName (possibly after
			 * intervening ExprWhitespace) are ::, then the token must be
			 * recognised as an AxisName." */
			if (m !== null && /^::/.test(s)) {
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
			mask &= ~tok.PINODE;
			mask &= ~tok.FUNCTION;
			mask &= ~tok.AXISNAME;

			return mask;
		}

		/* TODO: explain usage */
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
				if (m === null) {
					return null;
				}

				if (longest === null || m[0].length > longest.m[0].length) {
					longest = {
						l: l[w],
						m: m
					};
				}
			}

			/* XXX: longest can be null */
			longest.s = s.substring(longest.m[0].length, s.length);

			return longest;
		}

		/* TODO: explain returns an array, terminated by EOF or ERROR */
		this.lex = function (s) {
			var a;
			var prev;

			a = [ ];

			prev = null;

			do {
				var t;

				t = getnexttoken(s, prev);

				a.push({
						tok: t.l.tok,
						m:   t.m
					});

				s = t.s;

				prev = t.l.tok;
			} while (t.l.tok != tok.ERROR && t.l.tok != tok.EOF);

			return a;
		}
	});


	/*
	 * Syntax Analysis
	 */
	parsing = new (function () {

		/* TODO: explain what these are */
		var rules = {
			Predicate:              1 << 31 |  0,
			FilterExpr:             1 << 31 |  1,
			RelativeLocationPath:   1 << 31 |  2,
			NodeTest:               1 << 31 |  3,
			Step:                   1 << 31 |  4,
			LocationPath:           1 << 31 |  5,
			PathExpr:               1 << 31 |  6,
			EqualityExprGlue:       1 << 31 |  7,
			Expr:                   1 << 31 |  8,
			AdditiveExprGlue:       1 << 31 |  9,
			MultiplicativeExprGlue: 1 << 31 | 10,
			UnaryExpr:              1 << 31 | 11,
			Arguments:              1 << 31 | 12,
			PrimaryExpr:            1 << 31 | 13,
			AndExpr:                1 << 31 | 14,
			OrExpr:                 1 << 31 | 15,
			EqualityExpr:           1 << 31 | 16,
			MultiplicativeExpr:     1 << 31 | 17,
			UnionExpr:              1 << 31 | 18,
			AdditiveExpr:           1 << 31 | 19,
			RelativeLocationList:   1 << 31 | 20,
			Predicates:             1 << 31 | 21,
			AbsoluteLocationList:   1 << 31 | 22,
			RelationalExpr:         1 << 31 | 23,
			ArgumentsBody:          1 << 31 | 24
		};

		/* TODO: do we even need these? or can i inline function()s as below? */
		var actions = {
			TODOA: 1 << 31 | 1 << 30 | 0,
			TODOB: 1 << 31 | 1 << 30 | 1,
			TODOC: 1 << 31 | 1 << 30 | 2
		};

		/* TODO: normalise terminology: rules/symbols */
		/* TODO: merge into symbol table somehow? */
		function rulename(r) {
			for (var i in rules) {
				if (rules[i] == r) {
					return i;
				}
			}

			return "?";
		}

		function symboltype(s) {
			if (s & 1 << 30) return "action";
			if (s & 1 << 31) return "rule";
			                 return "terminal";
		}

		function symbolname(s) {
			switch (symboltype(s)) {
			case "action":   return "TODO";	/* TODO: implement */
			case "rule":     return rulename(s);
			case "terminal": return lexing.pptok(s);
			}
		}

		/*
		 * Conveniences for brevity
		 */
		var t = tok;
		var r = rules;

		/* TODO: explain this array is indexed by table[x][y] number */
		/* TODO: merge epislons (this will screw up cell numbers; be careful. commit first?) */
		/* TODO: inline function()s here for actions */
		var replacements = [
			[ t.MULOP, r.UnaryExpr, r.MultiplicativeExpr          ],
			[                                                     ],
			[ r.LocationPath                                      ],
			[ r.PrimaryExpr, r.FilterExpr, r.RelativeLocationPath ],
			[ r.Predicate, r.FilterExpr                           ],
			[                                                     ],
			[ t.ANDOP, r.EqualityExprGlue, r.AndExpr              ],
			[                                                     ],
			[ t.SETOP, r.PathExpr, r.UnionExpr                    ],
			[                                                     ],
			[ t.OROP, r.Expr                                      ],
			[                                                     ],
			[ r.Step, r.RelativeLocationList                      ],
			[ r.RelativeLocationPath                              ],
			[ t.SEQOP, r.AbsoluteLocationList                     ],
			[ t.VARIABLE                                          ],
			[ t.OPENGROUP, r.Expr, t.CLOSEGROUP                   ],
			[ t.LITERAL                                           ],
			[ t.NUMBER                                            ],
			[ t.FUNCTION, t.OPENGROUP, r.Arguments, t.CLOSEGROUP  ],
			[ r.AdditiveExprGlue, r.EqualityExpr                  ],
			[ r.Expr, r.ArgumentsBody                             ],
			[                                                     ],
			[ t.EQUOP, r.EqualityExprGlue                         ],
			[                                                     ],
			[ t.ADDOP, r.MultiplicativeExprGlue                   ],
			[ t.SUBOP, r.MultiplicativeExprGlue                   ],
			[                                                     ],
			[ t.SEQOP, r.RelativeLocationPath                     ],
			[                                                     ],
			[ r.EqualityExprGlue, r.AndExpr, r.OrExpr             ],
			[ r.Predicate, r.Predicates                           ],
			[                                                     ],
			[ r.MultiplicativeExprGlue, r.RelationalExpr          ],
			[ r.RelativeLocationPath                              ],
			[                                                     ],
			[ t.COMMA, r.Expr, r.ArgumentsBody                    ],
			[                                                     ],
			[ r.UnaryExpr, r.MultiplicativeExpr, r.AdditiveExpr   ],
			[ t.NAMETEST                                          ],
			[ t.NODETYPE, t.OPENGROUP, t.CLOSEGROUP               ],
			[ t.PINODE, t.OPENGROUP, t.LITERAL, t.CLOSEGROUP      ],
			[ t.RELOP, r.AdditiveExprGlue                         ],
			[                                                     ],
			[ t.OPENPRED, r.Expr, t.CLOSEPRED                     ],
			[ t.SUBOP, r.UnaryExpr                                ],
			[ r.PathExpr, r.UnionExpr                             ],
			[ t.AXISNAME, t.AXISSEP, r.NodeTest, r.Predicates     ],
			[ r.NodeTest, r.Predicates                            ],
		];

		/*
		 * This is the grammar specified by the W3C spec, with the following
		 * modifications:
		 *
		 *  - Productions and alternatives referencing abbreviated tokens are
		 *    elided, since these are expanded during lexing in this
		 *    implementation (see lexer.unabbreviate).
		 *  - The AxisName production is elided, since axis names are lexed to
		 *    a separate token in this implementation (see lexer.tok.AXISNAME).
		 *  - Semantically similar tokens are merged together, since these are
		 *    disambiguated during semantic analysis (see lexer.tok.EQUOP as
		 *    opposed to having two separate alts for '=' and '!=' in the
		 *    EqualityExpr production, for example).
		 *  - The grammar is converted to LL(1) by the usual transformations.
		 *
		 * TODO: write up the grammar, probbaly as an external document
		 * TODO: predictive parsing table. see appel p51 (bad ref. see the dragon book instead)
		 * TODO: explain that you probably ought to see the supporting documentation
		 * TODO: these are replacements.* numbers. undefined (empty) for "can't happen"
		 */ 
		var table = [
			[   ,   ,   ,   , 44,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,    ],
			[   ,   ,   ,   ,  4,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,  5,  5,   ,  5,  5,   ,    ],
			[   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   , 12, 12,   , 12, 12,   ,    ],
			[   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   , 40, 41,   , 39,   ,   ,    ],
			[   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   , 48, 48,   , 48, 47,   ,    ],
			[   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   , 14,   , 13, 13,   , 13, 13,   ,    ],
			[  3,  3,   ,   ,   ,   ,  3,   ,   ,   ,   ,   ,   ,   ,   ,  2,   ,  2,  2,  3,  2,  2,  3,    ],
			[ 20, 20,   ,   ,   ,   , 20,   ,   ,   , 20,   ,   ,   ,   , 20,   , 20, 20, 20, 20, 20, 20,    ],
			[ 30, 30,   ,   ,   ,   , 30,   ,   ,   , 30,   ,   ,   ,   , 30,   , 30, 30, 30, 30, 30, 30,    ],
			[ 33, 33,   ,   ,   ,   , 33,   ,   ,   , 33,   ,   ,   ,   , 33,   , 33, 33, 33, 33, 33, 33,    ],
			[ 38, 38,   ,   ,   ,   , 38,   ,   ,   , 38,   ,   ,   ,   , 38,   , 38, 38, 38, 38, 38, 38,    ],
			[ 46, 46,   ,   ,   ,   , 46,   ,   ,   , 45,   ,   ,   ,   , 46,   , 46,   , 46, 46, 46, 46, 46 ],
			[ 21, 21,   ,   ,   ,   , 21, 22,   ,   , 21,   ,   ,   ,   , 21,   , 21, 21, 21, 21, 21, 21,    ],
			[ 18, 17,   ,   ,   ,   , 16,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   , 19,   ,   , 15,    ],
			[   ,   ,  7,   ,   ,  7,   ,  7,  7,   ,   ,   ,  6,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,  7 ],
			[   ,   , 11,   ,   , 11,   , 11, 10,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   , 11 ],
			[   ,   , 24,   ,   , 24,   , 24, 24,   ,   ,   , 24, 23,   ,   ,   ,   ,   ,   ,   ,   ,   , 24 ],
			[   ,   ,  1,   ,   ,  1,   ,  1,   ,  1,   ,  0,  1,  1,  1,   ,   ,   ,   ,   ,   ,   ,   ,  1 ],
			[   ,   ,  9,   ,   ,  9,   ,  9,  9,  9,  9,  9,  9,  9,  9,   ,  8,   ,   ,   ,   ,   ,   ,  9 ],
			[   ,   , 27,   ,   , 27,   , 27, 27, 25, 26,   , 27, 27, 27,   ,   ,   ,   ,   ,   ,   ,   , 27 ],
			[   ,   , 29,   ,   , 29,   , 29, 29, 29, 29, 29, 29, 29, 29, 28, 29,   ,   ,   ,   ,   ,   , 29 ],
			[   ,   , 32,   , 31, 32,   , 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,   ,   ,   ,   ,   ,   , 32 ],
			[   ,   , 35,   ,   , 35,   , 35, 35, 35, 35, 35, 35, 35, 35,   , 35, 34, 34,   , 34, 34,   , 35 ],
			[   ,   , 43,   ,   , 43,   , 43, 43,   ,   ,   , 43, 43, 42,   ,   ,   ,   ,   ,   ,   ,   , 43 ],
			[   ,   , 36,   ,   ,   ,   , 37,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,   ,    ]
		];


		/*
		 * Floor of the binary logarithm of i.
		 * This is equivalent to Math.floor(Math.log(i) / Math.log(2));
		 * Given a power of 2, this returns the 0-based index of that bit.
		 */
		function ilog2(i) {
			var l;

			l = 0;

			while (i >>= 1) {
				l++;
			}

			return l;
		}

		/* TODO: find unique values from an array */
		function unique(t) {
			var a;

			a = [];

			function last(w) {
				for (var j = w + 1; j < t.length; j++) {
					if (t[j] == t[w]) {
						return false;
					}
				}

				return true;
			}

			for (var i = 0; i < t.length; i++) {
				if (last(i)) {
					a.push(t[i]);
				}
			}

			return a;
		}

		/* TODO: rename */
		function tablerhs(rule, tok) {
			var r;

			/* TODO: mask out bits */
			r = table[rule & ~(1 << 31)][ilog2(tok)];
			if (r === undefined) {
				return null;
			}

			return replacements[r];
		}

		/* TODO: do i want a CST? probably not. just the AST please. */
		/* have functions inlined in the rule productions which produce the AST by just grabbing tokens which matter. */
		/* TODO: also, conceternate multiple predicates into one expression? */
		/* TODO: various transforms on the AST after it is produced */
		/* TODO: consider using action symbols inlined into the grammar */
		/* TODO: make error messages with production names map them on to human-readable names. */
		/* TODO: likewise map fixed tokens onto their literal spellings (or provide an example spelling) */
		this.parse = function (a) {
			var stack;
			var curr;

			a.reverse();	/* TODO: explain. it's a queue, see? */

			/* TOOD: explain this is the start symbol */
			/* TODO: do we need EOF on here? probably if we don't check for trailing input tokens */
			stack = [ t.EOF, rules.Expr ];

			curr = a.pop();
			/* TODO: can disregard this being null, right? since that'll just naturally give a parse error */

			do {
				var x;

				if (curr.tok == tok.ERROR) {
					throw 'Lexical error: Unrecognised token ' + lexing.ppname(curr);
					return null;
				}

				x = stack.pop();

				switch (symboltype(x)) {
				case "action":	/* TODO: placeholder */
					/* call it */
					break;

				case "rule":
					var r;

					/* TODO: rename */
					/* TODO: move parse error message construction into a convenient function */
					r = tablerhs(x, curr.tok);
					if (r === null) {
						var m;
						var w;
						var rep;

						m = [];
						w = [];

						rep = table[x & ~(1 << 31)];
						for (var i in rep) {
							if (i === undefined) {
								continue;
							}

							w = w.concat(replacements[rep[i]]);
						}

						if (w.length == 0) {
							/* TODO: an epislon; follow through */
							w.push(stack.pop());
						}

						/* TODO: make w contain unique elements only */
						w = unique(w);

						for (var i in w) {
							m.push(symbolname(w[i]));
						}

						throw 'Syntax error: Unexpected ' + lexing.ppname(curr) + '; expected one of ' + m;
					}

					/* TODO: explain this silly dance is to avoid r.reverse(), which would modify rules[] */
					stack = stack.concat([].concat(r).reverse());
					break;

				case "terminal":
					if (x == curr.tok) {
						curr = a.pop();
					} else {
						throw 'Syntax error: Unexpected ' + lexing.ppname(curr) + '; expected ' + symbolname(x);
					}
					break;
				}

			} while (curr.tok != t.EOF);

			/* TODO: if stack is not empty (need EOF on it at all?), throw "Unexpected end of input; expected blah blah" */
			if (stack.length != 0) {
				var x;

				/* TODO: skip actions */
				x = stack.pop();

				/* TODO: make a convenience to print a stack item no matter what it is */
				throw 'Syntax error: unexpected end of input: expected ' + symbolname(x);
			}
		}
	});


	/*
	 * Debugging Interfaces
	 */
	this.debug = new (function () {
		this.dump_lex = function (s) {
			var a;

			a = lexing.lex(s);

			/* TODO: maybe don't return an array of tokens; no need */
			for (var i in a) {
				console.log(' ' + lexing.ppname(a[i]));
			}
		}

		/* TODO: parse only; do not construct an AST */
		this.parse = function (s) {
			var a;

			a = lexing.lex(s);
			parsing.parse(a);
		}

		this.dump_ast = function (s) {
			/* TODO: return JSON AST */
		}
	});


	/*
	 * Public Interfaces
	 */

	this.setresolver = function (TODO) {
		/* TODO: NS resolver same as DOM XPath interface */
	}

	this.eval = function (element, path) {
		var a;

		/* TODO: this is the public interface */
		a = lexing.lex(path);
		parsing.parse(a);
	}

});

