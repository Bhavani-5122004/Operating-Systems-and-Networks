#include "headers.h"
#include "A_4.h"

#define GREEN "\x1b[32m"
#define WHITE "\x1b[0m"
#define BLUE "\033[0;34m"
#define RED "\033[0;31m"

// int total_blocks = 0;

// create string of the permissions
char *permstring(struct stat fileInfo)
{
    char *perm = (char *)malloc(sizeof(char) * 15);
    perm[0] = S_ISDIR(fileInfo.st_mode) ? 'd' : '-';
    perm[1] = fileInfo.st_mode & S_IRUSR ? 'r' : '-';
    perm[2] = fileInfo.st_mode & S_IWUSR ? 'w' : '-';
    perm[3] = fileInfo.st_mode & S_IXUSR ? 'x' : '-';
    perm[4] = fileInfo.st_mode & S_IRGRP ? 'r' : '-';
    perm[5] = fileInfo.st_mode & S_IWGRP ? 'w' : '-';
    perm[6] = fileInfo.st_mode & S_IXGRP ? 'x' : '-';
    perm[7] = fileInfo.st_mode & S_IROTH ? 'r' : '-',
    perm[8] = fileInfo.st_mode & S_IWOTH ? 'w' : '-',
    perm[9] = fileInfo.st_mode & S_IXOTH ? 'x' : '-',
    perm[10] = '\0';

    return perm;
}
// check if it is an executable
int is_exec(struct stat fileInfo)
{
    if (permstring(fileInfo)[3] == 'x')
    {
        return 1;
    }
    return 0;
}

// comparator function
int compare_entries(const void *a, const void *b)
{
    return strcmp((*(struct dirent **)a)->d_name, (*(struct dirent **)b)->d_name);
}

// printing file info for -l flag
void printfileinfo(const char *path, int id, char *input)
{
    struct stat fileInfo;

    if (stat(path, &fileInfo) == 0)
    {

        struct passwd *pOwnerInfo = getpwuid(fileInfo.st_uid);
        struct group *pGroupInfo = getgrgid(fileInfo.st_gid);
        char timeStr[80];
        if (is_exec(fileInfo))
        {
            strftime(timeStr, sizeof(timeStr), WHITE "%h %d %H:%M" WHITE, localtime(&(fileInfo.st_mtime)));

            printf(WHITE "%s %lu %s %s %ld %s " WHITE,
                   permstring(fileInfo),
                   fileInfo.st_nlink,
                   pOwnerInfo->pw_name,
                   pGroupInfo->gr_name,
                   fileInfo.st_size,
                   timeStr);
            printf(GREEN "%s\n" WHITE, input);
        }

        else if (id == 8)
        {
            strftime(timeStr, sizeof(timeStr), WHITE "%h %d %H:%M" WHITE, localtime(&(fileInfo.st_mtime)));

            printf(WHITE "%s %lu %s %s %ld %s " WHITE,
                   permstring(fileInfo),
                   fileInfo.st_nlink,
                   pOwnerInfo->pw_name,
                   pGroupInfo->gr_name,
                   fileInfo.st_size,
                   timeStr);
            printf(WHITE "%s\n" WHITE, input);
        }
        else if (id == 4)
        {
            strftime(timeStr, sizeof(timeStr), WHITE "%h %d %H:%M" WHITE, localtime(&(fileInfo.st_mtime)));

            printf(WHITE "%s %lu %s %s %ld %s " WHITE,
                   permstring(fileInfo),
                   fileInfo.st_nlink,
                   pOwnerInfo->pw_name,
                   pGroupInfo->gr_name,
                   fileInfo.st_size,
                   timeStr);
            printf(BLUE "%s\n" WHITE, input);
        }
        else
        {
            strftime(timeStr, sizeof(timeStr), WHITE "%b %d %H:%M" WHITE, localtime(&(fileInfo.st_mtime)));

            printf(WHITE "%s %lu %s %s %ld %s " WHITE,
                   permstring(fileInfo),
                   fileInfo.st_nlink,
                   pOwnerInfo->pw_name,
                   pGroupInfo->gr_name,
                   fileInfo.st_size,
                   timeStr);
            printf(WHITE "%s\n" WHITE, input);
        }
    }
}

