<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:str="http://exslt.org/strings"
	xmlns:cal="http://xml.elide.org/calendar"
	xmlns:tl="http://xml.elide.org/timeline"

	extension-element-prefixes="date str"

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

	<xsl:param name="tl:entries" select="/.."/>
	<xsl:param name="tl:limit"   select="20"/>
	<xsl:param name="tl:date"    select="date:date()"/>
	<xsl:param name="tl:year"    select="date:year($tl:date)"/>
	<xsl:param name="tl:month"   select="date:month-in-year($tl:date)"/>
	<xsl:param name="tl:day"     select="date:day-in-month($tl:date)"/>
	<xsl:param name="tl:short"   select="false()"/>

	<xsl:template name="cal-link">
		<xsl:param name="date"/>
		<xsl:param name="delta"/>
		<xsl:param name="rel"/>
		<xsl:param name="next"/>
		<xsl:param name="skip"  select="concat($next, $next)"/>
		<xsl:param name="blank" select="$next"/>
		<xsl:param name="dest"  select="date:add($date, $delta)"/>

		<xsl:variable name="ds" select="date:seconds(date:add($date, $delta)) - date:seconds($date)"/>

		<xsl:choose>
			<xsl:when test="$tl:entries/tl:entry
				[date:year(h:html/h:head/h:meta[@name = 'date']/@content) = date:year($dest)
					and date:month-in-year(h:html/h:head/h:meta[@name = 'date']/@content)
						= date:month-in-year($dest)]">

				<a rel="{$rel}">
					<xsl:call-template name="tl:href">
						<xsl:with-param name="date" select="concat(date:year($dest), '-',
							str:align(date:month-in-year($dest), '00', 'right'))"/>
					</xsl:call-template>

					<xsl:value-of select="$next"/>
				</a>
			</xsl:when>

			<xsl:when test="$ds &gt; 0
				and $tl:entries/tl:entry
					[date:seconds(h:html/h:head/h:meta[@name = 'date']/@content) &gt; date:seconds($dest)]">
				<xsl:variable name="date-skip" select="$tl:entries/tl:entry
					[date:seconds(h:html/h:head/h:meta[@name = 'date']/@content) &gt; date:seconds($dest)]
					[1]
					/h:html/h:head/h:meta[@name = 'date']/@content"/>

				<a rel="{$rel}">
					<xsl:call-template name="tl:href">
						<xsl:with-param name="date" select="concat(date:year($date-skip), '-',
							str:align(date:month-in-year($date-skip), '00', 'right'))"/>
					</xsl:call-template>

					<xsl:value-of select="$skip"/>
				</a>
			</xsl:when>

			<xsl:when test="$ds &lt; 0
				and $tl:entries/tl:entry
					[date:seconds(h:html/h:head/h:meta[@name = 'date']/@content) &lt; date:seconds($dest)]">
				<xsl:variable name="date-skip" select="$tl:entries/tl:entry
					[date:seconds(h:html/h:head/h:meta[@name = 'date']/@content) &lt; date:seconds($dest)]
					[last()]
					/h:html/h:head/h:meta[@name = 'date']/@content"/>

				<a rel="{$rel}">
					<xsl:call-template name="tl:href">
						<xsl:with-param name="date" select="concat(date:year($date-skip), '-',
							str:align(date:month-in-year($date-skip), '00', 'right'))"/>
					</xsl:call-template>

					<xsl:value-of select="$skip"/>
				</a>
			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="$blank"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="cal-head">
		<xsl:param name="date"/>
		<xsl:param name="text"/>

		<xsl:choose>
			<xsl:when test="$tl:entries/tl:entry
				[date:year(h:html/h:head/h:meta[@name = 'date']/@content) = date:year($date)
				and date:month-in-year(h:html/h:head/h:meta[
					@name = 'date']/@content) = date:month-in-year($date)]">
				<a rel="up">
					<xsl:call-template name="tl:href">
						<xsl:with-param name="date"
							select="concat(date:year($date), '-',
								str:align(date:month-in-year($date), '00', 'right'))"/>
					</xsl:call-template>

					<xsl:value-of select="$text"/>
				</a>
			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="cal:caption">
		<xsl:param name="date"/>

		<tr>
			<xsl:choose>
				<xsl:when test="$tl:month or date:day-in-month($date)">
					<th>
						<xsl:call-template name="cal-link">
							<xsl:with-param name="date"  select="$date"/>
							<xsl:with-param name="delta" select="'-P1M'"/>
							<xsl:with-param name="rel"   select="'prev'"/>
							<xsl:with-param name="next"  select="'&lt;'"/>
						</xsl:call-template>
					</th>
					<th colspan="5">
						<!-- XXX: no; if displaying the current month (not a day) then omit the link here -->
						<xsl:call-template name="cal-head">
							<xsl:with-param name="date" select="$date"/>
							<xsl:with-param name="text" select="concat(date:month-name($date),
								'&#160;', date:year($date))"/>
						</xsl:call-template>
					</th>
					<th>
						<xsl:call-template name="cal-link">
							<xsl:with-param name="date"  select="$date"/>
							<xsl:with-param name="delta" select="'P1M'"/>
							<xsl:with-param name="rel"   select="'next'"/>
							<xsl:with-param name="next"  select="'&gt;'"/>
						</xsl:call-template>
					</th>
				</xsl:when>

				<xsl:otherwise>
					<th colspan="7">
						<xsl:call-template name="cal-head">
							<xsl:with-param name="date" select="$date"/>
							<xsl:with-param name="text" select="date:month-name($date)"/>
						</xsl:call-template>
					</th>
				</xsl:otherwise>
			</xsl:choose>
		</tr>
	</xsl:template>

	<xsl:template name="cal:content">
		<xsl:param name="date"/>

		<xsl:choose>
			<xsl:when test="$tl:entries/tl:entry[
					date:year(h:html/h:head/h:meta[@name = 'date']/@content) = date:year($date)
					and date:month-in-year(h:html/h:head/h:meta[
						@name = 'date']/@content) = date:month-in-year($date)
					and date:day-in-month(h:html/h:head/h:meta[
						@name = 'date']/@content) = date:day-in-month($date)]">
				<a>
					<xsl:call-template name="tl:href">
						<xsl:with-param name="date" select="$date"/>
					</xsl:call-template>

					<xsl:attribute name="title">
						<xsl:for-each select="$tl:entries/tl:entry[
							date:year(h:html/h:head/h:meta[@name = 'date']/@content) = date:year($date)
							and date:month-in-year(h:html/h:head/h:meta[
								@name = 'date']/@content) = date:month-in-year($date)
							and date:day-in-month(h:html/h:head/h:meta[
								@name = 'date']/@content) = date:day-in-month($date)]">
							<xsl:choose>
								<xsl:when test="h:html/h:head/h:title">
									<xsl:value-of select="string(h:html/h:head/h:title)"/>
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

					<xsl:value-of select="date:day-in-month($date)"/>
				</a>
			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="date:day-in-month($date)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tl:entry/h:html/h:head/h:title">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tl:entry/h:html">
		<xsl:apply-templates select="h:body/node()|h:body/text()|h:body/processing-instruction()"/>
	</xsl:template>

	<xsl:template match="tl:entry">
		<xsl:variable name="date" select="h:html/h:head/h:meta[@name = 'date']/@content"/>

		<article class="entry">
			<a name="{concat(date:year($date), '-', date:month-in-year($date), '-', date:day-in-month($date))}"/>

			<h1>
				<xsl:apply-templates select="h:html/h:head/h:title"/>
			</h1>

			<time pubdate="pubdate">
				<xsl:value-of select="$date"/>
			</time>

			<xsl:apply-templates select="h:html"/>

			<xsl:choose>
				<xsl:when test="$tl:short">
					<xsl:apply-templates select="tl:comments" mode="details"/>

					<!-- placeholder for javascript to modify -->
					<aside id="ph:preview"/>

					<xsl:call-template name="comment-form">
						<!-- XXX: postpath blog-specific; move this to blog.xsl -->
						<xsl:with-param name="postpath"
							select="translate($tl:date, '-', '/')"/>
						<xsl:with-param name="date"
							select="$tl:date"/>
						<xsl:with-param name="short"
							select="$tl:short"/>
					</xsl:call-template>
				</xsl:when>

				<xsl:otherwise>
					<xsl:apply-templates select="tl:comments" mode="summary"/>
				</xsl:otherwise>
			</xsl:choose>
		</article>
	</xsl:template>

	<xsl:template name="tl:year-view">
		<xsl:param name="month" select="1"/>

		<xsl:call-template name="cal:calendar">
			<xsl:with-param name="date"
				select="concat($tl:year, '-', str:align($month, '00', 'right'))"/>
		</xsl:call-template>

		<xsl:if test="$month &lt; 12">
			<xsl:call-template name="tl:year-view">
				<xsl:with-param name="month" select="$month + 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


	<xsl:template name="tl:title">
		<xsl:choose>
			<xsl:when test="$tl:date">
				<xsl:value-of select="$tl:date"/>
			</xsl:when>

			<xsl:otherwise>
				<xsl:text>Timeline</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tl:calendar">
		<xsl:variable name="date">
			<xsl:choose>
				<xsl:when test="$tl:month">
					<xsl:value-of select="concat($tl:year, '-', str:align($tl:month, '00', 'right'))"/>
				</xsl:when>

				<xsl:when test="$tl:year">
					<xsl:value-of select="$tl:year"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$tl:month">
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
				<xsl:when test="$tl:month">
					<xsl:value-of select="concat($tl:year, '-', str:align($tl:month, '00', 'right'))"/>
				</xsl:when>

				<xsl:when test="$tl:year">
					<xsl:value-of select="$tl:year"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<ol class="years">
			<xsl:for-each select="$tl:entries/tl:entry/h:html/h:head/h:meta[@name = 'date']/@content">
				<xsl:sort data-type="number" select="date:year(.)" order="descending"/>
		
				<xsl:variable name="year" select="date:year(.)"/>
		
				<xsl:if test="not(../../../../preceding-sibling::tl:entry[date:year(h:html/h:head/h:meta[@name = 'date']/@content) = $year])">
					<li>
						<xsl:if test="$tl:year = $year">
							<xsl:attribute name="class">
								<xsl:text>current</xsl:text>
							</xsl:attribute>
						</xsl:if>

						<a>
							<xsl:choose>
								<xsl:when test="$tl:month and $tl:year = $year">
									<xsl:attribute name="rel">
										<xsl:text>directory</xsl:text>
									</xsl:attribute>
								</xsl:when>

								<xsl:when test="not($tl:month) and $tl:year = $year - 1">
									<xsl:attribute name="rel">
										<xsl:text>prev</xsl:text>
									</xsl:attribute>
								</xsl:when>

								<xsl:when test="not($tl:month) and $tl:year = $year + 1">
									<xsl:attribute name="rel">
										<xsl:text>next</xsl:text>
									</xsl:attribute>
								</xsl:when>
							</xsl:choose>

							<xsl:call-template name="tl:href">
								<xsl:with-param name="date" select="$year"/>
							</xsl:call-template>
		
							<time>
								<xsl:value-of select="$year"/>
							</time>
						</a>
					</li>
				</xsl:if>
			</xsl:for-each>
		</ol>
	</xsl:template>

	<xsl:template name="tl:content-body">
		<xsl:choose>
			<xsl:when test="$tl:short">
				<!-- For submitting comments and window.reload()ing -->
				<!-- TODO: maybe this should be done by .htaccess instead -->
