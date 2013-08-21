/* Alicja Salamon 
Zadanie 2 - grupa 15:30-17:00.*/
%option noyywrap
%option yylineno
%{
#include <string.h>

struct strukturka{
	int port;
	char nazwa[256];
	int tcp_icmp;	
};

struct wszystkieDane{
	int portZrodlowy;
	int portDocelowy;
	char adresZrodlowy[256];
	char adresDocelowy[256];
	int tcp_icmp;
};


struct strukturka tablica[500];
char *uzytkownik;
int ile=0;
struct wszystkieDane tmp;

void wstaw(struct strukturka* str)
{
	int i;
	for(i=0; i<ile;i++){

		if(tablica[i].tcp_icmp==0){
			if(tablica[i].port==str->port &&
			strcmp(tablica[i].nazwa,str->nazwa)==0)
			return;
		}
		else{
			if(strcmp(tablica[i].nazwa,str->nazwa)==0)
			return;
		}
	}

	tablica[i]=*str;
	ile++;
}

void sprawdzIStworz()
{
	struct strukturka nowa;
	if(strcmp(uzytkownik,tmp.adresZrodlowy)==0){
		strcpy(nowa.nazwa,tmp.adresDocelowy);
		nowa.port=tmp.portDocelowy;
		}
	else if(strcmp(uzytkownik,tmp.adresDocelowy)==0){
		strcpy(nowa.nazwa,tmp.adresZrodlowy);
		nowa.port=tmp.portZrodlowy;
		}
	nowa.tcp_icmp=tmp.tcp_icmp;
	wstaw(&nowa);

}

%}

GODZINA		0[0-9]|1[0-9]|2[0-3]
SEC_MIN		[0-5][0-9]
MILISEC		[0-9]{6}
TIMESTAMP	{GODZINA}":"{SEC_MIN}":"{SEC_MIN}"."{MILISEC}

