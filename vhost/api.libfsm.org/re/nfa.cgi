#!/bin/sh

#echo -e 'Content-Type: text/plain\r'

# REQUEST_URI

RE=/home/kate/www/dioptre.org/re/libre/src/cli/re
FSM=/home/kate/www/dioptre.org/re/libfsm/src/cli/fsm

#PREFIX="$SCRIPT_NAME"
PREFIX="/re/nfa.cgi"

echo -n "$REQUEST_URI" \
	| sed -E "s,^$PREFIX\??,," \
	| perl -pe 's/%([0-9a-f]{2})/sprintf("%s", pack("H2",$1))/eig' \
	| ${RE} -dis /dev/stdin \
	> /dev/null
if [ $? != 0 ]; then
#	echo -e 'HTTP/1.0 400 Syntax error\r'
	echo -e 'Content-Type: text/plain\r'
	echo -e '\r'

	echo -n 'syntax error: '

echo -n "$REQUEST_URI" \
		| sed -E "s,^$PREFIX\??,," \
		| perl -pe 's/%([0-9a-f]{2})/sprintf("%s", pack("H2",$1))/eig'

	exit 0
fi

echo -e 'Content-Type: image/svg+xml\r'
echo -e '\r'

echo -n "$REQUEST_URI" \
	| sed -E "s,^$PREFIX\??,," \
	| perl -pe 's/%([0-9a-f]{2})/sprintf("%s", pack("H2",$1))/eig' \
	| ${RE} -dis /dev/stdin \
	| ${FSM} -ca -l dot \
	| dot -Tsvg -Efontname='verdana' -Efontsize=11 \
	| xsltproc --nonet --nowrite --nomkdir --novalid --xincludestyle svg.xsl - \
	| xmllint --nonet --format -

