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
		<xsl:param name="class"/>
		<xsl:param name="page"/>
		<xsl:param name="site"/>

		<xsl:param name="meta"  select="/.."/>
		<xsl:param name="main"  select="/.."/>
		<xsl:param name="notes" select="/.."/>

		<xsl:call-template name="theme-output">
			<xsl:with-param name="class" select="$class"/>
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
				<xsl:copy-of select="$site"/>
			</xsl:with-param>

			<xsl:with-param name="body">
				<main>
					<xsl:copy-of select="$main"/>
				</main>

				<xsl:if test="$notes and count(common:node-set($notes)/*) != 0">
					<aside class="notes">
						<xsl:copy-of select="$notes"/>
					</aside>
				</xsl:if>

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

					<!-- TODO: merge in manindex here. maybe centralise with bp -->
					<xsl:copy-of select="$meta"/>
				</aside>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

