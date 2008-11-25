/* $Id$ */

function f(a) {
	a.blur();

	li = a.parentNode;
	ul = li.parentNode;
	l = li.parentNode.getElementsByTagName('li');

	/* TODO: illegible. probably better to store ul.end = next(a.id) */
	if (li.getAttribute('start') == 'y') {
		li.removeAttribute('start');
		document.location.hash = null;
	} else {

		if (li.getAttribute('class') != 'click') {
			/* start */

			for (i = 0; i < l.length; i++) {
				l[i].removeAttribute('start');
			}

			li.setAttribute('start', 'x');
		} else {
			/* "next" */
			for (i = 0; i < l.length; i++) {
				if (l[i] == li) {
					li = l[i + 1];
					break;
				}
			}

			if (li == null) {
				li = l[0];
			}

			/* penultimate */
			if (li.getAttribute('start') == 'x') {
				li.setAttribute('start', 'y');
			}
		}

		li.setAttribute('class', 'click');
		document.location.hash = a.id;
	}

	/* Clear others */
	for (i = 0; i < l.length; i++) {
		if (l[i] != li) {
			l[i].removeAttribute('class');
		}
	}

	return false;
}

function g(id) {
	if (!id) {
		return;
	}

	a = document.getElementById(id);
	if (!a) {
		return;
	}

	f(a);
}

