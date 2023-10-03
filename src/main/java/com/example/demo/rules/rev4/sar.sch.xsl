<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:f="https://fedramp.gov/ns/oscal"
                xmlns:fedramp="https://fedramp.gov/ns/oscal"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:unit="http://us.gov/testing/unit-testing"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
   <xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>
   <!--PHASES-->
   <!--PROLOG-->
   <xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>
   <!--XSD TYPES FOR XSLT2-->
   <!--KEYS AND FUNCTIONS-->
   <!--DEFAULT RULES-->
   <!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-2-->
   <!--This mode can be used to generate prefixed XPath for humans-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
   <!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: GENERATE-ID-FROM-PATH -->
   <xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>
   <!--MODE: GENERATE-ID-2 -->
   <xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters-->
   <xsl:template match="text()" priority="-1"/>
   <!--SCHEMA SETUP-->
   <xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                              title="FedRAMP Security Assessment Results Validations"
                              schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="https://fedramp.gov/ns/oscal" prefix="f"/>
         <svrl:ns-prefix-in-attribute-values uri="http://csrc.nist.gov/ns/oscal/1.0" prefix="oscal"/>
         <svrl:ns-prefix-in-attribute-values uri="https://fedramp.gov/ns/oscal" prefix="fedramp"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2005/xpath-functions/array" prefix="array"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2005/xpath-functions/map" prefix="map"/>
         <svrl:ns-prefix-in-attribute-values uri="http://us.gov/testing/unit-testing" prefix="unit"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">import-ap</xsl:attribute>
            <xsl:attribute name="name">import-ap</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">results</xsl:attribute>
            <xsl:attribute name="name">results</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">automated-tools</xsl:attribute>
            <xsl:attribute name="name">automated-tools</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M24"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">sar-age-checks</xsl:attribute>
            <xsl:attribute name="name">sar-age-checks</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">metadata</xsl:attribute>
            <xsl:attribute name="name">metadata</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M26"/>
      </svrl:schematron-output>
   </xsl:template>
   <!--SCHEMATRON PATTERNS-->
   <doc:xspec xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
              xmlns:feddoc="http://us.gov/documentation/federal-documentation"
              xmlns:sch="http://purl.oclc.org/dsdl/schematron"
              href="../../test/rules/rev4/sar.xspec"/>
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">FedRAMP Security Assessment Results Validations</svrl:text>
   <xsl:param name="sap-import-url"
              select="             if (starts-with(/oscal:assessment-results/oscal:import-ap/@href, '#'))             then                 resolve-uri(/oscal:assessment-results/oscal:back-matter/oscal:resource[substring-after(/oscal:assessment-results/oscal:import-ap/@href, '#') = @uuid]/oscal:rlink/@href, base-uri())             else                 resolve-uri(/oscal:assessment-results/oscal:import-ap/@href, base-uri())"/>
   <xsl:param name="sap-available" select="doc-available($sap-import-url)"/>
   <xsl:param name="sap-doc"
              select="             if ($sap-available)             then                 doc($sap-import-url)             else                 ()"/>
   <xsl:param name="ssp-import-url"
              select="             if (starts-with($sap-doc/oscal:assessment-plan/oscal:import-ssp/@href, '#'))             then                 resolve-uri($sap-doc/oscal:assessment-plan/oscal:back-matter/oscal:resource[substring-after($sap-doc/oscal:assessment-plan/oscal:import-ssp/@href, '#') = @uuid]/oscal:rlink/@href, base-uri())             else                 resolve-uri($sap-doc/oscal:assessment-plan/oscal:import-ssp/@href, base-uri())"/>
   <xsl:param name="ssp-available"
              select="             if (: this is not a relative reference :) (not(starts-with($ssp-import-url, '#')))             then                 (: the referenced document must be available :)                 doc-available($ssp-import-url)             else                 true()"/>
   <xsl:param name="ssp-doc"
              select="             if ($ssp-available)             then                 doc($ssp-import-url)             else                 ()"/>
   <xsl:param name="resolved-profile-import-url"
              select="             if (starts-with($ssp-doc/oscal:system-security-plan/oscal:import-profile/@href, '#'))             then                 resolve-uri($ssp-doc/oscal:system-security-plan/oscal:back-matter/oscal:resource[substring-after($ssp-doc/oscal:system-security-plan/oscal:import-profile/@href, '#') = @uuid]/oscal:rlink/@href, base-uri())             else                 resolve-uri($ssp-doc/oscal:system-security-plan/oscal:import-profile/@href, base-uri())"/>
   <xsl:param name="resolved-profile-available"
              select="doc-available($resolved-profile-import-url)"/>
   <xsl:param name="resolved-profile-doc"
              select="             if ($resolved-profile-available)             then                 doc($resolved-profile-import-url)             else                 ()"/>
   <xsl:param xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
              xmlns:feddoc="http://us.gov/documentation/federal-documentation"
              xmlns:sch="http://purl.oclc.org/dsdl/schematron"
              as="xs:string"
              name="registry-base-path"
              select="'../../../content/rev4/resources/xml'"/>
   <xsl:param name="fedramp-values"
              select="doc(concat($registry-base-path, '/fedramp_values.xml'))"/>
   <xsl:param name="ssp-parties"
              select="$ssp-doc/oscal:system-security-plan/oscal:metadata/oscal:party/@uuid"/>
   <xsl:param name="sap-parties"
              select="$sap-doc/oscal:assessment-plan/oscal:metadata/oscal:party/@uuid"/>
   <xsl:param name="sar-parties"
              select="/oscal:assessment-results/oscal:metadata/oscal:party/@uuid"/>
   <!--PATTERN import-ap-->
   <!--RULE -->
   <xsl:template match="oscal:assessment-results" priority="1005" mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:assessment-results"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:import-ap"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:import-ap">
               <xsl:attribute name="id">has-import-ap</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SAR must have an import-ap element.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-import-ap-diagnostic">
This OSCAL SAR lacks an import-ap element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:import-ap" priority="1004" mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:import-ap"/>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="exists(@href)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists(@href)">
               <xsl:attribute name="id">has-import-ap-href</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SAR import-ap element must have an href attribute.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-import-ap-href-diagnostic">
