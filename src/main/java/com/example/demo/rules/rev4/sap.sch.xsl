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
                              title="FedRAMP Security Assessment Plan Validations"
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
            <xsl:attribute name="id">import-ssp</xsl:attribute>
            <xsl:attribute name="name">import-ssp</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">control-selection</xsl:attribute>
            <xsl:attribute name="name">control-selection</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">control-objective-selection</xsl:attribute>
            <xsl:attribute name="name">control-objective-selection</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M13"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">assessment-subject</xsl:attribute>
            <xsl:attribute name="name">assessment-subject</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">pentest</xsl:attribute>
            <xsl:attribute name="name">pentest</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M15"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">signed-sap</xsl:attribute>
            <xsl:attribute name="name">signed-sap</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M16"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">metadata</xsl:attribute>
            <xsl:attribute name="name">metadata</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M17"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">assessment-assets</xsl:attribute>
            <xsl:attribute name="name">assessment-assets</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M18"/>
      </svrl:schematron-output>
   </xsl:template>
   <!--SCHEMATRON PATTERNS-->
   <doc:xspec xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
              xmlns:feddoc="http://us.gov/documentation/federal-documentation"
              xmlns:sch="http://purl.oclc.org/dsdl/schematron"
              href="../../test/rules/rev4/sap.xspec"/>
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">FedRAMP Security Assessment Plan Validations</svrl:text>
   <xsl:param name="ssp-import-url"
              select="             if (starts-with(/oscal:assessment-plan/oscal:import-ssp/@href, '#'))             then                 resolve-uri(/oscal:assessment-plan/oscal:back-matter/oscal:resource[substring-after(/oscal:assessment-plan/oscal:import-ssp/@href, '#') = @uuid]/oscal:rlink[1]/@href, base-uri())             else                 resolve-uri(/oscal:assessment-plan/oscal:import-ssp/@href, base-uri())"/>
   <xsl:param name="ssp-available"
              select="             if (: this is not a relative reference :) (not(starts-with($ssp-import-url, '#')))             then                 (: the referenced document must be available :)                 doc-available($ssp-import-url)             else                 true()"/>
   <xsl:param name="ssp-doc"
              select="             if ($ssp-available)             then                 doc($ssp-import-url)             else                 ()"/>
   <xsl:param name="no-oscal-ssp"
              select="boolean(/oscal:assessment-plan/oscal:back-matter/oscal:resource/oscal:prop[@name = 'type' and @value eq 'no-oscal-ssp'])"/>
   <!--PATTERN import-ssp-->
   <!--RULE -->
   <xsl:template match="oscal:assessment-plan" priority="1007" mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:assessment-plan"/>
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
               <svrl:text>An OSCAL SAP must have an import-ssp element.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-import-ssp-diagnostic">
This OSCAL SAP lacks have an import-ssp element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:assessment-subject[@type = 'user'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:assessment-subject[@type = 'user'])">
               <xsl:attribute name="id">has-user-assessment-subject</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SAP must have an assesment-subject with a type of
                'user'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-user-assessment-subject-diagnostic">
This FedRAMP SAP does not have an assessment-subject with the type of 'user'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="web-apps"
                    select="                     $ssp-doc//oscal:component[oscal:prop[@name = 'type' and @value eq 'web-application']]/@uuid |                     $ssp-doc//oscal:inventory-item[oscal:prop[@name = 'type' and @value eq 'web-application']]/@uuid |                     //oscal:local-definitions/oscal:activity[oscal:prop[@value eq 'web-application']]/@uuid"/>
      <xsl:variable name="sap-web-tasks"
                    select="//oscal:task[oscal:prop[@value = 'web-application']]/oscal:associated-activity/@activity-uuid ! xs:string(.)"/>
      <xsl:variable name="missing-web-tasks" select="$web-apps[not(. = $sap-web-tasks)]"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count($web-apps[not(. = $sap-web-tasks)]) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count($web-apps[not(. = $sap-web-tasks)]) = 0">
               <xsl:attribute name="id">has-web-applications</xsl:attribute>
               <xsl:attribute name="see">https://github.com/GSA/fedramp-automation-guides/issues/31</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>For every web interface to be tested there must be a matching task entry.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-web-applications-diagnostic">
These web testing activities, <xsl:text/>
                  <xsl:value-of select="$missing-web-tasks"/>
                  <xsl:text/>, do not have matching tasks in the SSP or SAP.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:assessment-subject[@type = 'location'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:assessment-subject[@type = 'location'])">
               <xsl:attribute name="id">has-location-assessment-subject</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SAP must have a assessment-subject with a type of
                'location'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-location-assessment-subject-diagnostic">
This FedRAMP SAP does not have an assessment-subject with the type of
            'location'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:import-ssp" priority="1006" mode="M11">
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
               <svrl:text>An OSCAL SAP import-ssp element must have an href attribute.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-import-ssp-href-diagnostic">
This OSCAL SAP import-ssp element lacks an href attribute.</svrl:diagnostic-reference>
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
               <svrl:text>An OSCAL SAP import-ssp element href attribute which is document-relative must identify a target
                within the document. <xsl:text/>
                  <xsl:value-of select="@href"/>
                  <xsl:text/>.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-import-ssp-internal-href-diagnostic">
This OSCAL SAP import-ssp element href attribute which is document-relative does not identify
            a target within the document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="import-ssp-url" select="resolve-uri(@href, base-uri())"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (: this is not a relative reference :) (not(starts-with(@href, '#')))                     then                         (: the referenced document must be available :)                         doc-available($import-ssp-url)                     else                         (: the assertion succeeds :)                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (: this is not a relative reference :) (not(starts-with(@href, '#'))) then (: the referenced document must be available :) doc-available($import-ssp-url) else (: the assertion succeeds :) true()">
               <xsl:attribute name="id">has-import-ssp-external-href</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SAP import-ssp element href attribute which is an external reference must identify an available
                target.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-import-ssp-external-href-diagnostic">
This OSCAL SAP import-ssp element href attribute which is an external reference does not
            identify an available target.</svrl:diagnostic-reference>
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
The import-ssp element has an href attribute that does not reference an OSCAL system security
            plan document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:back-matter" priority="1005" mode="M11">
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
               <svrl:text>An OSCAL SAP which does not directly import the SSP must declare the SSP as a back-matter
                resource.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-system-security-plan-resource-diagnostic">
This OSCAL SAP which does not directly import the SSP does not declare the SSP as a
            back-matter resource.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:resource[oscal:prop[@name = 'type' and @value eq 'system-security-plan']]"
                 priority="1004"
                 mode="M11">
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
               <svrl:text>A FedRAMP SAP with a SSP resource declaration must have one and only one
                rlink element.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-ssp-rlink-diagnostic">
This OSCAL SAP with a SSP resource declaration does not have one and only one rlink
            element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:resource[oscal:prop[@name = 'type' and @value eq 'no-oscal-ssp']]"
                 priority="1003"
                 mode="M11">
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
               <svrl:text>A FedRAMP SAP which lacks an OSCAL SSP must declare a no-oscal-ssp resource.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-non-OSCAL-system-security-plan-resource-diagnostic">
