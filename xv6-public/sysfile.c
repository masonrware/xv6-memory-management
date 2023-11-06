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
 * P5 SYSCALL CODE
 */

/*
 * COPIED CODE FROM VM.C
 */

// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  if (*pde & PTE_P)
  {
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
  }
  else
  {
    if (!alloc || (pgtab = (pte_t *)kalloc()) == 0)
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
}

// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
  char *a, *last;
  pte_t *pte;

  a = (char *)PGROUNDDOWN((uint)va);
  last = (char *)PGROUNDDOWN(((uint)va) + size - 1);

  uint pa_phys = V2P(pa); // V2P test

  for (;;)
  {
    if ((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if (*pte & PTE_P)
      panic("remap");
    *pte = pa_phys | perm | PTE_P; // V2P test
    if (a == last)
      break;
    a += PGSIZE;
    pa_phys += PGSIZE; // V2P test
  }
  return 0;
}

/*
 * END COPIED CODE FROM VM.C
 */

struct vm_area *create_vma(struct vm_area *prev, struct vm_area *next, uint start, int len, int prot, int flags, int fd)
{
  struct vm_area *vma = (struct vm_area*)kalloc();
  vma->valid = 1;
  vma->start = start;
  vma->end = PGROUNDUP(start + len) - 1;
  vma->len = vma->end - start;
  vma->prot = prot;
  vma->flags = flags;
  vma->fd = fd;
  vma->space_after = next->start - vma->end;
  vma->f = myproc()->ofile[fd];
  vma->next = next;
  prev->next = vma;
  return vma;
}

int mmap_read(struct file *f, uint va, int off, int size)
{
  ilock(f->ip);
  // read to user space VA.
  int n = readi(f->ip, (char *) va, off, size);
  off += n;
  iunlock(f->ip);
  return off;
}

int sys_mmap(void)
{
  int addr;
  int length;
  int prot;
  int flags;
  int fd;
  int offset;



  // invalid arg check
  if (argint(0, &addr) < 0 ||
      argint(1, &length) < 0 ||
      argint(2, &prot) < 0 ||
      argint(3, &flags) < 0 ||
      argint(4, &fd) < 0 ||
      argint(5, &offset) < 0)
  {
    cprintf("ARG ERR\n");
    return -1;
  }

  struct proc *p = myproc();

  uint start_addr = 0;
  // cast param to uint
  uint arg_addr = (uint)addr;

  // We must use the provided address
  if (flags & MAP_FIXED)
  {
    // if the address provided is not page-addressable or out of bounds
    if (arg_addr % PGSIZE != 0 || arg_addr < MIN_ADDR || arg_addr >= MAX_ADDR)
    {
      cprintf("Address is not page-alligned or is out of bounds.\n");
      return -1;
    }

    struct vm_area *curr_vma = &p->head;

    // iterate over allocated VMAs
    while (curr_vma->start != MAX_ADDR)
    {
      // if provided address falls within the allocated VMA
      if (arg_addr >= curr_vma->start && arg_addr <= curr_vma->end)
      {
        cprintf("Address has already been mapped.\n");
        return -1;
      }

      // if the requested mapping is before the next VMA
      if (arg_addr < curr_vma->next->start)
      {
        // check the space after it
        if (curr_vma->space_after > length)
        {
          // we found enough space
          start_addr = arg_addr;
          curr_vma->space_after -= length;
          struct vm_area *new_vma = create_vma(curr_vma, curr_vma->next, start_addr, length, prot, flags, fd);

          // *** Ben's edit: allocate physical space, insert into page table ***
          for (int i = start_addr; i < new_vma->end; i += PGSIZE)
          {
            char *pa = kalloc();
            if (pa == 0)
              panic("kalloc");
            memset(pa, 0, PGSIZE);

            // set pa of vma to first page's pa
            if (i == start_addr) new_vma->pa = (uint) pa;

            if (mappages(p->pgdir, (void *) i, PGSIZE, (uint) pa, new_vma->prot | PTE_U) != 0)
            {
              kfree(pa);
              p->killed = 1;
            }

            // load file into physical memory
            if ((flags & MAP_ANON)==0)
            {
              struct file *f = p->ofile[fd];
			        f->off = 0;
              // Read the file content into vaddr
              fileread(f, (char *) i, PGSIZE);
            }
          }

          // account for guard page
          if ((flags & MAP_GROWSUP) != 0)
          {
            // check margin space, must be at least PGSIZE space for guard page
            if ((new_vma->next->start - (new_vma->end + 1)) < PGSIZE)
            {
              new_vma->guardstart = new_vma->end + 1;     // track start of guard page
              new_vma->end += PGSIZE;                     // increase end of mapping to include guard page
            }
            // not enough space for guard page
            else
            {
              cprintf("no room for guard page\n");
              return -1;
            }
          }

          return start_addr;
        }
      }
      curr_vma = curr_vma->next;
    }

    // we couldn't find any space, error out
    return -1;
  }
  // MAP_FIXED not set, we have to find an address
  struct vm_area *curr_vma = &p->head;

  // iterate over allocated VMAs
  while (curr_vma->start != MAX_ADDR)
  {
    // check the space after it - request encroaching on next VMA is covered because the
    // starting address is not arbitrary
    if (curr_vma->space_after > length)
    {
      // we found enough space
      start_addr = curr_vma->end + 1;
      curr_vma->space_after -= length;
      struct vm_area *new_vma = create_vma(curr_vma, curr_vma->next, start_addr, length, prot, flags, fd);

      // *** Ben's edit: allocate physical space, insert into page table ***
      for (int i = start_addr; i < new_vma->end; i += PGSIZE)
      {
        char *pa = kalloc();
        if (pa == 0)
          panic("kalloc");
        memset(pa, 0, PGSIZE);

        // set pa of vma to first page's pa
        if (i == start_addr) new_vma->pa = (uint) pa;

        if (mappages(p->pgdir, (void *) i, PGSIZE, (uint) pa, new_vma->prot | PTE_U) != 0)
        {
          kfree(pa);
          p->killed = 1;
        }

        // load file into physical memory
        if ((flags & MAP_ANON)==0)
        {
          struct file *f = p->ofile[fd];
          f->off = 0;
          // Read the file content into vaddr
          fileread(f, (char *) i, PGSIZE);
        }
      }

      // account for guard page
      if ((flags & MAP_GROWSUP) != 0)
      {
        // check margin space, must be at least PGSIZE space for guard page
        if ((new_vma->next->start - (new_vma->end + 1)) < PGSIZE)
        {
          new_vma->guardstart = new_vma->end + 1;     // track start of guard page
          new_vma->end += PGSIZE;                     // increase end of mapping to include guard page
        }
        // not enough space for guard page
        else
        {
          // cprintf("no room for guard page\n");
          return -1;
        }
      }

      return start_addr;
    }
    curr_vma = curr_vma->next;
  }

  // we couldn't find any space, error out
  return -1;
}

int sys_munmap(void)
{
  // void *addr, int length
  int addr;
  int length;
  uint arg_addr;
  uint end_addr;
  struct vm_area *vm = 0;

  // invalid arg check
  if (argint(0, &addr) < 0 || argint(1, &length) < 0)
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
    if (arg_addr == curr.start && curr.valid == 1)
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

  // write back to file if fbm enabled
  if (((vm->flags & MAP_ANON) == 0))
  {
    struct file* f = vm->f;                   // file for fbm
	f->off = 0;
	filewrite(f, (void*)vm->start, vm->len);
  }

  // remove mappings from page table
  pte_t* pte;
  for (int i = arg_addr; i < end_addr; i += PGSIZE)      // walk through each page of vma
  {     
    if ((pte = walkpgdir(myproc()->pgdir, (void *) i, 0)) == 0){   // obtain the PTE for current page
      if (*pte & PTE_P){                                  // check present (valid) bit
        char* v = P2V(PTE_ADDR(*pte));                    // addr translation for PTE
        kfree(v);                                         // free physical memory
      }
      *pte = 0;                                           // remove PTE
    }
  }

  // mark end of freed memory at the next highest page
  end_addr = PGROUNDUP(end_addr) - 1;

  // remove entire mapping block: | A | A | A | ->  |   |   |   |
  if (arg_addr == vm->start)
  {
    vm->valid = 0;                // make mem block available
    prev->next = vm->next;        // link previous block to next block after curr (unlink curr)
    prev->space_after += vm->len; // add space from unlinked block to space avail. after previous block
  }
  return 0;
}

/*
* END P5 SYSCALL CODE
*/
