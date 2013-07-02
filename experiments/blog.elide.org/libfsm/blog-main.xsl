<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:b="http://xml.elide.org/blog"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:kxslt="http://xml.elide.org/mod_kxslt"
	xmlns:cal="http://xml.elide.org/calendar"

	exclude-result-prefixes="b kxslt str date cal"

	extension-element-prefixes="kxslt str date">


	<xsl:import href="blog.xsl"/>


	<!-- TODO: find this programatically -->
	<xsl:variable name="base" select="'/j5/'"/>

	<xsl:variable name="QUERY_STRING" select="kxslt:getenv('QUERY_STRING')"/>

	<xsl:variable name="blog-date"  select="substring($QUERY_STRING, 1,  10)"/>
	<xsl:variable name="blog-title" select="substring($QUERY_STRING, 12, string-length($QUERY_STRING) - 11)"/>


	<xsl:output indent="yes" method="xml" encoding="utf-8"
		cdata-section-elements="script"
		media-type="application/xhtml+xml"

		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>


	<xsl:template name="b:href">
		<xsl:param name="date"/>
		<xsl:param name="title" select="false()"/>

		<xsl:attribute name="href">
			<xsl:choose>
				<xsl:when test="$title">
					<xsl:value-of select="concat($base,
						date:year($date), '-', str:align(date:month-in-year($date), '00', 'right'),
						'-', str:align(date:day-in-month($date), '00', 'right'),
						'/', $title)"/>
				</xsl:when>

				<xsl:when test="date:day-in-week($date)">
					<xsl:value-of select="concat($base,
						date:year($date), '-', str:align(date:month-in-year($date), '00', 'right'),
						'#', str:align(date:day-in-week($date), '00', 'right'))"/>
				</xsl:when>

				<xsl:otherwise>
					<xsl:value-of select="concat($base, $date, '/')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="/b:blog">
		<xsl:processing-instruction name="xml-stylesheet">
			<xsl:text>href="/srv/www/vhosts/elide.org/elide.xsl" type="text/xsl"</xsl:text>
		</xsl:processing-instruction>

		<html>
			<head>
				<title>
					<xsl:text>Blog</xsl:text>
				</title>

				<meta rcsid="$Id$"/>

				<link rel="stylesheet" href="/j5/blog.css"/>
				<link rel="stylesheet" href="/j5/valid.css"/>
				<link rel="stylesheet" href="/calendar.css"/>

				<script src="/j5/blog.js"     type="text/javascript"></script>
				<script src="/j5/valid.js"    type="text/javascript"></script>
				<script src="/j5/template.js" type="text/javascript"></script>	<!-- TODO: only where needed -->
			</head>

			<body onload="Valid.init(document.documentElement)">
				<xsl:call-template name="b:blog"/>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>

