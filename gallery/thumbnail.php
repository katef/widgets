<?php

$GALROOT = dirname($_SERVER['SCRIPT_FILENAME']);

function xerror($code) {
	header("HTTP/1.0 $code Not Found");
	echo $code;
	exit(1);
}

$filename = $_GET['filename'];
if (!$filename) {
	xerror(400);
}

$gallery = $_GET['gallery'];
if (!$gallery) {
	xerror(400);
}

$file = realpath("$GALROOT/$gallery/$filename");
if (!substr_compare($file, $GALROOT, 0, strlen($GALROOT))) {
	xerror(403);
}

$t = exif_thumbnail($file);
if (!$t) {
	xerror(404);
}

header('Content-Type: Image/jpeg');
echo $t;

?>
