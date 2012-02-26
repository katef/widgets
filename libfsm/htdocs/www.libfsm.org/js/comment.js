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

	/* see http://elide.org/snippets/css.js */
	function removeclass(node, klass) {
		var a, c;

		c = node.getAttribute('class');
		if (c == null) {
			return;
		}

		a = c.split(/\s/);

		for (var i = 0; i < a.length; i++) {
			if (a[i] == klass || a[i] == '') {
				a.splice(i, 1);
				i--;
			}
		}

		if (a.length == 0) {
			node.removeAttribute('class');
		} else {
			node.setAttribute('class', a.join(' '));
		}
	}

	/* see http://elide.org/snippets/css.js */
	function addclass(node, klass) {
		var a, c;

		a = [ ];

		c = node.getAttribute('class');
		if (c != null) {
			a = c.split(/\s/);
		}

		for (var i = 0; i < a.length; i++) {
			if (a[i] == klass || a[i] == '') {
				a.splice(i, 1);
				i--;
			}
		}

		a.push(klass);

		node.setAttribute('class', a.join(' '));
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
		var doc;

		str = '<body xmlns="http://www.w3.org/1999/xhtml">'
			+   str
			+ '</body>';

		/* TODO: would prefer to parse html (hence permitting ill-formed markup).
		can data:// URIs for XHR permit that?
		not all DOMParser implemntations seem to accept text/html */

		/* TODO: catch exceptions here? */
		doc = new DOMParser().parseFromString(str, 'text/xml');
		if (!doc) {
			/* TODO: can't happen; DOMParser stupidly returns an error document */
			return null;
		}

		/* TODO: parse error: http://html5.org/specs/dom-parsing.html#the-domparser-interface
		Let root be a new Element, with its local name set to "parsererror"
		and its namespace set to "http://www.mozilla.org/newlayout/xml/parsererror.xml".
		- find this, and return null
		*/

		/* TODO: walk document here; return null if it contains something not allowed?
		no need - we will validate server-side via ajax, for DRY on the DTD
		but if there is any canned client-side general HTML validation we can use
		(rather than our specific subset), then great, let's do that here; it can't hurt */

		return doc.documentElement.childNodes;
	}

	function error(prefix, message, advice) {
		document.getElementById('comment-error').textContent
			= prefix ? (prefix + ': ' + message + '.') : (message + '.');

		if (advice) {
			document.getElementById('comment-advice').textContent = advice;

			addclass(document.getElementById('comment'), 'advice');
		}

		addclass(document.getElementById('comment'), 'error');
	}

	function post(action, f) {
		var t;

		/* TODO: remove old preview? */

		removeclass(document.getElementById('comment'), 'error');
		removeclass(document.getElementById('comment'), 'advice');
		document.getElementById('comment-advice').textContent = '';

		var fields = {
			author:  fieldvalue('form-author'),
			email:   fieldvalue('form-email'),
			date:    '2010-11-11',	/* TODO: actually date+time */
			url:     fieldvalue('form-url'),
			comment: fieldvalue('form-comment')
		};

		fields.comment = parsefragment(fields.comment);
		if (!fields.comment) {
			return error(null, message,
				'Please make sure your markup is well-formed.');
		}

		/* server-side valdiation (TODO: explain DRY for the DTD) */
		/* don't need any query string stuff for just validation */
		t = Template(document.getElementById('comment-post-template'), fields);

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
				var placeholder;

				/* TODO: namespace @id, as tmpl:comment-preview or somesuch */
				/* TODO: do the @id replacement here, instead of in the template */
				t = Template(document.getElementById('comment-preview-template'), fields);

				placeholder = document.getElementById('comment-preview');

				xreplacechild(placeholder.parentNode, t, placeholder);
			});

		return false;
	}

	this.submit = function(e) {
		var action;

		if (oldsubmit && !oldsubmit(e)) {
			return false;
		}

		action = this.action
			+ '?repo='      + 'blog'
			+ '&id='        + '1994/08/22' /* TODO: get date from somewhere; - to / */
			+ '&shortform=' + encodeURIComponent('short-url-title2') /* TODO: ditto */
			+ '&stuff1='    + encodeURIComponent(this.stuff1.value)
			+ '&stuff2='    + encodeURIComponent(this.stuff2.value);

		post(action, function (fields) {
				/* TODO: options here:
				 * - reload the page; good feeling of something having been done
				 * - append to DOM, and fade background from green to white
				 * - don't show it (or rebuild the backend) at all; wait for moderator
				 */

				/* XXX: hacky. @style in the template sets display: block */
				document.getElementById('comment-preview').removeAttribute('style');
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

