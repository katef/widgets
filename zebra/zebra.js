/* $Id$ */

/*
 * A javascript implementation of zebra striping for tables.
 * Numbering is per tbody.
 *
 * TODO: think about whether i want to use === or ==
 * TODO: there is no block scope. for (var i) is misleading
 */

var Zebra = new (function () {

	function zebra(t, modulus) {
		var a;

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

		function stripe(a) {
			for (var i = 0; i < a.length; i++) {
				addclass(a[i], "zebra-" + (i % modulus));
			}
		}

		function getOffspring(c, name) {
			return c.childNodes.toArray().filter(function (e, i, a) {
					return e.nodeName.toUpperCase() == name.toUpperCase();
				});
		}

		/* TODO: i don't like this much */
		{
			stripe(getOffspring(t, 'tr'));

			a = getOffspring(t, 'tbody');
			for (var i = 0; i < a.length; i++) {
				stripe(getOffspring(a[i], 'tr'));
			}

			a = getOffspring(t, 'thead');
			for (var i = 0; i < a.length; i++) {
				stripe(getOffspring(a[i], 'tr'));
			}
		}
	}

	this.init = function (root, modulus) {
		var a;

		if (!Array.prototype.filter) {
			Array.prototype.filter = function (f) {
				var r;

				if (typeof f != "function") {
					throw new TypeError();
				}

				r = [ ];
				for (var i = this.length; i >= 0; i--) {
					if (i in this) {
						var val = this[i];	/* in case f mutates this */
						if (f.call(arguments[1], val, i, this)) {
							r.push(val);
						}
					}
				}

				return r;
			};
		}

		if (!NodeList.prototype.toArray) {
			NodeList.prototype.toArray = function() {  
				var a;

				a = new Array(this.length);
				for (var i = 0; i < this.length; i++) {
					a.push(this[i]);
				}

				return a;
			};
		}

		a = root.getElementsByTagName('table');
		for (var i = 0; i < a.length; i++) {
			zebra(a[i], modulus);
		}
	}

});

