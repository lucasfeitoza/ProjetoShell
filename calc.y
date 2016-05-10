
%{

#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
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
%token CD_COM
%left T_PLUS T_MINUS
%left T_MULTIPLY T_DIVIDE

%type<ival> expression
%type<fval> mixed_expression
%type<sval> diraux
%type<sval> touchaux

%start command

%%

command : calculation  aux	 
	| lscommand aux		
	| pscommand aux		
	| mkdircommand aux	
	| rmdircommand aux
	| ipcommand aux
	| killcommand aux
	| touchcommand aux
//	| startcommand aux
//	| cdcommand aux
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

rmdircommand: RMDIR_COM diraux T_NEWLINE	 {rmdir($2); }
;

killcommand: KILL_COM T_INT T_NEWLINE 		{kill($2); }
;

touchcommand: TOUCH_COM touchaux T_NEWLINE	{system("touch $2"); }
;

touchaux: T_CHAR	{$$ = $1; }
;

calculation: 
	   | calculation line
;

line: T_NEWLINE
    | mixed_expression T_NEWLINE { printf("\tResult: %f\n", $1);}
    | expression T_NEWLINE { printf("\tResult: %i\n", $1); } 
    | T_QUIT T_NEWLINE { printf("goodbye!\n"); exit(0); }
;

mixed_expression: T_FLOAT                 		 { $$ = $1; }
	  | mixed_expression T_PLUS mixed_expression	 { $$ = $1 + $3; }
	  | mixed_expression T_MINUS mixed_expression	 { $$ = $1 - $3; }
	  | mixed_expression T_MULTIPLY mixed_expression { $$ = $1 * $3; }
	  | mixed_expression T_DIVIDE mixed_expression	 { $$ = $1 / $3; }
	  | T_LEFT mixed_expression T_RIGHT		 { $$ = $2; }
	  | expression T_PLUS mixed_expression	 	 { $$ = $1 + $3; }
	  | expression T_MINUS mixed_expression	 	 { $$ = $1 - $3; }
	  | expression T_MULTIPLY mixed_expression 	 { $$ = $1 * $3; }
	  | expression T_DIVIDE mixed_expression	 { $$ = $1 / $3; }
	  | mixed_expression T_PLUS expression	 	 { $$ = $1 + $3; }
	  | mixed_expression T_MINUS expression	 	 { $$ = $1 - $3; }
	  | mixed_expression T_MULTIPLY expression 	 { $$ = $1 * $3; }
	  | mixed_expression T_DIVIDE expression	 { $$ = $1 / $3; }
	  | expression T_DIVIDE expression		 { $$ = $1 / (float)$3; }
;

expression: T_INT				{ $$ = $1; }
	  | expression T_PLUS expression	{ $$ = $1 + $3; }
	  | expression T_MINUS expression	{ $$ = $1 - $3; }
	  | expression T_MULTIPLY expression	{ $$ = $1 * $3; }
	  | T_LEFT expression T_RIGHT		{ $$ = $2; }
;

%%
int main() {
	yyin = stdin;
	do { 

		yyparse();
	} while(!feof(yyin));
	return 0;
}
void yyerror(const char* s) {
	fprintf(stderr, "Comando Inválido: %s\n", s);
	//exit(1);
	return;
}
