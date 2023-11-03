//
// File-system system calls.
// Mostly argument checking, since we don't trust
// user code, and calls into file.c and fs.c.
//

#include "types.h"
#include "defs.h"
#include "param.h"
#include "stat.h"
#include "mmu.h"
#include "proc.h"
#include "fs.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "file.h"
#include "fcntl.h"

#include "mmap.h"
#include "memlayout.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
  int fd;
  struct file *f;

  if (argint(n, &fd) < 0)
    return -1;
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    return -1;
  if (pfd)
    *pfd = fd;
  if (pf)
    *pf = f;
  return 0;
}

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for (fd = 0; fd < NOFILE; fd++)
  {
    if (curproc->ofile[fd] == 0)
    {
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
}

int sys_dup(void)
{
  struct file *f;
  int fd;

  if (argfd(0, 0, &f) < 0)
    return -1;
  if ((fd = fdalloc(f)) < 0)
    return -1;
  filedup(f);
  return fd;
}

int sys_read(void)
{
  struct file *f;
  int n;
  char *p;

  if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
    return -1;
  return fileread(f, p, n);
}

int sys_write(void)
{
  struct file *f;
  int n;
  char *p;

  if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
    return -1;
  return filewrite(f, p, n);
}

int sys_close(void)
{
  int fd;
  struct file *f;

  if (argfd(0, &fd, &f) < 0)
    return -1;
  myproc()->ofile[fd] = 0;
  fileclose(f);
  return 0;
}

int sys_fstat(void)
{
  struct file *f;
  struct stat *st;

  if (argfd(0, 0, &f) < 0 || argptr(1, (void *)&st, sizeof(*st)) < 0)
    return -1;
  return filestat(f, st);
}

// Create the path new as a link to the same inode as old.
int sys_link(void)
{
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if (argstr(0, &old) < 0 || argstr(1, &new) < 0)
    return -1;

  begin_op();
  if ((ip = namei(old)) == 0)
  {
    end_op();
    return -1;
  }

  ilock(ip);
  if (ip->type == T_DIR)
  {
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if ((dp = nameiparent(new, name)) == 0)
    goto bad;
  ilock(dp);
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0)
  {
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
  iput(ip);

  end_op();

  return 0;

bad:
  ilock(ip);
  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  end_op();
  return -1;
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de))
  {
    if (readi(dp, (char *)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if (de.inum != 0)
      return 0;
  }
  return 1;
}

// PAGEBREAK!
int sys_unlink(void)
{
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if (argstr(0, &path) < 0)
    return -1;

  begin_op();
  if ((dp = nameiparent(path, name)) == 0)
  {
    end_op();
    return -1;
  }

  ilock(dp);

  // Cannot unlink "." or "..".
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if ((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
  ilock(ip);

  if (ip->nlink < 1)
    panic("unlink: nlink < 1");
  if (ip->type == T_DIR && !isdirempty(ip))
  {
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
  if (writei(dp, (char *)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  if (ip->type == T_DIR)
  {
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);

  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);

  end_op();

  return 0;

bad:
  iunlockput(dp);
  end_op();
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    return 0;
  ilock(dp);

  if ((ip = dirlookup(dp, name, 0)) != 0)
  {
    iunlockput(dp);
    ilock(ip);
    if (type == T_FILE && ip->type == T_FILE)
      return ip;
    iunlockput(ip);
    return 0;
  }

  if ((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");

  ilock(ip);
  ip->major = major;
  ip->minor = minor;
  ip->nlink = 1;
  iupdate(ip);

  if (type == T_DIR)
  {              // Create . and .. entries.
    dp->nlink++; // for ".."
    iupdate(dp);
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  if (dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}

int sys_open(void)
{
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if (argstr(0, &path) < 0 || argint(1, &omode) < 0)
    return -1;

  begin_op();

  if (omode & O_CREATE)
  {
    ip = create(path, T_FILE, 0, 0);
    if (ip == 0)
    {
      end_op();
      return -1;
    }
  }
  else
  {
    if ((ip = namei(path)) == 0)
    {
      end_op();
      return -1;
    }
    ilock(ip);
    if (ip->type == T_DIR && omode != O_RDONLY)
    {
      iunlockput(ip);
      end_op();
      return -1;
    }
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0)
  {
    if (f)
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
  end_op();

  f->type = FD_INODE;
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
  return fd;
}

int sys_mkdir(void)
{
  char *path;
  struct inode *ip;

  begin_op();
  if (argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0)
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
  end_op();
  return 0;
}

int sys_mknod(void)
{
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if ((argstr(0, &path)) < 0 ||
      argint(1, &major) < 0 ||
      argint(2, &minor) < 0 ||
      (ip = create(path, T_DEV, major, minor)) == 0)
  {
    end_op();
    return -1;
  }
  iunlockput(ip);
  end_op();
  return 0;
}

int sys_chdir(void)
{
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();

  begin_op();
  if (argstr(0, &path) < 0 || (ip = namei(path)) == 0)
  {
    end_op();
    return -1;
  }
  ilock(ip);
  if (ip->type != T_DIR)
  {
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
  iput(curproc->cwd);
  end_op();
  curproc->cwd = ip;
  return 0;
}

int sys_exec(void)
{
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if (argstr(0, &path) < 0 || argint(1, (int *)&uargv) < 0)
  {
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for (i = 0;; i++)
  {
    if (i >= NELEM(argv))
      return -1;
    if (fetchint(uargv + 4 * i, (int *)&uarg) < 0)
      return -1;
    if (uarg == 0)
    {
      argv[i] = 0;
      break;
    }
    if (fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
}

int sys_pipe(void)
{
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if (argptr(0, (void *)&fd, 2 * sizeof(fd[0])) < 0)
    return -1;
  if (pipealloc(&rf, &wf) < 0)
    return -1;
  fd0 = -1;
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0)
  {
    if (fd0 >= 0)
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
  fd[1] = fd1;
  return 0;
}

/*
 * P5 CODE
 */

// void create_vma(struct vm_area *prev, struct vm_area *next, uint start, int len, int prot, int flags, int fd)
// {
//   struct vm_area *vma = 0;

//   vma->valid = 1;
//   vma->start = start;
//   vma->end = PGROUNDUP(start+len)-1;
//   vma->len = vma->end - start;
//   vma->prot = prot;
//   vma->flags = flags;
//   vma->fd = fd;
//   vma->space_after = next->start - vma->end;
//   vma->f = myproc()->ofile[fd];
//   vma->next = next;

//   prev->next = vma;
// }

// TODO implement below to read a file into user space
// int mmap_read(struct file *f, uint va, int offset, int size) {
//   return 0;
// }

/*
* COPIED CODE FROM VM.C
*/

// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
// static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
//   pde_t *pde;
//   pte_t *pgtab;

//   pde = &pgdir[PDX(va)];
//   if(*pde & PTE_P){
//     pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
//   } else {
//     if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
//       return 0;
//     // Make sure all those PTE_P bits are zero.
//     memset(pgtab, 0, PGSIZE);
//     // The permissions here are overly generous, but they can
//     // be further restricted by the permissions in the page table
//     // entries, if necessary.
//     *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
//   }
//   return &pgtab[PTX(va)];
// }

// // Create PTEs for virtual addresses starting at va that refer to
// // physical addresses starting at pa. va and size might not
// // be page-aligned.
// static int
// mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
// {
//   char *a, *last;
//   pte_t *pte;

//   a = (char*)PGROUNDDOWN((uint)va);
//   last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
//   for(;;){
//     if((pte = walkpgdir(pgdir, a, 1)) == 0)
//       return -1;
//     if(*pte & PTE_P)
//       panic("remap");
//     *pte = pa | perm | PTE_P;
//     if(a == last)
//       break;
//     a += PGSIZE;
//     pa += PGSIZE;
//   }
//   return 0;
// }

/*
* END COPIED CODE FROM VM.C
*/
int
sys_mmap(void)
{
  void *addr;
  int len, prot, flags, fd, offset;
  if (argint(0, (int*)&addr) < 0 || argint(1, &len) < 0 || argint(2, &prot) < 0 ||
      argint(3, &flags) < 0 || argint(4, &fd) < 0 || argint(5, &offset) < 0)
    return -1;
  return mmap(addr, len, prot, flags, fd, offset);
}

int
mmap(void *addr, int len, int prot, int flags, int fd, int offset)
{
  struct proc *curproc = myproc();
  uint start = (uint)addr;
  uint end = start + len;
  uint addr_offset = 0;

  if (start != 0) {
    // Ensure that the address is page-aligned
    if (PGROUNDUP(start) != start) {
      cprintf("mmap: Address not page-aligned\n");
      return -1;
    }
  }

  // Check flags for supported options
  if (flags & ~MAP_ANON) {
    cprintf("mmap: Unsupported flags\n");
    return -1;
  }

  if (len <= 0) {
    cprintf("mmap: Invalid length\n");
    return -1;
  }

  if (len > PGSIZE) {
    cprintf("mmap: Mapping too large\n");
    return -1;
  }

  if (flags & MAP_ANON) {
    // Anonymous memory mapping, allocate physical memory
    for (uint a = start; a < end; a += PGSIZE) {
      pde_t *pde = walkpgdir(curproc->pgdir, (char*)a, 1);
      if (!pde) {
        cprintf("mmap: Page directory entry allocation failed\n");
        return -1;
      }
      pte_t *pte = mappages(curproc->pgdir, (void*)a, PGSIZE, prot);
      if (!pte) {
        cprintf("mmap: Page table entry allocation failed\n");
        return -1;
      }
      if ((pte = walkpgdir(curproc->pgdir, (void*)a, 0)) == 0)
        panic("mmap: walkpgdir");
      char *mem = kalloc();
      if (mem == 0) {
        cprintf("mmap: kalloc failed\n");
        return -1;
      }
      memset(mem, 0, PGSIZE);
      if (mappages(curproc->pgdir, (void*)a, PGSIZE, V2P(mem) | prot) < 0) {
        cprintf("mmap: mappages failed\n");
        kfree(mem);
        return -1;
      }
      addr_offset += PGSIZE;
    }
  } else {
    // File-backed mapping
    struct file *f;
    if (fd < 0 || (f = curproc->ofile[fd]) == 0) {
      cprintf("mmap: Invalid file descriptor\n");
      return -1;
    }
    
    // TODO: Implement file-backed mapping using the file 'f' and 'offset'.
  }

  return (int)(start + addr_offset);
}


int sys_munmap(void)
{
  // void *addr, int length
  void *addr;
  int length;
  uint arg_addr;
  uint end_addr;
  struct vm_area *vm = 0;

  // invalid arg check
  if (argptr(0, (char **)&addr, sizeof(void *)) < 0 || argint(1, &length) < 0)
    return -1;

  arg_addr = (uint)addr;

  // address not multiple of PGSIZE or out of bounds
  if (arg_addr % PGSIZE != 0 || arg_addr < MIN_ADDR || arg_addr >= MAX_ADDR)
    return -1;

  struct proc *p = myproc();
  end_addr = arg_addr + length;

  struct vm_area curr = p->head;
  struct vm_area *prev = &curr;

  // iterate through VMAs to find VM to free
  while (curr.start != MAX_ADDR)
  {
    if (arg_addr == curr.start)
    {
      vm = &curr;
      break;
    }
    prev = &curr;
    curr = *curr.next;
  }

  // no mapping found
  if (vm == (void *)0)
    return -1;

  // write back to file if shared flag is set
  if (vm->flags & MAP_SHARED)
  {
    // TODO: file backed mapping write back
  }

  // TODO: remove mappings from page table?

  // mark end of freed memory at the next highest page
  end_addr = PGROUNDUP(end_addr) - 1;

  // remove entire mapping block: | A | A | A | ->  |   |   |   |
  if (arg_addr == vm->start)
  {
    vm->valid = 1;                // make mem block available
    prev->next = vm->next;        // link previous block to next block after curr (unlink curr)
    prev->space_after += vm->len; // add space from unlinked block to space avail. after previous block
  }
  return 0;
}

/*
* END P5 CODE
*/