This OSCAL SAR import-ap element lacks an href attribute.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="                     if (: this is a relative reference :) (matches(@href, '^#'))                     then                         (: the reference must exist within the document :)                         exists(//oscal:resource[@uuid eq substring-after(current()/@href, '#')])                     else                         (: the assertion succeeds :)                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (: this is a relative reference :) (matches(@href, '^#')) then (: the reference must exist within the document :) exists(//oscal:resource[@uuid eq substring-after(current()/@href, '#')]) else (: the assertion succeeds :) true()">
               <xsl:attribute name="id">has-import-ap-internal-href</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SAR import-ap element href attribute which is document-relative must identify a target within
                the document. <xsl:text/>
                  <xsl:value-of select="@href"/>
                  <xsl:text/>.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-import-ap-internal-href-diagnostic">
This OSCAL SAR import-ap element href attribute which is document-relative does not identify a
            target within the document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="$sap-doc/oscal:assessment-plan"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$sap-doc/oscal:assessment-plan">
               <xsl:attribute name="id">sap-document-available</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SAR import-ap element must reference an available SAP document.</svrl:text>
               <svrl:diagnostic-reference diagnostic="sap-document-available-diagnostic">
This OSCAL SAR import-ap element does not reference an available SAP document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="$ssp-doc/oscal:system-security-plan"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$ssp-doc/oscal:system-security-plan">
               <xsl:attribute name="id">ssp-document-available</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SAR import-ap element must reference an available SAP document that has an import-ssp element that
                references an available SSP document.</svrl:text>
               <svrl:diagnostic-reference diagnostic="ssp-document-available-diagnostic">
This OSCAL SAR import-ap element does not reference an available SAP document that has an
            import-ssp element that references an available SSP document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="$resolved-profile-doc/oscal:catalog"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$resolved-profile-doc/oscal:catalog">
               <xsl:attribute name="id">resolved-profile-catalog-document-available</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SAR import-ap element must reference an available SAP document that has an import-ssp element that
                references an available SSP document that has a import-profile element that references a resolved profile catalog
                document.</svrl:text>
               <svrl:diagnostic-reference diagnostic="resolved-profile-catalog-document-available-diagnostic">
This OSCAL SAR import-ap element does not reference an available SAP document
            that has an import-ssp element that references an available SSP document that has a import-profile element that references a resolved
            profile catalog document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="                     if (: this is not a relative reference :) (not(starts-with(@href, '#')))                     then                         (: the referenced document must be available :)                         doc-available($sap-import-url)                     else                         (: the assertion succeeds :)                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (: this is not a relative reference :) (not(starts-with(@href, '#'))) then (: the referenced document must be available :) doc-available($sap-import-url) else (: the assertion succeeds :) true()">
               <xsl:attribute name="id">has-import-ap-external-href</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SAR import-ap element href attribute which is an external reference must identify an available
                target.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-import-ap-external-href-diagnostic">
