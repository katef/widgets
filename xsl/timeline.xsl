<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:str="http://exslt.org/strings"
	xmlns:cal="http://xml.elide.org/calendar"
	xmlns:tl="http://xml.elide.org/timeline"

	exclude-result-prefixes="h date str tl cal">

	<!--
		TODO: pass in option for whether to permit comments or not? could even show commit messages as a comment
		TODO: can permit comments on any timeline entry... including svn/wiki changesets
		TODO: hilight current day, month, year etc
		TODO: search
		TODO: interject with day/month changes
		TODO: show >> instead of > if there's a gap
		 XXX: clicking on a day goes to the wrong #
	-->

	<xsl:import href="calendar.xsl"/>
	<xsl:import href="comment.xsl"/>

	<xsl:param name="timeline"       select="/.."/>
	<xsl:param name="timeline-limit" select="20"/>
	<xsl:param name="timeline-date"  select="date:date()"/>
	<xsl:param name="timeline-year"  select="date:year($timeline-date)"/>
	<xsl:param name="timeline-month" select="date:month-in-year($timeline-date)"/>
	<xsl:param name="timeline-day"   select="date:day-in-month($timeline-date)"/>
	<xsl:param name="timeline-short" select="false()"/>

	<xsl:template name="cal:content">
		<xsl:param name="date"/>

		<xsl:variable name="day" select="date:day-in-month($date)"/>

		<xsl:choose>
			<xsl:when test="$timeline/tl:timeline/tl:entry[@date = $date]">
				<a>
					<xsl:call-template name="tl:href">
						<!-- TODO: wrong date passed in? -->
						<xsl:with-param name="date" select="$date"/>
					</xsl:call-template>

					<xsl:attribute name="title">
						<xsl:for-each select="$timeline/tl:timeline/tl:entry[@date = $date]">
							<xsl:choose>
								<xsl:when test="h:html/h:head/h:title">
									<xsl:value-of select="h:html/h:head/h:title"/>
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
				<xsl:when test="$timeline-month or $year-index">
					<th>
						<xsl:variable name="date-delta" select="date:add($date, '-P1M')"/>

						<!-- TODO: centralise somehow -->
						<xsl:choose>
							<xsl:when test="$timeline/tl:timeline/tl:entry[starts-with(@date, $date-delta)]">
								<a>
									<xsl:call-template name="tl:href">
										<xsl:with-param name="date"
											select="concat(date:year($date-delta), '-',
												str:align(date:month-in-year($date-delta), '00', 'right'))"/>
									</xsl:call-template>

									<xsl:text>&lt;</xsl:text>
								</a>
							</xsl:when>

							<xsl:when test="$timeline/tl:timeline/tl:entry[starts-with(date:difference($date, @date), '-')]">
								<a>
									<xsl:variable name="date-skip"
										select="$timeline/tl:timeline/tl:entry
											[starts-with(date:difference($date, @date), '-')]
											[position() = last()]/@date"/>

									<!-- TODO: skip to next populated entry -->
									<xsl:call-template name="tl:href">
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
									<xsl:call-template name="tl:href">
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
							<xsl:when test="$timeline/tl:timeline/tl:entry[starts-with(@date, $date-delta)]">
								<a>
									<xsl:call-template name="tl:href">
										<xsl:with-param name="date"
											select="concat(date:year($date-delta), '-',
												str:align(date:month-in-year($date-delta), '00', 'right'))"/>
									</xsl:call-template>

									<xsl:text>&gt;</xsl:text>
								</a>
							</xsl:when>

							<xsl:when test="$timeline/tl:timeline/tl:entry[starts-with(date:difference(@date, $date), '-')]">
								<a>
									<xsl:variable name="date-skip"
										select="$timeline/tl:timeline/tl:entry
											[starts-with(date:difference(@date, $date), '-')]
											[position() = 1]/@date"/>

									<!-- TODO: skip to next populated entry -->
									<xsl:call-template name="tl:href">
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
							<xsl:when test="$timeline/tl:timeline/tl:entry
								[date:year(@date) = date:year($date)
								and date:month-in-year(@date) = date:month-in-year($date)]">
								<a>
									<xsl:call-template name="tl:href">
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


	<xsl:template match="tl:entry/h:html/h:head/h:title">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tl:entry/h:html">
		<xsl:apply-templates select="h:body/node()|h:body/text()|h:body/processing-instruction()"/>
	</xsl:template>

	<xsl:template match="tl:entry">
		<section class="entry">
			<a name="{@date}"/>

			<h2>
				<xsl:apply-templates select="h:html/h:head/h:title"/>

				<!-- TODO: this should be formatted by a particular theme. maybe output a PI here -->
				<span class="date">
					<xsl:value-of select="date:day-in-month(@date)"/>
					<xsl:text>&#xA0;</xsl:text>
					<xsl:value-of select="date:month-abbreviation(@date)"/>
					<xsl:text>&#xA0;&#8217;</xsl:text>
					<xsl:value-of select="substring(date:year(@date), 3, 2)"/>
				</span>
			</h2>

			<xsl:apply-templates select="h:html"/>

			<xsl:choose>
				<xsl:when test="$timeline-short">
					<xsl:apply-templates select="tl:comments" mode="details"/>

					<!-- placeholder for javascript to modify -->
					<aside id="ph:preview"/>

					<xsl:call-template name="comment-form">
						<!-- XXX: postpath blog-specific; move this to blog.xsl -->
						<xsl:with-param name="postpath"
							select="translate($timeline-date, '-', '/')"/>
						<xsl:with-param name="date"
							select="$timeline-date"/>
						<xsl:with-param name="short"
							select="$timeline-short"/>
					</xsl:call-template>
				</xsl:when>

				<xsl:otherwise>
					<xsl:apply-templates select="tl:comments" mode="summary"/>
				</xsl:otherwise>
			</xsl:choose>
		</section>
	</xsl:template>

	<xsl:template name="tl:year-view">
		<xsl:param name="month" select="1"/>

		<xsl:call-template name="cal:calendar">
			<xsl:with-param name="date"
				select="concat($timeline-year, '-', str:align($month, '00', 'right'))"/>
		</xsl:call-template>

		<xsl:if test="$month &lt; 12">
			<xsl:call-template name="tl:year-view">
				<xsl:with-param name="month" select="$month + 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


	<xsl:template name="tl:title">
		<xsl:choose>
			<xsl:when test="$timeline-date">
				<xsl:value-of select="$timeline-date"/>
			</xsl:when>

			<xsl:otherwise>
				<xsl:text>Timeline</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tl:calendar">
		<xsl:variable name="date">
			<xsl:choose>
				<xsl:when test="$timeline-month">
					<xsl:value-of select="concat($timeline-year, '-', str:align($timeline-month, '00', 'right'))"/>
				</xsl:when>

				<xsl:when test="$timeline-year">
					<xsl:value-of select="$timeline-year"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$timeline-month">
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

	<xsl:template name="tl:years">
		<xsl:variable name="date">
			<xsl:choose>
				<xsl:when test="$timeline-month">
					<xsl:value-of select="concat($timeline-year, '-', str:align($timeline-month, '00', 'right'))"/>
				</xsl:when>

				<xsl:when test="$timeline-year">
					<xsl:value-of select="$timeline-year"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<ol class="years">
			<xsl:for-each select="$timeline/tl:timeline/tl:entry/@date">
				<!-- TODO: really data-type is number? -->
				<xsl:sort data-type="number" select="date:year(.)" order="descending"/>
		
				<xsl:variable name="year" select="date:year(.)"/>
		
				<xsl:if test="not(../preceding-sibling::tl:entry[date:year(@date) = $year])">
					<li>
						<xsl:if test="$timeline-year = $year">
							<xsl:attribute name="class">
								<xsl:text>current</xsl:text>
							</xsl:attribute>
						</xsl:if>

						<a>
							<xsl:call-template name="tl:href">
								<xsl:with-param name="date" select="$year"/>
							</xsl:call-template>
		
							<xsl:value-of select="$year"/>
						</a>
					</li>
				</xsl:if>
			</xsl:for-each>
		</ol>
	</xsl:template>

	<xsl:template name="tl:content-body">
		<xsl:choose>
			<xsl:when test="$timeline-short">
				<!-- For submitting comments and window.reload()ing -->
				<!-- TODO: maybe this should be done by .htaccess instead -->
