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

	<xsl:import href="../../../xsl/theme.xsl"/>
	<xsl:import href="../../../xsl/man.xsl"/>
	<xsl:import href="theme.xsl"/>

	<!-- TODO: path from httpd as param -->
	<xsl:variable name="manindex" select="document('../../../var/kmkf-man/index.xhtml5')"/>

	<xsl:template match="/h:html">
		<xsl:call-template name="kmkf-output">
			<xsl:with-param name="class">
				<xsl:value-of select="concat(@class, ' man')"/>
			</xsl:with-param>

			<xsl:with-param name="page">
				<xsl:apply-templates select="h:head/h:title" mode="body"/>
			</xsl:with-param>

			<xsl:with-param name="site">
				<xsl:text>kmkf</xsl:text>
			</xsl:with-param>

			<xsl:with-param name="meta">
				<xsl:variable name="manvolnum"   select="h:head/h:meta[@name = 'refmeta-manvolnum']"/>
				<xsl:variable name="productname" select="h:head/h:meta[@name = 'refmeta-productname']"/>
				<xsl:variable name="refname"     select="h:head/h:meta[@name = 'refmeta-refname']"/>

				<nav class="submenu">
					<xsl:if test="$manvolnum and $productname and $refname">
						<xsl:call-template name="submenu-bottom">
							<xsl:with-param name="manindex"         select="$manindex"/>
							<xsl:with-param name="page-productname" select="$productname/@content"/>
							<xsl:with-param name="page-title"       select="$refname/@content"/>
						</xsl:call-template>
					</xsl:if>
				</nav>
			</xsl:with-param>

			<xsl:with-param name="main">
				<header id="bp-doctitle">
					<h1>
						<xsl:variable name="productname" select="h:head/h:meta[@name = 'refmeta-productname']/@content"/>
						<xsl:variable name="productrole" select="h:head/h:meta[@name = 'refmeta-productrole']/@content"/>
						<xsl:variable name="title"       select="h:head/h:meta[@name = 'refmeta-title']/@content"/>
						<xsl:variable name="pre"         select="substring-before($title, ' ')"/>
						<xsl:variable name="post"        select="substring-after ($title, ' ')"/>

						<xsl:choose>
							<xsl:when test="$productrole and $pre = $productname">
								<xsl:value-of select="$productrole"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$pre"/>
							</xsl:otherwise>
						</xsl:choose>

						<span>
							<xsl:value-of select="$post"/>
						</span>
					</h1>

					<h2>
						<xsl:apply-templates select="h:head/h:title" mode="body"/>
					</h2>
				</header>

				<xsl:apply-templates select="h:body/node()|h:body/text()|h:body/processing-instruction()"/>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

