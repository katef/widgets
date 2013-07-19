/* $Id$ */

var Overlay = new (function () {

	this.init = function(root, id, n) {
		o = root.ownerDocument.createElement('ol');
		o.className = 'overlay';
		o.id        = id;

		for (var i = 0; i < n; i++) {
			var c = root.ownerDocument.createElement('li');

			o.appendChild(c);
		}

		root.ownerDocument.body.appendChild(o);
	}

	/* TODO: handle resize to update height and width */

});

