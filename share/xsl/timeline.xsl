<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings"
	xmlns:common="http://exslt.org/common"
	xmlns:cal="http://xml.elide.org/calendar"
	xmlns:tl="http://xml.elide.org/timeline"

	extension-element-prefixes="date func str common"

	exclude-result-prefixes="h date func str common tl cal">

	<!--
		TODO: pass in option for whether to permit comments or not? could even show commit messages as a comment
		TODO: can permit comments on any timeline entry... including svn/wiki changesets
		TODO: hilight current day, month, year etc
		TODO: search
		TODO: interject with day/month changes
		TODO: show >> instead of > if there's a gap
		 XXX: clicking on a day goes to the wrong #
	-->

	<xsl:import href="lib/date.format-date.xsl"/>
	<xsl:import href="lib/date.make.xsl"/>
	<xsl:import href="lib/date.same.xsl"/>

	<xsl:import href="calendar.xsl"/>
	<xsl:import href="comment.xsl"/>
	<xsl:import href="copy.xsl"/>

	<xsl:param name="tl-limit"   select="20"/>
	<xsl:param name="tl-date"    select="substring(date:date(), 1, 10)"/>
	<xsl:param name="tl-year"    select="date:year($tl-date)"/>
	<xsl:param name="tl-month"   select="date:month-in-year($tl-date)"/>
	<xsl:param name="tl-day"     select="date:day-in-month($tl-date)"/>
	<xsl:param name="tl-short"   select="false()"/>

	<func:function name="tl:private">
		<xsl:param name="entry"/>

		<xsl:variable name="tags" select="$entry/h:html/h:head/h:meta[@name = 'tags']/@content"/>

