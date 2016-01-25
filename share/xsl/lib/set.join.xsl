<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings"
	xmlns:set="http://exslt.org/sets"
	xmlns:common="http://exslt.org/common"

	extension-element-prefixes="func str set"

	exclude-result-prefixes="func str set">

	<func:function name="set:join">
		<xsl:param name="set"/>
		<xsl:param name="delim" select="' '"/>

		<func:result>
			<xsl:for-each select="$set">
				<xsl:if test="position() &gt; 1">
					<xsl:value-of select="$delim"/>
				</xsl:if>
				<xsl:value-of select="."/>
			</xsl:for-each>
		</func:result>
	</func:function>

</xsl:stylesheet>

