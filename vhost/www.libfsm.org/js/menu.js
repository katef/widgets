/* $Id$ */

var Menu = new (function () {

	var delay = 125;	/* ms */

	/* Adapted from http://www.quirksmode.org/js/cookies.html */
	function setCookie(name, value, days) {
		var date, expires;

		if (days) {
			date = new Date();
			date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
			expires = "; expires=" + date.toGMTString();
		} else {
			expires = "";
		}

		document.cookie = name + "=" + value + expires + "; path=/; domain=libfsm.org";
	}

	/* Adapted from http://www.quirksmode.org/js/cookies.html */
	function getCookie(name) {
		var ca;

		name += "=";
		ca = document.cookie.split(';');

		for (var i = 0; i < ca.length; i++) {
			var c;

			c = ca[i];
			while (c.charAt(0) == ' ') {
				c = c.substring(1, c.length);
			}

			if (c.indexOf(name) == 0) {
				return c.substring(name.length, c.length);
			}
		}

		return null;
	}

	function contains(a, key) {
		for (var i = 0; i < a.length; i++) {
			if (a[i] == key) {
				return true;
			}
		}

		return false;
	}

	function findnode(id) {
		var a;

		a = document.getElementsByTagNameNS('http://www.w3.org/2000/svg', 'a');
		for (var i = 0; i < a.length; i++) {
			if (a[i] == null) {
				continue;
			}

			if (a[i].getAttributeNS('http://xml.libfsm.org/gv', 'node') != id) {
				continue;
			}

			return a[i];
		}

		return null;
	}

	function findedge(from, to) {
		var candidates = [];
		var edge, node;

		foreachedge(from, null, function (a, from, to) {
				var r;

				r = a.getAttributeNS('http://xml.libfsm.org/gv', 'reachable');
				if (r == null) {
					return;
				}

				r = r.split(' ');
				if (r == null) {
					return;
				}

				if (contains(r, to)) {
					candidates.push({
							a:    a,
							from: from,
							to:   to
						});
				}
			});

		return candidates[Math.floor(Math.random() * candidates.length)];
	}

	function findpage(url) {
		return forallnodes(function (a) {
				var re;

				re = a.getAttributeNS('http://xml.libfsm.org/gv', 'match');
				if (re == null) {
					return false;
				}

				re = new RegExp(re, 'i');

				if (re.test(url)) {
					return a.getAttributeNS('http://xml.libfsm.org/gv', 'node');
				}
			});
	}

	function forallnodes(f) {
		var a;

		a = document.getElementsByTagNameNS('http://www.w3.org/2000/svg', 'a');
		for (var i = 0; i < a.length; i++) {
			var r;

			if (a[i] == null) {
				continue;
			}

			r = f(a[i]);
			if (r) {
				return r;
			}
		}

		return null;
	}

	function foreachnode(id, f) {
		var a;

		a = document.getElementsByTagNameNS('http://www.w3.org/2000/svg', 'a');
		for (var i = 0; i < a.length; i++) {
			if (a[i] == null) {
				continue;
			}

			if (a[i].getAttributeNS('http://xml.libfsm.org/gv', 'node') == id) {
				f(a[i]);
			}
		}
	}

	function foreachedge(from, to, f) {
		var a;
		var node;

		node = findnode(from);
		if (!node) {
			return;
		}

		a = node.getElementsByTagNameNS('http://www.w3.org/2000/svg', 'g');
		for (var i = 0; i < a.length; i++) {
			var s;

			if (a[i] == null) {
				continue;
			}

			s = a[i].getAttributeNS('http://xml.libfsm.org/gv', 'edge');
			if (s == null) {
				continue;
			}

			s = s.split('-');
			if (s.length != 2) {
				continue;
			}

			if (s[0] != from) {
				continue;
			}

			if (to != null && s[1] != to) {
				continue;
			}

			f(a[i], s[0], s[1]);
		}
	}

	function transition(from, to) {
		var edge, node;

		edge = findedge(from, to) || findedge('start', to);
		node = findnode(edge.to);

		/* TODO: don't light up the text labels */
		/* TODO: gradually decrease delay with each recursion */

/* XXX: lastmost edge isn't lit? */

		setTimeout(function () {
				edge.a.setAttribute('class', 'hover');

				if (edge.to != to) {
					node.setAttribute('class', 'hover');

					setTimeout(function () {
							foreachnode(edge.to, function (a) {
									a.removeAttribute('class');
									edge.a.removeAttribute('class');
								});
						}, delay);

					transition(edge.to, to);
				} else {
					foreachnode(edge.to, function (a) {
							a.setAttribute('class', 'hover');
						});
					edge.a.removeAttribute('class');
				}
			}, delay);
	}

	this.save = function() {
/* XXX: never called? */
		setCookie('page', findpage(document.referrer), 0.5);
	}

	this.restore = function() {
		var from, to;
		var node, edge;

		from = getCookie('page')           || 'start';
		to   = findpage(document.referrer) || 'start';

		node = findnode(from);
		if (node) {
			node.setAttribute('class', 'hover');
		}

		if (from == '0') {
			edge = findedge('start', from);
			edge.a.setAttribute('class', 'hover');
		}

		setTimeout(function () {
				if (node) {
					node.removeAttribute('class');
				}

				if (edge) {
					edge.a.removeAttribute('class');
				}

				if (to != 'start') {
					transition(from, to);
				}
			}, delay * 6);	/* for visual acclimatisation on page entry */
	}

/* TODO: obsoleted by xlink?  */
	this.click = function (id) {
		var page;

		page = findpage(document.referrer);

		/* XXX: no, match against regexp */
		if (page == id) {
			transition('start', id);
			return;
		}

		setCookie('page', page, 0.5);

		/* TODO: is there a better way than window.parent? */
		window.parent.location = findnode(id).getAttributeNS('http://xml.libfsm.org/gv', 'href');
	}

	this.init = function (d, a) {
		for (var i = 0; i < a.length; i++) {
			var peers;

			peers = [ d.getElementById('menu-' + a[i]), findnode(a[i]) ];

			for (var j = 0; j < peers.length; j++) {
				if (peers[j] == null) {
					return;
				}

				peers[j].peer = peers[peers.length - 1 - j];

				peers[j].onmouseover = function () {
					this.peer.setAttribute('class', 'hover hoveredge');
				}

				peers[j].onmouseout = function () {
					this.peer.removeAttribute('class');
				}
			}
		}
	}

});

