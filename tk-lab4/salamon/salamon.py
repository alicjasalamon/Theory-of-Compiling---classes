#!/usr/bin/python

import sys
import re
import ply.lex as lex
import ply.yacc as yacc

lista=[]
listaPoprawnych=[]
identyfikatory=set()

tokens = (
	'RODZAJ_PUBLIKACJI',
	'WARTOSC_W_CUDZYSLOWIE',
	'WARTOSC',
)

literals = "{},="

def t_RODZAJ_PUBLIKACJI(t):
	r'@\w*'
	t.value = (t.value, t.lexer.lineno)
	return t

def t_WARTOSC_W_CUDZYSLOWIE(t):
	r'"(\n|.)*?"'
	#usun biale znaki z lewej strony
	t.value = re.sub('"\s+', '"', t.value)
	#i z prawej 
	t.value = re.sub('\s+"', '"', t.value)
	#i w srodku
	t.value = re.sub('\s+', ' ', t.value)
	t.value = (t.value, t.lexer.lineno)	
	entery =  re.findall('\n', t.value[0])
	t.lexer.lineno += len(entery)
	return t

def t_WARTOSC(t):
	r'\w+'
	t.value = (t.value, t.lexer.lineno)
	return t

t_ignore = ' \t'

def t_newline(t):
	r'\n+'
	t.lexer.lineno += len(t.value)

def t_error(t) :
	print("blad w lekserze")
	t.lexer.skip(1)

def p_error(p) :
	print("blad w parsingu- token ", p.value[0],", nr linii ", p.lineno )

def p_publications1(p):
	"""publications : publication"""

def p_publications2(p):
	"""publications : publications publication"""

def p_publication(p):
	"""publication : type '{' WARTOSC ',' fields '}'"""
	lista.append((p[1], p[3], p[5]))

def p_fields1(p):
	"""fields : field"""
	krotka = p[1]
	p[0]=	{krotka[0].lower() : krotka[1]}

def p_fields2(p):
	"""fields : fields ',' field"""
	krotka = p[3]
	mapa = p[1]
	if krotka[0].lower() not in mapa:
		mapa[krotka[0].lower()]=krotka[1]
	else:
		print("powtarzajaca sie nazwa pola ", krotka[0].lower() , "w linii", krotka[1][1])
		
	p[0]=mapa

def p_field1(p):
	"""field : WARTOSC '=' WARTOSC_W_CUDZYSLOWIE"""
	p[0]=(p[1][0].lower(),(p[3][0][1:-1],p[1][1]))

def p_field2(p):
	"""field : WARTOSC '=' WARTOSC """
	p[0]=(p[1][0].lower(),(p[3][0],p[1][1]))

def p_type(p):
	"""type : RODZAJ_PUBLIKACJI"""
	p[0]=p[1]


def wyswietl(krotka):
	print('<{}>'.format(krotka[0][0][1:].lower()))
	print('\t<keyword>{}</keyword>'.format(krotka[1][0]))
	for key, value in krotka[2].items():
		print('\t<{}>{}</{}>'.format(key, value[0], key))
	print('</{}>'.format(krotka[0][0][1:].lower()))
	print('\n')

def sprawdzKrotke(krotka):
	ok=1
	if krotka[0][0].lower() != "@book" \
	and krotka[0][0].lower() != "@article" \
	and krotka[0][0].lower() != "@inproceedings" :
		print("niepoprawny rodzaj publikacji",  krotka[0][0], \
		"w linii", krotka[0][1])
		ok= 0
	else:
		if krotka[0][0].lower() == "@book":
			potrzebne={"author", "title", "publisher", "year"}
		if krotka[0][0].lower() == "@article":
			potrzebne={"author", "title", "journal", "year"}
		if krotka[0][0].lower() == "@inproceedings":
			potrzebne={"author", "title", "booktitle", "year"}
		
		for klucz in krotka[2]:
			if klucz in potrzebne:
				potrzebne.remove(klucz)
			else:
				print("niepoprawny typ", klucz , "w linii", krotka[2][klucz][1])
				ok= 0
		
		if len(potrzebne)!=0:
			print("nie podano wymaganych pol, krotka ", krotka[0][1])
			ok= 0

		return ok

def sprawdzIdentyfikatory(krotka):
	if krotka[1][0] in identyfikatory:
		print("powtorzone ID-", krotka[1][0], "w linii",  krotka[1][1] )
		return 0
	else:
		identyfikatory.add(krotka[1][0])
		return 1

def sprawdzListe():
	for krotka in lista:
		wpisz=1
		if sprawdzIdentyfikatory(krotka) != 1:
			wpisz=0
		if sprawdzKrotke(krotka) !=1 :
			wpisz=0
		if wpisz ==1:
			listaPoprawnych.append(krotka)

if len(sys.argv)==1:
	print("brak argumentow, podaj nazwe pliku!")
else:
	file = open(sys.argv[1], "r")

	lexer = lex.lex()
	parser = yacc.yacc()
	text = file.read()
	parser.parse(text, lexer=lexer)

	sprawdzListe()	
	for krotka in listaPoprawnych:
	#	print(krotka)	
		wyswietl(krotka)

