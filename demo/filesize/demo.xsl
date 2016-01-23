<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings"
	xmlns:sz="http://xml.elide.org/filesize"
	xmlns="http://xml.elide.org/sizes-demo">

	<xsl:import href="filesize.xsl"/>

	<xsl:output method="text"/>

	<demo>
<!--
		<size value="0.12345678"/>
		<size value="0.1234567"/>
		<size value="0.123456"/>
		<size value="0.12345"/>
		<size value="0.1234"/>
		<size value="0.123"/>
		<size value="0.12"/>
		<size value="0.1"/>
-->
		<size value="0"/>
		<size value="1"/>
		<size value="10"/>
		<size value="12"/>
		<size value="123"/>
		<size value="1234"/>
		<size value="12345"/>
		<size value="12340"/>
		<size value="12300"/>
		<size value="12300"/>
		<size value="12000"/>
		<size value="120000"/>
		<size value="100000"/>
		<size value="1000000"/>
		<size value="1234567"/>
		<size value="12345678"/>
		<size value="123456789"/>
		<size value="1234567891"/>
		<size value="12345678912"/>
		<size value="123456789123"/>
		<size value="1234567891234"/>
		<size value="12345678912345"/>
		<size value="123456789123456"/>
		<size value="1234567891234567"/>
		<size value="12345678912345678"/>
		<size value="123456789123456789"/>
		<size value="1234567891234567891"/>
		<size value="12345678912345678912"/>
		<size value="123456789123456789123"/>
		<size value="1234567891234567891234"/>
		<size value="1234567890000000000000000"/>
	</demo>

	<xsl:template match="/">
		<!-- one day, I shall implement sprintf() for xslt... -->
		<xsl:value-of select="str:align('value', str:padding(30, ' '), 'right')"/>
		<xsl:text>  </xsl:text>
		<xsl:value-of select="str:align('*1000',  str:padding(15, ' '), 'left')"/>
		<xsl:value-of select="str:align('*1024',  str:padding(15, ' '), 'left')"/>
		<xsl:value-of select="str:align('*1024',  str:padding(15, ' '), 'left')"/>
		<xsl:text>&#10;</xsl:text>
		<xsl:apply-templates select="//@value"/>
	</xsl:template>

	<xsl:template match="@value">
		<xsl:variable name="b1024">
			<xsl:call-template name="sz:size">
				<xsl:with-param name="value" select="."/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="b1000">
			<xsl:call-template name="sz:size">
				<xsl:with-param name="value" select="."/>
				<xsl:with-param name="base"  select="1000"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="c1024">
			<xsl:call-template name="sz:size">
				<xsl:with-param name="value" select="."/>
				<xsl:with-param name="base"  select="1024"/>
				<xsl:with-param name="obase" select="1000"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="str:align(., str:padding(30, ' '), 'right')"/>
		<xsl:text>: </xsl:text>
		<xsl:value-of select="str:align($b1000, str:padding(15, ' '), 'left')"/>
		<xsl:value-of select="str:align($b1024, str:padding(15, ' '), 'left')"/>
		<xsl:value-of select="str:align($c1024, str:padding(15, ' '), 'left')"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>

</xsl:stylesheet>

