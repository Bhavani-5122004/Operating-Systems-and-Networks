#include "headers.h"
#include "A_8.h"

#define GREEN "\x1b[32m"
#define WHITE "\x1b[0m"
#define BLUE "\033[0;34m"
#define RED "\033[0;31m"

// int countd = 0;
// int countf = 0;
// int checkfd = -1;

// check if entry is a directory
int satisfies_dir(struct dirent *entry, char *filename)
{
    if (entry->d_type == DT_DIR && strcmp(entry->d_name, filename) == 0)
    {
        return 1;
    }
    return 0;
}

// check if entry is a file
int satisfies_file(struct dirent *entry, char *filename, char *wext)
{
    if ((strcmp(entry->d_name, filename) == 0 || strcmp(wext, filename) == 0) && entry->d_type != DT_DIR)
    {
        return 1;
    }
    return 0;
}

// check for both entries and directories (print them)
int checkboth(char *path, char *filename, int flag, int check, char *rpath)
{
    DIR *dir;
    struct dirent *entry;
    struct stat curr;

    dir = opendir(path);
    if (dir == NULL)
    {

        return 1;
    }

    while ((entry = readdir(dir)) != NULL)
    {
        if (satisfies_dir(entry, filename))
        {
            char currpath[1024];
            snprintf(currpath, sizeof(currpath), "%s/%s", rpath, entry->d_name);
            printf(BLUE ".%s\n" WHITE, currpath);
            checkfd++;
            check = 0;
        }

        if (strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0)
        {
            char currpath[1024];
            snprintf(currpath, sizeof(currpath), "%s/%s", path, entry->d_name);
            char *wext = (char *)malloc(sizeof(char) * 300);
            int wind = 0;
            for (int i = 0; i < strlen(entry->d_name); i++)
            {
                if (entry->d_name[i] == '.')
                {
                    break;
                }
                else
                {
                    wext[wind] = entry->d_name[i];
                    wind++;
                }
            }
            wext[wind] = '\0';

            if (stat(currpath, &curr) == 0 && S_ISDIR(curr.st_mode))
            {
                char updatedrpath[1024];
                snprintf(updatedrpath, sizeof(updatedrpath), "%s/%s", rpath, entry->d_name);
                check = checkboth(currpath, filename, flag, check, updatedrpath);
            }
            else if (satisfies_file(entry, filename, wext))
            {
                char updatedrpath[1024];
                snprintf(updatedrpath, sizeof(updatedrpath), "%s/%s", rpath, entry->d_name);
                printf(GREEN ".%s\n" WHITE, updatedrpath);
                checkfd++;
                check = 0;
            }
        }
    }

    closedir(dir);
    return check;
}

// check for only directories (print them)
int checkdir(char *path, char *filename, int flag, int check, char *rpath)
{
    DIR *dir;
    struct dirent *entry;
    struct stat curr;

    dir = opendir(path);
    if (dir == NULL)
    {

        return 1;
    }

    while ((entry = readdir(dir)) != NULL)
    {
        if (satisfies_dir(entry, filename))
        {
            char currpath[1024];
            snprintf(currpath, sizeof(currpath), "%s/%s", path, entry->d_name);
            printf(BLUE ".%s\n" WHITE, currpath);
            checkfd++;
            check = 0;
        }

        if (strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0)
        {

            char currpath[1024];
            snprintf(currpath, sizeof(currpath), "%s/%s", path, entry->d_name);

            if (stat(currpath, &curr) == 0 && S_ISDIR(curr.st_mode))
            {
                char updatedrpath[1024];
                snprintf(updatedrpath, sizeof(updatedrpath), "%s/%s", rpath, entry->d_name);
                check = checkdir(currpath, filename, flag, check, updatedrpath);

                check = 0;
            }
        }
    }

    closedir(dir);
    return check;
}

// count number of directories
int countdir(char *path, char *filename, int count)
{
    DIR *dir;
    struct dirent *entry;
    struct stat curr;

    dir = opendir(path);
    if (dir == NULL)
    {

        return 1;
    }

    while ((entry = readdir(dir)) != NULL)
    {
        if (satisfies_dir(entry, filename))
        {
            char currpath[1024];
            snprintf(currpath, sizeof(currpath), "%s/%s", path, entry->d_name);

            count++;
            countd++;
        }

        if (strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0)
        {

            char currpath[1024];
            snprintf(currpath, sizeof(currpath), "%s/%s", path, entry->d_name);

            if (stat(currpath, &curr) == 0 && S_ISDIR(curr.st_mode))
            {

                count = countdir(currpath, filename, count);
            }
        }
    }

    closedir(dir);
    return count;
}

