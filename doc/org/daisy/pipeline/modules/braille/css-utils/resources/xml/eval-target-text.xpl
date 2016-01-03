<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:eval-target-text"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:documentation>
        Evaluate target-text() values.
    </p:documentation>
    
    <p:input port="source" sequence="true">
        <p:documentation>
            target-text() values in the input must be represented by css:text elements. Elements
            that are referenced by a target-text() value must be indicated with a css:id attribute
            that matches the css:text element's target attribute.
        </p:documentation>
    </p:input>
    
    <p:output port="result" sequence="true">
        <p:documentation>
            css:text elements are replaces by the string value of their target element (the element
            whose css:id attribute corresponds with the css:text element's target attribute).
        </p:documentation>
    </p:output>
    
    <p:wrap-sequence wrapper="_"/>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="eval-target-text.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:filter select="/_/*"/>
    
</p:declare-step>
