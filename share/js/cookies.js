/* $Id$ */

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

