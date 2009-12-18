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
 * TODO: nested tables
 * TODO: permit empty <td>.innerHTML's during the sort(cmp) function, centralised
 * TODO: refactor to avoid repeated xpath queries
 * TODO: make it scale (cache column type, cache widths)
 * TODO: make it work with HTML namespaces, too
 * TODO: when flipping, if the class is set, we can assume the column is already sorted
 * TODO: cache column on first <th> click; this avoids needing to count @colspan each time
 * TODO: when masking, eliminate discounted indexes on-the-fly (pass a running mask through to each <td>)
 */


var table_uniqueid = 0;	/* see table_generateid */

/*
 * This array determines how to sort each data type. Types are identified by
 * regexp applied to each <td>'s .innerHTML in a column. Since cells are
 * frequently empty, each regexp should also be able to match an empty cell.
 *
 * Each entry here is ordered by precidence; the highest types in this array
 * have higher precidence. The lowest entry is a "catch-all" type.
 *
 * The comparison functions used for sorting should return positive, negative,
 * or 0, as per Array.sort(). They are passed string values, from two <td>'s
 * .innerHTML values to compare.
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
		/* TODO: add more, \uxxxx */
		re:  /^[$\uA3]?[0-9.,']+(\.[0-9,']+[cp]?)?$/,
		cmp: function (a, b) {
			/* TODO: "32c" needs to become "0.32" */
			a = a.replace(/[,'$cp]/g, '');
			b = b.replace(/[,'$cp]/g, '');
			return Number(a) - Number(b);
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
 * Generate a unique ID suitable for use in @id attributes.
 */
function table_generateid(prefix) {
	for (;;) {
		var s;

		s = prefix + table_uniqueid.toString(16);

		if (!document.getElementById(s)) {
			return s;
		}

		table_uniqueid++;
	}
}

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
		a = a.concat(c.split(/\s/));
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

/*
 * Returns an array of <th>s in the header for a table.
 *
 * colindex - 0-based column index of the column we're interested in.
 */
/* TODO: remove table_getcolumn */
function table_getcolumnth(t, colindex) {
	var a, c;

	c = [ ];

	/* TODO: algorithim: for each row, loop through until we get to the desired colindex */
	/* TODO: unfortunately I don't think javascript implementations provide variable binding */
	/* TODO: better to count using the DOM API, i think; can more easily deal with colspan then */
	a = table_xpath(t, "h:tr|h:thead/h:tr");
	for (var i in a) {
		var b, q;

		q = 0;

		/* TODO: loop through a[i] until we get to the desired colindex */
		b = a[i].cells;
		for (var j = 0; j < b.length; j++) {
			q += table_cellcolspan(b[j]);

			if (q > colindex) {
				if (b[j].localName == 'th') {
					c.push(b[j]);
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
	var a, c;

	c = [ ];

	rowindex++;

	/* TODO: algorithim: same as for table_getcolumnth */
	/* TODO: we only want <td>s below a given <th> */
	a = table_xpath(t, "h:tr[position() > " + rowindex + "]|h:tbody/h:tr[position() > " + rowindex + "]");
	for (var i in a) {
		var b, q;

		q = 0;

		/* TODO: loop through a[i] until we get to the desired colindex */
		b = a[i].cells;
		for (var j = 0; j < b.length; j++) {
			q += table_cellcolspan(b[j]);

			if (q > colindex) {
				if (b[j].localName == 'td') {
					c.push(b[j]);
				}
				break;
			}
		}
	}

	return c;
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

/* TODO: explain this returns a mask of table_type[] indexes */
function table_guesstypetd(td) {
	var mask;

	mask = 0;

	for (var i in table_types) {
		if (table_types[i].re.test(td.innerHTML)) {
			mask |= 1 << i;
		}
	}

	return mask;
}

/*
 * TODO: returns type ID's index or -1
 */
function table_guesstypecolumn(t, rowindex, i) {
	var typeindex;
	var mask;
	var v;

	/*
	 * For each regex that matches against a cell, add that type to a set. Then
	 * intersect all types within the set to find which we can consider
	 * appropiate for the entire column of cells. The type we decide is the
	 * highest precidence from this intersection.
	 */

	mask = ~0;

	v = table_getcolumntd(t, rowindex, i);
	for (var w in v) {
		/* TODO: identify cell type */
		/* TODO: & together all masks. Array.map(function() { &= }) perhaps */
		mask &= table_guesstypetd(v[w]);
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
 * Reset the sortedness state of all columns, and set the sortedness state for
 * the given column, which is flipped in direction if neccessary.
 *
 * Returns true if the column is to be sorted in descending order.
 */
function table_flipdir(t, i) {
	var lowest;
	var v;

	/* TODO: explain goal: */
	/* TODO: only reverse on clicking on the *same* th again; so store state in the <th> */
	/* TODO: explain we're getting the th to store state; state is in the class */

	lowest = table_getcolumnth(t, i).pop();
	if (lowest == null) {
		return;
	}

	/* TODO: grab dir here and invert it */
	dir = table_hasclass(lowest, 'table-ascending')
		? 'table-descending'
		: 'table-ascending';

	/* Reset classes for all other columns' data */
	v = table_xpath(t, "h:tbody/h:tr/h:td|h:tr/h:td");
	for (var w in v) {
		table_removeclass(v[w], "table-sorted");
	}

	/* Reset direction for all other columns' headers */
	v = table_xpath(t, "h:thead/h:tr/h:th|h:tr/h:th");
	for (var w in v) {
		table_removeclass(v[w], "table-ascending");
		table_removeclass(v[w], "table-descending");
		table_removeclass(v[w], "table-sorted");
	}

	table_addclass(lowest, dir);
	table_addclass(lowest, "table-sorted");

	return dir == 'table-descending';
}

function table_sortcolumntd(t, rowindex, i, cmp) {
	var tr, body;
	var v;

	v = table_getcolumntd(t, rowindex, i);

	v.sort(function (a, b) {
			/* TODO: serialisation of more complex tags goes here */
			return cmp(a.innerHTML, b.innerHTML);
		});

	if (table_flipdir(t, i)) {
		v.reverse();
	}

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
		body.appendChild(body.removeChild(v[w].parentNode));
	}
}

/*
 * This is the callback from the <th>.onclick events; the entry point to cause
 * a column to be sorted.
 */
function table_sort(id, rowindex, i) {
	var typeindex;
	var th, tr, t;

	th = document.getElementById(id);
	if (th == null) {
		return;
	}

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

	typeindex = table_guesstypecolumn(t, rowindex, i);
	if (typeindex == -1) {
		/* TODO: no type matched */
		return;
	}

	/*
	 * TODO: if we get this column here, just pass it to
	 * table_guesstypecolumn() to save getting it again.
	 */
	table_sortcolumntd(t, rowindex, i, table_types[typeindex].cmp);
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

		if (!lowest.id) {
			lowest.id = table_generateid('table-th-');
		}

		/*
		 * TODO: should probably wrap the <th> in an <a>, for UI consistency
		 * wrt accidentally selecting text.
		 */

		table_addclass(lowest, "table-sortable");
		lowest.setAttribute("onclick",
			"table_sort(this.id, " + rowindex + ", " + i + "); false");

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

