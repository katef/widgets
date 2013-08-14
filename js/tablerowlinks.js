/* adapted from http://radio.javaranch.com/pascarello/2005/05/19/1116509823591.html */
function ConvertRowsToLinks(xTableId) {
	var rows;

	rows = document.getElementById(xTableId).getElementsByTagName("tr");
	for (i = 0; i < rows.length; i++) {
		var link;
		var class;

		link = rows[i].getElementsByTagName("a")
		if (link.length != 1) {
			continue;
		}

		rows[i].onclick = new Function("document.location.href='" + link[0].href + "'");

		class = rows[i].getAttribute('class');
		if (class == null) {
			class = '';
		}

		rows[i].setAttribute('class', class + ' dl');
	}
}

/* <body onload="ConvertRowsToLinks('dl')"> */

