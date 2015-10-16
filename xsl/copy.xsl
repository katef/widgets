<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="comment()"/>

	<xsl:template match="processing-instruction()">
		<xsl:copy-of select="."/>
	</xsl:template>

	<!-- XXX: for some reason <xsl:copy> would output "<br></br>" -->
	<xsl:template match="*[not(node())]">
		<xsl:text disable-output-escaping="yes">&lt;</xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:for-each select="@*">
			<xsl:text> </xsl:text>
			<xsl:value-of select="name()"/>
			<xsl:text>=</xsl:text>
			<xsl:text>"</xsl:text>
			<xsl:value-of select="."/>
			<xsl:text>"</xsl:text>
		</xsl:for-each>
		<xsl:text disable-output-escaping="yes">/&gt;</xsl:text>
	</xsl:template>

	<xsl:template match="node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()|processing-instruction()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|text()">
		<xsl:copy-of select="."/>
	</xsl:template>

</xsl:stylesheet>

