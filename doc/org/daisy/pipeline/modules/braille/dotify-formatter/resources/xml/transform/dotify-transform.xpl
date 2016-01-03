<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:dotify-transform" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:dotify="http://code.google.com/p/dotify/"
                exclude-inline-prefixes="#all">
	
	<p:input port="source"/>
	<p:output port="result"/>
	
	<p:option name="css-block-transform" select="''"/>
	<p:option name="text-transform" select="''"/>
	<p:option name="temp-dir" required="true"/>
	
	<p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
	<p:import href="../format.xpl"/>
	
	<!-- for debug info -->
	<p:for-each><p:identity/></p:for-each>
	
	<px:transform>
		<p:with-option name="query" select="$css-block-transform"/>
		<p:with-option name="temp-dir" select="$temp-dir"/>
	</px:transform>
	
	<!-- for debug info -->
	<p:for-each><p:identity/></p:for-each>
	
	<dotify:format>
		<p:with-option name="text-transform" select="$text-transform"/>
	</dotify:format>
	
</p:declare-step>
