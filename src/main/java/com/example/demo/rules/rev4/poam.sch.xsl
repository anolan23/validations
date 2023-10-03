<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:array="http://www.w3.org/2005/xpath-functions/array"
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
                              title="FedRAMP Plan of Action and Milestones Validations"
                              schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="http://csrc.nist.gov/ns/oscal/1.0" prefix="oscal"/>
         <svrl:ns-prefix-in-attribute-values uri="https://fedramp.gov/ns/oscal" prefix="fedramp"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2005/xpath-functions/array" prefix="array"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2005/xpath-functions/map" prefix="map"/>
         <svrl:ns-prefix-in-attribute-values uri="http://us.gov/testing/unit-testing" prefix="unit"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">import-ssp</xsl:attribute>
            <xsl:attribute name="name">import-ssp</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M15"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">basics</xsl:attribute>
            <xsl:attribute name="name">basics</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M16"/>
      </svrl:schematron-output>
   </xsl:template>
   <!--SCHEMATRON PATTERNS-->
   <doc:xspec xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
              xmlns:feddoc="http://us.gov/documentation/federal-documentation"
              xmlns:sch="http://purl.oclc.org/dsdl/schematron"
              href="../../test/rules/rev4/poam.xspec"/>
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">FedRAMP Plan of Action and Milestones Validations</svrl:text>
   <xsl:param name="ssp-import-url"
              select="             if (starts-with(/oscal:plan-of-action-and-milestones/oscal:import-ssp/@href, '#'))             then                 resolve-uri(/oscal:plan-of-action-and-milestones/oscal:back-matter/oscal:resource[substring-after(/oscal:plan-of-action-and-milestones/oscal:import-ssp/@href, '#') = @uuid]/oscal:rlink[1]/@href, base-uri())             else                 resolve-uri(/oscal:plan-of-action-and-milestones/oscal:import-ssp/@href, base-uri())"/>
   <xsl:param name="ssp-available" select="doc-available($ssp-import-url)"/>
   <xsl:param name="ssp-doc"
              select="             if ($ssp-available)             then                 doc($ssp-import-url)             else                 ()"/>
   <xsl:param name="risk-UUIDs" select="//oscal:risk/@uuid"/>
   <xsl:param name="planned-risk-UUIDs"
              select="//oscal:risk[oscal:response[@lifecycle eq 'planned']]/@uuid"/>
   <xsl:param name="observation-UUIDs" select="//oscal:observation/@uuid"/>
   <xsl:param name="associated-risk-UUIDs"
              select="//oscal:poam-item/oscal:associated-risk/@risk-uuid"/>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="/" priority="1000" mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/"/>
      <!--REPORT information-->
      <xsl:if test="false() (: until global debug variable :)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="false() (: until global debug variable :)">
            <xsl:attribute name="role">information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>This document has a "<xsl:text/>
               <xsl:value-of select="namespace-uri(/*)"/>
               <xsl:text/>" namespace.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="namespace-uri(/*) eq 'http://csrc.nist.gov/ns/oscal/1.0'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="namespace-uri(/*) eq 'http://csrc.nist.gov/ns/oscal/1.0'">
               <xsl:attribute name="id">document-is-OSCAL-document</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This document is an OSCAL 1.0 document.</svrl:text>
               <svrl:diagnostic-reference diagnostic="document-is-OSCAL-document-diagnostic">
This document is NOT an OSCAL 1.0 document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT information-->
      <xsl:if test="false() (: until global debug variable :)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="false() (: until global debug variable :)">
            <xsl:attribute name="role">information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>This document is a <xsl:text/>
               <xsl:value-of select="local-name(/*)"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="*:plan-of-action-and-milestones"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="*:plan-of-action-and-milestones">
               <xsl:attribute name="id">document-is-plan-of-action-and-milestones</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This document is a plan-of-action-and-milestones.</svrl:text>
               <svrl:diagnostic-reference diagnostic="document-is-plan-of-action-and-milestones-diagnostic">
This document is NOT a plan-of-action-and-milestones.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>
   <!--PATTERN import-ssp-->
   <!--RULE -->
   <xsl:template match="oscal:plan-of-action-and-milestones"
                 priority="1006"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:plan-of-action-and-milestones"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:import-ssp"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:import-ssp">
               <xsl:attribute name="id">has-import-ssp</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL POA&amp;M must have an import-ssp element.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-import-ssp-diagnostic">
This OSCAL POA&amp;M lacks an import-ssp element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:import-ssp" priority="1005" mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:import-ssp"/>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="exists(@href)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists(@href)">
               <xsl:attribute name="id">has-import-ssp-href</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL POA&amp;M import-ssp element must have an href attribute.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-import-ssp-href-diagnostic">
This OSCAL POA&amp;M import-ssp element lacks an href attribute.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (: this is a relative reference :) (matches(@href, '^#'))                     then                         (: the reference must exist within the document :)                         exists(//oscal:resource[@uuid eq substring-after(current()/@href, '#')])                     else                         (: the assertion succeeds :)                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (: this is a relative reference :) (matches(@href, '^#')) then (: the reference must exist within the document :) exists(//oscal:resource[@uuid eq substring-after(current()/@href, '#')]) else (: the assertion succeeds :) true()">
               <xsl:attribute name="id">has-import-ssp-internal-href</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL POA&amp;M import-ssp element href attribute which is document-relative must identify a target
                within the document. <xsl:text/>
                  <xsl:value-of select="@href"/>
                  <xsl:text/>.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-import-ssp-internal-href-diagnostic">
This OSCAL POA&amp;M import-ssp element href attribute which is document-relative does not
            identify a target within the document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="$ssp-available = true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$ssp-available = true()">
               <xsl:attribute name="id">import-ssp-has-available-document</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The import-ssp element href attribute references an available document.</svrl:text>
               <svrl:diagnostic-reference diagnostic="import-ssp-has-available-document-diagnostic">
The import-ssp element has an href attribute that does not reference an available
            document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="$ssp-doc/oscal:system-security-plan"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$ssp-doc/oscal:system-security-plan">
               <xsl:attribute name="id">import-ssp-resolves-to-ssp</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The import-ssp element href attribute references an available OSCAL system security plan
                document.</svrl:text>
               <svrl:diagnostic-reference diagnostic="import-ssp-resolves-to-ssp-diagnostic">
The import-ssp element has an href attribute that does not reference an OSCAL system security plan
            document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:back-matter" priority="1004" mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:back-matter"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (matches(//oscal:import-ssp/@href, '^#'))                     then                         (: there must be a system-security-plan resource :)                         exists(oscal:resource[oscal:prop[@name eq 'type' and @value eq 'system-security-plan']])                     else                         (: the assertion succeeds :)                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (matches(//oscal:import-ssp/@href, '^#')) then (: there must be a system-security-plan resource :) exists(oscal:resource[oscal:prop[@name eq 'type' and @value eq 'system-security-plan']]) else (: the assertion succeeds :) true()">
               <xsl:attribute name="id">has-system-security-plan-resource</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL POA&amp;M which does not directly import the SSP must declare the SSP as a back-matter
                resource.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-system-security-plan-resource-diagnostic">
This OSCAL POA&amp;M which does not directly import the SSP does not declare the SSP as
            a back-matter resource.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:resource[oscal:prop[@name = 'type' and @value eq 'system-security-plan']]"
                 priority="1003"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:resource[oscal:prop[@name = 'type' and @value eq 'system-security-plan']]"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:rlink) and not(exists(oscal:rlink[2]))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:rlink) and not(exists(oscal:rlink[2]))">
               <xsl:attribute name="id">has-ssp-rlink</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL POA&amp;M with a SSP resource declaration must have one and only
                one rlink element.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-ssp-rlink-diagnostic">
This OSCAL POA&amp;M with a SSP resource declaration does not have one and only one rlink
            element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:resource[oscal:prop[@name = 'type' and @value eq 'no-oscal-ssp']]"
                 priority="1002"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:resource[oscal:prop[@name = 'type' and @value eq 'no-oscal-ssp']]"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="                     (: always warn :)                     false()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(: always warn :) false()">
               <xsl:attribute name="id">has-non-OSCAL-system-security-plan-resource</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL POA&amp;M which lacks an OSCAL SSP must declare a no-oscal-ssp resource.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-non-OSCAL-system-security-plan-resource-diagnostic">
This OSCAL POA&amp;M has a non-OSCAL SSP.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:resource[oscal:prop[@name = 'type' and @value eq 'system-security-plan']]/oscal:rlink"
                 priority="1001"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:resource[oscal:prop[@name = 'type' and @value eq 'system-security-plan']]/oscal:rlink"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@media-type = ('text/xml', 'application/json')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@media-type = ('text/xml', 'application/json')">
               <xsl:attribute name="id">has-acceptable-system-security-plan-rlink-media-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL POA&amp;M SSP rlink must have a 'text/xml' or 'application/json'
                media-type.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-acceptable-system-security-plan-rlink-media-type-diagnostic">
This OSCAL POA&amp;M SSP rlink does not have a 'text/xml' or
            'application/json' media-type.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:resource[oscal:prop[@name = 'type' and @value eq 'system-security-plan']]/oscal:base64"
                 priority="1000"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:resource[oscal:prop[@name = 'type' and @value eq 'system-security-plan']]/oscal:base64"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="false()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="false()">
               <xsl:attribute name="id">has-no-base64</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL POA&amp;M must not use a base64 element in a system-security-plan resource.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-no-base64-diagnostic">
This OSCAL POA&amp;M has a base64 element in a system-security-plan resource.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <!--PATTERN basics-->
   <!--RULE -->
   <xsl:template match="oscal:poam-item" priority="1009" mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:poam-item"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:associated-risk)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:associated-risk)">
               <xsl:attribute name="id">poam-item-has-associated-risk</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>poam-item has associated-risk.</svrl:text>
               <svrl:diagnostic-reference diagnostic="poam-item-has-associated-risk-diagnostic">
This poam-item lacks associated-risk.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="not(oscal:associated-risk[2])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(oscal:associated-risk[2])">
               <xsl:attribute name="id">poam-item-has-one-associated-risk</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>poam-item has one and only one associated-risk.</svrl:text>
               <svrl:diagnostic-reference diagnostic="poam-item-has-one-associated-risk-diagnostic">
This poam-item has more than one associated-risk.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:related-observation)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:related-observation)">
               <xsl:attribute name="id">poam-item-has-related-observation</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>poam-item has related-observation.</svrl:text>
               <svrl:diagnostic-reference diagnostic="poam-item-has-related-observation-diagnostic">
This poam-item lacks related-observation.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT information-->
      <xsl:if test="false() (: until global debug variable :)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="false() (: until global debug variable :)">
            <xsl:attribute name="role">information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>POA&amp;M derived completion date is <xsl:text/>
               <xsl:value-of select="max(//oscal:risk[@uuid = current()/oscal:associated-risk/@risk-uuid]/descendant::oscal:within-date-range/@end ! xs:dateTime(.))"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:poam-item/oscal:associated-risk"
                 priority="1008"
                 mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:poam-item/oscal:associated-risk"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@risk-uuid[. = $risk-UUIDs]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@risk-uuid[. = $risk-UUIDs]">
               <xsl:attribute name="id">associated-risk-has-target</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>poam-item <xsl:text/>
                  <xsl:value-of select="@risk-uuid"/>
                  <xsl:text/> associated-risk references a risk in this document.</svrl:text>
               <svrl:diagnostic-reference diagnostic="associated-risk-has-target-diagnostic">
This associated-risk does not reference a risk in this document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@risk-uuid[. = $planned-risk-UUIDs]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@risk-uuid[. = $planned-risk-UUIDs]">
               <xsl:attribute name="id">associated-risk-has-planned-response</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>poam-item <xsl:text/>
                  <xsl:value-of select="@risk-uuid"/>
                  <xsl:text/> associated-risk references a risk with a planned response.</svrl:text>
               <svrl:diagnostic-reference diagnostic="associated-risk-has-planned-response-diagnostic">
This associated-risk references a risk without a planned response.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:poam-item/oscal:related-observation"
                 priority="1007"
                 mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:poam-item/oscal:related-observation"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@observation-uuid[. = $observation-UUIDs]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@observation-uuid[. = $observation-UUIDs]">
               <xsl:attribute name="id">related-observation-has-observation</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>related-observation references an observation in this document.</svrl:text>
               <svrl:diagnostic-reference diagnostic="related-observation-has-observation-diagnostic">
This related-observation does not reference an observation in this
            document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:risk[@uuid[. = $associated-risk-UUIDs]]"
                 priority="1006"
                 mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:risk[@uuid[. = $associated-risk-UUIDs]]">
         <xsl:attribute name="see">https://github.com/18F/fedramp-automation/issues/353</xsl:attribute>
      </svrl:fired-rule>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:deadline)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists(oscal:deadline)">
               <xsl:attribute name="id">risk-has-deadline</xsl:attribute>
               <xsl:attribute name="see">https://github.com/18F/fedramp-automation/issues/353</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A risk must have a deadline.</svrl:text>
               <svrl:diagnostic-reference diagnostic="risk-has-deadline-diagnostic">
This risk lacks a deadline.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:response[@lifecycle eq 'recommendation']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:response[@lifecycle eq 'recommendation']">
               <xsl:attribute name="id">risk-has-recommendation</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A risk must have a recommendation response.</svrl:text>
               <svrl:diagnostic-reference diagnostic="risk-has-recommendation-diagnostic">
This risk has no recommendation response.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:response[@lifecycle eq 'planned']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:response[@lifecycle eq 'planned']">
               <xsl:attribute name="id">risk-has-planned-response</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A risk must have a planned response.</svrl:text>
               <svrl:diagnostic-reference diagnostic="risk-has-planned-response-diagnostic">
This risk has no planned response.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:response/oscal:task[@type eq 'milestone'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:response/oscal:task[@type eq 'milestone'])">
               <xsl:attribute name="id">risk-has-milestones</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A risk associated with a poam-item must have one or more milestones
                (response tasks).</svrl:text>
               <svrl:diagnostic-reference diagnostic="risk-has-milestones-diagnostic">
This risk associated with a poam-item lacks one or more milestones (response tasks).</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="threshold"
                    select="                     map {                         'low': xs:dayTimeDuration('P180D'),                         'moderate': xs:dayTimeDuration('P90D'),                         'high': xs:dayTimeDuration('P30D')                     }"/>
      <xsl:variable name="detected"
                    select="//oscal:observation[@uuid = current()/oscal:related-observation/@observation-uuid]/oscal:collected"/>
      <xsl:variable name="impact"
                    select="(oscal:characterization/oscal:facet[@name eq 'impact'][last()]/@value)[last()]"/>
      <!--REPORT information-->
      <xsl:if test="false() (: until global debug variable :)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="false() (: until global debug variable :)">
            <xsl:attribute name="role">information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>risk <xsl:text/>
               <xsl:value-of select="@uuid"/>
               <xsl:text/> has <xsl:text/>
               <xsl:value-of select="$impact"/>
               <xsl:text/> impact.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:characterization/oscal:facet[@name eq 'impact'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:characterization/oscal:facet[@name eq 'impact'])">
               <xsl:attribute name="id">has-risk-impact-characterization-facet</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Risk has characterization impact facet.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-risk-impact-characterization-facet-diagnostic">
This risk has no impact characterization.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="no-later-than"
                    select="                     if (exists($impact)) then                         xs:dateTime($detected) + map:get($threshold, $impact)                     else (: this date will not be used :)                         current-dateTime()"/>
      <xsl:variable name="scheduled-completion" select="xs:dateTime(oscal:deadline)"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists($impact) and $scheduled-completion lt $no-later-than"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists($impact) and $scheduled-completion lt $no-later-than">
               <xsl:attribute name="id">has-timely-completion-date</xsl:attribute>
               <xsl:attribute name="see">https://github.com/18F/fedramp-automation/issues/353</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Scheduled completion date is within detection response
                threshold.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-timely-completion-date-diagnostic">
Scheduled completion date (<xsl:text/>
                  <xsl:value-of select="$scheduled-completion"/>
                  <xsl:text/>) is after detection response threshold (<xsl:text/>
                  <xsl:value-of select="$no-later-than"/>
                  <xsl:text/>).</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:task[@type eq 'milestone']" priority="1005" mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:task[@type eq 'milestone']">
         <xsl:attribute name="see">https://github.com/GSA/fedramp-automation-guides/issues/18</xsl:attribute>
      </svrl:fired-rule>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:description)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:description)">
               <xsl:attribute name="id">milestone-has-description</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A milestone task has a description.</svrl:text>
               <svrl:diagnostic-reference diagnostic="milestone-has-description-diagnostic">
This milestone task lacks a description.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:timing)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists(oscal:timing)">
               <xsl:attribute name="id">milestone-has-timing</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A milestone task has a timing element.</svrl:text>
               <svrl:diagnostic-reference diagnostic="milestone-has-timing-diagnostic">
A milestone task lacks a timing element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:timing/oscal:within-date-range) (: accept on-date as well :) or exists(oscal:timing/oscal:on-date)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:timing/oscal:within-date-range) (: accept on-date as well :) or exists(oscal:timing/oscal:on-date)">
               <xsl:attribute name="id">milestone-has-timing-within-date-range</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A milestone
                task has a timing within-date-range element.</svrl:text>
               <svrl:diagnostic-reference diagnostic="milestone-has-timing-within-date-range-diagnostic">
This milestone task lacks a timing within-date-range element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:deadline" priority="1004" mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:deadline"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="current() castable as xs:dateTime"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="current() castable as xs:dateTime">
               <xsl:attribute name="id">deadline-is-valid-datetime</xsl:attribute>
               <xsl:attribute name="see">https://github.com/18F/fedramp-automation/issues/353</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Risk deadline is valid xs:dateTime().</svrl:text>
               <svrl:diagnostic-reference diagnostic="deadline-is-valid-datetime-diagnostic">
This risk deadline is not a valid xs:dateTime().</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:on-date" priority="1003" mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:on-date"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@date castable as xs:dateTime"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@date castable as xs:dateTime">
               <xsl:attribute name="id">on-date-date-is-valid-datetime</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>on-date element date is valid xs:dateTime.</svrl:text>
               <svrl:diagnostic-reference diagnostic="on-date-date-is-valid-datetime-diagnostic">
on-date element date is not a valid xs:dateTime.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:within-date-range" priority="1002" mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:within-date-range"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@start castable as xs:dateTime"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@start castable as xs:dateTime">
               <xsl:attribute name="id">within-date-range-start-is-valid-datetime</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>within-date-range start is valid xs:dateTime.</svrl:text>
               <svrl:diagnostic-reference diagnostic="within-date-range-start-is-valid-datetime-diagnostic">
within-date-range start is not a valid xs:dateTime.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@end castable as xs:dateTime"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@end castable as xs:dateTime">
               <xsl:attribute name="id">within-date-range-end-is-valid-datetime</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>within-date-range end is valid xs:dateTime.</svrl:text>
               <svrl:diagnostic-reference diagnostic="within-date-range-end-is-valid-datetime-diagnostic">
within-date-range end is not a valid xs:dateTime.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="xs:dateTime(@start) le xs:dateTime(@end)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="xs:dateTime(@start) le xs:dateTime(@end)">
               <xsl:attribute name="id">within-date-range-start-precedes-end</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>within-date-range start precedes end.</svrl:text>
               <svrl:diagnostic-reference diagnostic="within-date-range-start-precedes-end-diagnostic">
within-date-range start does not precede end.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:timing/oscal:at-frequency" priority="1001" mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:timing/oscal:at-frequency"/>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:risk-log/oscal:entry" priority="1000" mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:risk-log/oscal:entry"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:title)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists(oscal:title)">
               <xsl:attribute name="id">risk-log-entry-has-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A risk-log entry must have a title.</svrl:text>
               <svrl:diagnostic-reference diagnostic="risk-log-entry-has-title-diagnostic">
This risk-log entry lacks a title.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:start)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists(oscal:start)">
               <xsl:attribute name="id">risk-log-entry-has-start</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A risk-log entry must have a start.</svrl:text>
               <svrl:diagnostic-reference diagnostic="risk-log-entry-has-start-diagnostic">
This risk-log entry lacks a start.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="@*|node()" priority="-2" mode="M16">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
   </xsl:template>
</xsl:stylesheet>
