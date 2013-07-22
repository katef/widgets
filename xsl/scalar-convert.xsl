<?xml version="1.0"?>

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:dyn="http://exslt.org/dynamic"
	xmlns:scalar="http://exslt.org/scalar-convert"
	xmlns:common="http://exslt.org/common"
	xmlns="http://www.w3.org/2000/svg"

	extension-element-prefixes="dyn">

	<!--
		Conversion of a scalar value between various units.

		Default relations are as specified by CSS2, but may be overridden.
		For example, if you have empiric knowledge of a font with an x-height
		other than 0.5em, pass a param to override $ex.

		$src.value - A string of a numerical value of the form '123.455in'.
		             The suffix of units is optional; if not specified,
		             'px' is assumed.

		$dst.units - A string of a suffix, such as 'cm', to which $src.value
		             is to be converted.
		             If false(), the source units are used.

		$dpi              - Dots (px) per inch.
		$font-size        - One em height (in px).
		$percent.min/.max - Numerical values of the maximum and minimum values
		                    (in px) respectively corresponding to 0% and 100%.

		$fmt - An optional format string for format-number().
	-->
	<xsl:template name="scalar:convert">
		<xsl:param name="src.value"/>
		<xsl:param name="dst.units"/>

		<xsl:param name="dpi"/>
		<xsl:param name="font-size"/>
		<xsl:param name="percent.max"/>
		<xsl:param name="percent.min"/>

		<!-- absolute -->
		<xsl:param scalar:suffix="px" name="px" select="1"/>

		<!-- relative to font size -->
		<xsl:param scalar:suffix="em" name="em" select="$font-size"/>
		<xsl:param scalar:suffix="ex" name="ex" select="$font-size * 0.5"/>

		<!-- relative to $dpi -->
		<xsl:param scalar:suffix="in" name="in" select="$dpi"/>
		<xsl:param scalar:suffix="cm" name="cm" select="$in div 2.54"/>
		<xsl:param scalar:suffix="mm" name="mm" select="$cm * 0.1"/>
		<xsl:param scalar:suffix="pt" name="pt" select="$in * (1 div 72)"/>
		<xsl:param scalar:suffix="pc" name="pc" select="$pt * 12"/>

		<!-- relative to view size -->
		<xsl:param scalar:suffix="%" name="pr" select="$percent.max - $percent.min"/>

		<xsl:param name="fmt" select="'#.##########'"/>

		<xsl:variable name="units" select="document('')
			//xsl:template[@name = 'scalar:convert']
			 /xsl:param[@scalar:suffix]"/>

		<xsl:variable name="src.suffix-unit"
			select="$units[@scalar:suffix = substring($src.value,
					string-length($src.value) - string-length(@scalar:suffix) + 1,
					string-length(@scalar:suffix))]"/>

		<xsl:variable name="src">
			<xsl:choose>
				<xsl:when test="$src.suffix-unit">
					<xsl:value-of select="$src.suffix-unit/@scalar:suffix"/>
				</xsl:when>

				<xsl:otherwise>
					<xsl:value-of select="'px'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="dst">
			<xsl:choose>
				<xsl:when test="$dst.units">
					<xsl:value-of select="$dst.units"/>
				</xsl:when>

				<xsl:otherwise>
					<xsl:value-of select="$src"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="user">
			<xsl:call-template name="scalar:scale">
				<xsl:with-param name="n" select="number(substring($src.value, 1, string-length($src.value) - string-length($src.suffix-unit/@scalar:suffix)))"/>
				<xsl:with-param name="m" select="dyn:evaluate($units[@scalar:suffix = $src]/@select)"/>
				<xsl:with-param name="c" select="($src = '%') * $percent.min"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="result">
			<xsl:call-template name="scalar:scale">
				<xsl:with-param name="n" select="$user"/>
				<xsl:with-param name="m" select="1 div dyn:evaluate($units[@scalar:suffix = $dst]/@select)"/>
				<xsl:with-param name="k" select="($dst = '%') * $percent.min"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="format-number($result, $fmt)"/>
		<xsl:if test="$dst != 'px'">
			<xsl:value-of select="$dst"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="scalar:scale">
		<xsl:param name="n"/>
		<xsl:param name="m"/>
		<xsl:param name="k" select="0"/>
		<xsl:param name="c" select="0"/>

		<xsl:value-of select="$m * ($n - $k) + $c"/>
	</xsl:template>

</xsl:stylesheet>

