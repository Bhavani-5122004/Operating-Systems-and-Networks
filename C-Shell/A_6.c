#include "headers.h"
#include "A_6.h"

#define WHITE "\x1b[0m"
#define RED "\033[0;31m"

// fg process
int syscom(char *trimmed)
{

    struct timespec start_time, end_time;
    clock_gettime(CLOCK_MONOTONIC, &start_time);
    char *command = (char *)malloc(sizeof(char) * 1024);
    strcpy(command, trimmed);

    char *delimiter1 = (char *)malloc(sizeof(char) * 10);
    strcpy(delimiter1, " ");
    char *args[100];

    char *token = strtok(command, delimiter1);
    int i = 0;
    while (token != NULL && i < 10)
    {
        args[i] = token;
        token = strtok(NULL, delimiter1);
        i++;
    }
    args[i] = NULL;
    // after splitting into commands for execvp
    int pid = fork();
    if (pid == -1)
    {
        perror(RED "Fork failed" WHITE);
        return -1;
    }

    else if (pid == 0)
    {
        execvp(args[0], args);
        perror(RED "Execvp failed" WHITE);
        return -1;
    }

    int wait;
    waitpid(pid, &wait, 0);
    // getting time
    clock_gettime(CLOCK_MONOTONIC, &end_time);
    int elapsed_time = (end_time.tv_sec - start_time.tv_sec) +
                       (end_time.tv_nsec - start_time.tv_nsec) / 1e9;

    return elapsed_time;

    return 0;
}

// to update my array of structs of bg processes
int bgupdate(char *bg, int pid, holdbg **holdbgarr, int holdbgind)
{

    holdbgarr[holdbgind]->finished = 1;
    holdbgarr[holdbgind]->pid1 = pid;
    strcpy(holdbgarr[holdbgind]->bgp, bg);
    holdbgind++;
    return holdbgind;
}

// bg process
int bgcom(char *trimmed, holdbg **holdbgarr, int holdbgind)
{

    char *command = (char *)malloc(sizeof(char) * 1024);
    strcpy(command, trimmed);

    char *delimiter1 = (char *)malloc(sizeof(char) * 10);
    strcpy(delimiter1, " ");
    char *args[100];

    char *token = strtok(command, delimiter1);
    int i = 0;
    while (token != NULL && i < 10)
    {
        args[i] = token;
        token = strtok(NULL, delimiter1);
        i++;
    }
    args[i] = NULL;

    int pid = fork();
    if (pid == -1)
    {
        perror(RED "Fork failed" WHITE);
        return -1;
    }

    else if (pid == 0)
    {
        execvp(args[0], args);

        perror(RED "Execvp failed" WHITE);
        return -1;
    }
    else if (pid > 0)
    {

        holdbgind = bgupdate(args[0], pid, holdbgarr, holdbgind);

        printf("%d\n", pid);

        return holdbgind;
    }

    return holdbgind;
}
