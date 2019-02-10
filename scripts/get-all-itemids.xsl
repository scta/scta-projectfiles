<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">
  <xsl:template match="/">
    <xsl:call-template name="items"/>
    
  </xsl:template>
  <xsl:template name="items">
    <xsl:for-each select="//item">"<xsl:value-of select="./@id"/>.rdf",
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>