<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	extension-element-prefixes="func str"

	exclude-result-prefixes="func str">

	<func:function name="str:contains-word">
		<xsl:param name="string"/>
		<xsl:param name="word"/>

		<func:result select="boolean(str:tokenize($string, ' ')[. = $word])"/>
	</func:function>

</xsl:stylesheet>

