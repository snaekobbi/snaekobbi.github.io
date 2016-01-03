<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:include href="library.xsl"/>
    
    <xsl:template match="css:_">
        <xsl:copy>
            <xsl:sequence select="@*"/>
            <xsl:call-template name="apply-templates"/>
        </xsl:copy>
    </xsl:template>
    
    <!--
        unwrap inline boxes that contain block boxes
    -->
    <xsl:template match="css:box[not(@type='block')
                                 and descendant::css:box[@type='block']]">
        <xsl:variable name="properties" as="element()*">
            <xsl:call-template name="inherit-properties"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="@css:* or not(parent::*)">
                <xsl:element name="css:_">
                    <xsl:sequence select="@css:*"/>
                    <xsl:call-template name="apply-templates">
                        <xsl:with-param name="pending-properties" select="$properties" tunnel="yes"/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="apply-templates">
                    <xsl:with-param name="pending-properties" select="$properties" tunnel="yes"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:box">
        <xsl:variable name="properties" as="element()*">
            <xsl:call-template name="inherit-properties"/>
        </xsl:variable>
        <xsl:copy>
            <xsl:sequence select="@* except @style"/>
            <xsl:sequence select="css:style-attribute(css:serialize-declaration-list($properties))"/>
            <xsl:call-template name="apply-templates">
                <xsl:with-param name="container" select="." tunnel="yes"/>
                <xsl:with-param name="pending-properties" select="()" tunnel="yes"/>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="apply-templates">
        <xsl:param name="container" as="element()?" select="()" tunnel="yes"/>
        <xsl:for-each-group select="*|text()" group-adjacent="boolean(descendant-or-self::css:box[@type='block'])">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <xsl:for-each select="current-group()">
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$container/self::css:box[@type='inline']">
                    <xsl:sequence select="current-group()"/>
                </xsl:when>
                <xsl:when test="matches(string-join(current-group()/string(.), ''), '^[\s&#x2800;]*$')
                                and not(current-group()/(
                                          descendant-or-self::css:white-space
                                         |descendant-or-self::css:string
                                         |descendant-or-self::css:counter
                                         |descendant-or-self::css:text
                                         |descendant-or-self::css:leader))">
                    <xsl:sequence select="current-group()"/>
                </xsl:when>
                <xsl:otherwise>
                    <css:box type="inline">
                        <xsl:sequence select="current-group()"/>
                    </css:box>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
    
    <!--
        because some elements are unwrapped, property values must be computed and inherit must be concretized
    -->
    <xsl:template name="inherit-properties">
        <xsl:param name="pending-properties" as="element()*" select="()" tunnel="yes"/>
        <xsl:variable name="properties" as="element()*">
            <xsl:apply-templates select="." mode="css:computed-properties">
                <xsl:with-param name="concretize-inherit" select="false()"/>
                <xsl:with-param name="concretize-initial" select="false()"/>
                <xsl:with-param name="validate" select="false()"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:sequence select="for $p in distinct-values(($pending-properties/@name,$properties/@name))
                              return if ((not($properties[@name=$p]) and css:is-inherited($p))
                                          or $properties[@name=$p][@value='inherit'])
                                     then $pending-properties[@name=$p][last()]
                                     else $properties[@name=$p][last()]"/>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:sequence select="."/>
    </xsl:template>
    
</xsl:stylesheet>
