# Estrae domande e immagini dal PDF del questionario e produce assets/data/questions.json.
# Uso: python3 tools/extract_questions.py Questionario.pdf assets   (richiede: pip install pdfplumber pillow)
# La chiave delle risposte (KEY) non e' nel PDF: e' stata determinata a mano.
import os as _os
import pdfplumber, json, re, os, sys
PDF=sys.argv[1] if len(sys.argv)>1 else 'Questionario_SaNa_ITA.pdf'
OUT=sys.argv[2] if len(sys.argv)>2 else 'assets'
# Chiave delle risposte (indice 0=a, 1=b, 2=c)
KEY = """1a 2b 3c 4c 5b 6a 7a 8c 9b 10c 11a 12b 13b 14a 15b 16c 17b 18a 19a 20b
21b 22a 23a 24a 25c 26c 27a 28c 29b 30a 31a 32a 33c 34a 35b 36b 37c 38b 39b 40a
41a 42c 43a 44a 45b 46a 47b 48b 49c 50b 51b 52a 53a 54b 55a 56c 57b 58b 59a 60a
61c 62c 63a 64b 65a 66c 67b 68a 69b 70a 71a 72a 73b 74a 75a 76b 77b 78a 79a 80b
81c 82a 83b 84b 85a 86a 87c 88a 89c 90b 91a 92a 93c 94a 95b 96a 97a 98a 99b 100a
101b 102a 103a 104a 105c 106c 107c 108c 109b 110c 111b 112b 113a 114a 115b 116b 117a 118b 119b 120a
121b 122b 123c 124a 125b 126b 127c 128a 129b 130b 131b 132c 133a 134b 135b 136b 137c 138a 139c 140b
141b 142b 143b 144a 145b 146b 147a 148a 149a 150c"""
key={int(m.group(1)):'abc'.index(m.group(2)) for m in re.finditer(r'(\d+)([abc])',KEY)}
assert len(key)==150
def section(n):
    if n<=32: return 'A','Ittiologia'
    if n<=46: return 'A','Anatomia'
    if n<=53: return 'A','Malattie dei pesci'
    if n<=79: return 'B','Protezione delle acque e ecologia'
    if n<=107: return 'C','Attrezzi e tecniche di pesca'
    if n<=140: return 'D','Legislazione e protezione degli animali'
    return 'E','Valorizzazione alimentare delle catture'
def clean(s): return re.sub(r'\s+',' ',s.replace('\u00ad','')).strip()
_os.makedirs(OUT+'/images',exist_ok=True); _os.makedirs(OUT+'/data',exist_ok=True)
qs={}
with pdfplumber.open(PDF) as pdf:
    for pno,page in enumerate(pdf.pages):
        for tb in page.find_tables():
            data=tb.extract()
            for row,trow in zip(data,tb.rows):
                if not row[0] or not row[0].strip().isdigit(): continue
                n=int(row[0]); txt=clean(row[1] or '')
                lines=(row[2] or '').split('\n')
                opts=[]
                for ln in lines:
                    m=re.match(r'^\s*([abc])\)\s*(.*)$',ln)
                    if m: opts.append(m.group(2).strip())
                    elif opts: opts[-1]+=' '+ln.strip()
                    else: raise SystemExit(f'??? {n} {ln}')
                if n==49 and len(opts)==2:
                    # Nel PDF manca l'etichetta "c)" della terza opzione
                    b=opts[1]; i=b.index('Nei fiumi'); opts=[opts[0],b[:i].strip(),b[i:].strip()]
                opts=[clean(o) for o in opts]
                assert len(opts)==3,(n,opts)
                # immagini della riga
                x0,t,x1,b=trow.bbox
                imgs=[im for im in page.images if t<=(im['top']+im['bottom'])/2<=b]
                image=None
                if imgs:
                    im=imgs[0]
                    bb=(im['x0'],im['top'],im['x1'],im['bottom'])
                    fn=f'q{n:03d}.png'
                    page.crop(bb).to_image(resolution=220).save(f'{OUT}/images/{fn}')
                    image=f'assets/images/{fn}'
                s,sub=section(n)
                qs[n]={'id':n,'section':s,'subsection':sub,'text':txt,'options':opts,'correct':key[n],'image':image}
assert sorted(qs)==list(range(1,151)),[i for i in range(1,151) if i not in qs]
sections={'A':'Conoscenza dei pesci (ittiologia)','B':'Protezione delle acque, protezione delle specie, ecologia','C':'Attrezzi e tecniche di pesca','D':'Legislazione e protezione degli animali','E':'Valorizzazione alimentare delle catture'}
json.dump({'source':'Netzwerk Anglerausbildung - Questionario 07.2026','sections':sections,'questions':[qs[i] for i in range(1,151)]},open(f'{OUT}/data/questions.json','w'),ensure_ascii=False,indent=1)
print(sum(1 for q in qs.values() if q['image']),'immagini')
print([n for n in qs if qs[n]['image']])
