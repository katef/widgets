/* $Id$ */

/* TODO:
search document.forms (right?)
find @valid regexps from our namespace
add @onchange
add @onsubmit

on validation:
set label and input class to "valid", "invalid" or neither
use css with :content etc to display help text. leave that out of the markup
set invalid/valid for the entire form and disable/enable the submit button

on submit:
submitting an invalid form: need some sort of animation for positive feedback?
no need; just disable the submit button

TODO: cooperate with the pre-filled form text thingies; make a separate script which does that.
<input type="text" pre:text="Search..."/> or something

TODO: set form class onsubmit, and use display: none to hide a warning message

TODO: identify required fields (set a "required" class on them and their labels) by testing v:regex against ''


See also:
http://zendold.lojcomm.com.br/fvalidator/#selflink_examples

TODO: consider masking for prettification, something like http://zendold.lojcomm.com.br/imask/


TODO: explain some of the usage intentions

*/

var Valid = new (function () {
	var NS = "http://xml.elide.org/valid";

	/* see http://elide.org/snippets/css.js */
	function hasclass(node, class) {
		var a, c;

		c = node.getAttribute('class');
		if (c == null) {
			return;
		}

		a = c.split(/\s/);

		for (var i in a) {
			if (a[i] == class) {
				return true;
			}
		}

		return false;
	}

	/* see http://elide.org/snippets/css.js */
	function removeclass(node, class) {
		var a, c;

		c = node.getAttribute('class');
		if (c == null) {
			return;
		}

		a = c.split(/\s/);

		for (var i = 0; i < a.length; i++) {
			if (a[i] == class || a[i] == '') {
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
	function addclass(node, class) {
		var a, c;

		a = [ ];

		c = node.getAttribute('class');
		if (c != null) {
			a = c.split(/\s/);
		}

		for (var i = 0; i < a.length; i++) {
			if (a[i] == class || a[i] == '') {
				a.splice(i, 1);
				i--;
			}
		}

		a.push(class);

		node.setAttribute('class', a.join(' '));
	}


	/* see http://elide.org/snippets/events.js */
	function fireevent(node, type) {
		/* IE */
		if (node.fireEvent) {
			node.fireEvent('on' + type);
		}

		/* others */
		else if (document.createEvent) {
			var e;

			e = document.createEvent('HTMLEvents');
			if (e.initEvent) {
				e.initEvent(type, true, true);
			}
			if (node.dispatchEvent) {
				node.dispatchEvent(e);
			}
		}
	}


	function form_isvalid(form, state) {
		var inputs;

		inputs = form.getElementsByTagName('input');

		for (var i = 0; i < inputs.length; i++) {
			if (hasclass(inputs[i], 'invalid')) {
				return false;
			}
		}

		return true;
	}

	function form_setsubmittable(form, state) {
		var inputs;

		removeclass(form, 'invalid');
		removeclass(form, 'valid');

		addclass(form, state == true ? 'valid' : 'invalid');

		inputs = form.getElementsByTagName('input');

		for (var i = 0; i < inputs.length; i++) {
			var type;

			type = inputs[i].getAttribute('type');
			if (type != 'submit') {
				continue;
			}

			if (state == true) {
				inputs[i].removeAttribute('disabled');
			} else {
				inputs[i].setAttribute('disabled', 'disabled');
			}
		}
	}

	function form_setlabels(form, state, id) {
		var labels;

		labels = form.getElementsByTagName('label');

		for (var i = 0; i < labels.length; i++) {
			if (labels[i].getAttribute('for') != id) {
				continue;
			}

			removeclass(labels[i], 'valid');
			removeclass(labels[i], 'invalid');

			addclass(labels[i], state == true ? 'valid' : 'invalid');
		}
	}

	/* TODO: could merge the getElementsByTagName() with the other labels function; or make a callback or something */
	function form_reqlabels(form, id) {
		var labels;

		labels = form.getElementsByTagName('label');

		for (var i = 0; i < labels.length; i++) {
			if (labels[i].getAttribute('for') != id) {
				continue;
			}

			addclass(labels[i], 'required');
		}
	}

	function initinput(form, input, regex) {
		var re;

		addclass(input, 'validation');

		re = new RegExp(regex)
		if (re == null) {
			return;
		}

		if (!re.test('')) {
			addclass(input, 'required');

			if (input.id) {
				form_reqlabels(form, input.id);
			}

			/* TODO: add a "missing" class for fields which are reqired, but are missing */
		}
		
		input.onchange = function (e) {
			var state;

			if (e == null || e.type != 'change') {
				return;
			}

			/* TODO: skip disabled inputs. do this here, for forms which dynamically disable things conditionally */
			if (e.target.getAttribute('disabled')) {
				return;
			}

			removeclass(e.target, 'valid');
			removeclass(e.target, 'invalid');

			state = re.test(e.target.value);

			addclass(e.target, state == true ? 'valid' : 'invalid');

			if (state == true) {
				form_setsubmittable(e.target.form, form_isvalid(e.target.form));
			}  else {
				/*
				 * Note that we do not disable the submit button here, because
				 * we want to keep that operational for sake of visual feedback
				 * to have a message appear as a warning on submit.
				 */
			}

			/* TODO: find <label>s; centralise updating an input with updating a label? */
			if (e.target.id) {
				form_setlabels(e.target.form, state, e.target.id);
			}
		}
	}

	function initform(form) {
		var inputs;

		inputs = form.getElementsByTagName('input');

		for (var i = 0; i < inputs.length; i++) {
			var regex;
			var type;

			/*
			 * Looks like firefox screws up getAttributeNS(), so I'm doing this
			 * both ways, instead...
			 */
			regex = inputs[i].getAttributeNS(NS, 'regex')
			     || inputs[i].getAttribute('v:regex');
			if (regex == null) {
				continue;
			}

			type = inputs[i].getAttribute('type');
			if (type != 'text' && type != 'textarea' && type != 'hidden') {
				continue;
			}

			initinput(form, inputs[i], regex);
		}

		/* TODO: set form class? */

		/* TODO: test for required fields */

		/* for refresh auto-populating a form, after it was marked invalid.  TODO: explain this reenables the submit button */
		form_setsubmittable(form, true);

		form.onsubmit = function (e) {
			var inputs;

			if (e == null || e.type != 'submit') {
				return;
			}

			inputs = e.target.getElementsByTagName('input');

			/* TODO: go through and re-valid all inputs. this catches empty ones */
			for (var i = 0; i < inputs.length; i++) {
				fireevent(inputs[i], 'change');
			}

			form_setsubmittable(e.target, form_isvalid(e.target));

			return hasclass(e.target, 'valid');
		}
	}

	this.init = function(root) {
		var forms;

		forms = root.getElementsByTagName('form');

		for (var i = 0; i < forms.length; i++) {
			initform(forms[i]);
		}
	}
});

