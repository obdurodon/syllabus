<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:djb="http://www.obdurodon.org">
    <xsl:output method="xhtml" indent="yes"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
        omit-xml-declaration="yes"/>
    <xsl:variable name="start-date" select="xs:date('2014-08-25')" as="xs:date"/>
    <xsl:variable name="end-date" select="xs:date('2014-12-05')" as="xs:date"/>
    <xsl:variable name="fall-break" select="xs:date('2014-10-13')" as="xs:date"/>
    <xsl:variable name="labor-day" select="xs:date('2014-09-01')" as="xs:date"/>
    <xsl:variable name="thanksgiving-wednesday" select="xs:date('2014-11-26')" as="xs:date"/>
    <xsl:function name="djb:day-of-week" as="xs:string">
        <xsl:param name="date" as="xs:date"/>
        <xsl:sequence select="format-date($date,'[FNn,3-3]')"/>
    </xsl:function>
    <xsl:function name="djb:month-date" as="xs:string">
        <xsl:param name="date" as="xs:date"/>
        <xsl:sequence select="format-date($date,'[M01]-[D01]')"/>
    </xsl:function>
    <xsl:function name="djb:fall-break" as="xs:date">
        <xsl:param name="date" as="xs:date"/>
        <xsl:sequence select="$date + xs:dayTimeDuration('P1D')"/>
    </xsl:function>
    <xsl:function name="djb:thanksgiving" as="xs:boolean">
        <xsl:param name="date" as="xs:date"/>
        <xsl:sequence
            select="$date ge $thanksgiving-wednesday and $date le $thanksgiving-wednesday + xs:dayTimeDuration('P2D')"
        />
    </xsl:function>
    <xsl:function name="djb:add-row" as="element(html:tr)+">
        <xsl:param name="date" as="xs:date"/>
        <xsl:variable name="adjustment" select="if ($date eq $fall-break) then 'P1D' else 'P0D'"
            as="xs:string"/>
        <tr>
            <td>
                <xsl:value-of select="djb:day-of-week($date + xs:dayTimeDuration($adjustment))"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="djb:month-date($date + xs:dayTimeDuration($adjustment))"/>
            </td>
            <td>
                <xsl:choose>
                    <xsl:when test="$date eq $labor-day">
                        <xsl:text>Labor day; no class</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="$date = ($thanksgiving-wednesday,$thanksgiving-wednesday + xs:dayTimeDuration('P2D'))">
                        <xsl:text>Thanksgiving recess; no class</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <ul>
                            <xsl:if
                                test="$date gt $start-date + xs:dayTimeDuration('P7D') and $date lt $end-date - xs:dayTimeDuration('P7D')">
                                <!-- no blog or discussion board first or last week -->
                                <xsl:if test="djb:day-of-week($date) eq 'Fri'">
                                    <li>
                                        <xsl:text>Blog response due </xsl:text>
                                        <xsl:value-of
                                            select="if ($date + xs:dayTimeDuration('P3D') eq $fall-break) then 'Tuesday' else 'Monday'"
                                        />
                                    </li>
                                    <li>
                                        <xsl:text>Discussion-board contribution due </xsl:text>
                                        <xsl:value-of
                                            select="if ($date + xs:dayTimeDuration('P3D') eq $fall-break) then 'Tuesday' else 'Monday'"
                                        />
                                    </li>
                                </xsl:if>
                                <xsl:if test="djb:day-of-week($date) eq 'Wed'">
                                    <li>Blog posting due Friday</li>
                                </xsl:if>
                            </xsl:if>
                            <li>Assignments go here</li>
                        </ul>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
        <xsl:if test="$date lt $end-date">
            <xsl:variable name="skip"
                select="if (djb:day-of-week($date) eq 'Fri') then 'P3D' else 'P2D'"/>
            <xsl:sequence select="djb:add-row($date + xs:dayTimeDuration($skip))"/>
        </xsl:if>
    </xsl:function>
    <xsl:template match="/">
        <html>
            <head>
                <title>Syllabus</title>
            </head>
            <body>
                <h1>Syllabus</h1>
                <table border="1">
                    <tr>
                        <th>Date</th>
                        <th>Assignment</th>
                    </tr>
                    <xsl:sequence select="djb:add-row($start-date)"/>
                </table>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
