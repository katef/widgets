/* $Id$ */

var API = new (function () {
	function hasclass(node, klass) {
		var a, c;

		c = node.getAttribute('class');
		if (c == null) {
			return;
		}

		a = c.split(/\s/);

		for (var i in a) {
			if (a[i] == klass) {
				return true;
			}
		}

		return false;
	}

	function removeclass(node, klass) {
		var a, c;

		c = node.getAttribute('class');
		if (c == null) {
			return;
		}

		a = c.split(/\s/);

		for (var i = 0; i < a.length; i++) {
			if (a[i] == klass || a[i] == '') {
				a.splice(i, 1);
				i--;
			}
		}

		if (a.length == 0) {
			node.removeAttribute('class');
		} else {
			node.setAttribute('class', a.join(' '));
		}
	}

	function addclass(node, klass) {
		var a, c;

		a = [ ];

		c = node.getAttribute('class');
		if (c != null) {
			a = c.split(/\s/);
		}

		for (var i = 0; i < a.length; i++) {
			if (a[i] == klass || a[i] == '') {
				a.splice(i, 1);
				i--;
			}
		}

		a.push(klass);

		node.setAttribute('class', a.join(' '));
	}

	function togglenode(node) {
		if (hasclass(node, "expanded")) {
			removeclass(node, "expanded");
			addclass(node, "collapsed");
		} else {
			removeclass(node, "collapsed");
			addclass(node, "expanded");
		}
	}

	this.toggle = function(td, id) {
		var tbody;

		togglenode(td);

		tbody = document.getElementById(id);
		if (!tbody) {
			return;
		}

		togglenode(tbody);
	}

});

