
%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;
extern char * yytext;

void yyerror(const char* s);
void cd(char *);

%}

%union {
	int ival;
	float fval;
	char *sval;
}

%token<ival> T_INT
%token<fval> T_FLOAT
%token<sval> T_CHAR
%token T_PLUS T_MINUS T_MULTIPLY T_DIVIDE T_LEFT T_RIGHT
%token T_NEWLINE T_QUIT
%token LS_COM
%token PS_COM
%token IP_COM
%token MKDIR_COM

%token RMDIR_COM
%token KILL_COM
%token TOUCH_COM
%token START_COM
%token<sval> CD_COM
%left T_PLUS T_MINUS
%left T_MULTIPLY T_DIVIDE

%type<ival> expression
%type<fval> expression_f
%type<sval> diraux
%type<sval> cdcommand
%type<sval> cdcommandaux

%start command

%%

command : calculator  aux	 
	| lscommand aux		
	| pscommand aux		
	| mkdircommand aux	
	| rmdircommand aux
	| ipcommand aux
	| killcommand aux
//	| touchcommand aux
//	| startcommand aux
	| cdcommand aux
;

aux: command 
   | T_QUIT { printf("goodbye!\n"); exit(0); }
;

lscommand: LS_COM T_NEWLINE {system("ls"); }
;

pscommand: PS_COM T_NEWLINE {system("ps"); }
;

ipcommand: IP_COM T_NEWLINE {system("ifconfig"); }
;

mkdircommand: MKDIR_COM diraux T_NEWLINE {mkdir($2);  }
;

diraux: T_CHAR	{$$ = $1; }
;

rmdircommand: RMDIR_COM diraux T_NEWLINE	{rmdir($2); }
;

cdcommand: CD_COM cdcommandaux T_NEWLINE	{cd($2); }
;

cdcommandaux: T_CHAR	{$$ = $1; }
;

killcommand: KILL_COM T_INT T_NEWLINE 		{kill($2,0); }
;

/*touchcommand: TOUCH_COM touchaux  T_NEWLINE	{char* s=malloc(sizeof(char)*(strlen($1)+strlen($2)+1));
	                						strcpy(s,$1); 
	                						strcat(s," ");
	                						strcat(s,$2);      		                						system(s);
						}	
;

touchaux: T_CHAR {$$ = $1;}*/

calculator: 
	   | calculator line
;

line: T_NEWLINE
    | expression_f T_NEWLINE { printf("\tResult: %f\n", $1);}
    | expression T_NEWLINE { printf("\tResult: %i\n", $1); } 
    | T_QUIT T_NEWLINE { printf("goodbye!\n"); exit(0); }
;

expression_f: T_FLOAT                 		 { $$ = $1; }
	  | expression_f T_PLUS expression_f	 { $$ = $1 + $3; }
	  | expression_f T_MINUS expression_f	 { $$ = $1 - $3; }
	  | expression_f T_MULTIPLY expression_f { $$ = $1 * $3; }
	  | expression_f T_DIVIDE expression_f	 { $$ = $1 / $3; }
	  | T_LEFT expression_f T_RIGHT		 { $$ = $2; }
	  | expression T_PLUS expression_f	 { $$ = $1 + $3; }
	  | expression T_MINUS expression_f	 { $$ = $1 - $3; }
	  | expression T_MULTIPLY expression_f 	 { $$ = $1 * $3; }
	  | expression T_DIVIDE expression_f	 { $$ = $1 / $3; }
	  | expression_f T_PLUS expression	 { $$ = $1 + $3; }
	  | expression_f T_MINUS expression	 { $$ = $1 - $3; }
	  | expression_f T_MULTIPLY expression 	 { $$ = $1 * $3; }
	  | expression_f T_DIVIDE expression	 { $$ = $1 / $3; }
	  | expression T_DIVIDE expression	 { $$ = $1 / (float)$3; }
;

expression: T_INT				{ $$ = $1; }
	  | expression T_PLUS expression	{ $$ = $1 + $3; }
	  | expression T_MINUS expression	{ $$ = $1 - $3; }
	  | expression T_MULTIPLY expression	{ $$ = $1 * $3; }
	  | T_LEFT expression T_RIGHT		{ $$ = $2; }
;
%%

void cd(char *c) {
  char dir[1024];
  char res[2048];
  if (getcwd(dir, sizeof(dir))==NULL) {
    perror("Error getcwd()");
  }
  sprintf(res, "%s/%s", dir, c);
  if(chdir(res) != 0) {
    fprintf(stderr, "Error  cd()\n");
  }
}



void term(){
FILE *l = popen("pwd", "r");
	char c[256];	
	fgets(c, sizeof(c), l);
	pclose(l);
	strtok(c, "\n");
	printf("MShell:%s>>",c);
}



int main() {
	yyin = stdin;
	
	do { 
		term();
		yyparse();
	} while(!feof(yyin));
	return 0;
}
void yyerror(const char* s) {
	fprintf(stderr, "Comando Inválido: ");
	return;
}
