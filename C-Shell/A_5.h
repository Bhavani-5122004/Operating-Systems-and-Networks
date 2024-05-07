#ifndef __A_5_H
#define __A_5_H

int pasteventsfunc(char **pastevents, int arrind, const char *trimmed, char *run, char *homedir, char *curr, int arrlen);
int purge(char **pastevents, char *trimmed, int arrind, char *homedir, char *currdir);
void execute(char **pastevents, char *trimmed, int arrind, char *homedir, char *curr, char *prev, char *input, int arrlen, char *com, int time1, int holdbgind, holdbg **holdbgarr);

#endif