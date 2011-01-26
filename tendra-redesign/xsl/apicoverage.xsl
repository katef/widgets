<?xml version="1.0"?>

<!-- $Id$ -->

<!--
	API Coverage. This reports the presence of each API symbol specified for
	each system which implements that API.
-->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
	xmlns:d="http://xml.tendra.org/dump"
	xmlns:s="http://xml.tendra.org/specs"
	xmlns:i="http://xml.tendra.org/impls"
	xmlns:o="http://xml.tendra.org/osdepcov"
	xmlns:t="http://xml.tendra.org/tokdef"
	xmlns:c="http://xml.tendra.org/coverage"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:func="http://exslt.org/functions"

	extension-element-prefixes="func"

	version='1.0'>

	<xsl:output
		method="xml"
		version="1.0"
		encoding="utf-8"
		omit-xml-declaration="no"
		standalone="yes"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		indent="yes"
		media-type="screen"/>

	<!-- TODO: call coverage.something -->
	<xsl:param name="dump.inlineextensions" select="false()"/>
	<xsl:param name="coverage.api" select="false()"/>

	<xsl:param name="tendra.url.www" select="'http://www.tendra.org'"/>
	<xsl:param name="tendra.url.api" select="'http://api.tendra.org'"/>

	<func:function name="c:isprivate">
		<xsl:param name="name"/>
		<xsl:param name="key" select="''"/>

		<func:result select="$name = ''
				or  starts-with($name, '__')
				or (starts-with($name, '__TDF_') and $key = 'MO')
				or (starts-with($name, '__')     and $key = 'MB')"/>
	</func:function>

	<func:function name="c:ispublic">
		<xsl:param name="name"/>
		<xsl:param name="key" select="''"/>

		<func:result select="not(c:isprivate($name, $key))"/>
	</func:function>

	<func:function name="c:isinimpl">
		<xsl:param name="os"/>
		<xsl:param name="cpu"/>
		<xsl:param name="ver"/>
		<xsl:param name="api"/>
		<xsl:param name="symbol"/>
		<xsl:param name="parent"/>

		<func:result select="/o:osdepcov/i:impls/i:os
			[@os = $os]/i:cpu[@cpu = $cpu]/i:ver[@ver = $ver]
		        /i:impl/t:tokens/t:token[@api = $api][@symbol = $symbol][not($parent) or (@parent = $parent)]"/>
	</func:function>

	<func:function name="c:isinapi">
		<xsl:param name="targetapi"/>
		<xsl:param name="api"/>
		<xsl:param name="symbol"/>
		<xsl:param name="parent"/>

		<func:result select="(/o:osdepcov/s:specs/d:dump/d:api[substring-before(@name, '.') = $targetapi]//d:defn
                             |/o:osdepcov/s:specs/d:dump/d:api[substring-before(@name, '.') = $targetapi]//d:decl)
                                 [@name = $symbol][@api = $api][not(@parent_type) or (@parent_type = $parent)]"/>
	</func:function>


	<c:prefixes>
		<c:prefix key="TS" value="struct"/>
		<c:prefix key="TU" value="union"/>
		<c:prefix key="TE" value="enum"/>
		<c:prefix key="TC" value="class"/>
		<c:prefix key="TA" value="typedef"/>
		<c:prefix key="FS" value="static"/>
		<c:prefix key="M"  value="#define"/>
	</c:prefixes>

	<c:postfixes>
		<c:postfix key="F"  value="()"/>
		<c:postfix key="MF" value="()"/>
		<c:postfix key="NN" value="::"/>
		<c:postfix key="NA" value="::"/>
		<c:postfix key="L"  value=":"/>
	</c:postfixes>


	<xsl:template name="prettyname">
		<xsl:variable name="prefix" select="document('')//c:prefixes/c:prefix
			[starts-with(current()/@key, @key)]/@value"/>

		<xsl:variable name="postfix" select="document('')//c:postfixes/c:postfix
			[starts-with(current()/@key, @key)]/@value"/>

		<tt>
			<xsl:if test="$prefix">
				<xsl:value-of select="concat($prefix, '&#xA0;')"/>
			</xsl:if>

			<xsl:if test="@parent_type">
				<xsl:text>.</xsl:text>
			</xsl:if>

			<xsl:value-of select="@name"/>

			<xsl:if test="$postfix">
				<xsl:value-of select="$postfix"/>
			</xsl:if>
		</tt>
	</xsl:template>

	<xsl:template name="prettyapi">
		<xsl:param name="api" select="@api"/>

		<!-- TODO: possibly a javascript-parsed #api.subset in URLs to pre-expand rows? -->
		<tt>
			<xsl:choose>
				<xsl:when test="starts-with(@api, concat($coverage.api, '.'))">
					<xsl:value-of select="@api"/>
				</xsl:when>
				<xsl:otherwise>
					<a href="{$tendra.url.api}/{substring-before(@api, '.')}#{substring-after(@api, '.')}">
						<xsl:value-of select="@api"/>
					</a>
				</xsl:otherwise>
			</xsl:choose>
		</tt>
	</xsl:template>

	<xsl:template name="decl-defn-nametd">
		<td>
			<tt>
				<xsl:value-of select="@key"/>
			</tt>
		</td>
		<xsl:choose>
			<xsl:when test="@parent_type">
				<td>
					<tt>
						<xsl:call-template name="prettyapi">
							<xsl:with-param name="api">
								<xsl:value-of select="/o:osdepcov/s:specs/d:dump/d:api
									[@name = current()/@api]//d:defn
										[@key = 'TS'][@name = current()/@parent_type]/@api"/>
							</xsl:with-param>
						</xsl:call-template>
					</tt>
				</td>
				<td>
					<tt>
						<xsl:value-of select="@parent_type"/>
					</tt>
				</td>
				<td>
					<xsl:call-template name="prettyname"/>
				</td>
			</xsl:when>
			<xsl:when test="@api">
				<td>
					<xsl:call-template name="prettyapi"/>
				</td>
				<td colspan="2">
					<xsl:call-template name="prettyname"/>
				</td>
			</xsl:when>
			<xsl:otherwise>
				<td class="api-error" align="center">
					<!-- e.g. see ansi/stddef.h -->
					<xsl:text>(stray)</xsl:text>
				</td>
				<td colspan="2">
					<xsl:call-template name="prettyname"/>
				</td>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="i:ver" mode="impl">
		<xsl:param name="api"/>
		<xsl:param name="parent"/>
		<xsl:param name="symbol"/>

		<!-- TODO: big empty white box for APIs which are not attempted (i.e. i:imp[@api = $api] is missing -->
		<!-- TODO: also needs to compare token type to the key. possibly give tnc the ability to dump in tccdump(5) format? -->

		<td align="center">
			<xsl:choose>
				<xsl:when test="not(i:impl[@api = substring-before($api, '.')])">
					<xsl:attribute name="class">
						<xsl:text>na</xsl:text>
					</xsl:attribute>

					<xsl:text>&#x2013;</xsl:text>
				</xsl:when>
				<xsl:when test="not($parent) and i:impl[@api = substring-before($api, '.')]/t:tokens/t:token[@api = $api][@symbol = $symbol]">
					<xsl:attribute name="class">
						<xsl:text>api-yes</xsl:text>
					</xsl:attribute>

					<xsl:text>&#x2713;</xsl:text>
				</xsl:when>
				<xsl:when test="i:impl[@api = substring-before($api, '.')]/t:tokens/t:token[@parent = $parent][@symbol = $symbol]">
					<xsl:attribute name="class">
						<xsl:text>api-yes</xsl:text>
					</xsl:attribute>

					<xsl:text>&#x2713;</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">
						<xsl:text>api-no</xsl:text>
					</xsl:attribute>

					<xsl:text>&#x2717;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>

	<xsl:template match="d:api" mode="inherit">
		<tbody>
			<tr>
				<th colspan="3">
					<xsl:text>Extends:</xsl:text>
				</th>
				<td>
					<a href="#{@name}">
						<tt>
							<xsl:value-of select="@name"/>
						</tt>
					</a>
				</td>
			</tr>
		</tbody>
	</xsl:template>

	<xsl:template name="coveragebox">
		<xsl:param name="api"/>
		<xsl:param name="speccount"/>
		<xsl:param name="implcount"/>

		<td align="center">
			<xsl:choose>
				<xsl:when test="not(i:impl[@api = $api])">
					<xsl:attribute name="class">
						<xsl:text>na</xsl:text>
					</xsl:attribute>
					<xsl:text>&#x2013;</xsl:text>
				</xsl:when>

				<xsl:when test="$speccount = 0">
					<xsl:attribute name="class">
						<xsl:text>na</xsl:text>
					</xsl:attribute>
					<xsl:text>N/A</xsl:text>
				</xsl:when>

				<xsl:when test="$implcount = 0">
					<xsl:attribute name="class">
						<xsl:value-of select="'api-no'"/>
					</xsl:attribute>
					<xsl:value-of select="concat($implcount, '/', $speccount)"/>
				</xsl:when>

				<xsl:when test="$implcount &lt; $speccount">
					<xsl:attribute name="class">
						<xsl:text>api-partial</xsl:text>
					</xsl:attribute>
					<xsl:value-of select="concat($implcount, '/', $speccount)"/>
				</xsl:when>

				<xsl:when test="$implcount = $speccount">
					<xsl:attribute name="class">
						<xsl:text>api-yes</xsl:text>
					</xsl:attribute>
					<xsl:value-of select="concat($implcount, '/', $speccount)"/>
				</xsl:when>

				<xsl:when test="$implcount &gt; $speccount">
					<xsl:value-of select="concat('XS: ', $implcount, '/', $speccount)"/>
					<xsl:message terminate="yes">
						<xsl:text>Excess implementation count for </xsl:text>
						<xsl:value-of select="$api"/>
					</xsl:message>
				</xsl:when>
			</xsl:choose>
		</td>
	</xsl:template>

	<xsl:template match="i:os" mode="head-osname">
		<th colspan="{count(i:cpu/i:ver)}">
			<xsl:choose>
				<xsl:when test="@os = 'solaris'">
					<xsl:text>Solaris</xsl:text>
				</xsl:when>
				<xsl:when test="@os = 'haiku'">
					<xsl:text>Haiku</xsl:text>
				</xsl:when>
				<xsl:when test="@os = 'openbsd'">
					<xsl:text>OpenBSD</xsl:text>
				</xsl:when>
				<xsl:when test="@os = 'ubuntu'">
					<xsl:text>Ubuntu</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@os"/>
				</xsl:otherwise>
			</xsl:choose>
		</th>
	</xsl:template>

	<xsl:template match="i:ver" mode="head-osver">
		<td>
			<xsl:value-of select="concat(@ver, '/', ../@cpu)"/>
		</td>
	</xsl:template>

	<xsl:template match="i:ver" mode="foot-osver">
		<xsl:param name="speccount"/>

		<xsl:variable name="os" select="../../@os"/>
		<xsl:variable name="cpu" select="../@cpu"/>
		<xsl:variable name="ver" select="@ver"/>

		<xsl:variable name="implcount" select="count(i:impl/t:tokens/t:token
			[c:ispublic(@symbol)][c:isinapi($coverage.api, @api, @symbol, @parent)])"/>

		<xsl:call-template name="coveragebox">
			<xsl:with-param name="api"       select="$coverage.api"/>
			<xsl:with-param name="speccount" select="$speccount"/>
			<xsl:with-param name="implcount" select="$implcount"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="d:api/@name" mode="summary">
		<xsl:variable name="api" select="."/>

		<xsl:variable name="speccount"
			select="count((/o:osdepcov/s:specs/d:dump/d:api[@name = $api]//d:defn
				          |/o:osdepcov/s:specs/d:dump/d:api[@name = $api]//d:decl)
				[c:ispublic(@name, @key)])"/>

		<tbody>
			<tr>
				<td colspan="5" align="left" class="expandable collapsed" onclick="API.toggle(this, 'api-{$api}')">
					<tt>
						<xsl:value-of select="$api"/>
					</tt>
				</td>

				<xsl:for-each select="/o:osdepcov/i:impls/i:os/i:cpu/i:ver">
					<xsl:variable name="os"  select="../../@os"/>
					<xsl:variable name="cpu" select="../@cpu"/>
					<xsl:variable name="ver" select="@ver"/>

					<xsl:variable name="implcount"
						select="count(/o:osdepcov/s:specs/d:dump/d:api[@name = $api]//d:defn
						                  [c:ispublic(@name, @key)])
						      + count(/o:osdepcov/s:specs/d:dump/d:api[@name = $api]//d:decl
						                  [c:ispublic(@name, @key)]
						                  [c:isinimpl($os, $cpu, $ver, @api, @name, @parent_type)])"/>

					<xsl:call-template name="coveragebox">
						<xsl:with-param name="api"       select="substring-before($api, '.')"/>
						<xsl:with-param name="speccount" select="$speccount"/>
						<xsl:with-param name="implcount" select="$implcount"/>
					</xsl:call-template>
				</xsl:for-each>
			</tr>
		</tbody>

		<tbody id="api-{$api}" class="expandable collapsed">
			<xsl:for-each select="(/o:osdepcov/s:specs/d:dump/d:api[@name = $api]//d:defn
				|/o:osdepcov/s:specs/d:dump/d:api[@name = $api]//d:decl)
					[c:ispublic(@name, @key)]">
				<tr>
					<td class="na">
						<tt>
							<!-- TODO: maybe something other than box-drawing... -->
							<xsl:choose>
								<xsl:when test="position() = last()">
									<xsl:text>&#x2514;</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>&#x251C;</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</tt>
					</td>

					<xsl:call-template name="decl-defn-nametd"/>

					<!--
					   - "portable" means this symbol is portably *implemented*
					   - by the tspec-generated *interface*-defining headers.
					  -->
					<xsl:choose>
						<xsl:when test="name() = 'defn'">
							<td colspan="{count(/o:osdepcov/i:impls/i:os/i:cpu/i:ver)}"
								align="center" class="api-yes">
								<xsl:text>&#x2713;&#xA0;(portable)</xsl:text>
							</td>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="/o:osdepcov/i:impls/i:os/i:cpu/i:ver" mode="impl">
								<xsl:with-param name="api"    select="@api"/>
								<xsl:with-param name="parent" select="@parent_type"/>
								<xsl:with-param name="symbol" select="@name"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</tr>
			</xsl:for-each>
		</tbody>
	</xsl:template>

	<xsl:template name="api-summary">
		<a name="{$coverage.api}"/>

		<table>
			<caption>
				<xsl:value-of select="$coverage.api"/>
			</caption>

			<col align="center"/>
			<col align="center"/>
			<col align="left"/>
			<col align="left"/>
			<col align="left"/>

			<xsl:for-each select="/o:osdepcov/i:impls/i:os/i:cpu/i:ver">
				<col align="center"/>
			</xsl:for-each>

			<thead>
				<tr>
					<th colspan="5" align="left"><acronym><xsl:text>API</xsl:text></acronym></th>

					<xsl:apply-templates select="/o:osdepcov/i:impls/i:os" mode="head-osname"/>
				</tr>

				<tr>
					<td class="na">
						<tt><xsl:text>&#x2514;</xsl:text></tt>
					</td>
					<th align="right"><xsl:text>Key</xsl:text></th>
					<th><xsl:text>Defining API</xsl:text></th>
					<th colspan="2"><xsl:text>Symbol</xsl:text></th>

					<xsl:apply-templates select="/o:osdepcov/i:impls/i:os/i:cpu/i:ver" mode="head-osver"/>
				</tr>
			</thead>

			<xsl:apply-templates select="s:specs/d:dump/d:api/@name[starts-with(., concat($coverage.api, '.'))]" mode="summary">
				<xsl:sort select="."/>
			</xsl:apply-templates>

			<tfoot>
				<tr>
					<td colspan="4" class="noborder"/>
					<th align="right">
						<xsl:text>Total</xsl:text>
					</th>

					<xsl:apply-templates select="/o:osdepcov/i:impls/i:os/i:cpu/i:ver" mode="foot-osver">
						<xsl:with-param name="speccount"
							select="count((/o:osdepcov/s:specs/d:dump/d:api[starts-with(@name, concat($coverage.api, '.'))]//d:defn
			                              |/o:osdepcov/s:specs/d:dump/d:api[starts-with(@name, concat($coverage.api, '.'))]//d:decl)
			                                  [c:ispublic(@name, @key)])"/>
					</xsl:apply-templates>
				</tr>
			</tfoot>
		</table>
	</xsl:template>

	<xsl:template match="/o:osdepcov">
		<html>
			<head>
				<link rel="stylesheet" type="text/css" media="screen"
					href="{$tendra.url.www}/css/common.css"/>
				<link rel="stylesheet" type="text/css" media="screen"
					href="{$tendra.url.www}/css/minidocbook.css"/>
				<link rel="stylesheet" type="text/css" media="screen"
					href="{$tendra.url.api}/css/api.css"/>

				<meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>

				<script type="text/javascript"
					src="{$tendra.url.www}/js/col.js"></script>
				<script type="text/javascript"
					src="{$tendra.url.www}/js/table.js"></script>
				<script type="text/javascript"
					src="{$tendra.url.api}/js/apiexpander.js"></script>
			</head>

			<!-- TODO: unobtrusive javascript for apiexpander.js too -->
			<body onload="var r = document.documentElement;
					Table.init(r);
					Colalign.init(r);
					Expander.init(r);">

				<!-- TODO: banner, etc. centralise with the other xhtml xslt -->

				<xsl:call-template name="api-summary"/>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>