This OSCAL SAP has a non-OSCAL SSP.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:resource[oscal:prop[@name = 'type' and @value eq 'system-security-plan']]/oscal:rlink"
                 priority="1002"
                 mode="M11">
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
               <svrl:text>An OSCAL SAP SSP rlink must have a 'text/xml' or 'application/json'
                media-type.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-acceptable-system-security-plan-rlink-media-type-diagnostic">
This OSCAL SAP SSP rlink does not have a 'text/xml' or
            'application/json' media-type.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:resource[oscal:prop[@name = 'type' and @value eq 'system-security-plan']]/oscal:base64"
                 priority="1001"
                 mode="M11">
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
               <svrl:text>A FedRAMP SAP must not use a base64 element in a system-security-plan resource.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-no-base64-diagnostic">
This OSCAL SAP has a base64 element in a system-security-plan resource.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:task[oscal:prop[@value = 'web-application']]"
                 priority="1000"
                 mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:task[oscal:prop[@value = 'web-application']]"/>
      <xsl:variable name="ssp-web-apps"
                    select="                     $ssp-doc/oscal:component[oscal:prop[@name = 'type' and @value eq 'web-application']]/@uuid ! xs:string(.) |                     $ssp-doc/oscal:inventory-item[oscal:prop[@name = 'type' and @value eq 'web-application']]/@uuid ! xs:string(.)"/>
      <xsl:variable name="sap-web-apps"
                    select="/oscal:assessment-plan//oscal:local-definitions/oscal:activity[oscal:prop[@value eq 'web-application']]/@uuid ! xs:string(.)"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:associated-activity/@activity-uuid = $ssp-web-apps or oscal:associated-activity/@activity-uuid = $sap-web-apps"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:associated-activity/@activity-uuid = $ssp-web-apps or oscal:associated-activity/@activity-uuid = $sap-web-apps">
               <xsl:attribute name="id">matches-web-app-task</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Web applications targeted by associated activity must exist in either the SAP or SSP.</svrl:text>
               <svrl:diagnostic-reference diagnostic="matches-web-app-task-diagnostic">
This associated-activity, <xsl:text/>
                  <xsl:value-of select="oscal:associated-activity/@activity-uuid"/>
                  <xsl:text/>, references a non-existent (neither in the SSP nor SAP) web
            application.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:prop[@name = 'login-url'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:prop[@name = 'login-url'])">
               <xsl:attribute name="id">has-login-url-task</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>FedRAMP SAP Web Application Tasks must have login-url information.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-login-url-task-diagnostic">
This task, <xsl:text/>
                  <xsl:value-of select="../@uuid"/>
                  <xsl:text/>, does not contain login-url information.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:prop[@name = 'login-id'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:prop[@name = 'login-id'])">
               <xsl:attribute name="id">has-login-id-task</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>FedRAMP SAP Web Application Tasks must have login-id information.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-login-id-task-diagnostic">
This task, <xsl:text/>
                  <xsl:value-of select="../@uuid"/>
                  <xsl:text/>, does not contain login-id information.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>
   <!--PATTERN control-selection-->
   <xsl:variable name="ssp-control-ids"
                 select="$ssp-doc//oscal:implemented-requirement/@control-id ! xs:string(.)"/>
   <!--RULE -->
   <xsl:template match="oscal:control-selection" priority="1002" mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:control-selection"/>
      <xsl:variable name="exclude-control-ids"
                    select="oscal:exclude-control/@control-id ! xs:string(.)"/>
      <xsl:variable name="include-control-ids"
                    select="oscal:include-control/@control-id ! xs:string(.)"/>
      <xsl:variable name="matching-control-ids"
                    select="$exclude-control-ids[. = $include-control-ids]"/>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="(oscal:include-all and not(oscal:include-control)) or (oscal:include-control and not(oscal:include-all))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(oscal:include-all and not(oscal:include-control)) or (oscal:include-control and not(oscal:include-all))">
               <xsl:attribute name="id">include-all-or-include-control</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SAP control
                selection elements must have either an include-all element or include-control element(s) children.</svrl:text>
               <svrl:diagnostic-reference diagnostic="include-all-or-include-control-diagnostic">
A control-selection element may not have both include-all and include-control element
            children.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count($matching-control-ids) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count($matching-control-ids) = 0">
               <xsl:attribute name="id">duplicate-exclude-control-and-include-control-values</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The exclude-control and include-control sibling element @control-id values must be
                different.</svrl:text>
               <svrl:diagnostic-reference diagnostic="duplicate-exclude-control-and-include-control-values-diagnostic">
The @control-id values <xsl:text/>
                  <xsl:value-of select="$matching-control-ids"/>
                  <xsl:text/> are not allowed to occur more than once in this control-selection element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count($include-control-ids) eq count(distinct-values($include-control-ids))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count($include-control-ids) eq count(distinct-values($include-control-ids))">
               <xsl:attribute name="id">duplicate-include-control-values</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The include-control/@control-id values must not be
                duplicated.</svrl:text>
               <svrl:diagnostic-reference diagnostic="duplicate-include-control-values-diagnostic">
Duplicate values are not allowed to occur in include-control/@control-id
            elements.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count($exclude-control-ids) eq count(distinct-values($exclude-control-ids))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count($exclude-control-ids) eq count(distinct-values($exclude-control-ids))">
               <xsl:attribute name="id">duplicate-exclude-control-values</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The exclude-control/@control-id values must not be
                duplicated.</svrl:text>
               <svrl:diagnostic-reference diagnostic="duplicate-exclude-control-values-diagnostic">
Duplicate values are not allowed to occur in exclude-control/@control-id
            elements.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M12"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:include-control" priority="1001" mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:include-control"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@control-id[. = $ssp-control-ids]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@control-id[. = $ssp-control-ids]">
               <xsl:attribute name="id">control-inclusion-values-exist-in-ssp</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>SAP included controls are identified in the associated SSP. </svrl:text>
               <svrl:diagnostic-reference diagnostic="control-inclusion-values-exist-in-ssp-diagnostic">
The included control <xsl:text/>
                  <xsl:value-of select="@control-id"/>
                  <xsl:text/> does not exist in the associated SSP.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M12"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:exclude-control" priority="1000" mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:exclude-control"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@control-id[. = $ssp-control-ids]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@control-id[. = $ssp-control-ids]">
               <xsl:attribute name="id">control-exclusion-values-exist-in-ssp</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>SAP excluded controls are identified in the associated SSP. </svrl:text>
               <svrl:diagnostic-reference diagnostic="control-exclusion-values-exist-in-ssp-diagnostic">
