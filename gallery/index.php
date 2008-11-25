<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
	<title>Gallery</title>
	<link rel="stylesheet" href="gallery.css" type="text/css" />
	<script type="text/javascript" src="gallery.js"></script>
</head>

<body onload="g(unescape(self.document.location.hash.substring(1)))">
	<ul class="gallery">
		<?php

			$a = globdir(dirname($_SERVER['SCRIPT_FILENAME']) . 'Prague - Decadence and Decay'), '*');
			foreach ($a as $f) {
				printf("<li>\n");
				printf("\t<a onclick="return f(this)" href="%s" id="%s" name="%s">\n", $f, $f, $f);
				printf("\t\t<center><img src="%s"/></center>\n", $f);
				// printf("\t<div class="caption">%s</div>\n", '');
				printf("</li>\n");
			}

		?>
	</ul>
</body>
</html>

