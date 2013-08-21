/* Alicja Salamon
	grupa 15.30 - 17.00 */

%option noyywrap

%{
#include "salamon_aksamit.tab.h"
#include <string.h>
#include <stdlib.h>

char cialo[10000];
int licznik=0;
%}


%x BODY
%%

"void"			return VOID;
"char"			return CHAR;
"short"			return SHORT;
"int"			return INT;
"long"			return LONG;
"float"			return FLOAT;
"struct"		return STRUCT;
"enum"			return ENUM;
[a-zA-Z_][a-zA-Z0-9_]*  {
			yylval.string = strdup(yytext); 
			return IDENTYFIKATOR;
			}
[0-9]*			{
			yylval.string = strdup(yytext); 
			return LICZBA;
			}
			
[()\[\]*,;]		return yytext[0];
"}"			{
				printf("wystapil blad: zle nawiasy\n");
			}
"{"			{
				BEGIN(BODY);
				licznik++;
			}
<BODY>"}"		{
			licznik--;
			if(licznik==0)
			{
				yylval.string = strdup(cialo);
				BEGIN(INITIAL);
				strcpy(cialo,"");

				return CIALO;
			}
			else strcat(cialo, yytext);
			}
<BODY>"//".*			strcat(cialo, yytext);
<BODY>"/*"([^*]|\*[^/])*"*/"	strcat(cialo, yytext);	
<BODY>\".*\"			strcat(cialo, yytext);	
<BODY>"{"		{
				licznik++;
				strcat(cialo, yytext);
			}
<BODY>(.|\n)			strcat(cialo, yytext);
(.|\n)			;

%%

