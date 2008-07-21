#!/bin/sh
# $Id$

# Regnerate journal entries

contents() {
	src="$1"
	file="$2"

	y="`echo $src | cut -d/ -f 2`"
	m="`echo $src | cut -d/ -f 3`"
	d="`echo $src | cut -d/ -f 4`"
	date="$d/$m/$y"

	title="`echo $src | cut -d/ -f 5 | sed 's/.html$//'`"

	echo "<span class=\"date\">$date</span>" >> "$file"

	echo -n '<div class="entry">' >> "$file"

	# Numeric titles are unititled posts
	echo $title | egrep '^[0-9]+$' > /dev/null
	if [ $? -ne 0 ]; then
		echo "<h2>$title</h2>" >> "$file"
	fi

	cat "$src" >> "$file"
	echo '</div>' >> "$file"
}

entry() {
	dir=` echo $1 | cut -d/ -f 2-5 | sed 's/.html$//'`
	file="$dir/index.sxhtml"

	mkdir -p "$dir"

	echo '<!--#include virtual="../../../../entry.inc" -->' > "$file"
	echo '<!--#include virtual="../../../../cal.inc" -->' >> "$file"

	contents "$1" "$file"

	echo '<!--#include virtual="../../../../footer.inc" -->' >> "$file"
}

recent() {
	file="$1"

	contents "$2" "$file"
}

for i in src/*/*/*/*.html; do
	entry "$i"
done




# TODO: most recent:
file=index.sxhtml

echo '<!--#include virtual="recent.inc" -->' > "$file"
echo '<!--#include virtual="cal.inc" -->' >> "$file"

IFS='|'
for i in `ls -1d src/*/*/*/*.html \
	| sed -E 's,^src/([0-9]{4})/([0-9]{2})/([0-9]{2})/(.+)\.html$,\1\2\3/\4,' \
	| sort -rn \
	| head -n 20 \
	| sed -E 's,^([0-9]{4})([0-9]{2})([0-9]{2})/(.+)$,src/\1/\2/\3/\4.html,' \
	| tr '\n' '|'`; do
	recent "$file" "$i"
done

echo '<!--#include virtual="footer.inc" -->' >> "$file"

