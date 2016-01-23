<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	extension-element-prefixes="func str"

	exclude-result-prefixes="func str">

	<func:function name="str:ends-with">
		<xsl:param name="string"/>
		<xsl:param name="end"/>

		<func:result select="substring($string, string-length($string) - string-length($end) + 1) != $end"/>
	</func:function>

</xsl:stylesheet>

