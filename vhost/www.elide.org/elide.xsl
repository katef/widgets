<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:kxslt="http://xml.elide.org/mod_kxslt"
	xmlns:c="http://xml.elide.org/elide_contents"

	exclude-result-prefixes="h kxslt c">

	<xsl:output indent="yes" method="xml" encoding="utf-8"
		media-type="application/xhtml+xml"

		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>

	<c:contents>
		<c:category href="/snippets" name="Snippets"/>
		<c:category href="/small"    name="Small Programs"/>
		<c:category href="/projects" name="Projects"/>
<!--
		<c:category href="/journal"  name="Journal"/>
		<c:category href="/drams"    name="Dreams"/>
-->
	</c:contents>

	<xsl:variable name="istracpage" select="boolean(//h:a[@id = 'tracpowered'])"/>

	<xsl:template name="contents">
		<ul id="contents">
			<xsl:for-each select="document('')//c:contents/c:category">
				<li>
					<xsl:if test="starts-with(kxslt:getenv('REQUEST_URI'), @href)
						or (@href = '/projects' and $istracpage)">
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
	</xsl:template>

	<xsl:template match="/h:html">
		<html>
			<xsl:choose>
				<xsl:when test="$istracpage">
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
				</xsl:otherwise>
			</xsl:choose>
		</html>
	</xsl:template>

</xsl:stylesheet>

