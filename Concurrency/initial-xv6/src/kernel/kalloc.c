// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;

int copy_frequency[PHYSTOP/PGSIZE];
struct spinlock lock1;

void
kinit()
{
  initlock(&kmem.lock, "kmem");
  freerange(end, (void*)PHYSTOP);
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    kfree(p);
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;
  int temp;
  // Checks if page is within the range of memory
  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

   acquire(&lock1);
  // decrease the reference count
  int index = (uint64)pa/PGSIZE;
  copy_frequency[index] -= 1;
  temp = copy_frequency[index];
  release(&lock1);
  if (temp > 0)
    return;

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  
  // inserting r at the beginning of freelist
  acquire(&kmem.lock);
  r = (struct run*)pa;
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  struct run *run_1;

  acquire(&kmem.lock);
  run_1 = kmem.freelist;

    if(run_1) {
    kmem.freelist = run_1->next;
    
    int index = (uint64)run_1 / PGSIZE;
    copy_frequency[index] = 1;

  }
  release(&kmem.lock);

  if(run_1)
    memset((char*)run_1, 5, PGSIZE); // fill with junk
  return (void*)run_1;
}
