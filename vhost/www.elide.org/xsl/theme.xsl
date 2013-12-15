<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:c="http://xml.elide.org/elide_contents"
	xmlns:e="http://xml.elide.org/elide_website"

	extension-element-prefixes="date"

	exclude-result-prefixes="h c e date">

	<xsl:import href="../../../xsl/lib/date.format-date.function.xsl"/>

	<xsl:import href="../../../xsl/theme.xsl"/>
	<xsl:import href="../../../xsl/img.xsl"/>

	<xsl:param name="www-css"/>
	<xsl:param name="www-js"/>
	<xsl:param name="uri"/>

	<!-- TODO: rename contents to toc -->
	<c:contents>
		<c:category href="/diary/"    name="Diary"/>
		<c:category href="/articles/" name="Articles"/>
		<c:category href="/code/"     name="Code"/>
		<c:category href="/about/"    name="About"/>
	</c:contents>

	<xsl:template name="e:contents">
<!-- TODO: <nav> for this -->
		<ul id="contents">
			<xsl:for-each select="document('')//c:contents/c:category">
				<li>
					<xsl:if test="starts-with($uri, @href)">
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
			<xsl:with-param name="css"   select="'style.css debug.css'"/>

			<xsl:with-param name="js">
				<xsl:value-of select="'col.js fixup.js hyphenator-min.js overlay.js debug.js'"/>

				<!-- TODO: only where relevant -->
				<xsl:value-of select="' ajax.js valid.js comment.js template.js'"/>
			</xsl:with-param>

			<xsl:with-param name="onload">
				<xsl:text>Colalign.init(r);</xsl:text>
				<xsl:text>Fixup.init(r);</xsl:text>
				<xsl:text>Overlay.init(r, 'cols',  6);</xsl:text>
				<xsl:text>Overlay.init(r, 'rows', 26);</xsl:text>
			</xsl:with-param>

			<xsl:with-param name="page">
				<xsl:apply-templates select="h:head/h:title" mode="body"/>
			</xsl:with-param>

			<xsl:with-param name="site">
				<xsl:text>Kate&#8217;s </xsl:text>
				<xsl:apply-templates select="h:head/h:title" mode="body"/>
			</xsl:with-param>

			<xsl:with-param name="body">
				<header>
					<h1>
						<xsl:text>Kate&#8217;s amazing </xsl:text>
						<xsl:apply-templates select="h:head/h:title" mode="body"/>
					</h1>

					<xsl:call-template name="e:contents"/>
				</header>

				<section class="page hyphenate">
					<xsl:apply-templates select="h:body/node()|h:body/text()|h:body/processing-instruction()"/>
				</section>

				<nav id="sidebar">
					<xsl:apply-templates select="h:nav/node()|h:nav/text()|h:nav/processing-instruction()"/>
				</nav>

				<footer>
					<xsl:call-template name="e:page-footer"/>
				</footer>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