BAJT		[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|24[0-5]
IP		{BAJT}"."{BAJT}"."{BAJT}"."{BAJT}

SLOWO		[a-zA-Z]([a-zA-Z0-9])*

%x CHCE_IP
%x CHCE_ADRES
%x CHCE_TYP

%x LACZNIK_TCP
%x TCP_ADRES
%x TCP_PORT
%x TCP_KONIEC

%x LACZNIK_ICMP
%x ICMP_ADRES
%x ICMP
%x ICMP_PORT
%x ICMP_KONIEC

%x ERROR_TIMESTAMP
%x ERROR_ADRES1
%x ERROR_ADRES2
%x ERROR_PORT
%x ERROR

%%

<*><<EOF>>		{ 
			printf("\n");
			yyterminate();	
			}

<INITIAL>^{TIMESTAMP} 	{
			//printf("\n");
			BEGIN(CHCE_IP);
			}

<INITIAL>.		BEGIN(ERROR_TIMESTAMP);	

<CHCE_IP>" "IP" "	{
			//printf(" IP ");
			BEGIN(CHCE_ADRES);
			}

<CHCE_IP>" "arp.*\n 	{
			//printf("ARP");
			BEGIN(INITIAL);
			}

<CHCE_IP>.		BEGIN(ERROR);	

<CHCE_ADRES>({SLOWO}("."{SLOWO})*)|{IP} {
			//printf("%s", yytext);
			strcpy(tmp.adresZrodlowy, yytext);
			BEGIN(CHCE_TYP);
			}

<CHCE_ADRES>.		BEGIN(ERROR_ADRES1);	

<CHCE_TYP>"."([0-9])*   {
			if(atoi(yytext+1)<=65535)
			{
			//	printf(" TCP %d", atoi(yytext+1));
				BEGIN(LACZNIK_TCP);
				tmp.tcp_icmp=0;
				tmp.portZrodlowy=atoi(yytext+1);
			}
			else
			BEGIN(ERROR_ADRES1);
			}

<CHCE_TYP>" "      	{
			//printf(" IMCP ");
			tmp.tcp_icmp=1;
			BEGIN(LACZNIK_ICMP);
			}

<CHCE_TYP>.		BEGIN(ERROR);


<LACZNIK_TCP>" "">"" "	{
			//printf(" > ");
			BEGIN(TCP_ADRES);
			}

<LACZNIK_TCP>.		BEGIN(ERROR);

<TCP_ADRES>{IP}|({SLOWO}("."{SLOWO})*)	{
			//printf("%s", yytext);
			strcpy(tmp.adresDocelowy,yytext);
			BEGIN(TCP_PORT);
			}

<TCP_ADRES>.		BEGIN(ERROR_ADRES2);

<TCP_PORT>"."([0-9])*	{
			if(atoi(yytext+1)<=65535)
			{
		//		printf(" %d ", atoi(yytext+1));
				tmp.portDocelowy=atoi(yytext+1);
				BEGIN(TCP_KONIEC);
			}
			else
			BEGIN(ERROR_PORT);
			}

<TCP_PORT>.		BEGIN(ERROR_PORT);

<TCP_KONIEC>":".*\n	{
			//printf(" koniec1");
			BEGIN(INITIAL);
			sprawdzIStworz();
			}

<TCP_KONIEC>.		BEGIN(ERROR);

<LACZNIK_ICMP>">"" "	{
		//	printf(">");
			BEGIN(ICMP_ADRES);
			}

<LACZNIK_ICMP>.		BEGIN(ERROR);

<ICMP_ADRES>{IP}|({SLOWO}("."{SLOWO})*)	{
		//	printf(" %s", yytext);
			strcpy(tmp.adresDocelowy,yytext);
			BEGIN(ICMP);
			}

<ICMP_ADRES>.		BEGIN(ERROR_ADRES2);

<ICMP>": "icmp" "	{
			BEGIN(ICMP_PORT);
			}

<ICMP>.			BEGIN(ERROR);

<ICMP_PORT>([0-9])*	{
			if(atoi(yytext)<=65535)
			{
		//		printf(" %d ", atoi(yytext));
		//		tmp.portDocelowy=atoi(yytext);
				BEGIN(ICMP_KONIEC);
			}
			else
			BEGIN(ERROR_PORT);
			}

<ICMP_PORT>.		BEGIN(ERROR_PORT);

<ICMP_KONIEC>": ".*\n	{
			//printf(" koniec2");
			BEGIN(INITIAL);
			sprawdzIStworz();
			}

<ICMP_KONIEC>.		BEGIN(ERROR);

<ERROR_TIMESTAMP>.*\n	{
			printf("niepoprawny format timestampu, l. %d", yylineno);
			BEGIN(INITIAL);
			}

<ERROR_ADRES1>.*\n	{
			printf("niepoprawny adres nadawcy, l. %d", yylineno);
			BEGIN(INITIAL);
			}

<ERROR_ADRES2>.*\n	{
			printf("niepoprawny adres odbiorcy, l. %d", yylineno);
			BEGIN(INITIAL);
			}

<ERROR_PORT>.*\n	{
			printf("niepoprawny nr portu, l. %d", yylineno);
			BEGIN(INITIAL);
			}

<ERROR>.*\n		{
			printf("cos niedobrego, l. %d", yylineno);
			BEGIN(INITIAL);
			}

<*>\n			BEGIN(INITIAL);

%%

int main(int argc, char **argv)
{
   	 ++argv, --argc;  /* skip over program name */
	if ( argc == 2 )
	{
	uzytkownik=argv[0];
	yyin = fopen( argv[1], "r" );
	}
	else
	{
		printf("prosze podac argumenty: nazwaUzytkownika plik\n");
		return;
	}
    	yylex();

	int j;
	for(j=0; j<=ile-1;j++)
	{
		printf("%s", tablica[j].nazwa);
		if(tablica[j].tcp_icmp==0)
			printf(" tcp %d\n", tablica[j].port);
		else
			printf(" icmp\n");
		
	}
    return 0;
}

