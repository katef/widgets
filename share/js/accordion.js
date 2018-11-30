
var Accordion = new (function () {

	this.init = function (root) {
		var div = root.getElementsByTagName('div');

		for (var i = 0; i < div.length; i++) {
			if (!div[i].classList.contains('accordion')) {
				continue;
			}

			var details = div[i].getElementsByTagName("details");
			for (var j = 0; j < details.length; j++) {
				// possible to share guts with expander js?
				EventThing.attach(details[j], 'toggle', function () {
					if (!this.open) {
						return;
					}

					var details = this.parentNode.getElementsByTagName("details");
					for (var k = 0; k < details.length; k++) {
						if (details[k] === this) {
							continue;
						}

						details[k].open = false;
					}
				});
			}
		}
	}

});

