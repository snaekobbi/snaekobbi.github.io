<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="pxi:propagate-page-break"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:documentation>
        Change, add and remove page-break properties so that they can be mapped one-to-one on OBFL
        properties.
    </p:documentation>
    
    <p:input port="source">
        <p:documentation>
            The input is assumed to be a tree-of-boxes representation of a document that consists of
            only css:box elements and text nodes (and css:_ elements if they are document
            elements). Text and inline boxes must not have sibling block boxes, and there should be
            no block boxes inside inline boxes. The 'page-break' properties of block boxes must be
            declared in css:page-break-before, css:page-break-after and css:page-break-inside
            attributes.
        </p:documentation>
    </p:input>
    
    <p:output port="result">
        <p:documentation>
            A 'page-break-before' property with value 'left', 'right' or 'always' is propagated to
            the closest ancestor-or-self block box with a preceding sibling. A 'page-break-after'
            property with value 'avoid' is propagated to the closest ancestor-or-self block box with
            a following sibling. A 'page-break-before' property with value 'avoid' is converted into
            a 'page-break-after' property on the preceding sibling of the closest ancestor-or-self
            block box with a preceding sibling. A 'page-break-after' property with value 'left',
            'right' or 'always' is converted into a 'page-break-before' property on the immediately
            following block box. A 'page-break-inside' property with value 'avoid' on a box with
            child block boxes is propagated to all its children, and all children except the last
            get a 'page-break-after' property with value 'avoid'. In case of conflicting values
            between adjacent siblings, the value 'always' takes precedence over 'avoid', and 'avoid'
            takes precedence over 'auto'.
        </p:documentation>
    </p:output>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="propagate-page-break.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <!--
        In case of conflicting values between adjacent siblings, the value 'always' takes precedence
        over 'avoid'.
    -->
    <p:delete match="@css:page-break-after[.='avoid' and parent::*/following-sibling::*[1]/@css:page-break-before='always']"/>
    
</p:declare-step>
