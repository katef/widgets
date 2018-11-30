
var EventThing = new (function () {

	this.fire = function (node, type) {
		/* IE */
		if (node.fireEvent) {
			node.fireEvent('on' + type);
		}

		/* others */
		else if (document.createEvent) {
			var e;

			e = document.createEvent('HTMLEvents');
			if (e.initEvent) {
				e.initEvent(type, true, true);
			}
			if (node.dispatchEvent) {
				node.dispatchEvent(e);
			}
		}
	}

	this.attach = function (node, name, f) {
		node.addEventListener(name, f, false);
	}

	this.detach = function (node, name) {
		node.removeEventListener(name, f, false);
	}

});