// check files only (print them)
int checkfile(char *path, char *filename, int flag, int check, char *rpath)
{
    DIR *dir;
    struct dirent *entry;
    struct stat curr;

    dir = opendir(path);
    if (dir == NULL)
    {

        return 1;
    }

    while ((entry = readdir(dir)) != NULL)
    {

        if (strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0)
        {

            char currpath[1024];
            snprintf(currpath, sizeof(currpath), "%s/%s", path, entry->d_name);
            char *wext = (char *)malloc(sizeof(char) * 300);
            int wind = 0;
            for (int i = 0; i < strlen(entry->d_name); i++)
            {
                if (entry->d_name[i] == '.')
                {
                    break;
                }
                else
                {
                    wext[wind] = entry->d_name[i];
                    wind++;
                }
            }
            wext[wind] = '\0';

            if (stat(currpath, &curr) == 0 && S_ISDIR(curr.st_mode))
            {
                char updatedrpath[1024];
                snprintf(updatedrpath, sizeof(updatedrpath), "%s/%s", rpath, entry->d_name);
                check = checkfile(currpath, filename, flag, check, updatedrpath);
            }
            else if (satisfies_file(entry, filename, wext))
            {
                char updatedrpath[1024];
                snprintf(updatedrpath, sizeof(updatedrpath), "%s/%s", rpath, entry->d_name);

                printf(GREEN ".%s\n" WHITE, updatedrpath);
                checkfd++;
                check = 0;
            }
        }
    }

    closedir(dir);
    return check;
}

// count number of files
int countfile(char *path, char *filename, int count)
{
    DIR *dir;
    struct dirent *entry;
    struct stat curr;

    dir = opendir(path);
    if (dir == NULL)
    {

        return 1;
    }

    while ((entry = readdir(dir)) != NULL)
    {

        if (strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0)
        {

            char currpath[1024];
            snprintf(currpath, sizeof(currpath), "%s/%s", path, entry->d_name);
            char *wext = (char *)malloc(sizeof(char) * 300);
            int wind = 0;
            for (int i = 0; i < strlen(entry->d_name); i++)
            {
                if (entry->d_name[i] == '.')
                {
                    break;
                }
                else
                {
                    wext[wind] = entry->d_name[i];
                    wind++;
                }
            }
            wext[wind] = '\0';

            if (stat(currpath, &curr) == 0 && S_ISDIR(curr.st_mode))
            {

                count = countfile(currpath, filename, count);
            }
            else if (satisfies_file(entry, filename, wext))
            {

                count++;
                countf++;
            }
        }
    }

    closedir(dir);
    return count;
}

// get the dir (if we only have on directory - to get path)
int getdir(char *path, char *filename, char *rpath, char *switch1)
{
    DIR *dir;
    struct dirent *entry;
    struct stat curr;

    dir = opendir(path);
    if (dir == NULL)
    {

        return 0;
    }

    while ((entry = readdir(dir)) != NULL)
    {
        if (satisfies_dir(entry, filename))
        {
            char currpath[1024];
            snprintf(currpath, sizeof(currpath), "%s/%s", path, entry->d_name);

            strcpy(switch1, currpath);
            return 1;
        }

        if (strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0)
        {

            char currpath[1024];
            snprintf(currpath, sizeof(currpath), "%s/%s", path, entry->d_name);

            if (stat(currpath, &curr) == 0 && S_ISDIR(curr.st_mode))
            {
                char updatedrpath[1024];
                snprintf(updatedrpath, sizeof(updatedrpath), "%s/%s", rpath, entry->d_name);
                int k1 = getdir(currpath, filename, updatedrpath, switch1);
            }
        }
    }

    closedir(dir);
    return 0;
}

// check files with permission and print ( for -e flags )
int checkfilep(char *path, char *filename, int flag, int check, char *rpath)
{
    DIR *dir;
    struct dirent *entry;
    struct stat curr;

    dir = opendir(path);
    if (dir == NULL)
    {

        return 1;
    }

    while ((entry = readdir(dir)) != NULL)
    {

        if (strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0)
        {

            char currpath[1024];
            snprintf(currpath, sizeof(currpath), "%s/%s", path, entry->d_name);
            char *wext = (char *)malloc(sizeof(char) * 300);
            int wind = 0;
            for (int i = 0; i < strlen(entry->d_name); i++)
            {
                if (entry->d_name[i] == '.')
                {
                    break;
                }
                else
                {
                    wext[wind] = entry->d_name[i];
                    wind++;
                }
            }
            wext[wind] = '\0';

            if (stat(currpath, &curr) == 0 && S_ISDIR(curr.st_mode))
            {
                char updatedrpath[1024];
                snprintf(updatedrpath, sizeof(updatedrpath), "%s/%s", rpath, entry->d_name);
                check = checkfilep(currpath, filename, flag, check, updatedrpath);
            }
            else if (satisfies_file(entry, filename, wext))
            {
                char updatedrpath[1024];
                snprintf(updatedrpath, sizeof(updatedrpath), "%s/%s", rpath, entry->d_name);
                char abs[2024];
                snprintf(abs, sizeof(abs), "%s/%s", path, entry->d_name);

                if (access(abs, R_OK) == -1)
                {
                    printf("Missing permissions for task!\n");
                    return 2;
                }
                printf(GREEN ".%s\n" WHITE, updatedrpath);
                check = 0;
            }
        }
    }

    closedir(dir);
    return check;
}

