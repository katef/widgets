/* $Id$ */

var Expander = new (function () {

	function classcontains(e, needle) {
		var a = e.getAttribute("class").split(" ");

		for (var i = 0; i < a.length; i++) {
			if (a[i] == needle) {
				return true;
			}
		}

		return false;
	}

	function classreplace(e, replacement) {
		var i;

		a = e.getAttribute("class").split(" ");

		for (i = 0; i < a.length; i++) {
			if (a[i] == "collapsed" || a[i] == "expanding" || a[i] == "expanded") {
				a[i] = replacement;
				break;
			}
		}

		if (i == a.length) {
			a.push(replacement);
		}

		e.setAttribute("class", a.join(" "));
	}

	this.down = function (a) {
		/* TODO: hold diagonal */
	}

	this.expand = function (a) {
		var dl = a.parentNode.parentNode;
		var endclass;

		if (classcontains(dl, "expanded")) {
			endclass = "collapsed";
		} else {
			endclass = "expanded";
		}

		if (classcontains(dl, endclass)) {
			return;
		}

		classreplace(dl, "expanding");

		window.setTimeout(function() {
				classreplace(dl, endclass);
			}, 50);
	}

	/* TODO: can this be added to a stack of init functions? */
	this.init = function (root) {
		var dl = root.getElementsByTagName("dl");

		/* Here I would use XPath, if it were supported... */
		for (var i = 0; i < dl.length; i++) {
			if (!classcontains(dl[i], "expandable")) {
				continue;
			}

			var dt = dl[i].getElementsByTagName("dt")[0];

			var a = document.createElementNS('http://www.w3.org/1999/xhtml', 'a');
			a.setAttribute("onclick", "javascript:Expander.expand(this)");
			a.setAttribute("onmousedown", "javascript:Expander.down(this)");
			a.innerHTML  = dt.innerHTML;
			dt.innerHTML = null;
			dt.appendChild(a);

			if (!classcontains(dl[i], "expanded")) {
				classreplace(dl[i], "collapsed");
			}
		}
	}

});

