<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:c="http://xml.elide.org/contents"
	xmlns:e="http://xml.elide.org/elide_website"

	exclude-result-prefixes="h c e">

	<xsl:import href="../../../xsl/theme.xsl"/>
	<xsl:import href="../../../xsl/contents.xsl"/>

	<xsl:param name="www-css"/>
	<xsl:param name="www-js"/>

	<!-- TODO: nobody cares; get rid of this -->
	<xsl:template name="e:page-footer">
		<tt class="rcsid">
			<xsl:text>$Id: elide.xsl 549 2010-10-24 20:33:47Z kate $</xsl:text>
		</tt>
	</xsl:template>

	<xsl:template name="elide-output">
		<xsl:param name="category"/>
		<xsl:param name="class"/>
		<xsl:param name="page"/>

		<xsl:param name="head" select="/.."/>
		<xsl:param name="main" select="/.."/>

		<xsl:call-template name="theme-output">
			<xsl:with-param name="category" select="$category"/>
			<xsl:with-param name="class"    select="$class"/>

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

<!--
			<xsl:with-param name="page">
				<xsl:copy-of select="$page"/>
			</xsl:with-param>
-->

			<xsl:with-param name="site">
				<xsl:text>Kate&#8217;s </xsl:text>
				<xsl:copy-of select="$page"/>
			</xsl:with-param>

			<xsl:with-param name="head">
				<xsl:copy-of select="$head"/>

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
					and $page != 'Articles'"/>

				<header>
					<h1>
						<xsl:text>Kate&#8217;s Amazing </xsl:text>
						<xsl:choose>
							<xsl:when test="$article">
								<xsl:text>Articles</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="$page"/>
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
							<xsl:copy-of select="$page"/>
						</h1>
					</xsl:if>

					<xsl:copy-of select="$main"/>
				</main>

				<footer>
					<xsl:call-template name="e:page-footer"/>
				</footer>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

