<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:str="http://exslt.org/strings"
	xmlns:set="http://exslt.org/sets"
	xmlns:common="http://exslt.org/common"

	extension-element-prefixes="str"

	exclude-result-prefixes="h str">

	<xsl:import href="../../../xsl/copy.xsl"/>
	<xsl:import href="../../../xsl/theme.xsl"/>
	<xsl:import href="../../../xsl/doctitle.xsl"/>
	<xsl:import href="theme.xsl"/>

	<!-- TODO: path from httpd as param -->
	<xsl:variable name="manindex" select="document('../../../var/kmkf-man/index.xhtml5')"/>

	<xsl:template match="/h:html">
		<xsl:call-template name="kmkf-output">
			<xsl:with-param name="page">
				<xsl:apply-templates select="h:head/h:title" mode="body"/>
			</xsl:with-param>

			<xsl:with-param name="head">
				<xsl:copy-of select="h:head/h:meta[@name = 'description']"/>
				<xsl:copy-of select="h:head/h:meta[@name = 'keywords']"/>
			</xsl:with-param>

			<xsl:with-param name="main">
				<xsl:variable name="productname" select="h:head/h:meta[@name = 'refmeta-productname']/@content"/>
				<xsl:variable name="productrole" select="h:head/h:meta[@name = 'refmeta-productrole']/@content"/>
				<xsl:variable name="title"       select="h:head/h:meta[@name = 'refmeta-title']/@content"/>
				<xsl:variable name="pre"         select="substring-before($title, ' ')"/>
				<xsl:variable name="post"        select="substring-after ($title, ' ')"/>

				<xsl:call-template name="doctitle">
					<xsl:with-param name="product">
						<xsl:choose>
							<xsl:when test="$productrole and $pre = $productname">
								<xsl:value-of select="$productrole"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$pre"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="title">
						<xsl:value-of select="$post"/>
					</xsl:with-param>
					<xsl:with-param name="page">
						<xsl:apply-templates select="h:head/h:title" mode="body"/>
					</xsl:with-param>
				</xsl:call-template>

				<xsl:apply-templates select="h:body/node()" mode="copy"/>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

