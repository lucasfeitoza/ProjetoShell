
%{
#include <stdio.h>
#include <string.h>

#define YY_DECL int yylex()

#include "calc.tab.h"

%}
%option noyywrap
%%

[ \t]	; // ignore all whitespace
[0-9]+\.[0-9]+ 		{yylval.fval = atof(yytext); return T_FLOAT;}
[0-9]+			{yylval.ival = atoi(yytext); return T_INT;}
\n			{return T_NEWLINE;}
"+"			{return T_PLUS;}
"-"			{return T_MINUS;}
"*"			{return T_MULTIPLY;}
"/"			{return T_DIVIDE;}
"("			{return T_LEFT;}
")"			{return T_RIGHT;}
"exit"			{return T_QUIT;}
"quit"			{return T_QUIT;}
"ls"			{return LS_COM;}
"ps"			{return PS_COM;}
"mkdir"			{return MKDIR_COM;}
"rmdir"			{return RMDIR_COM;}
"kill"			{return KILL_COM;}
"ifconfig"		{return IP_COM;}
"touch"			{return TOUCH_COM;}
"start"			{return START_COM;}
"cd"			{return CD_COM;}
[A-Za-z_][A-Za-z0-9_]*	{yylval.sval = strdup(yytext); return T_CHAR;}
%%
