/* $Id$ */

var Expander = new (function () {

	function classcontains(e, needle) {
		var a = e.getAttribute("class");

		if (a == null) {
			return false;
		}

		a = a.split(" ");

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
			if (a[i] == "collapsed" || a[i] == "expanded") {
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
		var dt = a.parentNode;
		var endclass;
		var r;

/* TODO: option to collapse adjacent siblings, e.g. for accordian style */

		r = !classcontains(dt, "current");

		if (classcontains(dl, "expanded")) {
			endclass = "collapsed";
		} else {
			endclass = "expanded";
		}

		if (classcontains(dl, endclass)) {
			return r;
		}

		classreplace(dl, endclass);

		return r;
	}

	/* TODO: can this be added to a stack of init functions? */
	this.init = function (root, dlname, dtname) {
		var dl = root.getElementsByTagName(dlname);

		for (var i = 0; i < dl.length; i++) {
			if (!classcontains(dl[i], "expandable")) {
				continue;
			}

			var dt = dl[i].getElementsByTagName(dtname);
			for (var j = 0; j < dt.length; j++) {
				var a = dt[j].getElementsByTagName("a");
				if (a.length > 0) {
					a = a[0];
				} else {
					a = document.createElementNS('http://www.w3.org/1999/xhtml', 'a');
					a.innerHTML  = dt[j].innerHTML;

					dt[j].innerHTML = null;
					dt[j].appendChild(a);
				}

				/* XXX: returning false (to prevent bubbling) is deprecated */
				a.setAttribute("onclick",     "return Expander.expand(this);");
//				a.setAttribute("onmousedown", "return Expander.down(this);");
			}

			if (!classcontains(dl[i], "expanded")) {
				classreplace(dl[i], "collapsed");
			}
		}
	}

});

