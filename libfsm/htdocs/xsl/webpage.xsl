<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:apr="http://xml.elide.org/apr"
	xmlns:kxslt="http://xml.elide.org/mod_kxslt"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:svg="http://www.w3.org/2000/svg"

	exclude-result-prefixes="h apr kxslt">

	<xsl:import href="base.xsl"/>
	<xsl:import href="output.xsl"/>
	<xsl:import href="menu.xsl"/>

	<!-- TODO: i really dislike using xsl:output here.
		i want mod_kxslt to provide some way i can use common:document instead,
		and then keep outputting centralised for both standalone user documentation and the website -->
	<!-- TODO: have kxslt:header() output the appropriate content-type for html5 (text/html),
		which lets the source stay as .xhtml -->
	<!-- TODO: centralise output.xsl along with all my other web stuff... keep it generic -->
	<!-- TODO: kxslt:getheader() to do content negotiation and degrade to text/html with no SVG,
		if the browser doesn't accept application/xml+html -->
	<!-- XXX:
		doctype-public="HTML"
		doctype-system="TODO"
	-->
	<xsl:output
		method="xml"
		encoding="utf-8"
		indent="yes"
		omit-xml-declaration="yes"
		cdata-section-elements="script"
		media-type="application/xhtml+xml"
		standalone="yes"/>

	<xsl:template name="rcsid">
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
	</xsl:template>

	<xsl:template match="processing-instruction()">
		<xsl:message terminate="yes">
			<xsl:text>Unhandled PI: </xsl:text>
			<xsl:value-of select="name()"/>
		</xsl:message>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()|processing-instruction()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="body">
		<div class="grid-span-6">
			<xsl:apply-templates select="h:body/node()|h:body/processing-instruction()"/>
		</div>

		<!-- TODO: call this 'sidebar' instead -->
		<nav class="grid-span-2 grid-last">
			<!-- TODO: maybe i *do* want a @layout thingy instead... i dunno -->

			<xsl:if test="h:nav[@id = 'sidebar']">
				<xsl:apply-templates select="h:nav[@id = 'sidebar']/node()|h:nav[@id = 'sidebar']/processing-instruction()"/>
			</xsl:if>
		</nav>
	</xsl:template>

	<xsl:template name="static-head">
		<!-- TODO: perhaps leave these mmaps to mod_pagespeed to inline small css/js files -->

		<xsl:for-each select="h:head/h:link[@rel = 'stylesheet']">
			<xsl:choose>
				<xsl:when test="starts-with(@href, 'http://')">
					<xsl:copy-of select="."/>
				</xsl:when>

				<xsl:otherwise>
					<style>
						<xsl:copy-of select="attribute::*[not(name() = 'href') and not(name() = 'rel')]"/>

						<xsl:value-of select="apr:mmap(string(@href))"/>
					</style>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>

		<xsl:for-each select="h:head/h:script">
			<script>
				<xsl:copy-of select="attribute::*[not(name() = 'src')]"/>

				<xsl:choose>
					<xsl:when test="not(@src)">
						<xsl:copy-of select="node()|text()|processing-instruction()"/>
					</xsl:when>

					<xsl:when test="starts-with(@src, 'http://')">
						<xsl:copy-of select="@src"/>
					</xsl:when>

					<xsl:otherwise>
						<xsl:value-of select="apr:mmap(string(@src))"/>
					</xsl:otherwise>
				</xsl:choose>
			</script>
		</xsl:for-each>
	</xsl:template>

	<!-- TODO: use nav, footer etc for html5 -->
	<!-- TODO: centralise all this, for both static and non-static website pages. call it layout.xsl.
		we should only have one .xsl file which knows about blueprint layout (i.e. layout.xsl) -->
	<!-- TODO: breadcrums navigation; is it neccessary? -->
	<xsl:template name="static-content">
		<header class="page-section inverted">
			<h1 class="title">Kate&#x2019;s&#xa0;Lexer&#xa0;Generator

			<span class="tagline">(<span class="amp">&amp;</span>&#xa0;friends)</span></h1>
		</header>

		<nav class="menu grid-container">
			<!-- TODO: or: degrade inside the <svg> element?
			<xsl:choose>
				<xsl:when test="contains(kxslt:getheader('Accept'), 'application/xhtml+xml')">
					<xsl:call-template name="menu"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>TODO: non-SVG menu</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			-->

			<xsl:call-template name="menu"/>

			<menu class="grid-span-2 grid-last">
				<li>
					<a id="menu-fsm" href="{$libfsm.url.www}/libfsm">
						<span class="title">libfsm</span>
						<span class="desc">Static analysis of Finite Automata</span>
					</a>
				</li>

				<li>
					<a id="menu-re" href="{$libfsm.url.www}/libre">
						<span class="title">libre</span>
						<span class="desc">Compiling Regular Expressions to DFA</span>
					</a>
				</li>

				<li>
					<a id="menu-lx" href="{$libfsm.url.www}/lx">
						<span class="title">lx</span>
						<span class="desc">Lexer generator</span>
					</a>
				</li>
			</menu>
		</nav>

		<article class="page-section normal grid-container">
			<xsl:call-template name="body"/>
		</article>

		<footer class="page-section inverted">
			<xsl:call-template name="rcsid"/>
		</footer>
	</xsl:template>

	<!-- TODO: make sure xml:output stuff matches that for output.xsl -->
	<xsl:template match="/h:html">
		<!-- XXX: hack until libxslt supports html 5 -->
		<xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;&#xA;</xsl:text>

		<xsl:call-template name="output-content">
			<xsl:with-param name="method" select="'xhtml5'"/>

			<xsl:with-param name="css" select="concat(
				' ', $libfsm.url.www, '/css/menu.css',
				' ', $libfsm.url.www, '/css/style.css')"/>

<!-- TODO: obsoleted
			<xsl:with-param name="css" select="concat(
					' ', $libfsm.url.www, '/css/webpage.css',
					' ', $libfsm.url.www, '/css/menu.css')"/>
-->

			<xsl:with-param name="title">
				<xsl:apply-templates select="h:head/h:title"/>
			</xsl:with-param>

			<xsl:with-param name="content.head">
				<xsl:call-template name="static-head"/>
			</xsl:with-param>

			<xsl:with-param name="content.body">
				<xsl:call-template name="static-content"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>

