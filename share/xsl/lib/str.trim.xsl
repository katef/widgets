<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings"
	xmlns:common="http://exslt.org/common"

	extension-element-prefixes="func str"

	exclude-result-prefixes="func str">

	<func:function name="str:trim">
		<xsl:param name="string"/>
		<xsl:param name="space" select="'&#x9;&#xA;&#xD;&#x20;&#x2009;'"/>

		<!-- XXX: this is not really triming; inter-token whitespace needs preservation -->
		<func:result select="str:concat(str:tokenize($string, $space))"/>
	</func:function>

</xsl:stylesheet>

