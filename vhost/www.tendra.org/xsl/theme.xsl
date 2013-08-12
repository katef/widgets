<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:c="http://xml.tendra.org/tendra_contents"
	xmlns:t="http://xml.tendra.org/tendra_website"

	exclude-result-prefixes="h c t">

	<xsl:import href="../../../xsl/theme.xsl"/>

	<xsl:param name="www-css"/>
	<xsl:param name="www-js"/>
	<xsl:param name="uri"/>

	<!-- TODO: move tendra stuff here -->
	<c:contents>
		<c:category href="/diary/"    name="Diary"/>
		<c:category href="/articles/" name="Articles"/>
		<c:category href="/snippets/" name="Snippets"/>
		<c:category href="/small/"    name="Small"/>
		<c:category href="/projects/" name="Projects"/>
		<c:category href="/faq/"      name="FAQ"/>
		<c:category href="/about/"    name="About"/>
	</c:contents>

	<xsl:template name="t:contents">
<!--
		<ul id="contents">
			<xsl:for-each select="document('')//c:contents/c:category">
				<li>
					<xsl:if test="starts-with($uri, @href)">
						<xsl:attribute name="class">
							<xsl:text>current</xsl:text>
						</xsl:attribute>
					</xsl:if>

					<a href="{@href}">
						<xsl:value-of select="@name"/>
					</a>
				</li>
			</xsl:for-each>
		</ul>
-->
		<nav>
			<ul class="sections">
				<li>
					<a href="#">About</a>
					<ul>
						<li>
							<a class="menu" href="#">Introduction</a>
						</li>
						<li>
							<a class="menu" href="#">Status</a>
						</li>
						<li>
							<a class="menu" href="#">History</a>
						</li>
						<li>
							<a class="menu" href="#">People</a>
						</li>
						<li>
							<a class="menu" href="#">Contact</a>
						</li>
						<li>
							<a class="menu" href="#">Licences</a>
						</li>
					</ul>
				</li>
				<li>
					<a href="http://blog.tendra.org/">Blog</a>
				</li>
				<li>
					<a href="#">Wiki</a>
				</li>
				<li>
					<a href="#">Documentation</a>
					<ul>
						<li>
							<a class="menu" href="#">User guides</a>
						</li>
						<li>
							<a class="menu" href="#">Developer Guides</a>
						</li>
						<li>
							<a class="menu" href="#">Reference</a>
						</li>
						<li class="sep">
							<a class="menu" href="#">Manual Pages</a>
						</li>
						<li>
							<a class="menu" href="#">Bibliography</a>
						</li>
						<li>
							<a class="menu" href="#">Glossary</a>
						</li>
						<li>
							<a class="menu" href="#">FAQ</a>
						</li>
					</ul>
				</li>
				<li>
					<a href="#">Projects</a>
					<ul>
						<li>
							<a class="menu" href="#">TCC<span class="description">UI</span></a>
						</li>
						<li>
							<a class="menu" href="#">DRA Producers<span class="description">C/C++ → TDF</span></a>
						</li>
						<li class="sep">
							<a class="menu" href="#">DRA Installers<span class="description">TDF → asm</span></a>
						</li>
						<li>
							<a class="menu" href="#">TLD<span class="description">TDF Linker</span></a>
						</li>
						<li>
							<a class="menu" href="#">TNC<span class="description">TNC ↔ TDF</span></a>
						</li>
						<li>
							<a class="menu" href="#">TPL<span class="description">PL_TDF → TDF</span></a>
						</li>
						<li class="sep">
							<a class="menu" href="#">disp<span class="description">TDF → ASCII</span></a>
						</li>
						<li>
							<a class="menu" href="#">SID<span class="description">Parser generator</span></a>
						</li>
						<li>
							<a class="menu" href="#">Lexi<span class="description">Lexer generator</span></a>
						</li>
						<li>
							<a class="menu" href="#">Calculus<span class="description">Type generator</span></a>
						</li>
						<li>
							<a class="menu" href="#">Tspec<span class="description">API generator</span></a>
						</li>
						<li>
							<a class="menu" href="#">make_err<span class="description">Error generator</span></a>
						</li>
						<li>
							<a class="menu" href="#">make_tdf<span class="description">TDF I/O generator</span></a>
						</li>
					</ul>
				</li>
				<li>
					<a href="#">Development</a>
					<ul>
						<li>
							<a class="menu" href="#">Tickets</a>
						</li>
						<li>
							<a class="menu" href="#">Timeline</a>
						</li>
						<li>
							<a class="menu" href="#">Browse Source</a>
						</li>
						<li>
							<a class="menu" href="#">Automated Builds</a>
						</li>
					</ul>
				</li>
				<li class="current">
					<a href="#">Downloads</a>
				</li>
			</ul>
		</nav>
	</xsl:template>

	<xsl:template match="h:article[@class = 'entry']/h:h1/h:a">
		<xsl:copy-of select="*|text()"/>
	</xsl:template>

	<xsl:template match="h:article/h:a[@name]"/>

	<xsl:template match="h:article/h:time[@pubdate]">
		<a href="{$blog-base}/{.}">
			<xsl:copy-of select="../h:a[@name]/@*"/>
