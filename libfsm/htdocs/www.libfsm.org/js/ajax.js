/* $Id$ */

var Ajax = new (function () {

	this.post = function (url, data, f) {
		var ajax;

		if (data instanceof DocumentFragment) {
			data = new XMLSerializer().serializeToString(data);
		}

		if (!window.XMLHttpRequest) {
			ajax = new XDomainRequest();
			ajax.open('POST', url);
		} else {
			ajax = new XMLHttpRequest();
			ajax.open('POST', url, true);
		}

		/* TODO: no cache headers */
		/* note 'text/plain' (no charset) is required by CORS */
		ajax.setRequestHeader('Content-Type', 'text/plain');

		ajax.ontimeout = function () {
				f(0, 'Timeout');
			};

		ajax.onabort =
		ajax.onerror = function () {
				f(this.status, this.statusText);
			};

		ajax.onreadystatechange = function () {
				if (this.readyState != this.DONE) {
					return;
				}

				f(this.status, this.statusText);
			};

		/* TODO: try/catch stuff? */
		ajax.send(data);
	}

});

