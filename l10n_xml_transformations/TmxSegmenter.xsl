<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="3.0">
  
<!-- run as:
java -jar saxon9he.jar -s:02_para/unsegmented.tmx -xsl:TmxSegmenter.xsl -o:01_segm/segmented.tmx 
-->
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:output indent="yes"/>
    
    <xsl:param name="lb" as="xs:string">\s*&lt;/?(li|ul|br)\s*/?&gt;\s*</xsl:param>
    
    <xsl:template match="tu">
        <xsl:variable name="split">
            <xsl:apply-templates mode="split"/>
        </xsl:variable>
        <xsl:for-each-group select="$split/tuv/seg" group-by="position() mod count($split/tuv[1]/seg)">
            <tu tuid="{position()}">
                <xsl:apply-templates select="current-group()/snapshot()/.."/>
            </tu>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:mode name="split" on-no-match="shallow-copy"/>
    
    <xsl:template match="seg" expand-text="yes" mode="split">
        <xsl:for-each select="tokenize(
            replace(
                replace(
                    replace(
                        replace(.,  '(e.g.|par ex.) ', '$1 '  ),            
                        '([:.?!])\s+', '$1&lt;br&gt;'  ),  
                    '&lt;/?[biu]&gt;', ''  ),
                ' ', ' '),   
            '(' || $lb || ')+(•\s?)?')">
            <seg>{.}</seg>
        </xsl:for-each>
    </xsl:template>
    <!--             '(&lt;/?[biu]&gt;)*(' || $lb || ')+(•\s?|&lt;/?[biu]&gt;)*')"> -->
</xsl:stylesheet>