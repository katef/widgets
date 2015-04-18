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
		<xsl:param name="body"  select="/.."/>
		<xsl:param name="notes" select="/.."/>

		<xsl:call-template name="theme-output">
			<xsl:with-param name="class" select="$class"/>
<!-- XXX: hyphenate only certian elements. maybe just <p>
			<xsl:with-param name="class" select="concat($class, ' hyphenate')"/>
-->
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
					<xsl:copy-of select="$body"/>
				</main>

				<xsl:if test="$notes and count(common:node-set($notes)/*) != 0">
					<aside class="notes">
						<xsl:copy-of select="$notes"/>
					</aside>
				</xsl:if>

				<aside class="meta">
					<xsl:copy-of select="$meta"/>
				</aside>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

