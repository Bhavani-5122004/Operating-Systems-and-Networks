#include "headers.h"
#include "A_5.h"

#define WHITE "\x1b[0m"
#define RED "\033[0;31m"

int pasteventsfunc(char **pastevents, int arrind, const char *trimmed, char *run, char *homedir, char *curr, int arrlen)
{
    if (arrind == 0)
    {

        strcpy(pastevents[arrind], trimmed);
        arrind++;
        arrlen++;

        if (arrind == 15)
        {
            arrind = 0;
        }
    }
    else if (arrind != 0 && strcmp(pastevents[(arrind - 1)], trimmed) != 0)
    {
        if (arrind == 15)
        {
            
            arrind = 0;
        }

        strcpy(pastevents[arrind], trimmed);
        arrind++;
        arrlen++;
    }

    // storing info in the file
    chdir(homedir);

    FILE *file = fopen("holdarr.txt", "w");
    if (file == NULL)
    {
        printf("Failed to open the file.\n");
        return 1;
    }
    for (int i = 0; i < arrlen; i++)
    {
        if (i < 15)
        {

            fputs(pastevents[i], file);
            
            fputs("\n", file);
        }
    }
    fclose(file);

    chdir(curr);
    return arrind;
}

int purge(char **pastevents, char *trimmed, int arrind, char *homedir, char *currdir)
{
    // clear the file
    chdir(homedir);

    FILE *file = fopen("holdarr.txt", "w");
    fclose(file);
    chdir(currdir);
    arrind = 0;
    return arrind;
}

void execute(char **pastevents, char *trimmed, int arrind, char *homedir, char *curr, char *prev, char *input, int arrlen, char *com, int time1, int holdbgind, holdbg **holdbgarr)
{
    // finding the index
    int ind;
    if (strlen(trimmed) == 21)
    {
        int x = (trimmed + 19)[0] - '0';
        x *= 10;
        int y = (trimmed + 19)[1] - '0';
        x += y;
        ind = x;
    }
    else
    {
        int x = (trimmed + 19)[0] - '0';
        ind = x;
    }
    int imp = 0;
    if (arrlen >= 15)
    {
        imp = 15 - ind;
    }
    else
    {
        imp = arrind - ind;
    }
    char *indstr = (char *)malloc(sizeof(char) * 1024);

    strcpy(indstr, pastevents[imp]);

    if (strncmp(indstr, "warp", 4) == 0)
    {

        if (strlen(indstr) == 4)
        {

            if (chdir(homedir) == -1)
            {
                perror(RED "chdir" WHITE);
                return;
            }
            printf("%s\n", homedir);
            int is_error = 0;
        }

        else
        {

            int is_error = warp(indstr + 5, homedir, curr, prev);
        }
    }
    else if (strncmp(indstr, "peek", 4) == 0)
    {
        if (strlen(indstr) == 4)
        {

            int is_error = peekonly(indstr + 5, homedir, prev);
        }
        else
        {

            int is_error = peek(indstr + 5, homedir, prev);
        }
    }
    else if (strncmp(indstr, "proclore", 8) == 0)
    {
        if (strlen(indstr) == 8)
        {
            int is_error = process_info(getpid());
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

            int is_error = process_info(number);
        }
    }
    else if (strncmp(indstr, "seek", 4) == 0)
    {

        int is_error = findfile(indstr + 5, curr, homedir);
    }
    // EXECVP
    else
    {
        // BACKGROUND

        if (indstr[strlen(indstr) - 1] == '&')
        {
            char *split = (char *)malloc(sizeof(char) * 1024);

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
            time1 = syscom(indstr);
            if (time1 <= 2)
            {
                time1 = 0;
            }
            char *comtemp = (char *)malloc(sizeof(char) * 200);
            int comind = 0;
            for (int ip = 0; ip < strlen(indstr); ip++)
            {
                if (indstr[ip] != ' ')
                {
                    comtemp[comind] = indstr[ip];
                    comind++;
                }
                else
                {
                    break;
                }
            }
            comtemp[comind] = '\0';
            strcpy(com, comtemp);
        }
    }
}