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

	<func:function name="date:same-month">
		<xsl:param name="a"/>
		<xsl:param name="b"/>

		<func:result select="date:year($a) =          date:year($b)
		        and date:month-in-year($a) = date:month-in-year($b)"/>
	</func:function>

	<func:function name="date:make">
		<xsl:param name="y"/>
		<xsl:param name="M" select="false()"/>
		<xsl:param name="d" select="false()"/>
		<xsl:param name="h" select="false()"/>
		<xsl:param name="m" select="false()"/>
		<xsl:param name="s" select="false()"/>
		<xsl:param name="S" select="false()"/>
		<xsl:param name="Z" select="false()"/>

		<xsl:variable name="yyyy" select="str:align($y, '0000', 'right')"/>
		<xsl:variable name="MM"   select="str:align($M,   '00', 'right')"/>
		<xsl:variable name="dd"   select="str:align($d,   '00', 'right')"/>
		<xsl:variable name="hh"   select="str:align($h,   '00', 'right')"/>
		<xsl:variable name="mm"   select="str:align($m,   '00', 'right')"/>
		<xsl:variable name="ss"   select="str:align($s,   '00', 'right')"/>

		<!-- TODO: eventually replace with snprintf... or something... -->
		<xsl:choose>
			<xsl:when test="$Z">
				<func:result select="concat($yyyy, '-', $MM, '-', $dd, 'T', '$hh', ':', $mm, ':', $ss, '.', '$S', $Z)"/>
			</xsl:when>

			<xsl:when test="$S">
				<func:result select="concat($yyyy, '-', $MM, '-', $dd, 'T', '$hh', ':', $mm, ':', $ss, '.', '$S')"/>
			</xsl:when>

			<xsl:when test="$s">
				<func:result select="concat($yyyy, '-', $MM, '-', $dd, 'T', '$hh', ':', $mm, ':', $ss)"/>
			</xsl:when>

			<xsl:when test="$m">
				<func:result select="concat($yyyy, '-', $MM, '-', $dd, 'T', '$hh', ':', $mm)"/>
			</xsl:when>

			<xsl:when test="$h">
				<func:result select="concat($yyyy, '-', $MM, '-', $dd, 'T', '$hh')"/>
			</xsl:when>

			<xsl:when test="$d">
				<func:result select="concat($yyyy, '-', $MM, '-', $dd)"/>
			</xsl:when>

			<xsl:when test="$M">
				<func:result select="concat($yyyy, '-', $MM)"/>
			</xsl:when>

			<xsl:otherwise>
				<func:result select="concat($yyyy)"/>
			</xsl:otherwise>
		</xsl:choose>
	</func:function>

</xsl:stylesheet>

