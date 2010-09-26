<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	exclude-result-prefixes="h">

	<xsl:output indent="yes" method="xml" encoding="utf-8"
		cdata-section-elements="script"
		media-type="application/xhtml+xml"

		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>

	<xsl:template name="contents">
		<ul id="contents">
			<li><a href="/snippets"><xsl:text>Snippets</xsl:text></a></li>
			<li><a href="/small"><xsl:text>Small Programs</xsl:text></a></li>
			<li><a href="/projects"><xsl:text>Projects</xsl:text></a></li>
<!--
			<li><a href="/journal"><xsl:text>Journal</xsl:text></a></li>
			<li><a href="/dreams"><xsl:text>Dreams</xsl:text></a></li>
-->
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
						<xsl:text>$Id$</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</tt>
		</p>
	</xsl:template>

	<xsl:template name="head-common">
		<link rel="stylesheet" href="/elide.css"/>

		<script src="/widgets/linenumbers/linenumbers.js" type="text/javascript"/>

		<!-- TODO: have xslt light this up instead, by kxslt:getenv() -->
		<!-- TODO: assume trac is /projects -->
		<script><![CDATA[
			function contents() {
				li = document.getElementById('contents').getElementsByTagName('li');
				for (var i = 0; i < li.length; i++) {
					a = li[i].getElementsByTagName('a')[0];
					if (document.location.href.indexOf(a.href) == 0) {
						li[i].setAttribute('class', 'current');
					}
				}
			}
		]]></script>
	</xsl:template>

	<xsl:template match="/h:html">
		<html>
			<xsl:choose>
				<xsl:when test="//h:a[@id = 'tracpowered']">
					<head>
						<title>
							<xsl:text>Kate&#x2019;s Projects: </xsl:text>
							<xsl:apply-templates select="h:head/h:title"/>
						</title>

						<xsl:call-template name="head-common"/>

						<link rel="stylesheet" href="/trac/trac.css"/>

						<xsl:copy-of select="h:head/h:link[not(contains(@href, '/chrome/common/css/trac.css'))]"/>
						<xsl:copy-of select="h:head/h:style"/>
					</head>

					<body onload="contents();
						Linenumbers.init(document.documentElement);
						{h:body/@onload}">

						<h1 id="title">
							<xsl:text>Kate&#x2019;s Projects: </xsl:text>
							<xsl:apply-templates select="h:head/h:title"/>
						</h1>

						<xsl:call-template name="contents"/>

						<xsl:copy-of select="h:body/h:div[@id = 'mainnav']"/>
						<xsl:copy-of select="h:body/h:div[@id = 'main']"/>

						<xsl:call-template name="rcsid"/>
					</body>
				</xsl:when>

				<xsl:otherwise>
					<head>
						<title>
							<xsl:apply-templates select="h:head/h:title"/>
						</title>

						<xsl:call-template name="head-common"/>
						<link rel="stylesheet" href="/listing.css"/>

						<xsl:copy-of select="h:head/*"/>
					</head>

					<body onload="contents(); Linenumbers.init(document.documentElement)">
						<h1 id="title">
							<xsl:apply-templates select="h:head/h:title"/>
						</h1>

						<xsl:call-template name="contents"/>

						<xsl:copy-of select="h:body/*|text()"/>

						<xsl:call-template name="rcsid"/>
					</body>
				</xsl:otherwise>
			</xsl:choose>
		</html>
	</xsl:template>

</xsl:stylesheet>