This OSCAL SAR import-ap element href attribute which is an external reference does not
            identify an available target.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:back-matter" priority="1003" mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:back-matter"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (matches(//oscal:import-ap/@href, '^#'))                     then                         (: there must be a security-assessment-plan resource :)                         exists(oscal:resource[oscal:prop[@name eq 'type' and @value eq 'security-assessment-plan']])                     else                         (: the assertion succeeds :)                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (matches(//oscal:import-ap/@href, '^#')) then (: there must be a security-assessment-plan resource :) exists(oscal:resource[oscal:prop[@name eq 'type' and @value eq 'security-assessment-plan']]) else (: the assertion succeeds :) true()">
               <xsl:attribute name="id">has-security-assessment-plan-resource</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SAR which does not directly import the SAP must declare the SAP as a back-matter
                resource.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-security-assessment-plan-resource-diagnostic">
This OSCAL SAR which does not directly import the SAP does not declare the SAP as a
            back-matter resource.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:resource[oscal:prop[@name = 'type' and @value = 'evidence']] | oscal:resource[oscal:prop[@name = 'type' and @value = 'artifact']]"
                 priority="1002"
                 mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:resource[oscal:prop[@name = 'type' and @value = 'evidence']] | oscal:resource[oscal:prop[@name = 'type' and @value = 'artifact']]"/>
      <xsl:variable name="relevant-evidence-href"
                    select="//oscal:observation/oscal:relevant-evidence/substring-after(@href, '#')"/>
      <xsl:variable name="subject-UUID"
                    select="//oscal:observation/oscal:subject/@subject-uuid"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (@uuid[. = $relevant-evidence-href])                     then                         true()                     else                         if (@uuid[. = $subject-UUID])                         then                             true()                         else                             false()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (@uuid[. = $relevant-evidence-href]) then true() else if (@uuid[. = $subject-UUID]) then true() else false()">
               <xsl:attribute name="id">has-type-artifact-evidence-resource</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Resources of type 'evidence' or 'artifact' must have a matching relevant-evidence or subject
                UUID.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-type-artifact-evidence-resource-diagnostic">
The resource, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, of type 'evidence' or 'artifact' does not have a matching relevant-evidence or subject UUID.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:rlink or oscal:base64"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:rlink or oscal:base64">
               <xsl:attribute name="id">has-type-artifact-evidence-rlink-base64</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An observation of type 'evidence' or 'artifact' must have at least one rlink and/or base64
                element.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-type-artifact-evidence-rlink-base64-diagnostic">
The resource, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, of type 'evidence' or 'artifact' does not have at least one rlink or base64 child element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:rlink[not(matches(@href, '^/'))]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:rlink[not(matches(@href, '^/'))]">
               <xsl:attribute name="id">has-type-artifact-evidence-rlink-relative-path</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>If an observation of type 'evidence' or 'artifact' has an rlink the @href value must be
                a relative path.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-type-artifact-evidence-rlink-relative-path-diagnostic">
A resource, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, of type 'evidence' or 'artifact' has an rlink where the @href value is not a relative path.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:resource[oscal:prop[@name = 'type' and @value eq 'security-assessment-plan']]"
                 priority="1001"
                 mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:resource[oscal:prop[@name = 'type' and @value eq 'security-assessment-plan']]"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:rlink) and not(exists(oscal:rlink[2]))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:rlink) and not(exists(oscal:rlink[2]))">
               <xsl:attribute name="id">has-sap-rlink</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SAR with a SAP resource declaration must have one and only one
                rlink element.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-sap-rlink-diagnostic">
This OSCAL SAR with a SAP resource declaration does not have one and only one rlink
            element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:resource[oscal:prop[@name = 'type' and @value eq 'security-assessment-plan']]/oscal:rlink"
                 priority="1000"
                 mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:resource[oscal:prop[@name = 'type' and @value eq 'security-assessment-plan']]/oscal:rlink"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@media-type = ('text/xml', 'application/json')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@media-type = ('text/xml', 'application/json')">
               <xsl:attribute name="id">has-acceptable-security-assessment-plan-rlink-media-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SAR SAP rlink must have a 'text/xml' or 'application/json'
                media-type.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-acceptable-security-assessment-plan-rlink-media-type-diagnostic">
This OSCAL SAR SAP rlink does not have a 'text/xml' or
            'application/json' media-type.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
   </xsl:template>
   <!--PATTERN results-->
   <!--RULE -->
   <xsl:template match="oscal:result" priority="1015" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:result"/>
      <xsl:variable name="excluded-controls"
                    select="oscal:reviewed-controls/oscal:control-selection/oscal:exclude-control/@control-id"/>
      <xsl:variable name="included-controls"
                    select="                     if (oscal:reviewed-controls/oscal:control-selection/oscal:include-all)                     then                         $resolved-profile-doc//oscal:control/@id                     else                         oscal:reviewed-controls/oscal:control-selection/oscal:include-control/@control-id"/>
      <xsl:variable name="in-scope-controls"
                    select="$included-controls[not(. = $excluded-controls)]"/>
      <xsl:variable name="matching-response-point-ids"
                    select="                     for $i in $in-scope-controls                     return                         $resolved-profile-doc//oscal:control[@id = $i]//oscal:part[@name = 'objective'][oscal:prop[@name = 'response-point']]/@id"/>
      <xsl:variable name="finding-target-IDs"
                    select="oscal:finding/oscal:target[@type = 'objective-id']/@target-id"/>
      <xsl:variable name="finding-not-matches-with-response-points"
                    select="$matching-response-point-ids[not(. = $finding-target-IDs)]"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="$finding-not-matches-with-response-points = ''"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$finding-not-matches-with-response-points = ''">
               <xsl:attribute name="id">objectives-match-response-points</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>All in scope controls in the resolved baseline profile must have objectives that match a
                finding/target/@target-id in the current result assembly.</svrl:text>
               <svrl:diagnostic-reference diagnostic="objectives-match-response-points-diagnostic">
In the result, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, the following response points do not have matching finding/target/@target-id values: <xsl:text/>
                  <xsl:value-of select="$finding-not-matches-with-response-points"/>
                  <xsl:text/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:attestation[oscal:part[@name = 'authorization-statements']/oscal:prop[@ns = 'https://fedramp.gov/ns/oscal' and @name = 'recommend-authorization']]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:attestation[oscal:part[@name = 'authorization-statements']/oscal:prop[@ns = 'https://fedramp.gov/ns/oscal' and @name = 'recommend-authorization']]">
               <xsl:attribute name="id">has-attestation</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                There must exist an attestation with a part containing a property with a name of 'recommend-authorization'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-attestation-diagnostic">
The result, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, does not contain an attestation/part with a property of 'recommend-authorization'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="pl-2-other-than-satisfied-findings"
                    select="oscal:finding/oscal:target[@type = 'objective-id'][oscal:status ne 'satisfied'][matches(@target-id, '^pl-2\.')]/@target-id"/>
      <xsl:variable name="pl-2-profile-objectives"
                    select="$resolved-profile-doc/oscal:catalog//oscal:part[@name eq 'objective'][ancestor::oscal:control[@id eq 'pl-2']]/@id"/>
      <xsl:variable name="pl-2-not-matches-other-than-satisfied-findings"
                    select="$pl-2-other-than-satisfied-findings[not(. = $pl-2-profile-objectives)]"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count($pl-2-other-than-satisfied-findings) gt 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count($pl-2-other-than-satisfied-findings) gt 0">
               <xsl:attribute name="id">matching-control-PL-2-objectives</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Within a SAR, every unsatisfied PL-2 objective must have a matching resolved baseline profile catalog
                part.</svrl:text>
               <svrl:diagnostic-reference diagnostic="matching-control-PL-2-objectives-diagnostic">
Within a SAR, the PL-2 unsatisfied objectives, <xsl:text/>
                  <xsl:value-of select="$pl-2-not-matches-other-than-satisfied-findings"/>
                  <xsl:text/>, do not have a matching part in the resolved profile
            catalog.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(oscal:finding[oscal:target[@type = 'objective-id' and oscal:status/@state ne 'statisfied' and matches(@target-id, '^pl-2\.')]]) lt 2"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(oscal:finding[oscal:target[@type = 'objective-id' and oscal:status/@state ne 'statisfied' and matches(@target-id, '^pl-2\.')]]) lt 2">
               <xsl:attribute name="id">minimal-control-PL-2-findings</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every
                result must contain no more than one unsatisfied finding for the control PL-2.</svrl:text>
               <svrl:diagnostic-reference diagnostic="minimal-control-PL-2-findings-diagnostic">
Within a SAR, the result, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, contains more than one finding for the control PL-2.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:actor" priority="1014" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:actor"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (../../oscal:target[@type = 'objective-id'])                     then                         (@actor-uuid[. = $sap-parties]) or (@actor-uuid[. = $sar-parties])                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (../../oscal:target[@type = 'objective-id']) then (@actor-uuid[. = $sap-parties]) or (@actor-uuid[. = $sar-parties]) else true()">
               <xsl:attribute name="id">has-matching-SAP-party</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A finding must have an actor who is described in a SAP or SAR party assembly.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-matching-SAP-party-diagnostic">
The <xsl:text/>
                  <xsl:value-of select="../../local-name()"/>
                  <xsl:text/>, <xsl:text/>
                  <xsl:value-of select="../../@uuid"/>
                  <xsl:text/>, has a party, <xsl:text/>
                  <xsl:value-of select="@actor-uuid"/>
                  <xsl:text/>, that does not match a SAP or SAR party assembly.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (../../oscal:type = 'historic')                     then                         if (@actor-uuid[. = $sap-parties])                         then                             true()                         else                             if (@actor-uuid[. = $sar-parties])                             then                                 true()                             else                                 false()                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (../../oscal:type = 'historic') then if (@actor-uuid[. = $sap-parties]) then true() else if (@actor-uuid[. = $sar-parties]) then true() else false() else true()">
               <xsl:attribute name="id">has-matching-historic-party</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A historic observation must have an actor that is described in either the SAP or the SAR party
                assemblies.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-matching-historic-party-diagnostic">
The historic observation, <xsl:text/>
                  <xsl:value-of select="../../@uuid"/>
                  <xsl:text/>, has an actor that is not described in either the SAP or the SAR party assemblies.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="actorTypes" select="'tool', 'party', 'assessment-platform'"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@type[. = $actorTypes]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@type[. = $actorTypes]">
               <xsl:attribute name="id">has-correct-actor-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The actor @type must have one of the following as string content: 'tool', 'party', or
                'assessment-platform'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-correct-actor-type-diagnostic">
An actor element's type attribute in <xsl:text/>
                  <xsl:value-of select="../../local-name()"/>
                  <xsl:text/>
                  <xsl:text/>
                  <xsl:value-of select="../../@uuid"/>
                  <xsl:text/>, does not contain one of the following strings: 'tool', 'party', or 'assessment-platform'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:target" priority="1013" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:target"/>
      <xsl:variable name="implementation-status"
                    select="$fedramp-values/f:fedramp-values/f:value-set[@name = 'control-implementation-status']/f:allowed-values/f:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (current()[@type = 'objective-id'])                     then                         oscal:prop[@ns = 'https://fedramp.gov/ns/oscal' and @name = 'implementation-status']                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (current()[@type = 'objective-id']) then oscal:prop[@ns = 'https://fedramp.gov/ns/oscal' and @name = 'implementation-status'] else true()">
               <xsl:attribute name="id">has-implementation-status</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A target of objective-id type must have a property of 'implementation-status'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-implementation-status-diagnostic">
The target, <xsl:text/>
                  <xsl:value-of select="@target-id"/>
                  <xsl:text/>, does not have a property of 'implementation-status'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (current()[@type = 'objective-id']/oscal:prop[@ns = 'https://fedramp.gov/ns/oscal' and @name = 'implementation-status'])                     then                         oscal:prop[@ns = 'https://fedramp.gov/ns/oscal' and @name = 'implementation-status']/@value[. = $implementation-status]                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (current()[@type = 'objective-id']/oscal:prop[@ns = 'https://fedramp.gov/ns/oscal' and @name = 'implementation-status']) then oscal:prop[@ns = 'https://fedramp.gov/ns/oscal' and @name = 'implementation-status']/@value[. = $implementation-status] else true()">
               <xsl:attribute name="id">implementation-status-value</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The target's implementation-status property must be properly identified.</svrl:text>
               <svrl:diagnostic-reference diagnostic="implementation-status-value-diagnostic">
The implementation-status of the target, <xsl:text/>
                  <xsl:value-of select="@target-id"/>
                  <xsl:text/>, does not match acceptable FedRAMP values.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="satisfaction-status" select="'satisfied', 'other-than-satisfied'"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (current()[@type = 'objective-id'])                     then                         oscal:status                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (current()[@type = 'objective-id']) then oscal:status else true()">
               <xsl:attribute name="id">has-satisfaction-status</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A target of objective-id type must have a status.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-satisfaction-status-diagnostic">
The target, <xsl:text/>
                  <xsl:value-of select="@target-id"/>
                  <xsl:text/>, does not have a status child element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (current()[@type = 'objective-id']/oscal:status)                     then                         oscal:status/@state[. = $satisfaction-status]                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (current()[@type = 'objective-id']/oscal:status) then oscal:status/@state[. = $satisfaction-status] else true()">
               <xsl:attribute name="id">satisfaction-status-value</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The target's status element must be properly identified.</svrl:text>
               <svrl:diagnostic-reference diagnostic="satisfaction-status-value-diagnostic">
The satisfaction status of the target, <xsl:text/>
                  <xsl:value-of select="@target-id"/>
                  <xsl:text/>, does not match acceptable FedRAMP values.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(ancestor::oscal:result//oscal:target/@target-id[. eq current()/@target-id]) eq 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(ancestor::oscal:result//oscal:target/@target-id[. eq current()/@target-id]) eq 1">
               <xsl:attribute name="id">no-duplicate-target-id</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every finding target must be unique
                within a result.</svrl:text>
               <svrl:diagnostic-reference diagnostic="no-duplicate-target-id-diagnostic">
At least one objective target in the most recent result assembly is duplicated.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:subject" priority="1012" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:subject"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (../oscal:type = 'control-objective' and ../oscal:method = 'INTERVIEW')                     then                         if (@subject-uuid[. = $ssp-parties])                         then                             true()                         else                             if (@subject-uuid[. = $sap-parties])                             then                                 true()                             else                                 if (@subject-uuid[. = $sar-parties])                                 then                                     true()                                 else                                     false()                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (../oscal:type = 'control-objective' and ../oscal:method = 'INTERVIEW') then if (@subject-uuid[. = $ssp-parties]) then true() else if (@subject-uuid[. = $sap-parties]) then true() else if (@subject-uuid[. = $sar-parties]) then true() else false() else true()">
               <xsl:attribute name="id">has-subject-matching-party-uuid</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A subject uuid within an observation of type 'control-objective' must have a matching party @uuid in the
                metadata.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-subject-matching-party-uuid-diagnostic">
The observation, <xsl:text/>
                  <xsl:value-of select="../@uuid"/>
                  <xsl:text/>, has a subject uuid, <xsl:text/>
                  <xsl:value-of select="@subject-uuid"/>
                  <xsl:text/>, that does not match a party @uuid in the SSP, SAP, or SAR metadata assembly.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="SAR-backmatter-resources"
                    select="/oscal:assessment-results/oscal:back-matter/oscal:resource/@uuid"/>
      <xsl:variable name="subject-values"
                    select="'component', 'inventory-item', 'location', 'party', 'user'"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@type[. = $subject-values]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@type[. = $subject-values]">
               <xsl:attribute name="id">has-correct-subject-values</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A subject element type attribute must contain one of the following as string content: 'component',
                'inventory-item', 'location', 'party', or 'user'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-correct-subject-values-diagnostic">
A subject element's type attribute in <xsl:text/>
                  <xsl:value-of select="../local-name()"/>
                  <xsl:text/>
                  <xsl:text/>
                  <xsl:value-of select="../@uuid"/>
                  <xsl:text/>, does not contain one of the following strings: 'component', 'inventory-item', 'location', 'party', or
            'user'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (../oscal:type = 'control-objective' and ../oscal:method = 'EXAMINE')                     then                         @subject-uuid[. = $SAR-backmatter-resources]                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (../oscal:type = 'control-objective' and ../oscal:method = 'EXAMINE') then @subject-uuid[. = $SAR-backmatter-resources] else true()">
               <xsl:attribute name="id">has-subject-matching-resource-uuid</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A subject uuid within an observation of type 'control-objective' must have a matching resource @uuid
                in the back-matter.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-subject-matching-resource-uuid-diagnostic">
The observation, <xsl:text/>
                  <xsl:value-of select="../@uuid"/>
                  <xsl:text/>, has a subject uuid, <xsl:text/>
                  <xsl:value-of select="@subject-uuid"/>
                  <xsl:text/>, that does not match a resource @uuid in the SAR back-matter assembly.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:method" priority="1011" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:method"/>
      <xsl:variable name="method-values" select="'EXAMINE', 'INTERVIEW', 'TEST'"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test=". = $method-values"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=". = $method-values">
               <xsl:attribute name="id">has-correct-method-values</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A method element must contain one of the following strings: 'EXAMINE', 'INTERVIEW', or 'TEST'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-correct-method-values-diagnostic">
A method element in <xsl:text/>
                  <xsl:value-of select="../local-name()"/>
                  <xsl:text/>, does not contain one of the following strings: 'EXAMINE', 'INTERVIEW', or 'TEST'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:related-task" priority="1010" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:related-task"/>
      <xsl:variable name="sap-tasks"
                    select="$sap-doc/oscal:assessment-plan/oscal:task/@uuid"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@task-uuid[. = $sap-tasks]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@task-uuid[. = $sap-tasks]">
               <xsl:attribute name="id">has-matching-SAP-tasks</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A related-task element's uuid attribute must match a task @uuid value in the associated SAP.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-matching-SAP-tasks-diagnostic">
A related-task element's uuid attribute in <xsl:text/>
                  <xsl:value-of select="../../local-name()"/>
                  <xsl:text/>
                  <xsl:text/>
                  <xsl:value-of select="../../@uuid"/>
                  <xsl:text/>, does not match any task @uuid value in the associated SAP.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:observation" priority="1009" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:observation"/>
      <xsl:variable name="related-observations"
                    select="/oscal:assessment-results/oscal:result/oscal:finding/oscal:related-observation/@observation-uuid"/>
      <xsl:variable name="resourceUUIDs"
                    select="/oscal:assessment-results/oscal:back-matter/oscal:resource/@uuid"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:type = 'risk-adjustment')                     then                         if (@uuid[. = $related-observations])                         then                             true()                         else                             false()                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:type = 'risk-adjustment') then if (@uuid[. = $related-observations]) then true() else false() else true()">
               <xsl:attribute name="id">has-risk-adjustment-observation</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An observation with a type of 'risk-adjustment' must have a @uuid that matches a
                finding/related-observation/@observation-uuid.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-risk-adjustment-observation-diagnostic">
An observation, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, with a type of 'risk-adjustment' does not have a @uuid that matches a
            finding/related-observation/@observation-uuid.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:type = 'operational-requirement')                     then                         if (@uuid[. = $related-observations])                         then                             true()                         else                             false()                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:type = 'operational-requirement') then if (@uuid[. = $related-observations]) then true() else false() else true()">
               <xsl:attribute name="id">has-operational-requirement-observation</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An observation with a type of 'operational-requirement' must have a @uuid that matches a
                finding/related-observation/@observation-uuid.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-operational-requirement-observation-diagnostic">
