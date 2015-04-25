<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:str="http://exslt.org/strings"
	xmlns:set="http://exslt.org/sets"
	xmlns:common="http://exslt.org/common"

	extension-element-prefixes="str"

	exclude-result-prefixes="h str">

	<xsl:import href="string.xsl"/>

	<xsl:template match="h:a" mode="submenu">
		<xsl:param name="page-title"/>

		<xsl:variable name="current" select="str:contains-word($page-title, str:trim(.))"/>

		<li>
			<!-- TODO: i want a better way to do class lists; join() on a space-seperated list. make a classlist() function perhaps -->
			<xsl:if test="$current">
				<xsl:attribute name="class">
					<xsl:text>current</xsl:text>
				</xsl:attribute>
			</xsl:if>

			<!-- XXX: i don't like the h:span child here, which has surrounding whitespace -->
			<xsl:copy-of select="."/>
		</li>
	</xsl:template>

	<xsl:template name="submenu-top">
		<xsl:param name="manindex"/>
		<xsl:param name="page-vol"/>
		<xsl:param name="page-productname"/>

		<ul>
			<xsl:for-each select="set:distinct($manindex/h:html/h:body//h:dd/@data-productname)">
<!--
				<xsl:sort select="."/>
-->

				<li>
					<xsl:if test=". = $page-productname">
						<xsl:attribute name="class">
							<xsl:text>current</xsl:text>
						</xsl:attribute>
					</xsl:if>

					<!-- TODO: hovering over these should conditionally enable each library's pages below -->
					<a>
						<xsl:variable name="first" select="$manindex/h:html/h:body
							//h:dt[@data-productname = current()]
							/h:a[str:tolower(str:trim(.)) = str:tolower(current())][1]/@href"/>

						<xsl:choose>
							<xsl:when test="$first">
								<xsl:copy-of select="$first"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="$manindex/h:html/h:body//h:dt
									[@data-productname = current()][1]/h:a/@href"/>
							</xsl:otherwise>
						</xsl:choose>

						<xsl:value-of select="."/>
					</a>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>

	<xsl:template name="submenu-bottom">
		<xsl:param name="manindex"/>
		<xsl:param name="page-productname"/>
		<xsl:param name="page-title" select="false()"/>

		<xsl:variable name="links" select="$manindex/h:html/h:body
			/h:section
			/h:dl/h:dt[@data-productname = $page-productname]
			/h:a"/>

		<!-- first, ones with no role, for the currently visible product -->
		<ul class="small">
			<xsl:apply-templates select="$links" mode="submenu">
<!--
				<xsl:sort select="."/>
-->
				<xsl:with-param name="page-title" select="$page-title"/>
			</xsl:apply-templates>

			<!-- then iterate over roles, for the currently visible product -->
			<xsl:for-each select="$manindex/h:html/h:body/h:section
				/h:section
				[h:dl/h:dt[@data-productname = $page-productname]]">

				<xsl:variable name="rolelink-id">
					<!-- TODO: centralise somehow -->
					<xsl:if test="../@data-manvolnum = 3 and starts-with(@data-productrole, 'lib')">
						<!-- XXX: i don't like the h:span child here, which has surrounding whitespace -->
						<xsl:value-of select="generate-id(h:dl/h:dt/h:a
							[str:trim(.) = substring(current()/@data-productrole, 4, string-length(current()/@data-productrole))])"/>
					</xsl:if>
				</xsl:variable>

				<li>
					<xsl:if test="str:contains-word($page-title, str:trim(h:dl/h:dt/h:a[generate-id(.) = $rolelink-id]))">
						<xsl:attribute name="class">
							<xsl:text>current</xsl:text>
						</xsl:attribute>
					</xsl:if>

					<xsl:copy-of select="h:dl/h:dt/h:a[generate-id(.) = $rolelink-id]"/>

					<ul class="small">
						<xsl:apply-templates select="$manindex/h:html/h:body
							/h:section/h:section[@data-productrole = current()/@data-productrole]
							/h:dl/h:dt[@data-productname = $page-productname]
							/h:a[generate-id(.) != $rolelink-id]" mode="submenu">
							<xsl:with-param name="page-title" select="$page-title"/>
						</xsl:apply-templates>
					</ul>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>

</xsl:stylesheet>

