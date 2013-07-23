<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:common="http://exslt.org/common"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:c="http://xml.elide.org/elide_contents"
	xmlns:e="http://xml.elide.org/elide_website"

	exclude-result-prefixes="h c e">

	<xsl:import href="../../../xsl/theme.xsl"/>

	<xsl:param name="www-css"/>
	<xsl:param name="www-js"/>
	<xsl:param name="uri"/>

	<!-- TODO: rename contents to toc -->
	<c:contents>
		<c:category href="http://diary.elide.org/"        name="Diary"/>
		<c:category href="http://www.elide.org/snippets/" name="Snippets"/>
		<c:category href="http://www.elide.org/small/"    name="Small"/>
		<c:category href="http://www.elide.org/projects/" name="Projects"/>
		<c:category href="http://www.elide.org/contact/"  name="Contact"/>
	</c:contents>

	<xsl:template name="e:contents">
		<ul id="contents">
			<xsl:for-each select="document('')//c:contents/c:category">
				<li>
					<xsl:if test="starts-with(concat($scheme, '://', $host, $uri), @href)">
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

	<xsl:template name="e:category-title">
		<xsl:text>Website</xsl:text>
	</xsl:template>

	<xsl:template name="e:subpage-title">
		<xsl:apply-templates select="h:head/h:title"/>
	</xsl:template>

	<xsl:template name="e:page-head">
		<xsl:copy-of select="h:head/*"/>
	</xsl:template>

	<xsl:template name="e:page-onload">
	</xsl:template>

	<xsl:template name="e:page-body">
		<xsl:apply-templates select="h:body/node()|h:body/text()|h:body/processing-instruction()"/>
	</xsl:template>

	<xsl:template name="e:page-sidebar">
		<xsl:apply-templates select="h:nav/node()|h:nav/text()|h:nav/processing-instruction()"/>
	</xsl:template>

	<xsl:template name="e:page-footer">
		<tt class="rcsid">
			<xsl:choose>
				<xsl:when test="/h:html/h:head/h:meta[@name = 'rcsid']">
					<xsl:value-of select="/h:html/h:head/h:meta[@name = 'rcsid']/@content"/>
				</xsl:when>

				<xsl:otherwise>
					<xsl:text>$Id: elide.xsl 549 2010-10-24 20:33:47Z kate $</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</tt>
	</xsl:template>

	<xsl:template name="theme-title">
		<xsl:text>Kate&#8217;s&#160;Amazing </xsl:text>
		<xsl:call-template name="e:category-title"/>

		<xsl:variable name="subpage">
			<xsl:call-template name="e:subpage-title"/>
		</xsl:variable>

		<xsl:if test="$subpage">
			<xsl:text> &#8212; </xsl:text>
			<xsl:copy-of select="$subpage"/>
		</xsl:if>
	</xsl:template>

	<xsl:variable name="theme-css" select="concat(
		'style.css ',
		'debug.css ')"/>

	<xsl:variable name="theme-fonts" select="concat(
		'Maven+Pro:400,700 ',
		'Ubuntu+Mono')"/>

	<xsl:variable name="theme-js">
		<xsl:value-of select="concat(
			'debug.js ',
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

	<xsl:template name="theme-content">

		<!--
			This is an entry point for various sources (e.g. blog XML) to produce
			a page that looks like it belongs on elide.org. There should be nothing
			in here specific to transforming an XHTML source; those things are in
			e:-named templates which can be overridden.
		-->

<!-- XXX: no h:body/@onload here; provide a template and use xsl:attribute -->

		<header>
			<h1>
				<xsl:call-template name="theme-title"/>
			</h1>

			<xsl:call-template name="e:contents"/>
		</header>

		<section class="page">
			<xsl:call-template name="e:page-body"/>
		</section>

		<nav id="sidebar">
			<xsl:call-template name="e:page-sidebar"/>
		</nav>

		<footer>
			<xsl:call-template name="e:page-footer"/>
		</footer>

<!-- XXX: hack until @onload is done properly -->
<script><xsl:text>
Overlay.init(document.documentElement, 'cols',  6);
Overlay.init(document.documentElement, 'rows', 26);
</xsl:text></script>

	</xsl:template>

</xsl:stylesheet>

