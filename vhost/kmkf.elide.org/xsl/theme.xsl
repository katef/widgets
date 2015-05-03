<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:str="http://exslt.org/strings"
	xmlns:common="http://exslt.org/common"

	extension-element-prefixes="str"

	exclude-result-prefixes="h str">

	<xsl:template match="h:title" mode="body">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template name="kmkf-output">
		<xsl:param name="page"/>

		<xsl:param name="main"  select="/.."/>
		<xsl:param name="notes" select="/.."/>

		<xsl:call-template name="theme-output">
			<xsl:with-param name="class" select="'man'"/>
			<xsl:with-param name="css"   select="'style.css debug.css'"/>

			<xsl:with-param name="js">
				<xsl:value-of select="'col.js fixup.js overlay.js debug.js'"/>
			</xsl:with-param>

			<xsl:with-param name="onload">
				<xsl:text>Colalign.init(r);</xsl:text>
				<xsl:text>Fixup.init(r);</xsl:text>
				<xsl:text>Overlay.init(r, 'cols', 24);</xsl:text>
				<xsl:text>Overlay.init(r, 'rows', 26);</xsl:text>
			</xsl:with-param>

			<xsl:with-param name="page">
				<xsl:copy-of select="$page"/>
			</xsl:with-param>

			<xsl:with-param name="site">
				<xsl:text>kmkf</xsl:text>
			</xsl:with-param>

			<xsl:with-param name="body">
				<main>
					<xsl:copy-of select="$main"/>
				</main>

				<aside class="meta">
					<nav class="submenu">
						<ul>
							<li>
								<a href="/about/">About</a>
							</li>
							<li>
								<a href="/download/">Download</a>
							</li>
						</ul>
					</nav>

					<hr/>

					<xsl:variable name="manvolnum"   select="'5mk'"/>
					<xsl:variable name="productname" select="'KMKF'"/>

					<nav class="submenu">
						<xsl:call-template name="submenu-bottom">
							<xsl:with-param name="manindex"         select="$manindex"/>
							<xsl:with-param name="page-productname" select="$productname"/>
						</xsl:call-template>
					</nav>
				</aside>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

