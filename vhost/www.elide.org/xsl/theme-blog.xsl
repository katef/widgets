<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:tl="http://xml.elide.org/timeline"
	xmlns:date="http://exslt.org/dates-and-times"

	exclude-result-prefixes="h tl date">

	<xsl:import href="../../../xsl/theme.xsl"/>
	<xsl:import href="../../../xsl/img.xsl"/>
	<xsl:import href="../../../xsl/blog.xsl"/>

	<xsl:import href="theme.xsl"/>
	<xsl:import href="theme-plain.xsl"/>

	<!-- TODO: centralise relative path to root (see also theme-bib.xsl for the same) -->
	<xsl:param name="blog-file"/>
	<xsl:param name="blog-data" select="document(concat('../../../', $blog-file))"/>

	<xsl:template match="processing-instruction('blog-title')" mode="copy">
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

	<xsl:template match="processing-instruction('blog-archive')" mode="copy">
		<xsl:apply-templates select="$blog-data/tl:timeline" mode="tl-archive"/>
	</xsl:template>

	<xsl:template match="processing-instruction('blog-body')" mode="copy">
		<xsl:apply-templates select="$blog-data/tl:timeline" mode="tl-body"/>
	</xsl:template>

	<xsl:template match="processing-instruction('blog-index')" mode="copy">
		<xsl:apply-templates select="$blog-data/tl:timeline" mode="tl-index"/>
	</xsl:template>

</xsl:stylesheet>

