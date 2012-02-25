#!/usr/bin/env rc -Iop

# TODO: maybe phrase this as a trap on exit? so 'exit 404' vs. exit 201
fn error {
	printf 'Status: %u %s\r\n' $1 $2
	printf 'Access-Control-Allow-Origin: %s\r\n' $HTTP_REFERER
	printf 'Content-Length: 0\r\n'
	printf '\r\n'

	exit 0
}

fn success {
	# TODO: be stricter about this; what if HTTP_REFERER contains newline?
	printf 'Access-Control-Allow-Origin: %s\r\n' $HTTP_REFERER

	# TODO: cache headers for CORS access control
	# TODO: any others?
	printf 'Cache-Control: no-cache, must-revalidate\r\n'
	printf 'Pragma: no-cache\r\n'
	printf '\r\n'

	exit 0
}

fn validate {
	DTD = `{ dirname $SCRIPT_FILENAME }

	if (! test -f $DTD/comment.dtd) {
		error 500 'Missing DTD'
	}

	xmllint --nonet --noout --dtdvalid $DTD/comment.dtd $1 >[2] /dev/null
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
	case id;        id        = $pair(2)
	case shortform; shortform = $pair(2)
	case stuff1;    stuff1    = $pair(2)
	case stuff2;    stuff2    = $pair(2)
	case *;         error 403
	}
}

if (~ $#id 0) {
	if (!validate -) {
		error 400 'Invalid markup'
	}

	success
}

# TODO: centralise the following validation somehow:

if (! echo $repo | egrep '^[a-z]+$' > /dev/null) {
	error 403
}

if (! echo $id | egrep '^[0-9/]+$' > /dev/null) {
	error 403
}

if (! echo $shortform | egrep '^[0-9a-z][0-9a-z-]*$' > /dev/null) {
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

# TODO: support pre-flight requests: http://www.w3.org/TR/cors/#preflight-request

# See .htaccess
# TODO: this probably ought to be a directory which just contains svn www/,
# and only has the blog etc directories checked out
if (~ $#REPO_BASE 0) {
	error 500 'Missing $REPO_BASE'
}

if (~ $#REPO_BASE 0) {
	error 500 'Missing $REPO_BASE'
}

if (! test -d $REPO_BASE/$repo/$id/$shortform) {
	error 404
}

if (! cd $REPO_BASE/$repo/$id/$shortform) {
	error 500 'Couldn''t change directory'
}

while (! ln -s / lock.comment) {
	# TODO: add a timeout to give 408
	sleep 1
}

# TODO: and henceforth we could be killed by apache timing out on us,
# which we need to trap to remove the lockfile
# (and remove that trap after the lockfile is gone?)
{
	n = `{ ls -1 [0-9]*.xhtml5 | cut -f1 -d. | sort -rn | head -n 1 }

	if (~ $#n 0) {
		n = 0
	} else {
		n = `{ expr $n + 1 }
	}

	if (test -d $n.xhtml5) {
		rm lock.comment
		error 409 'Comment ID conflict'
	}

	cat > $n.xhtml5
}

if (! rm lock.comment) {
	error 409 'Missing lock file'
}

if (!validate $n.xhtml5) {
	rm $n.xhtml5
	error 400 'Invalid markup'
}

# TODO: commit to svn? (503 if failed, and rm the comment) put client IP etc in the commit message

# TODO: rebuild the website for blog stuff
# TODO: need to decide on $PREFIX 'make install' layout first

success

