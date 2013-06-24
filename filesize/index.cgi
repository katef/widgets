#!/bin/sh

echo -e "Content-Type: application/xhtml+xml\r\n"

xsltproc index.xsl index.xsl

