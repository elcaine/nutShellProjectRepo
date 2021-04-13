#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "global.h"
#include <unistd.h>
#include <limits.h>

#define nutRED         "\x1b[31m"
#define nutGREEN       "\x1b[32m"
#define nutYELLOW      "\x1b[33m"
#define nutBLUE        "\x1b[34m"
#define nutMAGENTA     "\x1b[35m"
#define nutCYAN        "\x1b[36m"
#define nutRESET       "\x1b[0m"

//char *getcwd(char *buf, size_t size);  // commented this out, seems like it can be removed
extern int yyparse();

int main()
{
    aliasIndex = 0;
    varIndex = 0;
    char cwd[PATH_MAX];
    getcwd(cwd, sizeof(cwd));

    strcpy(varTable.var[varIndex], "PWD");      // 0  * Pretty sure this isn't actually used...
    strcpy(varTable.word[varIndex], cwd);       //      but, all the other varIndices count on this = 0
    varIndex++;                                 //      Can't really kill, because something might loop this
    strcpy(varTable.var[varIndex], "HOME");     // 1
    strcpy(varTable.word[varIndex], cwd);
    varIndex++;
    strcpy(varTable.var[varIndex], "PROMPT");   // 2
    strcpy(varTable.word[varIndex], "$");
    varIndex++;
    strcpy(varTable.var[varIndex], "PATH");     // 3
    strcpy(varTable.word[varIndex], ".:/bin");
    // Need to remove the line below (hard coding location of non-built-in commands)
    strcat(varTable.word[varIndex], ":/usr/bin"); // *this, this is the line to kill
    varIndex++;
    strcpy(varTable.var[varIndex], ".");
    strcpy(varTable.word[varIndex], cwd);       // 4
    varIndex++;

    char* pointer = strrchr(cwd, '/');
    while (*pointer != '\0') 
    {
        *pointer = '\0';
        pointer++;
    }
    strcpy(varTable.var[varIndex], "..");
    strcpy(varTable.word[varIndex], cwd);       // 5
    varIndex++;

    char* userName = getenv("USER");
    //system("clear");  // Need to uncomment this for submission
    printf("\n****************************************\n");
    printf("*                                      *\n");
    printf("* SSSSSssssstarting the NuttyShell!!!! *\n");
    printf("*                                      *");
    printf("\n****************************************\n");

    while(1)
    {        
        printf(nutRED "%s" nutYELLOW, userName);
        printf("[%s]>> " nutGREEN, varTable.word[2]);
        yyparse();
    }
    return 0;
}