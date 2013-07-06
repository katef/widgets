<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:t="http://xml.tendra.org/www"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	exclude-result-prefixes="t">

	<!--
		TODO: title attributes for all <a/> links
	-->

	<t:sections>
		<t:section href="http://www.tendra.org/" name="About">
			<t:subsection href="#" name="Introduction"/>
			<t:subsection href="#" name="Status"/>
			<t:subsection href="#" name="History"/>
			<t:subsection href="http://www.tendra.org/people/" name="People"/>
			<t:subsection href="#" name="Contact"/>
			<t:subsection href="#" name="Licences"/>
		</t:section>

		<t:section href="http://blog.tendra.org/" name="Blog"/>

		<t:section href="http://wiki.tendra.org/" name="Wiki"/>

		<t:section href="http://docs.tendra.org/" name="Documentation">
			<t:subsection href="http://docs.tendra.org/user/" name="User&#160;Guides"/>
			<t:subsection href="http://docs.tendra.org/dev/"  name="Developer&#160;Guides"/>
			<t:subsection href="http://docs.tendra.org/ref/"  name="Reference"/>
			<t:subsection href="http://man.tendra.org/"       name="Manual&#160;Pages"/>
			<t:sep/>
			<t:subsection href="#" name="Bibliography"/>
			<t:subsection href="http://docs.tendra.org/glossary/" name="Glossary"/>
			<t:subsection href="http://docs.tendra.org/faq/"      name="FAQ"/>
		</t:section>

<!-- TODO: do we need these?
		<t:section href="#" name="Projects">
			<t:subsection href="#" name="TCC"                 desc="UI"/>
			<t:subsection href="#" name="DRA&#160;Producers"  desc="C/C++&#160;&#x2192;&#160;TDF"/>
			<t:subsection href="#" name="DRA&#160;Installers" desc="TDF&#160;&#x2192;&#160;asm"/>
			<t:sep/>
			<t:subsection href="#" name="TLD"                 desc="TDF&#160;Linker"/>
			<t:subsection href="#" name="TNC"                 desc="TNC&#160;&#x2194;&#160;TDF"/>
			<t:subsection href="#" name="TPL"                 desc="PL_TDF&#160;&#x2192;&#160;TDF"/>
			<t:subsection href="#" name="disp"                desc="TDF&#160;&#x2192;&#160;ASCII"/>
			<t:sep/>
			<t:subsection href="#" name="SID"                 desc="Parser&#160;generator"/>
			<t:subsection href="#" name="Lexi"                desc="Lexer&#160;generator"/>
			<t:subsection href="#" name="Calculus"            desc="Type&#160;generator"/>
			<t:subsection href="#" name="Tspec"               desc="API&#160;generator"/>
			<t:subsection href="#" name="make_err"            desc="Error&#160;generator"/>
			<t:subsection href="#" name="make_tdf"            desc="TDF&#160;I/O&#160;generator"/>
		</t:section>
-->

		<t:section href="http://dev.tendra.org/" name="Development">
			<t:subsection href="http://tickets.tendra.org/" name="Tickets"/>
			<t:subsection href="http://source.tendra.org/"  name="Browse&#160;Source"/>
			<t:sep/>
			<t:subsection href="http://builds.tendra.org/" name="Automated&#160;Builds"/>
			<t:subsection href="http://api.tendra.org/"    name="API&#160;Coverage"/>
			<t:subsection href="http://pmcc.tendra.org/"   name="Cyclomatic&#160;complexity"/>
			<t:sep/>
			<t:subsection href="http://dev.tendra.org/timeline/" name="Timeline"/>
			<t:subsection href="#" name="Revision&#160;Log"/>
			<t:subsection href="http://rss.tendra.org/"    name="RSS&#160;Feeds"/>
		</t:section>

		<t:section href="http://www.tendra.org/download/" name="Downloads"/>
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

			<a href="{@href}">
				<xsl:value-of select="@name"/>
				<xsl:apply-templates select="@desc"/>
			</a>
		</li>
	</xsl:template>

	<xsl:template match="t:section">
		<li>
			<xsl:if test="@name = 'Documentation'">	<!-- TODO: get from mod_kxslt or somesuch -->
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

	<xsl:template name="t:sections-menu">
		<ul class="sections">
			<xsl:apply-templates select="document('')//t:sections/t:section"/>
		</ul>
	</xsl:template>

</xsl:stylesheet>

