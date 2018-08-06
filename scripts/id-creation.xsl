<?xml version="1.0" ?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xi="http://www.w3.org/2001/XInclude" 
    xmlns:tei="http://www.tei-c.org/ns/1.0">
<xsl:output method="xml" indent="no" xml:space="preserve"/>
  <xsl:variable name="commentaryslug"><xsl:value-of select="/listofFileNames/header/commentaryslug"/></xsl:variable>
    
    
  <xsl:template match="div[@id='body']//div">
        <xsl:copy copy-namespaces="no">
            <xsl:attribute name="id">
                <xsl:value-of select="concat($commentaryslug, '-', generate-id())"></xsl:value-of>
            </xsl:attribute>
            <xsl:apply-templates select="./@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="div[@id='body']//item">
      <xsl:variable name="uniqueId" select=" generate-id()"/>
      <xsl:copy copy-namespaces="no">
        <xsl:attribute name="id">
          <xsl:value-of select="concat($commentaryslug, '-', $uniqueId)"></xsl:value-of>
        </xsl:attribute>
        <xsl:apply-templates select="./@* | node()">
         <xsl:with-param name="uniqueId" select="$uniqueId"/>
        </xsl:apply-templates>
      </xsl:copy>
    </xsl:template>
  <xsl:template match="div[@id='body']//fileName">
    <xsl:param name="uniqueId"></xsl:param>
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="filestem">
        <xsl:value-of select="concat($commentaryslug, '-', $uniqueId)"></xsl:value-of>
      </xsl:attribute>
      <xsl:apply-templates select="./@* | node()"/>
    </xsl:copy>
  </xsl:template>
    <!-- IdentityTransform -->
    
    <xsl:template match="@* | node()">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
