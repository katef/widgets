/* $Id$ */

var Cookie = new (function () {

	/* Adapted from http://www.quirksmode.org/js/cookies.html */
	this.set = function (domain, name, value, days) {
		var date, cookie;

		cookie  = name + "=" + value;
		cookie += ";path=/";

		if (domain) {
			cookie += ";domain=" + domain;
		}

		if (days) {
			date = new Date();
			date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
			cookie += ";expires=" + date.toGMTString();
		}

		document.cookie = cookie;
	}

	/* Adapted from http://www.quirksmode.org/js/cookies.html */
	this.get = function (name) {
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

});

