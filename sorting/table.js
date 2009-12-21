/* $Id$ */

/*
 * Automatically-identified sortable tables.
 * See http://elide.org/widgets/sorting/ for details.
 *
 * Ideas for future work:
 *
 * - save table order in URI after # (or use a cookie)
 * - take <input> values as well as table cell values, during recursive serialisation of a <td>'s contents, also <img>
 * - deal with something modifying the table, and reinitialise it
 * - <td> columns reorderable by drag & drop for their higest <th>
 * - <tr> reorderable by drag and drop
 * - use the column type to infer left/right/centre alignment
 */

/*
 * Implementation:
 *
 * The main idea here is to do as little as possible during initialisation
 * (since there are often lots of tables in one document). As much as possible
 * is postponed until the user clicks a <th> to sort it; I figure delay is ok
 * there, since they're expecting something to happen.
 *
 * All xpath paths are given using explicit paths from the parent, so as to
 * avoid accidentally selecting inside subtables.
 *
 * This uses Array.sort() for sorting; reimplementing this (as some do) seemed
 * unneccessary.
 */

/*
 * TODO: omit diagonal <th>s
 * TODO: omtimise for the typical special case of no @colspan
 * TODO: nested tables
 * TODO: serialse <input>s etc
 * TODO: add a "table-sorting" class to <th>, for UI feedback
 * TODO: refactor to avoid repeated xpath queries
 * TODO: make it scale (cache column type, cache widths)
 * TODO: make it work with HTML namespaces, too
 * TODO: alternate approach: pre-render entire <tables> sorted for each column. clicking to sort just swaps them in
 */


/*
 * This array determines how to sort each data type. Types are identified by
 * regexp applied to each <td>'s .innerHTML in a column. Since empty cells are
 * handled by the calling function, these regexps are never passed (and hence
 * need not match) an empty string.
 *
 * Each entry here is ordered by precidence; the highest types in this array
 * have higher precidence. The lowest entry is a "catch-all" type.
 *
 * The comparison functions used for sorting should return positive, negative,
 * or 0, as per Array.sort(). They are passed string values, from two <td>'s
 * .innerHTML values to compare. Empty cells are handled by the calling
 * function, and so the .cmp() callbacks are never be passed an empty string.
 *
 * The intention is that this array should be straightforward to extend with
 * additional types in the future.
 */
/*
 * TODO:
 * - date/time (ISO 8601 and friends)
 * - scientific notation
 * - filesize (1kb etc)
 * - Si magnitudes (1k3 3M 2da etc)
 *
 * See also: http://www.frequency-decoder.com/demo/table-sort-revisited/custom-sort-functions/
 */
