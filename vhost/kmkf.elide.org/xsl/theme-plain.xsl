<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:str="http://exslt.org/strings"

	extension-element-prefixes="str"

	exclude-result-prefixes="h str">

	<xsl:import href="../../../xsl/theme.xsl"/>
	<xsl:import href="../../../xsl/man.xsl"/>
	<xsl:import href="../../../xsl/doctitle.xsl"/>
	<xsl:import href="theme.xsl"/>

	<!-- TODO: path from httpd as param -->
	<xsl:variable name="manindex" select="document('../../../var/kmkf-man/index.xhtml5')"/>

	<xsl:template match="/h:html">
		<xsl:call-template name="kmkf-output">
			<xsl:with-param name="page">
				<xsl:apply-templates select="h:head/h:title" mode="body"/>
			</xsl:with-param>

			<xsl:with-param name="head">
				<xsl:copy-of select="h:head/h:meta[@name = 'description']"/>
				<xsl:copy-of select="h:head/h:meta[@name = 'keywords']"/>
			</xsl:with-param>

			<xsl:with-param name="main">
				<xsl:call-template name="doctitle">
					<xsl:with-param name="product">
						<!-- TODO: centralise template -->
						<xsl:text>KMKF</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="title">
						<xsl:apply-templates select="h:head/h:title" mode="body"/>
					</xsl:with-param>
				</xsl:call-template>

				<xsl:apply-templates mode="copy" select="h:body"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>

