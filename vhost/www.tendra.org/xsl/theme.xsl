<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:t="http://xml.tendra.org/www"

	exclude-result-prefixes="h t">

	<xsl:import href="../../../xsl/theme.xsl"/>

	<xsl:import href="contents.xsl"/>

	<xsl:param name="www-css"/>
	<xsl:param name="www-js"/>
	<xsl:param name="uri"/>

	<xsl:template match="h:article[@class = 'entry']/h:h1/h:a">
		<xsl:copy-of select="*|text()"/>
	</xsl:template>

	<xsl:template match="h:article/h:a[@name]"/>

	<xsl:template match="h:article/h:time[@pubdate]">
		<a href="{$blog-base}/{.}">
			<xsl:copy-of select="../h:a[@name]/@*"/>
<!--
			<xsl:copy-of select="../h:h1/h:a/@href, '/'"/>
-->
			<xsl:copy-of select="."/>
		</a>
	</xsl:template>

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

	<xsl:template match="/h:html/h:head/h:title" mode="body">
		<xsl:apply-templates select="node()|text()|processing-instruction()"/>
	</xsl:template>

	<xsl:template match="/h:html">
		<xsl:call-template name="theme-output">
			<xsl:with-param name="class" select="concat(@class, ' hyphenate')"/>

			<xsl:with-param name="css"   select="'style.css debug.css'"/>

			<xsl:with-param name="js">
				<xsl:value-of select="'col.js fixup.js hyphenator-min.js expander.js table.js overlay.js debug.js'"/>

				<xsl:value-of select="' fittext.js'"/>

				<!-- TODO: only where relevant -->
				<xsl:value-of select="' ajax.js valid.js comment.js template.js'"/>
				<xsl:value-of select="' tablerowlinks.js'"/>
			</xsl:with-param>

			<xsl:with-param name="onload">
				<xsl:text>Expander.init(r, "menu", "li", false, true);</xsl:text>
				<xsl:text>Colalign.init(r);</xsl:text>
				<xsl:text>Fixup.init(r);</xsl:text>
				<xsl:text>Table.init(r);</xsl:text>
				<xsl:text>Overlay.init(r, 'cols', 12);</xsl:text>
				<xsl:text>Overlay.init(r, 'rows', 26);</xsl:text>

				<!-- TODO: consider vw css units instead -->
				<xsl:text>window.fitText(document.getElementById("banner"), 1.2);</xsl:text>

				<!-- TODO: only where relevant -->
<!-- XXX:
				<xsl:text>ConvertRowsToLinks('download');</xsl:text>
-->
			</xsl:with-param>

			<xsl:with-param name="page">
				<xsl:apply-templates select="h:head/h:title" mode="body"/>
			</xsl:with-param>

			<xsl:with-param name="site">
				<xsl:text>TenDRA</xsl:text>
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
					<h1>
						<xsl:apply-templates select="h:head/h:title" mode="body"/>
					</h1>

					<xsl:apply-templates select="h:body/node()|h:body/text()|h:body/processing-instruction()"/>
				</main>

				<nav id="sidebar" class="hyphenate">
					<xsl:apply-templates select="h:nav/node()|h:nav/text()|h:nav/processing-instruction()"/>
				</nav>

				<footer>
					<xsl:call-template name="t:page-footer"/>
				</footer>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