An observation, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, with a type of 'operational-requirement' does not have a @uuid that matches a
            finding/related-observation/@observation-uuid.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:type = 'risk-adjustment')                     then                         if (oscal:relevant-evidence/oscal:link[substring-after(@href, '#')[. = $resourceUUIDs]])                         then                             true()                         else                             false()                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:type = 'risk-adjustment') then if (oscal:relevant-evidence/oscal:link[substring-after(@href, '#')[. = $resourceUUIDs]]) then true() else false() else true()">
               <xsl:attribute name="id">has-risk-adjustment-relevant-evidence</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An observation with a type of 'risk-adjustment' must have a relevant-evidence/link/@href, whose value
                after the '#', matches a back-matter/resource/@uuid.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-risk-adjustment-relevant-evidence-diagnostic">
An observation, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, with a type of 'risk-adjustment' does not have a relevant-evidence/link/@href, whose value after the '#', matches a
            back-matter/resource/@uuid.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:type = 'operational-requirement')                     then                         if (oscal:relevant-evidence[substring-after(@href, '#') = /oscal:assessment-results/oscal:back-matter/oscal:resource/@uuid])                         then                             true()                         else                             false()                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:type = 'operational-requirement') then if (oscal:relevant-evidence[substring-after(@href, '#') = /oscal:assessment-results/oscal:back-matter/oscal:resource/@uuid]) then true() else false() else true()">
               <xsl:attribute name="id">has-operational-requirement-relevant-evidence</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An observation with a type of 'operational-requirement' must have a relevant-evidence/@href, whose
                value after the '#', matches a back-matter/resource/@uuid.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-operational-requirement-relevant-evidence-diagnostic">