const table_types = [
	/* IP address */ {
		re:  /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/,
		cmp: function (a, b) {
			var re = /^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$/;
			a = a.match(re);
			b = b.match(re);
			return (a[1] << 3 | a[2] << 2 | a[3] << 1 | a[4] << 0)
			     - (a[1] << 3 | b[2] << 2 | b[3] << 1 | b[4] << 0);
		}
	},

	/* float (with separators) */ {
		re:  /^[-+]?[0-9,']*\.?[0-9,]+([eE][-+]?[0-9]+)?$/,
		cmp: function (a, b) {
			a = a.replace(/[,']/g, '');
			b = b.replace(/[,']/g, '');
			return Number(a) - Number(b);
		}
	},

	/* currency */ {
		re:  /^[#$\uA3]?[0-9.,']*\.?[0-9,]+([cp$]|UKP|GBP|USD)?$/i,
		cmp: function (a, b) {
			var ad = /[0-9][cp]$/i.test(a) ? 100 : 1;
			var bd = /[0-9][cp]$/i.test(b) ? 100 : 1;
			a = a.replace(/[^0-9.]/g, '');
			b = b.replace(/[^0-9.]/g, '');
			return Number(a) / ad - Number(b) / bd;
		}
	},

	/* DD/MM/YYYY */ {
		re:  /^[0123]?[0-9]\/(10|11|12|0?[0-9])\/\d\d(\d\d)?$/,
		cmp: function (a, b) {
			var re = /^(\d+)\/(\d+)\/(\d+)$/;
			a = a.match(re);
			b = b.match(re);
			a = new Date(a[3], Number(a[2]) - 1, a[1]);
			b = new Date(b[3], Number(b[2]) - 1, b[1]);
			return (a > b) - (a < b);
		}
	},

	/* MM/DD/YYYY */ {
		re:  /^(10|11|12|0?[0-9])\/[0123]?[0-9]\/\d\d(\d\d)?$/,
		cmp: function (a, b) {
			var re = /^(\d+)\/(\d+)\/(\d+)$/;
			a = a.match(re);
			b = b.match(re);
			a = new Date(a[3], Number(a[2]) - 1, a[1]);
			b = new Date(b[3], Number(b[2]) - 1, b[1]);
			return (a > b) - (a < b);
		}
	},

	/* string */ {
		re:  /./,
		cmp: function (a, b) {
			a = a.toLowerCase();
			b = b.toLowerCase();
			return (a > b) - (a < b);
		}
	}
];

/*
 * Floor of the binary logarithm of i.
 * This is equivalent to Math.floor(Math.log(i) / Math.log(2));
 * Given a power of 2, this returns the 0-based index of that bit.
 */
function table_ilog2(i) {
	var l;

	l = 0;

	while (i >>= 1) {
		l++;
	}

	return l;
}

function table_serialise(node) {
	if (node.table_serialised == null) {
		node.table_serialised = node.innerHTML.replace(/\s+/g, " ").trim();
	}

	return node.table_serialised;
}

function table_hasclass(node, class) {
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

function table_removeclass(node, class) {
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

function table_addclass(node, class) {
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

/*
 * Always returns an array, even if it's empty. The array contains DOM nodes.
 * Modifying nodes will change the document.
 *
 * Examples:
 *
 * var a = table_xpath(document.documentElement, "//h:th");
 * for (var i in a) {
 *     a[i].style.backgroundColor = 'aliceblue';
 * }
 *
 * // note xpath's 1-based indexing versus javascript's 0-based...
 * table_xpath(document.documentElement, "//h:h1[1]")[0].style.color = 'red';
 */
function table_xpath(root, query) {
	const type = XPathResult.ORDERED_NODE_ITERATOR_TYPE;
	var resolver;
	var a, r, n;

	a = [ ];

	resolver = function (prefix) {
		switch (prefix) {
		case "h": return "http://www.w3.org/1999/xhtml";
        default:  return null;
		}
	}

	r = document.evaluate(query, root, resolver, type, null);

	/* constructing an array because modifying any node invalidates the iterator */
	while ((n = r.iterateNext())) {
		a.push(n);
	}

	return a;
}

function table_cellcolspan(cell) {
	var span;

	span = cell.getAttribute('colspan');

	return span == null ? 1 : Number(span);
}

/*
 * Returns 0-based index of the given <th>'s row, or -1 if it's inside a <thead>.
 */
function table_findthrow(t, th) {
	var tr;

	if (th.parentNode.localName != 'tr') {
		return null;
	}

	tr = th.parentNode;

	if (tr.parentNode.localName == 'thead') {
		return -1;
	}

	for (var i in t.rows) {
		if (t.rows[i] == tr) {
			return i;
		}
	}

	return null;
}

function table_getcolumn(rows, colindex, localname) {
	var c;

	c = [ ];

	/*
	 * For each row, loop through its cells until the desired colindex is
	 * reached. I would love to do this in XPath, but unfortunately I don't
	 * think Javascript's API provides variable binding. So, counting here is
	 * done using the DOM API instead.
	 */
	for (var i in rows) {
		var cells, q;

		q = 0;

		cells = rows[i].cells;
		for (var j in cells) {
			q += table_cellcolspan(cells[j]);

			if (q > colindex) {
				if (cells[j].localName == localname) {
					c.push(cells[j]);
				}
				break;
			}
		}
	}

	return c;
}

/*
 * Returns an array of <td>s in the body for a table, after a given row.
 *
 * colindex - 0-based column index of the column we're interested in.
 * rowindex - 0-based row index of the row we're interested cells below.
 */
function table_getcolumntd(t, rowindex, colindex) {
	var a;

	rowindex++;

	a = table_xpath(t, "h:tr[position() > " + rowindex + "]"
	        + "|h:tbody/h:tr[position() > " + rowindex + "]");

	return table_getcolumn(a, colindex, "td");
}

/*
 * Returns an array of <th>s in the header for a table.
 *
 * colindex - 0-based column index of the column we're interested in.
 */
function table_getcolumnth(t, colindex) {
	var a;

	a = table_xpath(t, "h:tr|h:thead/h:tr");

	return table_getcolumn(a, colindex, "th");
}

function table_countcols(t) {
	var cols;
	var a;

	cols = 0;

	/*
	 * TODO: there must be a better way to do this... this assumes that the
	 * first header row is entirely populated. A more thorough approach would
	 * be to count in all the rows and take the maximum.
	 */
	a = table_xpath(t, "h:tr[1]/h:th|h:thead/h:tr[1]/h:th"
	                + "|h:tr[1]/h:td|h:thead/h:tr[1]/h:td");
	for (var i in a) {
		cols += table_cellcolspan(a[i]);
	}

	return cols;
}

/*
 * Return a mask of all table_type[] indexes which match the given string.
 * Only indexes present in the 'runningmask' argument are considered for
 * matching, and so it may be used to eliminate testing for irrelevant types.
 */
function table_guesstypetd(runningmask, s) {
	var mask;

	mask = 0;

	for (var i in table_types) {
		var j;

		j = 1 << i;

		if ((runningmask & j) == 0) {
			continue;
		}

		if (s == "" || table_types[i].re.test(s)) {
			mask |= j;
		}
	}

	return mask;
}

/*
 * Return the 0-based index of the highest precidence type matching all cells
 * in the given column, or -1 if no type matches.
 */
function table_guesstypecolumn(v) {
	var typeindex;
	var mask;

	/*
	 * For each regex that matches against a cell, add that type to a set. Then
	 * intersect all types within the set to find which we can consider
	 * appropiate for the entire column of cells. The type we decide is the
	 * highest precidence from this intersection.
	 */

	mask = ~0;

	for (var w in v) {
		mask &= table_guesstypetd(mask, table_serialise(v[w]));
	}

	/* no type matched */
	if (mask == 0) {
		return -1;
	}

	/* pick the first bit (i.e. the highest precidence) */
	mask &= ~(mask - 1);

	/* the index of the bit set (i.e. the index into table_types[]) */
	return table_ilog2(mask);
}

/*
 * This function reorders a column of data; this does not affect the page
 * layout - it is the array order which is modified, not the DOM tree.
 *
 * This function provides two mutually exclusive operations:
 *
 *  - Sorting unordered data; this happens on the first click.
 *  - Reversing sorted data; this happens on subsequent clicks.
 *
 * Descision-making for when to reorder, and in what direction depends on the
 * state of the current data. State is maintained in the @class list of the
 * <th> associated with that column.
 */
function table_ordercolumn(th, cmp, v) {
	var dir;

	if (table_hasclass(th, "table-sorted")) {
		v.reverse();

		dir = table_hasclass(th, 'table-ascending')
			? 'table-descending'
			: 'table-ascending';
	} else {
		v.sort(function (a, b) {
				a = table_serialise(a);
				b = table_serialise(b);

				if (a == "") return +1;
				if (b == "") return -1;

				return cmp(a, b);
			});

		dir = 'table-ascending';
	}

	return dir;
}

/*
 * Update the DOM tree to reflect the order of a given column.
 * @class attributes are also updated accordingly.
 */
function table_renderorder(t, th, dir, v) {
	/*
	 * Reset the sortedness state of all columns, and set the sortedness state
	 * for the given column.
	 */
	{
		var o;

		/* Reset classes for all other columns' data */
		/* TODO: only if this isn't our column; deal with that separately */
		o = table_xpath(t, "h:tbody/h:tr/h:td|h:tr/h:td");
		for (var w in o) {
			table_removeclass(o[w], "table-sorted");
		}

		/* Reset direction for all other columns' headers */
		o = table_xpath(t, "h:thead/h:tr/h:th|h:tr/h:th");
		for (var w in o) {
			table_removeclass(o[w], "table-ascending");
			table_removeclass(o[w], "table-descending");
			if (o[w] != th) {
				table_removeclass(o[w], "table-sorted");
			}
		}

		table_addclass(th, dir);
		table_addclass(th, "table-sorted");
	}

	/*
	 * Reorder rows.
	 */
	{
		var body, tr;

		tr = v[0].parentNode;
		if (tr.localName != 'tr') {
			return;
		}

		body = tr.parentNode;
		if (body.localName != 'table' && body.localName != 'tbody') {
			return;
		}

		for (var w in v) {
			table_addclass(v[w], "table-sorted");
			body.appendChild(v[w].parentNode);
		}
	}
}

/*
 * This little dance is an optimisation for speed; all the DOM modification is
 * performed with the table node taken out of the document. This stops a
 * browser from attempting to reflow the page layout every time a <tr> is added
 * or removed.
 *
 * After the modifications are done, the table is swapped back in to the
 * document. A placeholder node is used to conveniently hold its position.
 */
function table_replacenode(node, f) {
	var parent;
	var placeholder;

	parent = node.parentNode;
	if (parent == null) {
		return;
	}

	placeholder = document.createComment('placeholder');
	if (placeholder == null) {
		return;
	}

	parent.replaceChild(placeholder, node);

	f();

	parent.replaceChild(node, placeholder);
}

/*
 * This is the callback from the <th>.onclick events; the entry point to cause
 * a column to be sorted.
 */
function table_sort(th, rowindex, i) {
	var t;

	{
		var tr;

		if (th.parentNode.localName != 'tr') {
			return;
		}

		tr = th.parentNode;

		if (tr.parentNode.localName == 'table') {
			t = tr.parentNode;
		} else if (tr.parentNode.localName == 'thead') {
			t = tr.parentNode.parentNode;
		} else {
			return;
		}
	}

	table_replacenode(t, function () {
			var typeindex;
			var v;
			var dir;

			if (th.table_v == null) {
				th.table_v = table_getcolumntd(t, rowindex, i);
			}

			if (th.table_v.length == 0) {
				return;
			}

			if (th.table_typeindex == null) {
				th.table_typeindex = table_guesstypecolumn(th.table_v);
			}

			if (th.table_typeindex == -1) {
				table_addclass(th, "table-notype");
				return;
			}

			dir = table_ordercolumn(th, table_types[th.table_typeindex].cmp,
				th.table_v);

			table_renderorder(t, th, dir, th.table_v);
		});
}

/*
 * Initialise a single table.
 */
function table_inittable(t) {
	var cols;

	cols = table_countcols(t);

	/*
	 * For each column, find the lowest <th>. If it meets various requirements
	 * (such as actually having some <td>s below it), then make it active as a
	 * clickable sorting header.
	 *
	 * TODO: reconsider; perhaps select all cells in a column, and iterate
	 * backwards to find the lowest th. then the tds below it are trivial to
	 * find; just the remaining elements.
	 */
	for (var i = 0; i < cols; i++) {
		var lowest;
		var rowindex;

		/* find the lowest-down <th> of all the <th>s in this column */
		lowest = table_getcolumnth(t, i).pop();
		if (lowest == null) {
			continue;
		}

		/* discard multi-column <th>s */
		if (lowest.getAttribute("colspan") > 1) {
			continue;
		}

		rowindex = table_findthrow(t, lowest);
		if (rowindex == null) {
			continue;
		}

		/* Skip <th>s with no <td>s below them */
		if (table_getcolumntd(t, rowindex, i).length == 0) {
			continue;
		}

		/*
		 * TODO: discard all the <th>s below the topmost <th> in the entire
		 * table (i.e. no diagonal <th>s; they'd be moved around when sorting)
		 */

		/*
		 * TODO: should probably wrap the <th> in an <a>, for UI consistency
		 * wrt accidentally selecting text. If so, .blur() it onclick?
		 */

		table_addclass(lowest, "table-sortable");
		lowest.setAttribute("onclick",
			"table_sort(this, " + rowindex + ", " + i + "); false");

		/* TODO: make this lowest.onclick = function (event) { ... }; instead */
	}
}

/* TODO: there is probably a way to automate calling this */
function table_init() {
	var a;

	/*
	 * Here we do not include tables which have cells of @rowspan > 1, due to
	 * their unsortabilty.
	 */

	a = table_xpath(document.documentElement,
		  "//h:table[not(h:tbody/h:tr/h:td[@rowspan > 1]) "
		+ "              and not(h:tr/h:td[@rowspan > 1])]");
	for (var i in a) {
		table_inittable(a[i]);
	}
}