<!-- TODO: set-contains? -->
		<func:result select="str:tokenize($tags)[. = 'private']"/>
	</func:function>

	<func:function name="tl:pubdate">
		<xsl:param name="entry"/>

		<func:result select="$entry/h:html/h:head/h:meta[@name = 'date']/@content"/>
	</func:function>

	<func:function name="tl:entrytitle">
		<xsl:param name="entry"/>

		<func:result>
			<xsl:choose>
				<xsl:when test="string($entry/h:html/h:head/h:title)">
					<xsl:apply-templates select="$entry/h:html/h:head/h:title"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>(untitled)</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</func:result>
	</func:function>

	<!--
		Without specific content to show (i.e. when $tl-year is not set),
		the timeline content shows most recent entries upto a cutoff point.
		The cutoff is calculated by selecting entries upto a limited number,
		and then taking the month for the oldest item there. So this rounds
		down to the start of that month.
		Then entries up to the cutoff month are shown.
		In this way the pages index can navigate to the previous month.
	-->
	<func:function name="tl:cutoff">
		<xsl:param name="timeline"/>
		<xsl:param name="limit" select="$tl-limit"/>

		<func:result select="$timeline/tl:entry[position() >= last() - $limit]
			[1]/h:html/h:head/h:meta[@name = 'date']/@content"/>
	</func:function>

	<xsl:template name="cal-link">
		<xsl:param name="date"/>
		<xsl:param name="delta"/>
		<xsl:param name="rel"/>
		<xsl:param name="dest"  select="date:add($date, $delta)"/>

		<!-- these are date:format-date() format strings -->
		<xsl:param name="next"/>
		<xsl:param name="skip"/>
		<xsl:param name="blank" select="$next"/>
		<xsl:param name="dtfmt" select="'yyyy-MM-dd'"/>
		<xsl:param name="data"  select="false()"/>

		<xsl:variable name="ds" select="date:seconds(date:add($date, $delta)) - date:seconds($date)"/>

		<xsl:choose>
			<xsl:when test="tl:entry
				[date:same-month(tl:pubdate(.), $dest)]">

				<a rel="{$rel}">
					<xsl:call-template name="tl:href">
						<xsl:with-param name="date" select="date:format-date($dest, 'yyyy-MM')"/>
					</xsl:call-template>

					<xsl:if test="$data">
						<xsl:attribute name="data-fmt">
							<xsl:value-of select="date:format-date($dest, $data)"/>
						</xsl:attribute>
					</xsl:if>

					<time datetime="{date:format-date($dest, $dtfmt)}">
						<xsl:value-of select="date:format-date($dest, $next)"/>
					</time>
				</a>
			</xsl:when>

			<xsl:when test="$ds &gt; 0
				and tl:entry
					[date:seconds(tl:pubdate(.)) &gt; date:seconds($dest)]">
				<xsl:variable name="date-skip" select="tl:pubdate(tl:entry
					[date:seconds(tl:pubdate(.)) &gt; date:seconds($dest)]
					[1])"/>

				<a rel="{$rel}">
					<xsl:call-template name="tl:href">
						<xsl:with-param name="date" select="date:format-date($date-skip, 'yyyy-MM')"/>
					</xsl:call-template>

					<xsl:if test="$data">
						<xsl:attribute name="data-fmt">
							<xsl:value-of select="date:format-date($date-skip, $data)"/>
						</xsl:attribute>
					</xsl:if>

					<time datetime="{date:format-date($date-skip, $dtfmt)}" class="skip">
						<xsl:value-of select="date:format-date($date-skip, $skip)"/>
					</time>
				</a>
			</xsl:when>

			<xsl:when test="$ds &lt; 0
				and tl:entry
					[date:seconds(tl:pubdate(.)) &lt; date:seconds($dest)]">
				<xsl:variable name="date-skip" select="tl:pubdate(tl:entry
					[date:seconds(tl:pubdate(.)) &lt; date:seconds($dest)]
					[last()])"/>

				<a rel="{$rel}">
					<xsl:call-template name="tl:href">
						<xsl:with-param name="date" select="date:format-date($date-skip, 'yyyy-MM')"/>
					</xsl:call-template>

					<xsl:if test="$data">
						<xsl:attribute name="data-fmt">
							<xsl:value-of select="date:format-date($date-skip, $data)"/>
						</xsl:attribute>
					</xsl:if>

					<time datetime="{date:format-date($date-skip, $dtfmt)}" class="skip">
						<xsl:value-of select="date:format-date($date-skip, $skip)"/>
					</time>
				</a>
			</xsl:when>

			<xsl:otherwise>
				<time datetime="{date:format-date($dest, $dtfmt)}">
					<xsl:if test="$data">
						<xsl:attribute name="data-fmt">
							<xsl:value-of select="date:format-date($dest, $data)"/>
						</xsl:attribute>
					</xsl:if>

					<xsl:value-of select="date:format-date($dest, $blank)"/>
				</time>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="cal-head">
		<xsl:param name="date"/>
		<xsl:param name="text"/>

		<xsl:choose>
			<xsl:when test="tl:entry
				[date:same-month(tl:pubdate(.), $date)]">

				<a rel="up">
					<xsl:call-template name="tl:href">
						<xsl:with-param name="date" select="date:format-date($date, 'yyyy-MM')"/>
					</xsl:call-template>

					<time datetime="{date:format-date($date, 'yyyy-MM')}">
						<xsl:value-of select="$text"/>
					</time>
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
				<xsl:when test="$tl-month or date:day-in-month($date)">
					<th class="prev">
						<xsl:call-template name="cal-link">
							<xsl:with-param name="date"  select="$date"/>
							<xsl:with-param name="delta" select="'-P1M'"/>
							<xsl:with-param name="rel"   select="'prev'"/>
							<xsl:with-param name="next"  select="&quot;'&lt;'&quot;"/>
							<xsl:with-param name="skip"  select="&quot;'&lt;&lt;'&quot;"/>
							<xsl:with-param name="dtfmt" select="'yyyy-MM'"/>
						</xsl:call-template>
					</th>
					<th class="month" colspan="5">
						<!-- XXX: no; if displaying the current month (not a day) then omit the link here -->
						<xsl:call-template name="cal-head">
							<xsl:with-param name="date" select="$date"/>
							<xsl:with-param name="text" select="date:format-date($date, &quot;MMMMM'&#160;'yyyy&quot;)"/>
						</xsl:call-template>
					</th>
					<th class="next">
						<xsl:call-template name="cal-link">
							<xsl:with-param name="date"  select="$date"/>
							<xsl:with-param name="delta" select="'P1M'"/>
							<xsl:with-param name="rel"   select="'next'"/>
							<xsl:with-param name="next"  select="&quot;'&gt;'&quot;"/>
							<xsl:with-param name="skip"  select="&quot;'&gt;&gt;'&quot;"/>
							<xsl:with-param name="dtfmt" select="'yyyy-MM'"/>
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
			<xsl:when test="tl:entry
				[date:same-day(tl:pubdate(.), $date)]">

				<a>
					<xsl:call-template name="tl:href">
						<xsl:with-param name="date" select="$date"/>
					</xsl:call-template>

					<xsl:attribute name="title">
						<xsl:for-each select="tl:entry
							[date:same-day(tl:pubdate(.), $date)]">

							<!-- TODO: improper serialisation? -->
							<xsl:value-of select="string(tl:entrytitle(.))"/>

							<xsl:if test="position() != last()">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:attribute>

					<time datetime="{$date}">
						<xsl:value-of select="date:day-in-month($date)"/>
					</time>
				</a>
			</xsl:when>

			<xsl:otherwise>
				<time datetime="{$date}">
					<xsl:value-of select="date:day-in-month($date)"/>
				</time>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tl:entry/h:html/h:head/h:title">
		<xsl:apply-templates select="node()|@*" mode="copy"/>
	</xsl:template>

	<xsl:template match="tl:entry/h:html">
		<xsl:apply-templates select="h:head/h:template" mode="copy"/>
		<xsl:apply-templates select="h:head/h:script"   mode="copy"/>
		<xsl:apply-templates select="h:head/h:style"    mode="copy"/>
		<xsl:apply-templates select="h:body/node()"     mode="copy"/>
	</xsl:template>

	<xsl:template match="h:html/h:head/h:meta[@name = 'tags'][count(str:tokenize(@content))]">
		<xsl:if test="@content != 'private'">
			<ul class="tags">
				<xsl:for-each select="str:tokenize(@content)">
					<xsl:sort select="."/>

					<li>
						<a href="#TODO">
							<xsl:value-of select="."/>
						</a>
					</li>
				</xsl:for-each>
			</ul>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tl:entry[tl:private(.)]">
		<!-- TODO -->
	</xsl:template>

	<xsl:template match="tl:entry[not(tl:private(.))]">
		<xsl:variable name="date" select="tl:pubdate(.)"/>

		<article class="entry {@class}">
			<h1 id="{date:format-date($date, 'yyyy-MM-dd')}">
				<a>
					<xsl:call-template name="tl:href">
						<xsl:with-param name="date"  select="$date"/>
						<xsl:with-param name="short" select="@short"/>
					</xsl:call-template>

					<xsl:apply-templates select="h:html/h:head/h:title"/>
				</a>
			</h1>

			<time pubdate="{tl:pubdate(.)}">
				<xsl:value-of select="date:format-date($date, &quot;yyyy&#x2060;&#x2012;&#x2060;MM&#x2060;&#x2012;&#x2060;dd&quot;)"/>
			</time>

