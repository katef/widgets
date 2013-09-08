<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:date="http://exslt.org/dates-and-times"

	extension-element-prefixes="date"

	exclude-result-prefixes="date">

	<xsl:import href="../../../xsl/ordinal.xsl"/>

	<xsl:template name="ordinaldate">
		<xsl:param name="date"/>

		<!-- TODO: pubdate? -->
		<time datetime="{$date}" pubdate="pubdate">
			<xsl:if test="date:day-in-month($date)">
				<xsl:value-of select="date:day-in-month($date)"/>
				<span class="ordinal">
					<xsl:call-template name="ordinal">
						<xsl:with-param name="n" select="date:day-in-month($date)"/>
					</xsl:call-template>
				</span>

				<xsl:text>&#xA0;</xsl:text>
			</xsl:if>

			<xsl:if test="date:day-in-month($date)">
				<xsl:variable name="mon" select="date:month-abbreviation($date)"/>
				<xsl:choose>
					<xsl:when test="$mon = 'Sep'">
						<xsl:text>Sept</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$mon"/>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:text>&#xA0;</xsl:text>
			</xsl:if>

			<xsl:text>&#8217;</xsl:text>
			<xsl:value-of select="substring(date:year($date), 3, 2)"/>
		</time>
	</xsl:template>

</xsl:stylesheet>

