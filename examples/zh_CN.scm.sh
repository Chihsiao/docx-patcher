#!/usr/bin/env docx-patcher.sh
# shellcheck shell=bash

:xml.file word/settings.xml && {
    :xml.edit --var 'themeFontLang' '/w:settings/w:themeFontLang' \
        -d "\$themeFontLang/@w:eastAsia" -s "\$themeFontLang" -t attr -n w:eastAsia -v 'zh-CN'
}

:xml.file word/styles.xml && {
    :xml.edit --var 'rPrDefault' '/w:styles/w:docDefaults/w:rPrDefault'\
        -u "\$rPrDefault/w:rPr/w:lang/@w:eastAsia" -v 'zh-CN'
}