<!-- TODO: what matches this? -->
			<xsl:apply-templates select="h:html/h:head/h:meta[@name = 'tags']"/>

			<div class="body">
				<xsl:apply-templates select="h:html"/>
			</div>

			<xsl:choose>
				<xsl:when test="$tl-short">
					<xsl:apply-templates select="tl:comments" mode="details"/>

					<!-- placeholder for javascript to modify -->
					<aside id="ph:preview"/>

					<xsl:call-template name="comment-form">
						<!-- XXX: postpath blog-specific; move this to blog.xsl -->
						<xsl:with-param name="postpath"
							select="translate($tl-date, '-', '/')"/>
						<xsl:with-param name="date"
							select="$tl-date"/>
						<xsl:with-param name="short"
							select="$tl-short"/>
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
			<xsl:with-param name="date" select="date:make($tl-year, $month)"/>
		</xsl:call-template>

		<xsl:if test="$month &lt; 12">
			<xsl:call-template name="tl:year-view">
				<xsl:with-param name="month" select="$month + 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="tl:archive-view">
		<xsl:param name="min"  select="tl:pubdate(tl:entry)[1]"/>
		<xsl:param name="max"  select="tl:pubdate(tl:entry)[last()]"/>
		<xsl:param name="year" select="date:year($max)"/>

		<xsl:variable name="count"
			select="count(tl:entry[date:year(tl:pubdate(.)) = $year])"/>

		<section class="archive-year" data-count="{$count}">
			<h1 id="{$year}">
				<a>
					<xsl:call-template name="tl:href">
						<xsl:with-param name="date"  select="$year"/>
					</xsl:call-template>

					<time pubdate="{$year}">
						<xsl:value-of select="$year"/>
					</time>
				</a>
			</h1>

			<xsl:if test="$count &gt; 0">
				<ol class="archive">
					<xsl:for-each select="tl:entry
						[date:year(tl:pubdate(.)) = $year]">
	
						<xsl:sort data-type="number" select="date:seconds(tl:pubdate(.))"
							order="descending"/>
	
						<li>
							<xsl:variable name="date" select="date:format-date(tl:pubdate(.), 'yyyy-MM-dd')"/>

							<time pubdate="{tl:pubdate(.)}">
								<xsl:value-of select="$date"/>
							</time>
	
							<a>
								<xsl:call-template name="tl:href">
									<xsl:with-param name="date"  select="$date"/>
									<xsl:with-param name="short" select="@short"/>
								</xsl:call-template>

								<xsl:copy-of select="tl:entrytitle(.)"/>
							</a>
						</li>
					</xsl:for-each>
				</ol>
			</xsl:if>
		</section>

		<xsl:if test="$year &gt; date:year($min)">
			<xsl:call-template name="tl:archive-view">
				<xsl:with-param name="year" select="$year - 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="tl:title">
		<xsl:choose>
			<xsl:when test="$tl-date">
				<time datetime="{$tl-date}">
					<xsl:value-of select="$tl-date"/>
				</time>
			</xsl:when>

			<xsl:otherwise>
				<xsl:text>Timeline</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tl:pages">
		<xsl:param name="timeline"/>

		<xsl:param name="date"/>
		<xsl:param name="month"/>
		<xsl:param name="year"/>

		<ol class="pages">
