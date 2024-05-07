#include "headers.h"
#include "A_2.h"

char *trim(char *run)
{

    char *trimmed = (char *)malloc(sizeof(char) * 1024);
    char *temp = (char *)malloc(sizeof(char) * 1024);
    char *temp2 = (char *)malloc(sizeof(char) * 1024);
    int i = 0;
    for (i = 0; i < strlen(run); i++)
    {
        if (run[i] != ' ' && run[i] != '\t')
        {
            break;
        }
    }
    int tempind = 0;
    for (int j = i; j < strlen(run); j++)
    {
        temp[tempind] = run[j];
        tempind++;
    }
    temp[tempind] = '\0';
    i = 0;
    int trimind = 0;
    for (i = tempind - 1; i >= 0; i--)
    {
        if (temp[i] != ' ' && temp[i] != '\t')
        {
            break;
        }
    }
    for (int j = 0; j <= i; j++)
    {
        trimmed[trimind] = temp[j];
        trimind++;
    }
    trimmed[trimind] = '\0';

    // REMOVING MIDDLE WHITESPACES
    tempind = 0;
    for (int i = 0; i < strlen(trimmed); i++)
    {
        if (i != (strlen(trimmed) - 1) && ((trimmed[i] == ' ' || trimmed[i] == '\t') && (trimmed[i + 1] != ' ' && trimmed[i + 1] != '\t')))
        {
            temp2[tempind] = ' ';
            temp2[tempind + 1] = trimmed[i + 1];
            tempind += 2;
            i++;
        }
        else if (i != (strlen(trimmed) - 1) && (trimmed[i] != ' ' && trimmed[i] != '\t' && (trimmed[i + 1] == ' ' || trimmed[i] == '\t')))
        {
            temp2[tempind] = trimmed[i];
            tempind++;
        }
        else if (i != (strlen(trimmed) - 1) && ((trimmed[i] == ' ' || trimmed[i] == '\t') && (trimmed[i + 1] == ' ' || trimmed[i + 1] == '\t')))
        {
        }
        else
        {
            temp2[tempind] = trimmed[i];
            tempind++;
        }
    }
    temp2[tempind] = '\0';

    return temp2;
}