The excluded control <xsl:text/>
                  <xsl:value-of select="@control-id"/>
                  <xsl:text/> does not exist in the associated SSP.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M12"/>
   </xsl:template>
   <!--PATTERN control-objective-selection-->
   <!--RULE -->
   <xsl:template match="oscal:control-objective-selection"
                 priority="1009"
                 mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:control-objective-selection"/>
      <xsl:variable name="exclude-control-objective-ids"
                    select="oscal:exclude-objective/@objective-id ! xs:string(.)"/>
      <xsl:variable name="include-control-objective-ids"
                    select="oscal:include-objective/@objective-id ! xs:string(.)"/>
      <xsl:variable name="matching-control-objective-ids"
                    select="$exclude-control-objective-ids[. = $include-control-objective-ids]"/>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="(oscal:include-all and not(oscal:include-objective)) or (oscal:include-objective and not(oscal:include-all))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(oscal:include-all and not(oscal:include-objective)) or (oscal:include-objective and not(oscal:include-all))">
               <xsl:attribute name="id">include-all-or-include-objective</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SAP
                control objective selection element must have either an include-all element or include-control element(s) children.</svrl:text>
               <svrl:diagnostic-reference diagnostic="include-all-or-include-objective-diagnostic">
A control-objective-selection element may not have both include-all and include-objective
            element children.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count($matching-control-objective-ids) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count($matching-control-objective-ids) = 0">
               <xsl:attribute name="id">duplicate-exclude-objective-and-include-objective-values</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The exclude-control and include-control sibling element @control-id values must be
                different.</svrl:text>
               <svrl:diagnostic-reference diagnostic="duplicate-exclude-objective-and-include-objective-values-diagnostic">
The @control-id values <xsl:text/>
                  <xsl:value-of select="$matching-control-objective-ids"/>
                  <xsl:text/> are not allowed to occur more than once in this control-objective-selection
            element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:control-objective-selection/oscal:include-objective"
                 priority="1008"
                 mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:control-objective-selection/oscal:include-objective"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (following-sibling::oscal:include-objective)                     then                         if (@objective-id = following-sibling::oscal:include-objective/@objective-id)                         then                             false()                         else                             true()                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (following-sibling::oscal:include-objective) then if (@objective-id = following-sibling::oscal:include-objective/@objective-id) then false() else true() else true()">
               <xsl:attribute name="id">duplicate-include-objective-values</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The include-objective/@objective-id values are unique.</svrl:text>
               <svrl:diagnostic-reference diagnostic="duplicate-include-objective-values-diagnostic">
Duplicate values are not allowed to occur in include-objective/@objective-id, <xsl:text/>
                  <xsl:value-of select="@objective-id"/>
                  <xsl:text/>, elements.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:control-objective-selection/oscal:exclude-objective"
                 priority="1007"
                 mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:control-objective-selection/oscal:exclude-objective"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (following-sibling::oscal:exclude-objective)                     then                         if (@objective-id = following-sibling::oscal:exclude-objective/@objective-id)                         then                             false()                         else                             true()                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (following-sibling::oscal:exclude-objective) then if (@objective-id = following-sibling::oscal:exclude-objective/@objective-id) then false() else true() else true()">
               <xsl:attribute name="id">duplicate-exclude-objective-values</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The exclude-objective/@objective-id values are unique.</svrl:text>
               <svrl:diagnostic-reference diagnostic="duplicate-exclude-objective-values-diagnostic">
Duplicate values are not allowed to occur in exclude-objective/@objective-id, <xsl:text/>
                  <xsl:value-of select="@objective-id"/>
                  <xsl:text/>, elements.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>
   <xsl:variable name="profile-href"
                 select="resolve-uri($ssp-doc/oscal:system-security-plan/oscal:import-profile/@href, base-uri())"/>
   <xsl:variable name="profile-available"
                 select="                 if (: this is not a relative reference :) (not(starts-with(@href, '#')))                 then                     (: the referenced document must be available :)                     if (doc-available($profile-href))                     then                         exists(doc($profile-href)/oscal:profile)                     else                         false()                 else                     true()"/>
   <xsl:variable name="profile-doc"
                 select="                 if ($profile-available)                 then                     doc($profile-href)                 else                     ()"/>
   <xsl:variable name="profile-objective-ids" select="$profile-doc//oscal:add/@by-id"/>
   <!--RULE -->
   <xsl:template match="oscal:assessment-plan" priority="1002" mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:assessment-plan"/>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="$profile-available eq true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$profile-available eq true()">
               <xsl:attribute name="id">is-profile-document</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The associated SSP must have an import-profile that references a profile document.</svrl:text>
               <svrl:diagnostic-reference diagnostic="is-profile-document-diagnostic">
The associated SSP document does not have an import-profile that references a profile
            document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:include-objective" priority="1001" mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:include-objective"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@objective-id[. = $profile-objective-ids]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@objective-id[. = $profile-objective-ids]">
               <xsl:attribute name="id">objective-inclusion-values-exist-in-profile</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>SAP included objectives are identified in the associated profile.</svrl:text>
               <svrl:diagnostic-reference diagnostic="objective-inclusion-values-exist-in-profile-diagnostic">
The included objective <xsl:text/>
                  <xsl:value-of select="@objective-id"/>
                  <xsl:text/> does not exist in the associated profile.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:exclude-objective" priority="1000" mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:exclude-objective"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@objective-id[. = $profile-objective-ids]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@objective-id[. = $profile-objective-ids]">
               <xsl:attribute name="id">objective-exclusion-values-exist-in-profile</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>SAP excluded objective are identified in the associated profile.</svrl:text>
               <svrl:diagnostic-reference diagnostic="objective-exclusion-values-exist-in-profile-diagnostic">
