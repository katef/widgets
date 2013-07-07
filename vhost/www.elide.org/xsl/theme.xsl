<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:c="http://xml.elide.org/elide_contents"
	xmlns:e="http://xml.elide.org/elide_website"

	exclude-result-prefixes="h c e">

	<xsl:param name="www-base"/>
	<xsl:param name="www-css"/>
	<xsl:param name="www-js"/>
	<xsl:param name="uri"/>

	<xsl:output indent="yes" method="xml" encoding="utf-8"
		media-type="application/xhtml+xml"

		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>

	<c:contents>
		<c:category href="http://blog.elide.org/"         name="Blog"/>
		<c:category href="http://www.elide.org/snippets/" name="Snippets"/>
		<c:category href="http://www.elide.org/small/"    name="Small Programs"/>
		<c:category href="http://www.elide.org/projects/" name="Projects"/>
	</c:contents>

	<xsl:template name="e:contents">
		<ul id="contents">
			<xsl:for-each select="document('')//c:contents/c:category">
				<li>
					<xsl:if test="starts-with(concat($scheme, '://', $host, $uri), @href)">
						<xsl:attribute name="class">
							<xsl:text>current</xsl:text>
						</xsl:attribute>
					</xsl:if>

					<a href="{@href}">
						<xsl:value-of select="@name"/>
					</a>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>

	<xsl:template name="e:category-title">
		<xsl:text>Website</xsl:text>
	</xsl:template>

	<xsl:template name="e:subpage-title">
		<xsl:apply-templates select="h:head/h:title"/>
	</xsl:template>

	<!-- TODO: rename contents to toc -->
	<xsl:template name="e:title-header">
		<xsl:call-template name="e:title-head"/>
	</xsl:template>

	<xsl:template name="e:title-head">
		<xsl:text>Kate&#8217;s&#160;Amazing </xsl:text>
		<xsl:call-template name="e:category-title"/>

		<xsl:variable name="subpage">
			<xsl:call-template name="e:subpage-title"/>
		</xsl:variable>

		<xsl:if test="$subpage">
			<xsl:text> &#8212; </xsl:text>
			<xsl:copy-of select="$subpage"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="e:page-head">
		<xsl:copy-of select="h:head/*"/>
	</xsl:template>

	<xsl:template name="e:page-onload">
	</xsl:template>

	<xsl:template name="e:page-body">
		<xsl:copy-of select="h:body/*|h:body/text()"/>
	</xsl:template>

	<xsl:template name="e:page-footer">
		<tt class="rcsid">
			<xsl:choose>
				<xsl:when test="/h:html/h:head/h:meta[@name = 'rcsid']">
					<xsl:value-of select="/h:html/h:head/h:meta[@name = 'rcsid']/@content"/>
				</xsl:when>

				<xsl:otherwise>
					<xsl:text>$Id: elide.xsl 549 2010-10-24 20:33:47Z kate $</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</tt>
	</xsl:template>

	<xsl:template name="e:page" match="/h:html">

		<!--
			This is an entry point for various sources (e.g. blog XML) to produce
			a page that looks like it belongs on elide.org. There should be nothing
			in here specific to transforming an XHTML source; those things are in
			e:-named templates which can be overridden.
		-->

		<html>
			<head>
				<title>
					<xsl:call-template name="e:title-head"/>
				</title>

				<link rel="stylesheet" href="{$www-css}/elide.css"/>
				<link rel="stylesheet" href="{$www-css}/listing.css"/>

				<xsl:call-template name="e:page-head"/>
			</head>

<!-- XXX: no h:body/@onload here; provide a template and use xsl:attribute -->
			<body>
				<xsl:attribute name="onload">
					<xsl:text>Linenumbers.init(document.documentElement);</xsl:text>
					<xsl:call-template name="e:page-onload"/>
				</xsl:attribute>

				<h1 id="title">
					<xsl:call-template name="e:title-header"/>
				</h1>

				<xsl:call-template name="e:contents"/>

				<xsl:call-template name="e:page-body"/>

				<hr class="footer"/>

				<p>
					<xsl:call-template name="e:page-footer"/>
				</p>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>

