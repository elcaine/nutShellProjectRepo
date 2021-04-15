#ifndef THATHALF_H_
#define THATHALF_H_

int yyerror(char *s);
int runSetAlias(char *name, char *word);
int runSetenv(const char* name, const char* value);
int runUnsetenv(const char* name);
int runPrintenv();
int runPrintAlias();
int runUnalias(char* name);
int runCommand(char* command, char* argument);
int runGlobal(char* command, char* argument);
char* findPath(char* name);
//extern int wait(int);

#endif
