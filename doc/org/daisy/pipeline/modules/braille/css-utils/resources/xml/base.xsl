<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:re="regex-utils"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:import href="regex-utils.xsl"/>
    <xsl:import href="counters.xsl"/>
    
    <!-- ====== -->
    <!-- Syntax -->
    <!-- ====== -->
    
    <!--
        <color>
    -->
    <xsl:variable name="css:COLOR_RE" select="'#[0-9A-F]{6}'"/>
    <xsl:variable name="css:COLOR_RE_groups" select="0"/>
    
    <!--
        <braille-character>: http://snaekobbi.github.io/braille-css-spec/#dfn-braille-character
    -->
    <xsl:variable name="css:BRAILLE_CHAR_RE" select="'\p{IsBraillePatterns}'"/>
    <xsl:variable name="css:BRAILLE_CHAR_RE_groups" select="0"/>
    
    <!--
        <braille-string>: http://snaekobbi.github.io/braille-css-spec/#dfn-braille-string
    -->
    <xsl:variable name="css:BRAILLE_STRING_RE">'\p{IsBraillePatterns}*?'|"\p{IsBraillePatterns}*?"</xsl:variable>
    <xsl:variable name="css:BRAILLE_STRING_RE_groups" select="0"/>
    
    <!--
        <ident>
    -->
    <xsl:variable name="css:IDENT_RE" select="'(\p{L}|_)(\p{L}|_|-)*'"/>
    <xsl:variable name="css:IDENT_RE_groups" select="2"/>
    
    <xsl:variable name="css:IDENT_LIST_RE" select="re:space-separated($css:IDENT_RE)"/>
    <xsl:variable name="css:IDENT_LIST_RE_groups" select="re:space-separated-groups($css:IDENT_RE_groups)"/>
    
    <xsl:variable name="css:VENDOR_PRF_IDENT_RE" select="'-(\p{L}|_)+-(\p{L}|_)(\p{L}|_|-)*'"/>
    <xsl:variable name="css:VENDOR_PRF_IDENT_RE_groups" select="3"/>
    
    <!--
        <integer>
    -->
    <xsl:variable name="css:INTEGER_RE" select="'0|-?[1-9][0-9]*'"/>
    <xsl:variable name="css:INTEGER_RE_groups" select="0"/>
    
    <!--
        non-negative <integer>
    -->
    <xsl:variable name="css:NON_NEGATIVE_INTEGER_RE" select="'0|[1-9][0-9]*'"/>
    <xsl:variable name="css:NON_NEGATIVE_INTEGER_RE_groups" select="0"/>
    
    <!--
        <string>
    -->
    <xsl:variable name="css:STRING_RE">'[^']*'|"[^"]*"</xsl:variable>
    <xsl:variable name="css:STRING_RE_groups" select="0"/>
    
    <!--
        content()
    -->
    <xsl:variable name="css:CONTENT_FN_RE" select="'content\(\)'"/>
    <xsl:variable name="css:CONTENT_FN_RE_groups" select="0"/>
    
    <!--
        attr(<name>)
    -->
    <xsl:variable name="css:ATTR_FN_RE" select="concat('attr\(\s*(',$css:IDENT_RE,')\s*\)')"/>
    <xsl:variable name="css:ATTR_FN_RE_name" select="1"/>
    <xsl:variable name="css:ATTR_FN_RE_groups" select="$css:ATTR_FN_RE_name + $css:IDENT_RE_groups"/>
    
    <!--
        url(<string>) | attr(<name> url)
    -->
    <xsl:variable name="css:URL_RE" select="concat('url\(\s*(',$css:STRING_RE,')\s*\)|attr\(\s*(',$css:IDENT_RE,')(\s+url)?\s*\)')"/>
    <xsl:variable name="css:URL_RE_string" select="1"/>
    <xsl:variable name="css:URL_RE_attr" select="$css:URL_RE_string + $css:STRING_RE_groups + 1"/>
    <xsl:variable name="css:URL_RE_groups" select="$css:URL_RE_attr + $css:IDENT_RE_groups + 1"/>
    
    <!--
        string(<ident>): http://snaekobbi.github.io/braille-css-spec/#dfn-string
    -->
    <xsl:variable name="css:STRING_FN_RE" select="concat('string\(\s*(',$css:IDENT_RE,')\s*(,\s*(',$css:IDENT_RE,')\s*)?\)')"/>
    <xsl:variable name="css:STRING_FN_RE_ident" select="1"/>
    <xsl:variable name="css:STRING_FN_RE_scope" select="$css:STRING_FN_RE_ident + $css:IDENT_RE_groups + 2"/>
    <xsl:variable name="css:STRING_FN_RE_groups" select="$css:STRING_FN_RE_scope + $css:IDENT_RE_groups"/>
    
    <!--
        counter(<ident>,<counter-style>?): http://snaekobbi.github.io/braille-css-spec/#dfn-counter
    -->
    <xsl:variable name="css:COUNTER_FN_RE" select="concat('counter\(\s*(',$css:IDENT_RE,')\s*(,\s*(',$css:IDENT_RE,')\s*)?\)')"/>
    <xsl:variable name="css:COUNTER_FN_RE_ident" select="1"/>
    <xsl:variable name="css:COUNTER_FN_RE_style" select="$css:COUNTER_FN_RE_ident + $css:IDENT_RE_groups + 2"/>
    <xsl:variable name="css:COUNTER_FN_RE_groups" select="$css:COUNTER_FN_RE_style + $css:IDENT_RE_groups"/>
    
    <!--
        target-text(<url>): http://snaekobbi.github.io/braille-css-spec/#dfn-target-text
    -->
    <xsl:variable name="css:TARGET_TEXT_FN_RE" select="concat('target-text\(\s*(',$css:URL_RE,')\s*\)')"/>
    <xsl:variable name="css:TARGET_TEXT_FN_RE_url" select="1"/>
    <xsl:variable name="css:TARGET_TEXT_FN_RE_url_string" select="$css:TARGET_TEXT_FN_RE_url + $css:URL_RE_string"/>
    <xsl:variable name="css:TARGET_TEXT_FN_RE_url_attr" select="$css:TARGET_TEXT_FN_RE_url + $css:URL_RE_attr"/>
    <xsl:variable name="css:TARGET_TEXT_FN_RE_groups" select="$css:TARGET_TEXT_FN_RE_url + $css:URL_RE_groups"/>
    
    <!--
        target-string(<url>,<ident>): http://snaekobbi.github.io/braille-css-spec/#dfn-target-string
    -->
    <xsl:variable name="css:TARGET_STRING_FN_RE" select="concat('target-string\(\s*(',$css:URL_RE,')\s*,\s*(',$css:IDENT_RE,')\s*\)')"/>
    <xsl:variable name="css:TARGET_STRING_FN_RE_url" select="1"/>
    <xsl:variable name="css:TARGET_STRING_FN_RE_url_string" select="$css:TARGET_STRING_FN_RE_url + $css:URL_RE_string"/>
    <xsl:variable name="css:TARGET_STRING_FN_RE_url_attr" select="$css:TARGET_STRING_FN_RE_url + $css:URL_RE_attr"/>
    <xsl:variable name="css:TARGET_STRING_FN_RE_ident" select="$css:TARGET_STRING_FN_RE_url + $css:URL_RE_groups + 1"/>
    <xsl:variable name="css:TARGET_STRING_FN_RE_groups" select="$css:TARGET_STRING_FN_RE_ident + $css:IDENT_RE_groups"/>
    
    <!--
        target-counter(<url>,<ident>,<counter-style>?): http://snaekobbi.github.io/braille-css-spec/#dfn-target-counter
    -->
    <xsl:variable name="css:TARGET_COUNTER_FN_RE" select="concat('target-counter\(\s*(',$css:URL_RE,')\s*,\s*(',$css:IDENT_RE,')\s*(,\s*(',$css:IDENT_RE,')\s*)?\)')"/>
    <xsl:variable name="css:TARGET_COUNTER_FN_RE_url" select="1"/>
    <xsl:variable name="css:TARGET_COUNTER_FN_RE_url_string" select="$css:TARGET_COUNTER_FN_RE_url + $css:URL_RE_string"/>
    <xsl:variable name="css:TARGET_COUNTER_FN_RE_url_attr" select="$css:TARGET_COUNTER_FN_RE_url + $css:URL_RE_attr"/>
    <xsl:variable name="css:TARGET_COUNTER_FN_RE_ident" select="$css:TARGET_COUNTER_FN_RE_url + $css:URL_RE_groups + 1"/>
    <xsl:variable name="css:TARGET_COUNTER_FN_RE_style" select="$css:TARGET_COUNTER_FN_RE_ident + $css:IDENT_RE_groups + 2"/>
    <xsl:variable name="css:TARGET_COUNTER_FN_RE_groups" select="$css:TARGET_COUNTER_FN_RE_style + $css:IDENT_RE_groups"/>
    
    <!--
        leader(<braille-string>): http://snaekobbi.github.io/braille-css-spec/#dfn-leader
    -->
    <xsl:variable name="css:LEADER_FN_RE" select="concat('leader\(\s*(',$css:BRAILLE_STRING_RE,')\s*\)')"/>
    <xsl:variable name="css:LEADER_FN_RE_pattern" select="1"/>
    <xsl:variable name="css:LEADER_FN_RE_groups" select="$css:LEADER_FN_RE_pattern + $css:BRAILLE_STRING_RE_groups"/>
    
    <!--
        flow(<ident>): http://snaekobbi.github.io/braille-css-spec/#dfn-flow-1
    -->
    <xsl:variable name="css:FLOW_FN_RE" select="concat('flow\(\s*(',$css:IDENT_RE,')\s*\)')"/>
    <xsl:variable name="css:FLOW_FN_RE_ident" select="1"/>
    <xsl:variable name="css:FLOW_FN_RE_groups" select="$css:FLOW_FN_RE_ident + $css:IDENT_RE_groups"/>
    
    <!--
        -foo-bar([<ident>|<string>|<integer>][,[<ident>|<string>|<integer>]]*)
    -->
    <xsl:variable name="css:VENDOR_PRF_FN_ARG_RE" select="re:or(($css:IDENT_RE,$css:STRING_RE,$css:INTEGER_RE))"/>
    <xsl:variable name="css:VENDOR_PRF_FN_ARG_RE_ident" select="1"/>
    <xsl:variable name="css:VENDOR_PRF_FN_ARG_RE_string" select="$css:VENDOR_PRF_FN_ARG_RE_ident + $css:IDENT_RE_groups + 1"/>
    <xsl:variable name="css:VENDOR_PRF_FN_ARG_RE_integer" select="$css:VENDOR_PRF_FN_ARG_RE_string + $css:STRING_RE_groups + 1"/>
    <xsl:variable name="css:VENDOR_PRF_FN_ARG_RE_groups" select="$css:VENDOR_PRF_FN_ARG_RE_integer + $css:INTEGER_RE_groups"/>
    <xsl:variable name="css:VENDOR_PRF_FN_RE" select="concat('(',$css:VENDOR_PRF_IDENT_RE,')\(\s*(',re:comma-separated($css:VENDOR_PRF_FN_ARG_RE),')\s*\)')"/>
    <xsl:variable name="css:VENDOR_PRF_FN_RE_func" select="1"/>
    <xsl:variable name="css:VENDOR_PRF_FN_RE_args" select="$css:VENDOR_PRF_FN_RE_func + $css:VENDOR_PRF_IDENT_RE_groups + 1"/>
    <xsl:variable name="css:VENDOR_PRF_FN_RE_groups" select="$css:VENDOR_PRF_FN_RE_args + re:comma-separated-groups($css:VENDOR_PRF_FN_ARG_RE_groups)"/>
    
    <xsl:variable name="css:CONTENT_RE" select="concat('(',$css:STRING_RE,')|
                                                        (',$css:CONTENT_FN_RE,')|
                                                        (',$css:ATTR_FN_RE,')|
                                                        (',$css:STRING_FN_RE,')|
                                                        (',$css:COUNTER_FN_RE,')|
                                                        (',$css:TARGET_TEXT_FN_RE,')|
                                                        (',$css:TARGET_STRING_FN_RE,')|
                                                        (',$css:TARGET_COUNTER_FN_RE,')|
                                                        (',$css:LEADER_FN_RE,')|
                                                        (',$css:FLOW_FN_RE,')|
                                                        (',$css:VENDOR_PRF_FN_RE,')')"/>
    <xsl:variable name="css:CONTENT_RE_string" select="1"/>
    <xsl:variable name="css:CONTENT_RE_content_fn" select="$css:CONTENT_RE_string + $css:STRING_RE_groups + 1"/>
    <xsl:variable name="css:CONTENT_RE_attr_fn" select="$css:CONTENT_RE_content_fn + $css:CONTENT_FN_RE_groups + 1"/>
    <xsl:variable name="css:CONTENT_RE_attr_fn_name" select="$css:CONTENT_RE_attr_fn + $css:ATTR_FN_RE_name"/>
    <xsl:variable name="css:CONTENT_RE_string_fn" select="$css:CONTENT_RE_attr_fn + $css:ATTR_FN_RE_groups + 1"/>
    <xsl:variable name="css:CONTENT_RE_string_fn_ident" select="$css:CONTENT_RE_string_fn + $css:STRING_FN_RE_ident"/>
    <xsl:variable name="css:CONTENT_RE_string_fn_scope" select="$css:CONTENT_RE_string_fn + $css:STRING_FN_RE_scope"/>
    <xsl:variable name="css:CONTENT_RE_counter_fn" select="$css:CONTENT_RE_string_fn + $css:STRING_FN_RE_groups + 1"/>
    <xsl:variable name="css:CONTENT_RE_counter_fn_ident" select="$css:CONTENT_RE_counter_fn + $css:COUNTER_FN_RE_ident"/>
    <xsl:variable name="css:CONTENT_RE_counter_fn_style" select="$css:CONTENT_RE_counter_fn + $css:COUNTER_FN_RE_style"/>
    <xsl:variable name="css:CONTENT_RE_target_text_fn" select="$css:CONTENT_RE_counter_fn + $css:COUNTER_FN_RE_groups + 1"/>
    <xsl:variable name="css:CONTENT_RE_target_text_fn_url" select="$css:CONTENT_RE_target_text_fn + $css:TARGET_TEXT_FN_RE_url"/>
    <xsl:variable name="css:CONTENT_RE_target_text_fn_url_string" select="$css:CONTENT_RE_target_text_fn + $css:TARGET_TEXT_FN_RE_url_string"/>
    <xsl:variable name="css:CONTENT_RE_target_text_fn_url_attr" select="$css:CONTENT_RE_target_text_fn + $css:TARGET_TEXT_FN_RE_url_attr"/>
    <xsl:variable name="css:CONTENT_RE_target_string_fn" select="$css:CONTENT_RE_target_text_fn + $css:TARGET_TEXT_FN_RE_groups + 1"/>
    <xsl:variable name="css:CONTENT_RE_target_string_fn_url" select="$css:CONTENT_RE_target_string_fn + $css:TARGET_STRING_FN_RE_url"/>
    <xsl:variable name="css:CONTENT_RE_target_string_fn_url_string" select="$css:CONTENT_RE_target_string_fn + $css:TARGET_STRING_FN_RE_url_string"/>
    <xsl:variable name="css:CONTENT_RE_target_string_fn_url_attr" select="$css:CONTENT_RE_target_string_fn + $css:TARGET_STRING_FN_RE_url_attr"/>
    <xsl:variable name="css:CONTENT_RE_target_string_fn_ident" select="$css:CONTENT_RE_target_string_fn + $css:TARGET_STRING_FN_RE_ident"/>
    <xsl:variable name="css:CONTENT_RE_target_counter_fn" select="$css:CONTENT_RE_target_string_fn + $css:TARGET_STRING_FN_RE_groups + 1"/>
    <xsl:variable name="css:CONTENT_RE_target_counter_fn_url" select="$css:CONTENT_RE_target_counter_fn + $css:TARGET_COUNTER_FN_RE_url"/>
    <xsl:variable name="css:CONTENT_RE_target_counter_fn_url_string" select="$css:CONTENT_RE_target_counter_fn + $css:TARGET_COUNTER_FN_RE_url_string"/>
    <xsl:variable name="css:CONTENT_RE_target_counter_fn_url_attr" select="$css:CONTENT_RE_target_counter_fn + $css:TARGET_COUNTER_FN_RE_url_attr"/>
    <xsl:variable name="css:CONTENT_RE_target_counter_fn_ident" select="$css:CONTENT_RE_target_counter_fn + $css:TARGET_COUNTER_FN_RE_ident"/>
    <xsl:variable name="css:CONTENT_RE_target_counter_fn_style" select="$css:CONTENT_RE_target_counter_fn + $css:TARGET_COUNTER_FN_RE_style"/>
    <xsl:variable name="css:CONTENT_RE_leader_fn" select="$css:CONTENT_RE_target_counter_fn + $css:TARGET_COUNTER_FN_RE_groups + 1"/>
    <xsl:variable name="css:CONTENT_RE_leader_fn_pattern" select="$css:CONTENT_RE_leader_fn + $css:LEADER_FN_RE_pattern"/>
    <xsl:variable name="css:CONTENT_RE_flow_fn" select="$css:CONTENT_RE_leader_fn + $css:LEADER_FN_RE_groups + 1"/>
    <xsl:variable name="css:CONTENT_RE_flow_fn_ident" select="$css:CONTENT_RE_flow_fn + $css:FLOW_FN_RE_ident"/>
    <xsl:variable name="css:CONTENT_RE_vendor_prf_fn" select="$css:CONTENT_RE_flow_fn + $css:FLOW_FN_RE_groups + 1"/>
    <xsl:variable name="css:CONTENT_RE_vendor_prf_fn_func" select="$css:CONTENT_RE_vendor_prf_fn + $css:VENDOR_PRF_FN_RE_func"/>
    <xsl:variable name="css:CONTENT_RE_vendor_prf_fn_args" select="$css:CONTENT_RE_vendor_prf_fn + $css:VENDOR_PRF_FN_RE_args"/>
    <xsl:variable name="css:CONTENT_RE_groups" select="$css:CONTENT_RE_vendor_prf_fn + $css:VENDOR_PRF_FN_RE_groups"/>
    
    <xsl:variable name="css:CONTENT_LIST_RE" select="re:space-separated($css:CONTENT_RE)"/>
    <xsl:variable name="css:CONTENT_LIST_RE_groups" select="re:space-separated-groups($css:CONTENT_RE_groups)"/>
    
    <xsl:variable name="css:STRING_SET_PAIR_RE" select="concat('(',$css:IDENT_RE,')\s+(',$css:CONTENT_LIST_RE,')')"/>
    <xsl:variable name="css:STRING_SET_PAIR_RE_ident" select="1"/>
    <xsl:variable name="css:STRING_SET_PAIR_RE_list" select="$css:STRING_SET_PAIR_RE_ident + $css:IDENT_RE_groups + 1"/>
    
    <xsl:variable name="css:COUNTER_SET_PAIR_RE" select="concat('(',$css:IDENT_RE,')(\s+(',$css:INTEGER_RE,'))?')"/>
    <xsl:variable name="css:COUNTER_SET_PAIR_RE_ident" select="1"/>
    <xsl:variable name="css:COUNTER_SET_PAIR_RE_value" select="$css:COUNTER_SET_PAIR_RE_ident + $css:IDENT_RE_groups + 2"/>
    
    <xsl:variable name="css:DECLARATION_LIST_RE">([^'"\{\}]+|'[^']*'|"[^"]*")*</xsl:variable>
    <xsl:variable name="css:DECLARATION_LIST_RE_groups" select="1"/>
    
    <xsl:variable name="css:NESTED_RULE_RE" select="concat('@',$css:IDENT_RE,'\s+\{',$css:DECLARATION_LIST_RE,'\}')"/>
    
    <xsl:variable name="css:PSEUDOCLASS_RE" select="concat(':',$css:IDENT_RE,'(\([1-9][0-9]*\))?')"/>
    <xsl:variable name="css:PSEUDOCLASS_RE_groups" select="$css:IDENT_RE_groups + 1"/>
    
    <xsl:variable name="css:RULE_RE" select="concat('(((@',$css:IDENT_RE,')(',$css:PSEUDOCLASS_RE,')?|(::',$css:IDENT_RE,')|(',$css:PSEUDOCLASS_RE,'))\s*)?\{((',$css:DECLARATION_LIST_RE,'|',$css:NESTED_RULE_RE,')*)\}')"/>
    <xsl:variable name="css:RULE_RE_selector" select="2"/>
    <xsl:variable name="css:RULE_RE_selector_atrule" select="$css:RULE_RE_selector + 1"/>
    <xsl:variable name="css:RULE_RE_selector_atrule_pseudoclass" select="$css:RULE_RE_selector_atrule + $css:IDENT_RE_groups + 1"/>
    <xsl:variable name="css:RULE_RE_selector_pseudoelement" select="$css:RULE_RE_selector_atrule_pseudoclass + $css:PSEUDOCLASS_RE_groups + 1"/>
    <xsl:variable name="css:RULE_RE_selector_pseudoclass" select="$css:RULE_RE_selector_pseudoelement + $css:IDENT_RE_groups + 1"/>
    <xsl:variable name="css:RULE_RE_value" select="$css:RULE_RE_selector_pseudoclass + $css:PSEUDOCLASS_RE_groups + 1"/>
    
    <!-- ======= -->
    <!-- Parsing -->
    <!-- ======= -->
    
    <xsl:function name="css:property">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:choose>
            <xsl:when test="$value instance of xs:integer">
                <css:property name="{$name}" value="{format-number($value, '0')}"/>
            </xsl:when>
            <xsl:otherwise>
                <css:property name="{$name}" value="{$value}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="@css:*" mode="css:attribute-as-property" as="element()">
        <css:property name="{replace(local-name(),'^_','-')}" value="{string()}"/>
    </xsl:template>
    
    <xsl:template match="css:property" mode="css:property-as-attribute" as="attribute()">
        <xsl:attribute name="css:{replace(@name,'^-','_')}" select="@value"/>
    </xsl:template>
    
    <xsl:function name="css:parse-stylesheet" as="element()*">
        <xsl:param name="stylesheet" as="xs:string?"/>
        <xsl:if test="$stylesheet">
            <xsl:variable name="rules" as="element()*">
                <xsl:analyze-string select="$stylesheet" regex="{$css:RULE_RE}">
                    <xsl:matching-substring>
                        <xsl:element name="css:rule">
                            <xsl:if test="regex-group($css:RULE_RE_selector)!=''">
                                <xsl:attribute name="selector" select="concat(
                                                                         regex-group($css:RULE_RE_selector_atrule),
                                                                         regex-group($css:RULE_RE_selector_pseudoelement),
                                                                         regex-group($css:RULE_RE_selector_pseudoclass))"/>
                            </xsl:if>
                            <xsl:variable name="style" as="xs:string"
                                          select="replace(regex-group($css:RULE_RE_value), '(^\s+|\s+$)', '')"/>
                            <xsl:choose>
                                <xsl:when test="regex-group($css:RULE_RE_selector_atrule_pseudoclass)!=''">
                                    <xsl:element name="css:rule">
                                        <xsl:attribute name="selector" select="regex-group($css:RULE_RE_selector_atrule_pseudoclass)"/>
                                        <xsl:attribute name="style" select="$style"/>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="style" select="$style"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:if test="not(normalize-space(.)='')">
                            <css:rule style="{replace(., '(^\s+|\s+$)', '')}"/>
                        </xsl:if>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:for-each-group select="$rules" group-by="string(@selector)">
                <xsl:variable name="selector" as="xs:string" select="current-grouping-key()"/>
                <xsl:choose>
                    <xsl:when test="not(current-group()/*)">
                        <xsl:sequence select="current-group()[last()]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="nested-rules" as="xs:string*">
                            <xsl:if test="current-group()/@style">
                                <xsl:sequence select="concat('{ ',(current-group())/@style[last()],' }')"/>
                            </xsl:if>
                            <xsl:for-each-group select="current-group()/*" group-by="@selector">
                                <xsl:sequence select="concat(current-grouping-key(),' { ',current-group()[last()]/@style,' }')"/>
                            </xsl:for-each-group>
                        </xsl:variable>
                        <xsl:element name="css:rule">
                            <xsl:attribute name="selector" select="current-grouping-key()"/>
                            <xsl:attribute name="style" select="string-join($nested-rules,' ')"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="css:parse-declaration-list" as="element()*">
        <xsl:param name="declaration-list" as="xs:string?"/>
        <xsl:if test="$declaration-list">
            <xsl:for-each select="tokenize($declaration-list, ';')[not(normalize-space(.)='')]">
                <xsl:sequence select="css:property(
                                        normalize-space(substring-before(.,':')),
                                        replace(substring-after(.,':'), '(^\s+|\s+$)', ''))"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="css:parse-content-list" as="element()*">
        <xsl:param name="content-list" as="xs:string?"/>
        <xsl:param name="context" as="element()?"/>
        <xsl:if test="$content-list">
            <xsl:analyze-string select="$content-list" regex="{$css:CONTENT_RE}" flags="x">
                <xsl:matching-substring>
                    <xsl:choose>
                        <!--
                            <string>
                        -->
                        <xsl:when test="regex-group($css:CONTENT_RE_string)!=''">
                            <css:string value="{substring(regex-group($css:CONTENT_RE_string),
                                                          2, string-length(regex-group($css:CONTENT_RE_string))-2)}"/>
                        </xsl:when>
                        <!--
                            content()
                        -->
                        <xsl:when test="regex-group($css:CONTENT_RE_content_fn)!=''">
                            <css:content/>
                        </xsl:when>
                        <!--
                            attr(<name>)
                        -->
                        <xsl:when test="regex-group($css:CONTENT_RE_attr_fn)!=''">
                            <css:attr name="{regex-group($css:CONTENT_RE_attr_fn_name)}"/>
                        </xsl:when>
                        <!--
                            string(<ident>,<scope>?)
                        -->
                        <xsl:when test="regex-group($css:CONTENT_RE_string_fn)!=''">
                            <css:string name="{regex-group($css:CONTENT_RE_string_fn_ident)}">
                                <xsl:if test="regex-group($css:CONTENT_RE_string_fn_scope)!=''">
                                    <xsl:attribute name="scope" select="regex-group($css:CONTENT_RE_string_fn_scope)"/>
                                </xsl:if>
                            </css:string>
                        </xsl:when>
                        <!--
                            counter(<ident>,<counter-style>?)
                        -->
                        <xsl:when test="regex-group($css:CONTENT_RE_counter_fn)!=''">
                            <xsl:element name="css:counter">
                                <xsl:attribute name="name" select="regex-group($css:CONTENT_RE_counter_fn_ident)"/>
                                <xsl:if test="regex-group($css:CONTENT_RE_counter_fn_style)!=''">
                                    <xsl:attribute name="style" select="regex-group($css:CONTENT_RE_counter_fn_style)"/>
                                </xsl:if>
                            </xsl:element>
                        </xsl:when>
                        <!--
                            target-text(<url>)
                        -->
                        <xsl:when test="regex-group($css:CONTENT_RE_target_text_fn)!=''">
                            <css:text target="{if (regex-group($css:CONTENT_RE_target_text_fn_url_string)!='')
                                               then substring(regex-group($css:CONTENT_RE_target_text_fn_url_string),
                                                              2, string-length(regex-group($css:CONTENT_RE_target_text_fn_url_string))-2)
                                               else string($context/@*[name()=regex-group($css:CONTENT_RE_target_text_fn_url_attr)])}"/>
                        </xsl:when>
                        <!--
                            target-string(<url>,<ident>)
                        -->
                        <xsl:when test="regex-group($css:CONTENT_RE_target_string_fn)!=''">
                            <css:string target="{if (regex-group($css:CONTENT_RE_target_string_fn_url_string)!='')
                                                 then substring(regex-group($css:CONTENT_RE_target_string_fn_url_string),
                                                                2, string-length(regex-group($css:CONTENT_RE_target_string_fn_url_string))-2)
                                                 else string($context/@*[name()=regex-group($css:CONTENT_RE_target_string_fn_url_attr)])}"
                                        name="{regex-group($css:CONTENT_RE_target_string_fn_ident)}"/>
                        </xsl:when>
                        <!--
                            target-counter(<url>,<ident>,<counter-style>?)
                        -->
                        <xsl:when test="regex-group($css:CONTENT_RE_target_counter_fn)!=''">
                            <xsl:element name="css:counter">
                                <xsl:attribute name="target"
                                               select="if (regex-group($css:CONTENT_RE_target_counter_fn_url_string)!='')
                                                       then substring(regex-group($css:CONTENT_RE_target_counter_fn_url_string),
                                                                      2, string-length(regex-group($css:CONTENT_RE_target_counter_fn_url_string))-2)
                                                       else string($context/@*[name()=regex-group($css:CONTENT_RE_target_counter_fn_url_attr)])"/>
                                <xsl:attribute name="name" select="regex-group($css:CONTENT_RE_target_counter_fn_ident)"/>
                                <xsl:if test="regex-group($css:CONTENT_RE_target_counter_fn_style)!=''">
                                    <xsl:attribute name="style" select="regex-group($css:CONTENT_RE_target_counter_fn_style)"/>
                                </xsl:if>
                            </xsl:element>
                        </xsl:when>
                        <!--
                            leader(<braille-string>)
                        -->
                        <xsl:when test="regex-group($css:CONTENT_RE_leader_fn)!=''">
                            <css:leader pattern="{substring(regex-group($css:CONTENT_RE_leader_fn_pattern),
                                                            2, string-length(regex-group($css:CONTENT_RE_leader_fn_pattern))-2)}"/>
                        </xsl:when>
                        <!--
                            flow(<ident>)
                        -->
                        <xsl:when test="regex-group($css:CONTENT_RE_flow_fn)!=''">
                            <css:flow from="{regex-group($css:CONTENT_RE_flow_fn_ident)}"/>
                        </xsl:when>
                        <!--
                            -foo-bar([<ident>|<string>|<integer>][,[<ident>|<string>|<integer>]]*)
                        -->
                        <xsl:when test="regex-group($css:CONTENT_RE_vendor_prf_fn)!=''">
                            <css:custom-func name="{regex-group($css:CONTENT_RE_vendor_prf_fn_func)}">
                                <xsl:analyze-string select="regex-group($css:CONTENT_RE_vendor_prf_fn_args)" regex="{$css:VENDOR_PRF_FN_ARG_RE}">
                                    <xsl:matching-substring>
                                        <xsl:attribute name="arg{(position()+1) idiv 2}" select="."/>
                                    </xsl:matching-substring>
                                </xsl:analyze-string>
                            </css:custom-func>
                        </xsl:when>
                    </xsl:choose>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="css:parse-string-set" as="element()*">
        <xsl:param name="pairs" as="xs:string?"/>
        <!--
            force eager matching
        -->
        <xsl:variable name="regexp" select="concat($css:STRING_SET_PAIR_RE,'(\s*,|$)')"/>
        <xsl:if test="$pairs">
            <xsl:analyze-string select="$pairs" regex="{$regexp}" flags="x">
                <xsl:matching-substring>
                    <css:string-set name="{regex-group($css:STRING_SET_PAIR_RE_ident)}"
                                    value="{regex-group($css:STRING_SET_PAIR_RE_list)}"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="css:parse-counter-set" as="element()*">
        <xsl:param name="pairs" as="xs:string?"/>
        <xsl:param name="initial" as="xs:integer"/>
        <xsl:if test="$pairs">
            <xsl:analyze-string select="$pairs" regex="{$css:COUNTER_SET_PAIR_RE}" flags="x">
                <xsl:matching-substring>
                    <css:counter-set name="{regex-group($css:COUNTER_SET_PAIR_RE_ident)}"
                                     value="{if (regex-group($css:COUNTER_SET_PAIR_RE_value)!='')
                                             then regex-group($css:COUNTER_SET_PAIR_RE_value)
                                             else format-number($initial,'0')}"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:function>
    
    <!-- ===================================== -->
    <!-- Validating, inheriting and defaulting -->
    <!-- ===================================== -->
    
    <xsl:template match="css:property" mode="css:validate">
        <xsl:if test="css:is-valid(.)">
            <xsl:sequence select="."/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:property" mode="css:inherit">
        <!-- true means input is valid and result should be valid too -->
        <xsl:param name="validate" as="xs:boolean"/>
        <xsl:param name="context" as="element()"/>
        <xsl:choose>
            <xsl:when test="@value='inherit'">
                <xsl:variable name="parent" as="element()?" select="$context/ancestor::*[not(self::css:* except (self::css:box|self::css:block))][1]"/>
                <xsl:sequence select="if ($parent)
                                      then css:specified-properties(@name, true(), false(), $validate, $parent)
                                      else css:property(@name, 'initial')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:property" mode="css:default">
        <xsl:choose>
            <xsl:when test="@value='initial'">
                <xsl:sequence select="css:property(@name, css:initial-value(@name))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:property" mode="css:compute">
        <!--
            true means input does not have value 'inherit' and result should not have value 'inherit' either.
            'inherit' in the result means that the computed value is equal to the computed value of the parent, or the initial value if there is no parent.
        -->
        <xsl:param name="concretize-inherit" as="xs:boolean"/>
        <!--
            true means input does not have value 'initial' and result should not have value 'initial' either.
            'initial' in the result means that the computed value is equal to the initial value.
        -->
        <xsl:param name="concretize-initial" as="xs:boolean"/>
        <!-- true means input is valid and result should be valid too -->
        <xsl:param name="validate" as="xs:boolean"/>
        <xsl:param name="context" as="element()"/>
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="*" mode="css:cascaded-properties" as="element()*">
        <xsl:param name="properties" as="xs:string*" select="('#all')"/>
        <xsl:param name="validate" as="xs:boolean" select="false()"/>
        <xsl:variable name="declarations" as="element()*">
            <xsl:apply-templates select="@css:*[local-name()=$properties]" mode="css:attribute-as-property"/>
        </xsl:variable>
        <xsl:variable name="declarations" as="element()*"
            select="(css:parse-declaration-list(css:parse-stylesheet(@style)
                       /self::css:rule[not(@selector)][last()]/@style),
                     $declarations)"/>
        <xsl:variable name="declarations" as="element()*"
            select="if ('#all'=$properties) then $declarations else $declarations[@name=$properties and not(@name='#all')]"/>
        <xsl:variable name="declarations" as="element()*">
            <xsl:choose>
                <xsl:when test="$validate">
                    <xsl:apply-templates select="$declarations" mode="css:validate"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$declarations"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="for $property in distinct-values($declarations/self::css:property/@name) return
                              $declarations/self::css:property[@name=$property][last()]"/>
    </xsl:template>
    
    <xsl:template match="*" mode="css:specified-properties" as="element()*">
        <xsl:param name="properties" select="'#all'"/>
        <xsl:param name="concretize-inherit" as="xs:boolean" select="true()"/>
        <xsl:param name="concretize-initial" as="xs:boolean" select="true()"/>
        <xsl:param name="validate" as="xs:boolean" select="false()"/>
        <xsl:variable name="properties" as="xs:string*"
                      select="if ($properties instance of xs:string)
                              then tokenize(normalize-space($properties), ' ')
                              else $properties"/>
        <xsl:variable name="declarations" as="element()*">
            <xsl:apply-templates select="." mode="css:cascaded-properties">
                <xsl:with-param name="properties" select="$properties"/>
                <xsl:with-param name="validate" select="$validate"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="properties" as="xs:string*" select="$properties[not(.='#all')]"/>
        <xsl:variable name="properties" as="xs:string*"
            select="if ($validate) then $properties[.=$css:properties] else $properties"/>
        <xsl:variable name="declarations" as="element()*"
            select="($declarations,
                     for $property in distinct-values($properties) return
                       if ($declarations/self::css:property[@name=$property]) then ()
                       else if (css:is-inherited($property)) then css:property($property, 'inherit')
                       else css:property($property, 'initial'))"/>
        <xsl:variable name="declarations" as="element()*">
            <xsl:choose>
                <xsl:when test="$concretize-inherit">
                    <xsl:apply-templates select="$declarations" mode="css:inherit">
                        <xsl:with-param name="validate" select="$validate"/>
                        <xsl:with-param name="context" select="."/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$declarations"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$concretize-initial">
                <xsl:apply-templates select="$declarations" mode="css:default"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$declarations"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="css:specified-properties" as="element()*">
        <xsl:param name="properties"/>
        <xsl:param name="concretize-inherit" as="xs:boolean"/>
        <xsl:param name="concretize-initial" as="xs:boolean"/>
        <xsl:param name="validate" as="xs:boolean"/>
        <xsl:param name="context" as="element()"/>
        <xsl:apply-templates select="$context" mode="css:specified-properties">
            <xsl:with-param name="properties" select="$properties"/>
            <xsl:with-param name="concretize-inherit" select="$concretize-inherit"/>
            <xsl:with-param name="concretize-initial" select="$concretize-initial"/>
            <xsl:with-param name="validate" select="$validate"/>
        </xsl:apply-templates>
    </xsl:function>
    
    <xsl:template match="*" mode="css:computed-properties" as="element()*">
        <xsl:param name="properties" select="'#all'"/>
        <xsl:param name="concretize-inherit" as="xs:boolean" select="true()"/>
        <xsl:param name="concretize-initial" as="xs:boolean" select="true()"/>
        <xsl:param name="validate" as="xs:boolean" select="false()"/>
        <xsl:variable name="declarations" as="element()*">
            <xsl:apply-templates select="." mode="css:specified-properties">
                <xsl:with-param name="properties" select="$properties"/>
                <xsl:with-param name="concretize-inherit" select="false()"/>
                <xsl:with-param name="concretize-initial" select="false()"/>
                <xsl:with-param name="validate" select="$validate"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="declarations" as="element()*">
            <xsl:apply-templates select="$declarations" mode="css:compute">
                <xsl:with-param name="concretize-inherit" select="false()"/>
                <xsl:with-param name="concretize-initial" select="false()"/>
                <xsl:with-param name="validate" select="$validate"/>
                <xsl:with-param name="context" select="."/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="declarations" as="element()*">
            <xsl:choose>
                <xsl:when test="$concretize-inherit">
                    <xsl:apply-templates select="$declarations" mode="css:inherit">
                        <xsl:with-param name="validate" select="$validate"/>
                        <xsl:with-param name="context" select="."/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$declarations"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$concretize-initial">
                <xsl:apply-templates select="$declarations" mode="css:default"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$declarations"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="css:computed-properties" as="element()*">
        <xsl:param name="properties"/>
        <xsl:param name="concretize-inherit" as="xs:boolean"/>
        <xsl:param name="concretize-initial" as="xs:boolean"/>
        <xsl:param name="validate" as="xs:boolean"/>
        <xsl:param name="context" as="element()"/>
        <xsl:apply-templates select="$context" mode="css:computed-properties">
            <xsl:with-param name="properties" select="$properties"/>
            <xsl:with-param name="concretize-inherit" select="$concretize-inherit"/>
            <xsl:with-param name="concretize-initial" select="$concretize-initial"/>
            <xsl:with-param name="validate" select="$validate"/>
        </xsl:apply-templates>
    </xsl:function>
    
    <xsl:function name="css:computed-properties" as="element()*">
        <xsl:param name="properties"/>
        <xsl:param name="validate" as="xs:boolean"/>
        <xsl:param name="context" as="element()"/>
        <xsl:sequence select="css:computed-properties($properties, true(), true(), $validate, $context)"/>
    </xsl:function>
    
    <!-- =========== -->
    <!-- Serializing -->
    <!-- =========== -->
    
    <xsl:template match="css:rule" mode="css:serialize" as="xs:string">
        <xsl:choose>
            <xsl:when test="not(@selector)">
                <xsl:sequence select="@style"/>
            </xsl:when>
            <xsl:when test="matches(@selector,'^@')">
                <xsl:variable name="nested-rules" as="element()*" select="css:parse-stylesheet(@style)"/>
                <xsl:sequence select="string-join((
                                        if ($nested-rules[not(matches(@selector,'^:'))])
                                          then concat(@selector,' { ',
                                                      css:serialize-stylesheet($nested-rules[not(matches(@selector,'^:'))]),
                                                      ' }')
                                          else (),
                                        for $r in $nested-rules[matches(@selector,'^:')]
                                          return concat(@selector,$r/@selector,' { ',$r/@style,' }')),
                                        ' ')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="concat(@selector,' { ',@style,' }')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="css:property" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat(@name,': ',@value)"/>
    </xsl:template>
    
    <xsl:template match="css:string-set" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat(@name,' ',@value)"/>
    </xsl:template>
    
    <xsl:template match="css:counter-set" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat(@name,' ',@value)"/>
    </xsl:template>
    
    <xsl:template match="css:string[@value]" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('&quot;',@value,'&quot;')"/>
    </xsl:template>
    
    <xsl:template match="css:content" mode="css:serialize" as="xs:string">
        <xsl:sequence select="'content()'"/>
    </xsl:template>
    
    <xsl:template match="css:attr" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('attr(',@name,')')"/>
    </xsl:template>
    
    <xsl:template match="css:string[@name][not(@target)]" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('string(',@name,')')"/>
    </xsl:template>
    
    <xsl:template match="css:counter" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('counter(',@name,if (@style) then concat(', ', @style) else '',')')"/>
    </xsl:template>
    
    <xsl:template match="css:text[@target]" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('target-text(url(&quot;',@target,'&quot;))')"/>
    </xsl:template>
    
    <xsl:template match="css:string[@name][@target]" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('target-string(url(&quot;',@target,'&quot;), ',@name,')')"/>
    </xsl:template>
    
    <xsl:template match="css:counter[@target]" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('target-counter(url(&quot;',@target,'&quot;), ',@name,if (@style) then concat(', ', @style) else '',')')"/>
    </xsl:template>
    
    <xsl:template match="css:leader" mode="css:serialize" as="xs:string">
        <xsl:sequence select="concat('leader(&quot;',@pattern,'&quot;)')"/>
    </xsl:template>
    
    <xsl:function name="css:serialize-stylesheet" as="xs:string">
        <xsl:param name="rules" as="element()*"/>
        <xsl:variable name="serialized-declarations" as="xs:string*">
            <xsl:apply-templates select="$rules[not(@selector)]" mode="css:serialize"/>
        </xsl:variable>
        <xsl:variable name="serialized-rules" as="xs:string*">
            <xsl:apply-templates select="$rules[@selector]" mode="css:serialize"/>
        </xsl:variable>
        <xsl:variable name="serialized-rules" as="xs:string*">
            <xsl:if test="$serialized-declarations">
                <xsl:sequence select="string-join($serialized-declarations,'; ')"/>
            </xsl:if>
            <xsl:sequence select="$serialized-rules"/>
        </xsl:variable>
        <xsl:sequence select="string-join($serialized-rules,' ')"/>
    </xsl:function>
    
    <xsl:function name="css:serialize-declaration-list" as="xs:string">
        <xsl:param name="declarations" as="element()*"/>
        <xsl:variable name="serialized-declarations" as="xs:string*">
            <xsl:apply-templates select="$declarations" mode="css:serialize"/>
        </xsl:variable>
        <xsl:sequence select="string-join($serialized-declarations, '; ')"/>
    </xsl:function>
    
    <xsl:function name="css:serialize-content-list" as="xs:string">
        <xsl:param name="components" as="element()*"/>
        <xsl:variable name="serialized-components" as="xs:string*">
            <xsl:apply-templates select="$components" mode="css:serialize"/>
        </xsl:variable>
        <xsl:sequence select="string-join($serialized-components, ' ')"/>
    </xsl:function>
    
    <xsl:function name="css:serialize-string-set" as="xs:string">
        <xsl:param name="pairs" as="element()*"/>
        <xsl:variable name="serialized-pairs" as="xs:string*">
            <xsl:apply-templates select="$pairs" mode="css:serialize"/>
        </xsl:variable>
        <xsl:sequence select="string-join($serialized-pairs, ', ')"/>
    </xsl:function>
    
    <xsl:function name="css:serialize-counter-set" as="xs:string">
        <xsl:param name="pairs" as="element()*"/>
        <xsl:variable name="serialized-pairs" as="xs:string*">
            <xsl:apply-templates select="$pairs" mode="css:serialize"/>
        </xsl:variable>
        <xsl:sequence select="string-join($serialized-pairs, ' ')"/>
    </xsl:function>
    
    <xsl:function name="css:style-attribute" as="attribute()?">
        <xsl:param name="style" as="xs:string?"/>
        <xsl:if test="$style and $style!=''">
            <xsl:attribute name="style" select="$style"/>
        </xsl:if>
    </xsl:function>
    
    <!-- ========== -->
    <!-- Evaluating -->
    <!-- ========== -->
    
    <xsl:template match="css:string[@value]" mode="css:eval" as="xs:string">
        <xsl:sequence select="string(@value)"/>
    </xsl:template>
    
    <xsl:template match="css:content" mode="css:eval">
        <xsl:param name="context" as="element()?" select="()" tunnel="yes"/>
        <xsl:if test="$context">
            <xsl:sequence select="$context/child::node()"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="css:attr" mode="css:eval" as="xs:string?">
        <xsl:param name="context" as="element()?" select="()" tunnel="yes"/>
        <xsl:if test="$context">
            <xsl:variable name="name" select="string(@name)"/>
            <xsl:sequence select="string($context/@*[name()=$name])"/>
        </xsl:if>
    </xsl:template>
    
    <!-- ======= -->
    <!-- Strings -->
    <!-- ======= -->
    
    <xsl:function name="css:string" as="element()*">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="context" as="element()"/>
        <xsl:variable name="last-set" as="element()?"
                      select="$context/(self::*|preceding::*|ancestor::*)
                              [contains(@css:string-set,$name) or contains(@css:string-entry,$name)]
                              [last()]"/>
        <xsl:if test="$last-set">
            <xsl:variable name="value" as="xs:string?"
                          select="(css:parse-string-set($last-set/@css:string-entry),
                                   css:parse-string-set($last-set/@css:string-set))
                                  [@name=$name][last()]/@value"/>
            <xsl:sequence select="if ($value) then css:parse-content-list($value, $context)
                                  else css:string($name, $last-set/(preceding::*|ancestor::*)[last()])"/>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>
