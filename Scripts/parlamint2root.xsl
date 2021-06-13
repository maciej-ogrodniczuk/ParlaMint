<?xml version="1.0"?>
<!-- Take template for root ParlaMint corpus file and add info from XIncluded roots -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:variable name="today" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:variable name="docs">
    <xsl:for-each select="//xi:include">
      <!-- We need "../" as the this XSLT is in Scripts! -->
      <item>
	<xsl:value-of select="concat('../', @href)"/>
      </item>
    </xsl:for-each>
  </xsl:variable>

  <xsl:template match="tei:teiCorpus | tei:teiHeader">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:titleStmt/tei:respStmt[last()]">
    <xsl:copy-of select="."/>
    <xsl:for-each select="$docs//tei:item">
      <xsl:for-each select="document(.)/tei:teiCorpus">
	<xsl:variable name="corpus" select="@xml:id"/>
	<xsl:for-each select="tei:teiHeader//tei:titleStmt/tei:respStmt">
	  <xsl:copy>
	    <xsl:attribute name="n" select="$corpus"/>
	    <xsl:for-each select="tei:persName[not(@xml:lang) or @xml:lang != 'bg']">
	      <xsl:copy>
		<xsl:value-of select="."/>
	      </xsl:copy>
	    </xsl:for-each>
	    <xsl:for-each select="tei:resp[ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]">
	      <xsl:copy>
		<!--xsl:value-of select="concat($corpus, ': ', .)"/-->
		<xsl:value-of select="."/>
	      </xsl:copy>
	    </xsl:for-each>
	  </xsl:copy>
	</xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
    
  <xsl:template match="tei:title | tei:publisher">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="ancestor-or-self::tei:*[@xml:lang][1][@xml:lang!='en']">
	<xsl:attribute name="xml:lang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="when" select="$today"/>
      <xsl:value-of select="format-date(current-date(), '[MNn] [D], [Y]')"/>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="tei:titleStmt/tei:funder">
    <funder>
      <orgName>The CLARIN research infrastructure</orgName>
    </funder>
    <xsl:for-each select="$docs//tei:item">
      <xsl:for-each select="document(.)/tei:teiCorpus">
	<xsl:variable name="corpus" select="@xml:id"/>
	<xsl:variable name="funders">
	  <xsl:for-each select="tei:teiHeader//tei:titleStmt/tei:funder">
	    <xsl:if test="not(contains(., ' CLARIN '))">
	      <xsl:copy-of select="tei:*[ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]"/>
	    </xsl:if>
	  </xsl:for-each>
	</xsl:variable>
	<xsl:if test="normalize-space($funders)">
	  <funder n="{$corpus}">
	    <xsl:copy-of select="$funders"/>
	  </funder>
	</xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
    
  <xsl:template match="tei:extent">
    <xsl:copy>
      <xsl:variable name="corpora" select="count($docs/tei:item)"/>
      <measure unit="corpora" quantity="{format-number($corpora, '#')}">
	<xsl:value-of select="concat(format-number($corpora, '###,###,###'), ' corpora')"/>
      </measure>
      <!-- This number is the real number, but all else are fake!
      <xsl:variable name="text">
	<xsl:variable name="texts">
	  <xsl:for-each select="$docs/tei:item/document(.)/tei:teiCorpus">
	    <item>
	      <xsl:value-of select="count(xi:include)"/>
	    </item>
	  </xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="sum($texts/tei:item)"/>
      </xsl:variable>
      <measure unit="texts" quantity="{format-number($text, '#')}">
	<xsl:value-of select="concat(format-number($text, '###,###,###'), ' texts')"/>
      </measure-->
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:extent/tei:measure">
    <xsl:variable name="unit" select="@unit"/>
    <xsl:variable name="quant">
      <xsl:variable name="quants">
	<xsl:for-each select="$docs/tei:item/document(.)/tei:teiCorpus/tei:teiHeader//
			      tei:extent/tei:measure
			      [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']][@unit = $unit]">
	  <item>
	    <xsl:value-of select="@quantity"/>
	  </item>
	</xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="sum($quants/tei:item)"/>
    </xsl:variable>
    <xsl:copy>
      <xsl:attribute name="unit" select="$unit"/>
      <xsl:attribute name="quantity" select="format-number($quant, '#')"/>
      <xsl:value-of select="concat(format-number($quant, '###,###,###'), ' ', $unit)"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:tagUsage">
    <xsl:variable name="tagUsages">
      <xsl:for-each select="$docs/tei:item/document(.)/tei:teiCorpus/tei:teiHeader//
			    tei:tagsDecl//tei:tagUsage">
	<xsl:sort select="@gi"/>
	<xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each select="$tagUsages/tei:tagUsage">
      <xsl:variable name="gi" select="@gi"/>
      <xsl:if test="not(following-sibling::tei:tagUsage[@gi = $gi])">
	<xsl:variable name="occurences">
	  <xsl:for-each select="$tagUsages/tei:tagUsage[@gi = $gi]">
	    <item>
	      <xsl:value-of select="@occurs"/>
	    </item>
	  </xsl:for-each>
	</xsl:variable>
        <tagUsage gi="{$gi}" occurs="{format-number(sum($occurences/tei:item), '#')}"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="tei:sourceDesc/tei:bibl">
    <xsl:for-each select="$docs/tei:item/document(.)/tei:teiCorpus">
      <xsl:sort select="@xml:id"/>
      <listBibl>
	<xsl:attribute name="n" select="@xml:id"/>
	<head>
	  <xsl:value-of select="@xml:id"/>
	</head>
	<xsl:for-each select="tei:teiHeader//tei:sourceDesc/tei:bibl">
	  <bibl>
	    <xsl:apply-templates/>
	  </bibl>
	</xsl:for-each>
      </listBibl>
    </xsl:for-each>
  </xsl:template>
    
  <xsl:template match="tei:editorialDecl/tei:*">
    <xsl:variable name="name" select="name()"/>
    <xsl:copy>
      <xsl:for-each select="document($docs//tei:item)/tei:teiCorpus">
	<xsl:variable name="corpus" select="@xml:id"/>
	<xsl:for-each select="tei:teiHeader/tei:encodingDesc/
			      tei:editorialDecl/tei:*[name() = $name]/tei:p">
	  <xsl:copy>
	    <xsl:attribute name="n" select="$corpus"/>
	    <!--xsl:value-of select="concat($corpus, ': ', .)"/-->
	    <xsl:value-of select="."/>
	  </xsl:copy>
	</xsl:for-each>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:taxonomy">
    <xsl:variable name="id" select="@xml:id"/>
    <xsl:copy>
      <xsl:attribute name="xml:id" select="$id"/>
      <xsl:variable name="taxonomies">
	<xsl:for-each-group select="$docs/document(tei:item)/
				    tei:teiCorpus/tei:teiHeader//tei:classDecl/
				    tei:taxonomy[@xml:id = $id]/tei:category"
			    group-by="@xml:id">
	  <xsl:variable name="country-code" select="substring-after(
					    ancestor::tei:teiCorpus/@xml:id, '-')"/>
	  <category xml:id="{current-grouping-key()}-{$country-code}">
	    <xsl:for-each select="current-group()/tei:*">
	      <xsl:copy>
		<xsl:attribute name="corresp"
			       select="concat('#', ancestor::tei:teiCorpus/@xml:id)"/>
		<xsl:if test="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang != 'en'">
		  <xsl:attribute name="xml:lang"
				 select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
		</xsl:if>
		<xsl:apply-templates/>
	      </xsl:copy>
	    </xsl:for-each>
	  </category>
	</xsl:for-each-group>
      </xsl:variable>
      <xsl:copy-of select="$taxonomies"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:category">
    <xsl:variable name="country-code" select="substring-after(
					      ancestor::tei:teiCorpus/@xml:id, '-')"/>
    <xsl:variable name="id" select="concat(@xml:id, '-', $country-code)"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="xml:id" select="$id"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:appInfo">
    <xsl:for-each select="document($docs//tei:item)/tei:teiCorpus">
      <xsl:variable name="corpus" select="@xml:id"/>
      <xsl:for-each select="tei:teiHeader/tei:encodingDesc/tei:appInfo">
	<xsl:copy>
	  <xsl:attribute name="n" select="$corpus"/>
	  <xsl:apply-templates/>
	</xsl:copy>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="tei:settingDesc">
    <xsl:copy>
      <xsl:for-each select="$docs//document(tei:item)/tei:teiCorpus">
	<setting n="{@xml:id}">
	  <xsl:copy-of select="tei:teiHeader//tei:setting/tei:*"/>
	</setting>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="tei:change/@when">
    <xsl:attribute name="when" select="$today"/>
  </xsl:template>
    
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:if test="name() != 'xml:lang' and . != 'en'">
      <xsl:copy/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