<!-- TODO: titles for links -->
<!-- TODO: rel next/prev etc -->
			<li>
				<xsl:call-template name="cal-link">
					<xsl:with-param name="date"  select="$date"/>
					<xsl:with-param name="delta" select="'-P1Y'"/>
					<xsl:with-param name="rel"   select="'prev'"/>
					<xsl:with-param name="next"  select=    "&quot;'&lt;'&quot;"/>
					<xsl:with-param name="skip"  select="&quot;'&lt;&lt;'&quot;"/>
					<xsl:with-param name="dtfmt" select="'yyyy'"/>
					<xsl:with-param name="data"  select="'yyyy'"/>
				</xsl:call-template>
			</li>

			<li class="group">
				<ol>
					<li>
						<xsl:call-template name="cal-link">
							<xsl:with-param name="date"  select="$date"/>
							<xsl:with-param name="delta" select="'-P1M'"/>
							<xsl:with-param name="rel"   select="'prev'"/>
							<xsl:with-param name="next"  select=    "&quot;'&lt;&quot;"/>
							<xsl:with-param name="skip"  select="&quot;'&lt;&lt;&quot;"/>
							<xsl:with-param name="dtfmt" select="'yyyy-MM'"/>
							<xsl:with-param name="data"  select="'M'"/>
						</xsl:call-template>
					</li>

					<xsl:for-each select="str:tokenize('1 2 3 4 5 6 7 8 9 10 11 12')">
						<li>
							<xsl:if test="$month and $month = .">
								<xsl:attribute name="class">
									<xsl:text>current</xsl:text>
								</xsl:attribute>
							</xsl:if>

							<xsl:choose>
								<xsl:when test="$timeline/tl:entry
									[date:same-month(tl:pubdate(.), date:make($year, current()))]">
									<a>
										<xsl:call-template name="tl:href">
											<xsl:with-param name="date" select="date:make($year, .)"/>
										</xsl:call-template>

										<time datetime="{date:make($year, .)}">
											<xsl:value-of select="."/>
										</time>
									</a>
								</xsl:when>

								<xsl:otherwise>
									<time datetime="{date:make($year, .)}">
										<xsl:value-of select="."/>
									</time>
								</xsl:otherwise>
							</xsl:choose>
						</li>
					</xsl:for-each>

					<li>
						<xsl:call-template name="cal-link">
							<xsl:with-param name="date"  select="$date"/>
							<xsl:with-param name="delta" select="'P1M'"/>
							<xsl:with-param name="rel"   select="'prev'"/>
							<xsl:with-param name="next"  select=    "&quot;'&gt;&quot;"/>
							<xsl:with-param name="skip"  select="&quot;'&gt;&gt;&quot;"/>
							<xsl:with-param name="dtfmt" select="'yyyy-MM'"/>
							<xsl:with-param name="data"  select="'M'"/>
						</xsl:call-template>
					</li>
				</ol>
			</li>

			<li>
				<xsl:call-template name="cal-link">
					<xsl:with-param name="date"  select="$date"/>
					<xsl:with-param name="delta" select="'P1Y'"/>
					<xsl:with-param name="rel"   select="'next'"/>
					<xsl:with-param name="next"  select=    "&quot;'&gt;'&quot;"/>
					<xsl:with-param name="skip"  select="&quot;'&gt;&gt;'&quot;"/>
					<xsl:with-param name="dtfmt" select="'yyyy'"/>
					<xsl:with-param name="data"  select="'yyyy'"/>
				</xsl:call-template>
			</li>
		</ol>
	</xsl:template>

	<xsl:template match="tl:timeline" mode="tl-index">
		<xsl:choose>
			<xsl:when test="$tl-year">
				<xsl:call-template name="tl:pages">
					<xsl:with-param name="timeline" select="."/>
					<xsl:with-param name="date"     select="$tl-date"/>
					<xsl:with-param name="month"    select="$tl-month"/>
					<xsl:with-param name="year"     select="$tl-year"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="cutoff" select="tl:cutoff(.)"/>

				<xsl:call-template name="tl:pages">
					<xsl:with-param name="timeline" select="."/>
					<xsl:with-param name="date"     select="$cutoff"/>
					<xsl:with-param name="month"    select="date:month-in-year($cutoff)"/>
					<xsl:with-param name="year"     select="date:year($cutoff)"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tl:calendar">
		<xsl:variable name="date">
			<xsl:choose>
				<xsl:when test="$tl-month">
					<xsl:value-of select="date:make($tl-year, $tl-month)"/>
				</xsl:when>

				<xsl:when test="$tl-year">
					<xsl:value-of select="$tl-year"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$tl-month">
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
				<xsl:when test="$tl-month">
					<xsl:value-of select="date:make($tl-year, $tl-month)"/>
				</xsl:when>

				<xsl:when test="$tl-year">
					<xsl:value-of select="$tl-year"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<ol class="years">
			<xsl:for-each select="tl:entry/h:html/h:head/h:meta
				[@name = 'date']/@content">

				<xsl:sort data-type="number" select="date:year(.)" order="descending"/>
		
				<xsl:variable name="year" select="date:year(.)"/>
		
				<xsl:if test="not(../../../../preceding-sibling::tl:entry
					[date:year(tl:pubdate(.)) = $year])">

					<li>
						<xsl:if test="$tl-year = $year">
							<xsl:attribute name="class">
								<xsl:text>current</xsl:text>
							</xsl:attribute>
						</xsl:if>

						<a>
							<xsl:choose>
								<xsl:when test="$tl-month and $tl-year = $year">
									<xsl:attribute name="rel">
										<xsl:text>directory</xsl:text>
									</xsl:attribute>
								</xsl:when>

								<xsl:when test="not($tl-month) and $tl-year = $year - 1">
									<xsl:attribute name="rel">
										<xsl:text>prev</xsl:text>
									</xsl:attribute>
								</xsl:when>

								<xsl:when test="not($tl-month) and $tl-year = $year + 1">
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
			<xsl:when test="$tl-short">
				<!-- For submitting comments and window.reload()ing -->
				<!-- TODO: maybe this should be done by .htaccess instead -->
