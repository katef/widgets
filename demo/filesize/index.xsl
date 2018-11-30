<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings"
	xmlns:sz="http://xml.elide.org/filesize"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:d="http://xml.elide.org/sizes-demo"

	exclude-result-prefixes="d sz str">

	<xsl:import href="filesize.xsl"/>

	<xsl:output indent="yes" method="xml" encoding="utf-8"
		cdata-section-elements="script"
		media-type="application/xhtml+xml"

		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>

	<d:demo>
		<d:size value="0"/>
		<d:size value="1"/>
		<d:size value="10"/>
		<d:size value="12"/>
		<d:size value="123"/>
		<d:size value="1234"/>
		<d:size value="12345"/>
		<d:size value="12340"/>
		<d:size value="12300"/>
		<d:size value="12300"/>
		<d:size value="12000"/>
		<d:size value="120000"/>
		<d:size value="100000"/>
		<d:size value="1000000"/>
		<d:size value="1234567"/>
		<d:size value="12345678"/>
		<d:size value="123456789"/>
		<d:size value="1234567891"/>
		<d:size value="12345678912"/>
		<d:size value="123456789123"/>
		<d:size value="1234567891234"/>
		<d:size value="12345678912345"/>
		<d:size value="123456789123456"/>
		<d:size value="1234567891234567"/>
		<d:size value="12345678912345678"/>
		<d:size value="123456789123456789"/>
		<d:size value="1234567891234567891"/>
		<d:size value="12345678912345678912"/>
		<d:size value="123456789123456789123"/>
		<d:size value="1234567891234567891234"/>
	</d:demo>

	<xsl:template match="/">
		<html>
			<head>
				<title>Kate&#x2019;s Web Widgets &#x2014; XSLT file sizes</title>

				<link rel="stylesheet" href="filesize.css"/>
			</head>

			<body>
				<p>
					<xsl:text>Here's what it does:</xsl:text>
				</p>

				<table>
					<xsl:apply-templates select="//@value"/>
				</table>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="@value">
		<tr>
			<td>
				<tt>
					<xsl:value-of select="."/>
				</tt>
			</td>

			<td>
				<tt>
					<xsl:call-template name="sz:size">
						<xsl:with-param name="value" select="."/>
					</xsl:call-template>
				</tt>
			</td>

			<td>
				<tt>
					<xsl:call-template name="sz:size">
						<xsl:with-param name="value" select="."/>
						<xsl:with-param name="base"  select="1000"/>
					</xsl:call-template>
				</tt>
			</td>

			<td>
				<tt>
					<xsl:call-template name="sz:size">
						<xsl:with-param name="value" select="."/>
						<xsl:with-param name="base"  select="1024"/>
						<xsl:with-param name="obase" select="1000"/>
					</xsl:call-template>
				</tt>
			</td>
		</tr>
	</xsl:template>

</xsl:stylesheet>

