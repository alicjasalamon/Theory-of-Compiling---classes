%{

#include<stdio.h>
#include<string.h>
#include<stdlib.h>

int yylex(void); 
int yyerror(const char* s); 

struct parametr{
	char typ[256];
	char nazwa[256];
};

struct funkcja{
	char typ[256];
	char nazwa[256];
	int ileParametrow;
	struct parametr parametry[256];
	char cialo[10000];
};


struct funkcja tablicaFunkcji[1000];
int ileFunkcji=0;

struct funkcja biezacaFunkcja;
struct parametr biezacyParametr;

char* przygotowaneParametry[1000];
int ilePrzygotowanychParametrow=0;
int ileWpisanychParametrow=0;

int wystapilBlad=0;

void wstawFunkcjeDoTablicy()
{
	int i = ileFunkcji; 
	strcpy(tablicaFunkcji[i].typ, biezacaFunkcja.typ);
	strcpy(tablicaFunkcji[i].nazwa, biezacaFunkcja.nazwa);
	tablicaFunkcji[i].ileParametrow = biezacaFunkcja.ileParametrow;
	int j;
	for(j=0; j< biezacaFunkcja.ileParametrow; j++)
	{
		strcpy(tablicaFunkcji[i].parametry[j].typ, biezacaFunkcja.parametry[j].typ);
		strcpy(tablicaFunkcji[i].parametry[j].nazwa, biezacaFunkcja.parametry[j].nazwa);
	}
	strcpy(tablicaFunkcji[i].cialo, biezacaFunkcja.cialo);
	ileFunkcji++;
}

void wstawParametryDoFunkcji()
{	
	int i;
	int ok = 1;

	for(i=0; i<biezacaFunkcja.ileParametrow; i++)
	{
		if(strcmp(biezacyParametr.nazwa, biezacaFunkcja.parametry[i].nazwa)==0)
			ok = 0;
	}
	
	if(ok==1)
	{
		strcpy(biezacaFunkcja.parametry[biezacaFunkcja.ileParametrow].typ, biezacyParametr.typ);
		strcpy(biezacaFunkcja.parametry[biezacaFunkcja.ileParametrow].nazwa, biezacyParametr.nazwa);
		biezacaFunkcja.ileParametrow++;
	}
	else
	{
		printf("wystapil blad: powtorzenie parametru o tej samej nazwie\n");
		wystapilBlad=1;		
	}
}

void wstawPrzygotowaneParametryDoFunkcji()
{
	int i, j,z, o, ok=0;

	if(biezacaFunkcja.ileParametrow >= ileWpisanychParametrow+ilePrzygotowanychParametrow)
	{
		for(j=0; j<ilePrzygotowanychParametrow; j++)
		{
			for(i=0; i<biezacaFunkcja.ileParametrow; i++)
			{	
				z=0;
				while(przygotowaneParametry[j][z]!='[' && przygotowaneParametry[j][z]!='\0') z++;
				o=0;
				while(przygotowaneParametry[j][o]=='*') o++;

				if(strncmp(przygotowaneParametry[j]+o,biezacaFunkcja.parametry[i].nazwa,z)==0)
				{
					strcpy(biezacaFunkcja.parametry[i].typ, biezacyParametr.typ);
					strcpy(biezacaFunkcja.parametry[i].nazwa, przygotowaneParametry[j]);
				}
			}
		}
		ileWpisanychParametrow += ilePrzygotowanychParametrow;
	}
	else
	{
		printf("wystapil blad: niezgodnosc parametrow na liscie identyfikatorow z lista deklaracji\n");
		wystapilBlad=1;
	}
	ilePrzygotowanychParametrow=0;
}


void wstawGotoweParametryDoFunkcji()
{	
	int i;
	int ok = 1;
	if(strcmp(biezacyParametr.nazwa, "")!=0)
	{
		for(i=0; i<biezacaFunkcja.ileParametrow; i++)
		{
			if(strcmp(biezacyParametr.nazwa, biezacaFunkcja.parametry[i].nazwa)==0)
				ok = 0;
		}
	}
	
	if(ok==1)
	{
		strcpy(biezacaFunkcja.parametry[biezacaFunkcja.ileParametrow].typ, biezacyParametr.typ);
		strcpy(biezacaFunkcja.parametry[biezacaFunkcja.ileParametrow].nazwa, biezacyParametr.nazwa);
		biezacaFunkcja.ileParametrow++;

	}
	else
	{
		printf("wystapil blad: powtorzenie parametru o tej samej nazwie\n");
		wystapilBlad=1;		
	}
}

void sprawdzParametry()
{
	int i;
	int ok = 1;
	for(i=0; i<biezacaFunkcja.ileParametrow; i++)
	{
		if(strcmp(biezacaFunkcja.parametry[i].typ, "podaj")==0)
		{
			ok = 0;
		}
	}
	
	if(ok==0)
	{
		wystapilBlad=1;
		printf("wystapil blad: nie podano wystarczajacej liczby deklaracji %s \n ", biezacaFunkcja.nazwa);
	}
}

%}

%union {
char* string;
}

