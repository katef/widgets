/*
 * <body onload="ConvertRowsToLinks('dl')">
 * Adapted from http://radio.javaranch.com/pascarello/2005/05/19/1116509823591.html
 */

var Rowlinks = new (function () {

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
			rows[i].classList.add("rowlink");
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

