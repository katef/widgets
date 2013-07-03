<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:b="http://xml.elide.org/blog"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:cal="http://xml.elide.org/calendar"

	exclude-result-prefixes="b str date cal"

	extension-element-prefixes="str date">

	<xsl:import href="elide.xsl"/>
	<xsl:import href="blog.xsl"/>

	<xsl:param name="www-base"/>
	<xsl:param name="www-css"/>
	<xsl:param name="www-js"/>

	<!-- TODO: find this programatically -->
	<xsl:param name="base" select="'/'"/>

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
		<html>
			<head>
				<title>
					<xsl:text>Blog</xsl:text>
				</title>

				<link rel="stylesheet" href="{$www-css}/blog.css"/>
				<link rel="stylesheet" href="{$www-css}/valid.css"/>
				<link rel="stylesheet" href="{$www-css}/calendar.css"/>

<link rel="stylesheet" href="{$www-css}/elide.css"/>
<link rel="stylesheet" href="{$www-css}/listing.css"/>

				<script src="{$www-js}/blog.js"     type="text/javascript"></script>
				<script src="{$www-js}/valid.js"    type="text/javascript"></script>
				<script src="{$www-js}/template.js" type="text/javascript"></script>	<!-- TODO: only where needed -->
			</head>

			<body onload="Valid.init(document.documentElement)">
				<h1 id="title">
					<xsl:variable name="title">
						<xsl:call-template name="b:title"/>
					</xsl:variable>

					<xsl:text>Kate's Amazing Blog</xsl:text>

					<xsl:if test="$title">
						<xsl:text> - </xsl:text>
						<xsl:copy-of select="$title"/>
					</xsl:if>
				</h1>

				<xsl:call-template name="contents"/>

				<div class="cal-index">
					<xsl:call-template name="b:calendar"/>

					<hr/>

					<ol class="years">
						<xsl:call-template name="b:years"/>
					</ol>
				</div>

				<xsl:call-template name="b:content"/>


				<xsl:call-template name="rcsid"/>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>

