<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:c="http://xml.elide.org/elide_contents"

	exclude-result-prefixes="h c">

	<xsl:param name="www-base"/>
	<xsl:param name="www-css"/>
	<xsl:param name="www-js"/>
	<xsl:param name="uri"/>

	<xsl:output indent="yes" method="xml" encoding="utf-8"
		media-type="application/xhtml+xml"

		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>

	<c:contents>
		<c:category href="snippets" name="Snippets"/>
		<c:category href="small"    name="Small Programs"/>
		<c:category href="projects" name="Projects"/>
<!--
		<c:category href="journal"  name="Journal"/>
		<c:category href="dreams"   name="Dreams"/>
-->
	</c:contents>

	<!-- TODO: also normalise all <a/> hrefs -->
<!--
	<xsl:variable name="prefix">
		<xsl:variable name="server" select="$server_name"/>
		<xsl:if test="$server != 'elide.org'">
			<xsl:text>http://elide.org</xsl:text>
		</xsl:if>
	</xsl:variable>
-->

	<xsl:template name="contents">
		<ul id="contents">
			<xsl:for-each select="document('')//c:contents/c:category">
				<li>
					<xsl:if test="starts-with($uri, concat('/', @href, '/'))">
						<xsl:attribute name="class">
							<xsl:text>current</xsl:text>
						</xsl:attribute>
					</xsl:if>

					<a href="{$www-base}/{@href}">
						<xsl:value-of select="@name"/>
					</a>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>

	<xsl:template name="rcsid">
		<hr class="footer"/>

		<p>
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
		</p>
	</xsl:template>

	<xsl:template match="/h:html">
		<html>
			<head>
				<title>
					<xsl:apply-templates select="h:head/h:title"/>
				</title>

				<link rel="stylesheet" href="{$www-css}/elide.css"/>
				<link rel="stylesheet" href="{$www-css}/listing.css"/>

				<xsl:copy-of select="h:head/*"/>

				<script src="{$www-js}/widgets/linenumbers/linenumbers.js" type="text/javascript"/>
			</head>

			<body onload="contents();
				Linenumbers.init(document.documentElement);
				{h:body/@onload}">

				<h1 id="title">
					<xsl:apply-templates select="h:head/h:title"/>
				</h1>

				<xsl:call-template name="contents"/>

				<xsl:copy-of select="h:body/*|h:body/text()"/>

				<xsl:call-template name="rcsid"/>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>

