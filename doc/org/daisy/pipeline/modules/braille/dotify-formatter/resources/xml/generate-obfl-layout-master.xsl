<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.daisy.org/ns/2011/obfl"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:obfl="http://www.daisy.org/ns/2011/obfl"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
    
    <xsl:variable name="empty-string" as="element()">
        <string value=""/>
    </xsl:variable>
    
    <xsl:variable name="empty-field" as="element()">
        <field>
            <xsl:sequence select="$empty-string"/>
        </field>
    </xsl:variable>
    
    <xsl:function name="obfl:generate-layout-master">
        <xsl:param name="page-stylesheet" as="xs:string"/>
        <xsl:param name="name" as="xs:string"/>
        <xsl:variable name="page-stylesheet" as="element()*" select="css:parse-stylesheet($page-stylesheet)"/>
        <xsl:variable name="right-page-stylesheet" as="element()*" select="css:parse-stylesheet($page-stylesheet[@selector=':right']/@style)"/>
        <xsl:variable name="left-page-stylesheet" as="element()*" select="css:parse-stylesheet($page-stylesheet[@selector=':left']/@style)"/>
        <xsl:variable name="default-page-stylesheet" as="element()*">
            <xsl:choose>
                <xsl:when test="$right-page-stylesheet or $left-page-stylesheet">
                    <xsl:sequence select="css:parse-stylesheet($page-stylesheet[not(@selector)]/@style)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$page-stylesheet"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="default-page-properties" as="element()*"
                      select="css:parse-declaration-list($default-page-stylesheet[not(@selector)]/@style)"/>
        <xsl:variable name="size" as="xs:string"
                      select="($default-page-properties[@name='size'][css:is-valid(.)]/@value, css:initial-value('size'))[1]"/>
        <layout-master name="{$name}" duplex="true" page-number-variable="page"
                       page-width="{tokenize($size, '\s+')[1]}" page-height="{tokenize($size, '\s+')[2]}">
            <xsl:if test="$right-page-stylesheet">
                <!--
                    FIXME: is this influenced by initial-page-number?
                -->
                <template use-when="(= (% $page 2) 1)">
                    <xsl:call-template name="template">
                        <xsl:with-param name="stylesheet" select="$right-page-stylesheet"/>
                        <xsl:with-param name="page-side" tunnel="yes" select="'right'"/>
                    </xsl:call-template>
                </template>
            </xsl:if>
            <xsl:if test="$left-page-stylesheet">
                <template use-when="(= (% $page 2) 0)">
                    <xsl:call-template name="template">
                        <xsl:with-param name="stylesheet" select="$left-page-stylesheet"/>
                        <xsl:with-param name="page-side" tunnel="yes" select="'left'"/>
                    </xsl:call-template>
                </template>
            </xsl:if>
            <default-template>
                <xsl:call-template name="template">
                    <xsl:with-param name="stylesheet" select="$default-page-stylesheet"/>
                </xsl:call-template>
            </default-template>
        </layout-master>
    </xsl:function>
    
    <xsl:template name="template">
        <xsl:param name="stylesheet" as="element()*" required="yes"/>
        <xsl:variable name="top-left" as="element()*">
            <xsl:call-template name="fields">
                <xsl:with-param name="margin-stylesheet" select="$stylesheet[@selector='@top-left'][1]/@style"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="top-center" as="element()*">
            <xsl:call-template name="fields">
                <xsl:with-param name="margin-stylesheet" select="$stylesheet[@selector='@top-center'][1]/@style"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="top-right" as="element()*">
            <xsl:call-template name="fields">
                <xsl:with-param name="margin-stylesheet" select="$stylesheet[@selector='@top-right'][1]/@style"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="bottom-left" as="element()*">
            <xsl:call-template name="fields">
                <xsl:with-param name="margin-stylesheet" select="$stylesheet[@selector='@bottom-left'][1]/@style"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="bottom-center" as="element()*">
            <xsl:call-template name="fields">
                <xsl:with-param name="margin-stylesheet" select="$stylesheet[@selector='@bottom-center'][1]/@style"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="bottom-right" as="element()*">
            <xsl:call-template name="fields">
                <xsl:with-param name="margin-stylesheet" select="$stylesheet[@selector='@bottom-right'][1]/@style"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="properties" as="element()*"
                      select="css:parse-declaration-list($stylesheet[not(@selector)]/@style)"/>
        <xsl:variable name="margin-top" as="xs:integer"
                      select="max(($properties[@name='margin-top'][css:is-valid(.)]/xs:integer(@value),0))"/>
        <xsl:variable name="margin-bottom" as="xs:integer"
                      select="max(($properties[@name='margin-bottom'][css:is-valid(.)]/xs:integer(@value),0))"/>
        <xsl:variable name="margin-left" as="xs:integer"
                      select="max(($properties[@name='margin-left'][css:is-valid(.)]/xs:integer(@value),0))"/>
        <xsl:variable name="margin-right" as="xs:integer"
                      select="max(($properties[@name='margin-right'][css:is-valid(.)]/xs:integer(@value),0))"/>
        <xsl:choose>
            <xsl:when test="exists(($top-left, $top-center, $top-right)) or $margin-top &gt; 0">
                <xsl:call-template name="headers">
                    <xsl:with-param name="times" select="$margin-top"/>
                    <xsl:with-param name="left" select="$top-left"/>
                    <xsl:with-param name="center" select="$top-center"/>
                    <xsl:with-param name="right" select="$top-right"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <header/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="exists(($bottom-left, $bottom-center, $bottom-right)) or $margin-bottom &gt; 0">
                <xsl:call-template name="footers">
                    <xsl:with-param name="times" select="$margin-bottom"/>
                    <xsl:with-param name="left" select="$bottom-left"/>
                    <xsl:with-param name="center" select="$bottom-center"/>
                    <xsl:with-param name="right" select="$bottom-right"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <footer/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="margin-region">
            <xsl:with-param name="margin-stylesheet" select="$stylesheet[@selector='@left'][1]/@style"/>
            <xsl:with-param name="side" select="'left'"/>
            <xsl:with-param name="min-width" select="$margin-left"/>
        </xsl:call-template>
        <xsl:call-template name="margin-region">
            <xsl:with-param name="margin-stylesheet" select="$stylesheet[@selector='@right'][1]/@style"/>
            <xsl:with-param name="side" select="'right'"/>
            <xsl:with-param name="min-width" select="$margin-right"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="headers"> <!-- obfl:header* -->
        <xsl:param name="times" as="xs:integer" required="yes"/>
        <xsl:param name="left" as="element()*" required="yes"/> <!-- obfl:field* -->
        <xsl:param name="center" as="element()*" required="yes"/> <!-- obfl:field* -->
        <xsl:param name="right" as="element()*" required="yes"/> <!-- obfl:field* -->
        <xsl:if test="exists(($left, $center, $right)) or $times &gt; 0">
            <header>
                <xsl:sequence select="($left,$empty-field)[1]"/>
                <xsl:sequence select="($center,$empty-field)[1]"/>
                <xsl:sequence select="($right,$empty-field)[1]"/>
            </header>
            <xsl:call-template name="headers">
                <xsl:with-param name="times" select="$times - 1"/>
                <xsl:with-param name="left" select="$left[position()&gt;1]"/>
                <xsl:with-param name="center" select="$center[position()&gt;1]"/>
                <xsl:with-param name="right" select="$right[position()&gt;1]"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="footers"> <!-- obfl:footer* -->
        <xsl:param name="times" as="xs:integer" required="yes"/>
        <xsl:param name="left" as="element()*" required="yes"/> <!-- obfl:field* -->
        <xsl:param name="center" as="element()*" required="yes"/> <!-- obfl:field* -->
        <xsl:param name="right" as="element()*" required="yes"/> <!-- obfl:field* -->
        <xsl:if test="exists(($left, $center, $right)) or $times &gt; 0">
            <xsl:call-template name="footers">
                <xsl:with-param name="times" select="$times - 1"/>
                <xsl:with-param name="left" select="$left[position()&lt;last()]"/>
                <xsl:with-param name="center" select="$center[position()&lt;last()]"/>
                <xsl:with-param name="right" select="$right[position()&lt;last()]"/>
            </xsl:call-template>
            <footer>
                <xsl:sequence select="($empty-field,$left)[last()]"/>
                <xsl:sequence select="($empty-field,$center)[last()]"/>
                <xsl:sequence select="($empty-field,$right)[last()]"/>
            </footer>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="fields" as="element()*"> <!-- obfl:field* -->
        <xsl:param name="margin-stylesheet" as="xs:string?"/>
        <xsl:variable name="properties" as="element()*" select="css:parse-declaration-list($margin-stylesheet)"/>
        <xsl:variable name="white-space" as="xs:string" select="($properties[@name='white-space']/@value,'normal')[1]"/>
        <xsl:variable name="text-transform" as="xs:string" select="($properties[@name='text-transform']/@value,'auto')[1]"/>
        <xsl:variable name="content" as="element()*">
            <xsl:apply-templates select="css:parse-content-list($properties[@name='content'][1]/@value,())" mode="eval-content-list-top-bottom">
                <xsl:with-param name="white-space" select="$white-space"/>
                <xsl:with-param name="text-transform" select="$text-transform"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:for-each-group select="$content" group-ending-with="obfl:br">
            <field>
                <xsl:sequence select="if (current-group()[not(self::obfl:br)])
                                      then current-group()[not(self::obfl:br)]
                                      else $empty-string"/>
            </field>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template name="margin-region" as="element()?"> <!-- obfl:margin-region? -->
        <xsl:param name="margin-stylesheet" as="xs:string?"/>
        <xsl:param name="side" as="xs:string" required="yes"/>
        <xsl:param name="min-width" as="xs:integer" required="yes"/>
        <xsl:variable name="properties" as="element()*" select="css:parse-declaration-list($margin-stylesheet)"/>
        <xsl:variable name="indicators" as="element()*">
            <xsl:apply-templates select="css:parse-content-list($properties[@name='content'][1]/@value,())" mode="eval-content-list-left-right"/>
        </xsl:variable>
        <xsl:if test="exists($indicators) or $min-width &gt; 0">
            <margin-region align="{$side}" width="{max((count($indicators),$min-width))}">
                <indicators>
                    <xsl:sequence select="$indicators"/>
                </indicators>
            </margin-region>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:string[@value]" mode="eval-content-list-top-bottom">
        <xsl:param name="white-space" as="xs:string" select="'normal'"/>
        <xsl:param name="text-transform" as="xs:string" select="'auto'"/>
        <xsl:choose>
            <xsl:when test="$white-space=('pre-wrap','pre-line')">
                <!--
                    TODO: wrapping is not allowed, warn if content is clipped
                -->
                <xsl:analyze-string select="string(@value)" regex="\n">
                    <xsl:matching-substring>
                        <br/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:choose>
                            <xsl:when test="$white-space='pre-wrap'">
                                <string value="{replace(.,'\s','&#x00A0;')}">
                                    <xsl:if test="not($text-transform=('none','auto'))">
                                        <xsl:attribute name="text-style" select="concat('text-transform:',$text-transform)"/>
                                    </xsl:if>
                                </string>
                            </xsl:when>
                            <xsl:otherwise>
                                <string value="{.}">
                                    <xsl:if test="not($text-transform=('none','auto'))">
                                        <xsl:attribute name="text-style" select="concat('text-transform:',$text-transform)"/>
                                    </xsl:if>
                                </string>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <string value="{string(@value)}">
                    <xsl:if test="not($text-transform=('none','auto'))">
                        <xsl:attribute name="text-style" select="concat('text-transform:',$text-transform)"/>
                    </xsl:if>
                </string>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:counter[not(@target)][@name='page']" mode="eval-content-list-top-bottom">
        <xsl:param name="white-space" as="xs:string" select="'normal'"/>
        <xsl:param name="text-transform" as="xs:string" select="'auto'"/>
        <xsl:if test="$white-space!='normal'">
            <xsl:message select="concat('white-space:',$white-space,' could not be applied to target-counter(',@name,')')"/>
        </xsl:if>
        <current-page number-format="{if (@style=('roman', 'upper-roman', 'lower-roman', 'upper-alpha', 'lower-alpha'))
                                      then @style else 'default'}">
            <xsl:if test="not($text-transform=('none','auto'))">
                <xsl:attribute name="text-style" select="concat('text-transform:',$text-transform)"/>
            </xsl:if>
        </current-page>
    </xsl:template>
    
    <xsl:template match="css:string[@name][not(@target)]" mode="eval-content-list-top-bottom">
        <xsl:param name="white-space" as="xs:string" tunnel="yes" select="'normal'"/>
        <xsl:param name="text-transform" as="xs:string" select="'auto'"/>
        <xsl:param name="page-side" as="xs:string" tunnel="yes" select="'both'"/>
        <xsl:if test="$white-space!='normal'">
            <xsl:message select="concat('white-space:',$white-space,' could not be applied to target-string(',@name,')')"/>
        </xsl:if>
        <xsl:variable name="scope" select="(@scope,'first')[1]"/>
        <xsl:if test="$page-side='both' and $scope=('spread-first','spread-start','spread-last','spread-last-except-start')">
            <!--
                FIXME: force creation of templates for left and right pages when margin
                content contains "string(foo, spread-last)"
            -->
            <xsl:message terminate="yes"
                         select="concat('string(',@name,', ',$scope,') on both left and right side currently not supported')"/>
        </xsl:if>
        <xsl:variable name="var-name" as="xs:string" select="concat('tmp_',generate-id(.))"/>
        <xsl:variable name="text-transform-decl" as="xs:string" select="if (not($text-transform=('none','auto')))
                                                                        then concat(' text-transform:',$text-transform)
                                                                        else ''"/>
        <xsl:choose>
            <xsl:when test="$scope=('first','page-first')">
                <marker-reference marker="{@name}" direction="forward" scope="page"
                                  text-style="def:{$var-name}{$text-transform-decl}"/>
                <!--
                    FIXME: replace with scope="document" and remove second marker-reference
                -->
                <marker-reference marker="{@name}" direction="backward" scope="sequence"
                                  text-style="defifndef:{$var-name}{$text-transform-decl}"/>
                <marker-reference marker="{@name}/entry" direction="backward" scope="sequence"
                                  text-style="ifndef:{$var-name}{$text-transform-decl}"/>
            </xsl:when>
            <xsl:when test="$scope=('start','page-start')">
                <marker-reference marker="{@name}/prev" direction="forward" scope="page-content"
                                  text-style="def:{$var-name}{$text-transform-decl}"/>
                <!--
                    TODO: check that this does not match too much at the end of the page!
                    FIXME: replace with scope="document" and remove second marker-reference
                -->
                <marker-reference marker="{@name}" direction="backward" scope="sequence"
                                  text-style="defifndef:{$var-name}{$text-transform-decl}"/>
                <marker-reference marker="{@name}/entry" direction="backward" scope="sequence"
                                  text-style="ifndef:{$var-name}{$text-transform-decl}"/>
            </xsl:when>
            <xsl:when test="$scope=('last','page-last')">
                <!--
                    FIXME: replace with scope="document" and remove second marker-reference
                -->
                <marker-reference marker="{@name}" direction="backward" scope="sequence"
                                  text-style="def:{$var-name}{$text-transform-decl}"/>
                <marker-reference marker="{@name}/entry" direction="backward" scope="sequence"
                                  text-style="ifndef:{$var-name}{$text-transform-decl}"/>
            </xsl:when>
            <xsl:when test="$scope=('last-except-start','page-last-except-start')">
                <marker-reference marker="{@name}" direction="backward" scope="page-content">
                    <xsl:if test="not($text-transform=('none','auto'))">
                        <xsl:attribute name="text-style" select="concat('text-transform:',$text-transform)"/>
                    </xsl:if>
                </marker-reference>
            </xsl:when>
            <xsl:when test="$scope='spread-first'">
                <marker-reference marker="{@name}" direction="forward" scope="spread"
                                  text-style="def:{$var-name}{$text-transform-decl}">
                    <xsl:if test="$page-side='right'">
                        <xsl:attribute name="start-offset" select="'-1'"/>
                    </xsl:if>
                </marker-reference>
                <!--
                    FIXME: replace with scope="document" and remove second marker-reference
                -->
                <marker-reference marker="{@name}" direction="backward" scope="sequence"
                                  text-style="defifndef:{$var-name}{$text-transform-decl}">
                    <xsl:if test="$page-side='right'">
                        <xsl:attribute name="start-offset" select="'-1'"/>
                    </xsl:if>
                </marker-reference>
                <marker-reference marker="{@name}/entry" direction="backward" scope="sequence"
                                  text-style="ifndef:{$var-name}{$text-transform-decl}"/>
            </xsl:when>
            <xsl:when test="$scope='spread-start'">
                <marker-reference marker="{@name}/prev" direction="forward" scope="page-content"
                                  text-style="def:{$var-name}{$text-transform-decl}">
                    <xsl:if test="$page-side='right'">
                        <xsl:attribute name="start-offset" select="'-1'"/>
                    </xsl:if>
                </marker-reference>
                <!--
                    TODO: check that this does not match too much at the end of the page!
                    FIXME: replace with scope="document" and remove second marker-reference
                -->
                <marker-reference marker="{@name}" direction="backward" scope="sequence"
                                  text-style="defifndef:{$var-name}{$text-transform-decl}">
                    <xsl:if test="$page-side='right'">
                        <xsl:attribute name="start-offset" select="'-1'"/>
                    </xsl:if>
                </marker-reference>
                <marker-reference marker="{@name}/entry" direction="backward" scope="sequence"
                                  text-style="ifndef:{$var-name}{$text-transform-decl}"/>
            </xsl:when>
            <xsl:when test="$scope='spread-last'">
                <!--
                    FIXME: replace with scope="document" and remove second marker-reference
                -->
                <marker-reference marker="{@name}" direction="backward" scope="sequence"
                                  text-style="def:{$var-name}{$text-transform-decl}">
                    <xsl:if test="$page-side='left'">
                        <xsl:attribute name="start-offset" select="'1'"/>
                    </xsl:if>
                </marker-reference>
                <marker-reference marker="{@name}/entry" direction="backward" scope="sequence"
                                  text-style="ifndef:{$var-name}{$text-transform-decl}"/>
            </xsl:when>
            <xsl:when test="$scope='spread-last-except-start'">
                <!--
                    FIXME: scope="spread-content"
                -->
                <marker-reference marker="{@name}" direction="backward" scope="spread">
                    <xsl:if test="$page-side='left'">
                        <xsl:attribute name="start-offset" select="'1'"/>
                    </xsl:if>
                    <xsl:if test="not($text-transform=('none','auto'))">
                        <xsl:attribute name="text-style" select="concat('text-transform:',$text-transform)"/>
                    </xsl:if>
                </marker-reference>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes"
                             select="concat('in function string(',@name,', ',$scope,'): unknown keyword &quot;',$scope,'&quot;')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:custom-func[@name='-obfl-marker-indicator'][matches(@arg2,$css:STRING_RE) and not(@arg3)]"
                  mode="eval-content-list-left-right" priority="1">
        <marker-indicator markers="indicator/{@arg1}" indicator="{substring(@arg2,2,string-length(@arg2)-2)}"/>
    </xsl:template>
    
    <xsl:template match="css:custom-func[@name='-obfl-marker-indicator']" mode="eval-content-list-left-right">
        <xsl:message>-obfl-marker-indicator() function requires exactly two arguments</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:attr" mode="eval-content-list-top-bottom eval-content-list-left-right">
        <xsl:message>attr() function not supported in page margin</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:content" mode="eval-content-list-top-bottom eval-content-list-left-right">
        <xsl:message>content() function not supported in page margin</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:text[@target]" mode="eval-content-list-top-bottom eval-content-list-left-right">
        <xsl:message>target-text() function not supported in page margin</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:string[@value]" mode="eval-content-list-left-right">
        <xsl:message>strings not supported in left and right page margin</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:string[@name][not(@target)]" mode="eval-content-list-left-right">
        <xsl:message>string() function not supported in left and right page margin</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:string[@name][@target]" mode="eval-content-list-top-bottom eval-content-list-left-right">
        <xsl:message>target-string() function not supported in page margin</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:counter[@target]" mode="eval-content-list-top-bottom eval-content-list-left-right">
        <xsl:message>target-counter() function not supported in page margin</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:counter[not(@target)]" mode="eval-content-list-left-right">
        <xsl:message>counter() function not supported in left and right page margin</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:counter[not(@target)][not(@name='page')]" mode="eval-content-list-top-bottom">
        <xsl:message>counter() function not supported in page margin for other counters than 'page'</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:leader" mode="eval-content-list-top-bottom eval-content-list-left-right">
        <xsl:message>leader() function not supported in page margin</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:flow[@from]" mode="eval-content-list-top-bottom eval-content-list-left-right">
        <xsl:message>flow() function not supported in page margin</xsl:message>
    </xsl:template>
    
    <xsl:template match="css:custom-func[@name='-obfl-marker-indicator']" mode="eval-content-list-top-bottom">
        <xsl:message>-obfl-marker-indicator() function not supported in top and bottom page margin</xsl:message>
    </xsl:template>
    
    <xsl:template match="*" mode="eval-content-list-top-bottom eval-content-list-left-right">
        <xsl:message terminate="yes">Coding error</xsl:message>
    </xsl:template>
    
</xsl:stylesheet>
