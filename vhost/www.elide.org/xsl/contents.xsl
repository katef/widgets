<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:c="http://xml.elide.org/contents"

	exclude-result-prefixes="h c">

	<xsl:template name="c:contents">
		<xsl:param name="doc" select="/.."/>
		<xsl:param name="category"/>

		<ul>
			<xsl:for-each select="$doc/c:items/c:item">
				<li>
					<xsl:if test="$category and starts-with(@href, concat('/', $category))">
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
					</a>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>

</xsl:stylesheet>

