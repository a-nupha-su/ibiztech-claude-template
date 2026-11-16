# นับบรรทัดที่ตัดกลางคำใน PDF: คำในพจนานุกรมที่คร่อมรอยต่อระหว่างบรรทัดในกล่องข้อความเดียวกัน
import re,subprocess,sys,html
from pythainlp.corpus import thai_words
from pythainlp.tokenize import word_tokenize
D=set(thai_words())|{"ดีลเลอร์","เอกสาร","สำนักงานใหญ่","เจ้าหน้าที่","ผู้จัดการ"}
xml=subprocess.check_output(["pdftotext","-bbox-layout",sys.argv[1],"-"],text=True)
hits=[];n=0
TH=re.compile(r"[฀-๿]+$");HD=re.compile(r"^[฀-๿]+")
for page,body in enumerate(xml.split("<page ")[1:],1):
    for blk in re.findall(r"<block .*?</block>",body,re.S):
        lines=["".join(html.unescape(w) for w in re.findall(r"<word [^>]*>([^<]*)</word>",l)).replace("​","") for l in re.findall(r"<line .*?</line>",blk,re.S)]
        for a,b in zip(lines,lines[1:]):
            ma=TH.search(a);mb=HD.search(b)
            if not(ma and mb):continue
            n+=1
            x,y=ma.group(0)[-14:],mb.group(0)[:14]
            pos=0
            for tok in word_tokenize(x+y,engine="newmm"):
                if pos<len(x)<pos+len(tok) and tok in D and len(tok)>=3:
                    hits.append((page,x[-8:]+"/"+y[:8],tok));break
                pos+=len(tok)
print(sys.argv[1].split("/")[-1],"รอยต่อไทย",n,"ตัดกลางคำ",len(hits),"หน้า",len({h[0] for h in hits}))
print(hits[:int(sys.argv[2]) if len(sys.argv)>2 else 8])
