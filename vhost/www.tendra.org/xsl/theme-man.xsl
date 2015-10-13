<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"

	exclude-result-prefixes="h">

	<xsl:import href="theme.xsl"/>

<!--
	<xsl:param name="www-css"/>
	<xsl:param name="www-js"/>
	<xsl:param name="uri"/>
-->

	<!-- TODO: path from httpd as param -->
	<xsl:variable name="manindex" select="document('../../../var/tendra-man/index.xhtml5')"/>

	<xsl:template match="/h:html/h:head/h:title" mode="body">
		<xsl:apply-templates select="node()|text()|processing-instruction()"/>
	</xsl:template>

	<xsl:template match="/h:html">
		<xsl:call-template name="tendra-output">
			<xsl:with-param name="category" select="'documentation'"/>
			<xsl:with-param name="class"    select="concat(@class, ' hyphenate')"/>

			<xsl:with-param name="page">
				<xsl:apply-templates select="h:head/h:title" mode="body"/>
			</xsl:with-param>

			<xsl:with-param name="head">
				<xsl:copy-of select="h:head/h:meta[@name = 'description']"/>
				<xsl:copy-of select="h:head/h:meta[@name = 'keywords']"/>
			</xsl:with-param>


			<xsl:with-param name="main">
				<h1>
					<xsl:apply-templates select="h:head/h:title" mode="body"/>
				</h1>

				<xsl:apply-templates select="h:body/node()|h:body/text()|h:body/processing-instruction()"/>
			</xsl:with-param>

			<xsl:with-param name="sidebar">
				<h1>
					<xsl:text>Manpages</xsl:text>
				</h1>

				<xsl:for-each select="$manindex/h:html/h:body/h:section">
					<section>
						<h2>
							<xsl:copy-of select="h:h1/*|h:h1/text()"/>
						</h2>

						<ul>
							<xsl:for-each select=".//h:dt">
								<li>
									<xsl:copy-of select="*"/>
								</li>
							</xsl:for-each>
						</ul>
					</section>
				</xsl:for-each>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

