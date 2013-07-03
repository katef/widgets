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
				$thumb = exif_thumbnail("$d/$f", $width, $height);
				if (!$thumb) {
					continue;
				}

				$exif = exif_read_data("$d/$f");
				if (!$exif) {
					continue;
				}

				$year = substr($exif['DateTime'], 0, 4);
				$comment = $exif['COMMENT'][0];

				printf('<li>');
				printf('<a onclick="f(this); return false" href="%s" id="%s" name="%s">', "$d/$f", $f, $f);
				printf('<center><img width="%d" height="%d" src="thumbnail.php?gallery=%s&filename=%s"/></center>', $width, $height, $d, $f);
				printf('</a>');
				printf('<div class="caption">%s', "Prague, $year");
				if ($comment) {
					printf(" &mdash; %s", $comment);
				}
				printf("</div></li>\n");
			}

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

