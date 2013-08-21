#include<stdio.h>
#include<string.h>
#include<stdlib.h>

int main(void) 
{
	char a[200] = "dupa";
	char *b = "dupa[100]";

	int z=0;
	while(b[z++]!='[');
	
	printf("a: %s b: %s z: %d\n", a, b, z);
	if(strncmp(a,b,z-1)==0) printf("gra\n");
}

