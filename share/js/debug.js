/* $Id: debug.js 316 2012-02-22 18:10:48Z kate $ */

document.onkeyup = function (e) {
	var e = window.event ? event : e;

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
		var html, body, doc;

		body = document.body;
		html = document.body.parentNode;

/* TODO: store state in cookie */
		if (Class.has(html, 'debug')) {
			Class.remove(html, 'debug');
		} else {
			if (Overlay) {
				Overlay.init(body, 'rows', 24); /* enough for anyone */
				Overlay.init(body, 'cols', 32); /* enough for a screenfull */
			}

			loadstylesheet(document, '/css/debug.css');
			Class.add(html, 'debug');
		}
	}
}

