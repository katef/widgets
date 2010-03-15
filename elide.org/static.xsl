<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	exclude-result-prefixes="h">

	<xsl:output indent="yes" method="xml" encoding="utf-8"
		cdata-section-elements="script"
		media-type="application/xhtml+xml"/>

	<xsl:template match="/">
		<xsl:apply-templates select="h:html"/>
	</xsl:template>

	<xsl:template match="h:html">
		<html>
			<head>
				<link rel="stylesheet" href="/kate.css"/>
				<link rel="stylesheet" href="/listing.css"/>

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

				<xsl:copy-of select="h:head/*"/>
			</head>

			<body onload="contents()">
				<h1 id="title">
					<xsl:apply-templates select="h:head/h:title"/>
				</h1>

				<ul id="contents">
					<li><a href="/snippets"><xsl:text>Snippets</xsl:text></a></li>
					<li><a href="/small"><xsl:text>Small Programs</xsl:text></a></li>
					<li><a href="/projects"><xsl:text>Projects</xsl:text></a></li>
					<li><a href="/journal"><xsl:text>Journal</xsl:text></a></li>
					<li><a href="/dreams"><xsl:text>Dreams</xsl:text></a></li>
				</ul>

				<xsl:copy-of select="h:body/*|text()"/>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>

