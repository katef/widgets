<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:str="http://exslt.org/strings"
	xmlns:common="http://exslt.org/common"
	xmlns:c="http://xml.elide.org/contents"

	extension-element-prefixes="str"

	exclude-result-prefixes="h c str">

	<xsl:import href="../../../xsl/lib/str.tolower.xsl"/>
	<xsl:import href="../../../xsl/man.xsl"/>
	<xsl:import href="../../../xsl/contents.xsl"/>

	<xsl:template match="h:title" mode="body">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template name="kmkf-output">
		<xsl:param name="page"/>

		<xsl:param name="head"  select="/.."/>
		<xsl:param name="main"  select="/.."/>
		<xsl:param name="notes" select="/.."/>

		<xsl:call-template name="theme-output">
			<!-- OTT <xsl:with-param name="color" select="'#7c8'"/> -->
			<xsl:with-param name="class" select="'man'"/>
			<xsl:with-param name="css"   select="'style.css'"/>

			<xsl:with-param name="js">
				<xsl:value-of select="'col.js fixup.js overlay.js expander.js debug.js'"/>
			</xsl:with-param>

			<xsl:with-param name="onload">
				<xsl:text>Expander.init(r, 'nav', 'li', false, true);</xsl:text>
				<xsl:text>Colalign.init(r);</xsl:text>
				<xsl:text>Fixup.init(r);</xsl:text>
			</xsl:with-param>

			<xsl:with-param name="page">
				<xsl:copy-of select="$page"/>
			</xsl:with-param>

			<xsl:with-param name="site">
				<xsl:text>kmkf</xsl:text>
			</xsl:with-param>

			<xsl:with-param name="head">
				<xsl:copy-of select="$head"/>
			</xsl:with-param>

			<xsl:with-param name="body">
				<nav role="navigation">
					<xsl:call-template name="c:contents">
						<xsl:with-param name="doc"      select="document('contents.xml')"/>
						<xsl:with-param name="category" select="str:tolower($page)"/>
					</xsl:call-template>

					<hr/>

					<xsl:variable name="productname" select="'KMKF'"/>
					<xsl:variable name="manvolnum"   select="'7mk'"/>
					<xsl:variable name="refname"     select="h:head/h:meta[@name = 'refmeta-refname']"/>

					<xsl:call-template name="submenu-bottom">
						<xsl:with-param name="manindex"            select="$manindex"/>
						<xsl:with-param name="current-productname" select="$productname"/>
						<xsl:with-param name="current-manvolnum"   select="$manvolnum"/>
						<xsl:with-param name="current-refname"     select="$refname/@content"/>
					</xsl:call-template>
				</nav>

				<main>
					<xsl:copy-of select="$main"/>
				</main>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

