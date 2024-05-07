#ifndef __A_6_H
#define __A_6_H

int syscom(char *trimmed);
int bgupdate(char *bg, int pid, holdbg **holdbgarr, int holdbgind);
int bgcom(char *trimmed, holdbg **holdbgarr, int holdbgind);

#endif
