<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>
<xsl:template match="/">
    
    <html>
        <head>
            <title>Wonders of the World</title>
        </head>
        <body>
            <h1>Seven Wonders of the Ancient World</h1>
            <p>These ancient wonders are
                <xsl:for-each select="ancient_wonders/wonder/name[@language='English']">
                    <xsl:value-of select="."/> - 
                    <xsl:value-of select="string-length()"/> <!-- num characters of value of node name -->
                    <xsl:choose>
                        <xsl:when test="position() = last()">.</xsl:when>
                        <xsl:when test="position() = last()-1"> and </xsl:when>
                        <xsl:otherwise>, </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                Of these wonders
                <!-- get wonders that are destroyed by earthquake. [. = 'earthquake'] used to determine how it was destroyed
                    note: . (period) is used to select current node -->
                <xsl:value-of select="count(ancient_wonders/wonder/history/how_destroyed[. = 'earthquake'])"/>
                were destroyed by earthquake,
                <xsl:value-of select="count(ancient_wonders/wonder/history/how_destroyed[. = 'fire'])"/>
                were destroyed by fire, and
                <!-- count all child nodes named wonder and subtract count of wonders that was destroyed -->
                <xsl:value-of select="count(//wonder) - count(//how_destroyed)"/>
                are still standing.
            </p>
            <!-- choose nth wonder by using wonder[n] -->
            <p>This is not english: <xsl:value-of select="ancient_wonders/wonder[4]/name[@language != 'English']"/></p>
            <!-- select all 'file' attribute of current node's children nodes -->
            <xsl:apply-templates select="//*/@file"/>
            <table border="1">
                <tr>
                    <th>Wonder Name</th>
                    <th>City</th>
                    <th>Country</th>
                    <th>Height</th>
                    <th>Duration</th>
                    <th>Years Standing</th>
                    <th>Source</th>
                </tr>
                <!-- only display wonders whose height is greater than 100 -->
                <xsl:apply-templates select="ancient_wonders/wonder[height &gt; 100]">
                    <xsl:sort select="name" order="ascending" data-type="text"/>
                </xsl:apply-templates>
                <tr>
                    <td colspan="7" align="right">Average height of all ancient wonders:
                    <!-- get average height of all wonders: height is not equal to 0 == height exists -->
                    <xsl:value-of select="format-number(sum(/ancient_wonders/wonder/height) div count(/ancient_wonders/wonder/height[. != 0]), '#,000.0')"/></td>
                </tr>
            </table>
        </body>
    </html>
    
</xsl:template>

<xsl:template match="//*/@file">
    <!-- display file attribute value of current node -->
    <p align="center">
        <img>
            <!-- apply attribute "src" value for img with code below -->
            <xsl:attribute name="src">
                <xsl:value-of select="."/>
            </xsl:attribute>
            <!-- divide height and width by 2 and use ceiling() to round up to nearest integer -->
            <xsl:attribute name="width">
                <xsl:value-of select="ceiling(../@w div 2)"/>
            </xsl:attribute>
            <xsl:attribute name="height">
                <xsl:value-of select="ceiling(../@h div 2)"/>
            </xsl:attribute>
        </img><br/>
        <!-- parent of 'file' attribute is 'main_image'. Parent of 'main_image' is 'wonder'. Thus, ../../location -->
        <!-- <xsl:value-of select="../../substring-before(location, ',')"/> whyyyyyy??? -->
        <xsl:value-of select="../../name[@language = 'English']"/><br/>
        <xsl:value-of select="../../history/story"/>
    </p>
</xsl:template>

<!-- do not use @ when testing an attribute value -->
<xsl:template match="wonder[height &gt; 100]">
    <tr>
        <td><a>
            <xsl:attribute name="href">
                #<xsl:value-of select="name[@language='English']"/>
            </xsl:attribute>
            <!-- translate() here: lower case to upper case. If vice versa, interchange positions of alphabets -->
            <strong><xsl:value-of select="translate(name[@language='English'], 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/></strong><br/>
            <xsl:apply-templates select="name[@language!='English']"/>
        </a></td>
        <td>
            <xsl:value-of select="substring-before(location, ',')"/>
        </td>
        <td>
            <xsl:value-of select="substring-after(location, ',')"/>
        </td>
        <td>
            <xsl:value-of select="height"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="height/@units"/><br/>
            (<xsl:value-of select="format-number(height * .3048 * 1000, '###,000.0')"/> cm)
        </td>
        <xsl:apply-templates select="history"/>
    </tr>
</xsl:template>

<xsl:template match="history">
    <td>
        <xsl:value-of select="year_built"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="/ancient_wonders/wonder/history/*/@era"/>
        <xsl:text> - </xsl:text>
        <xsl:choose>
            <xsl:when test="year_destroyed &gt; 0">
                <xsl:value-of select="year_destroyed"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="year_destroyed/@era"/>
            </xsl:when>
            <xsl:otherwise>
                now
            </xsl:otherwise>
        </xsl:choose>
    </td>
    <td>
        <xsl:choose>
            <xsl:when test="year_destroyed/@era = 'BC'">
                <!-- this is not correct computation. Only intended for practice of format-number: negative number in parenthesis
                instead of showing negative sign (-) -->
                <xsl:value-of select="format-number(year_destroyed - year_built, '##0;(0)')"/>
            </xsl:when>
            <xsl:when test="year_destroyed/@era = 'AD'">
                <xsl:value-of select="year_built + year_destroyed - 1"/>
            </xsl:when>
            <xsl:otherwise>
                Still standing
            </xsl:otherwise>
        </xsl:choose>
    </td>
    <td>
        <xsl:value-of select="../source/@sectionid"/>
    </td>
</xsl:template>

<xsl:template match="name[@language !=' English']">
    (<em><xsl:value-of select="."/></em>)
</xsl:template>        
</xsl:stylesheet>