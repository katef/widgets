<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings"
	xmlns:c="http://xml.elide.org/contents"

	extension-element-prefixes="str"

	exclude-result-prefixes="c str">

	<xsl:import href="../../../xsl/lib/str.tolower.xsl"/>

	<xsl:template match="c:item/@desc">
		<span class="description">
			<xsl:value-of select="."/>
		</span>
	</xsl:template>

	<xsl:template match="c:item">
		<xsl:param name="category"/>

		<li>
			<xsl:if test="local-name(following-sibling::*[1]) = 'sep'">
				<xsl:attribute name="class">
					<xsl:text>sep</xsl:text>
				</xsl:attribute>
			</xsl:if>

			<xsl:if test="str:tolower(@name) = $category">
				<xsl:attribute name="class">
					<xsl:text>current</xsl:text>
				</xsl:attribute>
			</xsl:if>

			<a href="{@href}">
				<xsl:if test="@rel">
					<xsl:attribute name="rel">
						<xsl:value-of select="@rel"/>
					</xsl:attribute>
				</xsl:if>

				<xsl:value-of select="@name"/>
				<xsl:apply-templates select="@desc"/>
			</a>

			<xsl:if test="c:item">
				<ul>
					<xsl:if test="c:item/@desc">
						<xsl:attribute name="style">
							<xsl:text>width: 18em;</xsl:text>
						</xsl:attribute>
					</xsl:if>

					<xsl:apply-templates select="c:item"/>
				</ul>
			</xsl:if>
		</li>
	</xsl:template>

	<xsl:template name="c:contents">
		<xsl:param name="doc" select="/.."/>
		<xsl:param name="category" select="''"/>

		<ul>
			<xsl:apply-templates select="$doc/c:items/c:item">
				<xsl:with-param name="category" select="$category"/>
			</xsl:apply-templates>
		</ul>
	</xsl:template>

</xsl:stylesheet>

