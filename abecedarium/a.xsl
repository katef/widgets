<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="/a">
		<html>
			<head>
				<title>Alfabetet</title>
				<link rel="stylesheet" href="alfabetet.css" type="text/css"/>
				<meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
			</head>

			<body>
				<div id="help">&#x25C2; Hover over these</div>

				<ul>
					<xsl:apply-templates select="lang"/>
				</ul>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="lang">
		<xsl:apply-templates select="@uni"/>
		<xsl:apply-templates select="@upper"/>
		<xsl:apply-templates select="@lower"/>
	</xsl:template>

	<xsl:template match="@upper|@lower|@uni">
		<li class="{name()}">
			<span class="lang">
				<xsl:choose>
					<xsl:when test="name() != 'lower'">
						<xsl:value-of select="translate(substring(../@name, 1, 1),
						                                'abcdefghijklmnopqrstuvwxyz',
						                                'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
						<xsl:value-of select="substring(../@name, 2, string-length(../@name))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="../@name"/>
					</xsl:otherwise>
				</xsl:choose>
			</span>

			<ol>
				<xsl:call-template name="letter"/>
			</ol>
		</li>
	</xsl:template>

	<xsl:template name="letter">
		<xsl:param name="index"  select="1"/>
		<xsl:param name="letter">
			<xsl:choose>
				<xsl:when test="substring(., $index, 1) = '|'">
					<xsl:value-of select="substring(., $index,
						string-length(substring-before(substring(., $index + 1) , '|')) + 2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring(., $index, 1)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>

		<li>
			<xsl:choose>
				<xsl:when test="contains(../@vowels, $letter)">
					<xsl:attribute name="class">
						<xsl:text>vowel</xsl:text>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="contains(../@loan, $letter)">
					<xsl:attribute name="class">
						<xsl:text>loan</xsl:text>
					</xsl:attribute>
				</xsl:when>
			</xsl:choose>

			<xsl:choose>
				<xsl:when test="contains($letter, '/')">
					<xsl:value-of select="substring-before(translate($letter, '|', ''), '/')"/>
					<small>
						<xsl:text>&#160;</xsl:text>
						<xsl:value-of select="substring-after(translate($letter, '|', ''), '/')"/>
					</small>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="translate($letter, '|', '')"/>
				</xsl:otherwise>
			</xsl:choose>
		</li>

		<xsl:if test="$index &lt; string-length(.)">
			<xsl:call-template name="letter">
				<xsl:with-param name="index" select="$index + string-length($letter)"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>

