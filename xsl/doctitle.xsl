<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:common="http://exslt.org/common">

	<xsl:template name="doctitle">
		<xsl:param name="product"/>
		<xsl:param name="title"/>
		<xsl:param name="page" select="false()"/>

		<!-- TODO: remove bp- prefix -->
		<header id="bp-doctitle">
			<h1>
				<xsl:copy-of select="$product"/>

				<span>
					<xsl:copy-of select="$title"/>
				</span>
			</h1>

			<xsl:if test="$page">
				<h2>
					<xsl:copy-of select="$page"/>
				</h2>
			</xsl:if>
		</header>
	</xsl:template>

</xsl:stylesheet>

