<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:str="http://exslt.org/strings"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:tl="http://xml.elide.org/timeline"
	xmlns:cal="http://xml.elide.org/calendar"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	extension-element-prefixes="date str"

	exclude-result-prefixes="h tl date cal str">

	<xsl:import href="timeline.xsl"/>

	<xsl:param name="blog-date"  select="substring(date:date(), 1, 10)"/>
	<xsl:param name="blog-short" select="false()"/>
	<xsl:param name="blog-name"  select="'Blog'"/>

	<!-- TODO: keep timeline entries (suitable for SVN, too) seperate from blog specifics;
	so this file is equivalent to blog-main, and we have a centralised timeline.xsl
	which we can use for SVN and the blog
	of course svn's timeline won't need dates in the URL, since changset IDs are unique
	(so are the blog entry shorts, but the date in the URL is nice for other reasons,
	i.e. viewing an entire month, or viewing an entire year) -->

	<xsl:variable name="tl:date"  select="$blog-date"/>
	<xsl:variable name="tl:short" select="$blog-short"/>

	<xsl:template name="tl:title">
		<xsl:choose>
			<xsl:when test="$tl:date">
				<time datetime="{$tl:date}">
					<xsl:value-of select="date:format-date($tl:date,
						&quot;yyyy&#8288;&#x2013;&#8288;MM&#8288;&#x2013;&#8288;dd&quot;)"/>
				</time>
			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="$blog-name"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tl:href">
		<xsl:param name="date"/>
		<xsl:param name="short" select="false()"/>

		<xsl:attribute name="href">
			<xsl:choose>
				<xsl:when test="$short">
					<xsl:value-of select="concat($blog-base,
						'/', date:year($date),
						'-', str:align(date:month-in-year($date), '00', 'right'),
						'-', str:align(date:day-in-month($date),  '00', 'right'),
						'/', $short)"/>
				</xsl:when>

				<xsl:when test="date:day-in-month($date)">
					<xsl:value-of select="concat($blog-base,
						'/', date:year($date),
						'-', str:align(date:month-in-year($date), '00', 'right'),
						'-', str:align(date:day-in-month($date),  '00', 'right'))"/>
				</xsl:when>

				<xsl:otherwise>
					<xsl:value-of select="concat($blog-base, '/', $date)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<!-- TODO: maybe call minidocbook link template -->
	<xsl:template name="tl:a">
		<xsl:variable name="path" select="concat($blog-base,
			'/', substring(ancestor::tl:entry/h:html/h:head/h:meta
				[@name = 'date']/@content, 1, 10),
			'/', ancestor::tl:entry/@short)"/>

		<xsl:choose>
			<xsl:when test="starts-with(@href, '/')">
				<a rel="external nofollow">
					<xsl:apply-templates select="@*" mode="copy"/>
					<xsl:apply-templates select="node()|text()" mode="copy"/>
				</a>
			</xsl:when>

			<xsl:when test="contains(@href, '://')">
				<a>
					<xsl:apply-templates select="@*" mode="copy"/>
					<xsl:apply-templates select="node()|text()" mode="copy"/>
				</a>
			</xsl:when>

			<xsl:when test="@href">
				<a href="{concat($path, '/', @href)}">
					<xsl:apply-templates select="@*[name() != 'href']" mode="copy"/>
					<xsl:apply-templates select="node()|text()" mode="copy"/>
				</a>
			</xsl:when>

			<xsl:otherwise>
				<a>
					<xsl:apply-templates select="@*" mode="copy"/>
					<xsl:apply-templates select="node()|text()" mode="copy"/>
				</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--
		We do this here (rather than when generating the consolidated blog.xml)
		because here we have the option of falling back to a .png instead,
		depending on the Accept header from mod_kxslt.
	-->
	<xsl:template name="tl:img">
		<xsl:variable name="path" select="concat($blog-base,
			'/', substring(ancestor::tl:entry/h:html/h:head/h:meta
				[@name = 'date']/@content, 1, 10),
			'/', ancestor::tl:entry/@short)"/>
		<xsl:variable name="repo" select="concat($blog-repo,
			'/', substring(ancestor::tl:entry/h:html/h:head/h:meta
				[@name = 'date']/@content, 1, 4),
			'/', ancestor::tl:entry/@short)"/>

		<xsl:variable name="file" select="substring-before(@src, '.')"/>
		<xsl:variable name="ext"  select="substring-after (@src, '.')"/>

		<!-- TODO: could also provide .fsm, perhaps -->
		<!-- TODO: could also provide data:// URLs -->
		<xsl:choose>
			<xsl:when test="$ext = 'png'
			             or $ext = 'jpeg' or $ext = 'jpg' or $ext = 'JPG'">
				<img src="{concat($path, '/', $file, '.', $ext)}">
					<xsl:apply-templates select="@*[name() != 'src']" mode="copy"/>
				</img>
			</xsl:when>

			<xsl:when test="$ext = 'html' or $ext = 'html5'
			             or $ext = 'xhtml' or $ext = 'xhtml5'">
				<iframe src="{concat($path, '/', $file, '.', $ext)}">
					<xsl:apply-templates select="@*[name() != 'src']" mode="copy"/>
				</iframe>
			</xsl:when>

			<xsl:when test="$ext = 'svg'">
				<xsl:copy-of select="document(
					concat($repo, '/', $file, '.svg'))"/>
			</xsl:when>

			<xsl:when test="$ext = 'dot'">
				<xsl:copy-of select="document(
					concat($repo, '/', $file, '.svg'))"/>
			</xsl:when>

			<xsl:when test="$ext = 'txt'">
				<xsl:copy-of select="document(
					concat($repo, '/', $file, '.xml'))"/>
			</xsl:when>

			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>

