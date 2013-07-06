<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:tl="http://xml.elide.org/timeline"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	exclude-result-prefixes="tl">

	<xsl:param name="date"/>
	<xsl:param name="shortform"/>
	<xsl:param name="comment"/>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="tl:entry/tl:comments">
		<tl:comments>
			<xsl:apply-templates select="@*|node()"/>

			<!-- Silly that we can't do this in match="" -->
			<xsl:if test="../@date = $date and ../@shortform = $shortform">
				<xsl:copy-of select="document($comment)"/>
			</xsl:if>
		</tl:comments>
	</xsl:template>

</xsl:stylesheet>

