#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

struct spinlock tickslock;
uint ticks;
// int ec1;
// int ec2;
// int ec3;
// int ec4;

extern char trampoline[], uservec[], userret[];

// in kernelvec.S, calls kerneltrap().
void kernelvec();

extern int devintr();

void trapinit(void)
{
  initlock(&tickslock, "time");
}

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
  w_stvec((uint64)kernelvec);
}

//
// handle an interrupt, exception, or system call from user space.
// called from trampoline.S
//
void usertrap(void)
{
  int which_dev = 0;

  if ((r_sstatus() & SSTATUS_SPP) != 0)
    panic("usertrap: not from user mode");

  // send interrupts and exceptions to kerneltrap(),
  // since we're now in the kernel.
  w_stvec((uint64)kernelvec);

  struct proc *p = myproc();

  // save user program counter.
  p->trapframe->epc = r_sepc();

  if (r_scause() == 8)
  {
    // system call

    if (killed(p))
      exit(-1);

    // sepc points to the ecall instruction,
    // but we want to return to the next instruction.
    p->trapframe->epc += 4;
   
    // an interrupt will change sepc, scause, and sstatus,
    // so enable only now that we're done with those registers.
    intr_on();

    syscall();
  }
  else if ((which_dev = devintr()) != 0)
  {
    if(which_dev==1){
      #ifdef MLFQ
     // printf("**%d %d\n",myproc()->pid,myproc()->priority);
      yield();
    #endif
    }
    
    else if (which_dev == 2 && p->alarm_on == 0) {
    
      p->alarm_on = 1;
      int flag = 0;
        // If the time elapsed is more than the value passed
     if ((p->temp_ticks - ticks) >= p->maxticks){
          flag = 1;
          p->address = 0;
          p->temp_ticks = 0;
          p->maxticks = 0;
          //p->trapframe->epc = p->address;
          
          

        }
      p->temp_trapframe = kalloc();
     if(p->temp_trapframe && p->trapframe){
      // To set the temp trapframe to the current one
     memmove(p->temp_trapframe, p->trapframe, 4096);
     
   //  p->numticks+=1;
     
     if(flag == 1){
      // In case address of the handler changes due to repeated calling of the handler
      int tf_a0 = p->temp_trapframe->a0;
      p->trapframe->a0 = tf_a0;
      if(p->temp_address!=p->address){
       p->trapframe->epc = p->temp_address;
      }
      else{
         p->trapframe->epc = p->address;
      }
     
     }

  
        
     }
     else{
      return ;
     }
    
       
       
  }
  }
  
  else
  {
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    setkilled(p);
  }

  if (killed(p))
    exit(-1);

  // give up the CPU if this is a timer interrupt.
else if (which_dev == 1){
  #ifdef MLFQ
  p->numticks=0;
  yield();
  #endif
}

 else if (which_dev == 2){
  
  #ifdef RR
 
  yield();
  #else
  #ifdef FCFS
 
  #else
  #ifdef MLFQ
  struct proc* p = myproc();
   p->numticks5++;
   p->boost++;

if(p->boost>35){
      
   
        if(p->priority==0){
      
          p->priority=0;
      
        }
        else if(p->priority==1){
          ec2--;
          ec1++;
          p->priority=0;
          p->enter=ticks;
        }
        else if(p->priority==2){
          ec3--;
          ec2++;
          p->priority=1;
          p->enter=ticks;
        }
        else if(p->priority==3){
          ec4--;
          ec3++;
          p->priority=2;
          p->enter=ticks;
        }
       
        p->numticks5=0;
        p->boost=0;
        yield();
       
        
       }
 if(p->numticks5>=1 && p->priority==0){
        p->priority=1;
       p->numticks5=0;
    
       p->boost=0;
   
      p->enter=ticks;
      
      ec1--;
      ec2++;
        yield();
        // p->priority=1;
    }
    if(p->numticks5>=3 && p->priority==1){
       p->priority=2;
       p->numticks5=0;
 
        p->boost=0;
        p->enter=ticks;
        ec2--;
        ec3++;
     
       yield();
      }
     
    if(p->numticks5>=9 && p->priority==2){
      p->priority=3;
      p->numticks5=0;
       p->boost=0;
       p->enter=ticks;
      ec3--;
      ec4++;
   yield();
    }

  
  #endif
  #endif
  #endif
  }
  else if(which_dev==1)
  {
    #ifdef MLFQ
    yield();
    #endif
  }
  


  
    

  usertrapret();
}