The excluded objective <xsl:text/>
                  <xsl:value-of select="@objective-id"/>
                  <xsl:text/> does not exist in the associated profile.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>
   <!--PATTERN assessment-subject-->
   <xsl:variable name="ssp-users"
                 select="$ssp-doc//oscal:system-implementation//oscal:user/@uuid ! xs:string(.)"/>
   <xsl:variable name="sap-users"
                 select="/oscal:assessment-plan/oscal:local-definitions//oscal:user/@uuid ! xs:string(.)"/>
   <xsl:variable name="ssp-user-apps"
                 select="                 $ssp-doc/oscal:component[oscal:prop[@name = 'type' and @value eq 'role-based']]/@uuid ! xs:string(.) |                 $ssp-doc/oscal:inventory-item[oscal:prop[@name = 'type' and @value eq 'role-based']]/@uuid ! xs:string(.)"/>
   <xsl:variable name="sap-user-apps"
                 select="/oscal:assessment-plan//oscal:local-definitions/oscal:activity[oscal:prop[@value eq 'role-based']]/@uuid ! xs:string(.)"/>
   <!--RULE -->
   <xsl:template match="oscal:include-subject[@type = 'component'] | oscal:exclude-subject[@type = 'component']"
                 priority="1004"
                 mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:include-subject[@type = 'component'] | oscal:exclude-subject[@type = 'component']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     @subject-uuid[. = $ssp-doc//oscal:component[@type = 'subnet']/@uuid ! xs:string(.)] or                     @subject-uuid[. = //oscal:local-definitions//oscal:inventory-item/@uuid ! xs:string(.)]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@subject-uuid[. = $ssp-doc//oscal:component[@type = 'subnet']/@uuid ! xs:string(.)] or @subject-uuid[. = //oscal:local-definitions//oscal:inventory-item/@uuid ! xs:string(.)]">
               <xsl:attribute name="id">component-uuid-matches</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Component targeted by include or exclude subject must exist in the SAP or SSP.</svrl:text>
               <svrl:diagnostic-reference diagnostic="component-uuid-matches-diagnostic">
This include or exclude subject, <xsl:text/>
                  <xsl:value-of select="@subject-uuid"/>
                  <xsl:text/>, does not have a matching SSP component or SAP inventory-item.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:assessment-subject[@type = 'location']"
                 priority="1003"
                 mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:assessment-subject[@type = 'location']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(exists(oscal:include-all))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(exists(oscal:include-all))">
               <xsl:attribute name="id">location-not-include-all-element</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The FedRAMP SAP references locations individually.</svrl:text>
               <svrl:diagnostic-reference diagnostic="location-not-include-all-element-diagnostic">
This FedRAMP SAP assessment-subject[@type='location'] cannot have an include-all
            child.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:include-subject[@type = 'location']"
                 priority="1002"
                 mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:include-subject[@type = 'location']"/>
      <xsl:variable name="ssp-locations"
                    select="$ssp-doc/oscal:system-security-plan/oscal:metadata//oscal:location/@uuid ! xs:string(.)"/>
      <xsl:variable name="sap-locations"
                    select="/oscal:assessment-plan/oscal:metadata//oscal:location/@uuid ! xs:string(.)"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@subject-uuid = $ssp-locations or @subject-uuid = $sap-locations"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@subject-uuid = $ssp-locations or @subject-uuid = $sap-locations">
               <xsl:attribute name="id">location-uuid-matches</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Locations targeted by include subject must exist in the SAP or SSP.</svrl:text>
               <svrl:diagnostic-reference diagnostic="location-uuid-matches-diagnostic">
This include-subject, <xsl:text/>
                  <xsl:value-of select="@subject-uuid"/>
                  <xsl:text/>, references a non-existent (neither in the SSP nor SAP) location.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:assessment-subject[@type = 'user']/oscal:include-subject[@type = 'user'] | oscal:assessment-subject[@type = 'user']/oscal:exclude-subject[@type = 'user']"
                 priority="1001"
                 mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:assessment-subject[@type = 'user']/oscal:include-subject[@type = 'user'] | oscal:assessment-subject[@type = 'user']/oscal:exclude-subject[@type = 'user']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@subject-uuid = $ssp-users or @subject-uuid = $sap-users"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@subject-uuid = $ssp-users or @subject-uuid = $sap-users">
               <xsl:attribute name="id">user-uuid-matches</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Users targeted by include-subject or exclude-subject must exist in the SAP or associated SSP.</svrl:text>
               <svrl:diagnostic-reference diagnostic="user-uuid-matches-diagnostic">
This include-subject, <xsl:text/>
                  <xsl:value-of select="@subject-uuid"/>
                  <xsl:text/>, references a non-existent (neither in the SSP nor SAP) user.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:task[oscal:prop[@value = 'role-based']]"
                 priority="1000"
                 mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:task[oscal:prop[@value = 'role-based']]"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:associated-activity/@activity-uuid = $ssp-user-apps or oscal:associated-activity/@activity-uuid = $sap-user-apps"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:associated-activity/@activity-uuid = $ssp-user-apps or oscal:associated-activity/@activity-uuid = $sap-user-apps">
               <xsl:attribute name="id">matches-user-app-task</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>User tasks targeted by associated activity must exist in either the SAP or SSP.</svrl:text>
               <svrl:diagnostic-reference diagnostic="matches-user-app-task-diagnostic">
This associated-activity, <xsl:text/>
                  <xsl:value-of select="oscal:associated-activity/@activity-uuid"/>
                  <xsl:text/>, references a non-existent (neither in the SSP nor SAP) user.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:prop[@name = 'login-id'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:prop[@name = 'login-id'])">
               <xsl:attribute name="id">has-login-id-user-task</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>FedRAMP SAP Role Tasks must have login-id information.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-login-id-user-task-diagnostic">
This task, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, does not contain login-id information.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>
   <!--PATTERN pentest-->
   <!--RULE -->
   <xsl:template match="oscal:assessment-plan" priority="1008" mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:assessment-plan"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:terms-and-conditions"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:terms-and-conditions">
               <xsl:attribute name="id">has-terms-and-conditions</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The SAP contains terms and conditions.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-terms-and-conditions-diagnostic">
The SAP lacks terms and conditions.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:terms-and-conditions" priority="1007" mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:terms-and-conditions"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:part[@name = 'assumptions']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:part[@name = 'assumptions']">
               <xsl:attribute name="id">has-part-named-assumptions</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The SAP terms and conditions must contain a part called assumptions.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-part-named-assumptions-diagnostic">
The SAP lacks a part named 'assumptions'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:part[@name eq 'methodology']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:part[@name eq 'methodology']">
               <xsl:attribute name="id">has-methodology</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The SAP terms and conditions must contain a description of the methodology which will be
                used.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-methodology-diagnostic">
The SAP terms and conditions lacks a description of the methodology which will be used.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:part[@name eq 'disclosures']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:part[@name eq 'disclosures']">
               <xsl:attribute name="id">has-disclosures</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The SAP terms and conditions must contain Rules of Engagement (ROE)
                Disclosures.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-disclosures-diagnostic">
The SAP terms and conditions lacks Rules of Engagement (ROE) Disclosures.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:part[@name = 'included-activities']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:part[@name = 'included-activities']">
               <xsl:attribute name="id">has-part-named-included-activities</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The SAP terms and conditions must contain a part called
                included-activities.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-part-named-included-activities-diagnostic">
The SAP terms and conditions lacks Rules of Engagement (ROE) part of
            included-activities.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:part[@name = 'excluded-activities']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:part[@name = 'excluded-activities']">
               <xsl:attribute name="id">has-part-named-excluded-activities</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The SAP terms and conditions must contain a part called
                excluded-activities.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-part-named-excluded-activities-diagnostic">
The SAP terms and conditions lacks Rules of Engagement (ROE) part of
            excluded-activities.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:part[@name = 'liability-limitations']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:part[@name = 'liability-limitations']">
               <xsl:attribute name="id">has-part-named-liability-limitations</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The SAP terms and conditions must contain a part called
                liability-limitations.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-part-named-liability-limitations-diagnostic">
The SAP terms and conditions lacks a liability and limitations part.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:terms-and-conditions/oscal:part[@name eq 'assumptions']"
                 priority="1006"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:terms-and-conditions/oscal:part[@name eq 'assumptions']"/>
      <xsl:variable name="unsorted-assumptions"
                    select="oscal:part[@name eq 'assumption']/oscal:prop[@name eq 'sort-id']/@value"/>
      <xsl:variable name="sorted_assumptions" select="sort($unsorted-assumptions)"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="deep-equal($unsorted-assumptions, $sorted_assumptions)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="deep-equal($unsorted-assumptions, $sorted_assumptions)">
               <xsl:attribute name="id">assumption-ordered</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The SAP terms and conditions assumptions part must have assumption parts
                that are ordered.</svrl:text>
               <svrl:diagnostic-reference diagnostic="assumption-ordered-diagnostic">
The SAP assumption parts are incorrectly ordered.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:terms-and-conditions/oscal:part[@name eq 'methodology']"
                 priority="1005"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:terms-and-conditions/oscal:part[@name eq 'methodology']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'sampling']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'sampling']">
               <xsl:attribute name="id">has-sampling-method</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The SAP declares a sampling method.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-sampling-method-diagnostic">
