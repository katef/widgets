
function msOver (id) {
	a = document.getElementsByTagNameNS('http://www.w3.org/2000/svg', 'g');
	for (var i = 0; i < a.length; i++) {
		if (a[i] == null) {
			continue;
		}

		if (a[i].getAttribute('gv-id') == 'node' + id) {
			a[i].setAttribute('class', 'hover');
		}
	}
}

function msOut (id) {
	a = document.getElementsByTagNameNS('http://www.w3.org/2000/svg', 'g');
	for (var i = 0; i < a.length; i++) {
		if (a[i] == null) {
			continue;
		}

		if (a[i].getAttribute('gv-id') == 'node' + id) {
			a[i].removeAttribute('class');
		}
	}
}

