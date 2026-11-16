#!/bin/zsh
# ใช้ Word จริงแปลงสำเนาเป็น PDF: word_pdf.sh in.docx out.pdf (ถอด updateFields ในสำเนา กัน dialog ค้าง)
in=$1; out=$2; C=~/Library/Containers/com.microsoft.Word/Data/Documents; mkdir -p $C; t=$(mktemp -d); cp "$in" $t/a.docx; (cd $t; unzip -q a.docx word/settings.xml; python3 - <<'PY'
import re
p="word/settings.xml"; s=open(p,encoding="utf-8").read(); s=re.sub(r'<w:updateFields[^>]*/>','',s); open(p,"w",encoding="utf-8").write(s)
PY
zip -q a.docx word/settings.xml); N=wf-$$; cp $t/a.docx $C/$N.docx
open -g -a "Microsoft Word" $C/$N.docx
perl -e 'alarm 200; exec @ARGV' osascript <<OSA
tell application "Microsoft Word"
  repeat 90 times
    if exists document "$N.docx" then exit repeat
    delay 1
  end repeat
  delay 6
  save as document "$N.docx" file name "$C/$N.pdf" file format format PDF
  delay 2
  close document "$N.docx" saving no
end tell
OSA
r=$?; for i in {1..90}; do [ -s $C/$N.pdf ] && break; perl -e 'select(undef,undef,undef,1)'; done
[ -s $C/$N.pdf ] || { echo "ไม่พบ PDF จาก Word" >&2; r=3; }
cp $C/$N.pdf "$out" 2>/dev/null; rm -f $C/$N.docx $C/$N.pdf; rm -rf $t; exit $r
