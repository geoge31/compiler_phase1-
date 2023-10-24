%{

#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#define YY_DECL int alpha_yylex (void* ylval)

int tokeno=0;


struct alpha_token_t {

  unsigned int numLine;
  unsigned int finishLine;
  unsigned int numToken;
  char *content;
  char *type;
  char *caps;
  char  *des;
  struct alpha_token_t *next;
};

struct alpha_token_t *H=NULL;

void insertToken(struct alpha_token_t **Tok,unsigned int new_numLine,unsigned int new_finishLine, unsigned int new_numToken, char *new_Content,char *new_Type,char *new_Caps, char *new_Des){
    
    struct alpha_token_t *new_Token;
    struct alpha_token_t *last=*Tok;    /* trace pointer to find the last node of the list */ 

    new_Token=malloc(sizeof(struct alpha_token_t)); /* allocate memory for the new token */

    if(new_Token==NULL) {
        printf("Error Memory Allocation\n");
        exit(0);
    }

    new_Token->numLine=new_numLine;
    new_Token->finishLine=new_finishLine;
    new_Token->numToken=new_numToken;
    new_Token->content=new_Content;
    new_Token->type=new_Type;
    new_Token->caps=new_Caps;
    new_Token->des=new_Des; 
    new_Token->next=NULL;

    if(*Tok==NULL){     /* if global pointers points to NULL add it as first node */
        *Tok=new_Token;
    } 

    else{
        while(last->next!=NULL){            /* Find the Last node of the List */ 
            last=last->next;
        }
    last->next=new_Token;     /* Add new node at the end of the List */ 
    }
}

void print(struct alpha_token_t *Tok){
    
    struct alpha_token_t *n;
    n=Tok;

    while(n!=NULL){
        if(n->finishLine!=-1){
            printf("%d:     #%d     \"%d-%d\"      %s   %s",n->numLine,n->numToken,n->numLine,n->finishLine,n->type,n->caps,n->des);
        }else{
            printf("%d:     #%d     \"%s\"    %s   %s   %s",n->numLine,n->numToken,n->content,n->type,n->caps,n->des);
        } 
                
        n=n->next;
        printf("\n");     
    }
    free(n);
}

%}

%option noyywrap
%option yylineno



if  "if"
else        "else"
while       "while"
for         "for"
function        "function"
return          "return"
break          "break"
continue        "continue"
and         "and"
not         "not"
or           "or"
local       "local"
true        "true"
false       "false"
nil         "nil"
comment1    "//".*
comment2    "#".*
comment3    "/*"
assign      "="
plus        "+"
minus       "-"
mul         "*"
divide       "/"
mod         "%"
equal       "=="
notEqual        "!="
plusPlus       "++"
minusMinus       "--"
bigger      ">"
less        "<"
biggerEqual     ">="
lessEqual       "<="
leftBrace       "{"
rightBrace      "}"
leftBracket         "["
rightBracket        "]"
leftParenthesis         "("
rightParenthesis        ")"
semicolon       ";"
comma       ","
colon       ":"
doubleColon         "::"
dot     "."
doubleDot          ".."
id [a-zA-Z][a-zA-Z_0-9]*
integer (0[xX][0-9A-Fa-f]+)|([0-9]+)
realconstant    [0-9]*\.[0-9](e|E)?[0-9]*
space   [\r \t\v]
newline "\n"
string  \"



 
%%

