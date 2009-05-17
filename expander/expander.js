/* $Id$ */

function expand_classcontains(e, needle) {
	var a = e.getAttribute("class").split(" ");

	for (var i = 0; i < a.length; i++) {
		if (a[i] == needle) {
			return true;
		}
	}

	return false;
}

function expand_classreplace(e, replacement) {
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

function expand_down(a) {
	/* TODO: hold diagonal */
}

function expand(a) {
	var dl = a.parentNode.parentNode;
	var endclass;

	if (expand_classcontains(dl, "expanded")) {
		endclass = "collapsed";
	} else {
		endclass = "expanded";
	}

	if (expand_classcontains(dl, endclass)) {
		return;
	}

	expand_classreplace(dl, "expanding");

	window.setTimeout(function() {
			expand_classreplace(dl, endclass);
		}, 50);
}

/* TODO: can this be added to a stack of init functions? */
function init_expander() {
	var dl = document.getElementsByTagName("dl");

	/* Here I would use XPath, if it were supported... */
	for (var i = 0; i < dl.length; i++) {
		if (!expand_classcontains(dl[i], "expandable")) {
			continue;
		}

		var dt = dl[i].getElementsByTagName("dt")[0];

		var a = document.createElementNS('http://www.w3.org/1999/xhtml', 'a');
		a.setAttribute("onclick", "javascript:expand(this)");
		a.setAttribute("onmousedown", "javascript:expand_down(this)");
		a.innerHTML  = dt.innerHTML;
		dt.innerHTML = null;
		dt.appendChild(a);

		if (!expand_classcontains(dl[i], "expanded")) {
			expand_classreplace(dl[i], "collapsed");
		}
	}
}

