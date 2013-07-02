<?xml version="1.0"?>

<!--
	$Id: calendar.xsl 2 2010-03-23 07:55:50Z kate $

	XSLT-Generated monthly calendars.

	Adapted from:
	http://neilang.com/entries/generating-a-calendar-using-xslt/
-->

<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exslt="http://exslt.org/common" 
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:str="http://exslt.org/strings"
	xmlns:cal="http://xml.elide.org/calendar"

	exclude-result-prefixes="exslt date str cal">


	<!--
		Override this for some useful output per day.
	-->
	<xsl:template name="cal:content">
		<xsl:param name="date"/>

		<xsl:value-of select="date:day-in-month($date)"/>
	</xsl:template>

	<!--
		Override this to customise a caption.
		You could output a <tr> instead, for example.
	-->
	<xsl:template name="cal:caption">
		<xsl:param name="date"/>

		<caption>
			<xsl:value-of select="date:month-name($date)"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="date:year($date)"/>
		</caption>
	</xsl:template>

	<!--
		Entry point
	-->
	<xsl:template name="cal:calendar">
		<xsl:param name="date" select="date:date()"/>

		<table class="calendar" summary="Monthly calendar">
			<xsl:call-template name="cal:caption">
				<xsl:with-param name="date" select="$date"/>
			</xsl:call-template>

			<tr>
				<!-- TODO: exslt abbr-name() -->
				<th abbr="Sunday">   <xsl:text>Su</xsl:text></th>
				<th abbr="Monday">   <xsl:text>Mo</xsl:text></th>
				<th abbr="Tuesday">  <xsl:text>Tu</xsl:text></th>
				<th abbr="Wednesday"><xsl:text>We</xsl:text></th>
				<th abbr="Thursday"> <xsl:text>Th</xsl:text></th>
				<th abbr="Friday">   <xsl:text>Fr</xsl:text></th>
				<th abbr="Saturday"> <xsl:text>Sa</xsl:text></th>
			</tr>

			<xsl:call-template name="cal:week">
				<xsl:with-param name="date" select="$date"/>
			</xsl:call-template>
		</table>
	</xsl:template>


	<xsl:template name="cal:days-in-month">
		<xsl:param name="date"/>

		<xsl:variable name="month" select="date:month-in-year($date)"/>
		<xsl:variable name="year"  select="date:year($date)"/>

		<xsl:choose>
			<xsl:when test="$month =  1
			             or $month =  3
			             or $month =  5
			             or $month =  7
			             or $month =  8
			             or $month = 10
			             or $month = 12">
				<xsl:text>31</xsl:text>
			</xsl:when>
			<xsl:when test="$month = 2">
				<xsl:choose>
					<xsl:when test="date:leap-year($date)">
						<xsl:text>29</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>28</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>30</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="cal:first-day-in-week-for-month">
		<xsl:param name="date"/>

		<xsl:variable name="month" select="date:month-in-year($date)"/>
		<xsl:variable name="year"  select="date:year($date)"/>

		<xsl:value-of select="date:day-in-week(concat($year, '-',
			str:align($month, '00', 'right'), '-01'))"/>
	</xsl:template>

	<xsl:template name="cal:week">
		<xsl:param name="date"/>

		<xsl:param name="week" select="1"/>
		<xsl:param name="day"  select="1"/>

		<xsl:variable name="days-in-month">
			<xsl:call-template name="cal:days-in-month">
				<xsl:with-param name="date" select="$date"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="first-day-in-week-for-month">
			<xsl:call-template name="cal:first-day-in-week-for-month">
				<xsl:with-param name="date" select="$date"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="weeks-in-month"
			select="($days-in-month + $first-day-in-week-for-month - 1) div 7"/>

		<tr>
			<xsl:call-template name="cal:day">
				<xsl:with-param name="date" select="$date"/>
				<xsl:with-param name="day"  select="$day"/>
			</xsl:call-template>
		</tr>

		<xsl:if test="$weeks-in-month &gt; $week">
			<xsl:call-template name="cal:week">
				<xsl:with-param name="date" select="$date"/>
				<xsl:with-param name="week" select="$week + 1"/>
				<xsl:with-param name="day"  select="$week * 7 -
					($first-day-in-week-for-month - 2)"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="cal:day">
		<xsl:param name="date"/>
		<xsl:param name="day"/>

		<xsl:param name="count" select="1"/>

		<xsl:variable name="days-in-month">
			<xsl:call-template name="cal:days-in-month">
				<xsl:with-param name="date" select="$date"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="first-day-in-week-for-month">
			<xsl:call-template name="cal:first-day-in-week-for-month">
				<xsl:with-param name="date" select="$date"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="($day = 1 and $count != $first-day-in-week-for-month)
				or $day &gt; $days-in-month">
				<td class="empty"/>

				<xsl:if test="$count &lt; 7">
					<xsl:call-template name="cal:day">
						<xsl:with-param name="date"  select="$date"/>
						<xsl:with-param name="day"   select="$day"/>
						<xsl:with-param name="count" select="$count + 1"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<td>
					<xsl:if test="concat(substring($date, 1, 7), '-', str:align($day, '00', 'right')) = date:date()">
						<xsl:attribute name="class">
							<xsl:text>today</xsl:text>
						</xsl:attribute>
					</xsl:if>

					<xsl:variable name="month" select="date:month-in-year($date)"/>
					<xsl:variable name="year"  select="date:year($date)"/>

					<xsl:call-template name="cal:content">
						<xsl:with-param name="date"
							select="date:date(concat($year, '-',
								str:align($month, '00', 'right'), '-',
								str:align($day,   '00', 'right')))"/>
					</xsl:call-template>
				</td>

				<xsl:if test="$count &lt; 7">
					<xsl:call-template name="cal:day">
						<xsl:with-param name="date"  select="$date"/>
						<xsl:with-param name="day"   select="$day + 1"/>
						<xsl:with-param name="count" select="$count + 1"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>

