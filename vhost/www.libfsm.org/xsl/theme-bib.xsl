<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:date="http://exslt.org/dates-and-times"

	exclude-result-prefixes="h">

	<xsl:import href="../../../xsl/bibt2html.xsl"/>

	<xsl:import href="theme.xsl"/>
	<xsl:import href="theme-plain.xsl"/>

	<xsl:param name="bib-base"/>

	<xsl:template match="processing-instruction('bib')" mode="copy">
		<!-- TODO: variable for '../../../' to get to www base -->
		<xsl:variable name="file" select="concat('../../../', $bib-base,
			substring-before(., '.bib'), '.xml')"/>
		<xsl:apply-templates select="document($file)"/>
	</xsl:template>

</xsl:stylesheet>

