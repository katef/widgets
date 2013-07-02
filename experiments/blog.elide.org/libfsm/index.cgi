#!/usr/pkg/bin/rc

nl='
'

REPO=/home/kate/www/blog.elide.org/libfsm/repo
BASE=http://svn.elide.org/libfsm/www/blog

fn escape {
	echo $* | sed -E '
		s,&,\&amp;,g
		s,<,\&lt;,g
		s,>,\&gt;,g
	'
}

# $1 - "????/??/??/*.html"
fn entry {
	# TODO: get rid of $z. perhaps pass in just $1 $2 etc?
	o=$*
	*=`` / { echo $* }
	date=$1-^$2-^$3

	printf '\t<b:entry date="%s">\n' $date
	printf '\t\t<xi:include href="%s"/>\n' $REPO$o
	printf '\t</b:entry>\n'
}

{
	printf 'Content-type: application/xml+x-blog\r\n'
	printf '\r\n'
	echo '<?xml version="1.0"?>'

	echo '<!DOCTYPE b:blog PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"'
	echo '    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" ['

#	echo '    <!ENTITY %% xhtmllat1    SYSTEM "xhtml-lat1.ent">    %%xhtmllat1;'
#	echo '    <!ENTITY %% xhtmlsymbol  SYSTEM "xhtml-symbol.ent">  %%xhtmlsymbol;'
#	echo '    <!ENTITY %% xhtmlspecial SYSTEM "xhtml-special.ent"> %%xhtmlspecial;'

	echo ']>'

	echo '<?xml-stylesheet href="/srv/www/vhosts/elide.org/j5/blog-main.xsl" type="text/xsl"?>'

	echo '<b:blog xmlns:b="http://xml.elide.org/blog"'
	echo '      xmlns:xi="http://www.w3.org/2001/XInclude">'

	for (e in `` $nl { find $REPO -name '*.xhtml' }) {
		entry ` { echo $e | sed s,^$REPO,, }
	}

	echo '</b:blog>'
}

