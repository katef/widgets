/* $Id$ */

var Comment = new (function () {

	var oldsubmit;

	/*
	 * TODO: supporting multiple syntaxes (wiki syntax etc) done client-side only;
	 * all submit as XHTML
	 */

	/*
	 * Annoyingly the DOM spec is unclear about whether replacechild() may
	 * replace a Node with a DocumentFragment('s children). In practice, it
	 * does not work on several implementations, so I am providing my own.
	 */
	function xreplacechild(parent, newnode, oldnode) {
		if (newnode instanceof DocumentFragment) {
			parent.insertBefore(newnode, oldnode);
			parent.removeChild(oldnode);
			return;
		}

		parent.replaceChild(newnode, oldnode);
	}

	function fieldvalue(id) {
		var e;

		e = document.getElementById(id);
		if (e == null) {
			return null;
		}

		return e.value;
	}

	function parsefragment(str) {
		var root;

		str = '<body xmlns="http://www.w3.org/1999/xhtml">'
			+   str
			+ '</body>';

		/* TODO: would prefer to parse html (hence permitting ill-formed markup).
		can data:// URIs for XHR permit that?
		not all DOMParser implemntations seem to accept text/html */

		/* TODO: catch exceptions here? */
		root = new DOMParser().parseFromString(str, 'text/xml').documentElement;

		/*
		 * Parse errors according to http://html5.org/specs/dom-parsing.html
		 *
		 *   Let root be a new Element, with its local name set to "parsererror"
		 *   and its namespace set to "http://www.mozilla.org/newlayout/xml/parsererror.xml".
		 */
		if (root.nodeName != 'body') {
			return null;
		}

		/*
		 * However in Chrome, we get our <body> with <parsererror> inside it.
		 * Experimentation suggests this is always the first child, regardless
		 * of other content.
		 */
		if (root.childNodes.length > 0
		 && root.childNodes.item(0).nodeName == 'parsererror') {
			return null;
		}

		/* XXX: js PI nodes and {}s need stripping; run through template.js here first?
		 * no; do it server-side. but nice to error on the client, too. Even better to
		 * find how <?js comment ?> is causing this to be executed... */

		/*
		 * TODO: walk document here; return null if it contains something not allowed?
		 * No need - we will validate server-side via ajax, for DRY on the DTD.
		 * But if there is any canned client-side general HTML validation we can use
		 * (rather than our specific subset), then great, let's do that here too.
		 */

		/*
		 * Any remaining parse errors will be found server-side.
		 * We're just attempting to avoid an unneccessary trip above.
		 */

		return root.childNodes;
	}

	function error(prefix, message, advice) {
		document.getElementById('comment-error').textContent
			= prefix ? (prefix + ': ' + message + '.') : (message + '.');

		if (advice) {
			document.getElementById('comment-advice').textContent = advice;

			Class.add(document.getElementById('comment'), 'advice');
		}

		Class.add(document.getElementById('comment'), 'error');
	}

	function post(action, f) {
		var t;

		Class.remove(document.getElementById('comment'), 'error');
		Class.remove(document.getElementById('comment'), 'advice');
		document.getElementById('comment-advice').textContent = '';

		var fields = {
			date:    new Date().toISOString(),
			url:     fieldvalue('form-url'),
			email:   fieldvalue('form-email'),
			author:  fieldvalue('form-author'),
			comment: fieldvalue('form-comment')
		};

		fields.comment = parsefragment(fields.comment);
		if (!fields.comment) {
			return error(null, message,
				'Please make sure your markup is well-formed.');
		}

		/* server-side valdiation (TODO: explain DRY for the DTD) */
		/* don't need any query string stuff for just validation */
		t = Template(document.getElementById('tmpl:post'), fields);

		Ajax.post(action, t, function (status, message) {
			switch (status) {
			case 200:
			case 201:
				break;

			case 0:	  /* client side */
			case 408: /* server side */
				return error(null, message,
					'Please try again in a little while.');

			case 400:
				return error(null, message,
					'Please make sure your markup is well-formed and only '
			      + 'contains the tags permitted.');

			case 404:
				return error('Error', 'No such post');

			case 403:
			case 418:
				return error('Error', message);

			case 405:
			case 500:
			case 503:
				return error(status, message,
					"This is not your fault. Unless you're me.");

			default:
				return error(status, message);
			}

			f(fields);
		});
	}

	this.preview = function(e) {
		var comment;

		if (oldsubmit && !oldsubmit(e)) {
			return false;
		}

		post(this.action, function (fields) {
				var t;
				var ph;

				/* TODO: do the @id replacement here, instead of in the template */
				t = Template(document.getElementById('tmpl:preview'), fields);

				ph = document.getElementById('ph:preview');

				xreplacechild(ph.parentNode, t, ph);
			});

		return false;
	}

	this.submit = function(e) {
		var action;

		if (oldsubmit && !oldsubmit(e)) {
			return false;
		}

		/* TODO: disable submit and preview buttons;
		 * timeout to reenable them (or let the ajax timeout drive that) */

		/* TODO: encodeURIComponent() for all fields; need to decode in rc */
		action = this.action
			+ '?repo='      + 'blog'
			+ '&date='      + this.date.value
			+ '&postpath='  + this.postpath.value
			+ '&shortform=' + this.shortform.value
			+ '&author='    + encodeURIComponent(this.author.value)
			+ '&stuff1='    + encodeURIComponent(this.stuff1.value)
			+ '&stuff2='    + encodeURIComponent(this.stuff2.value);

		post(action, function (fields) {
				/* XXX: hacky. @style in the template sets display: block */
				document.getElementById('comment-preview').removeAttribute('style');

				window.location.reload(true);
			});

		return false;
	}

	this.onsubmit = function(form, f) {
		if (oldsubmit === undefined) {
			oldsubmit = form.onsubmit || null;
		}

		form.onsubmit = f;
	}

});

