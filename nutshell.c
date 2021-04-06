// This is ONLY a demo micro-shell whose purpose is to illustrate the need for and how to handle nested alias substitutions and Flex start conditions.
// This is to help students learn these specific capabilities, the code is by far not a complete nutshell by any means.
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
char *getcwd(char *buf, size_t size);

int main()
{
    aliasIndex = 0;
    varIndex = 0;
    char cwd[PATH_MAX];
    getcwd(cwd, sizeof(cwd));

    strcpy(varTable.var[varIndex], "PWD");      // 0
    strcpy(varTable.word[varIndex], cwd);
    varIndex++;
    strcpy(varTable.var[varIndex], "HOME");     // 1
    strcpy(varTable.word[varIndex], cwd);
    varIndex++;
    strcpy(varTable.var[varIndex], "PROMPT");   // 2
    strcpy(varTable.word[varIndex], "$");
    varIndex++;
    strcpy(varTable.var[varIndex], "PATH");     // 3
    strcpy(varTable.word[varIndex], ".:/bin");
    varIndex++;

    strcpy(aliasTable.name[aliasIndex], ".");   // 0 sets current working dir
    strcpy(aliasTable.word[aliasIndex], cwd);
    aliasIndex++;

    char *pointer = strrchr(cwd, '/');
    while(*pointer != '\0') {
        *pointer ='\0';
        pointer++;
    }
    strcpy(aliasTable.name[aliasIndex], "..");  // 1 sets dir holding cwd
    strcpy(aliasTable.word[aliasIndex], cwd);
    aliasIndex++;

    char* userName = getenv("USER");
    system("clear");

    while(1)
    {        
        printf(nutRED "%s" nutYELLOW, userName);
        printf("[%s]>> " nutGREEN, varTable.word[2]);
        yyparse();
    }

    return 0;
}