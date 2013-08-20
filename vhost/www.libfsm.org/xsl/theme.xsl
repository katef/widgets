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

	<xsl:template name="theme-menu">
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
	</xsl:template>

	<xsl:template match="/h:html/h:head/h:title" mode="body">
		<xsl:apply-templates select="node()|text()|processing-instruction()"/>
	</xsl:template>

	<xsl:template match="/h:html">
		<xsl:call-template name="theme-output">
			<xsl:with-param name="css"   select="'style.css debug.css'"/>

			<xsl:with-param name="js">
				<xsl:value-of select="'col.js fixup.js hyphenator-min.js table.js overlay.js debug.js'"/>

				<!-- TODO: only where relevant -->
				<xsl:value-of select="' ajax.js valid.js comment.js template.js'"/>
			</xsl:with-param>

			<xsl:with-param name="onload">
				<xsl:text>Colalign.init(r);</xsl:text>
				<xsl:text>Fixup.init(r);</xsl:text>
				<xsl:text>Table.init(r);</xsl:text>
				<xsl:text>Overlay.init(r, 'cols',  8);</xsl:text>
				<xsl:text>Overlay.init(r, 'rows', 66);</xsl:text>
			</xsl:with-param>

			<xsl:with-param name="site" select="'libfsm'"/>
			<xsl:with-param name="page">
				<xsl:apply-templates select="h:head/h:title" mode="body"/>
			</xsl:with-param>


			<xsl:with-param name="body">
				<header>
					<h1>
						<xsl:text>Kate&#x2019;s Lexer&#xa0;Generator</xsl:text>

						<xsl:if test="h:head/h:title">
							<xsl:text> &#8211;&#xa0;</xsl:text>
							<xsl:apply-templates select="h:head/h:title" mode="body"/>
						</xsl:if>
					</h1>
				</header>

				<section class="page hyphenate">
					<xsl:call-template name="theme-menu"/>

					<xsl:apply-templates select="h:body/node()|h:body/text()|h:body/processing-instruction()"/>
				</section>

				<nav class="sidebar hyphenate">
					<xsl:apply-templates select="h:nav/node()|h:nav/text()|h:nav/processing-instruction()"/>
				</nav>

				<footer>
					<xsl:call-template name="rcsid"/>
				</footer>
			</xsl:with-param>

		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>

