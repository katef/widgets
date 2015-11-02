<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings"
	xmlns:h="http://www.w3.org/1999/xhtml"

	extension-element-prefixes="str"

	exclude-result-prefixes="h str">

	<xsl:import href="../../../xsl/lib/str.tolower.xsl"/>

	<xsl:import href="../../../xsl/bibt2html.xsl"/>

	<xsl:import href="theme.xsl"/>
	<xsl:import href="theme-plain.xsl"/>

<!-- TODO: set params for tendra-specific bib2html configuration
(citation style, use ol rather than dl)
have bib2html sort by date then name. no sorting? tendra's order is done by hand
-->

	<xsl:param name="bib-base"/>

	<xsl:template match="processing-instruction('bib')" mode="copy">
		<!-- TODO: variable for '../../../' to get to www base -->
		<xsl:variable name="file" select="concat('../../../', $bib-base,
			substring-before(., '.bib'), '.xml')"/>
		<xsl:apply-templates select="document($file)"/>
	</xsl:template>

</xsl:stylesheet>

