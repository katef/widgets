<?xml version="1.0" standalone="yes"?>

<!-- $Id: base.xsl 199 2011-04-24 22:30:45Z kate $ -->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		Base parameters.

		This is conceptually equivalent to lx.base.mk, but for XSLT.
		These may be overridden by makefiles, on the command line for xsltproc.
	-->

	<xsl:param name="libfsm.ext"  select="'xhtml'"/>

	<xsl:param name="libfsm.url.man" select="'http://man.libfsm.org'"/>
	<xsl:param name="libfsm.url.www" select="'http://www.libfsm.org'"/>

</xsl:stylesheet>

