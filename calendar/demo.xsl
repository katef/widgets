<?xml version="1.0" encoding="utf-8"?>
<?xml-stylesheet href="demo.xhtml" type="text/xsl"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:str="http://exslt.org/strings"
	xmlns:kxslt="http://xml.elide.org/mod_kxslt"
	xmlns:cal="http://xml.elide.org/calendar"

	extension-element-prefixes="kxslt date str cal">

	<xsl:import href="calendar.xsl"/>

	<xsl:output method="xml" ident="yes" encoding="utf-8"
		doctype-public="-//W3C//DTD XHTML 1.1//EN"
		doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/>

	<xsl:template match="/">
		<xsl:processing-instruction name="xml-stylesheet">
			<xsl:text>href="/elide.xsl" type="text/xsl"</xsl:text>
		</xsl:processing-instruction>

		<xsl:apply-templates select="*"/>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="processing-instruction('demo')">
		<xsl:call-template name="cal:calendar">
			<xsl:with-param name="date" select="date:date()"/>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>

