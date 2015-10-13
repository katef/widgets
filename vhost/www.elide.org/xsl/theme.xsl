<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:c="http://xml.elide.org/contents"
	xmlns:e="http://xml.elide.org/elide_website"

	extension-element-prefixes="date"

	exclude-result-prefixes="h c e date">

	<xsl:import href="../../../xsl/lib/date.format-date.xsl"/>

	<xsl:import href="../../../xsl/theme.xsl"/>
	<xsl:import href="../../../xsl/img.xsl"/>
	<xsl:import href="../../../xsl/contents.xsl"/>

	<xsl:param name="www-css"/>
	<xsl:param name="www-js"/>

	<xsl:variable name="category" select="//h:meta[@name = 'category']/@content"/>
	<xsl:variable name="date"     select="//h:meta[@name = 'date']    /@content"/>

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

	<xsl:template match="h:section[@class = 'archive-year']/h:a[@name]"/>

<!--
	<xsl:template match="h:section[@class = 'archive-year']/h:h1">
		<xsl:copy-of select="h:a"/>
	</xsl:template>
-->

<!--
	<xsl:template match="h:section[@class = 'archive-year']/h:ol/h:li/h:time[@pubdate]"/>
-->

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

	<xsl:template match="/h:html/h:head/h:title" mode="body">
		<xsl:apply-templates select="node()|text()|processing-instruction()"/>
	</xsl:template>

	<xsl:template match="/h:html">
		<xsl:call-template name="theme-output">
			<xsl:with-param name="css"     select="'style.css'"/>
			<xsl:with-param name="favicon" select="'/favicon.ico'"/>

			<xsl:with-param name="js">
				<xsl:value-of select="'col.js fixup.js hyphenator-min.js overlay.js debug.js'"/>
				<xsl:value-of select="' ajax.js valid.js comment.js template.js instafeed.min.js'"/>
			</xsl:with-param>

			<xsl:with-param name="onload">
				<xsl:text>Colalign.init(r);</xsl:text>
				<xsl:text>Fixup.init(r);</xsl:text>
			</xsl:with-param>

			<xsl:with-param name="page">
				<xsl:apply-templates select="h:head/h:title" mode="body"/>
			</xsl:with-param>

			<xsl:with-param name="site">
				<xsl:text>Kate&#8217;s </xsl:text>
				<xsl:apply-templates select="h:head/h:title" mode="body"/>
			</xsl:with-param>

			<xsl:with-param name="head">
				<xsl:copy-of select="h:head/h:meta[@name = 'description']"/>
				<xsl:copy-of select="h:head/h:meta[@name = 'keywords']"/>

				<!-- here to cut loading time -->
				<style><![CDATA[
					header,
					footer:before {
						background-color: #0c3e86; /* 0b367a */
						background-image: url('/img/shelves.jpeg');
					}
				]]></style>
			</xsl:with-param>

			<xsl:with-param name="body">
				<xsl:variable name="article" select="$category = 'articles'
					and string(h:head/h:title) != 'Articles'"/>

				<header>
					<h1>
						<xsl:text>Kate&#8217;s Amazing </xsl:text>
						<xsl:choose>
							<xsl:when test="$article">
								<xsl:text>Articles</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="h:head/h:title" mode="body"/>
							</xsl:otherwise>
						</xsl:choose>
					</h1>

					<nav role="navigation">
						<xsl:call-template name="c:contents">
							<xsl:with-param name="doc"      select="document('contents.xml')"/>
							<xsl:with-param name="category" select="$category"/>
						</xsl:call-template>
					</nav>
				</header>

				<main role="main" class="hyphenate">
					<xsl:if test="$article">
						<h1>
							<xsl:apply-templates select="h:head/h:title" mode="body"/>
						</h1>
					</xsl:if>

					<xsl:if test="$date != ''"> <!-- TODO: proper false() -->
						<time datetime="$date">
							<xsl:value-of select="date:format-date($date, 'EEE, d MMMM yyyy')"/>
						</time>
					</xsl:if>

					<xsl:apply-templates select="h:body/node()|h:body/text()|h:body/processing-instruction()"/>
				</main>

				<footer>
					<xsl:call-template name="e:page-footer"/>
				</footer>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

