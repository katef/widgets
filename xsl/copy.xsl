<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="comment()"/>

	<xsl:template match="processing-instruction()">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()|processing-instruction()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="text()|@*">
		<xsl:copy-of select="."/>
	</xsl:template>

</xsl:stylesheet>

