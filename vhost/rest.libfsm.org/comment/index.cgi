#!/usr/bin/env rc -Iop

fn error {
	printf 'Status: %u %s\r\n' $1 $2
	printf 'Access-Control-Allow-Origin: %s\r\n' $HTTP_REFERER
	printf 'Content-Length: 0\r\n'
	printf '\r\n'

	exit
}

fn success {
	# TODO: be stricter about this; what if HTTP_REFERER contains newline?
	printf 'Access-Control-Allow-Origin: %s\r\n' $HTTP_REFERER

	# TODO: cache headers for CORS access control
	# TODO: any others?
	printf 'Cache-Control: no-cache, must-revalidate\r\n'
	printf 'Pragma: no-cache\r\n'
	printf '\r\n'

	exit
}

fn validate {
	DTD = `{ dirname $SCRIPT_FILENAME }

	if (! test -f $DTD/comment.dtd) {
		error 500 'Missing DTD'
	}

	# XXX: need to find PI nodes and {}s in attributes; xmllint --xpath for that?

	xmllint --nonet --noout --dtdvalid $DTD/comment.dtd $1 >[2] /dev/null
}

fn submit {
	COMMENTFILE = $1

	if (~ $#COMMENTFILE 0) {
		error 500 'Missing comment file'
	}

	if (~ $#SVNURL 0) {
		error 500 'Missing SVNURL'
	}

	if (~ $#HTDOCS 0) {
		error 500 'Missing HTDOCS'
	}

	if (! test -f $HTDOCS/repo/$repo.xml) {
		error 500 'Missing repo file'
	}

	n = `{ svn --non-interactive info $SVNURL | grep '^Revision: ' | cut -f2 -d: }
	if (!~ $status 0) {
		error 502 'Couldn''t find revision'
	}

	svnmsg  = ( Comment by $author on $repo:$date/$shortform from $REMOTE_ADDR. )
	svnuser = ( www: $REMOTE_ADDR )
	svnpath = $SVNURL/www/$repo/$postpath/$shortform/comment-$n.xhtml5

	svn --non-interactive import -q --username $^svnuser \
		-m $^svnmsg $COMMENTFILE $svnpath
	if (!~ $status 0) {
		error 502 'Couldn''t import comment'
	}

	tmpappend = `{ mktemp -qt comment.append }
	if (!~ $status 0) {
		error 500 'Couldn''t create append file'
	}

	xsltproc -o $tmpappend                   \
	    --stringparam date      $date        \
	    --stringparam shortform $shortform   \
	    --stringparam comment   $COMMENTFILE \
	    append.xsl $HTDOCS/repo/$repo.xml
	if (!~ $status 0) {
		rm $tmpappend
		error 500 'Couldn''t append comment'
	}

	# cat to avoid $HTDOCS/repo needing to be writeable
	cat $tmpappend > $HTDOCS/repo/$repo.xml
	if (!~ $status 0) {
		rm $tmpappend
		error 500 'Couldn''t move append file'
	}
}

if (!~ $REQUEST_METHOD POST) {
	printf 'Allow: POST\r\n'
	error 405
}

if (!~ $CONTENT_TYPE text/plain) {
	error 405 'Bad content type'
}

if (!~ $REQUEST_URI /comment/*) {
	error 404
}

# TODO: support pre-flight requests: http://www.w3.org/TR/cors/#preflight-request

for (pair in `` '&' { echo -n $QUERY_STRING }) {
	pair = `` '=' { echo -n $pair }

	if (!~ $#pair 2) {
		pair = ($pair '')
	}

	if (!~ $#pair 2) {
		error 403
	}

	# XXX: ought to urlescape here; a browser could legitimately escape alnum
	switch ($pair(1)) {
	case repo;      repo      = $pair(2)
	case postpath;  postpath  = $pair(2)
	case date;      date      = $pair(2)
	case shortform; shortform = $pair(2)
	case author;    author    = $pair(2)
	case stuff1;    stuff1    = $pair(2)
	case stuff2;    stuff2    = $pair(2)
	case *;         error 403
	}
}

if (~ $#postpath 0) {
	if (!validate -) {
		error 400 'Invalid markup'
	}

	success
}

# TODO: centralise the following validation somehow:
{
	if (! echo $repo | egrep '^[a-z]+$' > /dev/null) {
		error 403
	}

	if (! echo $postpath | egrep '^[0-9/]+$' > /dev/null) {
		error 403
	}

	if (! echo $date | egrep '^[0-9-]+$' > /dev/null) {
		error 403
	}

	if (! echo $shortform | egrep '^[0-9a-z][0-9a-z-]*$' > /dev/null) {
		error 403
	}

	if (! echo $author | egrep '.' > /dev/null) {
		error 403
	}

	if (!~ $stuff1 `{ date +%Y }) {
		error 418 'Not a human'
	}

	if (!~ $stuff2 '') {
		error 418 'Not a human'
	}

	if (!~ $HTTP_ORIGIN http://$repo.libfsm.org) {
		error 403
	}

	if (!~ $HTTP_REFERER http://$repo.libfsm.org/*) {
		error 403
	}
}

COMMENTFILE = `{ mktemp -qt comment.post }
if (!~ $status 0) {
	error 500 'Couldn''t create comment file'
}

if (! xmllint --format --nonet -o $COMMENTFILE -) {
	rm $COMMENTFILE
	error 500 'Couldn''t format comment'
}

if (! validate $COMMENTFILE) {
	rm $COMMENTFILE
	error 400 'Invalid markup'
}

{
	LOCKFILE = $TMPDIR/lock.comment

	if (! test -d $TMPDIR) {
		error 500 'Missing TMPDIR'
	}

	# to prevent a race between $n and commit
	while (! ln -s / $LOCKFILE) {
		# TODO: add a timeout to give 408
		sleep 1
	}

	fn sigexit {
		rm $LOCKFILE
		rm $COMMENTFILE
	}

	submit $COMMENTFILE

	fn sigexit

	if (! rm $LOCKFILE) {
		error 409 'Missing lock file'
	}
}

if (! rm $COMMENTFILE) {
	error 409 'Missing comment file'
}

success