An observation, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, with a type of 'operational-requirement' does not have a relevant-evidence/@href, whose value after the '#',
            matches a back-matter/resource/@uuid.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:type = 'historic' and oscal:method = 'MIXED'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:type = 'historic' and oscal:method = 'MIXED'">
               <xsl:attribute name="id">has-method-MIXED</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An observation of type 'historic' must also have a method of
                'MIXED'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-method-MIXED-diagnostic">
The historic observation, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, does not have a method of 'MIXED'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:type = 'ssp-statement-issue')                     then                         oscal:method = 'EXAMINE'                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:type = 'ssp-statement-issue') then oscal:method = 'EXAMINE' else true()">
               <xsl:attribute name="id">has-type-ssp-statement-issue</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An observation with a type of 'ssp-statement-issue' must also have a method of 'EXAMINE'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-type-ssp-statement-issue-diagnostic">
The observation, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, has a type of 'ssp-statement-issue' but does not have a method of 'EXAMINE'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:type = 'ssp-statement-issue')                     then                         @uuid[. = $related-observations]                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:type = 'ssp-statement-issue') then @uuid[. = $related-observations] else true()">
               <xsl:attribute name="id">has-type-ssp-statement-issue-matches-related-observation</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An observation with a type of 'ssp-statement-issue' must have a matching
                finding/related-observation/@observation-uuid value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-type-ssp-statement-issue-matches-related-observation-diagnostic">
The observation, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, does not have a matching finding/related-observation/@observation-uuid in the SAR.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="ssp-statement-uuids" select="$ssp-doc//oscal:statement/@uuid"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:type = 'ssp-statement-issue')                     then                         if (@uuid[. = $related-observations])                         then                             ../oscal:finding[oscal:related-observation/@observation-uuid = current()/@uuid]/oscal:implementation-statement-uuid[. = $ssp-statement-uuids]                         else                             true()                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:type = 'ssp-statement-issue') then if (@uuid[. = $related-observations]) then ../oscal:finding[oscal:related-observation/@observation-uuid = current()/@uuid]/oscal:implementation-statement-uuid[. = $ssp-statement-uuids] else true() else true()">
               <xsl:attribute name="id">has-implementation-statement-uuid-matches-ssp-statement-uuid</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The finding that has a related-observation/observation-uuid that matches an observation/@uuid, must also
                have a implementation-statement-uuid value that matches a statement/@uuid in the associated SSP.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-implementation-statement-uuid-matches-ssp-statement-uuid-diagnostic">
