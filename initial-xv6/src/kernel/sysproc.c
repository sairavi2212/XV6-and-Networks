#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  struct proc *p = myproc();
  struct proc *parent = p->parent;
  if (p != 0 && parent != 0)
  {
    for (int i = 0; i < 32; i++)
    {
      parent->syscall_cnt[i] += p->syscall_cnt[i];
    }
  }
  exit(n);
  return 0; // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if (growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n)
  {
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_waitx(void)
{
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
  argaddr(1, &addr1); // user virtual memory
  argaddr(2, &addr2);
  int ret = waitx(addr, &wtime, &rtime);
  struct proc *p = myproc();
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    return -1;
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    return -1;
  return ret;
}

uint64 sys_getSysCount(void)
{
  int mask, syscall_index;
  struct proc *p = myproc();
  argint(0, &mask);
  if (mask == 0 || (mask & (mask - 1)) != 0)
    return -1; // Invalid mask, not a power of 2

  // Find the index of the syscall corresponding to the mask
  syscall_index = 0;
  while (mask > 1)
  {
    syscall_index++;
    mask >>= 1;
  }

  if (syscall_index >= 32)
    return -1;

  return p->syscall_cnt[syscall_index];
}

uint64
sys_sigalarm(void)
{
  uint64 handler;
  int total_ticks;
  argint(0, &total_ticks);
  argaddr(1, &handler);

  struct proc *p = myproc();
  p->handler = handler;
  p->total_ticks = total_ticks;
  p->alarm_state = 0;
  p->ticks = 0;

  return 0;
}

uint64
sys_sigreturn(void)
{
  struct proc *p = myproc();
  memmove(p->trapframe, p->backup, sizeof(struct trapframe));
  p->ticks = 0;
  p->alarm_state = 0;
  usertrapret();
  return 0;
}

uint64 sys_settickets(void){
  int tickets;
  argint(0,&tickets);
  myproc()->tickets=tickets;
  return 0;
}