<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tl="http://xml.elide.org/timeline"
	xmlns:v="http://xml.elide.org/valid"
	xmlns:xlink="http://www.w3.org/1999/xlink"

	exclude-result-prefixes="h tl v">

	<!--
		TODO: where to get the comments date from?
	-->

	<xsl:template match="tl:comments" mode="summary">
		<footer class="comment-summary">
<!-- TODO: need to show author for details view, too -->
<xsl:text>by kate | </xsl:text>

			<a>
				<xsl:call-template name="tl:href">
					<xsl:with-param name="date"  select="../h:html/h:head/h:meta[@name = 'date']/@content"/>
					<xsl:with-param name="short" select="../@short"/>
				</xsl:call-template>

				<xsl:if test="count(tl:comment) != 0">
					<xsl:value-of select="count(tl:comment)"/>
					<xsl:text>&#xA0;</xsl:text>
				</xsl:if>

				<xsl:text>Comment</xsl:text>
				<xsl:if test="count(tl:comment) > 1">
					<xsl:text>s</xsl:text>
				</xsl:if>
			</a>
		</footer>
	</xsl:template>

	<xsl:template name="comment-form">
		<xsl:param name="postpath"/>
		<xsl:param name="date"/>
		<xsl:param name="short"/>

		<!-- TODO: tab order attributes -->
		<form id="comment" class="comment" action="{$www-api}/comment/">
			<h2>
				<xsl:text>Leave a comment</xsl:text>
			</h2>

			<input id="form-postpath" type="hidden" name="postpath"
				value="{ $postpath }"/>

			<input id="form-date" type="hidden" name="date"
				value="{ $date }"/>

			<input id="form-short" type="hidden" name="short"
				value="{ $short }"/>

			<label>
<!-- TODO: default to anonymous -->
				<input id="form-author" type="text" name="author" size="30" v:regex="."/>
				<xsl:text>Your name (required)</xsl:text>
			</label>

			<label>
				<input id="form-email" type="text" name="email" size="30" v:regex="@?"/>	<!-- TODO: regexp -->
				<xsl:text>Your email (it won't be shown)</xsl:text>
			</label>

			<label>
				<!-- TODO: html5 validation fields -->
				<input id="form-url" type="text" name="url" size="30" v:regex="^((https?://)?([^.]+\.)+[a-z]+(/.*)?)?$"/>
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
<!-- TODO: what's the id for? -->
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

			<aside class="feedback">
				<p class="invalid">
					<xsl:text>Please correct the fields indicated and try again.</xsl:text>
				</p>

				<p id="comment-error"/>

				<p id="comment-advice"/>
			</aside>

			<div class="buttons">
				<input type="submit" value="Submit"  onclick="Comment.onsubmit(this.form, Comment.submit)"/>
				<input type="submit" value="Preview" onclick="Comment.onsubmit(this.form, Comment.preview)"/>
			</div>
		</form>
	</xsl:template>

	<xsl:template match="tl:comments" mode="details">
		<xsl:if test="count(h:html) > 0">
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
		</xsl:if>
	</xsl:template>

	<xsl:template match="h:html" mode="details">
		<li>
			<span class="date">
				<xsl:value-of select="h:head/h:meta[@name = 'date']/@content"/>
			</span>

			<!-- note that comments don't have titles -->

			<span class="author">
				<xsl:choose>
					<!-- TODO: @url -->
					<xsl:when test="h:head/h:meta[@name = 'url']">
						<a href="{h:head/h:meta[@name = 'url']/@content}">
							<xsl:value-of select="h:head/h:meta[@name = 'author']/@content"/>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="h:head/h:meta[@name = 'author']/@content"/>
					</xsl:otherwise>
				</xsl:choose>
			</span>

			<xsl:copy-of select="h:body/node()|h:body/text()"/>
		</li>
	</xsl:template>

</xsl:stylesheet>

