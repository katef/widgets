/* $Id$ */

var Expander = new (function () {

	this.toggle = function (a, accordion, expand, oneway) {
		var dl, dt = a.parentNode;
		var endclass;
		var r;

		for (dl = dt; dl != null; dl = dl.parentNode) {
			if (Class.has(dl, "expandable")) {
				break;
			}
		}

		r = !Class.has(dt, "current");

		if (dl == null) {
			return r;
		}

		if (accordion) {
			var xdt = dl.getElementsByTagName("dt");
			for (var j = 0; j < xdt.length; j++) {
				Class.remove(xdt[j], "current");
			}

			if (r) {
				Class.add(dt, "current");
			}
		}

		if (expand) {
			if (oneway) {
				endclass = oneway;
			} else {
				if (Class.has(dl, "expanded")) {
					endclass = "collapsed";
				} else {
					endclass = "expanded";
				}
			}

			Class.remove(dl, "expanded");
			Class.remove(dl, "collapsed");

			Class.add(dl, endclass);
		}

		return r;
	}

	this.init = function (root, dlname, dtname, accordion, expand) {
		var dl = root.getElementsByTagName(dlname);

		for (var i = 0; i < dl.length; i++) {
			if (!Class.has(dl[i], "expandable")) {
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

			if (!accordion && !Class.has(dl[i], "expanded")) {
				Class.add(dl[i], "collapsed");
			}
		}
	}

});

