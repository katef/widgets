<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:common="http://exslt.org/common"
	xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	extension-element-prefixes="common func str"

	exclude-result-prefixes="h common func str">

	<xsl:import href="copy.xsl"/>
	<xsl:import href="output.xsl"/>

	<!--
		The main purpose of this is to copy through XHTML source to the
		output document. This cannot be done in output.xsl because
		output.xsl is not aware that the source may be (unthemed) XHTML.
	-->

	<!-- TODO: centralise -->
	<func:function name="str:contains-word">
		<xsl:param name="string"/>
		<xsl:param name="word"/>

		<func:result select="boolean(str:tokenize($string, ' ')[. = $word])"/>
	</func:function>

	<xsl:template match="node()" mode="copy">
		<xsl:apply-templates select="node()|text()|processing-instruction()"/>
	</xsl:template>

	<xsl:template name="theme-output">
		<xsl:param name="css"    select="''"/>
		<xsl:param name="fonts"  select="''"/>
		<xsl:param name="js"     select="''"/>
		<xsl:param name="onload" select="''"/>
		<xsl:param name="class"  select="false()"/>

		<xsl:param name="page"   select="/.."/>
		<xsl:param name="site"   select="/.."/>
		<xsl:param name="head"   select="/.."/>
		<xsl:param name="body"   select="/.."/>

		<xsl:call-template name="output-content">
			<xsl:with-param name="method" select="'html'"/>

			<xsl:with-param name="css"    select="$css"/>
			<xsl:with-param name="fonts"  select="$fonts"/>
			<xsl:with-param name="js"     select="$js"/>
			<xsl:with-param name="onload" select="$onload"/>
			<xsl:with-param name="class"  select="$class"/>

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

