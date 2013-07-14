<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:svg="http://www.w3.org/2000/svg"

	exclude-result-prefixes="h">

	<xsl:import href="base.xsl"/>
	<xsl:import href="../../../xsl/theme.xsl"/>
<!--
	<xsl:import href="menu.xsl"/>
-->

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

	<xsl:template name="body">
		<div class="grid-span-6">
			<xsl:apply-templates select="h:body/node()|h:body/text()|h:body/processing-instruction()"/>
		</div>

		<!-- TODO: call this 'sidebar' instead -->
		<nav class="grid-span-2 grid-last">
			<!-- TODO: maybe i *do* want a @layout thingy instead... i dunno -->

			<xsl:if test="h:nav[@id = 'sidebar']">
				<xsl:apply-templates select="h:nav[@id = 'sidebar']/node()|h:nav[@id = 'sidebar']/processing-instruction()"/>
			</xsl:if>
		</nav>
	</xsl:template>

	<xsl:template name="theme-head">
		<link rel="stylesheet" href="{$www-css}/menu.css"/>
		<link rel="stylesheet" href="{$www-css}/style.css"/>
	</xsl:template>

	<!-- TODO: use nav, footer etc for html5 -->
	<!-- TODO: centralise all this, for both static and non-static website pages. call it layout.xsl.
		we should only have one .xsl file which knows about blueprint layout (i.e. layout.xsl) -->
	<!-- TODO: breadcrums navigation; is it neccessary? -->
	<xsl:template name="theme-content">
		<header class="page-section inverted">
			<h1 class="title">Kate&#x2019;s&#xa0;Lexer&#xa0;Generator

			<span class="tagline">(<span class="amp">&amp;</span>&#xa0;friends)</span></h1>
		</header>

		<nav class="menu grid-container">
			<!-- TODO: or: degrade to non-SVG menu inside the <svg> element? -->
			<!-- TODO: consider looking at the Accept: header to decide to degrade to non-SVG here -->
<!-- XXX:
			<xsl:call-template name="menu"/>
-->

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

</xsl:stylesheet>

