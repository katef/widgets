<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings"

	extension-element-prefixes="date func str"

	exclude-result-prefixes="date func str">

	<func:function name="date:same-day">
		<xsl:param name="a"/>
		<xsl:param name="b"/>

		<func:result select="date:year($a) =        date:year($b)
		          and date:day-in-year($a) = date:day-in-year($b)"/>
	</func:function>

	<!-- TODO: eventually replace with date:format-date() -->
	<func:function name="date:ym">
		<xsl:param name="date"/>
		<xsl:param name="month" select="date:month-in-year($date)"/>

		<xsl:variable name="year"  select="date:year($date)"/>

		<func:result select="concat($year, '-', str:align($month, '00', 'right'))"/>
	</func:function>

</xsl:stylesheet>

