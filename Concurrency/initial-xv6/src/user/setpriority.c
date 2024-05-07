#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/riscv.h"
#include "user/user.h"


int main(int argc, char *argv[]){

    int a = setpriority(atoi(argv[1]),atoi(argv[2]));
    printf("Change Priority: %d\n",a);

    return 0;
}
