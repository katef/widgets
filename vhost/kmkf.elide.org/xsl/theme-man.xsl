<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings"
	xmlns:set="http://exslt.org/sets"
	xmlns:common="http://exslt.org/common"

	extension-element-prefixes="func str"

	exclude-result-prefixes="h func str">

	<xsl:import href="../../../xsl/theme.xsl"/>
	<xsl:import href="../../../xsl/img.xsl"/>
	<xsl:import href="theme.xsl"/>

	<!-- TODO: path from httpd as param -->
	<xsl:variable name="manindex" select="document('../../../var/kmkf-man/index.xhtml5')"/>

	<func:function name="str:trim">
		<xsl:param name="string"/>

		<!-- XXX: this is not really triming; inter-token whitespace needs preservation -->
		<func:result select="str:concat(str:tokenize($string))"/>
	</func:function>

	<func:function name="str:tolower">
		<xsl:param name="s"/>

		<xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
		<xsl:variable name="lower" select="'abcdefghijlkmnopqrstuvwxyz'"/>

		<func:result select="translate($s, $upper, $lower)"/>
	</func:function>

	<xsl:template name="submenu-top">
		<xsl:param name="page-vol"/>
		<xsl:param name="page-productname"/>

		<ul>
			<xsl:for-each select="set:distinct($manindex/h:html/h:body//h:dd/@data-productname)">
				<xsl:sort select="."/>

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

	<xsl:template match="h:a" mode="submenu">
		<xsl:param name="page-title"/>

		<li>
			<!-- XXX: i don't like the h:span child here, which has surrounding whitespace -->
			<xsl:if test="str:contains-word($page-title, str:trim(.))">
				<xsl:attribute name="class">
					<xsl:text>current</xsl:text>
				</xsl:attribute>
			</xsl:if>

			<xsl:copy-of select="."/>
		</li>
	</xsl:template>

	<xsl:template name="submenu-bottom">
		<xsl:param name="page-productname"/>
		<xsl:param name="page-title" select="false()"/>

		<!-- first, ones with no role, for the currently visible product -->
		<ul class="small">
			<xsl:apply-templates select="$manindex/h:html/h:body
				/h:section
				/h:dl/h:dt[@data-productname = $page-productname]
				/h:a" mode="submenu">
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

	<xsl:template match="/h:html">
		<xsl:call-template name="kmkf-output">
			<xsl:with-param name="class">
				<xsl:value-of select="concat(@class, ' typical man')"/>
			</xsl:with-param>

			<xsl:with-param name="page">
				<xsl:apply-templates select="h:head/h:title" mode="body"/>
			</xsl:with-param>

			<xsl:with-param name="site">
				<xsl:text>Bubblephone</xsl:text>
			</xsl:with-param>

			<xsl:with-param name="meta">
				<xsl:variable name="manvolnum"   select="h:head/h:meta[@name = 'refmeta-manvolnum']"/>
				<xsl:variable name="productname" select="h:head/h:meta[@name = 'refmeta-productname']"/>
				<xsl:variable name="refname"     select="h:head/h:meta[@name = 'refmeta-refname']"/>

				<xsl:if test="not(str:contains-word(@class, 'manindex'))">
					<nav class="submenu">
						<xsl:call-template name="submenu-top">
							<xsl:with-param name="page-vol"         select="$manvolnum/@content"/>
							<xsl:with-param name="page-productname" select="$productname/@content"/>
						</xsl:call-template>

						<xsl:if test="$manvolnum and $productname and $refname">
							<hr/>

							<xsl:call-template name="submenu-bottom">
								<xsl:with-param name="page-productname" select="$productname/@content"/>
								<xsl:with-param name="page-title"       select="$refname/@content"/>
							</xsl:call-template>
						</xsl:if>
					</nav>
				</xsl:if>
			</xsl:with-param>

			<xsl:with-param name="body">
				<xsl:choose>
					<xsl:when test="str:contains-word(@class, 'manindex')">
						<xsl:for-each select="set:distinct($manindex/h:html/h:body//h:dd/@data-productname)">
<!-- XXX: count(), not string-length() -->
							<xsl:sort select="string-length(.)"/>

							<section>
								<h1>
									<xsl:value-of select="."/>
								</h1>

<!-- XXX: therefore all index pages should have a <nav> wrapper.
inherit spacing from nav.submenu, but not block cursor -->
								<nav class="submenu">
									<xsl:call-template name="submenu-bottom">
										<xsl:with-param name="page-productname" select="."/>
									</xsl:call-template>
								</nav>
							</section>
						</xsl:for-each>
					</xsl:when>

					<xsl:otherwise>
						<header id="bp-doctitle">
							<h1>
								<xsl:variable name="productname" select="h:head/h:meta[@name = 'refmeta-productname']/@content"/>
								<xsl:variable name="productrole" select="h:head/h:meta[@name = 'refmeta-productrole']/@content"/>
								<xsl:variable name="title"       select="h:head/h:meta[@name = 'refmeta-title']/@content"/>
								<xsl:variable name="pre"         select="substring-before($title, ' ')"/>
								<xsl:variable name="post"        select="substring-after ($title, ' ')"/>

								<xsl:choose>
									<xsl:when test="$productrole and $pre = $productname">
										<xsl:value-of select="$productrole"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$pre"/>
									</xsl:otherwise>
								</xsl:choose>

								<span>
									<xsl:value-of select="$post"/>
								</span>
							</h1>

							<h2>
								<xsl:apply-templates select="h:head/h:title" mode="body"/>
							</h2>
						</header>

						<xsl:apply-templates select="h:body/node()|h:body/text()|h:body/processing-instruction()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

