<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:tl="http://xml.elide.org/timeline"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	exclude-result-prefixes="tl date">

	<xsl:include href="../../../xsl/blog.xsl"/>

	<xsl:template match="processing-instruction('blog-title')">
		<xsl:choose>
			<xsl:when test="date:day-in-week($tl:date)">
				<xsl:value-of select="date:format-date($tl:date,
					&quot;EEEE&quot;)"/>
			</xsl:when>

			<xsl:when test="date:month-in-year($tl:date)">
				<xsl:value-of select="date:format-date($tl:date,
					&quot;MMMM&quot;)"/>
			</xsl:when>

			<xsl:when test="date:year($tl:date)">
				<xsl:value-of select="date:format-date($tl:date,
					&quot;yyyy&quot;)"/>
			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="$blog-name"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>