int findfile(char *path, char *currdir, char *homedir)
{

    int flag = 0;
    int is_path = 1;
    char *filename = (char *)malloc(sizeof(char) * 200);
    char *pathname = (char *)malloc(sizeof(char) * 200);
    int find = 0;
    int pind = 0;
    if (strncmp(path, "-d -f", 5) == 0 || strncmp(path, "-f -d", 5) == 0)
    {
        printf("Invalid flags!\n");
        return -1;
    }
    else if (strncmp(path, "-e -f", 5) == 0 || strncmp(path, "-f -e", 5) == 0)
    {
        flag = 4;
        int i = 0;

        for (i = 6; i < strlen(path); i++)
        {
            if (path[i] == ' ')
            {
                break;
            }
            else
            {
                filename[find] = path[i];
                find++;
            }
        }
        filename[find] = '\0';
        if (i == strlen(path))
        {
            is_path = 0;
        }
        else
        {
            for (int j = i + 1; j < strlen(path); j++)
            {
                pathname[pind] = path[j];
                pind++;
            }
            pathname[pind] = '\0';
        }
    }
    else if (strncmp(path, "-e -d", 5) == 0 || strncmp(path, "-d -e", 5) == 0)
    {
        int i = 0;

        for (i = 6; i < strlen(path); i++)
        {
            if (path[i] == ' ')
            {
                break;
            }
            else
            {
                filename[find] = path[i];
                find++;
            }
        }
        filename[find] = '\0';
        if (i == strlen(path))
        {
            is_path = 0;
        }
        else
        {
            for (int j = i + 1; j < strlen(path); j++)
            {
                pathname[pind] = path[j];
                pind++;
            }
            pathname[pind] = '\0';
        }
        flag = 5;
    }
    else if (strncmp(path, "-d", 2) == 0)
    {
        int i = 0;

        for (i = 3; i < strlen(path); i++)
        {
            if (path[i] == ' ')
            {
                break;
            }
            else
            {
                filename[find] = path[i];
                find++;
            }
        }
        filename[find] = '\0';
        if (i == strlen(path))
        {
            is_path = 0;
        }
        else
        {
            for (int j = i + 1; j < strlen(path); j++)
            {
                pathname[pind] = path[j];
                pind++;
            }
            pathname[pind] = '\0';
        }

        flag = 1;
    }
    else if (strncmp(path, "-f", 2) == 0)
    {
        int i = 0;

        for (i = 3; i < strlen(path); i++)
        {
            if (path[i] == ' ')
            {
                break;
            }
            else
            {
                filename[find] = path[i];
                find++;
            }
        }
        filename[find] = '\0';
        if (i == strlen(path))
        {
            is_path = 0;
        }
        else
        {
            for (int j = i + 1; j < strlen(path); j++)
            {
                pathname[pind] = path[j];
                pind++;
            }
            pathname[pind] = '\0';
        }
        flag = 2;
    }
    else if (strncmp(path, "-e", 2) == 0)
    {
        int i = 0;

        for (i = 3; i < strlen(path); i++)
        {
            if (path[i] == ' ')
            {
                break;
            }
            else
            {
                filename[find] = path[i];
                find++;
            }
        }
        filename[find] = '\0';
        if (i == strlen(path))
        {
            is_path = 0;
        }
        else
        {
            for (int j = i + 1; j < strlen(path); j++)
            {
                pathname[pind] = path[j];
                pind++;
            }
            pathname[pind] = '\0';
        }

        flag = 3;
    }

    else
    {
        int i = 0;
        
        for (i = 0; i < strlen(path); i++)
        {
            if (path[i] == ' ')
            {
                break;
            }
            else
            {
                filename[find] = path[i];
                find++;
            }
        }
        filename[find] = '\0';
        if (i == strlen(path))
        {
            is_path = 0;
        }
        else
        {
            for (int j = i + 1; j < strlen(path); j++)
            {
                pathname[pind] = path[j];
                pind++;
            }
            pathname[pind] = '\0';
        }
    }
    // if path is not given
    if (is_path == 0)
    {
        char *path2 = (char *)malloc(sizeof(char) * 300);
        strcpy(path2, "");
        strcpy(pathname, currdir);
        strcat(path2, pathname);
        strcpy(pathname, path2);
    }

    if (strncmp(pathname, "./", 2) == 0)
    {
        char *temp4 = (char *)malloc(sizeof(char) * 1000);
        strcpy(temp4, pathname + 1);
        strcpy(pathname, temp4);
        char *slashpath = (char *)malloc(sizeof(char) * 1024);
        slashpath = getcwd(slashpath, 1024);

        strcat(slashpath, pathname);
        strcpy(pathname, slashpath);
    }
    if (strncmp(pathname, "~", 1) == 0)
    {
        char *temp4 = (char *)malloc(sizeof(char) * 1000);
        strcpy(temp4, pathname + 1);
        strcpy(pathname, temp4);
        char *slashpath = (char *)malloc(sizeof(char) * 1024);
        strcpy(slashpath, homedir);
        
        char *tempslash = (char *)malloc(sizeof(char) * 1024);
        int tee = 0;
        strcpy(tempslash, slashpath);
        int hh;

        for (hh = strlen(slashpath) - 1; hh >= 0; hh--)
        {
            if (tempslash[hh] == '/')
            {
                break;
            }
        }
        for (int kkk = hh; kkk < strlen(slashpath); kkk++)
        {
            tempslash[tee] = slashpath[kkk];
            tee++;
        }
        tempslash[tee] = '\0';
        
        if (strcmp(tempslash, pathname) != 0)
        {
            strcat(slashpath, pathname);
            strcpy(pathname, slashpath);
        }
        else
        {
            strcpy(pathname, slashpath);
            
        }

        
    }
   
    int k = -1;
    if (flag == 0)
    {
        k = checkboth(pathname, filename, flag, -1, "");
        // if (k == -1)
        // {
        //     printf("No match found!\n");
        // }
        if (checkfd == -1)
        {
            printf("No match found!\n");
        }
        checkfd = -1;
    }
    // -d
    else if (flag == 1)
    {

        k = checkdir(pathname, filename, flag, -1, "");
        if (checkfd == -1)
        {
            printf("No match found!\n");
        }

        checkfd = -1;
    }
    // -f
    else if (flag == 2)
    {

        k = checkfile(pathname, filename, flag, -1, "");
        if (checkfd == -1)
        {
            printf("No match found!\n");
        }

        checkfd = -1;
    }
    // -e
    else if (flag == 3)
    {

        int dircount = countdir(pathname, filename, 0);
        int filecount = countfile(pathname, filename, 0);

        if ((countd == 0 && countf == 1) || (countd == 1 && countf == 0))
        {

            if ((countd == 0 && countf == 1))
            {

                char *relpath = (char *)malloc(sizeof(char) * 1024);
                strcpy(relpath, "");
                k = checkfilep(pathname, filename, flag, -1, relpath);
            }
            else
            {

                k = 0;
                char *swi = (char *)malloc(sizeof(char) * 1000);
                
                int ii = getdir(pathname, filename, "", swi);
                
                if (access(swi, X_OK) == -1)
                {

                    printf("Missing permissions for task!\n");
                    return 2;
                }
                if (chdir(swi) == -1)
                {
                    perror(RED "Cannot change directory" WHITE);
                    return 2;
                }
                strcpy(currdir, swi);
            }
        }
        else
        {

            k = checkboth(pathname, filename, flag, -1, "");
            if (checkfd == -1)
            {
                printf("No match found!\n");
            }
            checkfd = 0;
        }

        countd = 0;
        countf = 0;
    }
    // -e -f
    else if (flag == 4)
    {
        int dircount = countdir(pathname, filename, 0);
        int filecount = countfile(pathname, filename, 0);
        
        if ((countd == 0 && countf == 1))
        {

            char *relpath = (char *)malloc(sizeof(char) * 1024);
            strcpy(relpath, "");
            k = checkfilep(pathname, filename, flag, -1, relpath);
        }
        else
        {

            k = checkfile(pathname, filename, flag, -1, "");
            if (checkfd == -1)
            {
                printf("No match found!\n");
            }
            checkfd = -1;
        }
        countd = 0;
        countf = 0;
    }
    // -e -d
    else if (flag == 5)
    {
        int dircount = countdir(pathname, filename, 0);
        int filecount = countfile(pathname, filename, 0);

        if ((countd == 1 && countf == 0))
        {

            k = 0;
            char *swi = (char *)malloc(sizeof(char) * 1000);
            int ii = getdir(pathname, filename, "", swi);

            if (access(swi, X_OK) == -1)
            {

                printf("Missing permissions for task!\n");
                return 2;
            }

            if (chdir(swi) == -1)
            {
                perror(RED "Cannot change directory" WHITE);
                return 2;
            }
            strcpy(currdir, swi);
        }

        else
        {
            k = checkdir(pathname, filename, flag, -1, "");
            if (checkfd == -1)
            {
                printf("No match found!\n");
            }
            checkfd = -1;
        }
        countd = 0;
        countf = 0;
    }

    return 0;
}