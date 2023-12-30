%{
#include "Project.tab.h"
void yyerror(char *);
#include <string.h>
#include <stdio.h>
#define MAX_SIZE 1000

void yyerror(char *);
int num_of_v=0;

struct KeyValue {
    char key[20];
    int value;
};

struct KeyValue myMap[MAX_SIZE]; // Assuming a fixed size for simplicity

void addToMap(const char *key, int value) {
    for (int i = 0; i < MAX_SIZE; ++i) {
        if (strcmp(myMap[i].key, key) == 0) {
            // Key already exists, update the value
            myMap[i].value = value;
            return;
        }
    }

    // Key not found, add a new entry
    for (int i = 0; i < MAX_SIZE; ++i) {
        if (myMap[i].key[0] == '\0') {
            strcpy(myMap[i].key, key);
            myMap[i].value = value;
            return;
        }
    }

    // Map is full
    printf("Error: Map is full, cannot add more entries.\n");
}

int getValueFromMap(const char *key) {
    for (int i = 0; i < MAX_SIZE; ++i) {
        if (strcmp(myMap[i].key, key) == 0) {
            return myMap[i].value;
        }
    }

    // Key not found
    return -1; // You can choose a different sentinel value or handle it differently
}

%}

%%

"if" {return IF;}
"while" {return WHILE;}
"==" {return EQ;}
"!=" {return NEQ;}
">" {return GT;}
"<" {return LT;}
">=" {return GE;}
"<=" {return LE;}
"{"  {return OC;}
"}"  {return CC;}
"elseif" {return ELSEIF;}
"else" {return ELSE;}
"int"      {return INT;}
"print"  {return PRINT;}

[a-zA-Z][a-zA-Z0-9]*       {   /* variables */
                if(getValueFromMap(yytext)==-1)
                  {
                        addToMap(yytext, num_of_v);
                     	yylval = num_of_v;
                        num_of_v++;
                   }
                      
                else
                      yylval=getValueFromMap(yytext);
                return VARIABLE;
            }
[0-9]+      {   /* integers */
                yylval = atoi(yytext);
                return INTEGER;
            }
[-+()*/=] {  return *yytext; }
";"            {return SEMICOLON;}
[ \t\n]        ;
.            yyerror(yytext); 
%%

int yywrap(void) {
    return 1;
}