<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:tl="http://xml.elide.org/timeline"
	xmlns:date="http://exslt.org/dates-and-times"

	extension-element-prefixes="date"

	exclude-result-prefixes="h tl date">

	<xsl:import href="base.xsl"/>
	<xsl:import href="../../../xsl/theme.xsl"/>
	<xsl:import href="../../../xsl/ordinal.xsl"/>
<!--
	<xsl:import href="menu.xsl"/>
-->

	<xsl:template match="h:article[@class = 'entry']/h:h1">
		<xsl:variable name="date" select="../h:time[@pubdate]"/>

		<h1>
			<xsl:copy-of select="text()|*"/>

			<time datetime="{$date}" pubdate="pubdate">
				<xsl:value-of select="date:day-in-month($date)"/>
				<span class="ordinal">
					<xsl:call-template name="ordinal">
						<xsl:with-param name="n" select="date:day-in-month($date)"/>
					</xsl:call-template>
				</span>

				<xsl:text>&#xA0;</xsl:text>

				<xsl:variable name="mon" select="date:month-abbreviation($date)"/>
				<xsl:choose>
					<xsl:when test="$mon = 'Sep'">
						<xsl:text>Sept</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$mon"/>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:text>&#xA0;&#8217;</xsl:text>
				<xsl:value-of select="substring(date:year($date), 3, 2)"/>
			</time>
		</h1>
	</xsl:template>

	<xsl:template match="h:article[@class = 'entry']/h:time"/>

	<!-- TMI? -->
<!--
	<xsl:template match="h:table[@class = 'calendar']/h:tr[@class = 'day-heading']"/>
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
		<xsl:apply-templates select="h:body/node()|h:body/text()|h:body/processing-instruction()"/>

		<nav class="sidebar">
			<!-- TODO: maybe i *do* want a @layout thingy instead... i dunno -->

			<xsl:if test="h:nav[@id = 'sidebar']">
				<xsl:apply-templates select="h:nav[@id = 'sidebar']/node()|h:nav[@id = 'sidebar']/processing-instruction()"/>
			</xsl:if>
		</nav>
	</xsl:template>

	<xsl:variable name="theme-css" select="concat(
		'style.css ',
		'debug.css')"/>

	<xsl:variable name="theme-fonts" select="concat(
		'Quattrocento')"/>

	<xsl:variable name="theme-js">
		<xsl:value-of select="concat(
			'style.js ',
			'overlay.js ')"/>

		<!-- TODO: only where relevant -->
		<xsl:value-of select="concat(
			'ajax.js ',
			'valid.js ',
			'comment.js ',
			'template.js')"/>
	</xsl:variable>

	<xsl:template name="theme-head">
	</xsl:template>

	<!-- TODO: use nav, footer etc for html5 -->
	<!-- TODO: centralise all this, for both static and non-static website pages. call it layout.xsl.
		we should only have one .xsl file which knows about blueprint layout (i.e. layout.xsl) -->
	<!-- TODO: breadcrums navigation; is it neccessary? -->
	<xsl:template name="theme-content">
		<header>
			<h1>Kate&#x2019;s&#xa0;Lexer&#xa0;Generator</h1>
		</header>

		<section class="page">
			<nav class="menu">
				<!-- TODO: or: degrade to non-SVG menu inside the <svg> element? -->
				<!-- TODO: consider looking at the Accept: header to decide to degrade to non-SVG here -->
<!-- XXX:
				<xsl:call-template name="menu"/>
-->
				<span>menu stuff here</span>

				<menu>
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

			<xsl:call-template name="body"/>
		</section>

		<footer>
			<xsl:call-template name="rcsid"/>
		</footer>

<!-- XXX: hack until @onload is done properly -->
<script><xsl:text>
Overlay.init(document.documentElement, 'cols',  8);
Overlay.init(document.documentElement, 'rows', 66);
</xsl:text></script>

	</xsl:template>

</xsl:stylesheet>

