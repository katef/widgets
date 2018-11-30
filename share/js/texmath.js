
var TexMath = new (function () {

	this.init = function(root) {
		var a;

		a = root.getElementsByClassName('texmath');
		for (i = 0; i < a.length; i++) {
		   katex.render(a[i].textContent, a[i]);
		}
	}

});

