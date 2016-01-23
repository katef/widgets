<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="processing-instruction('img')">
		<xsl:if test="not(starts-with(., 'src=&quot;'))">
			<xsl:message terminate="yes">
				<xsl:text>PI syntax error: expected </xsl:text>
				<xsl:text>&lt;?img src="file.png"?&gt;</xsl:text>
				<xsl:text>, got </xsl:text>
				<xsl:text>&lt;?img </xsl:text>
				<xsl:value-of select="."/>
				<xsl:text>?&gt;</xsl:text>
			</xsl:message>
		</xsl:if>

		<xsl:variable name="src" select="substring(., 6, string-length(.) - 6)"/>

		<!-- TODO: handle svg etc by filetype -->
		<a href="{$src}">
			<!-- TODO: alt="" -->
			<img src="{$src}"/>
		</a>
	</xsl:template>

</xsl:stylesheet>

