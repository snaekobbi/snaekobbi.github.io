<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:make-anonymous-inline-boxes"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:documentation>
        Break inline boxes around contained block boxes and create anonymous inline boxes
        (http://snaekobbi.github.io/braille-css-spec/#anonymous-boxes).
    </p:documentation>
    
    <p:input port="source">
        <p:documentation>
            The input is assumed to be a tree-of-boxes representation of a document that consists of
            only css:box and css:_ elements, text nodes, and text-only
            css:{string|counter|leader|text} elements.
        </p:documentation>
    </p:input>
    
    <p:output port="result">
        <p:documentation>
            Inline boxes that have descendant block boxes are either unwrapped, or if the element
            has one or more css:* attributes or if it's the document element, renamed to css:_. For
            such elements, the inherited properties (specified in the element's style attribute) are
            moved to the next preserved descendant box, and 'inherit' values on the next preserved
            descendant box are concretized. css:_ elements are retained. All adjacent text nodes and
            css:{string|counter|leader|text} elements that are not already contained in an inline
            box is wrapped into an anonymous one.
        </p:documentation>
    </p:output>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="make-anonymous-inline-boxes.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
