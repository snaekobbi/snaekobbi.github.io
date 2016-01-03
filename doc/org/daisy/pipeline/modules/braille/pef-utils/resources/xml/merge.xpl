<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pef:merge" name="merge"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:pef="http://www.daisy.org/ns/2008/pef"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-inline-prefixes="px p pxi xsl"
    version="1.0">
    
    <!--
        Merge all PEFs on the source port into a single PEF.
        * If level='volume', the volumes of all PEFs are concatenated.
        * If level='section', the volumes of all PEFs are merged into a single volume.
    -->
    
    <p:input port="source" sequence="true" primary="true" px:media-type="application/x-pef+xml"/>
    <p:input port="parameters" kind="parameter" primary="true"/>
    <p:output port="result" sequence="false" primary="true" px:media-type="application/x-pef+xml"/>
    <p:option name="level" select="'volume'"/>
    
    <p:declare-step type="pxi:merge-volumes" name="merge-volumes">
        <!--
            Merge all volumes on the source port into a single volume.
            The sections of all volumes are concatenated.
        -->
        <p:input port="source" sequence="true"/>
        <p:output port="result" sequence="false"/>
        <p:split-sequence test="position()=1" name="split"/>
        <p:identity name="first"/>
        <p:for-each>
            <p:iteration-source>
                <p:pipe step="split" port="not-matched"/>
            </p:iteration-source>
            <p:xslt>
                <p:input port="stylesheet">
                    <p:inline>
                        <xsl:stylesheet version="2.0">
                            <xsl:template match="/*">
                                <xsl:copy>
                                    <xsl:sequence select="@*|text()"/>
                                    <xsl:apply-templates select="*"/>
                                </xsl:copy>
                            </xsl:template>
                            <xsl:template match="*[local-name()='section']">
                                <xsl:copy>
                                    <xsl:sequence select="(@cols,parent::*/@cols)[1]"/>
                                    <xsl:sequence select="(@duplex,parent::*/@duplex)[1]"/>
                                    <xsl:sequence select="(@rowgap,parent::*/@rowgap)[1]"/>
                                    <xsl:sequence select="(@rows,parent::*/@rows)[1]"/>
                                    <xsl:sequence select="node()"/>
                                </xsl:copy>
                            </xsl:template>
                        </xsl:stylesheet>
                    </p:inline>
                </p:input>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
            </p:xslt>
        </p:for-each>
        <p:identity name="rest"/>
        <p:insert match="/*" position="last-child">
            <p:input port="source">
                <p:pipe step="first" port="result"/>
            </p:input>
            <p:input port="insertion" select="//pef:section">
                <p:pipe step="rest" port="result"/>
            </p:input>
        </p:insert>
        <p:xslt>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet version="2.0">
                        <xsl:template match="/*">
                            <xsl:copy>
                                <xsl:sequence select="@*|text()"/>
                                <xsl:apply-templates select="*"/>
                            </xsl:copy>
                        </xsl:template>
                        <xsl:template match="*[local-name()='section']">
                            <xsl:copy>
                                <xsl:if test="string(@cols)!=string(parent::*/@cols)">
                                    <xsl:sequence select="@cols"/>
                                </xsl:if>
                                <xsl:if test="string(@duplex)!=string(parent::*/@duplex)">
                                    <xsl:sequence select="@duplex"/>
                                </xsl:if>
                                <xsl:if test="string(@rowgap)!=string(parent::*/@rowgap)">
                                    <xsl:sequence select="@rowgap"/>
                                </xsl:if>
                                <xsl:if test="string(@rows)!=string(parent::*/@rows)">
                                    <xsl:sequence select="@rows"/>
                                </xsl:if>
                                <xsl:sequence select="node()"/>
                            </xsl:copy>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:declare-step>
    
    <p:xslt template-name="initial">
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet version="2.0" xmlns="http://www.daisy.org/ns/2008/pef">
                    <xsl:param name="title" select="''"/>
                    <xsl:param name="creator" select="''"/>
                    <xsl:template name="initial">
                        <head>
                            <meta>
                                <xsl:if test="$title != ''">
                                    <dc:title>
                                        <xsl:sequence select="$title"/>
                                    </dc:title>
                                </xsl:if>
                                <xsl:if test="$creator != ''">
                                    <dc:creator>
                                        <xsl:sequence select="$creator"/>
                                    </dc:creator>
                                </xsl:if>
                                <dc:date>
                                    <xsl:sequence select="current-date()"/>
                                </dc:date>
                                <dc:format>
                                    <xsl:text>application/x-pef+xml</xsl:text>
                                </dc:format>
                                <dc:identifier>
                                    <xsl:text>$identifier</xsl:text>
                                </dc:identifier>
                            </meta>
                        </head>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    
    <p:uuid match="//dc:identifier/text()[1]" name="head"/>
    
    <p:choose>
        <p:when test="$level='volume'">
            <p:identity>
                <p:input port="source" select="//pef:volume">
                    <p:pipe step="merge" port="source"/>
                </p:input>
            </p:identity>
        </p:when>
        <p:otherwise>
            <pxi:merge-volumes>
                <p:input port="source" select="//pef:volume">
                    <p:pipe step="merge" port="source"/>
                </p:input>
            </pxi:merge-volumes>
        </p:otherwise>
    </p:choose>
    
    <p:wrap-sequence wrapper="body" wrapper-namespace="http://www.daisy.org/ns/2008/pef" name="body"/>
    
    <p:wrap-sequence wrapper="pef" wrapper-namespace="http://www.daisy.org/ns/2008/pef">
        <p:input port="source">
            <p:pipe step="head" port="result"/>
            <p:pipe step="body" port="result"/>
        </p:input>
    </p:wrap-sequence>
    
    <p:add-attribute match="/pef:pef" attribute-name="version" attribute-value="2008-1"/>
    
</p:declare-step>
