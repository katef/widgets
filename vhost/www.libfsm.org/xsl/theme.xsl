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

	<xsl:template name="theme-menu">
		<nav class="menu">
			<!-- TODO: or: degrade to non-SVG menu inside the <svg> element? -->
			<!-- TODO: consider looking at the Accept: header to decide to degrade to non-SVG here -->
<!-- XXX:
			<xsl:call-template name="menu"/>
-->
			<span>menu stuff here</span>

			<ul>
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
			</ul>
		</nav>
	</xsl:template>

	<xsl:template match="/h:html/h:head/h:title" mode="body">
		<xsl:apply-templates select="node()" mode="copy"/>
	</xsl:template>

	<xsl:template name="libfsm-output">
		<xsl:param name="category"/>
		<xsl:param name="class"/>
		<xsl:param name="page"/>

		<xsl:param name="head"    select="/.."/>
		<xsl:param name="main"    select="/.."/>
		<xsl:param name="sidebar" select="/.."/>

		<xsl:call-template name="theme-output">
			<xsl:with-param name="category" select="$category"/>
			<xsl:with-param name="class"    select="$category"/>

			<xsl:with-param name="css" select="'style.css'"/>

			<xsl:with-param name="js">
				<xsl:value-of select="'col.js fixup.js hyphenator-min.js table.js overlay.js debug.js'"/>

				<!-- TODO: only where relevant -->
				<xsl:value-of select="' ajax.js valid.js comment.js template.js'"/>
			</xsl:with-param>

			<xsl:with-param name="onload">
				<xsl:text>Colalign.init(r);</xsl:text>
				<xsl:text>Fixup.init(r);</xsl:text>
				<xsl:text>Table.init(r);</xsl:text>
			</xsl:with-param>

			<xsl:with-param name="page">
				<xsl:copy-of select="$page"/>
			</xsl:with-param>

			<xsl:with-param name="site">
				<xsl:text>libfsm</xsl:text>
			</xsl:with-param>

			<xsl:with-param name="head">
				<xsl:copy-of select="$head"/>
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

				<main role="main" class="hyphenate">
					<xsl:copy-of select="$main"/>
				</main>

				<xsl:if test="$sidebar">
					<nav class="sidebar hyphenate">
						<xsl:copy-of select="$sidebar"/>
					</nav>
				</xsl:if>

				<footer>
					<xsl:comment> nothing to see here </xsl:comment>
				</footer>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

