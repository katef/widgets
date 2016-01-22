<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:b="http://xml.elide.org/blog"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:str="http://exslt.org/strings"
	xmlns:kxslt="http://xml.elide.org/mod_kxslt"

	exclude-result-prefixes="b date str kxslt"

	extension-element-prefixes="kxslt">


	<!--
		Interfaces to mod_kxslt for blog.xsl.
	-->


	<xsl:import href="blog.xsl"/>

	<xsl:variable name="blog-date" select="kxslt:getenv('QUERY_STRING')"/>


    <xsl:output indent="yes" method="xml" encoding="utf-8"
		cdata-section-elements="script"
		media-type="application/xhtml+xml"

		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>

	<xsl:template name="b:href">
		<xsl:param name="date"/>

		<xsl:attribute name="href">
			<xsl:choose>
				<xsl:when test="date:day-in-week($date)">
					<xsl:value-of select="concat(kxslt:getenv('SCRIPT_NAME'), '?',
						date:year($date), '-', str:align(date:month-in-year($date), '00', 'right'),
						'#', str:align(date:day-in-week($date), '00', 'right'))"/>
				</xsl:when>

				<xsl:otherwise>
					<xsl:value-of select="concat(kxslt:getenv('SCRIPT_NAME'), '?', $date)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

</xsl:stylesheet>