%token <string> IDENTYFIKATOR LICZBA VOID CHAR SHORT INT LONG FLOAT STRUCT ENUM CIALO

%type <string> functions function decl_specifier declaration_list declaration declarator_list declarator
%type <string> identifier_list param_list param_declaration abstract_declarator direct_abstract_declarator 
%type <string> direct_declarator pointer body
%%


functions 	
		: functions function {
			sprawdzParametry();
			if(wystapilBlad==0) wstawFunkcjeDoTablicy();
			biezacaFunkcja.ileParametrow=0;
			ileWpisanychParametrow=0;
			wystapilBlad=0;
			}
		| function {
			sprawdzParametry();
			if(wystapilBlad==0) wstawFunkcjeDoTablicy();
			biezacaFunkcja.ileParametrow=0;
			ileWpisanychParametrow=0;
			wystapilBlad=0;
			}
		;

function 	
		: decl_specifier declarator declaration_list body {
			strcpy(biezacaFunkcja.typ, $1);
			}
		| declarator declaration_list body {
			strcpy(biezacaFunkcja.typ, "int");
			}
		| decl_specifier declarator body {
			strcpy(biezacaFunkcja.typ, $1);
			}
		| declarator body {
			strcpy(biezacaFunkcja.typ, "int");
			}
		;

decl_specifier 	
		: VOID 			{$$=strdup("void");}
		| CHAR			{$$=strdup("char");}
		| SHORT			{$$=strdup("short");}
		| INT			{$$=strdup("int");}
		| LONG			{$$=strdup("long");}
		| FLOAT			{$$=strdup("float");}
		| STRUCT IDENTYFIKATOR	{
				char cos[1024] = "struct ";
				strcat(cos, $2);
				$$ = strdup(cos);
				}
		| ENUM IDENTYFIKATOR{
				char cos2[1024] = "enum ";
				strcat(cos2, $2);
				$$ = strdup(cos2);
				}
		;

declaration_list 
		: declaration_list declaration 
		| declaration
		;

declaration	
		: decl_specifier declarator_list ';' {
			strcpy(biezacyParametr.typ, $1);
			wstawPrzygotowaneParametryDoFunkcji();
			}
		| decl_specifier ';' {
			strcpy(biezacyParametr.typ, $1);
			wstawPrzygotowaneParametryDoFunkcji();
			}	
		;

declarator_list 
		: declarator {
			int m = ilePrzygotowanychParametrow;
			przygotowaneParametry[m] = $1;
			ilePrzygotowanychParametrow++;			
			}
		| declarator_list ',' declarator {
			int m = ilePrzygotowanychParametrow;
			przygotowaneParametry[m] = $3;
			ilePrzygotowanychParametrow++;
			}
		;

declarator 	
		: pointer direct_declarator {
			int n = strlen($1) + strlen($2);
			char* bufor =(char*) calloc(n+1,sizeof(char));
			strcat(bufor,$1);
			strcat(bufor,$2);
			free($1);
			free($2);
			$$ = bufor;
			}
		| direct_declarator
		;

direct_declarator 
		: IDENTYFIKATOR
		| '(' declarator ')' { $$ = $2; }
		| direct_declarator '[' LICZBA ']' {
			int n = strlen($1) + strlen($3);
			char* bufor =(char*) calloc(n+3,sizeof(char));
			strcat(bufor,$1);
			strcat(bufor,"[");
			strcat(bufor,$3);
			strcat(bufor,"]");
			free($1);
			free($3);
			$$ = bufor;
			}
		| direct_declarator '[' ']' {
			int n = strlen($1);
			char* bufor =(char*) calloc(n+3,sizeof(char));
			strcat(bufor,$1);
			strcat(bufor,"[]");
			free($1);
			$$ = bufor;
			}
		| direct_declarator '(' param_list ')' {
			int n = strlen($1) + strlen($3);
			char* bufor =(char*) calloc(n+3,sizeof(char));
			strcat(bufor,$1);
			strcat(bufor,"(");
			strcat(bufor,$3);
			strcat(bufor,")");
			strcpy(biezacaFunkcja.nazwa, $1);
			free($1);
			free($3);
			$$ = bufor;
			}
		| direct_declarator '(' identifier_list ')' {
			int n = strlen($1) + strlen($3);
			char* bufor =(char*) calloc(n+3,sizeof(char));
			strcat(bufor,$1);
			strcat(bufor,"(");
			strcat(bufor,$3);
			strcat(bufor,")");
			strcpy(biezacaFunkcja.nazwa, $1);
			free($1);
			free($3);
			$$ = bufor;
			}
		| direct_declarator '('  ')' {
			int n = strlen($1);
			char* bufor =(char*) calloc(n+3,sizeof(char));
			strcat(bufor,$1);
			strcat(bufor,"()");
			strcpy(biezacaFunkcja.nazwa, $1);
			free($1);
			$$ = bufor;
			}
		;
    