<!-- XXX:
				<xsl:variable name="dummy1" select="kxslt:setheader('Cache-control', 'no-store')"/>
				<xsl:variable name="dummy2" select="kxslt:setheader('Pragma',        'no-cache')"/>
				<xsl:variable name="dummy3" select="kxslt:setheader('Expires',       '-1')"/>
-->

				<xsl:apply-templates select="tl:entry
					[date:date($tl-date) = date:date(tl:pubdate(.))
						and $tl-short = @short]"/>
			</xsl:when>

			<xsl:when test="$tl-day">
				<xsl:apply-templates select="tl:entry
					[date:same-day(tl:pubdate(.), $tl-date)]">
					<xsl:sort select="date:seconds(tl:pubdate(.))"
						data-type="number" order="descending"/>
				</xsl:apply-templates>
			</xsl:when>

			<xsl:when test="$tl-month">
				<xsl:apply-templates select="tl:entry
					[date:same-month(tl:pubdate(.), date:make($tl-year, $tl-month))]">
					<xsl:sort select="date:seconds(tl:pubdate(.))"
						data-type="number" order="descending"/>
				</xsl:apply-templates>
			</xsl:when>

			<xsl:when test="$tl-year">
				<section class="year-view">
					<xsl:call-template name="tl:year-view"/>
				</section>
			</xsl:when>

			<xsl:otherwise>
				<xsl:variable name="cutoff" select="tl:cutoff(.)"/>

				<!-- TODO: interject with month headings -->
				<xsl:apply-templates select="tl:entry
					[date:year(tl:pubdate(.)) &gt; date:year($cutoff)
					 or (date:year(tl:pubdate(.)) = date:year($cutoff)
						and date:month-in-year(tl:pubdate(.)) &gt;= date:month-in-year($cutoff))]">
					<xsl:sort select="date:seconds(tl:pubdate(.))"
						data-type="number" order="descending"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tl:timeline" mode="tl-body">
		<xsl:variable name="r">
			<xsl:call-template name="tl:content-body"/>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="count(common:node-set($r)/node()) = 0">
				<span class="noentries">
					<xsl:text>(no entries)</xsl:text>
				</span>
			</xsl:when>

			<xsl:otherwise>
				<xsl:copy-of select="$r"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tl:timeline" mode="tl-archive">
		<section class="archive-view">
			<xsl:call-template name="tl:archive-view"/>
		</section>
	</xsl:template>

</xsl:stylesheet>

