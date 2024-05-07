#ifndef HEADERS_H_
#define HEADERS_H_


extern int countd;
extern int countf;
extern int checkfd;
extern int total_blocks;

typedef struct holdbg{
char* bgp;
int pid1;
int finished;
}holdbg;

#include <stdio.h>
#include <stdlib.h>
#include<readline/readline.h>
#include "prompt.h"
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <dirent.h>
#include <sys/stat.h>
#include <pwd.h>
#include <grp.h>
#include <time.h>
#include<sys/utsname.h>
#include <limits.h>
#include <time.h>
#endif