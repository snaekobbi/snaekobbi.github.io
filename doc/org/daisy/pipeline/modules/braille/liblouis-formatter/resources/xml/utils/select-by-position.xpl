<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:select-by-position"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-inline-prefixes="#all"
    version="1.0">
    
    <p:input port="source" sequence="true" primary="true"/>
    <p:option name="position" required="true"/>
    <p:output port="matched" sequence="true" primary="true"/>
    <p:output port="not-matched" sequence="true">
        <p:pipe step="split-sequence" port="not-matched"/>
    </p:output>
    
    <p:split-sequence name="split-sequence">
        <p:with-option name="test" select="concat('position()=number(', $position,')')">
            <p:empty/>
        </p:with-option>
    </p:split-sequence>
    
</p:declare-step>
