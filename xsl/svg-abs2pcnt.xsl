<?xml version="1.0"?>

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:dyn="http://exslt.org/dynamic"
	xmlns:str="http://exslt.org/strings"
	xmlns:math="http://exslt.org/math"
	xmlns:common="http://exslt.org/common"
	xmlns:scalar="http://exslt.org/scalar-convert"
	xmlns="http://www.w3.org/2000/svg"

	extension-element-prefixes="dyn str math">

	<xsl:import href="scalar-convert.xsl"/>

	<xsl:output indent="yes"/>

	<!--
		TODO: idea: convert absolute coordinates to percentage-based coordinates
		minimal requirement: to deal with graphviz-generated code
		minimal requirement: y-coordinates only

		input params: none needed. take size from /'s viewBox
		perhaps:
			- y-axis units (pt, %, etc)
			- x-axis units (pt, %, etc)
			- radius units (pt, %, etc)
			- dpi? (used for converting from pt to px)

		don't *need* to support different units (in, mm, pt etc), but it would be nice

		for paths, convert relative coordinates (lowercase) to absolute, then to percentages

		preserve comments, PIs etc
		comma appears to be equivalent to whitespace for path commands?

		e.g. for 90dpi:
		"1pt" equals "1.25px" (and therefore 1.25 user units)
		"1pc" equals "15px" (and therefore 15 user units)
		"1mm" would be "3.543307px" (3.543307 user units)
		"1cm" equals "35.43307px" (and therefore 35.43307 user units)
		"1in" equals "90px" (and therefore 90 user units)

		TODO: if x/y axis is not percentage, then also scale viewBoxes


(TODO: note coordinates can be in floating point notation!)
NEXT: polyline, polygon. the grammar for these is [, ]-seperated coordinate pairs. each cooardinate may have a [+-], and may be a float literal
	- so can these even have unit specifiers? i don't think so!
	- evidently not... which means these need wrapping in <svg>s with a transformation applied? really we can just make the <svg> the size of its parent viewbox
or: given a path, calculate new per-pixel values for each coordinate pair (i.e. do the transformation ourselves).
	- i don't like that much. the advantage of % is i keep the same coordinates for each media query
THEN: paths
	- ditto?

	-->

	<xsl:param name="dpi"       select="90"/>
	<xsl:param name="font-size" select="150"/>

	<!--
		Valid values are:
		  absolute:         'px',
		  relative to $dpi: 'pt', 'pc', 'mm', 'cm', 'in'
		  relative to $em:  'em', 'ex',
		  relative to view: '%'
		or false() to leave values verbatim.
	-->
	<xsl:param name="w.units" select="false()"/>
	<xsl:param name="h.units" select="false()"/>
	<xsl:param name="x.units" select="false()"/>
	<xsl:param name="y.units" select="false()"/>
	<xsl:param name="r.units" select="false()"/>

	<xsl:template match="@rx|@ry|@r">
		<xsl:variable name="viewbox" select="str:tokenize(ancestor-or-self::node()/@viewBox[1], ', ')"/>

		<!--
			See SVG 1.1 S7.10 "Units":
			For any other length value expressed as a percentage of the viewport,
			the percentage is calculated as the specified percentage of
				sqrt((actual-width)**2 + (actual-height)**2))/sqrt(2).
		-->
		<xsl:variable name="min" select="math:sqrt($viewbox[1] * $viewbox[1] + $viewbox[2] * $viewbox[2]) div math:sqrt(2)"/>
		<xsl:variable name="max" select="math:sqrt($viewbox[3] * $viewbox[3] + $viewbox[4] * $viewbox[4]) div math:sqrt(2) + $min"/>

		<xsl:attribute name="{name()}">
			<xsl:call-template name="scalar:convert">
				<xsl:with-param name="dst.units"   select="$r.units"/>
				<xsl:with-param name="src.value"   select="."/>

				<xsl:with-param name="dpi"         select="$dpi"/>
				<xsl:with-param name="font-size"   select="$font-size"/>
				<xsl:with-param name="percent.min" select="$min"/>
				<xsl:with-param name="percent.max" select="$max"/>
			</xsl:call-template>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@x|@cx">
		<xsl:variable name="viewbox" select="str:tokenize(ancestor-or-self::node()/@viewBox[1], ', ')"/>

		<xsl:attribute name="{name()}">
			<xsl:call-template name="scalar:convert">
				<xsl:with-param name="dst.units"   select="$x.units"/>
				<xsl:with-param name="src.value"   select="."/>

				<xsl:with-param name="dpi"         select="$dpi"/>
				<xsl:with-param name="font-size"   select="$font-size"/>
				<xsl:with-param name="percent.min" select="$viewbox[1]"/>
				<xsl:with-param name="percent.max" select="$viewbox[1] + $viewbox[3]"/>
			</xsl:call-template>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@y|@cy">
		<xsl:variable name="viewbox" select="str:tokenize(ancestor-or-self::node()/@viewBox[1], ', ')"/>

		<xsl:attribute name="{name()}">
			<xsl:call-template name="scalar:convert">
				<xsl:with-param name="dst.units"   select="$y.units"/>
				<xsl:with-param name="src.value"   select="."/>

				<xsl:with-param name="dpi"         select="$dpi"/>
				<xsl:with-param name="font-size"   select="$font-size"/>
				<xsl:with-param name="percent.min" select="$viewbox[2]"/>
				<xsl:with-param name="percent.max" select="$viewbox[2] + $viewbox[4]"/>
			</xsl:call-template>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@width">
		<xsl:variable name="viewbox" select="str:tokenize(ancestor-or-self::node()/@viewBox[1], ', ')"/>

		<xsl:attribute name="{name()}">
			<xsl:call-template name="scalar:convert">
				<xsl:with-param name="dst.units"   select="$w.units"/>
				<xsl:with-param name="src.value"   select="."/>

				<xsl:with-param name="dpi"         select="$dpi"/>
				<xsl:with-param name="font-size"   select="$font-size"/>
				<xsl:with-param name="percent.min" select="$viewbox[1]"/>
				<xsl:with-param name="percent.max" select="$viewbox[1] + $viewbox[3]"/>
			</xsl:call-template>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@height">
		<xsl:variable name="viewbox" select="str:tokenize(ancestor-or-self::node()/@viewBox[1], ', ')"/>

		<xsl:attribute name="{name()}">
			<xsl:call-template name="scalar:convert">
				<xsl:with-param name="dst.units"   select="$h.units"/>
				<xsl:with-param name="src.value"   select="."/>

				<xsl:with-param name="dpi"         select="$dpi"/>
				<xsl:with-param name="font-size"   select="$font-size"/>
				<xsl:with-param name="percent.min" select="$viewbox[2]"/>
				<xsl:with-param name="percent.max" select="$viewbox[2] + $viewbox[4]"/>
			</xsl:call-template>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@*|node()|comment()|processing-instruction()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()|comment()|processing-instruction()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>