The SAP lacks a sampling method.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'sampling' and @value = ('yes', 'no')]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'sampling' and @value = ('yes', 'no')]">
               <xsl:attribute name="id">has-allowed-sampling-method</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The SAP declares whether a
                sampling method is used.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-allowed-sampling-method-diagnostic">
The SAP fails to declare whether a sampling method is used.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'sampling' and @value eq 'no'])                     then                         (matches(oscal:p[position() = last()], '^.*\swill not use sampling when performing this assessment\.$'))                     else                         (if (oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'sampling' and @value eq 'yes'])                         then                             (matches(oscal:p[position() = last()], '^.*\swill use sampling when performing this assessment\.$'))                         else                             (false()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'sampling' and @value eq 'no']) then (matches(oscal:p[position() = last()], '^.*\swill not use sampling when performing this assessment\.$')) else (if (oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'sampling' and @value eq 'yes']) then (matches(oscal:p[position() = last()], '^.*\swill use sampling when performing this assessment\.$')) else (false()))">
               <xsl:attribute name="id">has-sampling-method-statement</xsl:attribute>
               <xsl:attribute name="see">https://github.com/GSA/fedramp-automation-guides/issues/30</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The sampling methodology's final paragraph is the correct sampling statement.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-sampling-method-statement-diagnostic">
The SAP methodology's final paragraph does not match the required string for a sampling
            property with a value of <xsl:text/>
                  <xsl:value-of select="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'sampling']/@value"/>
                  <xsl:text/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:terms-and-conditions/oscal:part[@name eq 'disclosures']"
                 priority="1004"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:terms-and-conditions/oscal:part[@name eq 'disclosures']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:part[@name eq 'disclosure']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:part[@name eq 'disclosure']">
               <xsl:attribute name="id">has-roe-disclosure-detail</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The SAP Rules of Engagement (ROE) Disclosures have one or more detail disclosure
                statements.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-roe-disclosure-detail-diagnostic">
The SAP Rules of Engagement (ROE) Disclosures lacks detail disclosure
            statements.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="unsorted-dislosures"
                    select="oscal:part[@name eq 'disclosure']/oscal:prop[@name eq 'sort-id']/@value"/>
      <xsl:variable name="sorted-dislosures" select="sort($unsorted-dislosures)"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="deep-equal($unsorted-dislosures, $sorted-dislosures)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="deep-equal($unsorted-dislosures, $sorted-dislosures)">
               <xsl:attribute name="id">disclosure-ordered</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The SAP terms and conditions disclosures part must have disclosure parts
                that are ordered.</svrl:text>
               <svrl:diagnostic-reference diagnostic="disclosure-ordered-diagnostic">
The SAP disclosure parts are incorrectly ordered.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:terms-and-conditions/oscal:part[@name eq 'excluded-activities']"
                 priority="1003"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:terms-and-conditions/oscal:part[@name eq 'excluded-activities']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:part[@name eq 'excluded-activity']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:part[@name eq 'excluded-activity']">
               <xsl:attribute name="id">has-roe-excluded-activity</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The SAP Rules of Engagement (ROE) excluded activities must have one or more excluded
                activity parts.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-roe-excluded-activity-diagnostic">
The SAP Rules of Engagement (ROE) included activities lacks an excluded activity
            part.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:terms-and-conditions/oscal:part[@name eq 'liability-limitations']"
                 priority="1002"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:terms-and-conditions/oscal:part[@name eq 'liability-limitations']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:part[@name eq 'liability-limitation']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:part[@name eq 'liability-limitation']">
               <xsl:attribute name="id">has-liability-limitation</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The SAP terms and conditions has a part 'liability-limitations' that has one or
                more 'liability-limitation' parts.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-liability-limitation-diagnostic">
The SAP liability and limitations does not have at least one part named
            'liability-limitation'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="unsorted-limitations"
                    select="oscal:part[@name eq 'liability-limitation']/oscal:prop[@name eq 'sort-id']/@value"/>
      <xsl:variable name="sorted-limitations" select="sort($unsorted-limitations)"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="deep-equal($unsorted-limitations, $sorted-limitations)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="deep-equal($unsorted-limitations, $sorted-limitations)">
               <xsl:attribute name="id">liability-limitations-ordered</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The SAP terms and conditions liability-limitations part has
                liability-limitation parts that are ordered.</svrl:text>
               <svrl:diagnostic-reference diagnostic="liability-limitations-ordered-diagnostic">
The SAP liability-limitation parts are incorrectly ordered.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:terms-and-conditions/oscal:part[@name eq 'included-activities']"
                 priority="1001"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:terms-and-conditions/oscal:part[@name eq 'included-activities']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:part[@name eq 'included-activity']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:part[@name eq 'included-activity']">
               <xsl:attribute name="id">has-roe-included-activity</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The SAP Rules of Engagement (ROE) included activities must have one or more included
                activity parts.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-roe-included-activity-diagnostic">
The SAP Rules of Engagement (ROE) included activities lacks an included activity
            part.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:back-matter" priority="1000" mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:back-matter"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:resource[oscal:prop[@name eq 'type' and @value eq 'penetration-test-plan']]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:resource[oscal:prop[@name eq 'type' and @value eq 'penetration-test-plan']]">
               <xsl:attribute name="id">has-penetration-test-plan</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The penetration test plan methodology
                attachment should be present.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-penetration-test-plan-diagnostic">
The penetration test plan methodology attachment is not present.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <!--PATTERN signed-sap-->
   <!--RULE -->
   <xsl:template match="oscal:back-matter" priority="1002" mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:back-matter"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:resource[oscal:prop[@name eq 'type' and @value eq 'signed-sap']])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:resource[oscal:prop[@name eq 'type' and @value eq 'signed-sap']])">
               <xsl:attribute name="id">has-signed-sap-resource</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SAP must have a `signed-sap`
                resource.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-signed-sap-resource-diagnostic">
This OSCAL SAP lacks a `signed-sap` resource.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:resource[oscal:prop[@name eq 'type' and @value eq 'signed-sap']]"
                 priority="1001"
                 mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:resource[oscal:prop[@name eq 'type' and @value eq 'signed-sap']]"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="exists(oscal:description)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:description)">
               <xsl:attribute name="id">signed-sap-resource-has-description</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SAP `signed-sap` resource must have a description.</svrl:text>
               <svrl:diagnostic-reference diagnostic="signed-sap-resource-has-description-diagnostic">
This OSCAL SAP `signed-sap` resource lacks a description.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:rlink)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists(oscal:rlink)">
               <xsl:attribute name="id">signed-sap-resource-has-rlink</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SAP `signed-sap` resource must have an rlink.</svrl:text>
               <svrl:diagnostic-reference diagnostic="signed-sap-resource-has-rlink-diagnostic">
