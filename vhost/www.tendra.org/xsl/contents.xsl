<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:t="http://xml.tendra.org/www"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	exclude-result-prefixes="t">

	<xsl:template name="t:banner">
		<h1 id="banner">
			<a href="#">
				<xsl:text>The&#160;</xsl:text>
				<span class="logo">
					<xsl:text>Ten</xsl:text>
					<span class="smallcaps">
						<xsl:text>DRA</xsl:text>
					</span>
				</span>
				<xsl:text>&#160;Project</xsl:text>
			</a>
		</h1>
	</xsl:template>

	<t:sections>
		<t:section href="#" name="About">
			<t:subsection href="#" name="Introduction"/>
			<t:subsection href="#" name="Status"/>
			<t:subsection href="#" name="History"/>
			<t:subsection href="#" name="People"/>
			<t:subsection href="#" name="Contact"/>
			<t:subsection href="#" name="Licences"/>
		</t:section>

		<t:section href="#" name="Blog"/>

		<t:section href="#" name="Wiki"/>

		<t:section href="#" name="Documentation">
			<t:subsection href="#" name="User&#160;guides"/>
			<t:subsection href="#" name="Developer&#160;Guides"/>
			<t:subsection href="#" name="Reference"/>
			<t:subsection href="#" name="Manual&#160;Pages"/>
			<t:sep/>
			<t:subsection href="#" name="Bibliography"/>
			<t:subsection href="#" name="Glossary"/>
			<t:subsection href="#" name="FAQ"/>
		</t:section>

		<t:section href="#" name="Projects">
			<t:subsection href="#" name="TCC"                 desc="UI"/>
			<t:subsection href="#" name="DRA&#160;Producers"  desc="C/C++&#160;&#x2192;&#160;TDF"/>
			<t:subsection href="#" name="DRA&#160;Installers" desc="TDF&#160;&#x2192;&#160;asm"/>
			<t:sep/>
			<t:subsection href="#" name="TLD"            desc="TDF&#160;Linker"/>
			<t:subsection href="#" name="TNC"            desc="TNC&#160;&#x2194;&#160;TDF"/>
			<t:subsection href="#" name="TPL"            desc="PL_TDF&#160;&#x2192;&#160;TDF"/>
			<t:subsection href="#" name="disp"           desc="TDF&#160;&#x2192;&#160;ASCII"/>
			<t:sep/>
			<t:subsection href="#" name="SID"            desc="Parser&#160;generator"/>
			<t:subsection href="#" name="Lexi"           desc="Lexer&#160;generator"/>
			<t:subsection href="#" name="Calculus"       desc="Type&#160;generator"/>
			<t:subsection href="#" name="Tspec"          desc="API&#160;generator"/>
			<t:subsection href="#" name="make_err"       desc="Error&#160;generator"/>
			<t:subsection href="#" name="make_tdf"       desc="TDF&#160;I/O&#160;generator"/>
		</t:section>

		<t:section href="#" name="Development">
			<t:subsection href="#" name="Tickets"/>
			<t:subsection href="#" name="Timeline"/>
			<t:subsection href="#" name="Revision&#160;Log"/>
			<t:subsection href="#" name="Browse&#160;Source"/>
			<t:subsection href="#" name="Automated&#160;Builds"/>
		</t:section>

		<t:section href="#" name="Downloads"/>
	</t:sections>

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
		<menu class="expandable collapsed">
			<xsl:apply-templates select="document('')//t:sections/t:section"/>
		</menu>
	</xsl:template>

</xsl:stylesheet>

