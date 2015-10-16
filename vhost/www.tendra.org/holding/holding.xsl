<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"

	exclude-result-prefixes="h">

	<xsl:import href="../../../xsl/copy.xsl"/>
	<xsl:import href="../../../xsl/theme.xsl"/>

	<xsl:template match="/h:html/h:head/h:title" mode="body">
		<xsl:apply-templates select="node()" mode="copy"/>
	</xsl:template>

	<xsl:template match="/h:html">
		<xsl:call-template name="theme-output">
			<xsl:with-param name="standalone" select="true()"/>
            <xsl:with-param name="class"      select="concat(@class, ' holding')"/>
			<xsl:with-param name="css"        select="'style.css holding.css'"/>

			<xsl:with-param name="page">
				<xsl:apply-templates select="h:head/h:title" mode="body"/>
			</xsl:with-param>

			<xsl:with-param name="head">
				<xsl:copy-of select="h:head/h:meta[@name = 'description']"/>
				<xsl:copy-of select="h:head/h:meta[@name = 'keywords']"/>
				<xsl:copy-of select="h:head/h:link"/>
			</xsl:with-param>

			<xsl:with-param name="body">
				<xsl:apply-templates select="h:body/node()" mode="copy"/>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

