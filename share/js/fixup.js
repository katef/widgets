
var Fixup = new (function () {

	/* TODO: different fixups per @lang */
	var fixups = [
//		{ from: /[ \n\t]+/g, to: ' '           }, // XXX: not for <pre>
		{ from: /I /g,       to: 'I\u00A0'     },
//		{ from: / as a /g,   to: ' as\u00A0a ' },
		{ from: / a /g,      to: ' a\u00A0'    }
	];

	this.init = function(root) {
		var w = document.createTreeWalker(
			root, 
			NodeFilter.SHOW_TEXT, 
			null, 
			false);
		var n;

		while (n = w.nextNode()) {
			for (var i in fixups) {
				n.nodeValue = n.nodeValue.replace(fixups[i].from, fixups[i].to);
			}
		}
	}

});

