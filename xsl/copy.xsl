<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="comment()" mode="copy"/>

	<xsl:template match="processing-instruction()" mode="copy">
		<xsl:copy-of select="."/>
	</xsl:template>

	<!-- XXX: for some reason <xsl:copy> would output "<br></br>" -->
	<xsl:template match="*[not(node())]" mode="copy">
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

	<xsl:template match="node()" mode="copy">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="copy"/>
		</xsl:copy>
	</xsl:template>

	<!-- TODO: fall through to text.xsl whitespace normalisation for text() -->
	<xsl:template match="@*|text()" mode="copy">
		<xsl:copy-of select="."/>
	</xsl:template>

</xsl:stylesheet>

