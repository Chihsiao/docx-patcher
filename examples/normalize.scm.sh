#!/usr/bin/env docx-patcher.sh
# shellcheck shell=bash

:xml.file word/settings.xml && {
  :xml.proc '
    <xsl:template match="/w:settings">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:copy-of select="node()[not(self::w:compat)]"/>
        <xsl:choose>
          <xsl:when test="not(w:compat)">
            <w:compat>
              <w:doNotUseIndentAsNumberingTabStop/>
              <w:compatSetting w:name="compatibilityMode" w:uri="http://schemas.microsoft.com/office/word" w:val="12"/>
            </w:compat>
          </xsl:when>
          <xsl:otherwise>
            <w:compat>
              <xsl:copy-of select="w:compat/@*"/>
              <xsl:copy-of select="w:compat/node()[not(self::w:splitPgBreakAndParaMark)]"/>
            </w:compat>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:copy>
    </xsl:template>
  '
}

:xml.file word/theme/theme1.xml && {
  :xml.edit --var 'accent1' '/a:theme/a:themeElements/a:clrScheme[@name="Office"]/a:accent1' \
    -d "\$accent1/node()" -s "\$accent1" -t elem -n a:srgbClr \
      -s "\$prev" -t attr -n val -v '000000'
}

:xml.file word/styles.xml && {
  :xml.edit --var 'headings' '/w:styles/w:style[starts-with(@w:styleId, "Heading")]' \
    -u "\$headings/w:rPr/w:color/@w:val" -v '000000'
}