The finding, <xsl:text/>
                  <xsl:value-of select="../oscal:finding[oscal:related-observation/@observation-uuid = current()/@uuid]/@uuid"/>
                  <xsl:text/>, that has a
            related-observation/observation-uuid that matches an observation/@uuid, also has a implementation-statement-uuid value that matches a
            statement/@uuid in the associated SSP.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:type = 'false-positive')                     then                         if (@uuid[. = $related-observations])                         then                             true()                         else                             false()                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:type = 'false-positive') then if (@uuid[. = $related-observations]) then true() else false() else true()">
               <xsl:attribute name="id">has-false-positive-observation</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An observation with a type of 'false-positive' must have a @uuid that matches a
                finding/related-observation/@observation-uuid.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-false-positive-observation-diagnostic">
An observation, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, with a type of 'false-positive' does not have a @uuid that matches a
            finding/related-observation/@observation-uuid.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:type = 'finding' and oscal:method = 'TEST')                     then                         if (oscal:relevant-evidence[substring-after(@href, '#') = /oscal:assessment-results/oscal:back-matter/oscal:resource[                         oscal:prop[@value = 'penetration-test-report']]/@uuid])                         then                             true()                         else                             false()                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:type = 'finding' and oscal:method = 'TEST') then if (oscal:relevant-evidence[substring-after(@href, '#') = /oscal:assessment-results/oscal:back-matter/oscal:resource[ oscal:prop[@value = 'penetration-test-report']]/@uuid]) then true() else false() else true()">
               <xsl:attribute name="id">has-pen-test-finding-resource</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An observation must have a relevant-evidence href that matches the penetration-test-report back-matter
                resource @uuid value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-pen-test-finding-resource-diagnostic">
An observation has a relevant-evidence href that does not matches the
            penetration-test-report back-matter resource @uuid value.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="pen-test-team"
                    select="/oscal:assessment-results/oscal:metadata/oscal:responsible-party[@role-id = 'penetration-test-lead']/oscal:party-uuid | /oscal:assessment-results/oscal:metadata/oscal:responsible-party[@role-id = 'penetration-test-team']/oscal:party-uuid"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:type = 'finding' and oscal:method = 'TEST' and not(oscal:subject/@type = 'component') and oscal:relevant-evidence[substring-after(@href, '#') = /oscal:assessment-results/oscal:back-matter/oscal:resource[                     oscal:prop[@value = 'penetration-test-report']]/@uuid])                     then                         if (oscal:origin/oscal:actor[@type = 'party']/@actor-uuid[. = $pen-test-team])                         then                             true()                         else                             false()                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:type = 'finding' and oscal:method = 'TEST' and not(oscal:subject/@type = 'component') and oscal:relevant-evidence[substring-after(@href, '#') = /oscal:assessment-results/oscal:back-matter/oscal:resource[ oscal:prop[@value = 'penetration-test-report']]/@uuid]) then if (oscal:origin/oscal:actor[@type = 'party']/@actor-uuid[. = $pen-test-team]) then true() else false() else true()">
               <xsl:attribute name="id">has-pen-test-team-match</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A penetration test observation must have actors that are described in the responsible-party assemblies
                for 'penetration-test-lead' or 'penetration-test-team'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-pen-test-team-match-diagnostic">
A penetration test observation, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/> has actors that are not described in the responsible-party assemblies for 'penetration-test-lead' or
            'penetration-test-team'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:related-observation" priority="1008" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:related-observation"/>
      <xsl:variable name="false-positive-observations"
                    select="/oscal:assessment-results/oscal:result/oscal:observation[oscal:type = 'false-positive']/@uuid"/>
      <xsl:variable name="false-positive-risks"
                    select="/oscal:assessment-results/oscal:result/oscal:risk/@uuid"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (@observation-uuid[. = $false-positive-observations])                     then                         if (../oscal:associated-risk/@risk-uuid[. = $false-positive-risks])                         then                             true()                         else                             false()                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (@observation-uuid[. = $false-positive-observations]) then if (../oscal:associated-risk/@risk-uuid[. = $false-positive-risks]) then true() else false() else true()">
               <xsl:attribute name="id">has-false-positive-related-related-observation</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A related-observation that has an @observation-uuid that matches an observation/@uuid with a type of
                'false-positive' must have an associated-risk/@risk-uuid that matches a risk/@uuid.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-false-positive-related-related-observation-diagnostic">
A related-observation, within the finding <xsl:text/>
                  <xsl:value-of select="../@uuid"/>
                  <xsl:text/>, that has an @observation-uuid that matches an observation/@uuid with a type of 'false-positive' does not have an
            associated-risk/@risk-uuid that matches a risk/@uuid.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <xsl:variable name="ssp-statement-uuids" select="$ssp-doc//oscal:statement/@uuid"/>
   <!--RULE -->
   <xsl:template match="oscal:risk" priority="1006" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:risk"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:prop[@ns = 'https://fedramp.gov/ns/oscal' and @name = 'risk-adjustment'])                     then                         if (@uuid[. = $ssp-statement-uuids])                         then                             true()                         else                             false()                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:prop[@ns = 'https://fedramp.gov/ns/oscal' and @name = 'risk-adjustment']) then if (@uuid[. = $ssp-statement-uuids]) then true() else false() else true()">
               <xsl:attribute name="id">has-risk-adjustment-matching-control-implementation-statement</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A risk with an @ns of 'https://fedramp.gov/ns/oscal' and an @name of 'risk-adjustment' should have a
                matching statement in the associated SSP.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-risk-adjustment-matching-control-implementation-statement-diagnostic">
A risk, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, with a type of 'risk-adjustment' does not have a matching statement @uuid in the associated SSP.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:status = 'closed')                     then                         if (oscal:risk-log/oscal:entry/oscal:status-change = 'closed')                         then                             true()                         else                             false()                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:status = 'closed') then if (oscal:risk-log/oscal:entry/oscal:status-change = 'closed') then true() else false() else true()">
               <xsl:attribute name="id">has-risk-log-status-closed</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A risk with a status of 'closed' must have a risk-log/entry with a status-change of
                'closed'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-risk-log-status-closed-diagnostic">
