#ifndef __A_8_H
#define __A_8_H

int satisfies_dir(struct dirent *entry, char *filename);
int satisfies_file(struct dirent *entry, char *filename, char *wext);
int checkboth(char *path, char *filename, int flag, int check, char *rpath);
int checkdir(char *path, char *filename, int flag, int check, char *rpath);
int countdir(char *path, char *filename, int count);
int checkfile(char *path, char *filename, int flag, int check, char *rpath);
int countfile(char *path, char *filename, int count);
int getdir(char *path, char *filename, char *rpath, char *switch1);
int checkfilep(char *path, char *filename, int flag, int check, char *rpath);
int findfile(char *path, char *currdir, char *homedir);

#endif
