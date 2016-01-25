/*
 * <body onload="ConvertRowsToLinks('dl')">
 * Adapted from http://radio.javaranch.com/pascarello/2005/05/19/1116509823591.html
 */

var Rowlinks = new (function () {

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

	this.convert = function (t) {
		var rows;

		rows = t.getElementsByTagName("tr");
		for (i = 0; i < rows.length; i++) {
			var link;

			link = rows[i].getElementsByTagName("a")
			if (link.length == 0) {
				continue;
			}

			rows[i].onclick = new Function("document.location.href='" + link[0].href + "'");

			addclass(rows[i], "rowlink");
		}
	}

	this.init = function (root) {
		var a;

		a = root.getElementsByTagName('table');
		for (var i = 0; i < a.length; i++) {
			convert(a[i]);
		}
	}

});

