<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:t="http://xml.tendra.org/www"
	xmlns:apr="http://xml.elide.org/apr"
	xmlns:kxslt="http://xml.elide.org/mod_kxslt"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	exclude-result-prefixes="h t apr kxslt">

	<xsl:import href="base.xsl"/>
	<xsl:import href="contents.xsl"/>
	<xsl:import href="output.xsl"/>

	<xsl:template match="h:head/h:title" mode="unabbr">
		<xsl:choose>
			<xsl:when test="h:abbr">
				<xsl:value-of select="h:abbr/@title"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="rcsid">
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

	<xsl:template name="search">
		<form class="search" style="display: block;">
			<div class="grid-span-2 search-input">
				<input type="text" />
			</div>
			<div class="grid-span-1 grid-last search-submit">
				<input type="submit" value="Search"/>
			</div>
		</form>
	</xsl:template>

	<xsl:template name="otherformats">
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

	<xsl:template name="login">
		<ul class="pipelist">
			<li>
				<!-- TODO -->
				<a href="/login">Login</a>
			</li>
		</ul>
	</xsl:template>

	<xsl:template name="body-contents">
		<!-- TODO: apply recursively -->
		<xsl:copy-of select="h:body/*|h:body/text()"/>
	</xsl:template>

	<xsl:template name="body">
<!-- TODO: to decide things like the RHS menu (e.g. related documents), categorise pages:
1. handcrafted pages, which have their own blueprint grid stuff
2. documentation
3. XXX...
and pick up which category it is from a meta thingy in the input xhtml

or: maybe this could be done with an xslt wrapper per directory, which overrides things (like the docbook xslt layers for overriding)
-->

		<xsl:choose>
			<xsl:when test="h:head/h:meta[@name = 'layout']/@content = 'docs'">
				<div class="grid-span-9 grid-border">
					<h1>
						<xsl:apply-templates select="h:head/h:title" mode="unabbr"/>
					</h1>

					<xsl:call-template name="body-contents"/>
				</div>
				<div class="grid-span-3 grid-last">
					<!-- TODO: best done with an xslt wrapper in the faq/ directory, instead? -->
					<xsl:if test="h:head/h:title = 'FAQ'">
						<!-- TODO: eg. faq-specific sidebar stuff here -->
					</xsl:if>

					<xsl:choose>
						<xsl:when test="h:nav[@id = 'sidebar']">
							<xsl:copy-of select="h:nav[@id = 'sidebar']/*"/>
						</xsl:when>

						<xsl:otherwise>
							<!-- TODO: docs stuff; lots of things here -->
							<h2>
								<xsl:text>See also</xsl:text>
							</h2>
							<ul class="menu">
								<li><a href="#">Orientation</a></li>
								<li><a href="#">History</a></li>
								<li><a href="#">Installation guide</a></li>
								<li><a href="#">Development</a></li>
							</ul>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:when>
			<xsl:when test="h:head/h:meta[@name = 'layout']/@content = 'typography'">
				<div class="grid-span-9 grid-border">
					<h1>
						<xsl:apply-templates select="h:head/h:title" mode="unabbr"/>
					</h1>

					<xsl:call-template name="body-contents"/>
				</div>
				<div class="grid-span-3 grid-last">
					<h2>
						<xsl:text>Typogaphic elements</xsl:text>
					</h2>
					<ul class="menu">
						<li><a href="/typography/text/">Text</a></li>
						<li><a href="/typography/headings/">Headings</a></li>
						<li><a href="/typography/lists/">Lists</a></li>
						<li><a href="/typography/tables/">Tables</a></li>
					</ul>
				</div>
			</xsl:when>
			<xsl:when test="h:head/h:meta[@name = 'layout']/@content = 'source'">
				<div class="grid-span-9 grid-border">
					<h1>
						<xsl:apply-templates select="h:head/h:title" mode="unabbr"/>
					</h1>

					<xsl:call-template name="body-contents"/>
				</div>
				<div class="grid-span-3 grid-last">
					<!-- TODO: maybe simpler to have a 'seealso' layout class, and put a whitespace seprated list of stuff to see in a meta tag, for this to pick up. reconsider after a few pages are done. obviously keep page-specific knowledge out of static.xsl -->
					<!-- TODO: possibly use the keyword-intersecting idea from rf? -->
					<h2>
						<xsl:text>See also</xsl:text>
					</h2>
					<ul class="menu">
						<li><a href="#">History</a></li>
						<li><a href="#">Installation guide</a></li>
						<li><a href="#">Development</a></li>
						<li><a href="#">Browse Source</a></li>
					</ul>
				</div>
			</xsl:when>
			<xsl:when test="h:head/h:meta[@name = 'layout']/@content = 'custom'">
				<xsl:call-template name="body-contents"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">
					<xsl:text>unspecified layout</xsl:text>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="static-head">
		<xsl:for-each select="h:head/h:link[@rel = 'stylesheet']">
			<style>
				<xsl:copy-of select="attribute::*[not(name() = 'href') and not(name() = 'rel')]"/>

				<xsl:value-of select="apr:mmap(string(@href))"/>
			</style>
		</xsl:for-each>

		<xsl:for-each select="h:head/h:script">
			<script>
				<xsl:copy-of select="attribute::*[not(name() = 'src')]"/>

				<xsl:value-of select="apr:mmap(string(@src))"/>
			</script>
		</xsl:for-each>
	</xsl:template>

	<!-- TODO: use nav, footer etc for html5 -->
	<!-- TODO: centralise all this, for both static and non-static website pages. call it layout.xsl.
		we should only have one .xsl file which knows about blueprint layout (i.e. layout.xsl) -->
	<!-- TODO: breadcrums navigation; is it neccessary? -->
	<xsl:template name="static-content">
		<div class="grid-container head">
			<div class="grid-prepend-9 grid-span-3 grid-last">
				<xsl:call-template name="banner"/>
			</div>
			<div class="grid-span-9">
				<xsl:call-template name="t:sections-menu"/>
			</div>
			<div class="grid-span-3 grid-last">
				<xsl:call-template name="search"/>	<!-- TODO: rename t:search etc -->
			</div>
		</div>

		<div class="grid-container body">
			<xsl:call-template name="body"/>
		</div>

		<div class="grid-container foot">
			<div class="grid-span-9">
				<xsl:call-template name="otherformats"/>	<!-- TODO: rename t:search etc -->

				<!-- TODO: find a home for this -->
				<xsl:call-template name="rcsid"/>
			</div>
			<div class="grid-span-3 grid-last">
				<xsl:call-template name="login"/>
			</div>
		</div>
	</xsl:template>

	<!-- TODO: make sure xml:output stuff matches that for output.xsl -->
	<xsl:template match="/h:html">
		<xsl:call-template name="output-content">
			<xsl:with-param name="css" select="concat(
					' ', $tendra.url.www, '/css/webpage.css',
					' ', $tendra.url.www, '/css/widgets.css')"/>

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

