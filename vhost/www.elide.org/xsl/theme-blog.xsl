<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:tl="http://xml.elide.org/timeline"

	exclude-result-prefixes="h tl">

	<xsl:import href="../../../xsl/theme.xsl"/>
	<xsl:import href="../../../xsl/img.xsl"/>
	<xsl:import href="../../../xsl/blog.xsl"/>
	<xsl:import href="../../../xsl/copy.xsl"/>

	<xsl:import href="theme.xsl"/>

	<xsl:param name="www-css"/>
	<xsl:param name="www-js"/>

	<!-- TODO: centralise relative path to root (see also theme-bib.xsl for the same) -->
	<xsl:param name="blog-file"/>
	<xsl:param name="blog-data" select="document(concat('../../../', $blog-file))"/>

	<xsl:template match="/h:html/h:head/h:title" mode="body">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<xsl:template match="/h:html">
		<xsl:variable name="category" select="//h:meta[@name = 'category']/@content"/>

		<xsl:variable name="page">
			<xsl:apply-templates select="h:head/h:title" mode="body"/>
		</xsl:variable>

		<xsl:call-template name="elide-output">
			<xsl:with-param name="class"    select="concat(@class, ' hyphenate')"/>

			<xsl:with-param name="page">
				<xsl:copy-of select="$page"/>
			</xsl:with-param>

			<xsl:with-param name="head">
				<xsl:copy-of select="h:head/h:meta[@name = 'description']"/>
				<xsl:copy-of select="h:head/h:meta[@name = 'keywords']"/>
			</xsl:with-param>

			<xsl:with-param name="main">
				<xsl:apply-templates select="h:body/node()" mode="copy"/>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>


	<!-- TODO: centralise PIs to pi/*.xsl -->

	<xsl:template match="processing-instruction('blog-archive')" mode="copy">
		<xsl:apply-templates select="$blog-data/tl:timeline" mode="tl-archive"/>
	</xsl:template>

	<xsl:template match="processing-instruction('blog-body')" mode="copy">
		<xsl:apply-templates select="$blog-data/tl:timeline" mode="tl-body"/>
	</xsl:template>

	<xsl:template match="processing-instruction('blog-index')" mode="copy">
		<xsl:apply-templates select="$blog-data/tl:timeline" mode="tl-index"/>
	</xsl:template>

</xsl:stylesheet>