// count total
int bcount(const char *path, int id, char *input)
{
    struct stat fileInfo;

    if (stat(path, &fileInfo) == 0)
    {

        total_blocks += fileInfo.st_blocks;
    }
    return 0;
}

int peek(char *run, char *homedir, char *prevdir)
{
    int flag = 0;
    char *temp = (char *)malloc(sizeof(char) * 1024);
    int j = 0;

    if (run[0] == '-')
    {
        // -a flag
        if (strncmp(run, "-a", 2) == 0 && strncmp(run, "-al", 3) != 0 && strncmp(run, "-a -l", 5) != 0)
        {

            for (int i = 0; i < strlen(run); i++)
            {
                if (i >= 3)
                {
                    temp[j] = run[i];
                    j++;
                }
            }

            flag = 1;
        }
        // -l flag
        else if (strncmp(run, "-l", 2) == 0 && strncmp(run, "-la", 3) != 0 && strncmp(run, "-l -a", 5) != 0)
        {
            for (int i = 0; i < strlen(run); i++)
            {
                if (i >= 3)
                {
                    temp[j] = run[i];
                    j++;
                }
            }
            flag = 2;
        }
        // -al and -la
        else if (strncmp(run, "-al", 3) == 0 || strncmp(run, "-la", 3) == 0)
        {
            for (int i = 0; i < strlen(run); i++)
            {
                if (i >= 4)
                {
                    temp[j] = run[i];
                    j++;
                }
            }
            if (strncmp(run, "-al", 3) == 0)
            {
                flag = 3;
            }
            else
            {
                flag = 4;
            }
        }
        // -a -l and -l -a
        else if (strncmp(run, "-a -l", 5) == 0 || strncmp(run, "-l -a", 5) == 0)
        {
            for (int i = 0; i < strlen(run); i++)
            {
                if (i >= 6)
                {
                    temp[j] = run[i];
                    j++;
                }
            }
            if (strncmp(run, "-a -l", 5) == 0)
            {
                flag = 5;
            }
            else
            {
                flag = 6;
            }
        }
        else if (strlen(run) == 1 && run[0] == '-')
        {
            temp[0] = '-';
            j = 1;
        }
        
        temp[j] = '\0';
        strcpy(run, temp);
    }

    // -a
    // create array of structs for my file names
    struct dirent **entries = (struct dirent **)malloc(sizeof(struct dirent *) * 100);
    for (int i = 0; i < 100; i++)
    {
        entries[i] = (struct dirent *)malloc(sizeof(struct dirent) * 100);
    }

    if (flag == 1)
    {
        char s[1000];
        DIR *dir = opendir(run);
        if (dir == NULL)
        {   
            // if no argument is passed
            
            if (strcmp(run, "") == 0)
            {
                dir = opendir(getcwd(s, 1000));
                strcpy(run, getcwd(s, 1000));
            }
            // peek ..
            else if (strncmp(run, "..", 2) == 0)
            {
                run = getcwd(run, 100);
                char *temprun = (char *)malloc(sizeof(char) * (strlen(run)));
                int tind2 = 0;
                int tind = 0;
                // remove the last folder from path
                for (tind = strlen(run) - 1; tind >= 0; tind--)
                {
                    if (run[tind] == '/')
                    {
                        break;
                    }
                }
                for (int q = 0; q < tind; q++)
                {
                    temprun[tind2] = run[q];
                    tind2++;
                }
                temprun[tind2] = '\0';
                strcpy(run, temprun);
            }

            else if (strncmp(run, ".", 1) == 0)
            {
                dir = opendir(getcwd(s, 100));
                run = getcwd(run, 100);
            }
            else if (strncmp(run, "-", 1) == 0)
            {
                dir = opendir(prevdir);
                strcpy(run, prevdir);
            }
            // for peek /
            else if (strncmp(run, "/", 1) == 0)
            {   
                char *slashpath = (char *)malloc(sizeof(char) * 1024);
                slashpath = getcwd(slashpath, 1024);
                strcat(slashpath, "/");
                strcat(slashpath, run + 1);
                
         if(dir = opendir(slashpath) == NULL){
            perror(RED "opendir" WHITE);
            return -1;
         }
                
                strcpy(run, slashpath);
            }
            else if (strncmp(run, "~", 1) == 0)
            {
                dir = opendir(homedir);
                strcpy(run, homedir);
            }
            else{
                if(dir = opendir(run) == NULL){
            perror(RED "opendir" WHITE);
            return -1;
         }
            }
            
        }
        struct dirent *path;

        int ind = 0;
        
        while ((path = readdir(dir)) != NULL)
        {

            if (path->d_type == DT_REG || path->d_type == DT_DIR || (strncmp(path->d_name, ".", 1) == 0))
            {

                entries[ind] = path;
                ind++;
            }
        }

        qsort(entries, ind, sizeof(struct dirent *), compare_entries);

        for (int i = 0; i < ind; i++)
        {
            char full_path[2056];
            snprintf(full_path, sizeof(full_path), "%s/%s", run, entries[i]->d_name);

            struct stat file_stat;

            if (stat(full_path, &file_stat) == 0 && (file_stat.st_mode & S_IXUSR))
            {
                printf(GREEN "%s\n" WHITE, entries[i]->d_name);
            }
            else if (entries[i]->d_type == DT_REG)
            {
                printf(WHITE "%s\n" WHITE, entries[i]->d_name);
            }
            else if (entries[i]->d_type == DT_DIR)
            {
                printf(BLUE "%s\n" WHITE, entries[i]->d_name);
            }
            else
            {
                printf("%s\n", entries[i]->d_name);
            }
        }
        

        closedir(dir);
    }

    // -l
    else if (flag == 2)
    {
        char s[1000];
        DIR *dir = opendir(run);
        if (dir == NULL)
        {

            if (strcmp(run, "") == 0)
            {

                dir = opendir(getcwd(s, 100));
                run = getcwd(run, 100);
            }
            else if (strncmp(run, "..", 2) == 0)
            {
                run = getcwd(run, 100);
                char *temprun = (char *)malloc(sizeof(char) * (strlen(run)));
                int tind2 = 0;
                int tind = 0;
                for (tind = strlen(run) - 1; tind >= 0; tind--)
                {
                    if (run[tind] == '/')
                    {
                        break;
                    }
                }
                for (int q = 0; q < tind; q++)
                {
                    temprun[tind2] = run[q];
                    tind2++;
                }
                temprun[tind2] = '\0';
                strcpy(run, temprun);
            }
            else if (strncmp(run, ".", 1) == 0)
            {
                dir = opendir(getcwd(s, 100));
                run = getcwd(run, 100);
            }
            else if (strncmp(run, "-", 1) == 0)
            {
                dir = opendir(prevdir);
                strcpy(run, prevdir);
            }
            else if (strncmp(run, "~", 1) == 0)
            {
                dir = opendir(homedir);
                strcpy(run, homedir);
            }
            else if (strncmp(run, "./", 2) == 0)
            {
                char *slashpath = (char *)malloc(sizeof(char) * 1024);
                slashpath = getcwd(slashpath, 1024);
                // strcat(slashpath,"/");
                strcat(slashpath, run + 1);

                if(dir = opendir(slashpath) == NULL){
            perror(RED "opendir" WHITE);
            return -1;
         }
                strcpy(run, slashpath);
            }
            else{
             perror(RED "opendir" WHITE);
            return -1;   
            }
        }

        struct dirent *path;

        int ind = 0;
        while ((path = readdir(dir)) != NULL)
        {

            if ((path->d_type == DT_REG || path->d_type == DT_DIR) && (strncmp(path->d_name, ".", 1) != 0))
            {

                entries[ind] = path;
                ind++;
            }
        }

        qsort(entries, ind, sizeof(struct dirent *), compare_entries);

        for (int i = 0; i < ind; i++)
        {

            char fullpath[500];
            snprintf(fullpath, sizeof(fullpath), "%s/%s", run, entries[i]->d_name);
            int id = entries[i]->d_type;

            int jjj = bcount(fullpath, id, entries[i]->d_name);
        }
        rewinddir(dir);
        ind = 0;
        printf("total %d\n", total_blocks / 2);
        total_blocks = 0;
        while ((path = readdir(dir)) != NULL)
        {

            if ((path->d_type == DT_REG || path->d_type == DT_DIR) && (strncmp(path->d_name, ".", 1) != 0))
            {

                entries[ind] = path;
                ind++;
            }
        }

        qsort(entries, ind, sizeof(struct dirent *), compare_entries);

        for (int i = 0; i < ind; i++)
        {

            char fullpath[500];
            snprintf(fullpath, sizeof(fullpath), "%s/%s", run, entries[i]->d_name);
            int id = entries[i]->d_type;

            printfileinfo(fullpath, id, entries[i]->d_name);
        }

        closedir(dir);
    }
    //-al or -a -l
    else if (flag == 3 || flag == 4 || flag == 5 || flag == 6)
    {
        char s[1000];
        DIR *dir = opendir(run);
        if (dir == NULL)
        {

            if (strcmp(run, "") == 0)
            {

                dir = opendir(getcwd(s, 100));
                run = getcwd(run, 100);
            }
            else if (strncmp(run, "..", 2) == 0)
            {
                run = getcwd(run, 100);
                char *temprun = (char *)malloc(sizeof(char) * (strlen(run)));
                int tind2 = 0;
                int tind = 0;
                for (tind = strlen(run) - 1; tind >= 0; tind--)
                {
                    if (run[tind] == '/')
                    {
                        break;
                    }
                }
                for (int q = 0; q < tind; q++)
                {
                    temprun[tind2] = run[q];
                    tind2++;
                }
                temprun[tind2] = '\0';
                strcpy(run, temprun);
            }
            else if (strncmp(run, ".", 1) == 0)
            {
                dir = opendir(getcwd(s, 100));
                run = getcwd(run, 100);
            }
            else if (strncmp(run, "-", 1) == 0)
            {
                dir = opendir(prevdir);
                strcpy(run, prevdir);
            }
            else if (strncmp(run, "/", 1) == 0)
            {
                char *slashpath = (char *)malloc(sizeof(char) * 1024);
                slashpath = getcwd(slashpath, 1024);
                strcat(slashpath, "/");
                strcat(slashpath, run + 1);

                 if(dir = opendir(slashpath) == NULL){
            perror(RED "opendir" WHITE);
            return -1;
         }
                strcpy(run, slashpath);
            }
            else if (strncmp(run, "~", 1) == 0)
            {
                dir = opendir(homedir);
                strcpy(run, homedir);
            }
            else{
                if(dir = opendir(run) == NULL){
            perror(RED "opendir" WHITE);
            return -1;
         }
            }
        }

        struct dirent *path;

        int ind = 0;
        while ((path = readdir(dir)) != NULL)
        {

            if ((path->d_type == DT_REG || path->d_type == DT_DIR))
            {

                entries[ind] = path;
                ind++;
            }
        }

        qsort(entries, ind, sizeof(struct dirent *), compare_entries);

        for (int i = 0; i < ind; i++)
        {

            char fullpath[500];
            snprintf(fullpath, sizeof(fullpath), "%s/%s", run, entries[i]->d_name);
            int id = entries[i]->d_type;

            int jjj = bcount(fullpath, id, entries[i]->d_name);
        }
        
        rewinddir(dir);
        ind = 0;
        printf("total %d\n", total_blocks / 2);
        total_blocks = 0;
        while ((path = readdir(dir)) != NULL)
        {

            if ((path->d_type == DT_REG || path->d_type == DT_DIR))
            {

                entries[ind] = path;
                ind++;
            }
        }

        qsort(entries, ind, sizeof(struct dirent *), compare_entries);

        for (int i = 0; i < ind; i++)
        {

            char fullpath[500];
            snprintf(fullpath, sizeof(fullpath), "%s/%s", run, entries[i]->d_name);
            int id = entries[i]->d_type;

            printfileinfo(fullpath, id, entries[i]->d_name);
        }

        closedir(dir);
    }

    // if peek path (no flag)
    else
    {

        char s[1000];
        DIR *dir = opendir(run);
        if (dir == NULL)
        {

            if (strncmp(run, "..", 2) == 0)
            {
                run = getcwd(run, 100);
                char *temprun = (char *)malloc(sizeof(char) * (strlen(run)));
                int tind2 = 0;
                int tind = 0;
                for (tind = strlen(run) - 1; tind >= 0; tind--)
                {
                    if (run[tind] == '/')
                    {
                        break;
                    }
                }
                for (int q = 0; q < tind; q++)
                {
                    temprun[tind2] = run[q];
                    tind2++;
                }
                temprun[tind2] = '\0';
                strcpy(run, temprun);
            }
            else if (strncmp(run, ".", 1) == 0)
            {
                dir = opendir(getcwd(s, 100));
                run = getcwd(run, 100);
            }
            else if (strncmp(run, "-", 1) == 0)
            {

                dir = opendir(prevdir);
                strcpy(run, prevdir);
            }
            else if (strncmp(run, "~", 1) == 0)
            {

                dir = opendir(homedir);
                strcpy(run, homedir);
            }
            else
            {

                perror(RED "Directory not found" WHITE);
                return -1;
            }
        }

        struct dirent *path;
      
        int ind = 0;
        // for the path given
        while ((path = readdir(dir)) != NULL)
        {

            if (path->d_type == DT_REG || path->d_type == DT_DIR && (strncmp(path->d_name, ".", 1) != 0))
            {

                entries[ind] = path;
                ind++;
            }
        }

        qsort(entries, ind, sizeof(struct dirent *), compare_entries);

        for (int i = 0; i < ind; i++)
        {
            char full_path[2056];
            snprintf(full_path, sizeof(full_path), "%s/%s", run, entries[i]->d_name);

            struct stat file_stat;

            if (stat(full_path, &file_stat) == 0 && (file_stat.st_mode & S_IXUSR))
            {
                printf(GREEN "%s\n" WHITE, entries[i]->d_name);
            }
            else if (entries[i]->d_type == DT_REG)
            {
                printf(WHITE "%s\n" WHITE, entries[i]->d_name);
            }
            else if (entries[i]->d_type == DT_DIR)
            {
                printf(BLUE "%s\n" WHITE, entries[i]->d_name);
            }
            else
            {
                printf("%s\n", entries[i]->d_name);
            }
        }

        closedir(dir);
    }
    return 0;
}