A risk, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, with a status of 'closed' does not have a risk-log/entry with a status-change of 'closed'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:prop[@name = 'priority'])                     then                         if (normalize-space($risk-priority-values) = '')                         then                             true()                         else                             if (oscal:prop[@name = 'priority']/@value[. ne $risk-priority-values])                             then                                 true()                             else                                 false()                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:prop[@name = 'priority']) then if (normalize-space($risk-priority-values) = '') then true() else if (oscal:prop[@name = 'priority']/@value[. ne $risk-priority-values]) then true() else false() else true()">
               <xsl:attribute name="id">has-duplicate-priority-value</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Risks with priority properties must have unique priority values.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-duplicate-priority-value-diagnostic">
The risk, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/> has a priority property that is not a unique priority value.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:response[@lifecycle = 'recommendation']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:response[@lifecycle = 'recommendation']">
               <xsl:attribute name="id">has-lifecycle-recommendation</xsl:attribute>
               <xsl:attribute name="see">https://github.com/GSA/fedramp-automation-guides/issues/45</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A risk must have a response of lifecycle with a value of
                recommendation.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-lifecycle-recommendation-diagnostic">
This risk, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, does not have a response element with a lifecycle of 'recommendation'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <xsl:variable name="risk-priority-values"
                 select="distinct-values(//oscal:risk/oscal:prop[@name = 'priority']/@value[. = following::oscal:risk/oscal:prop[@name = 'priority']/@value])"/>
   <!--RULE -->
   <xsl:template match="oscal:attestation/oscal:part[@name = 'authorization-statements'][oscal:prop[@ns = 'https://fedramp.gov/ns/oscal' and @name = 'recommend-authorization']]"
                 priority="1004"
                 mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:attestation/oscal:part[@name = 'authorization-statements'][oscal:prop[@ns = 'https://fedramp.gov/ns/oscal' and @name = 'recommend-authorization']]"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:prop/@value ne 'yes')                     then                         if (matches(normalize-space(oscal:part[1]/oscal:p[1]), 'A total of \w+ system risk(s?) were identified for .+, including .* High risk(s?), \w+ Moderate risk(s?), \w+ Low risk(s?), and \w+ of operationally required risk(s?).'))                         then                             true()                         else                             false()                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:prop/@value ne 'yes') then if (matches(normalize-space(oscal:part[1]/oscal:p[1]), 'A total of \w+ system risk(s?) were identified for .+, including .* High risk(s?), \w+ Moderate risk(s?), \w+ Low risk(s?), and \w+ of operationally required risk(s?).')) then true() else false() else true()">
               <xsl:attribute name="id">has-attestation-value-no</xsl:attribute>
               <xsl:attribute name="see">Guide to OSCAL-based FedRAMP Security Assessment Results - Section 4.12</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The recommend-authorization attestation with a non-yes value must have a first part with a first
                paragraph that matches the text in the Guide.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-attestation-value-no-diagnostic">
The recommend-authorization attestation with a non-yes value does not have a first part with a
            first paragraph that matches the text in the Guide.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:finding" priority="1003" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:finding"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:target/oscal:status/@state = 'not-satisfied')                     then                         exists(oscal:associated-risk)                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:target/oscal:status/@state = 'not-satisfied') then exists(oscal:associated-risk) else true()">
               <xsl:attribute name="id">has-finding-target-status-issue</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A finding with a target/status of 'not-satisfied must have an associated-risk element.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-finding-target-status-diagnostic">
This finding, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, has a target/status of the value 'not-satisfied' but does not have an associated-risk element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:associated-risk" priority="1002" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:associated-risk"/>
      <xsl:variable name="SAR-risk-uuids"
                    select="/oscal:assessment-results/oscal:result/oscal:risk/@uuid"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@risk-uuid[. = $SAR-risk-uuids]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@risk-uuid[. = $SAR-risk-uuids]">
               <xsl:attribute name="id">has-associated-risk-matching</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An associated-risk/@risk-uuid must have a matching risk/@uuid in the SAR.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-associated-risk-matching-diagnostic">
This associated-risk, <xsl:text/>
                  <xsl:value-of select="@risk-uuid"/>
                  <xsl:text/>, does not match any risk uuid values in the SAR.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:characterization" priority="1001" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:characterization"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:facet[@name = 'likelihood' and @system = 'https://fedramp.gov'] and oscal:facet[@name = 'impact' and @system = 'https://fedramp.gov']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:facet[@name = 'likelihood' and @system = 'https://fedramp.gov'] and oscal:facet[@name = 'impact' and @system = 'https://fedramp.gov']">
               <xsl:attribute name="id">has-facet-likelihood-and-impact</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Facets
                with @name of 'likelihood' and @name='impact' must exist in the characterization.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-facet-likelihood-and-impact-diagnostic">
Within a characterization in the risk assembly, <xsl:text/>
                  <xsl:value-of select="../@uuid"/>
                  <xsl:text/>, there is not a facet[@name='likelihood'] and a facet[@name='impact'].</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:facet" priority="1000" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:facet"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if ((@name = 'likelihood') and @system = 'https://fedramp.gov' or (@name = 'impact') and @system = 'https://fedramp.gov')                     then                         @value = ('low', 'moderate', 'high')                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if ((@name = 'likelihood') and @system = 'https://fedramp.gov' or (@name = 'impact') and @system = 'https://fedramp.gov') then @value = ('low', 'moderate', 'high') else true()">
               <xsl:attribute name="id">has-facet-correct-values</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A facet with @name = 'likelihood' or @name='impact' must have an @value of either 'low', 'moderate',
                or 'high'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-facet-correct-values-diagnostic">
This risk, <xsl:text/>
                  <xsl:value-of select="../../@uuid"/>
                  <xsl:text/>, has a characterization/facet element with the @name of either 'likelihood' or 'impact' whose @value is not
            'low', 'moderate' or 'high'..</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <!--PATTERN automated-tools-->
   <!--RULE -->
   <xsl:template match="oscal:observation[oscal:origin/oscal:actor/@type = 'tool']"
                 priority="1001"
                 mode="M24">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:observation[oscal:origin/oscal:actor/@type = 'tool']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:type = 'finding' and oscal:method = 'TEST'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:type = 'finding' and oscal:method = 'TEST'">
               <xsl:attribute name="id">has-method-TEST</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An observation of actor type 'tool' must have a type of 'finding' and a method
                of 'TEST'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-method-TEST-diagnostic">
