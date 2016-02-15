<?xml version="1.0"?>

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tl="http://xml.elide.org/timeline"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:str="http://exslt.org/strings"
	xmlns:svn="http://xml.elide.org/svn"
	xmlns:common="http://exslt.org/common"

	extension-element-prefixes="str common">

	<xsl:output indent="yes"/>

	<xsl:template match="path">
		<xsl:param name="prefix" select="false()"/>

		<h:li class="svn-{@action} svn-{@kind}">
			<h:a href="#TODO">
				<xsl:choose>
					<xsl:when test="$prefix">
						<xsl:value-of select="substring(.,
							string-length($prefix) + 1,
							string-length(.))"/>
					</xsl:when>

					<xsl:otherwise>
						<xsl:value-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</h:a>
		</h:li>
	</xsl:template>

	<xsl:template name="prefix">
		<xsl:param name="prefixes"/>
		<xsl:param name="paths"/>

		<xsl:variable name="prefix">
			<xsl:value-of select="common:node-set($prefixes)[1]"/>
		</xsl:variable>

		<xsl:if test="$paths[starts-with(., $prefix)]">
			<h:dt>
				<h:a href="#TODO/{$prefix}">
					<xsl:value-of select="$prefix"/>
				</h:a>
			</h:dt>

			<h:dd>
				<h:ul class="paths">
					<xsl:apply-templates select="$paths[starts-with(., $prefix)]">
						<xsl:sort select="concat(@action, .)"/>

						<xsl:with-param name="prefix" select="$prefix"/>
					</xsl:apply-templates>
				</h:ul>
			</h:dd>
		</xsl:if>

		<xsl:if test="$paths">
			<xsl:call-template name="prefix">
				<xsl:with-param name="paths"
					select="$paths
						[not(starts-with(., common:node-set($prefixes)[1]))]"/>
				<xsl:with-param name="prefixes"
					select="common:node-set($prefixes)
						[position() &gt; 1]"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="paths">
		<!-- TODO: consider javascript expandy-out fold-down accordion thingy,
			and only show the first 20 paths -->

		<xsl:variable name="paths" select="path"/>

		<!--
			Here we only want to construct prefixes which are directories,
			which we do by only selecting tokens which have a preceding sibling.
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

		<h:dl class="paths">
			<xsl:call-template name="prefix">
				<xsl:with-param name="prefixes"
					select="common:node-set($uniq-prefixes)/svn:prefix"/>
				<xsl:with-param name="paths"
					select="path"/>
			</xsl:call-template>
		</h:dl>
	</xsl:template>

	<xsl:template name="log-summary">
		<h:a class="summary" href="#TODO">
			<h:span class="rev">
				<xsl:text>[</xsl:text>
				<xsl:value-of select="@revision"/>
				<xsl:text>]</xsl:text>
			</h:span>
		</h:a>
	</xsl:template>

	<xsl:template name="log-languages">
		<xsl:variable name="all-extensions">
			<xsl:for-each select="paths/path">
				<xsl:variable name="file"
					select="str:tokenize(., '/')
						[position() = last()]"/>

				<xsl:if test="contains($file, '.') and not(starts-with($file, '.'))">
					<xsl:variable name="ext"
						select="str:tokenize($file, '.')
							[position() = last()]"/>

					<xsl:choose>
						<xsl:when test="$ext = 'org'"/>
						<xsl:when test="$ext = 'inc'"/>

						<xsl:when test="$ext = 'h'">
							<svn:ext>
								<xsl:text>c</xsl:text>
							</svn:ext>
						</xsl:when>

						<xsl:when test="$ext = 'lct'">
							<svn:ext>
								<xsl:text>lxi</xsl:text>
							</svn:ext>
						</xsl:when>

						<xsl:when test="$ext = 'act'">
							<svn:ext>
								<xsl:text>sid</xsl:text>
							</svn:ext>
						</xsl:when>

						<xsl:otherwise>
							<svn:ext>
								<xsl:value-of select="$ext"/>
							</svn:ext>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="uniq-extensions">
			<xsl:for-each select="common:node-set($all-extensions)/svn:ext
				[not(preceding-sibling::svn:ext = .)]">

				<xsl:sort select="."/>

				<svn:ext>
					<xsl:value-of select="."/>
				</svn:ext>
			</xsl:for-each>
		</xsl:variable>

		<xsl:for-each select="common:node-set($uniq-extensions)/svn:ext">
			<xsl:if test="position() != 1">
				<xsl:text>, </xsl:text>
			</xsl:if>

			<xsl:choose>
				<xsl:when test=". = 'css'">
					<abbr>
						<xsl:text>CSS</xsl:text>
					</abbr>
				</xsl:when>

				<xsl:when test=". = 'mk'">
					<xsl:text>Make</xsl:text>
				</xsl:when>

				<xsl:when test=". = 'c'">
					<xsl:text>C</xsl:text>
				</xsl:when>

				<xsl:when test=". = 'js'">
					<xsl:text>Javascript</xsl:text>
				</xsl:when>

				<xsl:when test=". = 'sid'">
					<xsl:text>SID</xsl:text>
				</xsl:when>

				<xsl:when test=". = 'lxi'">
					<xsl:text>Lexi</xsl:text>
				</xsl:when>

				<xsl:when test=". = 'xsl'">
					<xsl:text>XSLT</xsl:text>
				</xsl:when>

				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:if test="position() = last()">
				<xsl:text>.</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="log-category">
		<xsl:choose>
			<xsl:when test="paths/path[starts-with(., '/tags/')]">
				<xsl:text>Release</xsl:text>
			</xsl:when>

			<xsl:when test="paths/path[starts-with(., '/trunk/doc/')]">
				<xsl:text>Documentation</xsl:text>
			</xsl:when>

			<xsl:when test="paths/path[starts-with(., '/trunk/share/mk/')]">
				<xsl:text>Build system</xsl:text>
			</xsl:when>

			<xsl:when test="paths/path[starts-with(., '/trunk/share/')]">
				<xsl:text>Document processing</xsl:text>
			</xsl:when>

			<xsl:when test="paths/path[starts-with(., '/trunk/tests/')]">
				<xsl:text>Tests</xsl:text>
			</xsl:when>

			<xsl:when test="paths/path[starts-with(., '/trunk/examples/')]">
				<xsl:text>Examples</xsl:text>
			</xsl:when>

			<xsl:when test="paths/path[starts-with(., '/trunk/src/include/')
				or starts-with(., '/libfsm/trunk/src/include/')
				or starts-with(., '/libre/trunk/src/include/')]">
				<xsl:text>API</xsl:text>
			</xsl:when>

			<xsl:when test="paths/path[starts-with(., '/trunk/src/')
				or starts-with(., '/libfsm/trunk/src/')
				or starts-with(., '/libre/trunk/src/')]">
				<xsl:text>Source</xsl:text>
			</xsl:when>

			<xsl:when test="paths/path[starts-with(., '/www/blog/')]">
				<xsl:text>Blog entry</xsl:text>
			</xsl:when>

			<xsl:when test="paths/path[starts-with(., '/www/')]">
				<xsl:text>Website</xsl:text>
			</xsl:when>

			<xsl:otherwise>
				<xsl:text>Miscellaneous</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="logentry">
		<tl:entry short="{@revision}">
			<h:html>
				<h:head>
					<h:meta name="author" content="{author}"/>
					<h:meta name="date"   content="{date}"/>

					<h:title>
						<xsl:call-template name="log-summary"/>
					</h:title>
				</h:head>

				<h:body>
					<!-- TODO: maybe http://log.libfsm.org/$changeset[/path/in/diff] to show a diff? -->

