#include "headers.h"
#include "A_3.h"

#define WHITE "\x1b[0m"
#define RED "\033[0;31m"

int warp(char *run, char *homedir, char *currdir, char *prevdir)
{

    char *path = (char *)malloc(sizeof(char) * 505);
    strcpy(path, run);
    // for just warp
    if (strcmp(run, "") == 0 || strcmp(run, "\n") == 0 || strcmp(run, " ") == 0 || strlen(run) == 0 || strcmp(run, "\0") == 0)
    {
        strcpy(prevdir, getcwd(prevdir, 210));

        if (chdir(homedir) == -1)
        {
            perror(RED "chdir" WHITE);
            return -1;
        }
        printf("%s\n", homedir);
        strcpy(currdir, homedir);
        return 0;
    }

    int len = strlen(run);
    char *temp = (char *)malloc(sizeof(char) * 105);
    int p = 0;
    // loop to split the commands
    for (int k = 0; k < len; k++)
    {
        if (run[k] == ' ' || k == len - 1)
        {

            if (k == len - 1)
            {
                temp[p] = run[k];
                p++;
            }
            temp[p] = '\0';
            strcpy(path, temp);
            p = 0;

            temp = (char *)malloc(sizeof(char) * 105);
            // warp ~/
            if (path[0] == '~' && path[1] == '/')
            {
                strcpy(prevdir, getcwd(prevdir, 210));
                if (chdir(homedir) == -1)
                {
                    perror(RED "chdir" WHITE);
                    return -1;
                }
                printf("%s\n", homedir);
                strcpy(currdir, homedir);
                strcpy(prevdir, getcwd(prevdir, 210));

                if (strcmp(run, "/") == 0 || chdir(path + 2) == -1)
                {

                    perror(RED "chdir" WHITE);
                    return -1;
                }
                strcpy(currdir, getcwd(currdir, 1024));
                printf("%s\n", currdir);
            }
            // warp ~
            else if (strcmp(path, "~") == 0)
            {
                strcpy(prevdir, getcwd(prevdir, 210));
                if (chdir(homedir) == -1)
                {
                    perror(RED "chdir" WHITE);
                    return -1;
                }
                printf("%s\n", homedir);
                strcpy(currdir, homedir);
            }
            // warp -
            else if (strcmp(path, "-") == 0)
            {
                if (strcmp(prevdir, currdir) == 0)
                {
                    printf("OLDPWD not set\n");
                }
                else
                    printf("%s\n", prevdir);
                char temp[strlen(prevdir) + 10];
                strcpy(temp, prevdir);
                strcpy(prevdir, getcwd(prevdir, 210));

                if (chdir(temp) == -1)
                {
                    perror(RED "chdir" WHITE);
                    return -1;
                }
                //  strcpy(prevdir, getcwd(prevdir, 210));
                strcpy(currdir, temp);
            }

            else
            {
                // warp .
                if (strcmp(path, ".") == 0)
                {
                    printf("%s\n", currdir);
                }
                // warp ..
                else if (strcmp(path, "..") == 0)
                {
                    strcpy(prevdir, getcwd(prevdir, 210));
                    if (chdir(path) == -1)
                    {
                        perror(RED "chdir" WHITE);
                        return -1;
                    }

                    char *str = (char *)malloc(sizeof(char) * strlen(currdir));
                    int i = 0;
                    for (i = strlen(currdir) - 1; i >= 0; i--)
                    {
                        if (currdir[i] == '/')
                        {
                            break;
                        }
                    }
                    for (int j = 0; j < i; j++)
                    {
                        str[j] = currdir[j];
                    }
                    str[strlen(str)] = '\0';
                    strcpy(currdir, str);
                    printf("%s\n", str);
                }

                // warp for paths and directory names
                else
                {

                    strcpy(prevdir, getcwd(prevdir, 210));

                    if (strcmp(run, "/") == 0 || chdir(path) == -1)
                    {

                        perror(RED "chdir" WHITE);
                        return -1;
                    }
                    strcpy(currdir, getcwd(currdir, 1024));
                    printf("%s\n", currdir);
                }
            }
        }

        else
        {
            temp[p] = run[k];
            p++;
        }
    }

    return 0;
}