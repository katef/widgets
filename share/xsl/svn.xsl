<?xml version="1.0"?>

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tl="http://xml.elide.org/timeline"
	xmlns:str="http://exslt.org/strings"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:svn="http://xml.elide.org/svn"
	xmlns:common="http://exslt.org/common"
	xmlns="http://www.w3.org/1999/xhtml"

	extension-element-prefixes="str date common">

	<xsl:output indent="yes"/>

	<xsl:template match="path[../path[@copyfrom-path = current()]]"/>

	<xsl:template name="svn:pathlink">
		<xsl:param name="prefix"/>
		<xsl:param name="path"/>
		<xsl:param name="action"/>
		<xsl:param name="kind"/>

		<a class="svn-{$action} svn-{$kind}" href="#TODO">
			<xsl:choose>
				<xsl:when test="$prefix and starts-with($path, $prefix)">
					<xsl:value-of select="substring($path,
						string-length($prefix) + 1,
						string-length($path))"/>
				</xsl:when>

				<xsl:otherwise>
					<xsl:value-of select="$path"/>
				</xsl:otherwise>
			</xsl:choose>
		</a>
	</xsl:template>

	<xsl:template match="path">
		<xsl:param name="prefix" select="false()"/>

		<li>
			<xsl:if test="@copyfrom-path">
				<xsl:attribute name="class">
					<xsl:text>copy</xsl:text>
				</xsl:attribute>

				<xsl:variable name="action">
					<xsl:choose>
<!-- TODO: distinguish copy from move? -->
<!-- TODO: if several copies were made, show the origional being deleted -->
						<xsl:when test="@action = 'A'">
							<xsl:value-of select="'R'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@action"/> <!-- destination -->
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:call-template name="svn:pathlink">
					<xsl:with-param name="prefix" select="$prefix"/>
					<xsl:with-param name="path"   select="@copyfrom-path"/>
					<xsl:with-param name="action" select="$action"/>
					<xsl:with-param name="kind"   select="@kind"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:call-template name="svn:pathlink">
				<xsl:with-param name="prefix" select="$prefix"/>
				<xsl:with-param name="path"   select="."/>
				<xsl:with-param name="action" select="@action"/>
				<xsl:with-param name="kind"   select="@kind"/>
			</xsl:call-template>
		</li>
	</xsl:template>

	<xsl:template name="prefix">
		<xsl:param name="prefixes"/>
		<xsl:param name="paths"/>

		<xsl:variable name="prefix">
			<xsl:value-of select="common:node-set($prefixes)[1]"/>
		</xsl:variable>

		<xsl:if test="$paths[starts-with(., $prefix)]">
			<dt>
				<a href="#TODO/{$prefix}">
					<xsl:value-of select="$prefix"/>
				</a>
			</dt>

			<dd>
				<ul class="paths">
					<xsl:apply-templates select="$paths[starts-with(., $prefix)]">
						<xsl:sort select="@action"/>
						<xsl:sort select="."/>

						<xsl:with-param name="prefix" select="$prefix"/>
					</xsl:apply-templates>
				</ul>
			</dd>
		</xsl:if>

		<xsl:if test="$paths[not(starts-with(., $prefix))]">
			<xsl:call-template name="prefix">
				<xsl:with-param name="paths"
					select="$paths[not(starts-with(., $prefix))]"/>
				<xsl:with-param name="prefixes"
					select="common:node-set($prefixes)
						[position() &gt; 1]"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="paths">
		<!-- TODO: consider javascript expandy-out fold-down accordion thingy,
			and only show the first 20 paths -->

		<!--
			Here we only want to construct prefixes which are directories,
			which we do by only selecting tokens which have a preceding sibling.
TODO: could possibly use @kind instead?
		-->
		<xsl:variable name="all-prefixes">
			<xsl:for-each select="path">
				<xsl:for-each select="str:tokenize(., '/')
					[position() &lt; 5]">
					[following-sibling::token]">
					<svn:prefix>
						<xsl:text>/</xsl:text>
						<xsl:for-each select="preceding-sibling::token">
							<xsl:value-of select="."/>
							<xsl:text>/</xsl:text>
						</xsl:for-each>
					</svn:prefix>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="uniq-prefixes">
			<xsl:for-each select="common:node-set($all-prefixes)/svn:prefix
				[not(preceding-sibling::svn:prefix = .)]">

				<xsl:sort select="string-length(.)"
					data-type="number" order="descending"/>

				<svn:prefix>
					<xsl:value-of select="."/>
				</svn:prefix>
			</xsl:for-each>
		</xsl:variable>

		<dl class="paths">
			<xsl:call-template name="prefix">
				<xsl:with-param name="prefixes"
					select="common:node-set($uniq-prefixes)/svn:prefix"/>
				<xsl:with-param name="paths"
					select="path"/>
			</xsl:call-template>
		</dl>
	</xsl:template>

	<xsl:template name="log-summary">
		<span class="cite">
			<xsl:value-of select="@revision"/>
		</span>
	</xsl:template>

	<xsl:template match="logentry">
		<xsl:variable name="padding" select="msg
			/text() = 'This is an empty revision for padding.'"/>

		<tl:entry short="{@revision}">
			<xsl:attribute name="class">
				<xsl:text>changelog</xsl:text>
				<xsl:if test="$padding">
					<xsl:text> padding</xsl:text>
				</xsl:if>
			</xsl:attribute>

			<html>
				<head>
					<meta name="author" content="{author}"/>
					<meta name="date"   content="{date}"/>

					<title>
						<xsl:call-template name="log-summary"/>
					</title>
				</head>

				<body>
					<!-- TODO: maybe http://log.libfsm.org/$changeset[/path/in/diff] to show a diff? -->
					<!-- TODO: wiki syntax: how? surely not in xpath... -->
					<!-- TODO: maybe exslt:document them out to .wiki files, and <img/> them in? -->
					<!-- TODO: maybe client-side in javascript -->

					<xsl:choose>
						<xsl:when test="$padding">
							<span class="filler">
								<xsl:text>empty revision for padding</xsl:text>
							</span>
						</xsl:when>
						<xsl:otherwise>
							<aside class="msg">
								<xsl:value-of select="msg"/>
							</aside>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:apply-templates select="paths"/>
				</body>
			</html>

			<xsl:if test="not($padding)">
				<tl:comments/>
			</xsl:if>
		</tl:entry>
	</xsl:template>

	<xsl:template match="/log">
		<tl:timeline>
			<xsl:apply-templates select="logentry">
				<xsl:sort data-type="number" select="date:seconds(date)"
					order="descending"/>
			</xsl:apply-templates>
		</tl:timeline>
	</xsl:template>

</xsl:stylesheet>

