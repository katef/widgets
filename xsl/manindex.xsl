<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:mi="http://xml.elide.org/manindex"

	exclude-result-prefixes="mi">

	<xsl:import href="copy.xsl"/>
	<xsl:import href="output.xsl"/>

	<xsl:template match="mi:refentry">
		<xsl:for-each select="mi:refnamediv/mi:refname">
			<xsl:sort select="."/>

			<dt>
				<a href="{concat(../../mi:refmeta/mi:refentrytitle,
					'.', ../../mi:refmeta/mi:manvolnum)}">	<!-- canonical page name -->
<!-- TODO: apply-templates for proper XHTML output -->
					<xsl:value-of select="concat(., '.', ../../mi:refmeta/mi:manvolnum)"/>
				</a>
			</dt>
		</xsl:for-each>

		<dd>
				<xsl:value-of select="mi:refnamediv/mi:refpurpose"/>
		</dd>
	</xsl:template>

	<xsl:template match="mi:manvolnum" mode="section">
		<section>
			<h1>
				<a id="{.}"/>
				<xsl:text>Section </xsl:text>
				<xsl:value-of select="."/>
			</h1>

			<dl class="manindex">
				<xsl:apply-templates select="//mi:refentry[mi:refmeta/mi:manvolnum = current()]">
					<!-- TODO: sort by file extension first, if present -->
					<xsl:sort select="."/>
				</xsl:apply-templates>
			</dl>
		</section>
	</xsl:template>

	<xsl:template match="/mi:manindex">

		<xsl:call-template name="output-content">
			<xsl:with-param name="method" select="'xml'"/>

			<xsl:with-param name="title">
<xsl:text>TODO</xsl:text>
			</xsl:with-param>

			<xsl:with-param name="body">
				<xsl:apply-templates select="mi:refentry/mi:refmeta/mi:manvolnum
					[not(. = ../../preceding-sibling::mi:refentry/mi:refmeta/mi:manvolnum)]" mode="section">
					<xsl:sort select="."/>
				</xsl:apply-templates>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

