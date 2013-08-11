<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:str="http://exslt.org/strings"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:tl="http://xml.elide.org/timeline"
	xmlns:cal="http://xml.elide.org/calendar"
	xmlns:kxslt="http://xml.elide.org/mod_kxslt"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	exclude-result-prefixes="h kxslt tl date cal str">

	<xsl:import href="../xsl/theme.xsl"/>
	<xsl:import href="../xsl/timeline.xsl"/>

	<xsl:variable name="timeline" select="document('../repo/svn.xml')"/>

	<xsl:variable name="QUERY_STRING" select="kxslt:getenv('QUERY_STRING')"/>

	<xsl:variable name="timeline-limit" select="999"/>	<!-- TODO -->
	<xsl:variable name="timeline-date"  select="false()"/>

	<xsl:template name="tl:title">
		<xsl:choose>
			<xsl:when test="$timeline-shortform">
				<xsl:value-of select="$timeline-shortform"/>
			</xsl:when>

			<xsl:otherwise>
				<xsl:text>Changelog</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tl:href">
		<xsl:param name="date"/>
		<xsl:param name="shortform" select="false()"/>

		<xsl:attribute name="href">
<!-- TODO -->
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="processing-instruction('log-title')">
		<xsl:call-template name="tl:title"/>
	</xsl:template>

	<xsl:template match="processing-instruction('log-calendar')">
		<xsl:call-template name="tl:calendar"/>

		<hr/>

		<ol class="years">
			<xsl:call-template name="tl:years"/>
		</ol>

<!-- TODO:
		<hr/>

		<form class="log">
			<label><input type="checkbox"/>&#xA0;Blog entries</label>
			<label><input type="checkbox"/>&#xA0;Source</label>
			<label><input type="checkbox"/>&#xA0;Releases</label>
			<label><input type="checkbox"/>&#xA0;Tickets</label>
			<label><input type="checkbox"/>&#xA0;Build system</label>
			<label><input type="checkbox"/>&#xA0;Documentation</label>
			<label><input type="checkbox"/>&#xA0;Tests</label>
			<label><input type="checkbox"/>&#xA0;Examples</label>
			<label><input type="checkbox"/>&#xA0;Website</label>
		</form>
-->
	</xsl:template>

	<xsl:template match="processing-instruction('log-body')">
		<xsl:call-template name="tl:content"/>
	</xsl:template>

</xsl:stylesheet>

