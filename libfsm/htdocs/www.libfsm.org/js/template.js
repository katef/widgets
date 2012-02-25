/* $Id$ */

/*
 * Apply a template against the given context, substituting out processing
 * instructions.
 *
 * Parameters are:
 *  e   - A DOM Node containing a template. The parent element is ignored.
 *  ctx - Context passed to "this" when evaluating expressions.
 *
 * Expressions are processing instructions of the form <?js 1 + 2 ?> or
 * attributes of the form <a href="{ 1 + 2 }"/>.
 *
 * Expressions for PIs evaluate to a DOM Node (in which case the PI is replaced
 * with that Node), or otherwise the PI is substituted with a TextNode.
 * Expressions for attributes must evaluate to a type which may be implicitly
 * converted to a string.
 *
 * During evaluation of an expression, properties from ctx are made available
 * as local variables. The "this" object is bound to the DOM node for that PI
 * or attribute node.
 *
 * Returns a DocumentFragment containing the expanded template.
 */
function Template(e, ctx) {
	var frag;

	/*
	 * Annoyingly the DOM spec is unclear about whether replacechild() may
	 * replace a Node with a DocumentFragment('s children). In practice, it
	 * does not work on several implementations, so I am providing my own.
	 */
	function xreplacechild(parent, newnode, oldnode) {
		if (newnode instanceof DocumentFragment) {
			parent.insertBefore(newnode, oldnode);
			parent.removeChild(oldnode);
			return;
		}

		parent.replaceChild(newnode, oldnode);
	}

	function exprvalue(node, expr) {
		/*
		 * Here I would say s = eval.apply(node, [ expr ]); but apparently
		 * eval() needs the global context.
		 */
		(function () {
			with (ctx || {}) {
				s = eval(expr);
			}
		}).apply(node);

		return s;
	}

	function pivalue(node) {
		var s;

		s = exprvalue(node, node.nodeValue);

		switch (true) {
		case s === undefined:
		case s === null:
		case s === '':
			return document.createTextNode('');

		case s instanceof Node:
			return s;

		default:
			return document.createTextNode(s);
		}
	}

	function attrvalue(node) {
		var a;

		a = node.nodeValue.split('{');
		for (var i = 1; i < a.length; i++) {
			var v;

			a[i] = a[i].split('}');
			v = exprvalue(node, a[i][0]);
			if (v == undefined || v == null) {
				return undefined;
			}
			a[i] = v + a[i][1];
		}

		return a.join('');
	}

	/*
	 * Clone out children of the template, so that we may modify them,
	 */
	{
		frag = document.createDocumentFragment();

		for (var i = 0; i < e.childNodes.length; i++) {
			frag.appendChild(e.childNodes[i].cloneNode(true));
		}
	}

	/*
	 * Recurr through the clones, substituting PI nodes for their respective
	 * evaluated replacements.
	 */
	(function (node, parent) {
		if (node.nodeType == document.PROCESSING_INSTRUCTION_NODE
		 && node.nodeName == 'js') {
			xreplacechild(parent, pivalue(node), node);
		}

		for (var i = 0; node.attributes && i < node.attributes.length; i++) {
			var v;

			v = attrvalue(node.attributes[i]);

			/*
			 * Here an attribute is requesting its own removal; this will
			 * produce <a href="...">...</a> when title is undefined:
			 *
			 *   <a href="{ url }" title="{ title }"><?js text ?></a>
			 */
			if (v === undefined) {
				node.removeAttribute(node.attributes[i].name);
				i--;
				continue;
			}

			/*
			 * Here an attribute is requesting we replace its node with its
			 * own children. This is pretty odd, but permits this:
			 *
			 *   <a href="{ url || this.ownerElement }"><?js text ?></a>
			 *
			 * which will be equivalent to <?js text ?> when url is null.
			 *
			 * A slightly more convoluted case is:
			 *
			 *   <meta name="date" content="{ date || this.ownerElement }"/>
			 *
			 * Where the node has no children, and so it will be replaced with
			 * an empty document fragment, which has the effect of simply
			 * removing the node when date is null.
			 */
			if (v == node) {
				var f;

				f = document.createDocumentFragment();

				for (var i = 0; i < node.childNodes.length; i++) {
					f.appendChild(node.childNodes[i]);
				}

				xreplacechild(parent, f, node);
				node = parent;

				break;
			}

			node.attributes[i].nodeValue = v;
		}

		for (var i = 0; i < node.childNodes.length; i++) {
			arguments.callee(node.childNodes[i], node);
		}
	})(frag, null);

	return frag;
}

