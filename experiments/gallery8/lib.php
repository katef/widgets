<?php

/*
 * Glob within a given directory.
 */
function globdir($dir, $pattern) {
	$r = array();

	$d = opendir($dir);
	if (!$d) {
		return;
	}

	while (($f = readdir($d)) !== false) {
		if ($f{0} == '.') {
			continue;
		}

		if (fnmatch($pattern, $f)) {
			$r[] = $f;
		}
	}

	closedir($d);

	return $r;
}

?>
