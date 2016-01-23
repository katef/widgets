<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template name="ordinal">
		<xsl:param name="n"/>

		<xsl:choose>
			<xsl:when test="$n &gt; 10">
				<xsl:text>th</xsl:text>
			</xsl:when>

			<xsl:when test="$n mod 10 = 1">
				<xsl:text>st</xsl:text>
			</xsl:when>

			<xsl:when test="$n mod 10 = 2">
				<xsl:text>nd</xsl:text>
			</xsl:when>

			<xsl:when test="$n mod 10 = 3">
				<xsl:text>rd</xsl:text>
			</xsl:when>

			<xsl:otherwise>
				<xsl:text>th</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>

