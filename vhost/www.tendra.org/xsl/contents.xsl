<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:t="http://xml.tendra.org/www"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	exclude-result-prefixes="t">

	<xsl:template match="t:subsection/@desc">
		<span class="description">
			<xsl:value-of select="."/>
		</span>
	</xsl:template>

	<xsl:template match="t:subsection">
		<li>
			<!-- TODO: hilight current item -->
			<xsl:if test="local-name(following-sibling::*[1]) = 'sep'">
				<xsl:attribute name="class">
					<xsl:text>sep</xsl:text>
				</xsl:attribute>
			</xsl:if>

			<a class="menu" href="{@href}">
				<xsl:if test="@rel">
					<xsl:attribute name="rel">
						<xsl:value-of select="@rel"/>
					</xsl:attribute>
				</xsl:if>

				<xsl:value-of select="@name"/>
				<xsl:apply-templates select="@desc"/>
			</a>
		</li>
	</xsl:template>

	<xsl:template match="t:section">
		<li>
			<xsl:if test="@name = 'Blog'">	<!-- TODO: get from mod_kxslt or somesuch -->
				<xsl:attribute name="class">
					<xsl:text>current</xsl:text>
				</xsl:attribute>
			</xsl:if>

			<a href="{@href}">
				<xsl:if test="@rel">
					<xsl:attribute name="rel">
						<xsl:value-of select="@rel"/>
					</xsl:attribute>
				</xsl:if>

				<xsl:value-of select="@name"/>
			</a>

			<xsl:if test="t:subsection">
				<ul>
					<xsl:if test="t:subsection/@desc">
						<xsl:attribute name="style">
							<xsl:text>width: 18em;</xsl:text>
						</xsl:attribute>
					</xsl:if>

					<xsl:apply-templates select="t:subsection"/>
				</ul>
			</xsl:if>
		</li>
	</xsl:template>

	<!-- TODO: rename contents -->
	<xsl:template name="t:sections-menu">
		<nav role="navigation" class="expandable collapsed">
			<ul>
				<xsl:apply-templates select="document('contents.xml')/t:sections/t:section"/>
			</ul>
		</nav>
	</xsl:template>

</xsl:stylesheet>

