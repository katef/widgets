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

TODO: update for html5 input types, too


See also:
http://zendold.lojcomm.com.br/fvalidator/#selflink_examples

TODO: consider masking for prettification, something like http://zendold.lojcomm.com.br/imask/


TODO: explain some of the usage intentions
TODO: all my functions don't need to be prefixed form_*()...

*/

var Valid = new (function () {
	var NS = "http://xml.elide.org/valid";

	/* see http://elide.org/snippets/css.js */
	function hasclass(node, klass) {
		var a, c;

		c = node.getAttribute('class');
		if (c == null) {
			return;
		}

		a = c.split(/\s/);

		for (var i in a) {
			if (a[i] == klass) {
				return true;
			}
		}

		return false;
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

			if (hasclass(inputs[i], 'missing')) {
				return false;
			}
		}

		return true;
	}

	function form_hasmissing(form, state) {
		var inputs;

		inputs = form.getElementsByTagName('input');

		for (var i = 0; i < inputs.length; i++) {
			if (hasclass(inputs[i], 'missing')) {
				return true;
			}
		}

		return false;
	}

	function form_setmissing(form, missing) {
		removeclass(form, 'missing');

		if (missing) {
			addclass(form, 'missing');
		}
	}

	function form_setsubmittable(form, valid) {
		var inputs;

		removeclass(form, 'invalid');
		removeclass(form, 'valid');

		addclass(form, valid == true ? 'valid' : 'invalid');

		inputs = form.getElementsByTagName('input');

		for (var i = 0; i < inputs.length; i++) {
			var type;

			type = inputs[i].getAttribute('type');
			if (type != 'submit') {
				continue;
			}

			if (valid) {
				inputs[i].removeAttribute('disabled');
			} else {
				inputs[i].setAttribute('disabled', 'disabled');
			}
		}
	}

	function form_labelisfor(form, label, target) {
		if (target.id && label.getAttribute('for') == target.id) {
			return true;
		}

		return (function (form, label, target) {
			if (target == form) {
				return false;
			}

			if (target == label) {
				return true;
			}

			return arguments.callee(form, label, target.parentNode);
		})(form, label, target);
	}

	function form_setlabels(form, state, target) {
		var labels;

		labels = form.getElementsByTagName('label');

		for (var i = 0; i < labels.length; i++) {
			if (!form_labelisfor(form, labels[i], target)) {
				continue;
			}

			removeclass(labels[i], 'valid');
			removeclass(labels[i], 'invalid');
			removeclass(labels[i], 'missing');

			addclass(labels[i], state);
		}
	}

	/* TODO: could merge the getElementsByTagName() with the other labels function; or make a callback or something */
	function form_reqlabels(form, target) {
		var labels;

		labels = form.getElementsByTagName('label');

		for (var i = 0; i < labels.length; i++) {
			if (!form_labelisfor(form, labels[i], target)) {
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

			form_reqlabels(form, input);
		}
		
		input.onchange = function (e) {
			var state;
			var missing;

			if (e == null || e.type != 'change') {
				return;
			}

			if (e.target.getAttribute('disabled')) {
				return;
			}

			removeclass(e.target, 'valid');
			removeclass(e.target, 'invalid');
			removeclass(e.target, 'missing');

			if (e.target.value == '' && hasclass(e.target, 'required')) {
				state = 'missing';
			} else if (re.test(e.target.value)) {
				state = 'valid';
			} else {
				state = 'invalid';
			}

			addclass(e.target, state);

			form_setmissing(e.target.form, form_hasmissing(e.target.form));

			if (state == 'valid') {
				form_setsubmittable(e.target.form,
					form_isvalid(e.target.form));
			}  else {
				/*
				 * Note that we do not disable the submit button here, because
				 * we want to keep that operational for sake of visual feedback
				 * to have a message appear as a warning on submit.
				 */
			}

			/* TODO: find <label>s; centralise updating an input with updating a label? */
			form_setlabels(e.target.form, state, e.target);
		}
	}

	function form_validatabletype(type) {
		return type == 'text'
		    || type == 'textarea'
		    || type == 'hidden'
		    || type == 'password';
	}

	function initform(form) {
		var inputs;

		inputs = form.getElementsByTagName('input');

		for (var i = 0; i < inputs.length; i++) {
			var regex;

			/*
			 * Looks like firefox screws up getAttributeNS(), so I'm doing this
			 * both ways, instead...
			 */
			regex = inputs[i].getAttributeNS(NS, 'regex')
			     || inputs[i].getAttribute('v:regex');
			if (regex == null) {
				continue;
			}

			if (!form_validatabletype(inputs[i].getAttribute('type'))) {
				continue;
			}

			initinput(form, inputs[i], regex);
		}

		/* for refresh auto-populating a form, after it was marked invalid.  TODO: explain this reenables the submit button */
		form_setmissing(form, false);
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

			form_setmissing(e.target, form_hasmissing(e.target));
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

