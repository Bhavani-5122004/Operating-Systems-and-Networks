#include "headers.h"
#include "A_7.h"

#define WHITE "\x1b[0m"
#define RED "\033[0;31m"

int process_info(int pid)
{
    char *status = (char *)malloc(sizeof(char) * 10);

    char path[1005];
    snprintf(path, 1005, "/proc/%d/stat", pid);

    FILE *fp = fopen(path, "r");
    if (fp == NULL)
    {
        perror(RED "fopen" WHITE);
        return -1;
    }
    int processID;
    char state;
    unsigned long vm_size;
    char executable[100];
    // get pid, executable and state
    fscanf(fp, "%d %s %c",
           &processID, executable, &state);

    for (int i = 0; i < 19; ++i)
    {
        fscanf(fp, "%*u ");
    }
    if (fscanf(fp, "%lu", &vm_size) != 1)
    {
        perror(RED "Error reading file" WHITE);
        fclose(fp);
        return -1;
    }
    fclose(fp);
    // foreground = +
    if (isatty(state) && state == 'R')
    {
        strcpy(status, "R+");
    }
    else if (isatty(state) && state == 'S')
    {
        strcpy(status, "S+");
    }
    else if (!isatty(state) && state == 'R')
    {
        strcpy(status, "R");
    }
    else if (!isatty(state) && state == 'S')
    {
        strcpy(status, "S");
    }
    else if (state == 'Z')
    {
        strcpy(status, "Z");
    }

    printf("pid : %d\n", pid);
    printf("Process Status  : %s\n", status);
    printf("Process Group : %d\n", getpgid(pid));
    printf("Virtual memory : %lu\n", vm_size);
    char *exec = (char *)malloc(sizeof(char) * 1024);
    int execind = 0;
    int j;
    // finding executable path
    snprintf(path, 1005, "/proc/%d/exe", pid);
    char temppath[1000];
    ssize_t len = readlink(path, temppath, 1000);
    if (len == -1)
    {
        perror(RED "Error reading link" WHITE);
        return -1;
    }

    temppath[len] = '\0';
    for (j = strlen(temppath) - 1; j >= 0; j--)
    {
        if (temppath[j] == '/')
        {
            break;
        }
    }
    for (int o = j; o < strlen(temppath); o++)
    {
        exec[execind] = temppath[o];
        execind++;
    }
    exec[execind] = '\0';
    printf("executable path : %s\n", exec);

    return 0;
}
