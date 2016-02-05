/* $Id$ */

/* TODO:
search document.forms (right?)
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
<input type="text" data-instruction="Search..."/> or something

TODO: set form class onsubmit, and use display: none to hide a warning message



See also:
http://zendold.lojcomm.com.br/fvalidator/#selflink_examples

TODO: consider masking for prettification, something like http://zendold.lojcomm.com.br/imask/


TODO: explain some of the usage intentions
TODO: all my functions don't need to be prefixed form_*()...

*/

var Valid = new (function () {

	function form_isvalid(form, state) {
		var inputs;

		inputs = form.getElementsByTagName('input');

		for (var i = 0; i < inputs.length; i++) {
			if (Class.has(inputs[i], 'invalid')) {
				return false;
			}

			if (Class.has(inputs[i], 'missing')) {
				return false;
			}
		}

		return true;
	}

	function form_hasmissing(form, state) {
		var inputs;

		inputs = form.getElementsByTagName('input');

		for (var i = 0; i < inputs.length; i++) {
			if (Class.has(inputs[i], 'missing')) {
				return true;
			}
		}

		return false;
	}

	function form_setmissing(form, missing) {
		Class.remove(form, 'missing');

		if (missing) {
			Class.add(form, 'missing');
		}
	}

	function form_setsubmittable(form, valid) {
		var inputs;

		Class.remove(form, 'invalid');
		Class.remove(form, 'valid');

		Class.add(form, valid == true ? 'valid' : 'invalid');

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

			Class.remove(labels[i], 'valid');
			Class.remove(labels[i], 'invalid');
			Class.remove(labels[i], 'missing');

			Class.add(labels[i], state);
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

			Class.add(labels[i], 'required');
		}
	}

	function initinput(form, input, pattern) {
		var re;

		Class.add(input, 'validation');

		re = new RegExp(pattern)
		if (re == null) {
			return;
		}

		if (!re.test('')) {
			Class.add(input, 'required');

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

			Class.remove(e.target, 'valid');
			Class.remove(e.target, 'invalid');
			Class.remove(e.target, 'missing');

			if (e.target.value == '' && Class.has(e.target, 'required')) {
				state = 'missing';
			} else if (re.test(e.target.value)) {
				state = 'valid';
			} else {
				state = 'invalid';
			}

			Class.add(e.target, state);

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
			var pattern;

			/* TODO: fall back to finding the attribute for non-HTML5 browsers.
			 * or make a .pattern polyfill  */
			pattern = '^' + inputs[i].pattern + '$';
			if (pattern == null) {
				continue;
			}

			if (!form_validatabletype(inputs[i].getAttribute('type'))) {
				continue;
			}

			initinput(form, inputs[i], pattern);
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

			return Class.has(e.target, 'valid');
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

