#ifndef THATHALF_H_
#define THATHALF_H_

int yyerror(char* s);
int runSetAlias(char* name, char* word);
int runSetenv(const char* name, const char* value);
int runUnsetenv(const char* name);
int runPrintenv();
int runPrintAlias();
int runUnalias(char* name);
int runCommand(char* name);
int runGlobal(char* name);
extern int wait(int);

// will need to remove/merge your runCommand with my genCommand
int genCommandNil(char* name);
#endif