<!-- XXX:
				<xsl:variable name="dummy1" select="kxslt:setheader('Cache-control', 'no-store')"/>
				<xsl:variable name="dummy2" select="kxslt:setheader('Pragma',        'no-cache')"/>
				<xsl:variable name="dummy3" select="kxslt:setheader('Expires',       '-1')"/>
-->

				<xsl:apply-templates select="$timeline/tl:timeline/tl:entry[date:date($timeline-date) = date:date(@date)
					and $timeline-short = @short]"/>
			</xsl:when>

			<xsl:when test="$timeline-day">
				<xsl:apply-templates select="$timeline/tl:timeline/tl:entry[date:year(@date) = $timeline-year
					and date:month-in-year(@date) = $timeline-month
					and date:day-in-month(@date)  = $timeline-day]"/>
			</xsl:when>

			<xsl:when test="$timeline-month">
				<xsl:apply-templates select="$timeline/tl:timeline/tl:entry[date:year(@date) = $timeline-year
					and date:month-in-year(@date) = $timeline-month]"/>
			</xsl:when>

			<xsl:when test="$timeline-year">
				<section class="year-view">
					<xsl:call-template name="tl:year-view"/>
				</section>
			</xsl:when>

			<xsl:otherwise>
				<!-- TODO: interject with month headings -->
				<!-- TODO: pagnation -->
				<xsl:apply-templates select="$timeline/tl:timeline/tl:entry[position() >= last() - $timeline-limit]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tl:content">
		<xsl:variable name="r">
			<xsl:call-template name="tl:content-body"/>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$r = ''"> <!-- XXX: why can't i count($r) here? -->
				<xsl:text>(no entries)</xsl:text>
			</xsl:when>

			<xsl:otherwise>
				<xsl:copy-of select="$r"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>

