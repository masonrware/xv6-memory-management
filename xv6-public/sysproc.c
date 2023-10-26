#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "psched.h"
#include "syscall.h"

/*
* BEGINNING OF ADDED CODE FOR P4
*/

/// @brief nice system call for proc to voluntarily decrease priority
/// @param n ticks count to set process priority to
/// @return the old nice value, pre replacement  
int
sys_nice(void)
{
  int n;
 
  if (argint(0, &n) < 0) return -1;

  if (n < 0 || n > 20) return -1;

  int prev_nice = myproc()->nice;
  myproc()->nice = n;
  return prev_nice;
}

/// @brief getschedstate system call for user process to view state of scheduled processes
/// @param pinfo user-provided structure for population with scheduler info
/// @return status code
int
sys_getschedstate(void) {
  struct pschedinfo* pinfo;

  if (argptr(0, (void*)&pinfo, sizeof(*pinfo)) < 0) return -1;
  if ((void *) pinfo == (void *) 0) return -1;

  populate_pschedinfo(pinfo);
  return 0;
}

/*
* END OF ADDED CODE FOR P4
*/

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;
    
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  
  myproc()->sleep_ticks = n;

  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }

  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}
