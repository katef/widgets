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

	<xsl:template name="c:contents">
		<xsl:param name="doc"      select="/.."/>
		<xsl:param name="category" select="''"/>

		<ul>
			<xsl:for-each select="$doc/c:items/c:item">
				<li>
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
					</a>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>

</xsl:stylesheet>

