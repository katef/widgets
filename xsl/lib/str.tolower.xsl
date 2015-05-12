<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings"
	xmlns:common="http://exslt.org/common"

	extension-element-prefixes="func str"

	exclude-result-prefixes="func str">

	<func:function name="str:tolower">
		<xsl:param name="s"/>

		<xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
		<xsl:variable name="lower" select="'abcdefghijlkmnopqrstuvwxyz'"/>

		<func:result select="translate($s, $upper, $lower)"/>
	</func:function>

</xsl:stylesheet>

