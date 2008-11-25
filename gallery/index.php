<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
	<title>Gallery</title>
	<link rel="stylesheet" href="gallery.css" type="text/css" />
	<script type="text/javascript" src="gallery.js"></script>
</head>

<body>
<?php
require_once('lib.php');
$d = 'sample_gallery';

?>
	<ul class="gallery" id="<?php echo $d ?>">
		<?php


			$a = globdir(dirname($_SERVER['SCRIPT_FILENAME']) . "/$d", '*');
			foreach ($a as $f) {
				printf('<li>');
				printf('<a onclick="return f(this)" href="%s" id="%s" name="%s">', "$d/$f", $f, $f);
				printf('<center><img src="thumbnail.php?gallery=%s&filename=%s"/></center>', $d, $f);
				printf('</a>');
				printf('<div class="caption">%s</div>', 'Prague, 2006');
				printf("</li>\n");
			}

			/* TODO: g()-calling script inlined here */
		?>

		<script type="text/javascript">
		<!--
			/* TODO: wait for gallery.js to load? */
			g(unescape(self.document.location.hash.substring(1)));
			p('<?php echo $d ?>');
		// -->
		</script>
	</ul>
</body>
</html>

