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

    strcpy(varTable.var[varIndex], "PWD");      // 0  * Pretty sure this isn't actually used... but, all the
    strcpy(varTable.word[varIndex], cwd);       //      other varIndices count on this = 0.  Can't really kill
    varIndex++;                                 //      because something might loop through varTable, starting here
    strcpy(varTable.var[varIndex], "HOME");     // 1
    strcpy(varTable.word[varIndex], cwd);
    varIndex++;
    strcpy(varTable.var[varIndex], "PROMPT");   // 2  * Prolly samething here as above.
    strcpy(varTable.word[varIndex], "$");
    varIndex++;
    strcpy(varTable.var[varIndex], "PATH");     // 3    The mighty might PATH (... of confusion!)
    strcpy(varTable.word[varIndex], ".:/bin");
    // Need to remove the line below (hard coding location of non-built-in commands)
    //strcat(varTable.word[varIndex], ":/usr/bin"); // *this, this is the line to kill
    varIndex++;
    strcpy(varTable.var[varIndex], ".");
    strcpy(varTable.word[varIndex], cwd);       // 4    The mighty mighty current directory
    varIndex++;

    char* pointer = strrchr(cwd, '/');
    while (*pointer != '\0') 
    {
        *pointer = '\0';
        pointer++;
    }
    strcpy(varTable.var[varIndex], "..");
    strcpy(varTable.word[varIndex], cwd);       // 5    The mighty mighty parent directory
    varIndex++;

    char* userName = getenv("USER");
    //system("clear");  // Need to uncomment this for submission
    printf("\n****************************************\n");
    printf("*                                      *\n");
    printf("* Fareed and Daniel's Nutshell Project *\n");
    printf("*                                      *");
    printf("\n****************************************\n");

    while(1)
    {        
        printf(nutRED "%s", userName);
        printf(nutYELLOW ":");
        if (strcmp(varTable.word[4], varTable.word[1]) != 0)
        {
            printf(nutBLUE "%s", varTable.word[4]);
        }
        printf(nutYELLOW "$");
        printf(nutGREEN " ");
        yyparse();
    }
    return 0;
}
 
