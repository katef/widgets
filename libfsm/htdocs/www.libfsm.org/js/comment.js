/* $Id$ */

var Comment = new (function () {

	var oldsubmit;

	/*
	 * TODO: ideas on sanitizing HTML:
	 *
	 * have the browser construct a new dom document
	 * add the user's html verbatim in the middle of it
	 * walk the DOM tree throwing an error if any invalid elements are encountered
	 * (i.e. not one of the allowed elements)
	 *
	 * (need to do this server-side, too: can't trust clients. but need to do it client side for the preview stuff)
	 *
	 * TODO: supporting multiple syntaxes (wiki syntax etc) done client-side only; all submit as XHTML
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

	function sanitise(str) {
		var doc;
		var x;
		var frag;

		/* TODO:
		doc = document.implementation.createDocument("", "", null);

		frag = document.implementation.createDocumentFragment();

		frag.appendChild(

		frag.normalize();
		*/


		/* TODO: try/catch dom exceptions? */

		/* TODO: better abstract these to browser-specific bits */

		var parser = new DOMParser();
		var d = parser.parseFromString('<x>' + str + '</x>', "text/xml");

		var s = new XMLSerializer();
		var z = s.serializeToString(d);
	}

	this.preview = function(e) {
		var aside;

		if (oldsubmit && !oldsubmit(e)) {
			return false;
		}

		/* TODO: remove old preview if it's already there */
		/* TODO: add new preview */
		/* TODO: message for hilighting it as a preview (or just set a CSS class) */
		/* TODO: don't submit after this */

		/* TODO: do want to keep this separate from the real comments,
		 * for visual emphasis that it does not exist yet.
		 * then refresh when the ajax is submitted */
		aside = document.getElementById('comment-preview');

		/*
		 * TODO: if sanity-check fails, show an error which goes where the normal form error is.
		 * two kinds of error:
		 * 1. does not parse
		 * 2. contains dissalowed elements (permit entity references; permit CDATA)
		 */

		var fields = {
			name:    fieldvalue('form-name'),
			date:    '2010-11-11',	/* TODO */
			url:     fieldvalue('form-url'),
			comment: fieldvalue('form-comment')
		};

		sanitise(fields.comment);

		/* TODO: namespace @id, as tmpl:comment-preview or somesuch */
		var t = Template(document.getElementById('comment-preview-template'), fields);

		/* TODO: comment needs to be parsed... but then it is from validation, anyway */

		/* TODO: do the @id replacement here, instead of in the template */
		xreplacechild(aside.parentNode, t, aside);

		return false;
	}

	this.submit = function(e) {
		if (oldsubmit && !oldsubmit(e)) {
			return false;
		}

		/* TODO: remove old preview if it's already there */

		/* TODO: submit to ajax */

		/* TODO: add new preview */
		/* TODO: message for ajax submission success/failure (or just set a CSS class) */

		alert("submit " + e);

		return false;
	}

	this.onsubmit = function(form, f) {
		if (oldsubmit === undefined) {
			oldsubmit = form.onsubmit || null;
		}

		form.onsubmit = f;
	}

});

