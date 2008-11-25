<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
	<title>Gallery</title>
	<link rel="stylesheet" href="gallery.css" type="text/css" />
	<script type="text/javascript" src="gallery.js"></script>
</head>

<body onload="g(unescape(self.document.location.hash.substring(1)))">
<?php
require_once('lib.php');
$d = 'sample_gallery';

?>
	<ul class="gallery">
		<?php


			$a = globdir(dirname($_SERVER['SCRIPT_FILENAME']) . "/$d", '*');
			foreach ($a as $f) {
				printf('<li>');
				printf('<a onclick="return f(this)" href="%s" id="%s" name="%s">', $f, $f, $f);
				printf('<center><img src="thumbnail.php?gallery=%s&filename=%s"/></center>', $d, $f);
				printf('</a>');
				printf('<div class="caption">%s</div>', 'Prague, 2006');
				printf("</li>\n");
			}

		?>
	</ul>
</body>
</html>

