#ifndef THISHALF_H_
#define THISHALF_H_

int wipe();
int runPWD();
int runCDnil();
int runCD(char* arg);
int runCDspc(char* arg1, char* arg2);
int runPWD();
int genCommandNil(char* name);
int genCommand(char* name, char* fml);
extern int wait(int);

#endif