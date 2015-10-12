<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:c="http://xml.elide.org/contents"

	exclude-result-prefixes="c">

	<xsl:template match="c:item/@desc">
		<span class="description">
			<xsl:value-of select="."/>
		</span>
	</xsl:template>

	<xsl:template match="c:item">
		<li>
			<xsl:if test="local-name(following-sibling::*[1]) = 'sep'">
				<xsl:attribute name="class">
					<xsl:text>sep</xsl:text>
				</xsl:attribute>
			</xsl:if>

			<xsl:if test="@name = 'Blog'">	<!-- TODO: get from mod_kxslt or somesuch -->
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

		<ul>
			<xsl:apply-templates select="$doc/c:items/c:item"/>
		</ul>
	</xsl:template>

</xsl:stylesheet>