This OSCAL SAP `signed-sap` resource lacks an rlink.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:resource[oscal:prop[@name eq 'type' and @value eq 'signed-sap']]/oscal:rlink"
                 priority="1000"
                 mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:resource[oscal:prop[@name eq 'type' and @value eq 'signed-sap']]/oscal:rlink"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="@media-type eq 'application/pdf'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@media-type eq 'application/pdf'">
               <xsl:attribute name="id">signed-sap-rlink-has-media-type-pdf</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SAP `signed-sap` resource rlink should use 'application/pdf' media-type.</svrl:text>
               <svrl:diagnostic-reference diagnostic="signed-sap-rlink-has-media-type-pdf-diagnostic">
This OSCAL SAP `signed-sap` resource rlink does not use 'application/pdf'
            media-type.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="@*|node()" priority="-2" mode="M16">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
   </xsl:template>
   <!--PATTERN metadata-->
   <!--RULE -->
   <xsl:template match="oscal:metadata" priority="1005" mode="M17">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:metadata"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:role[@id = 'assessor']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:role[@id = 'assessor']">
               <xsl:attribute name="id">has-metadata-role-assessor</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This FedRAMP SAP has a role with an @id of 'assessor'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-role-assessor-diagnostic">
This FedRAMP metadata does not have a role with an @id of 'assessor'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:role[@id = 'csp-assessment-poc']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:role[@id = 'csp-assessment-poc']">
               <xsl:attribute name="id">has-metadata-csp-poc-role</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This FedRAMP SAP has a role with an @id value of 'csp-assessment-poc'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-csp-poc-role-diagnostic">
This FedRAMP metadata does not contain a role with an @id of
            'csp-assessment-poc'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:role[@id = 'csp-end-of-testing-poc']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:role[@id = 'csp-end-of-testing-poc']">
               <xsl:attribute name="id">has-metadata-role-end-of-testing</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This FedRAMP SAP has a role with an @id of 'csp-end-of-testing-poc'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-role-end-of-testing-diagnostic">
This FedRAMP metadata does not have a role with an @id of
            'csp-end-of-testing-poc'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:location"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:location">
               <xsl:attribute name="id">has-metadata-location</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This FedRAMP SAP has a location element in the metadata.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-location-diagnostic">
This FedRAMP metadata does not have a location.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:party[oscal:prop[@ns = 'https://fedramp.gov/ns/oscal' and @name = 'iso-iec-17020-identifier']]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:party[oscal:prop[@ns = 'https://fedramp.gov/ns/oscal' and @name = 'iso-iec-17020-identifier']]">
               <xsl:attribute name="id">has-metadata-party</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This FedRAMP SAP has a
                metadata element with a party element with a @name of the value 'iso-iec-17020-identifier'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-party-diagnostic">
This FedRAMP metadata does not have a party with a prop whose @name is
            'iso-iec-17020-identifier'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:party[oscal:prop[@ns = 'https://fedramp.gov/ns/oscal' and @name = 'iso-iec-17020-identifier' and matches(@value, '^\d{4}\.\d{2}$')]]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:party[oscal:prop[@ns = 'https://fedramp.gov/ns/oscal' and @name = 'iso-iec-17020-identifier' and matches(@value, '^\d{4}\.\d{2}$')]]">
               <xsl:attribute name="id">has-metadata-correctly-formatted-party</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This
                FedRAMP SAP has a metadata/party with an @name of 'iso-iec-17020-identifier' has a correctly formatted @value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-correctly-formatted-party-diagnostic">
This FedRAMP metadata/party with an @name of 'iso-iec-17020-identifier' does not
            have a correctly formatted @value.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:role[@id = 'csp-results-poc']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:role[@id = 'csp-results-poc']">
               <xsl:attribute name="id">has-metadata-role-test-results</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This FedRAMP SAP has a role with an @id of 'csp-results-poc'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-role-test-results-diagnostic">
This FedRAMP metadata does not have a role with an @id of
            'csp-results-poc'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:responsible-party[@role-id = 'csp-results-poc']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:responsible-party[@role-id = 'csp-results-poc']">
               <xsl:attribute name="id">has-metadata-responsible-party-test-results</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This FedRAMP SAP has a responsible-party with a @role-id of
                'csp-results-poc'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-responsible-party-test-results-diagnostic">
This FedRAMP metadata does not have a responsible-party with a @role-id of
            'csp-results-poc'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:responsible-party[@role-id = 'csp-end-of-testing-poc']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:responsible-party[@role-id = 'csp-end-of-testing-poc']">
               <xsl:attribute name="id">has-metadata-responsible-party-end-of-testing</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This FedRAMP SAP has a responsible-party with a @role-id of
                'csp-end-of-testing-poc'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-responsible-party-end-of-testing-diagnostic">
This FedRAMP metadata does not have a responsible-party with a @role-id of
            'csp-end-of-testing-poc'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:responsible-party[@role-id = 'csp-assessment-poc']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:responsible-party[@role-id = 'csp-assessment-poc']">
               <xsl:attribute name="id">has-metadata-csp-poc-responsible-party</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This FedRAMP SAP has a responsible-party with an @role-id value of
                'csp-assessment-poc'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-csp-poc-responsible-party-diagnostic">
This FedRAMP metadata does not contain a responsible-party with a @role-id of
            'csp-assessment-poc'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:role[@id = 'assessment-team']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:role[@id = 'assessment-team']">
               <xsl:attribute name="id">has-metadata-assessment-team-role</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This FedRAMP SAP has a role with an @id value of 'assessment-team'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-assessment-team-role-diagnostic">
This FedRAMP metadata does not contain a role with an @id of
            'assessment-team'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:responsible-party[@role-id = 'assessment-team']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:responsible-party[@role-id = 'assessment-team']">
               <xsl:attribute name="id">has-metadata-responsible-party-assessment</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This FedRAMP SAP has a responsible-party with an @role-id value of
                'assessment-team'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-responsible-party-assessment-diagnostic">
This FedRAMP metadata does not contain a responsible-party with a @role-id of
            'assessment-team'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:responsible-party[@role-id = 'assessment-lead']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:responsible-party[@role-id = 'assessment-lead']">
               <xsl:attribute name="id">has-metadata-responsible-party-lead</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This FedRAMP SAP has a responsible-party with an @role-id value of
                'assessment-lead'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-responsible-party-lead-diagnostic">
This FedRAMP metadata does not contain a responsible-party with a @role-id of
            'assessment-lead'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(oscal:responsible-party[@role-id = 'assessment-lead']) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(oscal:responsible-party[@role-id = 'assessment-lead']) = 1">
               <xsl:attribute name="id">has-metadata-responsible-party-lead-multiple</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This FedRAMP SAP has a single responsible-party with an
                @role-id value of 'assessment-lead'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-responsible-party-lead-multiple-diagnostic">
This FedRAMP metadata contains more than one responsible-party element with a
            @role-id of 'assessment-lead'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:metadata/oscal:responsible-party[@role-id = 'csp-results-poc']"
                 priority="1004"
                 mode="M17">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:metadata/oscal:responsible-party[@role-id = 'csp-results-poc']"/>
      <xsl:variable name="SAP-partyPersonResults_IDs"
                    select="../oscal:party[@type = 'person']/@uuid"/>
      <xsl:variable name="ssp-party-person-ids"
                    select="$ssp-doc/oscal:system-security-plan/oscal:metadata/oscal:party[@type = 'person']/@uuid"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:party-uuid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:party-uuid">
               <xsl:attribute name="id">has-metadata-responsible-party-results-uuid</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This FedRAMP SAP has a responsible-party with a @role-id of 'csp-results-poc' and a child party-uuid
                element.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-responsible-party-results-uuid-diagnostic">
