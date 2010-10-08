/* $Id$ */

/*
 * Apply a template against the given context, substituting out processing
 * instructions.
 *
 * Parameters are:
 *  e   - A DOM Node containing a template. The parent element is ignored.
 *  ctx - Context passed to "this" when evaluating expressions.
 *
 * Expressions are processing instructions of the form <?js 1 + 2 ?>.
 * These may evaluate to a DOM Node (in which case the PI is replaced with that
 * Node), or otherwise the PI is substituted with a TextNode.
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

	function pivalue(expr) {
		var s;

		/*
		 * Here I would say s = eval.apply(ctx, [ expr ]); but apparently
		 * eval() needs the global context.
		 */
		(function () {
			s = eval(expr);
		}).apply(ctx);

		return s instanceof Node ? s : document.createTextNode(s);
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
			xreplacechild(parent, pivalue(node.nodeValue), node);
		}

		for (var i = 0; i < node.childNodes.length; i++) {
			arguments.callee(node.childNodes[i], node);
		}
	})(frag, null);

	return frag;
}

