#include <stdio.h>

int printhead() { printf("<section><h2>Tabla ASCII</h2>\n<table style=\"border-collapse: collapse; border:1px; width: 100%; font-size: 22px; \">\n"); }
int printtail() { printf("\n</table>\n</section>\n"); }
int printrowbegin() { printf("<tr>\n"); }
int printrowend() { printf("</tr>\n"); }
int printcell(int c) { 
	char *bg;

	bg = "#EEEEEE";
	if('A' <= c && c <= 'Z') bg = "#EEFF00";
	if('a' <= c && c <= 'z') bg = "#FFCC00";
	if('0' <= c && c <= '9') bg = "#00EEFF";
	printf("<td align=\"right\" style=\"background-color: %s;\">%d</td><td align=\"center\" style=\"background-color: %s;\">%c</td> ", bg, c, bg, c); 
}

main()
{
	int i,j;
	int c = 32;
	int J = 8; // cols
	int I;

	I = (127-31)/J; // rows

	printhead();
	for(i=0; i<I; i++) {
		printrowbegin();
		for(j=0; j<J; j++) {
			c = 32 + i + I  *  j;
			//if(c == 127) goto chau;
			printcell(c);
			//printf("%3d %c   ",c,c);
		}
		printrowend();
		puts("");
	}
chau:   printtail();
}