This FedRAMP metadata has a responsible-party with a @role-id of
            'csp-results-poc' without a child party-uuid.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:party-uuid[. = $ssp-party-person-ids])                     then                         true()                     else                         if (oscal:party-uuid[. = $SAP-partyPersonResults_IDs])                         then                             true()                         else                             false()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:party-uuid[. = $ssp-party-person-ids]) then true() else if (oscal:party-uuid[. = $SAP-partyPersonResults_IDs]) then true() else false()">
               <xsl:attribute name="id">has-metadata-csp-results-responsible-party-matches</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Responsible party POCs for Communication of Results have matching uuid values in either the SSP or SAP
                party/uuid elements.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-csp-results-responsible-party-matches-diagnostic">
This fedRAMP metadata as a responsible party POCs for Communication of
            Results without a matching person party in either the associated SSP or the SAP.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:metadata/oscal:responsible-party[@role-id = 'csp-end-of-testing-poc']"
                 priority="1003"
                 mode="M17">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:metadata/oscal:responsible-party[@role-id = 'csp-end-of-testing-poc']"/>
      <xsl:variable name="sap-party-person-EOT-ids"
                    select="../oscal:party[@type = 'person']/@uuid"/>
      <xsl:variable name="ssp-party-person-ids"
                    select="$ssp-doc/oscal:system-security-plan/oscal:metadata/oscal:party[@type = 'person']/@uuid"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:party-uuid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:party-uuid">
               <xsl:attribute name="id">has-metadata-responsible-party-uuid</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This FedRAMP SAP has a responsible-party with a @role-id of 'csp-end-of-testing-poc' and a child party-uuid
                element.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-responsible-party-uuid-diagnostic">
This FedRAMP metadata has a responsible-party with a @role-id of
            'csp-end-of-testing-poc' without a child party-uuid.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:party-uuid[. = $ssp-party-person-ids])                     then                         true()                     else                         if (oscal:party-uuid[. = $sap-party-person-EOT-ids])                         then                             true()                         else                             false()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:party-uuid[. = $ssp-party-person-ids]) then true() else if (oscal:party-uuid[. = $sap-party-person-EOT-ids]) then true() else false()">
               <xsl:attribute name="id">has-metadata-csp-eot-responsible-party-matches</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Responsible party POCs for End of Testing have matching uuid values in either the SSP or SAP party/uuid
                elements.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-csp-eot-responsible-party-matches-diagnostic">
This fedRAMP metadata as a responsible party POCs for End of Testing
            without a matching person party in either the associated SSP or the SAP.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:metadata/oscal:responsible-party[@role-id = 'assessment-team']"
                 priority="1002"
                 mode="M17">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:metadata/oscal:responsible-party[@role-id = 'assessment-team']"/>
      <xsl:variable name="partyPersonIDs" select="../oscal:party[@type = 'person']/@uuid"/>
      <xsl:variable name="responsible-parties" select="oscal:party-uuid"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count($responsible-parties) gt 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count($responsible-parties) gt 0">
               <xsl:attribute name="id">has-metadata-responsible-party-has-party-uuid</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>There is at least one party-uuid element as a child of
                responsible-party[@role-id='assessment-team'].</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-responsible-party-has-party-uuid-diagnostic">
This FedRAMP responsible-party element, <xsl:text/>
                  <xsl:value-of select="@role-id"/>
                  <xsl:text/> does not have at least one party-uuid element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count($responsible-parties) eq count(distinct-values($partyPersonIDs[. = $responsible-parties]))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count($responsible-parties) eq count(distinct-values($partyPersonIDs[. = $responsible-parties]))">
               <xsl:attribute name="id">has-metadata-responsible-party-matches</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each assessment team member in
                this FedRAMP SAP is described individually.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-responsible-party-matches-diagnostic">
This FedRAMP metadata does not have a matching party for every individual on the
            assessment team.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:metadata/oscal:responsible-party[@role-id = 'assessment-lead']"
                 priority="1001"
                 mode="M17">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:metadata/oscal:responsible-party[@role-id = 'assessment-lead']"/>
      <xsl:variable name="assessment-team"
                    select="../oscal:responsible-party[@role-id = 'assessment-team']/oscal:party-uuid"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:party-uuid[. = $assessment-team]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:party-uuid[. = $assessment-team]">
               <xsl:attribute name="id">has-metadata-responsible-party-lead-matches</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The assessment-lead has a party-uuid that exists in the assessment-team list of
                party-uuid elements.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-responsible-party-lead-matches-diagnostic">
This FedRAMP metadata does not have a
            responsible-party[@role-id='assessment-lead']/party-uuid that matches a
            responsible-party[@role-id='assessment-team']/party-uuid.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="../oscal:party[@type = 'person'][@uuid = current()/oscal:party-uuid]/oscal:telephone-number"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../oscal:party[@type = 'person'][@uuid = current()/oscal:party-uuid]/oscal:telephone-number">
               <xsl:attribute name="id">has-metadata-responsible-party-phone</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The responsible-party with @role-id
                of 'assessment-lead' must reference a party with a telephone number.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-responsible-party-phone-diagnostic">
The responsible-party with an @role-id of 'assessment-lead' does not reference a
            party with a telephone number.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="../oscal:party[@type = 'person'][@uuid = current()/oscal:party-uuid]/oscal:email-address"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../oscal:party[@type = 'person'][@uuid = current()/oscal:party-uuid]/oscal:email-address">
               <xsl:attribute name="id">has-metadata-responsible-party-email</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The responsible-party with @role-id of
                'assessment-lead' must reference a party with an email address.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-responsible-party-email-diagnostic">
The first person of the assessment team does not reference a party with an email
            address.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:responsible-party[@role-id = 'csp-assessment-poc']"
                 priority="1000"
                 mode="M17">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:responsible-party[@role-id = 'csp-assessment-poc']"/>
      <xsl:variable name="sap-csp-assessment-poc" select="oscal:party-uuid"/>
      <xsl:variable name="sap-party-person-ids"
                    select="oscal:party[@type = 'person']/@uuid"/>
      <xsl:variable name="ssp-party-person-ids"
                    select="$ssp-doc/oscal:system-security-plan/oscal:metadata/oscal:party[@type = 'person']/@uuid"/>
      <xsl:variable name="SAP-partyOrgIDs"
                    select="oscal:party[@type = 'organization']/@uuid"/>
      <xsl:variable name="ssp-party-org-ids"
                    select="$ssp-doc/oscal:system-security-plan/oscal:metadata/oscal:party[@type = 'organization']/@uuid"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:party-uuid[. = $ssp-party-person-ids])                     then                         true()                     else                         if (oscal:party-uuid[. = $sap-party-person-ids])                         then                             true()                         else                             if (oscal:party-uuid[. = $ssp-party-org-ids])                             then                                 true()                             else                                 if (oscal:party-uuid[. = $SAP-partyOrgIDs])                                 then                                     true()                                 else                                     false()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:party-uuid[. = $ssp-party-person-ids]) then true() else if (oscal:party-uuid[. = $sap-party-person-ids]) then true() else if (oscal:party-uuid[. = $ssp-party-org-ids]) then true() else if (oscal:party-uuid[. = $SAP-partyOrgIDs]) then true() else false()">
               <xsl:attribute name="id">has-metadata-csp-poc-responsible-party-matches</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Responsible party POCs have matching uuid values in either the SSP or SAP party/uuid elements.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-csp-poc-responsible-party-matches-diagnostic">
