#ifndef __A_4_H
#define __A_4_H

char *permstring(struct stat fileInfo);
int is_exec(struct stat fileInfo);
int compare_entries(const void *a, const void *b);
void printfileinfo(const char *path, int id, char *input);
int bcount(const char *path, int id, char *input);
int peek(char *run, char *homedir, char *prevdir);
int peekonly(char *trimmed, char *homedir, char *prevdir);

#endif