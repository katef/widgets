#!/bin/sh
# $Id$

# Regnerate journal entries

# $1 - dest
# $2 - src
contents() {
	file="$1"
	src="$2"

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

	contents "$file" "$1"

	echo '<!--#include virtual="../../../../footer.inc" -->' >> "$file"
}

year() {
	dir=` echo $1 | cut -d/ -f 2`
	file="$dir/index.sxhtml"

	mkdir -p "$dir"

	echo '<!--#include virtual="../year.inc" -->' > "$file"

	iterate 20 "src/$dir/??/??/*.html" "$file"

	echo '<!--#include virtual="../footer.inc" -->' >> "$file"
}

# $1 - Number of items
# $2 - glob, e.g. src/????/??/??/*.html
gettoplist() {
	ls -1d $2 \
		| sed -E 's,^src/([0-9]{4})/([0-9]{2})/([0-9]{2})/(.+)\.html$,\1\2\3/\4,' \
		| sort -rn \
		| head -n $1 \
		| sed -E 's,^([0-9]{4})([0-9]{2})([0-9]{2})/(.+)$,src/\1/\2/\3/\4.html,'
}

# Iterate through a list, calling a callback for each
# $1 - number of items
# $2 - glob
# $3 - file
iterate() {
	IFS='|'
	for i in `gettoplist $1 "$2" \
		| tr '\n' '|'`; do
		contents "$3" "$i"
	done
}

date_year=`date +%Y`
date_mon=`date +%B`
date_day="`date +%e`"

# Calendar
echo '<div class="cal">' > cal.inc
echo '<table>' >> cal.inc
echo "<tr><th>&lt;</th><th colspan='5'>$date_mon</th><th>&gt;</th></tr>" >> cal.inc
cal \
	| grep -v $date_year \
	| sed -E 's,(..)( |$),<td>\1</td>,g; s,$,</td></tr>,; s,^,<tr>,' \
	| sed -E "s,$date_day,<em>&</em>," \
	>> cal.inc
echo '</table>' >> cal.inc
echo '<hr/>' >> cal.inc

for i in `ls -1d src/???? | cut -f 2 -d / | sort -n`; do
	yy=`echo $i | cut -c 3-`
	echo "<a href=\"$i\">&rsquo;$yy</a> " >> cal.inc
done

echo '</div>' >> cal.inc

# Single entries
for i in src/????/??/??/*.html; do
	entry "$i"
done

# Years
for i in src/????/??/??/*.html; do
	year "$i"
done


# Most recent
file=index.sxhtml

echo '<!--#include virtual="recent.inc" -->' > "$file"
echo '<!--#include virtual="cal.inc" -->' >> "$file"

iterate 20 'src/????/??/??/*.html' "$file"

echo '<!--#include virtual="footer.inc" -->' >> "$file"

