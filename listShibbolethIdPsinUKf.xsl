<?xml version="1.0" encoding="UTF-8"?>
<!--

	Lists visible Shibboleth IdPs in the UK federation.

	Intended to be run like `xsltproc listShibbolethIdPsinUKf.xsl ukfederation-metadata.xml`

-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
        xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
        xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

        <xsl:output method="text" encoding="UTF-8"/>

	<!-- catches both /idp/profile/SAML2/POST/SSO and /shibboleth-idp/profile/SAML2/POST/SSO forms -->
        <xsl:template match="md:EntityDescriptor
                [md:IDPSSODescriptor/md:SingleSignOnService[contains(@Location, 'idp/profile/SAML')]]
		[not(../md:Extensions/mdattr:EntityAttributes/saml:Attribute[@Name='http://macedir.org/entity-category'][saml:AttributeValue='http://refeds.org/category/hide-from-discovery'])]
		[md:Extensions/mdrpi:RegistrationInfo[@registrationAuthority='http://ukfederation.org.uk']]
		">
                <xsl:value-of select="@entityID"/>
                <xsl:text>&#10;</xsl:text>
        </xsl:template>

        <xsl:template match="text()">
                <!-- do nothing -->
        </xsl:template>
</xsl:stylesheet>
