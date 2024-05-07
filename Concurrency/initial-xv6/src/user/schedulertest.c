#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/riscv.h"
#include "user/user.h"

#define NFORK 10
#define IO 5

int main(int argc, char *argv[])
{
  int n, pid;
  int wtime, rtime;
  int twtime = 0, trtime = 0;
 
  for (n = 0; n < NFORK; n++)
  {
    pid = fork();
   
    if (pid < 0)
      break;
    if (pid == 0)
    {
      if (n < IO)
      {
        #ifdef PBS
        int set = setpriority(pid,0);
        if(set == 1){
         // printf("YES\n");
        }
        #endif
        
        
        sleep(200); // IO bound processes
        
        
      }
      else
      {
      
        for (volatile int i = 0; i < 1000000000; i++)
        {
        } // CPU bound process
      }
      // printf("Process %d finished\n", n);
      exit(0);
    }
  }
  for (; n > 0; n--)
  {
    if (waitx(0, &wtime, &rtime) >= 0)
    {
      trtime += rtime;
      twtime += wtime;
    }
  }
  printf("Average rtime %d,  wtime %d\n", trtime / NFORK, twtime / NFORK);
  exit(0);
}