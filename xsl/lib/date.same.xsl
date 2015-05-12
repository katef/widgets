<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:func="http://exslt.org/functions"

	extension-element-prefixes="date func"

	exclude-result-prefixes="date func">

	<func:function name="date:same-day">
		<xsl:param name="a"/>
		<xsl:param name="b"/>

		<func:result select="date:year($a) =        date:year($b)
		          and date:day-in-year($a) = date:day-in-year($b)"/>
	</func:function>

	<func:function name="date:same-month">
		<xsl:param name="a"/>
		<xsl:param name="b"/>

		<func:result select="date:year($a) =          date:year($b)
		        and date:month-in-year($a) = date:month-in-year($b)"/>
	</func:function>

	<func:function name="date:same-year">
		<xsl:param name="a"/>
		<xsl:param name="b"/>

		<func:result select="date:year($a) =          date:year($b)"/>
	</func:function>

</xsl:stylesheet>

