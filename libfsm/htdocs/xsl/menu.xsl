<?xml version="1.0"?>

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsl2="http://xml.libfsm.org/xslt-alias"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns="http://www.w3.org/2000/svg"
	xmlns:gv="http://xml.libfsm.org/gv"
	xmlns:xlink="http://www.w3.org/1999/xlink">

	<xsl:import href="dot.xsl"/>

	<xsl:namespace-alias stylesheet-prefix="xsl2" result-prefix="xsl"/>

	<xsl:output indent="yes" cdata-section-elements="script"/>

	<xsl:template match="/">
		<!-- This is generated so that webpage.xsl can call-template it to include svg inline.
			(the SVG needs to be inline so that it has the same DOM document, and therefore permits relocating) -->
		<xsl2:stylesheet version="1.0"
			xmlns="http://www.w3.org/2000/svg"
			xmlns:gv="http://xml.libfsm.org/gv"
			xmlns:xlink="http://www.w3.org/1999/xlink">

			<xsl2:template name="menu">
				<xsl:apply-templates/>
			</xsl2:template>
		</xsl2:stylesheet>
	</xsl:template>

	<xsl:template name="braces">
		<g transform="translate(-5 110)" class="help">
			<!-- TODO: is there a nice way to <def> and <use> this where each brace has a different width? -->
			<path
				d=" M 50,10
				    C 50,15.5 55,21.25 60.25,21.25
				    L 187,21.25
				    C 192.25,21.25 197.5,27 197.5,32 197.5,27 202.25,21.25 208,21.25
				    L 334.75,21.25
				    C 340,21.25 345.25,15.5 345.25,10"/>
			<text text-anchor="middle" x="192.5" y="47">
				<xsl:text>Learn about it</xsl:text>
			</text>
		</g>

		<g transform="translate(75 110)" class="help">
			<path
				d=" M 310,10
				    C 310,15.5 315,21.25 320.25,21.25
				    L 422,21.25
				    C 427.25,21.25 432.5,27 432.5,32 432.5,27 437.25,21.25 443,21.25
				    L 544.75,21.25
				    C 550,21.25 555.25,15.5 555.25,10"/>
			<text text-anchor="middle" x="432.5" y="47">
				<xsl:text>Use it</xsl:text>
			</text>
		</g>
	</xsl:template>

	<xsl:template match="svg:svg">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>

			<xsl:attribute name="onload">
				<xsl:value-of select="'Menu.restore();'"/>
			</xsl:attribute>

			<xsl:attribute name="onunload">
				<xsl:value-of select="'Menu.save();'"/>
			</xsl:attribute>

			<!-- XXX: grid concepts for webpage.xsl only -->
			<xsl:attribute name="class">
				<xsl:text>menu grid-span-6</xsl:text>
			</xsl:attribute>

			<xsl:apply-templates select="node()"/>

			<xsl:call-template name="braces"/>
		</xsl:copy>
	</xsl:template>

	<!-- TODO: maybe do this in css instead? -->
	<xsl:template match="svg:text">
		<xsl:variable name="text" select="translate(., ' _', '')"/>

		<xsl:if test="$text != ''">
			<xsl:copy>
				<xsl:apply-templates select="@*"/>
	
				<xsl:choose>
					<xsl:when test="$text = 'O'">
						<xsl:attribute name="y"><xsl:value-of select="@y - 10"/></xsl:attribute>
						<xsl:text>Download</xsl:text>
					</xsl:when>
					<xsl:when test="$text = 'A'">
						<xsl:attribute name="y"><xsl:value-of select="@y - 5"/></xsl:attribute>
						<xsl:text>About</xsl:text>
					</xsl:when>
					<xsl:when test="$text = 'B'">
						<xsl:attribute name="y"><xsl:value-of select="@y + 30"/></xsl:attribute>
						<xsl:text>Blog</xsl:text>
					</xsl:when>
					<xsl:when test="$text = 'R'">
						<xsl:attribute name="x"><xsl:value-of select="@x - 30"/></xsl:attribute>
						<xsl:attribute name="y"><xsl:value-of select="@y + 65"/></xsl:attribute>
						<xsl:text>Browser</xsl:text>
					</xsl:when>
					<xsl:when test="$text = 'I'">
						<xsl:attribute name="x"><xsl:value-of select="@x + 00"/></xsl:attribute>
						<xsl:attribute name="y"><xsl:value-of select="@y + 10"/></xsl:attribute>
						<xsl:text>Timeline</xsl:text>
					</xsl:when>
					<xsl:when test="$text = 'T'">
						<xsl:attribute name="y"><xsl:value-of select="@y + 25"/></xsl:attribute>
						<xsl:text>Tickets</xsl:text>
					</xsl:when>
					<xsl:when test="$text = 'D'">
						<xsl:attribute name="x"><xsl:value-of select="@x + 05"/></xsl:attribute>
						<xsl:attribute name="y"><xsl:value-of select="@y - 10"/></xsl:attribute>
						<xsl:text>Documentation</xsl:text>
					</xsl:when>
				</xsl:choose>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>

