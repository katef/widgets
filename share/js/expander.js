/* $Id$ */

var Expander = new (function () {

	this.toggle = function (a, accordion, expand, oneway) {
		var dl, dt = a.parentNode;
		var endclass;
		var r;

		for (dl = dt; dl != null; dl = dl.parentNode) {
			if (dl.classList.contains("expandable")) {
				break;
			}
		}

		r = !dt.classList.contains("current");

		if (dl == null) {
			return r;
		}

		if (accordion) {
			var xdt = dl.getElementsByTagName("dt");
			for (var j = 0; j < xdt.length; j++) {
				xdt[j].classList.remove("current");
			}

			if (r) {
				dt.classList.add("current");
			}
		}

		if (expand) {
			if (oneway) {
				endclass = oneway;
			} else {
				if (dl.classList.contains("expanded")) {
					endclass = "collapsed";
				} else {
					endclass = "expanded";
				}
			}

			dl.classList.remove("expanded");
			dl.classList.remove("collapsed");

			dl.classList.add(endclass);
		}

		return r;
	}

	this.init = function (root, dlname, dtname, accordion, expand) {
		var dl;

		if (root.nodeName.toLowerCase() == dlname) {
			dl = root;
		} else {
			dl = root.getElementsByTagName(dlname);
		}

		for (var i = 0; i < dl.length; i++) {
			if (!dl[i].classList.contains("expandable")) {
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

					dt[j].innerHTML = '';
					dt[j].appendChild(a);
				}

				a.onclick = function () {
						return Expander.toggle(this, accordion, expand, false);
					};
			}

			if (!accordion && !dl[i].classList.contains("expanded")) {
				dl[i].classList.add("collapsed");
			}
		}
	}

});

