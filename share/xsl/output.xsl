<?xml version="1.0" standalone="yes"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:w="http://xml.elide.org/widgets"
	xmlns="http://www.w3.org/1999/xhtml"

	xmlns:common="http://exslt.org/common"
	xmlns:str="http://exslt.org/strings"
	xmlns:func="http://exslt.org/functions"

	extension-element-prefixes="common str func"

	exclude-result-prefixes="common str w">

	<!-- for HTML5 -->
	<xsl:output method="html" media-type="text/html" omit-xml-declaration="yes" indent="yes"/>

	<!-- for populating from the command line -->
	<xsl:param name="w.css"       select="''"/>
	<xsl:param name="w.js"        select="''"/>
	<xsl:param name="w.onload"    select="''"/>

	<!-- filenames -->
	<xsl:param name="file-ext"    select="'xhtml5'"/>
	<xsl:param name="file-single" select="'single'"/>
	<xsl:param name="file-index"  select="'index'"/>
	<xsl:param name="file-toc"    select="$file-index"/>
	<xsl:param name="file-front"  select="'frontmatter'"/>

	<!-- URLs to correspond to filenames -->
	<xsl:param name="www-home"/>
	<xsl:param name="www-base"/>
	<xsl:param name="www-css"/>
	<xsl:param name="www-js"/>
	<xsl:param name="www-man"     select="false()"/> <!-- e.g. 'http://man.example.com' -->
	<xsl:param name="www-ext"     select="$file-ext"/>
	<xsl:param name="www-single"  select="$file-single"/>
	<xsl:param name="www-toc"     select="$file-toc"/>
	<xsl:param name="www-front"   select="$file-front"/>

	<func:function name="w:fileext">
		<xsl:param name="filename"/>
		<xsl:param name="ext"/>

		<func:result>
			<xsl:value-of select="$filename"/>
			<xsl:if test="$ext">
				<xsl:value-of select="concat('.', $ext)"/>
			</xsl:if>
		</func:result>
	</func:function>

	<func:function name="w:relative">
		<xsl:param name="base"/>
		<xsl:param name="url"/>

		<func:result>
			<xsl:choose>
				<xsl:when test="starts-with($url, 'http://') or starts-with($url, 'https://')">
					<xsl:value-of select="$url"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($base, '/', $url)"/>
				</xsl:otherwise>
			</xsl:choose>
		</func:result>
	</func:function>

	<xsl:template name="output">
		<xsl:param name="filename"/>
		<xsl:param name="css"       select="''"/>
		<xsl:param name="js"        select="''"/>
		<xsl:param name="onload"    select="''"/>
		<xsl:param name="lang"      select="'en-gb'"/>
		<xsl:param name="class"     select="false()"/>
		<xsl:param name="color"     select="false()"/>
		<xsl:param name="favicon"   select="false()"/>

		<xsl:param name="canonical" select="false()"/>
		<xsl:param name="next"      select="false()"/>
		<xsl:param name="prev"      select="false()"/>
		<xsl:param name="first"     select="false()"/>
		<xsl:param name="last"      select="false()"/>
		<xsl:param name="up"        select="false()"/>

		<xsl:param name="title"/>
		<xsl:param name="head"      select="/.."/>
		<xsl:param name="body"      select="/.."/>

		<xsl:variable name="method">
			<xsl:choose>
				<xsl:when test="$file-ext = 'xhtml'">
					<xsl:value-of select="'xml'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'html'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- TODO: have these as a database of tags in this .xsl file and use document() to get them -->
		<xsl:variable name="media">
			<xsl:choose>
				<xsl:when test="$method = 'xml'">
					<xsl:text>application/xhtml+xml'/xml</xsl:text>
				</xsl:when>
				<xsl:when test="$method = 'html'">
					<xsl:text>text/html</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="doctype-public">
			<xsl:choose>
				<xsl:when test="$method = 'xml'">
					<xsl:text>-//W3C//DTD XHTML 1.0 Strict//EN</xsl:text>
				</xsl:when>
				<xsl:when test="$method = 'html'">
					<xsl:text>TODO</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="doctype-system">
			<xsl:choose>
				<xsl:when test="$method = 'xml'">
					<xsl:text>DTD/xhtml1-strict.dtd</xsl:text>
				</xsl:when>
				<xsl:when test="$method = 'html'">
					<xsl:text>TODO</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="output-file">
			<xsl:choose>
				<xsl:when test="$filename">
 					<xsl:value-of select="$filename"/>
					<xsl:if test="$file-ext">
 						<xsl:value-of select="concat('.', $file-ext)"/>
					</xsl:if>
				</xsl:when>

				<xsl:otherwise>
					<xsl:text>/dev/stdout</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:message>
			<xsl:text>Outputting </xsl:text>
			<xsl:value-of select="concat($output-file, ': &quot;', $title, '&quot;')"/>
		</xsl:message>

		<!--
			The idea here is that we never generate output in the default document tree;
			instead, <common:document> is used for all output. This means a filename given
			by xsltproc -o is always ignored. Instead, -o applies as a directory name only.
		-->
		<common:document
			href="{$output-file}"
			method="{$method}"
			encoding="utf-8"
			indent="yes"
			omit-xml-declaration="yes"
			cdata-section-elements="script"
			media-type="{$media}"
			standalone="yes">
