/* $Id$ */

function fireevent(node, type) {
	/* IE */
	if (node.fireEvent) {
		node.fireEvent('on' + type);
	}

	/* others */
	else if (document.createEvent) {
		var e;

		e = document.createEvent('HTMLEvents');
		if (e.initEvent) {
			e.initEvent(type, true, true);
		}
		if (node.dispatchEvent) {
			node.dispatchEvent(e);
		}
	}
}

