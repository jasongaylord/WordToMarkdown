<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
 	xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" 
 	xmlns:rels="http://schemas.openxmlformats.org/package/2006/relationships" 
 	xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" 
 	xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" 
 	xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
    xmlns:i="urn:WordToMarkdown"
    exclude-result-prefixes="msxsl"> 

	<xsl:template match="/w:document">
		<i:document>
			<xsl:apply-templates />
		</i:document>
	</xsl:template>

	<xsl:template match="w:body">
		<i:body>
			<xsl:apply-templates />
		</i:body>
	</xsl:template>

	<xsl:template match="rels:Relationships" />

	<!-- Heading styles -->
	<xsl:template match="w:p[ w:pPr/w:pStyle/@w:val[ starts-with( ., 'Heading' ) ] ]">
		<xsl:variable name="style" select="w:pPr/w:pStyle/@w:val[ starts-with( ., 'Heading' ) ]" />
		<xsl:variable name="level" select="substring( $style, 8, 1 )" />
		<xsl:variable name="type" select="translate( substring( $style, 9 ), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz' )" />
		<xsl:if test="count(w:r)">
			<i:heading>
				<xsl:attribute name="level"><xsl:value-of select="$level" /></xsl:attribute>
				<xsl:if test="$type != ''"><xsl:attribute name="type"><xsl:value-of select="$type" /></xsl:attribute></xsl:if>
				<xsl:apply-templates />
			</i:heading>
		</xsl:if>
	</xsl:template>

	<!-- Regular paragraph style -->
	<xsl:template match="w:p">
		<xsl:if test="count(w:r)">
			<i:para><xsl:apply-templates /></i:para>
		</xsl:if>
	</xsl:template>

	<!-- List items -->
	<xsl:template match="w:p[ w:pPr/w:numPr ]">
		<xsl:if test="count(w:r)">
			<i:listitem level="{ w:pPr/w:numPr/w:ilvl/@w:val }" type="{ w:pPr/w:numPr/w:numId/@w:val }"><xsl:apply-templates /></i:listitem>
		</xsl:if>
	</xsl:template>
	<xsl:template match="w:p[ w:pPr/w:pStyle/@w:val = 'ListBullet']">
		<xsl:if test="count(w:r)">
			<i:listitem level="0" type="1"><xsl:apply-templates /></i:listitem>
		</xsl:if>
	</xsl:template>
	<xsl:template match="w:p[ w:pPr/w:pStyle/@w:val = 'ListNumber']">
		<xsl:if test="count(w:r)">
			<i:listitem level="0" type="2"><xsl:apply-templates /></i:listitem>
		</xsl:if>
	</xsl:template>

	<!-- Text content -->
	<xsl:template match="w:r">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="w:r[w:rPr/w:b and not(w:rPr/w:i)]/w:t">
		<!-- bold -->
		<i:bold><xsl:value-of select="." /></i:bold>
	</xsl:template>
	<xsl:template match="w:r[w:rPr/w:i and not(w:rPr/w:b)]/w:t">
		<!-- italic -->
		<i:italic><xsl:value-of select="." /></i:italic>
	</xsl:template>
	<xsl:template match="w:r[w:rPr/w:i and w:rPr/w:b]/w:t">
		<!-- bold + italic -->
		<i:italic><i:bold><xsl:value-of select="." /></i:bold></i:italic>
	</xsl:template>
	<xsl:template match="w:t">
		<!-- normal -->
		<xsl:value-of select="." />
	</xsl:template>
	<xsl:template match="w:br">
		<i:linebreak />
	</xsl:template>

	<!-- Complete hyperlinks -->
	<xsl:template match="w:hyperlink">
		<xsl:variable name="id" select="@r:id" />
		<xsl:if test="count(w:r)">
			<i:link>
				<xsl:attribute name="href"><xsl:value-of select="/w:document/rels:Relationship[@Id=$id]/@Target" /></xsl:attribute>
				<xsl:if test="/w:document/rels:Relationship[@Id=$id]/@TargetMode">
					<xsl:attribute name="target"><xsl:value-of select="/w:document/rels:Relationship[@Id=$id]/@TargetMode" /></xsl:attribute>
				</xsl:if>
				<xsl:apply-templates />
			</i:link>
		</xsl:if>
	</xsl:template>

	<!-- Images -->
	<xsl:template match="w:drawing">
		<xsl:apply-templates select=".//a:blip" />
	</xsl:template>
	<xsl:template match="a:blip">
		<xsl:variable name="id" select="@r:embed" />
		<i:image>
			<xsl:attribute name="src"><xsl:value-of select="/w:document/data/@word-folder" /><xsl:value-of select="/w:document/rels:Relationship[@Id=$id]/@Target" /></xsl:attribute>
			<xsl:attribute name="width"><xsl:value-of select="round( ancestor::w:drawing[1]//wp:extent/@cx div 9525 )" /></xsl:attribute>
			<xsl:attribute name="height"><xsl:value-of select="round( ancestor::w:drawing[1]//wp:extent/@cy div 9525 )" /></xsl:attribute>
            <xsl:attribute name="alt"><xsl:value-of select="ancestor::w:drawing[1]//wp:docPr/@descr" /></xsl:attribute>
            <xsl:attribute name="title"><xsl:value-of select="ancestor::w:drawing[1]//wp:docPr/@title" /></xsl:attribute>
		</i:image>
	</xsl:template>

	<!-- Edit: Inserted text -->
	<xsl:template match="w:ins">
		<xsl:apply-templates />
	</xsl:template>

	<!-- Edit: Deleted text -->
	<xsl:template match="w:del" />

</xsl:stylesheet>