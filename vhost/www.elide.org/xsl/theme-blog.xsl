<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:tl="http://xml.elide.org/timeline"

	exclude-result-prefixes="h tl">

	<xsl:import href="../../../xsl/lib/date.format-date.xsl"/>

	<xsl:import href="../../../xsl/theme.xsl"/>
	<xsl:import href="../../../xsl/img.xsl"/>
	<xsl:import href="../../../xsl/blog.xsl"/>

	<xsl:import href="theme.xsl"/>

	<xsl:param name="www-css"/>
	<xsl:param name="www-js"/>

	<xsl:param name="archive"/>

	<xsl:template match="/tl:timeline">
		<xsl:call-template name="elide-output">
			<xsl:with-param name="category" select="'diary'"/>

			<xsl:with-param name="onload">
				<xsl:text>Valid.init(r);</xsl:text>
			</xsl:with-param>

			<xsl:with-param name="page">
				<xsl:call-template name="tl:content"/>
			</xsl:with-param>

			<xsl:with-param name="head">
				<!-- TODO: xinclude these; keep centralised somewhere (as comment.xhtml5?)
					also would prefer them to be optional... -->
				<script type="text/template" id="tmpl:preview"><![CDATA[
					<aside style="display: block;">
						<!-- TODO: do the @id replacement in xreplacechild() in comment.js instead -->
						<?js void (this.parentNode.id = 'comment-preview'); ?>

						<!-- TODO: use html5's time element for this sort of thing -->
						<span class="date">
							<?js date ?>
						</span>

						<span class="author">
							<a href="{ url || this.ownerElement }"><?js author ?></a>
						</span>

						<?js comment ?>
					</aside>
				]]></script>

				<script type="text/template" id="tmpl:post"><![CDATA[
					<?js void (this.parentNode.id = 'comment-post'); ?>

					<!-- TODO: html5 doctype? -->
					<html xmlns="http://www.w3.org/1999/xhtml">
						<head>
							<meta name="author" content="{ author || this.ownerElement }"/>
							<meta name="email"  content="{ email  || this.ownerElement }"/>
							<meta name="date"   content="{ date   || this.ownerElement }"/>
							<meta name="url"    content="{ url    || this.ownerElement }"/>
						</head>

						<body>
							<?js comment ?>
						</body>
					</html>
				]]></script>
			</xsl:with-param>

			<xsl:with-param name="main">
				<xsl:choose>
					<xsl:when test="$archive">
						<xsl:call-template name="tl:content-archive"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="tl:content"/>
					</xsl:otherwise>
				</xsl:choose>

				<nav id="monthindex">
					<xsl:call-template name="tl:index"/>

					<a href="/archive">Archive</a>
				</nav>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

