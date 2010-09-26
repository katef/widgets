<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:sz="http://xml.elide.org/filesize">

	<!--
		Format a file size to a human-readable (but inaccurate) form.

		$base  - The value for each $units column. Sensible values are 1000
		         1024.
		$obase - The number of digits on the left hand side, in the output base
		         (which is always base 10), before rolling over to the next
		         unit. Sensible values are 100 and 1000.
		$sfd   - The number of significant digits on the right-hand-side.
		         Beyond this, values are rounded off (possibly with rounding
		         error, for large values). Sensible values are 1, 2, 3, 4.
	-->
	<xsl:template name="sz:size">
		<xsl:param name="value"/>
		<xsl:param name="base"  select="1024"/>
		<xsl:param name="obase" select="100"/>
		<xsl:param name="sfd"   select="1"/>
		<xsl:param name="units" select="'kMGTP'"/>

		<xsl:variable name="lhs"
			select="$value div $base - $value mod $base div $base"/>
		<xsl:variable name="rhs"
			select="$value mod $base"/>

		<xsl:choose>
			<xsl:when test="$value &lt; 0">
				<xsl:message terminate="yes">
					<xsl:text>negative sizes not supported</xsl:text>
				</xsl:message>
			</xsl:when>

			<xsl:when test="$value = 0">
				<xsl:value-of select="$value"/>
			</xsl:when>

			<xsl:when test="$value &lt; 1">
				<xsl:message terminate="yes">
					<xsl:text>fractional sizes not supported</xsl:text>
				</xsl:message>
			</xsl:when>

			<xsl:when test="$value &lt; $obase">	<!-- 12B -->
				<xsl:value-of select="$value"/>
			</xsl:when>

			<xsl:when test="$lhs &lt; $obase or string-length($units) = 1">
				<xsl:variable name="rhd" select="round(substring($rhs, 1, $sfd))"/>
				<xsl:value-of select="$lhs"/>
				<xsl:if test="$sfd &gt; 0 and $rhd != 0">
					<xsl:value-of select="concat('.', $rhd)"/>
				</xsl:if>
				<xsl:value-of select="substring($units, 1, 1)"/>
			</xsl:when>

			<xsl:otherwise>
				<xsl:call-template name="sz:size">
					<xsl:with-param name="base"  select="$base"/>
					<xsl:with-param name="sfd"   select="$sfd"/>
					<xsl:with-param name="units" select="substring($units, 2, string-length($units))"/>
					<xsl:with-param name="value" select="$value div $base"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>

