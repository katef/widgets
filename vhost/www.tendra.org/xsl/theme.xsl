<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:t="http://xml.tendra.org/www"

	exclude-result-prefixes="h t">

	<xsl:import href="../../../xsl/theme.xsl"/>

	<xsl:import href="contents.xsl"/>

	<xsl:template name="t:page-footer">
<!-- TODO -->
		<ul class="otherformats pipelist">
			<li>
				<a rel="nofollow" href="/wiki/Glossary?format=txt">Plain Text</a>
			</li>
			<li>
				<a rel="nofollow" href="?format=csv&amp;USER=kate">CSV</a>
			</li>
			<li>
				<a rel="nofollow" href="/wiki/Glossary?format=rss xyz.rss">RSS</a>
			</li>
		</ul>
	</xsl:template>

	<xsl:template name="tendra-output">
		<xsl:param name="class"/>
		<xsl:param name="page"/>

		<xsl:param name="head"    select="/.."/>
		<xsl:param name="main"    select="/.."/>
		<xsl:param name="sidebar" select="/.."/>

		<xsl:call-template name="theme-output">
			<xsl:with-param name="class"   select="$class"/>
			<xsl:with-param name="css"     select="'style.css'"/>
			<xsl:with-param name="favicon" select="'/favicon.ico'"/>

			<xsl:with-param name="js">
				<xsl:value-of select="'col.js fixup.js hyphenator-min.js expander.js table.js overlay.js debug.js'"/>
				<xsl:value-of select="' fittext.js'"/>

				<!-- TODO: only where relevant -->
				<xsl:value-of select="' ajax.js valid.js comment.js template.js'"/>
				<xsl:value-of select="' tablerowlinks.js'"/>
			</xsl:with-param>

			<xsl:with-param name="onload">
				<xsl:text>Expander.init(r, "nav", "li", false, true);</xsl:text>
				<xsl:text>Colalign.init(r);</xsl:text>
				<xsl:text>Fixup.init(r);</xsl:text>
				<xsl:text>Table.init(r);</xsl:text>

				<!-- TODO: consider vw css units instead -->
				<xsl:text>window.fitText(document.getElementById("banner"), 1.3);</xsl:text>

				<!-- TODO: only where relevant -->
<!-- XXX:
				<xsl:text>ConvertRowsToLinks('download');</xsl:text>
-->
			</xsl:with-param>

			<xsl:with-param name="page">
				<xsl:copy-of select="$page"/>
			</xsl:with-param>

			<xsl:with-param name="site">
				<xsl:text>TenDRA</xsl:text>
			</xsl:with-param>

			<xsl:with-param name="head">
				<xsl:copy-of select="$head"/>
			</xsl:with-param>

			<xsl:with-param name="body">
				<header class="donthyphenate">
					<xsl:call-template name="t:banner"/>

<!-- search is overkill for now
					<form class="search">
						<input type="text"/>
						<input type="submit" value="Search"/>
					</form>
-->

					<xsl:call-template name="t:sections-menu"/>
				</header>

				<main role="main" class="hyphenate">
					<xsl:copy-of select="$main"/>
				</main>

				<xsl:if test="$sidebar">
					<nav id="sidebar" class="hyphenate">
						<xsl:copy-of select="$sidebar"/>
					</nav>
				</xsl:if>

				<footer>
					<xsl:call-template name="t:page-footer"/>
				</footer>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