<!-- XXX: only for non-HTML5
			doctype-public="{$doctype-public}"
			doctype-system="{$doctype-system}"
-->

			<xsl:call-template name="output-content">
				<xsl:with-param name="method"    select="$method"/>
				<xsl:with-param name="css"       select="$css"/>
				<xsl:with-param name="js"        select="$js"/>
				<xsl:with-param name="onload"    select="$onload"/>
				<xsl:with-param name="lang"      select="$lang"/>
				<xsl:with-param name="class"     select="$class"/>
				<xsl:with-param name="color"     select="$color"/>
				<xsl:with-param name="favicon"   select="$favicon"/>

				<xsl:with-param name="canonical" select="$canonical"/>
				<xsl:with-param name="next"      select="$next"/>
				<xsl:with-param name="prev"      select="$prev"/>
				<xsl:with-param name="first"     select="$first"/>
				<xsl:with-param name="last"      select="$last"/>
				<xsl:with-param name="up"        select="$up"/>

				<xsl:with-param name="title"     select="$title"/>
				<xsl:with-param name="head"      select="$head"/>
				<xsl:with-param name="body"      select="$body"/>
			</xsl:call-template>

		</common:document>
	</xsl:template>

	<xsl:template name="output-content">
		<xsl:param name="method"    select="'xml'"/>
		<xsl:param name="css"       select="''"/>
		<xsl:param name="js"        select="''"/>
		<xsl:param name="onload"    select="''"/>
		<xsl:param name="lang"      select="'en-gb'"/>
		<xsl:param name="class"     select="false()"/>
		<xsl:param name="color"     select="false()"/>
		<xsl:param name="favicon"   select="false()"/>

		<xsl:param name="canonical" select="false()"/>
		<xsl:param name="next"      select="false()"/>
		<xsl:param name="prev"      select="false()"/>
		<xsl:param name="first"     select="false()"/>
		<xsl:param name="last"      select="false()"/>
		<xsl:param name="up"        select="false()"/>

		<xsl:param name="title"     select="/.."/>
		<xsl:param name="head"      select="/.."/>
		<xsl:param name="body"      select="/.."/>

		<xsl:if test="$method = 'html'">
			<xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;&#xA;</xsl:text>
		</xsl:if>

		<!--
			The moznomarginboxes and mozdisallowselectionprint attributes here
			are meaningful to firefox; they elide the browser-supplied header
			and footer for printed content.
			What a horrible way to expose that setting.
		-->
		<html lang="{$lang}"
			moznomarginboxes="moznomarginboxes"
			mozdisallowselectionprint="mozdisallowselectionprint">

			<xsl:if test="$class">
				<xsl:attribute name="class">
					<xsl:value-of select="$class"/>
				</xsl:attribute>
			</xsl:if>

			<head>
				<title>
					<xsl:value-of select="$title"/>
				</title>

				<xsl:if test="$www-base">
					<base href="{$www-base}"/>

					<!-- $www-base is expected for chunked documents -->
					<xsl:if test="not($canonical)">
						<link rel="canonical" href=""/>
					</xsl:if>
				</xsl:if>

				<xsl:if test="$canonical">
					<link rel="canonical" href="{$canonical}"/>
				</xsl:if>

				<xsl:if test="$next">
					<link rel="next" href="{$next}"/>
				</xsl:if>

				<xsl:if test="$prev">
					<link rel="prev"     href="{$prev}"/>
					<link rel="previous" href="{$prev}"/>
				</xsl:if>

				<xsl:if test="$first">
					<link rel="first" href="{$first}"/>
					<link rel="begin" href="{$first}"/>
					<link rel="start" href="{$first}"/>
				</xsl:if>

				<xsl:if test="$last">
					<link rel="last" href="{$last}"/>
					<link rel="end"  href="{$last}"/>
				</xsl:if>

				<xsl:if test="$up">
					<link rel="up" href="{$up}"/>
				</xsl:if>

				<xsl:if test="$www-home">
					<link rel="home" href="{$www-home}"/>
				</xsl:if>

				<xsl:if test="$favicon">
					<link rel="shortcut icon" type="image/x-icon" href="{$favicon}"/>
				</xsl:if>

				<!-- TODO: maybe a node set is better, after all -->
				<xsl:for-each select="str:tokenize($w.css)|str:tokenize($css)">
					<link rel="stylesheet" type="text/css" media="all" href="{w:relative($www-css, .)}"/>
				</xsl:for-each>

				<xsl:text disable-output-escaping="yes">&lt;!--[if IE 8]&gt;</xsl:text>
					<script type="text/javascript" src="{$www-js}/ie8.js"></script>
				<xsl:text disable-output-escaping="yes">&lt;![endif]--&gt;</xsl:text>
				<xsl:text disable-output-escaping="yes">&lt;!--[if lt IE 9]&gt;</xsl:text>
					<script type="text/javascript" src="{$www-js}/html5shiv-printshiv.min.js"></script>
				<xsl:text disable-output-escaping="yes">&lt;![endif]--&gt;</xsl:text>
				<xsl:text disable-output-escaping="yes">&lt;!--[if lt IE 8]&gt;</xsl:text>
					<script src="{$www-js}/Element.details.ielt8.js"></script>
				<xsl:text disable-output-escaping="yes">&lt;![endif]--&gt;</xsl:text>
				<xsl:text disable-output-escaping="yes">&lt;!--[if IE 8]&gt;</xsl:text>
					<script src="{$www-js}/Element.details.ie8.js"></script>
				<xsl:text disable-output-escaping="yes">&lt;![endif]--&gt;</xsl:text>
				<xsl:text disable-output-escaping="yes">&lt;!--[if gt IE 8]&gt;&lt;!--&gt;</xsl:text>
					<script src="{$www-js}/Element.details.js"></script>
				<xsl:text disable-output-escaping="yes">&lt;!--&lt;![endif]--&gt;</xsl:text>

				<xsl:for-each select="str:tokenize($w.js)|str:tokenize($js)">
					<script type="text/javascript" src="{w:relative($www-js, .)}"></script>
				</xsl:for-each>

				<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<meta name="HandheldFriendly" content="true"/>

				<xsl:if test="$method = 'html'">
					<meta http-equiv="Content-Type"
						content="text/html; charset=utf-8"/>
				</xsl:if>

				<xsl:if test="$color">
					<meta name="theme-color" content="{$color}"/>
				</xsl:if>

				<xsl:copy-of select="$head"/>
			</head>

			<body onload="var r = document.documentElement; {$w.onload} {$onload}">
				<xsl:copy-of select="$body"/>
			</body>
		</html>

	</xsl:template>

</xsl:stylesheet>

