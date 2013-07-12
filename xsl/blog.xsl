<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:str="http://exslt.org/strings"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:tl="http://xml.elide.org/timeline"
	xmlns:cal="http://xml.elide.org/calendar"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	exclude-result-prefixes="h tl date cal str">

	<xsl:import href="copy.xsl"/>
	<xsl:import href="timeline.xsl"/>

	<xsl:param name="blog-date"     select="substring(date:date(), 1, 10)"/>
	<xsl:param name="blog-timeline" select="/.."/>
	<xsl:param name="blog-short"    select="false()"/>

	<!-- TODO: keep timeline entries (suitable for SVN, too) seperate from blog specifics;
	so this file is equivalent to blog-main, and we have a centralised timeline.xsl
	which we can use for SVN and the blog
	of course svn's timeline won't need dates in the URL, since changset IDs are unique
	(so are the blog entry shorts, but the date in the URL is nice for other reasons,
	i.e. viewing an entire month, or viewing an entire year) -->
	<!-- TODO: so this file just glues PIs onto timeline.xsl -->

	<xsl:variable name="timeline"       select="document($blog-timeline)"/>
	<xsl:variable name="timeline-date"  select="$blog-date"/>
	<xsl:variable name="timeline-title" select="$blog-short"/>
	<xsl:variable name="timeline-short" select="$blog-short"/>

	<xsl:template name="tl:title">
		<xsl:choose>
			<xsl:when test="$timeline-date">
				<xsl:value-of select="$timeline-date"/>
			</xsl:when>

			<xsl:otherwise>
				<xsl:text>Blog</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tl:href">
		<xsl:param name="date"/>
		<xsl:param name="short" select="false()"/>

		<xsl:attribute name="href">
			<xsl:choose>
				<xsl:when test="$short">
					<xsl:value-of select="concat($blog-base,
						'/', date:year($date),
						'-', str:align(date:month-in-year($date), '00', 'right'),
						'-', str:align(date:day-in-month($date),  '00', 'right'),
						'/', $short)"/>
				</xsl:when>

				<xsl:when test="date:day-in-week($date)">
					<xsl:value-of select="concat($blog-base,
						'/', date:year($date),
						'-', str:align(date:month-in-year($date), '00', 'right'),
						'-', str:align(date:day-in-week($date),   '00', 'right'))"/>
				</xsl:when>

				<xsl:otherwise>
					<xsl:value-of select="concat($blog-base, '/', $date)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<!--
		We do this here (rather than when generating the consolidated blog.xml)
		because here we have the option of falling back to a .png instead,
		depending on the Accept header from mod_kxslt.
	-->
	<xsl:template match="tl:entry/h:html/h:body//h:img
		[not(starts-with(@src, 'http://'))]">

		<xsl:variable name="path" select="concat('blog',
			'/', translate(substring(ancestor::tl:entry/@date, 1, 10), '-', '/'),
			'/', ancestor::tl:entry/@short)"/>

		<xsl:variable name="file" select="substring-before(@src, '.')"/>
		<xsl:variable name="ext"  select="substring-after (@src, '.')"/>

		<!-- TODO: could also provide .fsm, perhaps -->
		<!-- TODO: could also provide data:// URLs -->
		<xsl:choose>
			<xsl:when test="$ext = 'dot'">
				<xsl:copy-of select="document(
					concat($path, '/', $file, '.svg'))"/>
			</xsl:when>

			<xsl:when test="$ext = 'txt'">
				<xsl:copy-of select="document(
					concat($path, '/', $file, '.xml'))"/>
			</xsl:when>

			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="processing-instruction('blog-title')">
		<xsl:call-template name="tl:title"/>
	</xsl:template>

	<xsl:template match="processing-instruction('blog-calendar')">
		<xsl:call-template name="tl:calendar"/>

		<hr/>

		<ol class="years">
			<xsl:call-template name="tl:years"/>
		</ol>
	</xsl:template>

	<xsl:template match="processing-instruction('blog-body')">
		<xsl:call-template name="tl:content"/>
	</xsl:template>

</xsl:stylesheet>

