<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:xlink="http://www.w3.org/1999/xlink"

	exclude-result-prefixes="xlink">

	<xsl:output
		method="xml"
		omit-xml-declaration="yes"
		indent="no"/>

	<xsl:template match="comment()"/>
	<xsl:template match="@xml:space"/>
	<xsl:template match="@width"/>
	<xsl:template match="@height"/>
	<xsl:template match="@id"/>

	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>

