<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:cal="http://xml.elide.org/calendar"
	xmlns:b="http://xml.elide.org/blog"
	xmlns:e="http://xml.elide.org/elide_website"

	exclude-result-prefixes="e b str date cal"

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

	<!-- TODO: rename category to section or something -->
	<xsl:template name="e:category-title">
		<xsl:text>Blog</xsl:text>
	</xsl:template>

	<xsl:template name="e:subpage-title">
		<xsl:variable name="title">
			<xsl:call-template name="b:title"/>
		</xsl:variable>

		<xsl:if test="$title">
			<xsl:copy-of select="$title"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="e:page-head">
		<link rel="stylesheet" href="{$www-css}/blog.css"/>
		<link rel="stylesheet" href="{$www-css}/valid.css"/>
		<link rel="stylesheet" href="{$www-css}/calendar.css"/>

		<script src="{$www-js}/blog.js"     type="text/javascript"></script>
		<script src="{$www-js}/valid.js"    type="text/javascript"></script>

		<!-- TODO: only where needed -->
		<script src="{$www-js}/template.js" type="text/javascript"></script>
	</xsl:template>

	<xsl:template name="e:page-onload">
		<xsl:text>Valid.init(document.documentElement);</xsl:text>
	</xsl:template>

	<xsl:template name="e:page-body">
		<div class="cal-index">
			<xsl:call-template name="b:calendar"/>

			<hr/>

			<ol class="years">
				<xsl:call-template name="b:years"/>
			</ol>
		</div>

		<xsl:call-template name="b:content"/>
	</xsl:template>

	<xsl:template name="e:page-footer">
		<!-- TODO: something involving actual content here -->
		<tt class="rcsid">
			<xsl:text>$Id$</xsl:text>
		</tt>
	</xsl:template>

	<xsl:template match="/b:blog">
		<xsl:call-template name="e:page"/>
	</xsl:template>

</xsl:stylesheet>