<!-- XXX:
				<xsl:variable name="dummy1" select="kxslt:setheader('Cache-control', 'no-store')"/>
				<xsl:variable name="dummy2" select="kxslt:setheader('Pragma',        'no-cache')"/>
				<xsl:variable name="dummy3" select="kxslt:setheader('Expires',       '-1')"/>
-->

				<xsl:apply-templates select="$tl:entries/tl:entry[date:date($tl:date) = date:date(h:html/h:head/h:meta[@name = 'date']/@content)
					and $tl:short = @short]"/>
			</xsl:when>

			<xsl:when test="$tl:day">
				<xsl:apply-templates select="$tl:entries/tl:entry[date:year(h:html/h:head/h:meta[@name = 'date']/@content) = $tl:year
					and date:month-in-year(h:html/h:head/h:meta[@name = 'date']/@content) = $tl:month
					and date:day-in-month(h:html/h:head/h:meta[@name = 'date']/@content)  = $tl:day]"/>
			</xsl:when>

			<xsl:when test="$tl:month">
				<xsl:apply-templates select="$tl:entries/tl:entry[date:year(h:html/h:head/h:meta[@name = 'date']/@content) = $tl:year
					and date:month-in-year(h:html/h:head/h:meta[@name = 'date']/@content) = $tl:month]"/>
			</xsl:when>

			<xsl:when test="$tl:year">
				<section class="year-view">
					<xsl:call-template name="tl:year-view"/>
				</section>
			</xsl:when>

			<xsl:otherwise>
				<!-- TODO: interject with month headings -->
				<!-- TODO: pagnation -->
				<xsl:apply-templates select="$tl:entries/tl:entry[position() >= last() - $tl:limit]"/>
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

