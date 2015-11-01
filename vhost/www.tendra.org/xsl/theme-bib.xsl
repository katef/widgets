<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings"
	xmlns:h="http://www.w3.org/1999/xhtml"

	extension-element-prefixes="str"

	exclude-result-prefixes="h str">

	<xsl:import href="../../../xsl/lib/str.tolower.xsl"/>

	<xsl:import href="../../../xsl/copy.xsl"/>
	<xsl:import href="../../../xsl/bibt2html.xsl"/>

	<xsl:import href="theme.xsl"/>

<!-- TODO: set params for tendra-specific bib2html configuration
(citation style, use ol rather than dl)
have bib2html sort by date then name. no sorting? tendra's order is done by hand
-->

<!--
	<xsl:param name="www-css"/>
	<xsl:param name="www-js"/>
	<xsl:param name="uri"/>
-->

	<xsl:param name="bib-base"/>

	<xsl:template match="/h:html/h:head/h:title" mode="body">
		<xsl:apply-templates select="node()" mode="copy"/>
	</xsl:template>

	<xsl:template match="processing-instruction('bib')" mode="copy">
		<!-- TODO: variable for '../../../' to get to www base -->
		<xsl:variable name="file" select="concat('../../../', $bib-base,
			substring-before(., '.bib'), '.xml')"/>
		<xsl:apply-templates select="document($file)"/>
	</xsl:template>

	<xsl:template match="/h:html">
		<xsl:variable name="category" select="//h:meta[@name = 'category']/@content"/>

		<xsl:variable name="page">
			<xsl:apply-templates select="h:head/h:title" mode="body"/>
		</xsl:variable>

		<xsl:call-template name="tendra-output">
			<xsl:with-param name="category" select="$category"/>
			<xsl:with-param name="class"    select="concat(@class, ' hyphenate')"/>

			<xsl:with-param name="page">
				<xsl:copy-of select="$page"/>
			</xsl:with-param>

			<xsl:with-param name="head">
				<xsl:copy-of select="h:head/h:meta[@name = 'description']"/>
				<xsl:copy-of select="h:head/h:meta[@name = 'keywords']"/>
			</xsl:with-param>

			<xsl:with-param name="main">
				<h1>
					<xsl:apply-templates select="h:head/h:title" mode="body"/>
				</h1>

				<xsl:apply-templates select="h:body/node()" mode="copy"/>
			</xsl:with-param>

			<xsl:with-param name="sidebar">
				<xsl:apply-templates select="h:nav/node()" mode="copy"/>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