This FedRAMP SAP has a responsible-party with a role-id of
            'csp-assessment-poc' whose uuid, <xsl:text/>
                  <xsl:value-of select="oscal:party-uuid"/>
                  <xsl:text/> , does not match a party in either the associated SSP or the SAP.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(oscal:party-uuid) gt 2"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(oscal:party-uuid) gt 2">
               <xsl:attribute name="id">has-metadata-responsible-party-csp-poc-matches</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A responsible party with a role-id of 'csp-assessment-poc' must contain at least three Points of
                Contact.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-responsible-party-csp-poc-matches-diagnostic">
The responsible party with a role-id of 'csp-assessment-poc' does not
            contain at least three Points of Contact.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="../oscal:responsible-party[@role-id = 'csp-operations-center']/oscal:party-uuid[. = $sap-csp-assessment-poc]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../oscal:responsible-party[@role-id = 'csp-operations-center']/oscal:party-uuid[. = $sap-csp-assessment-poc]">
               <xsl:attribute name="id">has-metadata-csp-poc-responsible-party-ops-center</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>At least one of
                the Points of Contact must be an Operations Center.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-metadata-csp-poc-responsible-party-ops-center-diagnostic">
The responsible party with a role-id of 'csp-assessment-poc' does not
            have a POC that is a Operations Center.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="@*|node()" priority="-2" mode="M17">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
   </xsl:template>
   <!--PATTERN assessment-assets-->
   <!--RULE -->
   <xsl:template match="oscal:assessment-assets/oscal:component[@type = 'software']"
                 priority="1002"
                 mode="M18">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:assessment-assets/oscal:component[@type = 'software']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name = 'vendor']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name = 'vendor']">
               <xsl:attribute name="id">has-software-component-vendor</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SAP assessment asset component must have a vendor name.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-software-component-vendor-diagnostic">
This FedRAMP SAP has a assessment asset component, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, that does not identify the vendor name.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name = 'name']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name = 'name']">
               <xsl:attribute name="id">has-software-component-tool</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SAP assessment asset component must have a tool name.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-software-component-tool-diagnostic">
This FedRAMP SAP has a assessment asset component, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, that does not identify the tool name.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name = 'version']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name = 'version']">
               <xsl:attribute name="id">has-software-component-version</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SAP assessment asset component must have a version number for the tool.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-software-component-version-diagnostic">
This FedRAMP SAP has a assessment asset component, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, that does not identify the version of the tool.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:status[@state = 'operational']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:status[@state = 'operational']">
               <xsl:attribute name="id">has-software-component-status</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SAP assessment asset component has a status with a state of
                'operational'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-software-component-status-diagnostic">
This FedRAMP SAP has a assessment asset component, <xsl:text/>
                  <xsl:value-of select="@uuid"/>
                  <xsl:text/>, that does not identify the status state as 'operational'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M18"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:assessment-platform" priority="1001" mode="M18">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:assessment-platform"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:prop[@name eq 'ipv4-address'])                     then                         (oscal:prop[@name eq 'ipv4-address'][matches(@value, '(^[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?$)')])                     else                         (true())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:prop[@name eq 'ipv4-address']) then (oscal:prop[@name eq 'ipv4-address'][matches(@value, '(^[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?$)')]) else (true())">
               <xsl:attribute name="id">ipv4-has-content</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="oscal:prop[@name = 'ipv4-address']/@value"/>
                  <xsl:text/>A FedRAMP SAP assessment-platform IPv4 value must be valid.</svrl:text>
               <svrl:diagnostic-reference diagnostic="ipv4-has-content-diagnostic">
The @value content of prop whose @name is 'ipv4-address' has incorrect content.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:prop[@name eq 'ipv4-address']/@value = '0.0.0.0')                     then                         (false())                     else                         (true())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:prop[@name eq 'ipv4-address']/@value = '0.0.0.0') then (false()) else (true())">
               <xsl:attribute name="id">ipv4-has-non-placeholder</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="oscal:prop[@name = 'asset-id']/@value"/>
                  <xsl:text/>A FedRAMP SAP assessment-platform element must not define a placeholder IPv4
                value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="ipv4-has-non-placeholder-diagnostic">
The @value content of prop whose @name is 'ipv4-address' has placeholder value of
            0.0.0.0.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="IPv6-regex"
                    select="                     '(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:)                 {1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:)                 {1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]                 {1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:                 ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))'"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:prop[@name eq 'ipv6-address'])                     then                         (oscal:prop[@name eq 'ipv6-address'][matches(@value, $IPv6-regex)])                     else                         (true())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:prop[@name eq 'ipv6-address']) then (oscal:prop[@name eq 'ipv6-address'][matches(@value, $IPv6-regex)]) else (true())">
               <xsl:attribute name="id">ipv6-has-content</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="oscal:prop[@name = 'asset-id']/@value"/>
                  <xsl:text/>A FedRAMP SAP assessment-platform IPv6 value must be valid.</svrl:text>
               <svrl:diagnostic-reference diagnostic="ipv6-has-content-diagnostic">
The @value content of prop whose @name is 'ipv6-address' has incorrect content.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:prop[@name eq 'ipv6-address']/@value eq '::')                     then                         (false())                     else                         (true())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:prop[@name eq 'ipv6-address']/@value eq '::') then (false()) else (true())">
               <xsl:attribute name="id">ipv6-has-non-placeholder</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="oscal:prop[@name = 'asset-id']/@value"/>
                  <xsl:text/> must have an appropriate IPv6 value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="ipv6-has-non-placeholder-diagnostic">
The @value content of prop whose @name is 'ipv6-address' has placeholder value of
            ::.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M18"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:assessment-platform/oscal:uses-component"
                 priority="1000"
                 mode="M18">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:assessment-platform/oscal:uses-component"/>
      <xsl:variable name="SAP-assessment-assets-components"
                    select="../../oscal:component/@uuid"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@component-uuid[. = $SAP-assessment-assets-components]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@component-uuid[. = $SAP-assessment-assets-components]">
               <xsl:attribute name="id">has-uses-component-match</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SAP must have assessment platform uses-component uuid values
                that match assessment-assets component uuid values.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-uses-component-match-diagnostic">
This assessment platform uses-component uuid value, <xsl:text/>
                  <xsl:value-of select="@component-uuid"/>
                  <xsl:text/> does not have a matching assessment-assets component uuid value.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M18"/>
   </xsl:template>
</xsl:stylesheet>
