
var Overlay = new (function () {

	this.init = function(root, id, n) {
		var doc;
		var o;

		doc = root.ownerDocument;

		if (doc.getElementById(id)) {
			return;
		}

		o = doc.createElement('ol');
		o.className = 'overlay';
		o.id        = id;

		for (var i = 0; i < n; i++) {
			var c = doc.createElement('li');

			o.appendChild(c);
		}

		root.appendChild(o);
	}

	/* TODO: handle resize to update height and width */

});

