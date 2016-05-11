
%{
#include <stdio.h>
#include <string.h>

#define YY_DECL int yylex()

#include "Mshel.tab.h"

%}
%option noyywrap
%%

[ \t]	; 
[0-9]+\.[0-9]+ 		{yylval.fval = atof(yytext); return T_FLOAT;}
[0-9]+			{yylval.ival = atoi(yytext); return T_INT;}
\n			{term(); return T_NEWLINE;}
"+"			{return T_PLUS;}
"-"			{return T_MINUS;}
"*"			{return T_MULTIPLY;}
"/"			{return T_DIVIDE;}
"("			{return T_LEFT;}
")"			{return T_RIGHT;}
"quit"			{return T_QUIT;}
"ls"			{return LS_COM;}
"ps"			{return PS_COM;}
"mkdir"			{return MKDIR_COM;}
"rmdir"			{return RMDIR_COM;}
"kill"			{return KILL_COM;}
"ifconfig"		{return IP_COM;}
"touch"			{return TOUCH_COM;}
"start"			{return START_COM;}
"cd"			{yylval.sval = strdup(yytext); return CD_COM;}
[A-Za-z0-9/\.]+		{yylval.sval = strdup(yytext); return T_CHAR;}
%%
