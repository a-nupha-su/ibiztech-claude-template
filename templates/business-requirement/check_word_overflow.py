# วัดหน้าที่มีเนื้อหาเลยขอบขวาหรือซ้ายของระยะขอบ: overflow.py x.pdf
import re,subprocess,sys
xml=subprocess.check_output(["pdftotext","-bbox",sys.argv[1],"-"],text=True)
pages=re.findall(r'<page width="([\d.]+)" height="[\d.]+">(.*?)</page>',xml,re.S)
bad=[]
for i,(w,b) in enumerate(pages,1):
    xs=[(float(a),float(c)) for a,c in re.findall(r'<word xMin="([\d.]+)" yMin="[\d.]+" xMax="([\d.]+)"',b)]
    if not xs: continue
    l=min(x[0] for x in xs); r=max(x[1] for x in xs)
    if r>float(w)-72+2 or l<72-8: bad.append((i,round(l),round(r)))
print("pages",len(pages),"margin_right",float(pages[0][0])-72,"overflow_pages",len(bad)); print(bad[:40])
