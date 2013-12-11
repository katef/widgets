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
					<tt class="command">
						<xsl:value-of select="concat(., '.', ../../mi:refmeta/mi:manvolnum)"/>
					</tt>
				</a>
			</dt>
		</xsl:for-each>

		<dd>
				<xsl:value-of select="mi:refnamediv/mi:refpurpose"/>
		</dd>
	</xsl:template>

	<xsl:template name="section">
		<xsl:param name="manvolnum"/>
		<xsl:param name="productname"/>

		<section class="manindex">
			<h1>
				<a id="{.}"/>
				<xsl:text>Section </xsl:text>
				<xsl:value-of select="$manvolnum"/>

				<xsl:if test="$productname">
					<span class="product">
						<xsl:value-of select="$productname"/>
					</span>
				</xsl:if>
			</h1>

			<dl>
				<xsl:apply-templates select="//mi:refentry
					[mi:refmeta/mi:manvolnum = $manvolnum]
					[not($productname) or mi:refentryinfo/mi:productname = $productname]">
					<xsl:sort select="."/>
				</xsl:apply-templates>
			</dl>
		</section>
	</xsl:template>

	<xsl:template match="mi:manvolnum" mode="section">
		<xsl:variable name="manvolnum" select="."/>

		<xsl:if test="//mi:refentry
			[mi:refmeta/mi:manvolnum = current()]
			[not(mi:refentryinfo/mi:productname)]">
			<xsl:call-template name="section">
				<xsl:with-param name="manvolnum" select="$manvolnum"/>
			</xsl:call-template>
		</xsl:if>

		<xsl:for-each select="//mi:refentry
			[mi:refmeta/mi:manvolnum = current()]/mi:refentryinfo/mi:productname
			[not(. = ../../preceding-sibling::mi:refentry
				[mi:refmeta/mi:manvolnum = current()]/mi:refentryinfo/mi:productname)]">
			<xsl:sort select="."/>
			<xsl:call-template name="section">
				<xsl:with-param name="manvolnum"   select="$manvolnum"/>
				<xsl:with-param name="productname" select="."/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="/mi:manindex">

		<xsl:call-template name="output-content">
			<xsl:with-param name="method" select="'xml'"/>

			<xsl:with-param name="title">
<!-- TODO -->
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