int peekonly(char *trimmed, char *homedir, char *prevdir)
{
    char s[100];
    DIR *dir = opendir(getcwd(s, 100));
    char *run1 = (char *)malloc(sizeof(char *) * 100);
    run1 = getcwd(run1, 100);
    struct dirent *path;

    int ind = 0;
    struct dirent **entries = (struct dirent **)malloc(sizeof(struct dirent *) * 100);
    for (int i = 0; i < 100; i++)
    {
        entries[i] = (struct dirent *)malloc(sizeof(struct dirent) * 100);
    }
    while ((path = readdir(dir)) != NULL)
    {

        if (path->d_type == DT_REG || path->d_type == DT_DIR && (strncmp(path->d_name, ".", 1) != 0))
        {

            entries[ind] = path;
            ind++;
        }
    }

    qsort(entries, ind, sizeof(struct dirent *), compare_entries);

    for (int i = 0; i < ind; i++)
    {
        char full_path[2056];
        snprintf(full_path, sizeof(full_path), "%s/%s", homedir, entries[i]->d_name);

        struct stat file_stat;

        if (stat(full_path, &file_stat) == 0 && (file_stat.st_mode & S_IXUSR))
        {
            printf(GREEN "%s\n" WHITE, entries[i]->d_name);
        }
        else if (entries[i]->d_type == DT_REG)
        {
            printf(WHITE "%s\n" WHITE, entries[i]->d_name);
        }
        else if (entries[i]->d_type == DT_DIR)
        {
            printf(BLUE "%s\n" WHITE, entries[i]->d_name);
        }
        else
        {
            printf("%s\n", entries[i]->d_name);
        }
    }

    closedir(dir);
    return 0;
}