{if}        {tokeno++; insertToken(&H,yylineno,-1,tokeno,"if","KEYWORD","IF","<-enumerated");}
{else}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"else","KEYWORD","ELSE","<-enumerated");}
{while}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"while","KEYWORD","WHILE","<-enumerated");}
{for}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"for","KEYWORD","FOR","<-enumerated");}
{function}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"function","KEYWORD","FUNCTION","<-enumerated");}
{return}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"return","KEYWORD","RETURN","<-enumerated");}
{break}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"break","KEYWORD","BREAK","<-enumerated");}
{continue}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"continue","KEYWORD","CONTINUE","<-enumerated");}
{and}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"and","KEYWORD","AND","<-enumerated");}
{not}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"not","KEYWORD","NOT","<-enumerated");}
{or}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"or","KEYWORD","OR","<-enumerated");}
{local}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"local","KEYWORD","LOCAL","<-enumerated");}
{true}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"true","KEYWORD","TRUE","<-enumerated");}
{false}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"false","KEYWORD","FALSE","<-enumerated");}
{nil}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"nil","KEYWORD","NIL","<-enumerated");}
{comment1}      {tokeno++; insertToken(&H,yylineno,-1,tokeno," ","COMMENT","LINE_COMMENT","<-enumerated");}
{comment2}      {tokeno++; insertToken(&H,yylineno,-1,tokeno," ","COMMENT","LINE_COMMENT","<-enumerated");}
{comment3}      {
                    
                    int in;
                    int start_com=1,finish_com=0,nest_com=0;
                    int yyline1=0,yyline2=0,yyline3=0;

                    yyline1=yylineno;
                    
                    while(in=input()) {
                       
                        if(in == '/') {
                            if((in=input()) == '*'){
                                yyline2=yylineno;
                                tokeno++;
                                start_com++;
                                nest_com++;
                            }else unput(in);
                        }
                        if(in == '*'){
                            if((in=input()) =='/'){
                                finish_com++;
                                nest_com++;
                                tokeno++;
                                yyline3=yylineno;
                                    if(start_com!=finish_com) {
                                        tokeno++;
                                        insertToken(&H,yyline2,yyline3,tokeno," ","COMMENT","NESTED_COMMENT","<-enumerated");
                                    }
                            }else unput(in);  
                        }
                        if(start_com==finish_com) break;
                    }

                    if(start_com!=finish_com) {
                        tokeno++; printf("%d:     #%d     ERROR: UNTERMINATED COMMENT\n",yylineno,tokeno);
                        exit(0);
                    }

                    yyline3=yylineno;
                    tokeno++;
                    insertToken(&H,yyline1,yyline3,tokeno,"","COMMENT","BLOCK_COMMENT","<-enumerated");
}

                
{assign}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"=","OPERATOR","ASSIGN","<-enumerated");}
{plus}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"+","OPERATOR","PLUS","<-enumerated");}
{minus}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"-","OPERATOR","MINUS","<-enumerated");}
{mul}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"*","OPERATOR",",ULTIPLY","<-enumerated");}
{divide}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"/","OPERATOR","DIVIDE","<-enumerated");}
{mod}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"%","OPERATOR","MOD","<-enumerated");}
{equal}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"==","OPERATOR","EQUAL","<-enumerated");}
{notEqual}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"!=","OPERATOR","NOT_EQUAL","<-enumerated");}
{plusPlus}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"++","OPERATOR","PLUS_PLUS","<-enumerated");}
{minusMinus}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"--","OPERATOR","MINUS_MINUS","<-enumerated");}
{bigger}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,">","OPERATOR","GREATER","<-enumerated");}
{less}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"<","OPERATOR","LESS","<-enumerated");}
{biggerEqual}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,">=","OPERATOR","GREATER_EQUAL","<-enumerated");}
{lessEqual}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"<=","OPERATOR","LESS_EQUAL","<-enumerated");}
{leftBrace}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"{","PUNCTUATION","LEFT BRACE","<-enumerated");}
{rightBrace}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"}","PUNCTUATION","RIGHT BRACE","<-enumerated");}
{leftBracket}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"[","PUNCTUATION","LEFT BRACKET","<-enumerated");}
{rightBracket}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"]","PUNCTUATION","RIGHT BRACKET","<-enumerated");}
{leftParenthesis}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"(","PUNCTUATION","LEFT PARENTHESIS","<-enumerated");}
{rightParenthesis}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,")","PUNCTUATION","RIGHT PARENTHESIS","<-enumerated");}
{semicolon}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,";","PUNCTUATION","SEMICOLON","<-enumerated");}
{comma}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,",","PUNCTUATION","COMMA","<-enumerated");}
{colon}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,":","PUNCTUATION","COLON","<-enumerated");}
{doubleColon}      {tokeno++; insertToken(&H,-1,yylineno,tokeno,"::","PUNCTUATION","DOUBLE_COLON","<-enumerated");}
{dot}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,".","PUNCTUATION","DOT","<-enumerated");}
{doubleDot}      {tokeno++; insertToken(&H,yylineno,-1,tokeno,"..","PUNCTUATION","DOUBLE_DOT","<-enumerated");}
{id}        {tokeno++; insertToken(&H,yylineno,-1,tokeno,yytext,"ID",yytext,"<-char");}
{integer}        {tokeno++; insertToken(&H,yylineno,-1,tokeno,yytext,"CONST_INT",yytext,"<-int");}
{realconstant}          {tokeno++; insertToken(&H,yylineno,-1,tokeno,yytext,"CONST_REAL",yytext,"<-real*");}
{space}         { }
{newline}         { }
{string} {
                int in;
                int i=0,isClosed=0;
                char *str=(char *)malloc(5000*sizeof(char));
                int newyyline=yylineno;

                while(in=input()){
                    if(in=='\\'){
                        if((in=input())=='"'){
                            str=(char *)realloc(str,5000*sizeof(char));
                            str[i++]='\"';
                        }
                        unput(in);

                        if((in=input())=='t'){
                            str=(char *)realloc(str,5000*sizeof(char));
                            str[i++]='\t';
                        }
                        unput(in);

                        if((in=input())=='n'){
                            str=(char *)realloc(str,5000*sizeof(char));
                           str[i++]='\n';                  
                        }
                        unput(in);

                        if((in=input())=='\\'){
                            str=(char *)realloc(str,5000*sizeof(char));
                           str[i++]='\\';
                        }
                        unput(in);

                        if((in=input())=='b'){
                            str=(char *)realloc(str,5000*sizeof(char));
                            str[i++]='\b';
                        }
                    }

                    else if(in=='\"'){
                        i++;
                        isClosed=1;
                        break;
                    } 
                    
                    else {
                        str=(char *)realloc(str,5000*sizeof(char));
                        str[i++]=in;
                    }
                    
                }
                printf("\n");

                str=(char *)realloc(str,5000*sizeof(char));
                str[i++]=0;
                tokeno++;
                insertToken(&H,newyyline,-1,tokeno,str,"STRING",str,"<-char*");

                if(isClosed==0) {
                    printf("ERROR! Unterminated string\n");
                    exit(0);
                }

                i=0;
        }

%%

int main(int argc, char **argv){


    if(argc>1){
           if(!(yyin=fopen(argv[1],"r"))) {
                    fprintf(stderr, "Cannot  read file %s\n", argv[1]);
                    return 1;
           }       
    }
    else{
        yyin=stdin;
    }

    alpha_yylex(yyin);

    printf("---------------- Lexical Analysis------------------\n");
    print(H);
    free(H);

    return 0;
}
