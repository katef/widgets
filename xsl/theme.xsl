<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:common="http://exslt.org/common"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	extension-element-prefixes="common"

	exclude-result-prefixes="h common">

	<xsl:import href="copy.xsl"/>
	<xsl:import href="output.xsl"/>

	<!-- XXX:
		doctype-public="HTML"
		doctype-system="TODO"
	-->
<!-- XXX: do i need this here, and not just in output.xsl?
	<xsl:output
		method="xml"
		encoding="utf-8"
		indent="yes"
		omit-xml-declaration="yes"
		cdata-section-elements="script"
		media-type="application/xhtml+xml"
		standalone="yes"/>
-->

	<xsl:template name="theme-title">
		<xsl:apply-templates select="h:head/h:title"/>
	</xsl:template>

	<xsl:template name="theme-head">
	</xsl:template>

	<xsl:template name="theme-content">
	</xsl:template>

	<xsl:template match="/h:html">
		<!-- XXX: hack until libxslt supports HTML5 -->
<!-- XXX:
		<xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;&#xA;</xsl:text>
-->

		<xsl:call-template name="output-content">
			<xsl:with-param name="method" select="'xhtml5'"/>

			<xsl:with-param name="css"   select="$theme-css"/>
			<xsl:with-param name="fonts" select="$theme-fonts"/>
			<xsl:with-param name="js"    select="$theme-js"/>

			<xsl:with-param name="title">
				<xsl:call-template name="theme-title"/>
			</xsl:with-param>

			<xsl:with-param name="content.head">
				<xsl:for-each select="h:head/h:link[@rel = 'stylesheet']">
					<xsl:copy-of select="."/>
				</xsl:for-each>

				<xsl:for-each select="h:head/h:script">
					<script>
						<xsl:copy-of select="attribute::*[not(name() = 'src')]"/>

						<xsl:choose>
							<xsl:when test="not(@src)">
								<xsl:copy-of select="node()|text()|processing-instruction()"/>
							</xsl:when>

							<xsl:otherwise>
								<xsl:copy-of select="@src"/>
							</xsl:otherwise>
						</xsl:choose>
					</script>
				</xsl:for-each>

				<xsl:call-template name="theme-head"/>
			</xsl:with-param>

			<xsl:with-param name="content.body">
				<xsl:call-template name="theme-content"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>

