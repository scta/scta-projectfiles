<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:dc="http://purl.org/dc/elements/1.1/">

  <!-- VARIABLES -->
  <xsl:variable name="expression-id" select="//header/commentaryid"/>

  <xsl:output method="xml" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="node()|@*">
    <xsl:apply-templates />
    <!-- <xsl:copy> -->
    <!--   <xsl:apply-templates select="node()|@*"/> -->
    <!-- </xsl:copy> -->
  </xsl:template>

  <xsl:template match="listofFileNames">
    <edf>
      <header>
        <date/>
        <schema
            name="edf"
            version="1.0.0"
            url="https://github.com/scta/edf-schema/blob/master/src/edf.rng"/>
      </header>
      <body>
        <xsl:apply-templates  select="div[@id='body']"/>
      </body>
    </edf>
  </xsl:template>

  <xsl:template match="div[@id='body']">
    <div id="{$expression-id}">
      <!-- Global optional fields -->
      <dc:title><xsl:value-of select="//header/commentaryName"/></dc:title>
      <dc:creator><xsl:value-of select="//header/authorUri"/></dc:creator>
      <dc:description><xsl:value-of select="//header/description"/></dc:description>
      <!-- Top level metadata -->
      <parentWorkGroup><xsl:value-of select="tokenize(//header/parentWorkGroup, '/')[last()]" /></parentWorkGroup>
      
      <!-- to replace parent Work Group
        
        <xsl:variable name="parentWorkGroup" select="//header/parentWorkGroup"/>
        <work isCanonical="true" parentWorkGroup="{$parentWorkGroup}">w-<xsl:value-of select="$expression-id"/></work>
      
      -->
      
    </div>
    <attribution>
      <xsl:copy-of select="//header/questionListSource"/>
      <xsl:copy-of select="//header/questionListOriginalEditor"/>
      <xsl:copy-of select="//header/questionListEncoder"/>
    </attribution>
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="description">
    <dc:description><xsl:value-of select="." /></dc:description>
  </xsl:template>

  <xsl:template match="//header/questionListSource">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="hasWitnesses">
    <manifestations>
      <xsl:apply-templates/>
    </manifestations>
  </xsl:template>

  <xsl:template match="header/hasWitnesses/witness">
    <xsl:variable name="siglum" select="@id"/>
    <manifestation id="{$siglum}">
      <slug><xsl:value-of select="slug"/></slug>
      <dc:title><xsl:value-of select="title"/></dc:title>
      <xsl:apply-templates />
    </manifestation>
  </xsl:template>

  <xsl:template match="item/hasWitnesses/witness">
    <xsl:variable name="siglum" select="@ref"/>
    <manifestation ref="{$siglum}">
      <xsl:apply-templates />
    </manifestation>
  </xsl:template>

  <xsl:template match="folio">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="div">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="head">
    <dc:title><xsl:value-of select="."/></dc:title>
  </xsl:template>

  <xsl:template match="title">
    <dc:title><xsl:value-of select="."/></dc:title>
  </xsl:template>

  <xsl:template match="item">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="questionTitle">
    <xsl:copy-of select="."/>
  </xsl:template>


</xsl:stylesheet>