//
// return to user space
//
void usertrapret(void)
{
  struct proc *p = myproc();

  // we're about to switch the destination of traps from
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
  p->trapframe->kernel_trap = (uint64)usertrap;
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()

  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
  x |= SSTATUS_SPIE; // enable interrupts in user mode
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64))trampoline_userret)(satp);

 
  

 
}

// interrupts and exceptions from kernel code go here via kernelvec,
// on whatever the current kernel stack is.

void kerneltrap()
{
  int which_dev = 0;
  uint64 sepc = r_sepc();
  uint64 sstatus = r_sstatus();
  uint64 scause = r_scause();

  if ((sstatus & SSTATUS_SPP) == 0)
    panic("kerneltrap: not from supervisor mode");
  if (intr_get() != 0)
    panic("kerneltrap: interrupts enabled");

  if ((which_dev = devintr()) == 0)
  {
    printf("scause %p\n", scause);
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    panic("kerneltrap");
  }
//  if(which_dev==1){
//     #ifdef MLFQ
//      // printf("**%d %d\n",myproc()->pid,myproc()->priority);
//     //  yield();
//     #endif
//     }
  // give up the CPU if this is a timer interrupt.
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
  {
 

  #ifdef RR
 
  yield();
  #else
  #ifdef FCFS
 
  #else
  #ifdef MLFQ
  struct proc* p = myproc();
  //  p->numticks++;
  //  p->boost++;
 
       if(p->boost>2){
    //  struct proc* p1;
      // for(p = proc;p<&proc[NPROC];p++){
        if(p->priority==0){
          ec1++;
          p->priority=0;
         // p->enter=ticks;
        }
        else if(p->priority==1){
          ec2--;
          ec1++;
          p->priority=0;
          p->enter=ticks;
        }
        else if(p->priority==2){
          ec3--;
          ec2++;
          p->priority=1;
          p->enter=ticks;
        }
        else if(p->priority==3){
          ec4--;
          ec3++;
          p->priority=2;
          p->enter=ticks;
        }
       
        // p->numticks=0;
        // p->boost=0;
       
        
      // }
      
    }
else if(p->numticks>=1 && p->priority==0){
      p->priority=1;
      p->numticks=0;
      //p->state=RUNNABLE;
      p->boost=0;
      p->enter=ticks;
      ec1--;
      ec2++;
      yield();
    }
     else if(p->numticks>=3 && p->priority==1){
      p->priority=2;
      p->numticks=0;
      //p->state=RUNNABLE;
       p->boost=0;
       p->enter=ticks;
      ec2--;
      ec3++;
      yield();
    }
    else if(p->numticks>=9 && p->priority==2){
      p->priority=3;
      p->numticks=0;
      //p->state=RUNNABLE;
       p->boost=0;
       p->enter=ticks;
      ec3--;
      ec4++;
      yield();
    }
    else{
      //printf("HIIIII");
      p->numticks++;
    }
  
  #endif
  #endif
  #endif
  }
  // if(which_dev==1){
  //   #ifdef MLFQ
  //   struct proc* p=myproc();
  //   p->numticks=0;
  //     yield();
  //     #endif
  //   }
    

  // the yield() may have caused some traps to occur,
  // so restore trap registers for use by kernelvec.S's sepc instruction.
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
  acquire(&tickslock);
  ticks++;
  update_time();
  // for (struct proc *p = proc; p < &proc[NPROC]; p++)
  // {
  //   acquire(&p->lock);
  //   if (p->state == RUNNING)
  //   {
  //     printf("here");
  //     p->rtime++;
  //   }
  //   // if (p->state == SLEEPING)
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
  release(&tickslock);
}

// check if it's an external interrupt or software interrupt,
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
      (scause & 0xff) == 9)
  {
    // this is a supervisor external interrupt, via PLIC.

    // irq indicates which device interrupted.
    int irq = plic_claim();

    if (irq == UART0_IRQ)
    {
      uartintr();
    }
    else if (irq == VIRTIO0_IRQ)
    {
      virtio_disk_intr();
    }
    else if (irq)
    {
      printf("unexpected interrupt irq=%d\n", irq);
    }

    // the PLIC allows each device to raise at most one
    // interrupt at a time; tell the PLIC the device is
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
  {
    // software interrupt from a machine-mode timer interrupt,
    // forwarded by timervec in kernelvec.S.

    if (cpuid() == 0)
    {
      clockintr();
    }

    // acknowledge the software interrupt by clearing
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  }
  else
  {
    return 0;
  }
}
