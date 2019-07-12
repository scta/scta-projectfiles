<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:variable name="topLevelId" select="/listofFileNames/header[1]/commentaryid[1]"></xsl:variable>
  <xsl:variable name="baseRepoPath" select="concat('/Users/jcwitt/Projects/scta/scta-texts/', $topLevelId, '/')"/>
  <xsl:variable name="savePath" select="concat('/Users/jcwitt/Projects/scta/scta-outlines/', $topLevelId, '.xml')"/>
  
  <xsl:template match="/">
    <xsl:result-document method="xhtml" xpath-default-namespace="http://www.tei-c.org/ns/1.0" href="{$savePath}">
      <div>
      <xsl:apply-templates />
      </div>
    </xsl:result-document>
  </xsl:template>
  <xsl:template match="header"/>
  <xsl:template match="hasWitness"/>
  <xsl:template match="fileName|folio|questionTitle"/>
  <xsl:template match="div">
    <div data-outline-id="{./@id}" class="outline"><xsl:apply-templates/></div>
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="item">
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="./@id">
          <xsl:value-of select="./@id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="./fileName/@filestem"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
      <xsl:call-template name="item-hiearchy">
        <xsl:with-param name="itemid" select="$id"/>
      </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="tei:p">
    <div data-outline-id="{./@xml:id}" class="outline">
      <p class="outline-head">Paragraph <xsl:value-of select="./@xml:id"/></p>
    </div>
  </xsl:template>
  <xsl:template match="tei:div">
    <div data-outline-id="{./@xml:id}" class="outline">
      <xsl:choose>
        <xsl:when test="./tei:head[1]">
          <p class="outline-head"><xsl:value-of select="./tei:head[1]"/></p>  
        </xsl:when>
        <xsl:otherwise>
          <p class="outline-head">Division <xsl:value-of select="./@xml:id"/></p>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates/>
      
      
    </div>
  </xsl:template>
  <xsl:template match="tei:head"/>
  <xsl:template match="tei:teiHeader"/>
  <xsl:template match="tei:front"/>
  <xsl:template match="head|title">
    <p class="outline-head"><xsl:value-of select="."/></p>
  </xsl:template>
  <xsl:template name="item-hiearchy">
    <xsl:param name="itemid"/>
    <xsl:variable name="itemRepoPath" select="concat($baseRepoPath, $itemid, '/')"/>
    <xsl:variable name="extraction-file">
      <xsl:choose>
        <xsl:when test="document(concat($itemRepoPath, 'transcriptions.xml'))/manifestation[@manifestationDefault='true']/transcriptions/transcription[@transcriptionDefault='true']/version[@versionDefault='true']/url">
          <xsl:value-of select="concat($itemRepoPath, document(concat($itemRepoPath, 'transcriptionsNew.xml'))/manifestation[@manifestationDefault='true']/transcriptions/transcription[@transcriptionDefault='true']/version[@versionDefault='true']/url)"/>
        </xsl:when>
        <xsl:when test="document(concat($itemRepoPath, 'transcriptions.xml'))/transcriptions/transcription[@use-for-extraction='true']">
          <xsl:value-of select="concat($itemRepoPath, document(concat($itemRepoPath, 'transcriptions.xml'))/transcriptions/transcription[@use-for-extraction='true'])"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($itemRepoPath, $itemid, '.xml')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:message><xsl:value-of select="$extraction-file"/></xsl:message>
    <xsl:apply-templates select="document($extraction-file)//tei:body/tei:div[@xml:id=$itemid]"/>
    
  </xsl:template>
</xsl:stylesheet>
