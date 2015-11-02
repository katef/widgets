<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings"

	extension-element-prefixes="str"

	exclude-result-prefixes="h str">

	<xsl:template name="glossary">
		<xsl:variable name="dts" select="//h:dl[@class = 'glossary']/h:dt"/>

		<nav class="letterindex">
			<ol>
				<xsl:for-each select="str:tokenize('A B C D E F G H I J K L M N O P Q R S T U V W X Y Z')">
					<li>
						<xsl:choose>
							<xsl:when test="$dts[@id = current()]">
								<a href="#{.}">
									<xsl:value-of select="."/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="."/>
							</xsl:otherwise>
						</xsl:choose>
					</li>
				</xsl:for-each>
			</ol>
		</nav>

	</xsl:template>

</xsl:stylesheet>