The finding observation, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, of actor type 'tool' does not have a type of 'finding' and a method of 'TEST'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="assessment-assets-components"
                    select="../oscal:local-definitions/oscal:assessment-assets/oscal:component/@uuid"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@uuid[. = $assessment-assets-components]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@uuid[. = $assessment-assets-components]">
               <xsl:attribute name="id">has-matching-assessment-asset-component</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An observation with an actor of type 'tool' must have a matching
                assessment-assets/component.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-matching-assessment-asset-component-diagnostic">
An observation with an actor of type 'tool' does not have a matching
            assessment-assets/component.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="related-observation-UUIDs"
                    select="../oscal:finding/oscal:related-observation/@observation-uuid"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@uuid[. = $related-observation-UUIDs]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@uuid[. = $related-observation-UUIDs]">
               <xsl:attribute name="id">has-related-observation</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The observation UUID must be cited by (at least) one of the parent result's finding
                related observations.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-related-observation-diagnostic">
An observation, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, is not cited by (at least) one of the parent result's finding related observations.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     (: there is a raw-tool-output resource with the UUID referenced by the context item's relevant-evidence :)                     //oscal:resource[oscal:prop[@name eq 'type' and @value eq 'raw-tool-output'] and @uuid eq current()/oscal:relevant-evidence[substring-after(@href, '#')]]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(: there is a raw-tool-output resource with the UUID referenced by the context item's relevant-evidence :) //oscal:resource[oscal:prop[@name eq 'type' and @value eq 'raw-tool-output'] and @uuid eq current()/oscal:relevant-evidence[substring-after(@href, '#')]]">
               <xsl:attribute name="id">has-relevant-evidence</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This
                observation has a relevant-evidence href that references a raw-tool-output back-matter resource.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-relevant-evidence-diagnostic">
The observation, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, has a relevant-evidence href that does not reference any raw-tool-output back-matter resource @uuid
            value.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M24"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:observation[oscal:origin/oscal:actor/@type = 'tool']/oscal:subject"
                 priority="1000"
                 mode="M24">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:observation[oscal:origin/oscal:actor/@type = 'tool']/oscal:subject"/>
      <xsl:variable name="local-definition-subjects"
                    select="../../oscal:local-definitions/oscal:component/@uuid | ../../oscal:local-definitions/oscal:inventory-item/@uuid"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@subject-uuid[. = $local-definition-subjects]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@subject-uuid[. = $local-definition-subjects]">
               <xsl:attribute name="id">observation-subject-is-locally-defined</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each subject of an automated tool must correspond to one of the locally defined
                components or inventory-items.</svrl:text>
               <svrl:diagnostic-reference diagnostic="observation-subject-is-locally-defined-diagnostic">
The subject, <xsl:text/>
                  <xsl:value-of select="@subject-uuid"/>
                  <xsl:text/>, does not correspond to one of the locally defined components or inventory-items.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M24"/>
   </xsl:template>
   <!--PATTERN sar-age-checks-->
   <!--RULE -->
   <xsl:template match="oscal:result" priority="1000" mode="M25">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:result"/>
      <xsl:variable name="start-uuid"
                    select="//oscal:result[xs:dateTime(oscal:start) eq max(//oscal:result/oscal:start ! xs:dateTime(.))]/@uuid"/>
      <xsl:variable name="end-uuid"
                    select="//oscal:result[xs:dateTime(oscal:end) eq max(//oscal:result/oscal:end ! xs:dateTime(.))]/@uuid"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="exists(oscal:end)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists(oscal:end)">
               <xsl:attribute name="id">assessment-has-ended</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>All assessments should be completed.</svrl:text>
               <svrl:diagnostic-reference diagnostic="assessment-has-ended-diagnostic">
This assessment has not ended.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (exists(oscal:start) and exists(oscal:end)) then                         xs:dateTime(oscal:start) lt xs:dateTime(oscal:end)                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (exists(oscal:start) and exists(oscal:end)) then xs:dateTime(oscal:start) lt xs:dateTime(oscal:end) else true()">
               <xsl:attribute name="id">start-precedes-end</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Assessment start precedes assessment end.</svrl:text>
               <svrl:diagnostic-reference diagnostic="start-precedes-end-diagnostic">
Assessment start date is greater than assessment end date.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="P365D" select="xs:dayTimeDuration('P365D')"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (@uuid eq $end-uuid) then                         xs:dateTime(oscal:end) gt current-dateTime() - $P365D                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (@uuid eq $end-uuid) then xs:dateTime(oscal:end) gt current-dateTime() - $P365D else true()">
               <xsl:attribute name="id">has-contemporary-assessment</xsl:attribute>
               <xsl:attribute name="see">https://github.com/18F/fedramp-automation/issues/348</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The most recently completed assessment must have been completed within the last 12
                months.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-contemporary-assessment-diagnostic">
The most recently completed assessment is older than 12 months.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="P180D" select="current-dateTime() - xs:dayTimeDuration('P180D')"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (@uuid eq $end-uuid) then                         every $c in descendant::oscal:observation/oscal:collected                             satisfies                             $c castable as xs:dateTime and xs:dateTime($c) gt $P180D                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (@uuid eq $end-uuid) then every $c in descendant::oscal:observation/oscal:collected satisfies $c castable as xs:dateTime and xs:dateTime($c) gt $P180D else true()">
               <xsl:attribute name="id">result-observations-are-recent</xsl:attribute>
               <xsl:attribute name="see">https://github.com/18F/fedramp-automation/issues/348</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every observation within this most recent result is recently collected.</svrl:text>
               <svrl:diagnostic-reference diagnostic="result-observations-are-recent-diagnostic">
This most recent result has observations older than <xsl:text/>
                  <xsl:value-of select="$P180D"/>
                  <xsl:text/> (180 days ago).</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
   </xsl:template>
   <!--PATTERN metadata-->
   <!--RULE -->
   <xsl:template match="oscal:metadata" priority="1000" mode="M26">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:metadata"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:responsible-party[@role-id = 'penetration-test-lead']/oscal:party-uuid) and not(exists(oscal:responsible-party[@role-id = 'penetration-test-lead']/oscal:party-uuid[2]))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:responsible-party[@role-id = 'penetration-test-lead']/oscal:party-uuid) and not(exists(oscal:responsible-party[@role-id = 'penetration-test-lead']/oscal:party-uuid[2]))">
               <xsl:attribute name="id">has-pen-test-lead</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The
                count of party-uuid elements of a responsible-party of role-id 'penetration-test-lead' must be one.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-pen-test-lead-diagnostic">
The count of party-uuid elements of a responsible-party of role-id 'penetration-test-lead' is not
            one.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
   </xsl:template>
</xsl:stylesheet>
