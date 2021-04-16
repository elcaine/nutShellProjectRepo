#ifndef THISHALF_H_
#define THISHALF_H_

int wipe();
int runPWD();
int runCDnil();
int runCD(char* arg);
int runCDspc(char* arg1, char* arg2);
int runPWD();
int genCommandOne(char* comm);
int genCommandTwo(char* comm, char* arg1);
int genCommandTre(char* comm, char* arg1, char* arg2);
int genCommandFor(char* comm, char* arg1, char* arg2, char* arg3);
int genCommandFiv(char* comm, char* arg1, char* arg2, char* arg3, char* arg4);
int genCommandSix(char* comm, char* arg1, char* arg2, char* arg3, char* arg4, char* arg5);
int genCommand	 (char* comm, char* arg1, char* arg2, char* arg3, char* arg4, char* arg5, char* arg6);
extern int wait(int);
int runCommand(char* command, char* argument);
int runGlobal(char* command, char* argument);
#endif
