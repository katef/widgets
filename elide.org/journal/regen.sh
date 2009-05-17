#!/bin/sh
# $Id$

# Regnerate journal entries

# $1 - number
monthname() {
	case $1 in
	01)
		echo Jan
		;;
	02)
		echo Feb
		;;
	03)
		echo Mar
		;;
	04)
		echo Apr
		;;
	05)
		echo May
		;;
	06)
		echo Jun
		;;
	07)
		echo Jul
		;;
	08)
		echo Aug
		;;
	09)
		echo Sep
		;;
	10)
		echo Oct
		;;
	11)
		echo Nov
		;;
	12)
		echo Dec
		;;
	esac
}

# $1 - daydir: 2007/06/12
# $2 - filec: a number
#
# 2007 -> 06/12
# 2007/06 -> 12
# 2007/07/12 ->
# 2007/07/12/0 -> ../
relimg() {
	p=`echo $1 | cut -d / -f $2-`
	if [ -z $p ]; then
		echo ..
	else
		echo $p
	fi
}

# $1 - dest
# $2 - src
contents() {
	file="$1"
	src="$2"

	y="`echo $src | cut -d/ -f 2 | cut -c 3-`"
	m="`echo $src | cut -d/ -f 3`"
	d="`echo $src | cut -d/ -f 4 | sed 's/^0//'`"
	date="$d `monthname $m` &rsquo;$y"

	daydir="`echo $src | cut -f 2- -d/ | rev | cut -f 2- -d/ | rev`"
	title="`echo $src | cut -d/ -f 5 | sed 's/.html$//'`"

	echo "<span class=\"date\"><a href=\"TODO\">$date</a></span>" >> "$file"

	echo -n '<div class="entry">' >> "$file"

	# Numeric titles are unititled posts
	echo $title | egrep '^[0-9]+$' > /dev/null
	if [ $? -ne 0 ]; then
		echo "<h2>$title</h2>" >> "$file"
	fi

	content="`cat \"$src\"`"
	# Makeshift image stuff
	filec=`echo $file | sed 's/[^/]//g' | wc -c`
	relimgpath=`relimg $daydir $filec`
	content="`echo "$content" \
		| sed 's,<?img *\(.*\):\(.*\) *?>,<a href="'$relimgpath'/\2" title="\1"><img alt="\1" src="'$relimgpath'/thumb-\2"/></a>,g' \
		| sed 's,<?img *\(.*\) *?>,<a href="'$relimgpath'/\1"><img src="'$relimgpath'/thumb-\1"/></a>,g' \
		`"

	# This is a bit enthusiastic
	# TODO: it needs to not modify things inside URLs, or inside <pre>, <code> etc
	echo "$content" | sed -E 's,([A-Z][A-Z]+)[ \n],<acronym>&</acronym>,g' \
		>> "$file"
	echo '</div>' >> "$file"
}

entry() {
	dir=` echo $1 | cut -d/ -f 2-5 | sed 's/.html$//'`
	m=` echo $1 | cut -d/ -f 3`
	y=` echo $1 | cut -d/ -f 2`
	file="$dir/index.sxhtml"

	mkdir -p "$dir"

	echo '<!--#include virtual="../../../../entry.inc" -->' > "$file"
	echo '<!--#include virtual="../../../../../contents.inc" -->' >> "$file"

	gencal "$file" $y $m
	contents "$file" "$1"

	echo '<!--#include virtual="../../../../footer.inc" -->' >> "$file"
}

year() {
	dir=` echo $1 | cut -d/ -f 2`
	file="$dir/index.sxhtml"

	mkdir -p "$dir"

	echo '<!--#include virtual="../year.inc" -->' > "$file"
	echo '<!--#include virtual="../../contents.inc" -->' >> "$file"

	# TODO show calendar for the current date here
	gencal "$file" $y
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

# Iterate through a list
# $1 - number of items
# $2 - glob
# $3 - file
iterate() {
	x="$IFS"
	IFS='|'
	for i in `gettoplist $1 "$2" \
		| tr '\n' '|'`; do
		contents "$3" "$i"
	done
	IFS="$x"
}

mostrecent() {
	file=index.sxhtml
	y=`date +%Y`
	m=`date +%m`

	echo '<!--#include virtual="recent.inc" -->' > "$file"
	echo '<!--#include virtual="../contents.inc" -->' >> "$file"

	gencal "$file" $y $m
	iterate 20 'src/????/??/??/*.html' "$file"

	echo '<!--#include virtual="footer.inc" -->' >> "$file"
}

# $1 - file
# $2 - year
# $3 - month (optional)
gencal() {
	y=`date +%y`

	echo '<div class="cal">' >> "$1"

	if [ ! -z $3 ]; then
		# XXX: month name should come from $3
		mn=`date +%B`
		yy=`echo $2 | cut -c 3-`

		echo '<table>' >> "$1"
		echo "<tr><th><a href="TODO">&#x25C0;</a></th><th colspan='5'>$mn &rsquo;$yy</th><th><a href="TODO">&#x25B6;</a></th></tr>" >> "$1"
		echo "<tr><th>Sun</th><th>Mon</th><th>Tue</th><th>Wed</th><th>Thu</th><th>Fri</th><th>Sat</th></tr>" >> "$1"

		caltxt="`cal $3 $2 \
			| grep -v $y \
			| grep -v Tu \
			| sed -E 's,(..)( |$),<td>\1</td>,g; s,$,</td></tr>,; s,^,<tr>,'`"

		if [ $2 -eq `date +%m` -a $3 -eq `date +%y` ]; then
			d=`date +%d`
			caltxt="`echo $caltxt | sed -E 's,$d,<em>&</em>,'`"
		fi

		# TODO: placeholder link
		echo $caltxt | sed 's/10/<a href="TODO">10<\/a>/' >> "$1"

		echo '</table>' >> "$1"
		echo '<hr/>' >> "$1"

	fi

	# Year list
	for i in `ls -1d src/???? | cut -f 2 -d / | sort -n`; do
		yy=`echo $i | cut -c 3-`
		echo "<a href=\"$i\">&rsquo;$yy</a> " >> "$1"
	done

	echo '</div>' >> "$1"
}

# Single entries
for i in src/????/??/??/*.html; do
	entry "$i"
done

# Years
for i in src/????/??/??/*.html; do
	year "$i"
done

# Most recent
mostrecent

# image stuff, kept in single entry locations
# TODO: for thumbnails, crop down to 80%
for img in `ls -1 src/????/??/??/*.jpeg src/????/??/??/*.jpg ????/??/??/*.png 2> /dev/null`; do
	file="`basename $img`"
	dstdir="`echo $img | rev | cut -f2- -d/ | rev | cut -f2- -d/`"
	install -m 644 $img $dstdir/$file
	convert -thumbnail x200 -shave '10%' $img $dstdir/thumb-$file
done

