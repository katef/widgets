<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tl="http://xml.elide.org/timeline"
	xmlns:v="http://xml.elide.org/valid"

	exclude-result-prefixes="h tl v">

	<!--
		TODO: where to get the comments date from?
	-->

	<xsl:template match="tl:comments" mode="summary">
		<span class="comment-summary">
			<a>
				<xsl:call-template name="tl:href">
					<xsl:with-param name="date"      select="../@date"/>
					<xsl:with-param name="shortform" select="../@shortform"/>
				</xsl:call-template>

				<span class="icon"/>

				<xsl:value-of select="count(tl:comment)"/>
			</a>
		</span>
	</xsl:template>

	<xsl:template name="comment-form">
		<!-- TODO: tab order attributes -->
		<form class="comment">
			<h3>
				<xsl:text>Leave a comment</xsl:text>
			</h3>

			<label>
				<input id="form-name" type="text" name="name" size="30" v:regex="."/>
				<xsl:text>Your name (required)</xsl:text>
			</label>

			<label>
				<!-- TODO: html5 validation fields -->
				<input id="form-url" type="text" name="url" size="30" v:regex="^((http://)?([^.]+\.)+[a-z]+(/.*)?)?$"/>
				<xsl:text>Your website</xsl:text>
				<span class="example">
					<xsl:text>(e.g. </xsl:text>
					<tt>
						<xsl:text>http://elide.org/</xsl:text>
					</tt>
					<xsl:text>)</xsl:text>
				</span>
			</label>

			<label id="stuff1">
				<input type="text" name="stuff1" size="30" v:regex=".*"/>
				<xsl:text>The year (to prove you're human)</xsl:text>
			</label>

			<label id="stuff2">
				<input type="text" name="stuff2" size="30" v:regex=".*"/>
				<xsl:text>Some more stuff</xsl:text>
			</label>

			<label>
				<textarea id="form-comment" name="comment" rows="10" cols="80" v:regex="^.+$"/>
				<aside class="markup">
					<xsl:text>Markup permitted: </xsl:text>
					<code>&lt;br/&gt;</code>
					<xsl:text>, </xsl:text>
					<code>&lt;p&gt;</code>
					<xsl:text>, </xsl:text>
					<code>&lt;q&gt;</code>
					<xsl:text>, </xsl:text>
					<code>&lt;code&gt;</code>
					<xsl:text>, </xsl:text>
					<code>&lt;pre&gt;</code>
					<xsl:text>, </xsl:text>
					<code>&lt;em&gt;</code>
					<xsl:text>, </xsl:text>
					<code>&lt;blockquote&gt;</code>
					<xsl:text>, </xsl:text>
					<code>&lt;a&#xA0;href="..."&gt;</code>
				</aside>
			</label>

			<div class="error">
				<xsl:text>Please correct the fields indicated and try again.</xsl:text>
			</div>

			<div class="buttons">
				<input type="submit" value="Submit"  onclick="Comment.onsubmit(this.form, Comment.submit)"/>
				<input type="submit" value="Preview" onclick="Comment.onsubmit(this.form, Comment.preview)"/>
			</div>
		</form>
	</xsl:template>

	<xsl:template match="tl:comments" mode="details">
		<aside class="comment-details">
			<h3>
				<xsl:value-of select="count(h:html)"/>
				<xsl:text> comment</xsl:text>
				<xsl:if test="count(h:html) != 1">
					<xsl:text>s</xsl:text>
				</xsl:if>
			</h3>

			<hr/>

			<ol>
				<xsl:apply-templates select="h:html" mode="details"/>
			</ol>
		</aside>
	</xsl:template>

	<xsl:template match="h:html" mode="details">
		<li>
			<span class="date">
				<!-- TODO: where to get the comment date from? -->
				<xsl:text>TODO</xsl:text>
				<xsl:value-of select="substring(tl:entry/@date, 1, 10)"/>
			</span>

			<span class="name">
				<xsl:choose>
					<!-- TODO: @url -->
					<xsl:when test="@url">
						<a href="{@url}">
							<xsl:value-of select="@name"/>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@name"/>
					</xsl:otherwise>
				</xsl:choose>
			</span>

			<xsl:copy-of select="h:body/node()|h:body/text()"/>
		</li>
	</xsl:template>

</xsl:stylesheet>

