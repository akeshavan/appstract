<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:h="http://www.w3.org/1999/xhtml">

	<xsl:template match="sec[@sec-type]">
		<xsl:if test="@sec-type='materials|methods' or @sec-type='methods'">
            <xsl:copy-of select="."/>
	     </xsl:if>
		 <xsl:message>SEC:<xsl:value-of select="@sec-type"/></xsl:message>
	</xsl:template> 

	
</xsl:stylesheet>
