<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:louis="http://liblouis.org/liblouis"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all">
	
	<xsl:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/transform/block-translator-template.xsl"/>
	
	<xsl:param name="query"/>
	
	<xsl:template match="css:block" mode="#default before after">
		<xsl:variable name="text" as="text()*" select="//text()"/>
		<xsl:variable name="style" as="xs:string*">
			<xsl:for-each select="$text">
				<xsl:variable name="inline-style" as="element()*"
				              select="css:computed-properties($inline-properties[not(.='word-spacing')], true(), parent::*)"/>
				<xsl:sequence select="css:serialize-declaration-list($inline-style[not(@value=css:initial-value(@name))])"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="lang" select="ancestor-or-self::*[@xml:lang][1]/string(@xml:lang)"/>
		<xsl:apply-templates select="node()[1]" mode="treewalk">
			<xsl:with-param name="new-text-nodes" select="louis:translate(concat($query,'(locale:',$lang,')'), $text, $style)"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="css:property[@name='letter-spacing']" mode="translate-declaration-list"/>
	
	<xsl:template match="css:property[@name='word-spacing']" mode="translate-declaration-list">
		<xsl:sequence select="."/>
	</xsl:template>
	
	<xsl:template match="css:property[@name=('text-transform','font-style','font-weight','text-decoration','color')]"
	              mode="translate-declaration-list"/>
	
	<xsl:template match="css:property[@name='hyphens' and @value='auto']" mode="translate-declaration-list">
		<xsl:sequence select="css:property('hyphens','manual')"/>
	</xsl:template>
	
</xsl:stylesheet>
