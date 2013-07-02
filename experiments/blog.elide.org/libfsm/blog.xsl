<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings"
	xmlns:cal="http://xml.elide.org/calendar"
	xmlns:b="http://xml.elide.org/blog"
	xmlns:v="http://xml.elide.org/valid"

	exclude-result-prefixes="h date func str b v cal">


	<!--
		TODO: hilight current day, month, year etc
		TODO: search
		TODO: interject with day/month changes
		TODO: show >> instead of > if there's a gap
		 XXX: clicking on a day goes to the wrong #
		TODO: <img> URLs etc (and an image widget)
	-->

	<xsl:import href="calendar.xsl"/>

	<xsl:variable name="blog-date"  select="date:date()"/>
	<xsl:variable name="blog-year"  select="date:year($blog-date)"/>
	<xsl:variable name="blog-month" select="date:month-in-year($blog-date)"/>
	<xsl:variable name="blog-day"   select="date:day-in-month($blog-date)"/>
	<xsl:variable name="blog-title" select="false()"/>


	<xsl:output indent="yes" method="xml" encoding="utf-8"
		cdata-section-elements="script"
		media-type="application/xhtml+xml"

		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>

	<xsl:template name="cal:content">
		<xsl:param name="date"/>

		<xsl:variable name="day" select="date:day-in-month($date)"/>

		<xsl:choose>
			<xsl:when test="/b:blog/b:entry[@date = $date]">
				<a>
					<xsl:call-template name="b:href">
						<!-- TODO: wrong date passed in? -->
						<xsl:with-param name="date" select="$date"/>
					</xsl:call-template>

					<xsl:attribute name="title">
						<xsl:for-each select="/b:blog/b:entry[@date = $date]">
							<xsl:choose>
								<xsl:when test="@title">
									<xsl:value-of select="@title"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>(untitled)</xsl:text>
								</xsl:otherwise>
							</xsl:choose>

							<xsl:if test="position() != last()">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:attribute>

					<xsl:value-of select="$day"/>
				</a>
			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="$day"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="cal:caption">
		<xsl:param name="date"/>

		<xsl:variable name="year-index" select="boolean(date:day-in-week($date))"/>

		<tr>
			<xsl:choose>
				<xsl:when test="$blog-month or $year-index">
					<th>
						<xsl:variable name="date-delta" select="date:add($date, '-P1M')"/>

						<!-- TODO: centralise somehow -->
						<xsl:choose>
							<xsl:when test="/b:blog/b:entry[starts-with(@date, $date-delta)]">
								<a>
									<xsl:call-template name="b:href">
										<xsl:with-param name="date"
											select="concat(date:year($date-delta), '-',
												str:align(date:month-in-year($date-delta), '00', 'right'))"/>
									</xsl:call-template>

									<xsl:text>&lt;</xsl:text>
								</a>
							</xsl:when>

							<xsl:when test="/b:blog/b:entry[starts-with(date:difference($date, @date), '-')]">
								<a>
									<xsl:variable name="date-skip"
										select="/b:blog/b:entry
											[starts-with(date:difference($date, @date), '-')]
											[position() = last()]/@date"/>

									<!-- TODO: skip to next populated entry -->
									<xsl:call-template name="b:href">
										<xsl:with-param name="date"
											select="concat(date:year($date-skip), '-',
												str:align(date:month-in-year($date-skip), '00', 'right'))"/>
									</xsl:call-template>

									<xsl:text>&lt;&lt;</xsl:text>
								</a>
							</xsl:when>

							<xsl:otherwise>
								<xsl:text>&lt;</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</th>
					<th colspan="5">
						<xsl:choose>
							<xsl:when test="$year-index">
								<a>
									<xsl:call-template name="b:href">
										<xsl:with-param name="date" select="concat(date:year($date), '-',
											str:align(date:month-in-year($date), '00', 'right'))"/>
									</xsl:call-template>

									<xsl:value-of select="date:month-name($date)"/>
									<xsl:text> </xsl:text>
									<xsl:value-of select="date:year($date)"/>
								</a>
							</xsl:when>

							<xsl:otherwise>
								<xsl:value-of select="date:month-name($date)"/>
								<xsl:text> </xsl:text>
								<xsl:value-of select="date:year($date)"/>
							</xsl:otherwise>
						</xsl:choose>
					</th>
					<th>
						<xsl:variable name="date-delta" select="date:add($date, 'P1M')"/>

						<xsl:choose>
							<xsl:when test="/b:blog/b:entry[starts-with(@date, $date-delta)]">
								<a>
									<xsl:call-template name="b:href">
										<xsl:with-param name="date"
											select="concat(date:year($date-delta), '-',
												str:align(date:month-in-year($date-delta), '00', 'right'))"/>
									</xsl:call-template>

									<xsl:text>&gt;</xsl:text>
								</a>
							</xsl:when>

							<xsl:when test="/b:blog/b:entry[starts-with(date:difference(@date, $date), '-')]">
								<a>
									<xsl:variable name="date-skip"
										select="/b:blog/b:entry
											[starts-with(date:difference(@date, $date), '-')]
											[position() = 1]/@date"/>

									<!-- TODO: skip to next populated entry -->
									<xsl:call-template name="b:href">
										<xsl:with-param name="date"
											select="concat(date:year($date-skip), '-',
												str:align(date:month-in-year($date-skip), '00', 'right'))"/>
									</xsl:call-template>

									<xsl:text>&gt;&gt;</xsl:text>
								</a>
							</xsl:when>

							<xsl:otherwise>
								<xsl:text>&gt;</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</th>
				</xsl:when>

				<xsl:otherwise>
					<th colspan="7">
						<xsl:choose>
							<xsl:when test="/b:blog/b:entry[starts-with(@date, substring($date, 1, 7))]">
								<a>
									<xsl:call-template name="b:href">
										<xsl:with-param name="date"
											select="concat(date:year($date), '-',
												str:align(date:month-in-year($date), '00', 'right'))"/>
									</xsl:call-template>

									<xsl:value-of select="date:month-name($date)"/>
								</a>
							</xsl:when>

							<xsl:otherwise>
								<xsl:value-of select="date:month-name($date)"/>
							</xsl:otherwise>
						</xsl:choose>
					</th>
				</xsl:otherwise>
			</xsl:choose>
		</tr>
	</xsl:template>


	<func:function name="b:friendlyurl">
		<xsl:param name="title"/>

		<func:result select="translate($title,
			' ABCDEFGHIJKLMNOPQRSTUVWXYZ',
			'-abcdefghijklmnopqrstuvwxyz')"/>
	</func:function>

	<!-- TODO: explain that you're expected to override this. e.g. for embedding <html> or just text.
		likewise provide a way to override the title, so it can get the title from <html>'s <head>.
		separate the title from the ID name -->
	<xsl:template match="b:content">
		<xsl:copy-of select="*[name() != 'b:comments']|text()"/>
	</xsl:template>

	<xsl:template match="b:comments" mode="summary">
		<span class="comment-summary">
			<a>
				<!-- XXX: i am writing thse translate()s out the stupid long way, because
				   - func:function's parameter passing is broken for libxslt 1.1.24 -->
				<xsl:call-template name="b:href">
					<xsl:with-param name="date"  select="../@date"/>
					<xsl:with-param name="title" select="translate(../@title,
						' ABCDEFGHIJKLMNOPQRSTUVWXYZ',
						'-abcdefghijklmnopqrstuvwxyz')"/>
				</xsl:call-template>

				<span class="icon"/>

				<xsl:value-of select="count(b:comment)"/>
