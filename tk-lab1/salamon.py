import os
import sys
import re

def processFile(filepath):
    fp = open(filepath, 'rU')
    content = fp.read()

    #autor
    autor = ""
    pattern = r'<META NAME="AUTOR" CONTENT="(.*?)">'
    r = re.compile(pattern)
    m = r.search(content)
    if(m):
        autor = m.group(1)

    #dzial
    dzial = ""
    pattern = r'<META NAME="DZIAL" CONTENT="gazeta/(.*?)">'
    r = re.compile(pattern)
    m = r.search(content)
    if(m):
        dzial = m.group(1)  
        
    #slowa kluczowe
    slowaKLuczowe = ""
    pattern = r'<META NAME="KLUCZOWE_\d" CONTENT="(.*?)">'
    r = re.compile(pattern)
    m = r.finditer(content)
    for slowoKluczowe in m:
        slowaKLuczowe = slowaKLuczowe + " " +slowoKluczowe.group(1)
                
    #content2, zeby szukac pomiedzy pierwszym <P> i pierwszym <META>
    content2 = ""
    pattern = r'(<P(.*?)>)(?P<srodek>(.|\n)*?)(<META(.*?)>)'
    r = re.compile(pattern)
    m = r.search(content)
    if(m):
        content2 = m.group('srodek') 
         
    #wycinanie znacznikow
    pattern = r'<(.)*?>'
    r = re.compile(pattern)
    content2 = r.sub("", content2)
        
    #liczby zmiennoprzecinkowe
    zbiorLiczbZmiennoprzecinkowych = set()
    pattern = r'\b(\d+, \d+)\b'
    r = re.compile(pattern)
    m = r.finditer(content2)
    for liczbaZmiennoprzecinkowa in m:
        zbiorLiczbZmiennoprzecinkowych.add(liczbaZmiennoprzecinkowa.group(1))
   
    #usuniecie liczb zmiennoprzecinkowych   
    content2 = r.sub("", content2)
    
    #adresy mailowe
    zbiorAdresowMailowych = set()
    pattern = r'\b(?P<mail>\w+(.w+)*@\w+(.\w+)+)\b'
    r = re.compile(pattern)
    m = r.finditer(content2)
    for adresMailowy in m:
        zbiorAdresowMailowych.add(adresMailowy.group('mail'))
     
    #usuniecie adresow mailowych   
    content2 = r.sub("", content2)
    
    #skroty
    zbiorSkrotow = set()
    pattern = r'\b(?P<skrot>[a-zA-Z]{1,3}\.)'
    r = re.compile(pattern)
    m = r.finditer(content2)
    for skrot in m:
        zbiorSkrotow.add(skrot.group('skrot'))
     
    #usuniecie skrotow 
    content2 = r.sub("", content2)   
    
    #daty
    zbiorDat = set()
    pattern = r'''
    (?P<dzienA>
        (?P<dzien31A>31)
        |(?P<dzien30A>30)
        |(?P<dzien29A>0[1-9]|[12][0-9]) 
    )   
    (?P<separatorA>[\./-])
    (?P<miesiacA>              
        (?(dzien31A)
        (?P<miesiac31A>01|03|05|07|08|10|12)
        )
        (?(dzien30A)
        (?P<miesiac30A>0[13456789]|10|11|12)
        )
        (?(dzien29A)
        (?P<miesiac29A>0[1-9]|10|11|12)
        )
    )
    (?P=separatorA)
    (?P<rokA>(\d){4})
    |
    (?P<rokB>(\d){4})
    (?P<separatorB>[\./-])
    (?P<dzienB>
        (?P<dzien31B>31)
        |(?P<dzien30B>30)
        |(?P<dzien29B>0[1-9]|[12][0-9]) 
    )   
    (?P=separatorB)
    (?P<miesiacB>              
        (?(dzien31B)
        (?P<miesiac31B>01|03|05|07|08|10|12)
        )
        (?(dzien30B)
        (?P<miesiac30B>0[13456789]|10|11|12)
        )
        (?(dzien29B)
        (?P<miesiac29B>0[1-9]|10|11|12)
        )
    )
    '''
    r = re.compile(pattern, re.X)
    m = r.finditer(content2)
    for data in m:
        zbiorDat.add(( data.group('dzienA') if data.group('dzienA') else data.group('dzienB'),
                         data.group('miesiacA') if data.group('miesiacA') else data.group('miesiacB'), 
                         data.group('rokA') if data.group('rokA') else data.group('rokB')))
        
    #usuniecie dat
    content2 = r.sub("", content2) 
        
    #liczby calkowite
    zbiorLiczbCalkowitych = set()
    pattern = r'''
    (-?)              # mamy - albo nie
    (?P<liczba>
    (\d){1,4}         # liczba 4-cyfrowa
    |[12](\d){4}      # 5 cyfrowa zaczynajaca sie od 1 lub 2
    |3[01](\d){3}     # 5 cyfrowa z 3 na poczatku
    |32[0-6](\d){2}   # 5 cyfrowa z 32 na poczatku
    |327[0-5]\d       # 5 cyfrowa z 327 na poczatku
    |3276[0-7]        # 5 cyfrowa, ale nie 32768
    |(?(1)32768)      # -32768
    )
    '''
    r = re.compile(pattern, re.X)
    m = r.finditer(content2)
    for liczbaCalkowita in m:
        zbiorLiczbCalkowitych.add(liczbaCalkowita.group('liczba'))
    
    #zdania
    listaZdan = []
    pattern = r'(?P<zdanie>(.)+?([.?!]+|\n))'
    r = re.compile(pattern)
    m = r.finditer(content2)
    for zdanie in m:
        listaZdan.append(zdanie.group('zdanie'))
        #print(zdanie.group('zdanie'))
    
    fp.close()
    print("nazwa pliku:" + " "+ filepath)
    print("autor:" + " " + autor)
    print("dzial:" + " " + dzial)
    print("slowa kluczowe:" + slowaKLuczowe)
    print("liczba zdan:" + str(listaZdan.__len__()))
    print("liczba skrotow:"  + " " + str(len(zbiorSkrotow)))
    print("liczba liczb calkowitych z zakresu int:" + " " + str(len(zbiorLiczbCalkowitych)))
    print("liczba liczb zmiennoprzecinkowych:" + " " + str(len(zbiorLiczbZmiennoprzecinkowych)))
    print("liczba dat:" + " " + str(len(zbiorDat)))
    print("liczba adresow email:" + " " + str(len(zbiorAdresowMailowych)))
    print("\n")



try:
    path = sys.argv[1]
except Exception:
    print("Brak podanej nazwy katalogu")
    sys.exit(0)


tree = os.walk(path)

for root, dirs, files in tree:
    for f in files:
        if f.endswith(".html"):
            filepath = os.path.join(root, f)
            processFile(filepath)


