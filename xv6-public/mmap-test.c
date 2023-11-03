#include "types.h"
#include "stat.h"
#include "user.h"
#include "mmap.h"

int
main(int argc, char **argv)
{
  uint va = 0x65000000;
  int length = 1024;
  int prot = PROT_READ;
  int flags = MAP_FIXED | MAP_SHARED;
  int fd = 0;
  int offset = 0;


  mmap(va, length, prot, flags, fd, offset);

  printf(1, "[0] mapped successfully\n");

  munmap(va, length);

  printf(1, "[1] unmapped successfully\n");

  exit();
}
