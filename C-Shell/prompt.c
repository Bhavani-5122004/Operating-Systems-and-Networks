#include "headers.h"
#include "prompt.h"

#define PURPLE "\033[0;35m"
#define WHITE "\x1b[0m"

int prompt(char *home, char *curr, char *sysname, int sn, int k, char *command)
{
    char *username = (char *)malloc(sizeof(char) * 1000);

    username = getlogin();
    char *temp = (char *)malloc(sizeof(char) * 1024);
    int is_in = 0;

    if (sn == -1)
    {
        printf("Error in getting system name\n");
    }
    char *currdir = (char *)malloc(sizeof(char) * 1000);
    currdir = getcwd(currdir, 1000);
    strcpy(temp, currdir);
    int flag = 1;

    if (currdir == NULL || strcmp(currdir, home) == 0)
    {
        flag = 0;
    }
    if (strncmp(currdir, home, strlen(home)) == 0)
    {
        is_in = 1;

        char *remainingpath = (char *)malloc(sizeof(char *) * 1024);
        remainingpath = currdir + strlen(home);

        strcpy(currdir, remainingpath);
    }

    // if we run a foreground process of time > 2s and not home directory
    if (k != 0 && flag != 0)
    {
        printf("<");
        printf(PURPLE "%s" WHITE, username);
        printf("@%s:~%s~%s : %ds> ", sysname, currdir, command, k);
        k = 0;
    }
    // fg process and home directory
    else if (k != 0 && flag == 0)
    {
        printf("<");
        printf(PURPLE "%s" WHITE, username);
        printf("@%s:~ %s : %ds> ", sysname, command, k);
        k = 0;
    }
    // normal process and home dir
    else if (flag == 0 && k == 0)
    {
        printf("<");
        printf(PURPLE "%s" WHITE, username);
        printf("@%s:~> ", sysname);
    }
    // normal process in a directory
    else
    {
        printf("<");
        printf(PURPLE "%s" WHITE, username);
        printf("@%s:~%s> ", sysname, currdir);
    }
    if (is_in == 1)
    {
        strcpy(currdir, temp);
    }
    // changing currdir
    strcpy(curr, currdir);
    return k;
}
