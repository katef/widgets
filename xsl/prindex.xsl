<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings"
	xmlns:common="http://exslt.org/common"

	extension-element-prefixes="str common"

	exclude-result-prefixes="str common h">

	<xsl:import href="output.xsl"/>

	<xsl:param name="src"/>
	<xsl:param name="title" select="false()"/>
	<xsl:param name="mdb.url.man" select="false()"/> <!-- e.g. 'http://man.example.com' -->

	<xsl:variable name="root">
		<xsl:for-each select="str:tokenize($src, ':')">
			<xsl:copy-of select="document(.)/h:html"/>
		</xsl:for-each>
	</xsl:variable>

	<xsl:template match="h:html">
		<xsl:variable name="date" select="h:head/h:meta[@name = 'created']/@content"/>

		<dt>
			<a href="/pr/{$date}/">
				<xsl:value-of select="$date"/>
			</a>
		</dt>

<!-- TODO: also output short title for links etc (keep as meta in xhtml5 source) -->
		<dd data-created="{$date}">
			<xsl:value-of select="h:head/h:title"/>
		</dd>
	</xsl:template>

	<xsl:template match="/">
		<xsl:call-template name="output">
			<xsl:with-param name="class"  select="'prindex'"/>

			<xsl:with-param name="title">
				<xsl:if test="$title">
					<xsl:value-of select="$title"/>
				</xsl:if>
			</xsl:with-param>

			<xsl:with-param name="body">
				<dl>
					<xsl:apply-templates select="common:node-set($root)/h:html">
<!-- TODO: sort @content as date -->
						<xsl:sort select="h:head/h:meta[@name = 'created']/@content"/>
					</xsl:apply-templates>
				</dl>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>