identifier_list	
		: IDENTYFIKATOR	{
			strcpy(biezacyParametr.nazwa, $1);
			strcpy(biezacyParametr.typ, "podaj");
			wstawParametryDoFunkcji();
			}
		| identifier_list ',' IDENTYFIKATOR {
			strcpy(biezacyParametr.nazwa, $3);
			strcpy(biezacyParametr.typ, "podaj");
			wstawParametryDoFunkcji();
			}
		;

param_list	
		: param_declaration 
		| param_list ',' param_declaration
		;

param_declaration 
		: decl_specifier declarator {
			strcpy(biezacyParametr.nazwa, $2);
			strcpy(biezacyParametr.typ, $1);
			wstawGotoweParametryDoFunkcji();
			}
 		| decl_specifier abstract_declarator {
			strcpy(biezacyParametr.nazwa, "");
			strcpy(biezacyParametr.typ, $1);
			wstawGotoweParametryDoFunkcji();
			}
 		| decl_specifier{
			strcpy(biezacyParametr.nazwa, "");
			strcpy(biezacyParametr.typ, $1);
			wstawGotoweParametryDoFunkcji();
		}
		;

abstract_declarator 
		: pointer
		| pointer direct_abstract_declarator {
			int n = strlen($1) + strlen($2);
			char* bufor =(char*) calloc(n+1,sizeof(char));
			strcat(bufor,$1);
			strcat(bufor,$2);
			free($1);
			free($2);
			$$ = bufor;
			}
		| direct_abstract_declarator
		;

direct_abstract_declarator 
		: '(' abstract_declarator ')' {
			int n = strlen($2);
			char* bufor =(char*) calloc(n+3,sizeof(char));
			bufor[0] = '(';
			strcat(bufor, $2);
			bufor[n+1] = ')';
			free($2);
			$$ = bufor;
			}	
		| direct_abstract_declarator '[' LICZBA ']' {
			int n = strlen($1) + strlen($3);
			char* bufor =(char*) calloc(n+3,sizeof(char));
			strcat(bufor,$1);
			strcat(bufor,"[");
			strcat(bufor,$3);
			strcat(bufor,"]");
			free($1);
			free($3);
			$$ = bufor;
			}
		| '[' LICZBA ']' {
			int n = strlen($2);
			char* bufor =(char*) calloc(n+3,sizeof(char));
			bufor[0] = '[';
			strcat(bufor, $2);
			bufor[n+1] = ']';
			free($2);
			$$ = bufor;
			}			
		| direct_abstract_declarator '[' ']' {
			int n = strlen($1);
			char* bufor =(char*) calloc(n+3,sizeof(char));
			strcat(bufor, $1);
			bufor[n] = '[';
			bufor[n+1] = ']';
			free($1);
			$$ = bufor;
			}	
		| '[' ']' {
			$$ = strdup("[]");
			}		
		| direct_abstract_declarator '(' param_list ')' {
			int n = strlen($1) + strlen($3);
			char* bufor =(char*) calloc(n+3,sizeof(char));
			bufor[0] = '(';
			strcat(bufor,$1);
			strcat(bufor,")");
			strcat(bufor,$3);
			free($1);
			free($3);
			$$ = bufor;
			}
		| '(' param_list ')' {
			int n = strlen($2);
			char* bufor =(char*) calloc(n+3,sizeof(char));
			bufor[0] = '(';
			strcat(bufor,$2);
			bufor[n+1] = ')';
			free($2);
			$$ = bufor;
			}
		| direct_abstract_declarator '(' ')' {
			int n = strlen($1);
			char* bufor =(char*) calloc(n+3,sizeof(char));
			bufor[n] = '(';
			bufor[n+1] = ')';
			free($1);
			$$ = bufor;
			}	
		| '(' ')' {
			$$ = strdup("()");
			}
		;
                      
pointer 	
		: '*' {$$ = strdup("*");}
		| pointer '*' {
			int n = strlen($1);
			char* bufor =(char*) calloc(n+2,sizeof(char));
			strcat(bufor, $1);
			bufor[n] = '*';
			free($1);
			$$ = bufor;
			}
		;

body		
		: CIALO	{
			strcpy(biezacaFunkcja.cialo, $$);
			}
		;

%%

int main(void) 
{
	biezacaFunkcja.ileParametrow=0;
	yyparse();
	
	int i,j;
	for(i=0; i<ileFunkcji; i++)
	{
		printf("%s ", tablicaFunkcji[i].typ);
		printf("%s(", tablicaFunkcji[i].nazwa);
		
		if(tablicaFunkcji[i].ileParametrow==0)
			printf("void)");
		else
		{
			for(j=0; j<tablicaFunkcji[i].ileParametrow-1; j++)
			{
				printf("%s ", tablicaFunkcji[i].parametry[j].typ);
				printf("%s, ", tablicaFunkcji[i].parametry[j].nazwa);
			}
			j=tablicaFunkcji[i].ileParametrow-1;
			printf("%s ", tablicaFunkcji[i].parametry[j].typ);
			printf("%s)\n", tablicaFunkcji[i].parametry[j].nazwa);
		}
		printf("{%s}\n\n", tablicaFunkcji[i].cialo);
	}
	return 0;  
}

int yyerror(const char* s) {
    printf("blad: %s\n", s);
}
