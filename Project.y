
%token INTEGER VARIABLE SEMICOLON INT IF EQ NEQ GT LT GE LE OC CC ELSEIF ELSE PRINT WHILE
%right  '='
%left '+' '-' 
%left '*' '/'


%{

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include<stdbool.h>
int yylex(void);
void yyerror(char *);
extern FILE * yyin;
extern FILE * yyout;
FILE* yyError;
int sym[1000];
bool existIf=false;

bool conditionResult=true;
int cou=-1;

%}


%%                                    
program:
        program statement|
        ;

statement:
        expr SEMICOLON                     
        |INT VARIABLE '=' expr SEMICOLON       {if(conditionResult){ sym[$2] = $4; } } 
	|INT VARIABLE SEMICOLON       {if(conditionResult){ sym[$2] = -1; } } 
	|VARIABLE '=' expr SEMICOLON      { 
                                                 if(sym[$1] == 0) {
                                                           fprintf(yyout, "Error: Variable is not declared.\r\n");                                                    
                                                             exit(1);
                                                  }
                                                        sym[$1] = $3; 
                                     } 
	|ifstatement {existIf=false;conditionResult=true; }
	|whilestatement
	|PRINT '(' expr ')' SEMICOLON {if(conditionResult)fprintf(yyout,"%d\r\n",$3);}

	
        ;

whilestatement:
    WHILE '(' expr ')' SEMICOLON {	fprintf(yyout, "---------------Loop Start Here-------------- \r\n");
				    while ($3) { fprintf(yyout, "loop number : %d\r\n",cou=cou+1); $3=$3-1; }  cou=0;
				  fprintf(yyout, "---------------Loop End Here-------------- \r\n"); }
    ;


ifstatement:IF  '(' condition ')' OC statement CC {existIf=true ; } anyelse 
;



anyelse:  {existIf=false;conditionResult=true; }
	|ELSE {if(existIf==true){if(conditionResult==true){ conditionResult=false;}else{conditionResult=true;}}else{conditionResult=false; yyerror("Error:'else' without previous 'if'");} } OC statement CC {existIf=false;conditionResult=true;}
  	
	|ELSEIF '(' condition ')'{if(existIf==false){conditionResult=false;yyerror("\rError:'elseif' without previous 'if'");}} OC statement CC {if ($3==false){conditionResult=true;}} anyelse 
	
	
;  
condition:expr EQ expr {if(conditionResult==true&&existIf==false||conditionResult==false &&existIf==true){$$ =true;conditionResult= $1 == $3;}else{$$=false;conditionResult=false;} }
	|expr NEQ expr {if(conditionResult==true&&existIf==false||conditionResult==false &&existIf==true){$$=true;conditionResult = $1 != $3;}else{$$=false;conditionResult=false;}}
	|expr GT expr {if(conditionResult==true&&existIf==false||conditionResult==false &&existIf==true){$$ =true;conditionResult= $1 > $3;}else{$$=false;conditionResult=false;}}
	|expr LT expr {if(conditionResult==true&&existIf==false||conditionResult==false &&existIf==true){$$ =true;conditionResult= $1 < $3;}else{$$=false;conditionResult=false;}}
	|expr GE expr {if(conditionResult==true&&existIf==false||conditionResult==false &&existIf==true){$$ =true;conditionResult= $1 >= $3;}else{$$=false;conditionResult=false;}}
	|expr LE expr {if(conditionResult==true&&existIf==false||conditionResult==false &&existIf==true){$$ =true;conditionResult= $1 <= $3;}else{$$=false;conditionResult=false;}} 
	;



expr:
        INTEGER                  { $$ = $1; }
        | VARIABLE                { $$ = sym[$1];}
	| expr '*' expr           { $$ = $1 * $3; }
        | expr '/' expr           { $$ = $1 / $3; }
        | expr '+' expr           { $$ = $1 + $3; }
        | expr '-' expr           { $$ = $1 - $3; }
        
        | '(' expr ')'            { $$ = $2; }
        ;



%%
void yyerror(char *s) {
fprintf(yyError, "%s\r\n", s);
}

int main(void) {
yyin = fopen( "in.txt", "r" );
yyout = fopen( "output.txt", "w" );
yyError = fopen( "outError.txt", "w" );
yyparse();

fclose(yyin);
fclose(yyout);
fclose(yyError);

return 0;
}