<!--
			<xsl:copy-of select="../h:h1/h:a/@href, '/'"/>
-->
			<xsl:copy-of select="."/>
		</a>
	</xsl:template>

	<xsl:template name="t:category-title">
		<!-- TODO: override for blog etc - how? pass in as param from nginx conf? -->
		<xsl:text>Website</xsl:text>
	</xsl:template>

	<xsl:template name="t:page-footer">
<!-- TODO -->
		<ul class="otherformats pipelist">
			<li>
				<a rel="nofollow" href="/wiki/Glossary?format=txt">Plain Text</a>
			</li>
			<li>
				<a rel="nofollow" href="?format=csv&amp;USER=kate">CSV</a>
			</li>
			<li>
				<a rel="nofollow" href="/wiki/Glossary?format=rss xyz.rss">RSS</a>
			</li>
		</ul>
	</xsl:template>

	<xsl:template match="/h:html/h:head/h:title" mode="body">
		<xsl:apply-templates select="node()|text()|processing-instruction()"/>
	</xsl:template>

	<xsl:template match="/h:html">
		<xsl:call-template name="theme-output">
			<xsl:with-param name="css"   select="'style.css debug.css'"/>
			<xsl:with-param name="fonts" select="'Maven+Pro:400,700 Ubuntu+Mono'"/>

			<xsl:with-param name="js">
				<xsl:value-of select="'debug.js overlay.js'"/>

				<!-- TODO: only where relevant -->
				<xsl:value-of select="' ajax.js valid.js comment.js template.js'"/>
			</xsl:with-param>

			<xsl:with-param name="onload">
				<xsl:text>Overlay.init(r, 'cols',  6);</xsl:text>
				<xsl:text>Overlay.init(r, 'rows', 26);</xsl:text>
			</xsl:with-param>

			<xsl:with-param name="page">
				<xsl:apply-templates select="h:head/h:title" mode="body"/>
			</xsl:with-param>

			<xsl:with-param name="site">
				<xsl:text>Kate&#8217;s </xsl:text>
				<xsl:call-template name="t:category-title"/>
			</xsl:with-param>

			<xsl:with-param name="body">
				<header>
					<h1 id="banner">
						<a href="#">
							<xsl:text>The </xsl:text>
							<span class="logo">
								<xsl:text>Ten</xsl:text>
								<!-- TODO: or: ᴅʀᴀ -->
								<span class="smallcaps">
									<xsl:text>DRA</xsl:text>
								</span>
							</span>
							<xsl:text> Project</xsl:text>
						</a>
					</h1>

					<form class="search">
						<div class="span-2">
							<input type="text"/>
						</div>
						<div class="span-1 last">
							<input type="submit" value="Search"/>
						</div>
					</form>

					<xsl:call-template name="t:contents"/>
				</header>

				<xsl:apply-templates select="h:head/h:title" mode="body"/>

				<section class="page">
					<xsl:apply-templates select="h:body/node()|h:body/text()|h:body/processing-instruction()"/>
				</section>

				<nav id="sidebar">
					<xsl:apply-templates select="h:nav/node()|h:nav/text()|h:nav/processing-instruction()"/>
				</nav>

				<footer>
					<xsl:call-template name="t:page-footer"/>
				</footer>
			</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>

