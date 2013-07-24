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

	<!-- TODO: maybe roll this into output.xsl -->
	<xsl:template name="theme-output">
		<xsl:param name="css"    select="''"/>
		<xsl:param name="fonts"  select="''"/>
		<xsl:param name="js"     select="''"/>
		<xsl:param name="onload" select="''"/>

		<xsl:param name="page"   select="/.."/>
		<xsl:param name="site"   select="/.."/>
		<xsl:param name="head"   select="/.."/>
		<xsl:param name="body"   select="/.."/>

		<xsl:call-template name="output-content">
			<xsl:with-param name="method" select="'xhtml5'"/>

			<xsl:with-param name="css"    select="$css"/>
			<xsl:with-param name="fonts"  select="$fonts"/>
			<xsl:with-param name="js"     select="$js"/>
			<xsl:with-param name="onload" select="$onload"/>

			<xsl:with-param name="title">
				<xsl:copy-of select="$page"/>

				<xsl:if test="$site and $page">
					<xsl:text> &#8211;&#xa0;</xsl:text>
				</xsl:if>

				<xsl:copy-of select="$site"/>
			</xsl:with-param>

			<xsl:with-param name="head">
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

				<!-- TODO: meta headers for prev/next links -->

				<xsl:copy-of select="$head"/>
			</xsl:with-param>

			<xsl:with-param name="body" select="$body"/>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

