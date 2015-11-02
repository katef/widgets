<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"

	exclude-result-prefixes="h">

	<xsl:import href="../../../xsl/theme.xsl"/>
	<xsl:import href="../../../xsl/glossary.xsl"/>

	<xsl:import href="theme.xsl"/>
	<xsl:import href="theme-plain.xsl"/>

	<xsl:template match="processing-instruction('glossary')" mode="copy">
		<xsl:call-template name="glossary"/>
	</xsl:template>

</xsl:stylesheet>

