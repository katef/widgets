/* $Id$ */

function f(a) {
	a.blur();

	li = a.parentNode;
	ul = li.parentNode;
	l = ul.getElementsByTagName('li');

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
		setimgsrc(li, true);
		document.location.hash = a.id;
	}

	/* Clear others */
	for (i = 0; i < l.length; i++) {
		if (l[i] != li) {
			l[i].removeAttribute('class');
			setimgsrc(l[i], false);
		}
	}

	return false;
}

/*
 * zoom is either true for zoomed images, or false for thumbnails.
 */
function setimgsrc(li, zoom) {
	ul = li.parentNode;
	if (!ul) {
		return;
	}

	a = li.getElementsByTagName('a')[0];
	if (!a) {
		return;
	}

	img = a.getElementsByTagName('img')[0];
	if (!img) {
		return;
	}

	if (zoom) {
		img.src = ul.id + '/' + a.id;
	} else {
		img.src = 'thumbnail.php?gallery=' + ul.id + '&filename=' + a.id;
	}
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

/* preload zoomed images */
function p(gid) {
	ul = document.getElementById(gid);
	if (!ul) {
		return;
	}

	l = ul.getElementsByTagName('li');
	if (!l) {
		return;
	}

	for (i = 0; i < l.length; i++) {
		li = l[i];
		if (!li) {
			continue;
		}

		a = li.getElementsByTagName('a')[0];
		if (!a) {
			continue;
		}

		img = new Image();
		img.src = a.href;
	}
}

