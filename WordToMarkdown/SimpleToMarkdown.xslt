<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
	xmlns:i="urn:WordToMarkdown"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output
		method="text"
		omit-xml-declaration="yes"
		media-type="text/plain"
	/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="i:document">
        <xsl:apply-templates />
        <xsl:text>&#xa;</xsl:text>
        <xsl:for-each select="//i:link">
            <xsl:text>&#32;&#32;[</xsl:text>
            <xsl:value-of select="position()" />
            <xsl:text>]:&#32;</xsl:text>
            <xsl:value-of select="@href" />
            <xsl:text>&#xa;</xsl:text>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="i:body">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="i:heading">
        <xsl:value-of select="substring('######', 1, @level)" />
        <xsl:text>&#32;</xsl:text>
        <xsl:apply-templates />
        <xsl:text>&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <xsl:template match="i:link">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="." />
        <xsl:text>][</xsl:text>
        <xsl:value-of select="count(preceding::i:link) + 1" />
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template match="i:image">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="." />
        <xsl:text>][</xsl:text>
        <xsl:value-of select="count(preceding::i:image) + 1" />
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template match="i:italic">
        <xsl:text>*</xsl:text>
        <xsl:apply-templates />
        <xsl:text>*</xsl:text>
    </xsl:template>

    <xsl:template match="i:bold">
        <xsl:text>__</xsl:text>
        <xsl:apply-templates />
        <xsl:text>__</xsl:text>
    </xsl:template>

    <xsl:template match="i:para">
        <xsl:if test="./* or text() != ''">
            <xsl:apply-templates />
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="i:linebreak">
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <!-- Bullet list-item -->
    <xsl:template match="i:listitem[@type='1']">
        <xsl:value-of select="substring('&#9;&#9;&#9;&#9;&#9;&#9;&#9;&#9;&#9;&#9;', 1, @level)" />
        <xsl:text>-&#9;</xsl:text>
        <xsl:apply-templates />
        <xsl:text>&#xa;</xsl:text>
        <xsl:if test="local-name(following-sibling::i:*[1]) != 'listitem'">
            <xsl:text>&#xa;</xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- Numbered list-item -->
    <xsl:template match="i:listitem[@type='2']">
        <xsl:variable name="level" select="@level" />
        <xsl:variable name="type" select="@type" />
        <xsl:value-of select="substring('&#9;&#9;&#9;&#9;&#9;&#9;&#9;&#9;&#9;&#9;', 1, $level)" />
        <xsl:value-of select="count(preceding::i:listitem[@level=$level and @type=$type]) + 1" />
        <xsl:text>.&#9;</xsl:text>
        <xsl:apply-templates />
        <xsl:text>&#xa;</xsl:text>
        <xsl:if test="local-name(following-sibling::i:*[1]) != 'listitem'">
            <xsl:text>&#xa;</xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- Trim whitespace on headings, paragraphs and list-items -->
    <!--xsl:template match="i:heading/text() | i:para/text() | i:listitem/text()"><xsl:choose><xsl:when test="substring(., string-length(.), 1) = ' '"><xsl:value-of select="substring(., 1, string-length(.) - 1)" /></xsl:when><xsl:otherwise><xsl:value-of select="." /></xsl:otherwise></xsl:choose></xsl:template-->

    <!-- Escape asterix -->
    <xsl:template match="text()">
        <xsl:call-template name="string-replace-all">
            <xsl:with-param name="text" select="." />
            <xsl:with-param name="replace" select="'*'" />
            <xsl:with-param name="by" select="'\*'" />
        </xsl:call-template>
    </xsl:template>

    <!-- Superscript ® -->
    <xsl:template match="text()">
        <xsl:call-template name="string-replace-all">
            <xsl:with-param name="text" select="." />
            <xsl:with-param name="replace" select="'®'" />
            <xsl:with-param name="by" select="'&lt;sup&gt;®&lt;/sup&gt;'" />
        </xsl:call-template>
    </xsl:template>

    <!-- Utility string replace -->
    <xsl:template name="string-replace-all">
        <xsl:param name="text" />
        <xsl:param name="replace" />
        <xsl:param name="by" />
        <xsl:choose>
            <xsl:when test="contains($text, $replace)">
                <xsl:value-of select="substring-before($text, $replace)" />
                <xsl:value-of select="$by" />
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text" select="substring-after($text, $replace)" />
                    <xsl:with-param name="replace" select="$replace" />
                    <xsl:with-param name="by" select="$by" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>