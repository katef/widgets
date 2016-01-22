<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:b="http://xml.elide.org/blog"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:str="http://exslt.org/strings"
	xmlns:cal="http://xml.elide.org/calendar"

	exclude-result-prefixes="b date str cal">


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


	<xsl:template match="b:entry">
		<div class="entry">
			<xsl:if test="@date">
				<span class="date">
					<a name="{@date}"/>
					<xsl:value-of select="@date"/>
				</span>
			</xsl:if>

			<xsl:if test="@title">
				<h2>
					<xsl:value-of select="@title"/>
				</h2>
			</xsl:if>

			<xsl:copy-of select="*|text()"/>
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
		<h3>
			<xsl:call-template name="b:title"/>
		</h3>

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

