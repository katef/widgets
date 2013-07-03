<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:env="http://xml.elide.org/printenv"
 	xmlns:dyn="http://exslt.org/dynamic"

	extension-element-prefixes="dyn">

	<xsl:param name="uri"/>
	<xsl:param name="host"/>
	<xsl:param name="scheme"/>
	<xsl:param name="server_name"/>

	<xsl:param name="blog_date"/>
	<xsl:param name="blog_title"/>

	<xsl:output method="text" encoding="utf-8"
		cdata-section-elements="script"
		media-type="plain/text"/>

	<xsl:template match="xsl:param">
		<xsl:value-of select="@name"/>
		<xsl:text>: </xsl:text>
		<xsl:value-of select="dyn:evaluate(concat('$', @name))"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>

	<xsl:template match="/">
		<xsl:apply-templates select="document('')//xsl:param"/>
	</xsl:template>

</xsl:stylesheet>

