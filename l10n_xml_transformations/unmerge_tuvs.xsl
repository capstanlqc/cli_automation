<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <!-- 
        See it in action here: https://xsltfiddle.liberty-development.net/6rewNxx/10
        Run it as: java -jar /mnt/c/Apps/saxon6-5-5/saxon.jar -o output.tmx input.tmx ~/path/to/unmerge_tuvs_xsl2.xsl
    -->
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>           
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tu[descendant::tuv[@xml:lang !='en-ZZ']]">
        <xsl:for-each select="tuv[@xml:lang !='en-ZZ']">
            <tu>
                <xsl:copy-of select="../tuv[@xml:lang='en-ZZ']"/>
                <xsl:copy-of select="."/>
            </tu>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>