<!-- TODO: i don't think i need any of this
					<h:ul class="meta">
						<h:li>
							<xsl:call-template name="log-category"/>
						</h:li>

						<h:li>
							<xsl:text>Languages:&#xA0;</xsl:text>
							<xsl:call-template name="log-languages"/>
						</h:li>

						<h:li>
							<xsl:text>By&#xA0;</xsl:text>
							<xsl:value-of select="author"/>
							<xsl:text>.</xsl:text>
						</h:li>
					</h:ul>
-->

					<!-- TODO: wiki syntax: how? surely not in xpath... -->
					<!-- TODO: maybe exslt:document them out to .wiki files, and <img/> them in? -->
					<!-- TODO: maybe client-side in javascript -->

					<xsl:apply-templates select="paths"/>

					<h:aside class="msg">
						<xsl:value-of select="msg"/>
					</h:aside>
				</h:body>
			</h:html>

			<tl:comments/>
		</tl:entry>
	</xsl:template>

	<xsl:template match="/log">
		<!-- TODO: mod_kxslt to get QUERY_STRING and only show interesting paths;
			select where starts-with() the relevant prefix
			(/www/blog, /www in general, /tags, /trunk/src, /trunk/doc, etc. maybe overkill) -->
		<tl:timeline>
			<xsl:apply-templates select="logentry"/>
<!-- TODO: sort by date! -->
		</tl:timeline>
	</xsl:template>

</xsl:stylesheet>

