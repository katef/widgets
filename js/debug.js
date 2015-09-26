/* $Id: debug.js 316 2012-02-22 18:10:48Z kate $ */

document.onkeyup = function (e) {
	var e = window.event ? event : e;

	/* see http://elide.org/snippets/css.js */
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

	/* see http://elide.org/snippets/css.js */
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

	/* see http://elide.org/snippets/css.js */
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

	function loadstylesheet(doc, href) {
		var head, link;

		if (doc.getElementById(href)) {
			return;
		}

		head = doc.getElementsByTagName('head')[0];
		link = doc.createElement('link');

		link.id    = href;
		link.href  = href;
		link.type  = 'text/css';
		link.rel   = 'stylesheet';
		link.media = 'all';

		head.appendChild(link);
	}

	/* 71 is 'g' */
	if (e.altKey && e.keyCode == 71) {
		var html;

		html = document.body.parentNode;

/* TODO: store state in cookie */
		if (hasclass(html, 'debug')) {
			removeclass(html, 'debug');
		} else {
			loadstylesheet(document, '/css/debug.css');
			addclass(html, 'debug');
		}
	}
}

