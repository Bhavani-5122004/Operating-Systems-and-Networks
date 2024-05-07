#include "headers.h"
#include "prompt.h"
#include "A_3.h"
#include "A_2.h"
#include "A_4.h"
#include "A_5.h"
#include "A_6.h"
#include "A_7.h"
#include "A_8.h"

int countd = 0;
int countf = 0;
int checkfd = -1;
total_blocks = 0;

#define WHITE "\x1b[0m"
#define RED "\033[0;31m"

int main()
{
    countd = 0;
 countf = 0;
 checkfd = -1;
    int execflag = 0;
    holdbg **holdbgarr = (holdbg **)malloc(sizeof(holdbg *) * 100);
    for (int i = 0; i < 100; i++)
    {
        holdbgarr[i] = (holdbg *)malloc(sizeof(holdbg) * 1000);
        holdbgarr[i]->bgp = (char *)malloc(sizeof(char) * 400);
    }
    int holdbgind = 0;
    char *sysname = (char *)malloc(sizeof(char) * 1024);
    int sn = gethostname(sysname, 1024);

    char **pastevents = (char **)malloc(sizeof(char *) * 15);
    for (int i = 0; i < 15; i++)
    {
        pastevents[i] = (char *)malloc(sizeof(char) * 2005);
    }
    int arrind = 0;
    char *homedir = (char *)malloc(sizeof(char) * 1024);
    homedir = getcwd(homedir, 305);
    char *prev = (char *)malloc(sizeof(char) * 1024);
    char *curr = (char *)malloc(sizeof(char) * 1024);
    strcpy(prev, homedir);
    int fore = 0;
    int arrlen = 0;
    char *line = (char *)malloc(sizeof(char) * 2000);
    char *past_temp = (char *)malloc(sizeof(char *) * 1000);
    strcpy(curr, homedir);
    chdir(homedir);
    char *com = (char *)malloc(sizeof(char *) * 1024);
    strcpy(com, "");
    char *inputtemp = (char *)malloc(sizeof(char *) * 1024);
    FILE *file = fopen("holdarr.txt", "r");

    if (file == NULL)
    {

        file = fopen("holdarr.txt", "w");
    }
    else
    {

        line = (char *)malloc(sizeof(char) * 200);
        while (fgets(line, 200, file) != NULL)
        {
            line[strcspn(line, "\n")] = '\0';

            strcpy(pastevents[arrind], line);

            arrind++;
        }
    }
    arrlen = arrind;

    fclose(file);
    chdir(curr);
    int time1 = 0;
    while (1)
    {
        int kl = 0;

        time1 = prompt(homedir, curr, sysname, sn, time1, com);

        char input[1000];
        if (fgets(input, sizeof(input), stdin) == NULL)
        {
            break;
        }
        int status;
        int y = holdbgind;
        // printing any bg processes
        if (holdbgind != 0)
        {

            for (int hg = 0; hg < y; hg++)
            {
                pid_t pid = waitpid(holdbgarr[hg]->pid1, &status, WNOHANG);
                int flagbg = 0;

                if (WIFEXITED(status) && pid > 0)
                {
                    printf("%s exited normally (%d)\n", holdbgarr[hg]->bgp, holdbgarr[hg]->pid1);
                    flagbg = 1;
                }
                else if (WIFSIGNALED(status) && pid > 0)
                {
                    printf("%s exited abnormally (%d)\n", holdbgarr[hg]->bgp, holdbgarr[hg]->pid1);
                    flagbg = 1;
                }
                if (flagbg == 1)
                {
                    holdbgind--;
                    holdbgarr[hg] = holdbgarr[holdbgind];
                }
            }
        }
        input[strcspn(input, "\n")] = '\0';

        strcpy(inputtemp, input);
        inputtemp = trim(inputtemp);
        int should = 0;
        if (strstr(inputtemp, "pastevents") != NULL)
        {
            should = 1;
        }

        const char delim[2] = ";";
        int flag = 0;
        for (int i = 0; i < strlen(input); i++)
        {
            if (input[i] == '&')
            {
                flag = 1;
                break;
            }
        }
        char *run = (char *)malloc(sizeof(char) * 1024);
        int splitind = 0;
        // time1 = 0;
        // splitting input based on ; and &
        for (int sp = 0; sp < strlen(input); sp++)
        {
            // if split on &
            if (input[sp] == '&')
            {
                run[splitind] = input[sp];
                splitind++;

                run[splitind] = '\0';
                splitind = 0;

                char *trimmed = (char *)malloc(sizeof(char) * strlen(run));
                trimmed = trim(run);
                strcpy(past_temp, trimmed);

                if (should == 0)
                {
                    int k = arrind;
                    arrind = pasteventsfunc(pastevents, arrind, inputtemp, run, homedir, curr, arrlen);

                    if (k != arrind)
                    {
                        arrlen++;
                    }
                }

                if (trimmed[strlen(trimmed) - 1] == '&')
                {

                    char *split = (char *)malloc(sizeof(char) * 1024);

                    char *bg = (char *)malloc(sizeof(char) * 200);
                    int bgind = 0;

                    for (int bb = 0; bb < strlen(run) - 1; bb++)
                    {
                        bg[bgind] = run[bb];
                        bgind++;
                    }
                    bg[bgind] = '\0';
                    bg = trim(bg);
                    holdbgind = bgcom(bg, holdbgarr, holdbgind);
                }
            }
            // split on ; or no & or ;
            else if (input[sp] == ';' || sp == strlen(input) - 1)
            {
                if (sp == strlen(input) - 1)
                {
                    run[splitind] = input[sp];
                    splitind++;
                }
                run[splitind] = '\0';
                splitind = 0;
                char *trimmed = (char *)malloc(sizeof(char) * strlen(run));
                trimmed = trim(run);

                int is_error = 0;
                // // WARP
                if (strncmp(trimmed, "warp", 4) == 0)
                {
                    if (strlen(trimmed) == 5)
                    {
                        perror(RED "Error: Directory does not exist" WHITE);
                        return -1;
                    }
                    else if (strlen(input) == 4)
                    {
                        strcpy(prev, getcwd(prev, 210));
                        if (chdir(homedir) == -1)
                        {
                            perror(RED "chdir" WHITE);
                            return -1;
                        }
                        strcpy(curr, homedir);
                        strcpy(past_temp, trimmed);
                        printf("%s\n", homedir);
                        is_error = 0;
                    }

                    else
                    {
                        strcpy(past_temp, trimmed);

                        is_error = warp(trimmed + 5, homedir, curr, prev);
                    }

                    // if (is_error == 0)
                    // {
                    if (should == 0)
                    {
                        int k = arrind;
                        arrind = pasteventsfunc(pastevents, arrind, inputtemp, run, homedir, curr, arrlen);

                        if (k != arrind)
                        {
                            arrlen++;
                        }
                    }

                    // }
                }

                // // PEEK

                else if (strncmp(trimmed, "peek", 4) == 0)
                {
                    if (strlen(trimmed) == 4)
                    {
                        strcpy(past_temp, trimmed);
                        int is_error = peekonly(trimmed + 5, homedir, prev);
                    }
                    else if (strcmp(trimmed, "peek -") == 0)
                    {
                        printf("No such file or directory\n");
                    }
                    else
                    {
                        strcpy(past_temp, trimmed);
                        // for peek- or peek/
                        if (strlen(trimmed + 5) == 0)
                        {
                            printf(RED "Invalid command\n" WHITE);
                        }
                        else
                        {
                            int is_error = peek(trimmed + 5, homedir, prev);
                        }
                    }

                    // if (is_error == 0)
                    // {
                    if (should == 0)
                    {
                        int k = arrind;

                        arrind = pasteventsfunc(pastevents, arrind, inputtemp, run, homedir, curr, arrlen);

                        if (k != arrind)
                        {
                            arrlen++;
                        }
                    }

                    //}
                }
                // // PASTEVENTS
                else if (strncmp(trimmed, "pastevents", 10) == 0)
                {
                    if (strncmp(trimmed, "pastevents purge", 16) == 0)
                    {
                        arrind = purge(pastevents, trimmed, arrind, homedir, curr);

                        arrlen = 0;
                    }
                    else if ((strncmp(trimmed, "pastevents execute", 18) == 0))
                    {
                        execute(pastevents, trimmed, arrind, homedir, curr, prev, input, arrlen, com, time1, holdbgind, holdbgarr);
                    }
                    else
                    {

                        for (int i = 0; i < arrlen; i++)
                        {
                            if (i < 15)
                            {
                                printf("%s\n", pastevents[i]);
                            }
                        }
                    }
                }
                // PROCLORE
                else if (strncmp(trimmed, "proclore", 8) == 0)
                {
                    if (strlen(trimmed) == 8)
                    {
                        int is_error = process_info(getpid());
                        // if (is_error == 0)
                        // {
                        strcpy(past_temp, trimmed);
                        if (should == 0)
                        {
                            int k = arrind;
                            arrind = pasteventsfunc(pastevents, arrind, inputtemp, run, homedir, curr, arrlen);
                            if (k != arrind)
                            {
                                arrlen++;
                            }
                        }
                        //}
                    }
                    else
                    {
                        char *num = (char *)malloc(sizeof(char) * 15);
                        int numind = 0;
                        for (int kk = 9; kk < strlen(trimmed); kk++)
                        {
                            num[numind] = trimmed[kk];
                            numind++;
                        }
                        num[numind] = '\0';
                        int number = atoi(num);
                        strcpy(past_temp, trimmed);
                        int is_error = process_info(number);
                    }
                    // if (is_error == 0)
                    // {
                    strcpy(past_temp, trimmed);
                    if (should == 0)
                    {
                        int k = arrind;
                        arrind = pasteventsfunc(pastevents, arrind, inputtemp, run, homedir, curr, arrlen);
                        if (k != arrind)
                        {
                            arrlen++;
                        }
                    }

                    //}
                }

                // SEEK
                else if (strncmp(trimmed, "seek", 4) == 0)
                {
                    int is_error = findfile(trimmed + 5, curr, homedir);
                    // if (is_error == 0)
                    //         {
                    strcpy(past_temp, trimmed);
                    if (should == 0)
                    {
                        int k = arrind;
                        arrind = pasteventsfunc(pastevents, arrind, inputtemp, run, homedir, curr, arrlen);
                        if (k != arrind)
                        {
                            arrlen++;
                        }
                    }
                    // }
                }

                // EXECVP
                else
                {
                    // BACKGROUND

                    strcpy(past_temp, trimmed);

                    if (should == 0)
                    {
                        int k = arrind;
                        arrind = pasteventsfunc(pastevents, arrind, inputtemp, run, homedir, curr, arrlen);
                        if (k != arrind)
                        {
                            arrlen++;
                        }
                    }
                    if (trimmed[strlen(trimmed) - 1] == '&')
                    {
                        char *split = (char *)malloc(sizeof(char) * 1024);
                        strcpy(split, trimmed);

                        char *bg = (char *)malloc(sizeof(char) * 200);
                        int bgind = 0;

                        for (int bb = 0; bb < strlen(split) - 2; bb++)
                        {
                            bg[bgind] = split[bb];
                            bgind++;
                        }
                        bg[bgind] = '\0';
                        holdbgind = bgcom(bg, holdbgarr, holdbgind);
                    }
                    // FOREGROUND
                    else
                    {
                        time1 = syscom(trimmed);
                        if (time1 <= 2)
                        {
                            time1 = 0;
                        }

                        char *comtemp = (char *)malloc(sizeof(char) * 200);
                        int comind = 0;
                        for (int ip = 0; ip < strlen(trimmed); ip++)
                        {
                            if (trimmed[ip] != ' ')
                            {
                                comtemp[comind] = trimmed[ip];
                                comind++;
                            }
                            else
                            {
                                break;
                            }
                        }
                        comtemp[comind] = '\0';
                        strcpy(com, comtemp);
                        strcpy(past_temp, trimmed);
                        if (should == 0)
                        {
                            int k = arrind;
                            arrind = pasteventsfunc(pastevents, arrind, inputtemp, run, homedir, curr, arrlen);
                            if (k != arrind)
                            {
                                arrlen++;
                            }
                        }
                    }
                }
            }
            else
            {
                run[splitind] = input[sp];
                splitind++;
            }
        }

        // printf("***%s\n",run);
    }
    return 0;
}