<!--
				<xsl:text> comment</xsl:text>
				<xsl:if test="count(b:comment) != 1">
					<xsl:text>s</xsl:text>
				</xsl:if>
				<xsl:text> &#xBB;</xsl:text>
-->
			</a>
		</span>
	</xsl:template>

	<xsl:template name="comment-form">
		<div class="comment-form">
			<h2>
				<xsl:text>Leave a comment</xsl:text>
			</h2>

			<hr/>

			<!-- TODO: tab order attributes -->
			<form>
				<label>
					<input id="form-name" type="text" name="name" size="30" v:regex="."/>
					<xsl:text>Your name (required)</xsl:text>
				</label>

				<label>
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
					<input type="text" name="stuff1" size="30" v:regex="."/>
					<xsl:text>The year (to prove you're human)</xsl:text>
				</label>

				<label id="stuff2">
					<input type="text" name="stuff2" size="30"/>
					<xsl:text>Some more stuff.</xsl:text>
				</label>

				<label>
					<textarea id="form-comment" name="comment" rows="10" cols="80" v:regex="^.+$"/>
					<div class="markup">
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
					</div>
				</label>

				<div class="error">
					<xsl:text>Please correct the fields indicated and try again.</xsl:text>
				</div>

				<div class="buttons">
					<input type="submit" value="Submit"  onclick="Blog.onsubmit(this.form, Blog.submit)"/>
					<input type="submit" value="Preview" onclick="Blog.onsubmit(this.form, Blog.preview)"/>
				</div>
			</form>
		</div>
	</xsl:template>

	<xsl:template match="b:comments" mode="details">
		<div class="comment-details">
			<h2>
				<xsl:value-of select="count(b:comment)"/>
				<xsl:text> comment</xsl:text>
				<xsl:if test="count(b:comment) != 1">
					<xsl:text>s</xsl:text>
				</xsl:if>
			</h2>

			<hr/>

			<ol>
				<xsl:apply-templates select="b:comment" mode="details"/>
			</ol>
		</div>
	</xsl:template>

	<xsl:template match="b:comment" mode="details">
		<li>
			<span class="date">
				<xsl:value-of select="substring(@date, 1, 10)"/>
			</span>

			<span class="name">
				<xsl:choose>
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

			<xsl:copy-of select="*[name() != 'b:comments']|text()"/>
		</li>
	</xsl:template>

	<xsl:template name="blog-templates">
		<!-- TODO: these processing instructions really want to be exslt functions! -->
		<!-- TODO: output these in <head> instead (but only when needed) -->

		<script type="text/template" id="comment-preview-template-a">
			<a href="{{ url }}">
				<xsl:processing-instruction name="js">
					<xsl:text>name </xsl:text>
				</xsl:processing-instruction>
			</a>
		</script>

		<script type="text/template" id="comment-preview-template">
			<div style="display: block">
				<!-- set dynamically to avoid conflict with the existing ID -->
				<!-- TODO: must be a better way to do this! -->
				<!-- TODO: another way: <div style="display: block" xid="{{ void(this.ownerElement.id = 'comment-preview') }}"> -->
				<xsl:processing-instruction name="js">
					<xsl:text>void (this.parentNode.id = 'comment-preview'); </xsl:text>
				</xsl:processing-instruction>

				<span class="date">
					<xsl:processing-instruction name="js">
						<xsl:text>date </xsl:text>
					</xsl:processing-instruction>
				</span>
				<span class="name">
					<xsl:processing-instruction name="js">
						<xsl:text>url ? Template(document.getElementById('comment-preview-template-a'), ctx) : name </xsl:text>
					</xsl:processing-instruction>
				</span>
				<xsl:processing-instruction name="js">
					<xsl:text>comment </xsl:text>
				</xsl:processing-instruction>
			</div>
		</script>
	</xsl:template>

	<xsl:template match="b:entry">
		<div class="entry">
			<xsl:if test="@date">
				<span class="date">
					<a name="{@date}"/>
					<xsl:value-of select="@date"/>
				</span>

				<xsl:if test="not($blog-title)">
					<xsl:apply-templates select="b:comments" mode="summary"/>
				</xsl:if>
			</xsl:if>

			<xsl:if test="@title">
				<h2>
					<xsl:value-of select="@title"/>
				</h2>
			</xsl:if>

			<xsl:apply-templates select="b:content"/>

			<xsl:if test="$blog-title">
				<xsl:apply-templates select="b:comments" mode="details"/>

				<xsl:call-template name="blog-templates"/>

				<!-- placeholder for javascript to modify -->
				<div id="comment-preview"/>
			</xsl:if>

			<xsl:call-template name="comment-form"/>
		</div>
	</xsl:template>

	<xsl:template name="b:year-view">
		<xsl:param name="month" select="1"/>

		<xsl:call-template name="cal:calendar">
			<xsl:with-param name="date"
				select="concat($blog-year, '-', str:align($month, '00', 'right'))"/>
		</xsl:call-template>

		<xsl:if test="$month &lt; 12">
			<xsl:call-template name="b:year-view">
				<xsl:with-param name="month" select="$month + 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


	<!--
		Title entry point
	-->
	<xsl:template name="b:title">
		<xsl:choose>
			<xsl:when test="$blog-date">
				<xsl:value-of select="$blog-date"/>
			</xsl:when>

			<xsl:otherwise>
				<xsl:text>Blog</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--
		Calendar entry point
	-->
	<xsl:template name="b:calendar">
		<xsl:variable name="date">
			<xsl:choose>
				<xsl:when test="$blog-month">
					<xsl:value-of select="concat($blog-year, '-', str:align($blog-month, '00', 'right'))"/>
				</xsl:when>

				<xsl:when test="$blog-year">
					<xsl:value-of select="$blog-year"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$blog-month">
				<xsl:call-template name="cal:calendar">
					<xsl:with-param name="date" select="$date"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:otherwise>
				<xsl:call-template name="cal:calendar">
					<xsl:with-param name="date" select="date:date()"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="b:years">
		<xsl:variable name="date">
			<xsl:choose>
				<xsl:when test="$blog-month">
					<xsl:value-of select="concat($blog-year, '-', str:align($blog-month, '00', 'right'))"/>
				</xsl:when>

				<xsl:when test="$blog-year">
					<xsl:value-of select="$blog-year"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:for-each select="b:entry/@date">
			<xsl:sort data-type="number" select="@date"/>
	
			<xsl:variable name="year" select="substring(., 1, 4)"/>
	
			<xsl:if test="not(../preceding-sibling::b:entry[substring(@date, 1, 4) = $year])">
				<li>
					<xsl:if test="$date = $year">
						<xsl:attribute name="class">
							<xsl:text>current</xsl:text>
						</xsl:attribute>
					</xsl:if>

					<a>
						<xsl:call-template name="b:href">
							<xsl:with-param name="date" select="$year"/>
						</xsl:call-template>
	
						<xsl:value-of select="$year"/>
					</a>
				</li>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!--
		Content entry point
	-->
	<xsl:template name="b:content">
		<xsl:choose>
			<xsl:when test="$blog-title">
				<!-- XXX: i am writing thse translate()s out the stupid long way, because
				   - func:function's parameter passing is broken for libxslt 1.1.24 -->

				<xsl:apply-templates select="b:entry[date:date($blog-date) = date:date(@date)
					and $blog-title = translate(@title, ' ABCDEFGHIJKLMNOPQRSTUVWXYZ',
					                                    '-abcdefghijklmnopqrstuvwxyz')]"/>

				<!-- TODO: rewrite this in a nicer way, somehow... -->
				<xsl:if test="not(b:entry[date:date($blog-date) = date:date(@date)
					and $blog-title = translate(@title, ' ABCDEFGHIJKLMNOPQRSTUVWXYZ',
					                                    '-abcdefghijklmnopqrstuvwxyz')])">
					<p>
						<xsl:text>(no entries)</xsl:text>
					</p>
				</xsl:if>
			</xsl:when>

			<xsl:when test="$blog-day">
				<xsl:apply-templates select="b:entry[date:year(@date) = $blog-year
					and date:month-in-year(@date) = $blog-month
					and date:day-in-month(@date)  = $blog-day]"/>

				<xsl:if test="not(b:entry[date:year(@date) = $blog-year
					and date:day-in-month(@date)  = $blog-day
					and date:month-in-year(@date) = $blog-month])">
					<xsl:text>(no entries)</xsl:text>
				</xsl:if>
			</xsl:when>

			<xsl:when test="$blog-month">
				<xsl:apply-templates select="b:entry[date:year(@date) = $blog-year
					and date:month-in-year(@date) = $blog-month]"/>

				<xsl:if test="not(b:entry[date:year(@date) = $blog-year
					and date:month-in-year(@date) = $blog-month])">
					<xsl:text>(no entries)</xsl:text>
				</xsl:if>
			</xsl:when>

			<xsl:when test="$blog-year">
				<div class="year-view">
					<xsl:call-template name="b:year-view"/>
				</div>
			</xsl:when>

			<xsl:otherwise>
				<!-- TODO: interject with month headings -->
				<!-- TODO: pagnation -->
				<xsl:apply-templates select="b:entry[position() >= last() - 20]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--
		Convenience for all of the above
	-->
	<xsl:template name="b:blog">
		<xsl:if test="not($blog-title)">
			<h3>
				<xsl:call-template name="b:title"/>
			</h3>
		</xsl:if>

		<div class="cal-index">
			<xsl:call-template name="b:calendar"/>

			<hr/>

			<ol class="years">
				<xsl:call-template name="b:years"/>
			</ol>
		</div>

		<xsl:call-template name="b:content"/>
	</xsl:template>

</xsl:stylesheet>

