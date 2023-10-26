
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc e0 69 11 80       	mov    $0x801169e0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 99 38 10 80       	mov    $0x80103899,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 94 87 10 80       	push   $0x80108794
80100042:	68 80 b5 10 80       	push   $0x8010b580
80100047:	e8 cf 52 00 00       	call   8010531b <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 cc fc 10 80 7c 	movl   $0x8010fc7c,0x8010fccc
80100056:	fc 10 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 d0 fc 10 80 7c 	movl   $0x8010fc7c,0x8010fcd0
80100060:	fc 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 b5 10 80 	movl   $0x8010b5b4,-0xc(%ebp)
8010006a:	eb 47                	jmp    801000b3 <binit+0x7f>
    b->next = bcache.head.next;
8010006c:	8b 15 d0 fc 10 80    	mov    0x8010fcd0,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 50 7c fc 10 80 	movl   $0x8010fc7c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	83 c0 0c             	add    $0xc,%eax
80100088:	83 ec 08             	sub    $0x8,%esp
8010008b:	68 9b 87 10 80       	push   $0x8010879b
80100090:	50                   	push   %eax
80100091:	e8 02 51 00 00       	call   80105198 <initsleeplock>
80100096:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
80100099:	a1 d0 fc 10 80       	mov    0x8010fcd0,%eax
8010009e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a1:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	a3 d0 fc 10 80       	mov    %eax,0x8010fcd0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000ac:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b3:	b8 7c fc 10 80       	mov    $0x8010fc7c,%eax
801000b8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000bb:	72 af                	jb     8010006c <binit+0x38>
  }
}
801000bd:	90                   	nop
801000be:	90                   	nop
801000bf:	c9                   	leave  
801000c0:	c3                   	ret    

801000c1 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000c1:	55                   	push   %ebp
801000c2:	89 e5                	mov    %esp,%ebp
801000c4:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c7:	83 ec 0c             	sub    $0xc,%esp
801000ca:	68 80 b5 10 80       	push   $0x8010b580
801000cf:	e8 69 52 00 00       	call   8010533d <acquire>
801000d4:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000d7:	a1 d0 fc 10 80       	mov    0x8010fcd0,%eax
801000dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000df:	eb 58                	jmp    80100139 <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
801000e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e4:	8b 40 04             	mov    0x4(%eax),%eax
801000e7:	39 45 08             	cmp    %eax,0x8(%ebp)
801000ea:	75 44                	jne    80100130 <bget+0x6f>
801000ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ef:	8b 40 08             	mov    0x8(%eax),%eax
801000f2:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000f5:	75 39                	jne    80100130 <bget+0x6f>
      b->refcnt++;
801000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fa:	8b 40 4c             	mov    0x4c(%eax),%eax
801000fd:	8d 50 01             	lea    0x1(%eax),%edx
80100100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100103:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100106:	83 ec 0c             	sub    $0xc,%esp
80100109:	68 80 b5 10 80       	push   $0x8010b580
8010010e:	e8 98 52 00 00       	call   801053ab <release>
80100113:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100119:	83 c0 0c             	add    $0xc,%eax
8010011c:	83 ec 0c             	sub    $0xc,%esp
8010011f:	50                   	push   %eax
80100120:	e8 af 50 00 00       	call   801051d4 <acquiresleep>
80100125:	83 c4 10             	add    $0x10,%esp
      return b;
80100128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012b:	e9 9d 00 00 00       	jmp    801001cd <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100133:	8b 40 54             	mov    0x54(%eax),%eax
80100136:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100139:	81 7d f4 7c fc 10 80 	cmpl   $0x8010fc7c,-0xc(%ebp)
80100140:	75 9f                	jne    801000e1 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100142:	a1 cc fc 10 80       	mov    0x8010fccc,%eax
80100147:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014a:	eb 6b                	jmp    801001b7 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010014c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014f:	8b 40 4c             	mov    0x4c(%eax),%eax
80100152:	85 c0                	test   %eax,%eax
80100154:	75 58                	jne    801001ae <bget+0xed>
80100156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100159:	8b 00                	mov    (%eax),%eax
8010015b:	83 e0 04             	and    $0x4,%eax
8010015e:	85 c0                	test   %eax,%eax
80100160:	75 4c                	jne    801001ae <bget+0xed>
      b->dev = dev;
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 55 08             	mov    0x8(%ebp),%edx
80100168:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016e:	8b 55 0c             	mov    0xc(%ebp),%edx
80100171:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100177:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010017d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100180:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100187:	83 ec 0c             	sub    $0xc,%esp
8010018a:	68 80 b5 10 80       	push   $0x8010b580
8010018f:	e8 17 52 00 00       	call   801053ab <release>
80100194:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010019a:	83 c0 0c             	add    $0xc,%eax
8010019d:	83 ec 0c             	sub    $0xc,%esp
801001a0:	50                   	push   %eax
801001a1:	e8 2e 50 00 00       	call   801051d4 <acquiresleep>
801001a6:	83 c4 10             	add    $0x10,%esp
      return b;
801001a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ac:	eb 1f                	jmp    801001cd <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b1:	8b 40 50             	mov    0x50(%eax),%eax
801001b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001b7:	81 7d f4 7c fc 10 80 	cmpl   $0x8010fc7c,-0xc(%ebp)
801001be:	75 8c                	jne    8010014c <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001c0:	83 ec 0c             	sub    $0xc,%esp
801001c3:	68 a2 87 10 80       	push   $0x801087a2
801001c8:	e8 e8 03 00 00       	call   801005b5 <panic>
}
801001cd:	c9                   	leave  
801001ce:	c3                   	ret    

801001cf <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001cf:	55                   	push   %ebp
801001d0:	89 e5                	mov    %esp,%ebp
801001d2:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001d5:	83 ec 08             	sub    $0x8,%esp
801001d8:	ff 75 0c             	push   0xc(%ebp)
801001db:	ff 75 08             	push   0x8(%ebp)
801001de:	e8 de fe ff ff       	call   801000c1 <bget>
801001e3:	83 c4 10             	add    $0x10,%esp
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ec:	8b 00                	mov    (%eax),%eax
801001ee:	83 e0 02             	and    $0x2,%eax
801001f1:	85 c0                	test   %eax,%eax
801001f3:	75 0e                	jne    80100203 <bread+0x34>
    iderw(b);
801001f5:	83 ec 0c             	sub    $0xc,%esp
801001f8:	ff 75 f4             	push   -0xc(%ebp)
801001fb:	e8 99 27 00 00       	call   80102999 <iderw>
80100200:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100203:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100206:	c9                   	leave  
80100207:	c3                   	ret    

80100208 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100208:	55                   	push   %ebp
80100209:	89 e5                	mov    %esp,%ebp
8010020b:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	83 c0 0c             	add    $0xc,%eax
80100214:	83 ec 0c             	sub    $0xc,%esp
80100217:	50                   	push   %eax
80100218:	e8 69 50 00 00       	call   80105286 <holdingsleep>
8010021d:	83 c4 10             	add    $0x10,%esp
80100220:	85 c0                	test   %eax,%eax
80100222:	75 0d                	jne    80100231 <bwrite+0x29>
    panic("bwrite");
80100224:	83 ec 0c             	sub    $0xc,%esp
80100227:	68 b3 87 10 80       	push   $0x801087b3
8010022c:	e8 84 03 00 00       	call   801005b5 <panic>
  b->flags |= B_DIRTY;
80100231:	8b 45 08             	mov    0x8(%ebp),%eax
80100234:	8b 00                	mov    (%eax),%eax
80100236:	83 c8 04             	or     $0x4,%eax
80100239:	89 c2                	mov    %eax,%edx
8010023b:	8b 45 08             	mov    0x8(%ebp),%eax
8010023e:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	ff 75 08             	push   0x8(%ebp)
80100246:	e8 4e 27 00 00       	call   80102999 <iderw>
8010024b:	83 c4 10             	add    $0x10,%esp
}
8010024e:	90                   	nop
8010024f:	c9                   	leave  
80100250:	c3                   	ret    

80100251 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100251:	55                   	push   %ebp
80100252:	89 e5                	mov    %esp,%ebp
80100254:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100257:	8b 45 08             	mov    0x8(%ebp),%eax
8010025a:	83 c0 0c             	add    $0xc,%eax
8010025d:	83 ec 0c             	sub    $0xc,%esp
80100260:	50                   	push   %eax
80100261:	e8 20 50 00 00       	call   80105286 <holdingsleep>
80100266:	83 c4 10             	add    $0x10,%esp
80100269:	85 c0                	test   %eax,%eax
8010026b:	75 0d                	jne    8010027a <brelse+0x29>
    panic("brelse");
8010026d:	83 ec 0c             	sub    $0xc,%esp
80100270:	68 ba 87 10 80       	push   $0x801087ba
80100275:	e8 3b 03 00 00       	call   801005b5 <panic>

  releasesleep(&b->lock);
8010027a:	8b 45 08             	mov    0x8(%ebp),%eax
8010027d:	83 c0 0c             	add    $0xc,%eax
80100280:	83 ec 0c             	sub    $0xc,%esp
80100283:	50                   	push   %eax
80100284:	e8 af 4f 00 00       	call   80105238 <releasesleep>
80100289:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
8010028c:	83 ec 0c             	sub    $0xc,%esp
8010028f:	68 80 b5 10 80       	push   $0x8010b580
80100294:	e8 a4 50 00 00       	call   8010533d <acquire>
80100299:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	8b 40 4c             	mov    0x4c(%eax),%eax
801002a2:	8d 50 ff             	lea    -0x1(%eax),%edx
801002a5:	8b 45 08             	mov    0x8(%ebp),%eax
801002a8:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002ab:	8b 45 08             	mov    0x8(%ebp),%eax
801002ae:	8b 40 4c             	mov    0x4c(%eax),%eax
801002b1:	85 c0                	test   %eax,%eax
801002b3:	75 47                	jne    801002fc <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002b5:	8b 45 08             	mov    0x8(%ebp),%eax
801002b8:	8b 40 54             	mov    0x54(%eax),%eax
801002bb:	8b 55 08             	mov    0x8(%ebp),%edx
801002be:	8b 52 50             	mov    0x50(%edx),%edx
801002c1:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002c4:	8b 45 08             	mov    0x8(%ebp),%eax
801002c7:	8b 40 50             	mov    0x50(%eax),%eax
801002ca:	8b 55 08             	mov    0x8(%ebp),%edx
801002cd:	8b 52 54             	mov    0x54(%edx),%edx
801002d0:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002d3:	8b 15 d0 fc 10 80    	mov    0x8010fcd0,%edx
801002d9:	8b 45 08             	mov    0x8(%ebp),%eax
801002dc:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002df:	8b 45 08             	mov    0x8(%ebp),%eax
801002e2:	c7 40 50 7c fc 10 80 	movl   $0x8010fc7c,0x50(%eax)
    bcache.head.next->prev = b;
801002e9:	a1 d0 fc 10 80       	mov    0x8010fcd0,%eax
801002ee:	8b 55 08             	mov    0x8(%ebp),%edx
801002f1:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002f4:	8b 45 08             	mov    0x8(%ebp),%eax
801002f7:	a3 d0 fc 10 80       	mov    %eax,0x8010fcd0
  }
  
  release(&bcache.lock);
801002fc:	83 ec 0c             	sub    $0xc,%esp
801002ff:	68 80 b5 10 80       	push   $0x8010b580
80100304:	e8 a2 50 00 00       	call   801053ab <release>
80100309:	83 c4 10             	add    $0x10,%esp
}
8010030c:	90                   	nop
8010030d:	c9                   	leave  
8010030e:	c3                   	ret    

8010030f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010030f:	55                   	push   %ebp
80100310:	89 e5                	mov    %esp,%ebp
80100312:	83 ec 14             	sub    $0x14,%esp
80100315:	8b 45 08             	mov    0x8(%ebp),%eax
80100318:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010031c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80100320:	89 c2                	mov    %eax,%edx
80100322:	ec                   	in     (%dx),%al
80100323:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80100326:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010032a:	c9                   	leave  
8010032b:	c3                   	ret    

8010032c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010032c:	55                   	push   %ebp
8010032d:	89 e5                	mov    %esp,%ebp
8010032f:	83 ec 08             	sub    $0x8,%esp
80100332:	8b 45 08             	mov    0x8(%ebp),%eax
80100335:	8b 55 0c             	mov    0xc(%ebp),%edx
80100338:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010033c:	89 d0                	mov    %edx,%eax
8010033e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100341:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100345:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80100349:	ee                   	out    %al,(%dx)
}
8010034a:	90                   	nop
8010034b:	c9                   	leave  
8010034c:	c3                   	ret    

8010034d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010034d:	55                   	push   %ebp
8010034e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100350:	fa                   	cli    
}
80100351:	90                   	nop
80100352:	5d                   	pop    %ebp
80100353:	c3                   	ret    

80100354 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100354:	55                   	push   %ebp
80100355:	89 e5                	mov    %esp,%ebp
80100357:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010035a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010035e:	74 1c                	je     8010037c <printint+0x28>
80100360:	8b 45 08             	mov    0x8(%ebp),%eax
80100363:	c1 e8 1f             	shr    $0x1f,%eax
80100366:	0f b6 c0             	movzbl %al,%eax
80100369:	89 45 10             	mov    %eax,0x10(%ebp)
8010036c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100370:	74 0a                	je     8010037c <printint+0x28>
    x = -xx;
80100372:	8b 45 08             	mov    0x8(%ebp),%eax
80100375:	f7 d8                	neg    %eax
80100377:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010037a:	eb 06                	jmp    80100382 <printint+0x2e>
  else
    x = xx;
8010037c:	8b 45 08             	mov    0x8(%ebp),%eax
8010037f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100382:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100389:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010038c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010038f:	ba 00 00 00 00       	mov    $0x0,%edx
80100394:	f7 f1                	div    %ecx
80100396:	89 d1                	mov    %edx,%ecx
80100398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010039b:	8d 50 01             	lea    0x1(%eax),%edx
8010039e:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003a1:	0f b6 91 04 90 10 80 	movzbl -0x7fef6ffc(%ecx),%edx
801003a8:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003b2:	ba 00 00 00 00       	mov    $0x0,%edx
801003b7:	f7 f1                	div    %ecx
801003b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003c0:	75 c7                	jne    80100389 <printint+0x35>

  if(sign)
801003c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003c6:	74 2a                	je     801003f2 <printint+0x9e>
    buf[i++] = '-';
801003c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003cb:	8d 50 01             	lea    0x1(%eax),%edx
801003ce:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003d1:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003d6:	eb 1a                	jmp    801003f2 <printint+0x9e>
    consputc(buf[i]);
801003d8:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003de:	01 d0                	add    %edx,%eax
801003e0:	0f b6 00             	movzbl (%eax),%eax
801003e3:	0f be c0             	movsbl %al,%eax
801003e6:	83 ec 0c             	sub    $0xc,%esp
801003e9:	50                   	push   %eax
801003ea:	e8 f9 03 00 00       	call   801007e8 <consputc>
801003ef:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003f2:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003fa:	79 dc                	jns    801003d8 <printint+0x84>
}
801003fc:	90                   	nop
801003fd:	90                   	nop
801003fe:	c9                   	leave  
801003ff:	c3                   	ret    

80100400 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100400:	55                   	push   %ebp
80100401:	89 e5                	mov    %esp,%ebp
80100403:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100406:	a1 b4 ff 10 80       	mov    0x8010ffb4,%eax
8010040b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010040e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100412:	74 10                	je     80100424 <cprintf+0x24>
    acquire(&cons.lock);
80100414:	83 ec 0c             	sub    $0xc,%esp
80100417:	68 80 ff 10 80       	push   $0x8010ff80
8010041c:	e8 1c 4f 00 00       	call   8010533d <acquire>
80100421:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100424:	8b 45 08             	mov    0x8(%ebp),%eax
80100427:	85 c0                	test   %eax,%eax
80100429:	75 0d                	jne    80100438 <cprintf+0x38>
    panic("null fmt");
8010042b:	83 ec 0c             	sub    $0xc,%esp
8010042e:	68 c1 87 10 80       	push   $0x801087c1
80100433:	e8 7d 01 00 00       	call   801005b5 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100438:	8d 45 0c             	lea    0xc(%ebp),%eax
8010043b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010043e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100445:	e9 2f 01 00 00       	jmp    80100579 <cprintf+0x179>
    if(c != '%'){
8010044a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010044e:	74 13                	je     80100463 <cprintf+0x63>
      consputc(c);
80100450:	83 ec 0c             	sub    $0xc,%esp
80100453:	ff 75 e4             	push   -0x1c(%ebp)
80100456:	e8 8d 03 00 00       	call   801007e8 <consputc>
8010045b:	83 c4 10             	add    $0x10,%esp
      continue;
8010045e:	e9 12 01 00 00       	jmp    80100575 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100463:	8b 55 08             	mov    0x8(%ebp),%edx
80100466:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010046a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010046d:	01 d0                	add    %edx,%eax
8010046f:	0f b6 00             	movzbl (%eax),%eax
80100472:	0f be c0             	movsbl %al,%eax
80100475:	25 ff 00 00 00       	and    $0xff,%eax
8010047a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010047d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100481:	0f 84 14 01 00 00    	je     8010059b <cprintf+0x19b>
      break;
    switch(c){
80100487:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010048b:	74 5e                	je     801004eb <cprintf+0xeb>
8010048d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100491:	0f 8f c2 00 00 00    	jg     80100559 <cprintf+0x159>
80100497:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010049b:	74 6b                	je     80100508 <cprintf+0x108>
8010049d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
801004a1:	0f 8f b2 00 00 00    	jg     80100559 <cprintf+0x159>
801004a7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004ab:	74 3e                	je     801004eb <cprintf+0xeb>
801004ad:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004b1:	0f 8f a2 00 00 00    	jg     80100559 <cprintf+0x159>
801004b7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004bb:	0f 84 89 00 00 00    	je     8010054a <cprintf+0x14a>
801004c1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004c5:	0f 85 8e 00 00 00    	jne    80100559 <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ce:	8d 50 04             	lea    0x4(%eax),%edx
801004d1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004d4:	8b 00                	mov    (%eax),%eax
801004d6:	83 ec 04             	sub    $0x4,%esp
801004d9:	6a 01                	push   $0x1
801004db:	6a 0a                	push   $0xa
801004dd:	50                   	push   %eax
801004de:	e8 71 fe ff ff       	call   80100354 <printint>
801004e3:	83 c4 10             	add    $0x10,%esp
      break;
801004e6:	e9 8a 00 00 00       	jmp    80100575 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ee:	8d 50 04             	lea    0x4(%eax),%edx
801004f1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004f4:	8b 00                	mov    (%eax),%eax
801004f6:	83 ec 04             	sub    $0x4,%esp
801004f9:	6a 00                	push   $0x0
801004fb:	6a 10                	push   $0x10
801004fd:	50                   	push   %eax
801004fe:	e8 51 fe ff ff       	call   80100354 <printint>
80100503:	83 c4 10             	add    $0x10,%esp
      break;
80100506:	eb 6d                	jmp    80100575 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
80100508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010050b:	8d 50 04             	lea    0x4(%eax),%edx
8010050e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100511:	8b 00                	mov    (%eax),%eax
80100513:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100516:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010051a:	75 22                	jne    8010053e <cprintf+0x13e>
        s = "(null)";
8010051c:	c7 45 ec ca 87 10 80 	movl   $0x801087ca,-0x14(%ebp)
      for(; *s; s++)
80100523:	eb 19                	jmp    8010053e <cprintf+0x13e>
        consputc(*s);
80100525:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100528:	0f b6 00             	movzbl (%eax),%eax
8010052b:	0f be c0             	movsbl %al,%eax
8010052e:	83 ec 0c             	sub    $0xc,%esp
80100531:	50                   	push   %eax
80100532:	e8 b1 02 00 00       	call   801007e8 <consputc>
80100537:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010053a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010053e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100541:	0f b6 00             	movzbl (%eax),%eax
80100544:	84 c0                	test   %al,%al
80100546:	75 dd                	jne    80100525 <cprintf+0x125>
      break;
80100548:	eb 2b                	jmp    80100575 <cprintf+0x175>
    case '%':
      consputc('%');
8010054a:	83 ec 0c             	sub    $0xc,%esp
8010054d:	6a 25                	push   $0x25
8010054f:	e8 94 02 00 00       	call   801007e8 <consputc>
80100554:	83 c4 10             	add    $0x10,%esp
      break;
80100557:	eb 1c                	jmp    80100575 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100559:	83 ec 0c             	sub    $0xc,%esp
8010055c:	6a 25                	push   $0x25
8010055e:	e8 85 02 00 00       	call   801007e8 <consputc>
80100563:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100566:	83 ec 0c             	sub    $0xc,%esp
80100569:	ff 75 e4             	push   -0x1c(%ebp)
8010056c:	e8 77 02 00 00       	call   801007e8 <consputc>
80100571:	83 c4 10             	add    $0x10,%esp
      break;
80100574:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100575:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100579:	8b 55 08             	mov    0x8(%ebp),%edx
8010057c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010057f:	01 d0                	add    %edx,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f be c0             	movsbl %al,%eax
80100587:	25 ff 00 00 00       	and    $0xff,%eax
8010058c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010058f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100593:	0f 85 b1 fe ff ff    	jne    8010044a <cprintf+0x4a>
80100599:	eb 01                	jmp    8010059c <cprintf+0x19c>
      break;
8010059b:	90                   	nop
    }
  }

  if(locking)
8010059c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005a0:	74 10                	je     801005b2 <cprintf+0x1b2>
    release(&cons.lock);
801005a2:	83 ec 0c             	sub    $0xc,%esp
801005a5:	68 80 ff 10 80       	push   $0x8010ff80
801005aa:	e8 fc 4d 00 00       	call   801053ab <release>
801005af:	83 c4 10             	add    $0x10,%esp
}
801005b2:	90                   	nop
801005b3:	c9                   	leave  
801005b4:	c3                   	ret    

801005b5 <panic>:

void
panic(char *s)
{
801005b5:	55                   	push   %ebp
801005b6:	89 e5                	mov    %esp,%ebp
801005b8:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005bb:	e8 8d fd ff ff       	call   8010034d <cli>
  cons.locking = 0;
801005c0:	c7 05 b4 ff 10 80 00 	movl   $0x0,0x8010ffb4
801005c7:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005ca:	e8 5f 2a 00 00       	call   8010302e <lapicid>
801005cf:	83 ec 08             	sub    $0x8,%esp
801005d2:	50                   	push   %eax
801005d3:	68 d1 87 10 80       	push   $0x801087d1
801005d8:	e8 23 fe ff ff       	call   80100400 <cprintf>
801005dd:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005e0:	8b 45 08             	mov    0x8(%ebp),%eax
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	50                   	push   %eax
801005e7:	e8 14 fe ff ff       	call   80100400 <cprintf>
801005ec:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005ef:	83 ec 0c             	sub    $0xc,%esp
801005f2:	68 e5 87 10 80       	push   $0x801087e5
801005f7:	e8 04 fe ff ff       	call   80100400 <cprintf>
801005fc:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ff:	83 ec 08             	sub    $0x8,%esp
80100602:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100605:	50                   	push   %eax
80100606:	8d 45 08             	lea    0x8(%ebp),%eax
80100609:	50                   	push   %eax
8010060a:	e8 ee 4d 00 00       	call   801053fd <getcallerpcs>
8010060f:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100612:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100619:	eb 1c                	jmp    80100637 <panic+0x82>
    cprintf(" %p", pcs[i]);
8010061b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010061e:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100622:	83 ec 08             	sub    $0x8,%esp
80100625:	50                   	push   %eax
80100626:	68 e7 87 10 80       	push   $0x801087e7
8010062b:	e8 d0 fd ff ff       	call   80100400 <cprintf>
80100630:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100633:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100637:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010063b:	7e de                	jle    8010061b <panic+0x66>
  panicked = 1; // freeze other CPU
8010063d:	c7 05 6c ff 10 80 01 	movl   $0x1,0x8010ff6c
80100644:	00 00 00 
  for(;;)
80100647:	eb fe                	jmp    80100647 <panic+0x92>

80100649 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100649:	55                   	push   %ebp
8010064a:	89 e5                	mov    %esp,%ebp
8010064c:	53                   	push   %ebx
8010064d:	83 ec 14             	sub    $0x14,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100650:	6a 0e                	push   $0xe
80100652:	68 d4 03 00 00       	push   $0x3d4
80100657:	e8 d0 fc ff ff       	call   8010032c <outb>
8010065c:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
8010065f:	68 d5 03 00 00       	push   $0x3d5
80100664:	e8 a6 fc ff ff       	call   8010030f <inb>
80100669:	83 c4 04             	add    $0x4,%esp
8010066c:	0f b6 c0             	movzbl %al,%eax
8010066f:	c1 e0 08             	shl    $0x8,%eax
80100672:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100675:	6a 0f                	push   $0xf
80100677:	68 d4 03 00 00       	push   $0x3d4
8010067c:	e8 ab fc ff ff       	call   8010032c <outb>
80100681:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
80100684:	68 d5 03 00 00       	push   $0x3d5
80100689:	e8 81 fc ff ff       	call   8010030f <inb>
8010068e:	83 c4 04             	add    $0x4,%esp
80100691:	0f b6 c0             	movzbl %al,%eax
80100694:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100697:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010069b:	75 34                	jne    801006d1 <cgaputc+0x88>
    pos += 80 - pos%80;
8010069d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006a0:	ba 67 66 66 66       	mov    $0x66666667,%edx
801006a5:	89 c8                	mov    %ecx,%eax
801006a7:	f7 ea                	imul   %edx
801006a9:	89 d0                	mov    %edx,%eax
801006ab:	c1 f8 05             	sar    $0x5,%eax
801006ae:	89 cb                	mov    %ecx,%ebx
801006b0:	c1 fb 1f             	sar    $0x1f,%ebx
801006b3:	29 d8                	sub    %ebx,%eax
801006b5:	89 c2                	mov    %eax,%edx
801006b7:	89 d0                	mov    %edx,%eax
801006b9:	c1 e0 02             	shl    $0x2,%eax
801006bc:	01 d0                	add    %edx,%eax
801006be:	c1 e0 04             	shl    $0x4,%eax
801006c1:	29 c1                	sub    %eax,%ecx
801006c3:	89 ca                	mov    %ecx,%edx
801006c5:	b8 50 00 00 00       	mov    $0x50,%eax
801006ca:	29 d0                	sub    %edx,%eax
801006cc:	01 45 f4             	add    %eax,-0xc(%ebp)
801006cf:	eb 38                	jmp    80100709 <cgaputc+0xc0>
  else if(c == BACKSPACE){
801006d1:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006d8:	75 0c                	jne    801006e6 <cgaputc+0x9d>
    if(pos > 0) --pos;
801006da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006de:	7e 29                	jle    80100709 <cgaputc+0xc0>
801006e0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801006e4:	eb 23                	jmp    80100709 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006e6:	8b 45 08             	mov    0x8(%ebp),%eax
801006e9:	0f b6 c0             	movzbl %al,%eax
801006ec:	80 cc 07             	or     $0x7,%ah
801006ef:	89 c1                	mov    %eax,%ecx
801006f1:	8b 1d 00 90 10 80    	mov    0x80109000,%ebx
801006f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fa:	8d 50 01             	lea    0x1(%eax),%edx
801006fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100700:	01 c0                	add    %eax,%eax
80100702:	01 d8                	add    %ebx,%eax
80100704:	89 ca                	mov    %ecx,%edx
80100706:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
80100709:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010070d:	78 09                	js     80100718 <cgaputc+0xcf>
8010070f:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100716:	7e 0d                	jle    80100725 <cgaputc+0xdc>
    panic("pos under/overflow");
80100718:	83 ec 0c             	sub    $0xc,%esp
8010071b:	68 eb 87 10 80       	push   $0x801087eb
80100720:	e8 90 fe ff ff       	call   801005b5 <panic>

  if((pos/80) >= 24){  // Scroll up.
80100725:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
8010072c:	7e 4d                	jle    8010077b <cgaputc+0x132>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010072e:	a1 00 90 10 80       	mov    0x80109000,%eax
80100733:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100739:	a1 00 90 10 80       	mov    0x80109000,%eax
8010073e:	83 ec 04             	sub    $0x4,%esp
80100741:	68 60 0e 00 00       	push   $0xe60
80100746:	52                   	push   %edx
80100747:	50                   	push   %eax
80100748:	e8 35 4f 00 00       	call   80105682 <memmove>
8010074d:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
80100750:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100754:	b8 80 07 00 00       	mov    $0x780,%eax
80100759:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010075c:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010075f:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100768:	01 c0                	add    %eax,%eax
8010076a:	01 c8                	add    %ecx,%eax
8010076c:	83 ec 04             	sub    $0x4,%esp
8010076f:	52                   	push   %edx
80100770:	6a 00                	push   $0x0
80100772:	50                   	push   %eax
80100773:	e8 4b 4e 00 00       	call   801055c3 <memset>
80100778:	83 c4 10             	add    $0x10,%esp
  }

  outb(CRTPORT, 14);
8010077b:	83 ec 08             	sub    $0x8,%esp
8010077e:	6a 0e                	push   $0xe
80100780:	68 d4 03 00 00       	push   $0x3d4
80100785:	e8 a2 fb ff ff       	call   8010032c <outb>
8010078a:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010078d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100790:	c1 f8 08             	sar    $0x8,%eax
80100793:	0f b6 c0             	movzbl %al,%eax
80100796:	83 ec 08             	sub    $0x8,%esp
80100799:	50                   	push   %eax
8010079a:	68 d5 03 00 00       	push   $0x3d5
8010079f:	e8 88 fb ff ff       	call   8010032c <outb>
801007a4:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
801007a7:	83 ec 08             	sub    $0x8,%esp
801007aa:	6a 0f                	push   $0xf
801007ac:	68 d4 03 00 00       	push   $0x3d4
801007b1:	e8 76 fb ff ff       	call   8010032c <outb>
801007b6:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
801007b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007bc:	0f b6 c0             	movzbl %al,%eax
801007bf:	83 ec 08             	sub    $0x8,%esp
801007c2:	50                   	push   %eax
801007c3:	68 d5 03 00 00       	push   $0x3d5
801007c8:	e8 5f fb ff ff       	call   8010032c <outb>
801007cd:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
801007d0:	8b 15 00 90 10 80    	mov    0x80109000,%edx
801007d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007d9:	01 c0                	add    %eax,%eax
801007db:	01 d0                	add    %edx,%eax
801007dd:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801007e2:	90                   	nop
801007e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801007e6:	c9                   	leave  
801007e7:	c3                   	ret    

801007e8 <consputc>:

void
consputc(int c)
{
801007e8:	55                   	push   %ebp
801007e9:	89 e5                	mov    %esp,%ebp
801007eb:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
801007ee:	a1 6c ff 10 80       	mov    0x8010ff6c,%eax
801007f3:	85 c0                	test   %eax,%eax
801007f5:	74 07                	je     801007fe <consputc+0x16>
    cli();
801007f7:	e8 51 fb ff ff       	call   8010034d <cli>
    for(;;)
801007fc:	eb fe                	jmp    801007fc <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
801007fe:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100805:	75 29                	jne    80100830 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100807:	83 ec 0c             	sub    $0xc,%esp
8010080a:	6a 08                	push   $0x8
8010080c:	e8 35 67 00 00       	call   80106f46 <uartputc>
80100811:	83 c4 10             	add    $0x10,%esp
80100814:	83 ec 0c             	sub    $0xc,%esp
80100817:	6a 20                	push   $0x20
80100819:	e8 28 67 00 00       	call   80106f46 <uartputc>
8010081e:	83 c4 10             	add    $0x10,%esp
80100821:	83 ec 0c             	sub    $0xc,%esp
80100824:	6a 08                	push   $0x8
80100826:	e8 1b 67 00 00       	call   80106f46 <uartputc>
8010082b:	83 c4 10             	add    $0x10,%esp
8010082e:	eb 0e                	jmp    8010083e <consputc+0x56>
  } else
    uartputc(c);
80100830:	83 ec 0c             	sub    $0xc,%esp
80100833:	ff 75 08             	push   0x8(%ebp)
80100836:	e8 0b 67 00 00       	call   80106f46 <uartputc>
8010083b:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010083e:	83 ec 0c             	sub    $0xc,%esp
80100841:	ff 75 08             	push   0x8(%ebp)
80100844:	e8 00 fe ff ff       	call   80100649 <cgaputc>
80100849:	83 c4 10             	add    $0x10,%esp
}
8010084c:	90                   	nop
8010084d:	c9                   	leave  
8010084e:	c3                   	ret    

8010084f <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
8010084f:	55                   	push   %ebp
80100850:	89 e5                	mov    %esp,%ebp
80100852:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
80100855:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
8010085c:	83 ec 0c             	sub    $0xc,%esp
8010085f:	68 80 ff 10 80       	push   $0x8010ff80
80100864:	e8 d4 4a 00 00       	call   8010533d <acquire>
80100869:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
8010086c:	e9 50 01 00 00       	jmp    801009c1 <consoleintr+0x172>
    switch(c){
80100871:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100875:	0f 84 81 00 00 00    	je     801008fc <consoleintr+0xad>
8010087b:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010087f:	0f 8f ac 00 00 00    	jg     80100931 <consoleintr+0xe2>
80100885:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100889:	74 43                	je     801008ce <consoleintr+0x7f>
8010088b:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010088f:	0f 8f 9c 00 00 00    	jg     80100931 <consoleintr+0xe2>
80100895:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100899:	74 61                	je     801008fc <consoleintr+0xad>
8010089b:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
8010089f:	0f 85 8c 00 00 00    	jne    80100931 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
801008a5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
801008ac:	e9 10 01 00 00       	jmp    801009c1 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008b1:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
801008b6:	83 e8 01             	sub    $0x1,%eax
801008b9:	a3 68 ff 10 80       	mov    %eax,0x8010ff68
        consputc(BACKSPACE);
801008be:	83 ec 0c             	sub    $0xc,%esp
801008c1:	68 00 01 00 00       	push   $0x100
801008c6:	e8 1d ff ff ff       	call   801007e8 <consputc>
801008cb:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
801008ce:	8b 15 68 ff 10 80    	mov    0x8010ff68,%edx
801008d4:	a1 64 ff 10 80       	mov    0x8010ff64,%eax
801008d9:	39 c2                	cmp    %eax,%edx
801008db:	0f 84 e0 00 00 00    	je     801009c1 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008e1:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
801008e6:	83 e8 01             	sub    $0x1,%eax
801008e9:	83 e0 7f             	and    $0x7f,%eax
801008ec:	0f b6 80 e0 fe 10 80 	movzbl -0x7fef0120(%eax),%eax
      while(input.e != input.w &&
801008f3:	3c 0a                	cmp    $0xa,%al
801008f5:	75 ba                	jne    801008b1 <consoleintr+0x62>
      }
      break;
801008f7:	e9 c5 00 00 00       	jmp    801009c1 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008fc:	8b 15 68 ff 10 80    	mov    0x8010ff68,%edx
80100902:	a1 64 ff 10 80       	mov    0x8010ff64,%eax
80100907:	39 c2                	cmp    %eax,%edx
80100909:	0f 84 b2 00 00 00    	je     801009c1 <consoleintr+0x172>
        input.e--;
8010090f:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
80100914:	83 e8 01             	sub    $0x1,%eax
80100917:	a3 68 ff 10 80       	mov    %eax,0x8010ff68
        consputc(BACKSPACE);
8010091c:	83 ec 0c             	sub    $0xc,%esp
8010091f:	68 00 01 00 00       	push   $0x100
80100924:	e8 bf fe ff ff       	call   801007e8 <consputc>
80100929:	83 c4 10             	add    $0x10,%esp
      }
      break;
8010092c:	e9 90 00 00 00       	jmp    801009c1 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100931:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100935:	0f 84 85 00 00 00    	je     801009c0 <consoleintr+0x171>
8010093b:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
80100940:	8b 15 60 ff 10 80    	mov    0x8010ff60,%edx
80100946:	29 d0                	sub    %edx,%eax
80100948:	83 f8 7f             	cmp    $0x7f,%eax
8010094b:	77 73                	ja     801009c0 <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
8010094d:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100951:	74 05                	je     80100958 <consoleintr+0x109>
80100953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100956:	eb 05                	jmp    8010095d <consoleintr+0x10e>
80100958:	b8 0a 00 00 00       	mov    $0xa,%eax
8010095d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100960:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
80100965:	8d 50 01             	lea    0x1(%eax),%edx
80100968:	89 15 68 ff 10 80    	mov    %edx,0x8010ff68
8010096e:	83 e0 7f             	and    $0x7f,%eax
80100971:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100974:	88 90 e0 fe 10 80    	mov    %dl,-0x7fef0120(%eax)
        consputc(c);
8010097a:	83 ec 0c             	sub    $0xc,%esp
8010097d:	ff 75 f0             	push   -0x10(%ebp)
80100980:	e8 63 fe ff ff       	call   801007e8 <consputc>
80100985:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100988:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010098c:	74 18                	je     801009a6 <consoleintr+0x157>
8010098e:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100992:	74 12                	je     801009a6 <consoleintr+0x157>
80100994:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
80100999:	8b 15 60 ff 10 80    	mov    0x8010ff60,%edx
8010099f:	83 ea 80             	sub    $0xffffff80,%edx
801009a2:	39 d0                	cmp    %edx,%eax
801009a4:	75 1a                	jne    801009c0 <consoleintr+0x171>
          input.w = input.e;
801009a6:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
801009ab:	a3 64 ff 10 80       	mov    %eax,0x8010ff64
          wakeup(&input.r);
801009b0:	83 ec 0c             	sub    $0xc,%esp
801009b3:	68 60 ff 10 80       	push   $0x8010ff60
801009b8:	e8 20 46 00 00       	call   80104fdd <wakeup>
801009bd:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
801009c0:	90                   	nop
  while((c = getc()) >= 0){
801009c1:	8b 45 08             	mov    0x8(%ebp),%eax
801009c4:	ff d0                	call   *%eax
801009c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801009c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801009cd:	0f 89 9e fe ff ff    	jns    80100871 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
801009d3:	83 ec 0c             	sub    $0xc,%esp
801009d6:	68 80 ff 10 80       	push   $0x8010ff80
801009db:	e8 cb 49 00 00       	call   801053ab <release>
801009e0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009e7:	74 05                	je     801009ee <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
801009e9:	e8 ad 46 00 00       	call   8010509b <procdump>
  }
}
801009ee:	90                   	nop
801009ef:	c9                   	leave  
801009f0:	c3                   	ret    

801009f1 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009f1:	55                   	push   %ebp
801009f2:	89 e5                	mov    %esp,%ebp
801009f4:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009f7:	83 ec 0c             	sub    $0xc,%esp
801009fa:	ff 75 08             	push   0x8(%ebp)
801009fd:	e8 69 11 00 00       	call   80101b6b <iunlock>
80100a02:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a05:	8b 45 10             	mov    0x10(%ebp),%eax
80100a08:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a0b:	83 ec 0c             	sub    $0xc,%esp
80100a0e:	68 80 ff 10 80       	push   $0x8010ff80
80100a13:	e8 25 49 00 00       	call   8010533d <acquire>
80100a18:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a1b:	e9 ab 00 00 00       	jmp    80100acb <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
80100a20:	e8 b2 38 00 00       	call   801042d7 <myproc>
80100a25:	8b 40 24             	mov    0x24(%eax),%eax
80100a28:	85 c0                	test   %eax,%eax
80100a2a:	74 28                	je     80100a54 <consoleread+0x63>
        release(&cons.lock);
80100a2c:	83 ec 0c             	sub    $0xc,%esp
80100a2f:	68 80 ff 10 80       	push   $0x8010ff80
80100a34:	e8 72 49 00 00       	call   801053ab <release>
80100a39:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a3c:	83 ec 0c             	sub    $0xc,%esp
80100a3f:	ff 75 08             	push   0x8(%ebp)
80100a42:	e8 11 10 00 00       	call   80101a58 <ilock>
80100a47:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a4f:	e9 a9 00 00 00       	jmp    80100afd <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
80100a54:	83 ec 08             	sub    $0x8,%esp
80100a57:	68 80 ff 10 80       	push   $0x8010ff80
80100a5c:	68 60 ff 10 80       	push   $0x8010ff60
80100a61:	e8 69 44 00 00       	call   80104ecf <sleep>
80100a66:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a69:	8b 15 60 ff 10 80    	mov    0x8010ff60,%edx
80100a6f:	a1 64 ff 10 80       	mov    0x8010ff64,%eax
80100a74:	39 c2                	cmp    %eax,%edx
80100a76:	74 a8                	je     80100a20 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a78:	a1 60 ff 10 80       	mov    0x8010ff60,%eax
80100a7d:	8d 50 01             	lea    0x1(%eax),%edx
80100a80:	89 15 60 ff 10 80    	mov    %edx,0x8010ff60
80100a86:	83 e0 7f             	and    $0x7f,%eax
80100a89:	0f b6 80 e0 fe 10 80 	movzbl -0x7fef0120(%eax),%eax
80100a90:	0f be c0             	movsbl %al,%eax
80100a93:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a96:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a9a:	75 17                	jne    80100ab3 <consoleread+0xc2>
      if(n < target){
80100a9c:	8b 45 10             	mov    0x10(%ebp),%eax
80100a9f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100aa2:	76 2f                	jbe    80100ad3 <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100aa4:	a1 60 ff 10 80       	mov    0x8010ff60,%eax
80100aa9:	83 e8 01             	sub    $0x1,%eax
80100aac:	a3 60 ff 10 80       	mov    %eax,0x8010ff60
      }
      break;
80100ab1:	eb 20                	jmp    80100ad3 <consoleread+0xe2>
    }
    *dst++ = c;
80100ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab6:	8d 50 01             	lea    0x1(%eax),%edx
80100ab9:	89 55 0c             	mov    %edx,0xc(%ebp)
80100abc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100abf:	88 10                	mov    %dl,(%eax)
    --n;
80100ac1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100ac5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100ac9:	74 0b                	je     80100ad6 <consoleread+0xe5>
  while(n > 0){
80100acb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100acf:	7f 98                	jg     80100a69 <consoleread+0x78>
80100ad1:	eb 04                	jmp    80100ad7 <consoleread+0xe6>
      break;
80100ad3:	90                   	nop
80100ad4:	eb 01                	jmp    80100ad7 <consoleread+0xe6>
      break;
80100ad6:	90                   	nop
  }
  release(&cons.lock);
80100ad7:	83 ec 0c             	sub    $0xc,%esp
80100ada:	68 80 ff 10 80       	push   $0x8010ff80
80100adf:	e8 c7 48 00 00       	call   801053ab <release>
80100ae4:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ae7:	83 ec 0c             	sub    $0xc,%esp
80100aea:	ff 75 08             	push   0x8(%ebp)
80100aed:	e8 66 0f 00 00       	call   80101a58 <ilock>
80100af2:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100af5:	8b 55 10             	mov    0x10(%ebp),%edx
80100af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100afb:	29 d0                	sub    %edx,%eax
}
80100afd:	c9                   	leave  
80100afe:	c3                   	ret    

80100aff <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b05:	83 ec 0c             	sub    $0xc,%esp
80100b08:	ff 75 08             	push   0x8(%ebp)
80100b0b:	e8 5b 10 00 00       	call   80101b6b <iunlock>
80100b10:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b13:	83 ec 0c             	sub    $0xc,%esp
80100b16:	68 80 ff 10 80       	push   $0x8010ff80
80100b1b:	e8 1d 48 00 00       	call   8010533d <acquire>
80100b20:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b2a:	eb 21                	jmp    80100b4d <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100b2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b32:	01 d0                	add    %edx,%eax
80100b34:	0f b6 00             	movzbl (%eax),%eax
80100b37:	0f be c0             	movsbl %al,%eax
80100b3a:	0f b6 c0             	movzbl %al,%eax
80100b3d:	83 ec 0c             	sub    $0xc,%esp
80100b40:	50                   	push   %eax
80100b41:	e8 a2 fc ff ff       	call   801007e8 <consputc>
80100b46:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b49:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b50:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b53:	7c d7                	jl     80100b2c <consolewrite+0x2d>
  release(&cons.lock);
80100b55:	83 ec 0c             	sub    $0xc,%esp
80100b58:	68 80 ff 10 80       	push   $0x8010ff80
80100b5d:	e8 49 48 00 00       	call   801053ab <release>
80100b62:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b65:	83 ec 0c             	sub    $0xc,%esp
80100b68:	ff 75 08             	push   0x8(%ebp)
80100b6b:	e8 e8 0e 00 00       	call   80101a58 <ilock>
80100b70:	83 c4 10             	add    $0x10,%esp

  return n;
80100b73:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b76:	c9                   	leave  
80100b77:	c3                   	ret    

80100b78 <consoleinit>:

void
consoleinit(void)
{
80100b78:	55                   	push   %ebp
80100b79:	89 e5                	mov    %esp,%ebp
80100b7b:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b7e:	83 ec 08             	sub    $0x8,%esp
80100b81:	68 fe 87 10 80       	push   $0x801087fe
80100b86:	68 80 ff 10 80       	push   $0x8010ff80
80100b8b:	e8 8b 47 00 00       	call   8010531b <initlock>
80100b90:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b93:	c7 05 cc ff 10 80 ff 	movl   $0x80100aff,0x8010ffcc
80100b9a:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b9d:	c7 05 c8 ff 10 80 f1 	movl   $0x801009f1,0x8010ffc8
80100ba4:	09 10 80 
  cons.locking = 1;
80100ba7:	c7 05 b4 ff 10 80 01 	movl   $0x1,0x8010ffb4
80100bae:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100bb1:	83 ec 08             	sub    $0x8,%esp
80100bb4:	6a 00                	push   $0x0
80100bb6:	6a 01                	push   $0x1
80100bb8:	e8 a5 1f 00 00       	call   80102b62 <ioapicenable>
80100bbd:	83 c4 10             	add    $0x10,%esp
}
80100bc0:	90                   	nop
80100bc1:	c9                   	leave  
80100bc2:	c3                   	ret    

80100bc3 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100bc3:	55                   	push   %ebp
80100bc4:	89 e5                	mov    %esp,%ebp
80100bc6:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100bcc:	e8 06 37 00 00       	call   801042d7 <myproc>
80100bd1:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bd4:	e8 97 29 00 00       	call   80103570 <begin_op>

  if((ip = namei(path)) == 0){
80100bd9:	83 ec 0c             	sub    $0xc,%esp
80100bdc:	ff 75 08             	push   0x8(%ebp)
80100bdf:	e8 a7 19 00 00       	call   8010258b <namei>
80100be4:	83 c4 10             	add    $0x10,%esp
80100be7:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bee:	75 1f                	jne    80100c0f <exec+0x4c>
    end_op();
80100bf0:	e8 07 2a 00 00       	call   801035fc <end_op>
    cprintf("exec: fail\n");
80100bf5:	83 ec 0c             	sub    $0xc,%esp
80100bf8:	68 06 88 10 80       	push   $0x80108806
80100bfd:	e8 fe f7 ff ff       	call   80100400 <cprintf>
80100c02:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c0a:	e9 2f 04 00 00       	jmp    8010103e <exec+0x47b>
  }
  ilock(ip);
80100c0f:	83 ec 0c             	sub    $0xc,%esp
80100c12:	ff 75 d8             	push   -0x28(%ebp)
80100c15:	e8 3e 0e 00 00       	call   80101a58 <ilock>
80100c1a:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c1d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c24:	6a 34                	push   $0x34
80100c26:	6a 00                	push   $0x0
80100c28:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c2e:	50                   	push   %eax
80100c2f:	ff 75 d8             	push   -0x28(%ebp)
80100c32:	e8 0d 13 00 00       	call   80101f44 <readi>
80100c37:	83 c4 10             	add    $0x10,%esp
80100c3a:	83 f8 34             	cmp    $0x34,%eax
80100c3d:	0f 85 a4 03 00 00    	jne    80100fe7 <exec+0x424>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c43:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c49:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c4e:	0f 85 96 03 00 00    	jne    80100fea <exec+0x427>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c54:	e8 e9 72 00 00       	call   80107f42 <setupkvm>
80100c59:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c5c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c60:	0f 84 87 03 00 00    	je     80100fed <exec+0x42a>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c66:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c6d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c74:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c7a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c7d:	e9 de 00 00 00       	jmp    80100d60 <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c82:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c85:	6a 20                	push   $0x20
80100c87:	50                   	push   %eax
80100c88:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c8e:	50                   	push   %eax
80100c8f:	ff 75 d8             	push   -0x28(%ebp)
80100c92:	e8 ad 12 00 00       	call   80101f44 <readi>
80100c97:	83 c4 10             	add    $0x10,%esp
80100c9a:	83 f8 20             	cmp    $0x20,%eax
80100c9d:	0f 85 4d 03 00 00    	jne    80100ff0 <exec+0x42d>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100ca3:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100ca9:	83 f8 01             	cmp    $0x1,%eax
80100cac:	0f 85 a0 00 00 00    	jne    80100d52 <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100cb2:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cb8:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100cbe:	39 c2                	cmp    %eax,%edx
80100cc0:	0f 82 2d 03 00 00    	jb     80100ff3 <exec+0x430>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100cc6:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ccc:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cd2:	01 c2                	add    %eax,%edx
80100cd4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cda:	39 c2                	cmp    %eax,%edx
80100cdc:	0f 82 14 03 00 00    	jb     80100ff6 <exec+0x433>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ce2:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ce8:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cee:	01 d0                	add    %edx,%eax
80100cf0:	83 ec 04             	sub    $0x4,%esp
80100cf3:	50                   	push   %eax
80100cf4:	ff 75 e0             	push   -0x20(%ebp)
80100cf7:	ff 75 d4             	push   -0x2c(%ebp)
80100cfa:	e8 e9 75 00 00       	call   801082e8 <allocuvm>
80100cff:	83 c4 10             	add    $0x10,%esp
80100d02:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d05:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d09:	0f 84 ea 02 00 00    	je     80100ff9 <exec+0x436>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d0f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d15:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d1a:	85 c0                	test   %eax,%eax
80100d1c:	0f 85 da 02 00 00    	jne    80100ffc <exec+0x439>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d22:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d28:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d2e:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100d34:	83 ec 0c             	sub    $0xc,%esp
80100d37:	52                   	push   %edx
80100d38:	50                   	push   %eax
80100d39:	ff 75 d8             	push   -0x28(%ebp)
80100d3c:	51                   	push   %ecx
80100d3d:	ff 75 d4             	push   -0x2c(%ebp)
80100d40:	e8 d6 74 00 00       	call   8010821b <loaduvm>
80100d45:	83 c4 20             	add    $0x20,%esp
80100d48:	85 c0                	test   %eax,%eax
80100d4a:	0f 88 af 02 00 00    	js     80100fff <exec+0x43c>
80100d50:	eb 01                	jmp    80100d53 <exec+0x190>
      continue;
80100d52:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d53:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d57:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d5a:	83 c0 20             	add    $0x20,%eax
80100d5d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d60:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d67:	0f b7 c0             	movzwl %ax,%eax
80100d6a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d6d:	0f 8c 0f ff ff ff    	jl     80100c82 <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d73:	83 ec 0c             	sub    $0xc,%esp
80100d76:	ff 75 d8             	push   -0x28(%ebp)
80100d79:	e8 0b 0f 00 00       	call   80101c89 <iunlockput>
80100d7e:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d81:	e8 76 28 00 00       	call   801035fc <end_op>
  ip = 0;
80100d86:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d90:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d95:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d9a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100da0:	05 00 20 00 00       	add    $0x2000,%eax
80100da5:	83 ec 04             	sub    $0x4,%esp
80100da8:	50                   	push   %eax
80100da9:	ff 75 e0             	push   -0x20(%ebp)
80100dac:	ff 75 d4             	push   -0x2c(%ebp)
80100daf:	e8 34 75 00 00       	call   801082e8 <allocuvm>
80100db4:	83 c4 10             	add    $0x10,%esp
80100db7:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dbe:	0f 84 3e 02 00 00    	je     80101002 <exec+0x43f>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100dc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dc7:	2d 00 20 00 00       	sub    $0x2000,%eax
80100dcc:	83 ec 08             	sub    $0x8,%esp
80100dcf:	50                   	push   %eax
80100dd0:	ff 75 d4             	push   -0x2c(%ebp)
80100dd3:	e8 72 77 00 00       	call   8010854a <clearpteu>
80100dd8:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100ddb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dde:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100de8:	e9 96 00 00 00       	jmp    80100e83 <exec+0x2c0>
    if(argc >= MAXARG)
80100ded:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100df1:	0f 87 0e 02 00 00    	ja     80101005 <exec+0x442>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100df7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dfa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e01:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e04:	01 d0                	add    %edx,%eax
80100e06:	8b 00                	mov    (%eax),%eax
80100e08:	83 ec 0c             	sub    $0xc,%esp
80100e0b:	50                   	push   %eax
80100e0c:	e8 00 4a 00 00       	call   80105811 <strlen>
80100e11:	83 c4 10             	add    $0x10,%esp
80100e14:	89 c2                	mov    %eax,%edx
80100e16:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e19:	29 d0                	sub    %edx,%eax
80100e1b:	83 e8 01             	sub    $0x1,%eax
80100e1e:	83 e0 fc             	and    $0xfffffffc,%eax
80100e21:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e31:	01 d0                	add    %edx,%eax
80100e33:	8b 00                	mov    (%eax),%eax
80100e35:	83 ec 0c             	sub    $0xc,%esp
80100e38:	50                   	push   %eax
80100e39:	e8 d3 49 00 00       	call   80105811 <strlen>
80100e3e:	83 c4 10             	add    $0x10,%esp
80100e41:	83 c0 01             	add    $0x1,%eax
80100e44:	89 c2                	mov    %eax,%edx
80100e46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e49:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e50:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e53:	01 c8                	add    %ecx,%eax
80100e55:	8b 00                	mov    (%eax),%eax
80100e57:	52                   	push   %edx
80100e58:	50                   	push   %eax
80100e59:	ff 75 dc             	push   -0x24(%ebp)
80100e5c:	ff 75 d4             	push   -0x2c(%ebp)
80100e5f:	e8 92 78 00 00       	call   801086f6 <copyout>
80100e64:	83 c4 10             	add    $0x10,%esp
80100e67:	85 c0                	test   %eax,%eax
80100e69:	0f 88 99 01 00 00    	js     80101008 <exec+0x445>
      goto bad;
    ustack[3+argc] = sp;
80100e6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e72:	8d 50 03             	lea    0x3(%eax),%edx
80100e75:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e78:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e7f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e86:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e90:	01 d0                	add    %edx,%eax
80100e92:	8b 00                	mov    (%eax),%eax
80100e94:	85 c0                	test   %eax,%eax
80100e96:	0f 85 51 ff ff ff    	jne    80100ded <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9f:	83 c0 03             	add    $0x3,%eax
80100ea2:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100ea9:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ead:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100eb4:	ff ff ff 
  ustack[1] = argc;
80100eb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eba:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ec0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec3:	83 c0 01             	add    $0x1,%eax
80100ec6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ecd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ed0:	29 d0                	sub    %edx,%eax
80100ed2:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100ed8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100edb:	83 c0 04             	add    $0x4,%eax
80100ede:	c1 e0 02             	shl    $0x2,%eax
80100ee1:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ee4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee7:	83 c0 04             	add    $0x4,%eax
80100eea:	c1 e0 02             	shl    $0x2,%eax
80100eed:	50                   	push   %eax
80100eee:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ef4:	50                   	push   %eax
80100ef5:	ff 75 dc             	push   -0x24(%ebp)
80100ef8:	ff 75 d4             	push   -0x2c(%ebp)
80100efb:	e8 f6 77 00 00       	call   801086f6 <copyout>
80100f00:	83 c4 10             	add    $0x10,%esp
80100f03:	85 c0                	test   %eax,%eax
80100f05:	0f 88 00 01 00 00    	js     8010100b <exec+0x448>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80100f0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f14:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f17:	eb 17                	jmp    80100f30 <exec+0x36d>
    if(*s == '/')
80100f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f1c:	0f b6 00             	movzbl (%eax),%eax
80100f1f:	3c 2f                	cmp    $0x2f,%al
80100f21:	75 09                	jne    80100f2c <exec+0x369>
      last = s+1;
80100f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f26:	83 c0 01             	add    $0x1,%eax
80100f29:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f2c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f33:	0f b6 00             	movzbl (%eax),%eax
80100f36:	84 c0                	test   %al,%al
80100f38:	75 df                	jne    80100f19 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f3a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3d:	83 c0 6c             	add    $0x6c,%eax
80100f40:	83 ec 04             	sub    $0x4,%esp
80100f43:	6a 10                	push   $0x10
80100f45:	ff 75 f0             	push   -0x10(%ebp)
80100f48:	50                   	push   %eax
80100f49:	e8 78 48 00 00       	call   801057c6 <safestrcpy>
80100f4e:	83 c4 10             	add    $0x10,%esp

  // Populate process values
  curproc->nice = 0;
80100f51:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f54:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  curproc->cpu = 0;
80100f5b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f5e:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80100f65:	00 00 00 
  curproc->priority = 0;
80100f68:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f6b:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80100f72:	00 00 00 
  curproc->ticks = 0;
80100f75:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f78:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
80100f7f:	00 00 00 
  curproc->sleep_ticks = 0;
80100f82:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f85:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80100f8c:	00 00 00 

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f8f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f92:	8b 40 04             	mov    0x4(%eax),%eax
80100f95:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f98:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f9b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f9e:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100fa1:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fa4:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100fa7:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100fa9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fac:	8b 40 18             	mov    0x18(%eax),%eax
80100faf:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100fb5:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100fb8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fbb:	8b 40 18             	mov    0x18(%eax),%eax
80100fbe:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100fc1:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100fc4:	83 ec 0c             	sub    $0xc,%esp
80100fc7:	ff 75 d0             	push   -0x30(%ebp)
80100fca:	e8 3d 70 00 00       	call   8010800c <switchuvm>
80100fcf:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fd2:	83 ec 0c             	sub    $0xc,%esp
80100fd5:	ff 75 cc             	push   -0x34(%ebp)
80100fd8:	e8 d4 74 00 00       	call   801084b1 <freevm>
80100fdd:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fe0:	b8 00 00 00 00       	mov    $0x0,%eax
80100fe5:	eb 57                	jmp    8010103e <exec+0x47b>
    goto bad;
80100fe7:	90                   	nop
80100fe8:	eb 22                	jmp    8010100c <exec+0x449>
    goto bad;
80100fea:	90                   	nop
80100feb:	eb 1f                	jmp    8010100c <exec+0x449>
    goto bad;
80100fed:	90                   	nop
80100fee:	eb 1c                	jmp    8010100c <exec+0x449>
      goto bad;
80100ff0:	90                   	nop
80100ff1:	eb 19                	jmp    8010100c <exec+0x449>
      goto bad;
80100ff3:	90                   	nop
80100ff4:	eb 16                	jmp    8010100c <exec+0x449>
      goto bad;
80100ff6:	90                   	nop
80100ff7:	eb 13                	jmp    8010100c <exec+0x449>
      goto bad;
80100ff9:	90                   	nop
80100ffa:	eb 10                	jmp    8010100c <exec+0x449>
      goto bad;
80100ffc:	90                   	nop
80100ffd:	eb 0d                	jmp    8010100c <exec+0x449>
      goto bad;
80100fff:	90                   	nop
80101000:	eb 0a                	jmp    8010100c <exec+0x449>
    goto bad;
80101002:	90                   	nop
80101003:	eb 07                	jmp    8010100c <exec+0x449>
      goto bad;
80101005:	90                   	nop
80101006:	eb 04                	jmp    8010100c <exec+0x449>
      goto bad;
80101008:	90                   	nop
80101009:	eb 01                	jmp    8010100c <exec+0x449>
    goto bad;
8010100b:	90                   	nop

 bad:
  if(pgdir)
8010100c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101010:	74 0e                	je     80101020 <exec+0x45d>
    freevm(pgdir);
80101012:	83 ec 0c             	sub    $0xc,%esp
80101015:	ff 75 d4             	push   -0x2c(%ebp)
80101018:	e8 94 74 00 00       	call   801084b1 <freevm>
8010101d:	83 c4 10             	add    $0x10,%esp
  if(ip){
80101020:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101024:	74 13                	je     80101039 <exec+0x476>
    iunlockput(ip);
80101026:	83 ec 0c             	sub    $0xc,%esp
80101029:	ff 75 d8             	push   -0x28(%ebp)
8010102c:	e8 58 0c 00 00       	call   80101c89 <iunlockput>
80101031:	83 c4 10             	add    $0x10,%esp
    end_op();
80101034:	e8 c3 25 00 00       	call   801035fc <end_op>
  }
  return -1;
80101039:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010103e:	c9                   	leave  
8010103f:	c3                   	ret    

80101040 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101040:	55                   	push   %ebp
80101041:	89 e5                	mov    %esp,%ebp
80101043:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80101046:	83 ec 08             	sub    $0x8,%esp
80101049:	68 12 88 10 80       	push   $0x80108812
8010104e:	68 20 00 11 80       	push   $0x80110020
80101053:	e8 c3 42 00 00       	call   8010531b <initlock>
80101058:	83 c4 10             	add    $0x10,%esp
}
8010105b:	90                   	nop
8010105c:	c9                   	leave  
8010105d:	c3                   	ret    

8010105e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
8010105e:	55                   	push   %ebp
8010105f:	89 e5                	mov    %esp,%ebp
80101061:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80101064:	83 ec 0c             	sub    $0xc,%esp
80101067:	68 20 00 11 80       	push   $0x80110020
8010106c:	e8 cc 42 00 00       	call   8010533d <acquire>
80101071:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101074:	c7 45 f4 54 00 11 80 	movl   $0x80110054,-0xc(%ebp)
8010107b:	eb 2d                	jmp    801010aa <filealloc+0x4c>
    if(f->ref == 0){
8010107d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101080:	8b 40 04             	mov    0x4(%eax),%eax
80101083:	85 c0                	test   %eax,%eax
80101085:	75 1f                	jne    801010a6 <filealloc+0x48>
      f->ref = 1;
80101087:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010108a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101091:	83 ec 0c             	sub    $0xc,%esp
80101094:	68 20 00 11 80       	push   $0x80110020
80101099:	e8 0d 43 00 00       	call   801053ab <release>
8010109e:	83 c4 10             	add    $0x10,%esp
      return f;
801010a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010a4:	eb 23                	jmp    801010c9 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010a6:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801010aa:	b8 b4 09 11 80       	mov    $0x801109b4,%eax
801010af:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801010b2:	72 c9                	jb     8010107d <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
801010b4:	83 ec 0c             	sub    $0xc,%esp
801010b7:	68 20 00 11 80       	push   $0x80110020
801010bc:	e8 ea 42 00 00       	call   801053ab <release>
801010c1:	83 c4 10             	add    $0x10,%esp
  return 0;
801010c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801010c9:	c9                   	leave  
801010ca:	c3                   	ret    

801010cb <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801010cb:	55                   	push   %ebp
801010cc:	89 e5                	mov    %esp,%ebp
801010ce:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801010d1:	83 ec 0c             	sub    $0xc,%esp
801010d4:	68 20 00 11 80       	push   $0x80110020
801010d9:	e8 5f 42 00 00       	call   8010533d <acquire>
801010de:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010e1:	8b 45 08             	mov    0x8(%ebp),%eax
801010e4:	8b 40 04             	mov    0x4(%eax),%eax
801010e7:	85 c0                	test   %eax,%eax
801010e9:	7f 0d                	jg     801010f8 <filedup+0x2d>
    panic("filedup");
801010eb:	83 ec 0c             	sub    $0xc,%esp
801010ee:	68 19 88 10 80       	push   $0x80108819
801010f3:	e8 bd f4 ff ff       	call   801005b5 <panic>
  f->ref++;
801010f8:	8b 45 08             	mov    0x8(%ebp),%eax
801010fb:	8b 40 04             	mov    0x4(%eax),%eax
801010fe:	8d 50 01             	lea    0x1(%eax),%edx
80101101:	8b 45 08             	mov    0x8(%ebp),%eax
80101104:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101107:	83 ec 0c             	sub    $0xc,%esp
8010110a:	68 20 00 11 80       	push   $0x80110020
8010110f:	e8 97 42 00 00       	call   801053ab <release>
80101114:	83 c4 10             	add    $0x10,%esp
  return f;
80101117:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010111a:	c9                   	leave  
8010111b:	c3                   	ret    

8010111c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010111c:	55                   	push   %ebp
8010111d:	89 e5                	mov    %esp,%ebp
8010111f:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101122:	83 ec 0c             	sub    $0xc,%esp
80101125:	68 20 00 11 80       	push   $0x80110020
8010112a:	e8 0e 42 00 00       	call   8010533d <acquire>
8010112f:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101132:	8b 45 08             	mov    0x8(%ebp),%eax
80101135:	8b 40 04             	mov    0x4(%eax),%eax
80101138:	85 c0                	test   %eax,%eax
8010113a:	7f 0d                	jg     80101149 <fileclose+0x2d>
    panic("fileclose");
8010113c:	83 ec 0c             	sub    $0xc,%esp
8010113f:	68 21 88 10 80       	push   $0x80108821
80101144:	e8 6c f4 ff ff       	call   801005b5 <panic>
  if(--f->ref > 0){
80101149:	8b 45 08             	mov    0x8(%ebp),%eax
8010114c:	8b 40 04             	mov    0x4(%eax),%eax
8010114f:	8d 50 ff             	lea    -0x1(%eax),%edx
80101152:	8b 45 08             	mov    0x8(%ebp),%eax
80101155:	89 50 04             	mov    %edx,0x4(%eax)
80101158:	8b 45 08             	mov    0x8(%ebp),%eax
8010115b:	8b 40 04             	mov    0x4(%eax),%eax
8010115e:	85 c0                	test   %eax,%eax
80101160:	7e 15                	jle    80101177 <fileclose+0x5b>
    release(&ftable.lock);
80101162:	83 ec 0c             	sub    $0xc,%esp
80101165:	68 20 00 11 80       	push   $0x80110020
8010116a:	e8 3c 42 00 00       	call   801053ab <release>
8010116f:	83 c4 10             	add    $0x10,%esp
80101172:	e9 8b 00 00 00       	jmp    80101202 <fileclose+0xe6>
    return;
  }
  ff = *f;
80101177:	8b 45 08             	mov    0x8(%ebp),%eax
8010117a:	8b 10                	mov    (%eax),%edx
8010117c:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010117f:	8b 50 04             	mov    0x4(%eax),%edx
80101182:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101185:	8b 50 08             	mov    0x8(%eax),%edx
80101188:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010118b:	8b 50 0c             	mov    0xc(%eax),%edx
8010118e:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101191:	8b 50 10             	mov    0x10(%eax),%edx
80101194:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101197:	8b 40 14             	mov    0x14(%eax),%eax
8010119a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010119d:	8b 45 08             	mov    0x8(%ebp),%eax
801011a0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801011a7:	8b 45 08             	mov    0x8(%ebp),%eax
801011aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801011b0:	83 ec 0c             	sub    $0xc,%esp
801011b3:	68 20 00 11 80       	push   $0x80110020
801011b8:	e8 ee 41 00 00       	call   801053ab <release>
801011bd:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
801011c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011c3:	83 f8 01             	cmp    $0x1,%eax
801011c6:	75 19                	jne    801011e1 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801011c8:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801011cc:	0f be d0             	movsbl %al,%edx
801011cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011d2:	83 ec 08             	sub    $0x8,%esp
801011d5:	52                   	push   %edx
801011d6:	50                   	push   %eax
801011d7:	e8 8a 2d 00 00       	call   80103f66 <pipeclose>
801011dc:	83 c4 10             	add    $0x10,%esp
801011df:	eb 21                	jmp    80101202 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801011e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011e4:	83 f8 02             	cmp    $0x2,%eax
801011e7:	75 19                	jne    80101202 <fileclose+0xe6>
    begin_op();
801011e9:	e8 82 23 00 00       	call   80103570 <begin_op>
    iput(ff.ip);
801011ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011f1:	83 ec 0c             	sub    $0xc,%esp
801011f4:	50                   	push   %eax
801011f5:	e8 bf 09 00 00       	call   80101bb9 <iput>
801011fa:	83 c4 10             	add    $0x10,%esp
    end_op();
801011fd:	e8 fa 23 00 00       	call   801035fc <end_op>
  }
}
80101202:	c9                   	leave  
80101203:	c3                   	ret    

80101204 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101204:	55                   	push   %ebp
80101205:	89 e5                	mov    %esp,%ebp
80101207:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010120a:	8b 45 08             	mov    0x8(%ebp),%eax
8010120d:	8b 00                	mov    (%eax),%eax
8010120f:	83 f8 02             	cmp    $0x2,%eax
80101212:	75 40                	jne    80101254 <filestat+0x50>
    ilock(f->ip);
80101214:	8b 45 08             	mov    0x8(%ebp),%eax
80101217:	8b 40 10             	mov    0x10(%eax),%eax
8010121a:	83 ec 0c             	sub    $0xc,%esp
8010121d:	50                   	push   %eax
8010121e:	e8 35 08 00 00       	call   80101a58 <ilock>
80101223:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101226:	8b 45 08             	mov    0x8(%ebp),%eax
80101229:	8b 40 10             	mov    0x10(%eax),%eax
8010122c:	83 ec 08             	sub    $0x8,%esp
8010122f:	ff 75 0c             	push   0xc(%ebp)
80101232:	50                   	push   %eax
80101233:	e8 c6 0c 00 00       	call   80101efe <stati>
80101238:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010123b:	8b 45 08             	mov    0x8(%ebp),%eax
8010123e:	8b 40 10             	mov    0x10(%eax),%eax
80101241:	83 ec 0c             	sub    $0xc,%esp
80101244:	50                   	push   %eax
80101245:	e8 21 09 00 00       	call   80101b6b <iunlock>
8010124a:	83 c4 10             	add    $0x10,%esp
    return 0;
8010124d:	b8 00 00 00 00       	mov    $0x0,%eax
80101252:	eb 05                	jmp    80101259 <filestat+0x55>
  }
  return -1;
80101254:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101259:	c9                   	leave  
8010125a:	c3                   	ret    

8010125b <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010125b:	55                   	push   %ebp
8010125c:	89 e5                	mov    %esp,%ebp
8010125e:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101261:	8b 45 08             	mov    0x8(%ebp),%eax
80101264:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101268:	84 c0                	test   %al,%al
8010126a:	75 0a                	jne    80101276 <fileread+0x1b>
    return -1;
8010126c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101271:	e9 9b 00 00 00       	jmp    80101311 <fileread+0xb6>
  if(f->type == FD_PIPE)
80101276:	8b 45 08             	mov    0x8(%ebp),%eax
80101279:	8b 00                	mov    (%eax),%eax
8010127b:	83 f8 01             	cmp    $0x1,%eax
8010127e:	75 1a                	jne    8010129a <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101280:	8b 45 08             	mov    0x8(%ebp),%eax
80101283:	8b 40 0c             	mov    0xc(%eax),%eax
80101286:	83 ec 04             	sub    $0x4,%esp
80101289:	ff 75 10             	push   0x10(%ebp)
8010128c:	ff 75 0c             	push   0xc(%ebp)
8010128f:	50                   	push   %eax
80101290:	e8 7e 2e 00 00       	call   80104113 <piperead>
80101295:	83 c4 10             	add    $0x10,%esp
80101298:	eb 77                	jmp    80101311 <fileread+0xb6>
  if(f->type == FD_INODE){
8010129a:	8b 45 08             	mov    0x8(%ebp),%eax
8010129d:	8b 00                	mov    (%eax),%eax
8010129f:	83 f8 02             	cmp    $0x2,%eax
801012a2:	75 60                	jne    80101304 <fileread+0xa9>
    ilock(f->ip);
801012a4:	8b 45 08             	mov    0x8(%ebp),%eax
801012a7:	8b 40 10             	mov    0x10(%eax),%eax
801012aa:	83 ec 0c             	sub    $0xc,%esp
801012ad:	50                   	push   %eax
801012ae:	e8 a5 07 00 00       	call   80101a58 <ilock>
801012b3:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801012b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
801012b9:	8b 45 08             	mov    0x8(%ebp),%eax
801012bc:	8b 50 14             	mov    0x14(%eax),%edx
801012bf:	8b 45 08             	mov    0x8(%ebp),%eax
801012c2:	8b 40 10             	mov    0x10(%eax),%eax
801012c5:	51                   	push   %ecx
801012c6:	52                   	push   %edx
801012c7:	ff 75 0c             	push   0xc(%ebp)
801012ca:	50                   	push   %eax
801012cb:	e8 74 0c 00 00       	call   80101f44 <readi>
801012d0:	83 c4 10             	add    $0x10,%esp
801012d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012da:	7e 11                	jle    801012ed <fileread+0x92>
      f->off += r;
801012dc:	8b 45 08             	mov    0x8(%ebp),%eax
801012df:	8b 50 14             	mov    0x14(%eax),%edx
801012e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012e5:	01 c2                	add    %eax,%edx
801012e7:	8b 45 08             	mov    0x8(%ebp),%eax
801012ea:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012ed:	8b 45 08             	mov    0x8(%ebp),%eax
801012f0:	8b 40 10             	mov    0x10(%eax),%eax
801012f3:	83 ec 0c             	sub    $0xc,%esp
801012f6:	50                   	push   %eax
801012f7:	e8 6f 08 00 00       	call   80101b6b <iunlock>
801012fc:	83 c4 10             	add    $0x10,%esp
    return r;
801012ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101302:	eb 0d                	jmp    80101311 <fileread+0xb6>
  }
  panic("fileread");
80101304:	83 ec 0c             	sub    $0xc,%esp
80101307:	68 2b 88 10 80       	push   $0x8010882b
8010130c:	e8 a4 f2 ff ff       	call   801005b5 <panic>
}
80101311:	c9                   	leave  
80101312:	c3                   	ret    

80101313 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101313:	55                   	push   %ebp
80101314:	89 e5                	mov    %esp,%ebp
80101316:	53                   	push   %ebx
80101317:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010131a:	8b 45 08             	mov    0x8(%ebp),%eax
8010131d:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101321:	84 c0                	test   %al,%al
80101323:	75 0a                	jne    8010132f <filewrite+0x1c>
    return -1;
80101325:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010132a:	e9 1b 01 00 00       	jmp    8010144a <filewrite+0x137>
  if(f->type == FD_PIPE)
8010132f:	8b 45 08             	mov    0x8(%ebp),%eax
80101332:	8b 00                	mov    (%eax),%eax
80101334:	83 f8 01             	cmp    $0x1,%eax
80101337:	75 1d                	jne    80101356 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101339:	8b 45 08             	mov    0x8(%ebp),%eax
8010133c:	8b 40 0c             	mov    0xc(%eax),%eax
8010133f:	83 ec 04             	sub    $0x4,%esp
80101342:	ff 75 10             	push   0x10(%ebp)
80101345:	ff 75 0c             	push   0xc(%ebp)
80101348:	50                   	push   %eax
80101349:	e8 c3 2c 00 00       	call   80104011 <pipewrite>
8010134e:	83 c4 10             	add    $0x10,%esp
80101351:	e9 f4 00 00 00       	jmp    8010144a <filewrite+0x137>
  if(f->type == FD_INODE){
80101356:	8b 45 08             	mov    0x8(%ebp),%eax
80101359:	8b 00                	mov    (%eax),%eax
8010135b:	83 f8 02             	cmp    $0x2,%eax
8010135e:	0f 85 d9 00 00 00    	jne    8010143d <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
80101364:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
8010136b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101372:	e9 a3 00 00 00       	jmp    8010141a <filewrite+0x107>
      int n1 = n - i;
80101377:	8b 45 10             	mov    0x10(%ebp),%eax
8010137a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010137d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101383:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101386:	7e 06                	jle    8010138e <filewrite+0x7b>
        n1 = max;
80101388:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010138b:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010138e:	e8 dd 21 00 00       	call   80103570 <begin_op>
      ilock(f->ip);
80101393:	8b 45 08             	mov    0x8(%ebp),%eax
80101396:	8b 40 10             	mov    0x10(%eax),%eax
80101399:	83 ec 0c             	sub    $0xc,%esp
8010139c:	50                   	push   %eax
8010139d:	e8 b6 06 00 00       	call   80101a58 <ilock>
801013a2:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801013a5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801013a8:	8b 45 08             	mov    0x8(%ebp),%eax
801013ab:	8b 50 14             	mov    0x14(%eax),%edx
801013ae:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801013b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801013b4:	01 c3                	add    %eax,%ebx
801013b6:	8b 45 08             	mov    0x8(%ebp),%eax
801013b9:	8b 40 10             	mov    0x10(%eax),%eax
801013bc:	51                   	push   %ecx
801013bd:	52                   	push   %edx
801013be:	53                   	push   %ebx
801013bf:	50                   	push   %eax
801013c0:	e8 d4 0c 00 00       	call   80102099 <writei>
801013c5:	83 c4 10             	add    $0x10,%esp
801013c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013cb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013cf:	7e 11                	jle    801013e2 <filewrite+0xcf>
        f->off += r;
801013d1:	8b 45 08             	mov    0x8(%ebp),%eax
801013d4:	8b 50 14             	mov    0x14(%eax),%edx
801013d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013da:	01 c2                	add    %eax,%edx
801013dc:	8b 45 08             	mov    0x8(%ebp),%eax
801013df:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013e2:	8b 45 08             	mov    0x8(%ebp),%eax
801013e5:	8b 40 10             	mov    0x10(%eax),%eax
801013e8:	83 ec 0c             	sub    $0xc,%esp
801013eb:	50                   	push   %eax
801013ec:	e8 7a 07 00 00       	call   80101b6b <iunlock>
801013f1:	83 c4 10             	add    $0x10,%esp
      end_op();
801013f4:	e8 03 22 00 00       	call   801035fc <end_op>

      if(r < 0)
801013f9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013fd:	78 29                	js     80101428 <filewrite+0x115>
        break;
      if(r != n1)
801013ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101402:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101405:	74 0d                	je     80101414 <filewrite+0x101>
        panic("short filewrite");
80101407:	83 ec 0c             	sub    $0xc,%esp
8010140a:	68 34 88 10 80       	push   $0x80108834
8010140f:	e8 a1 f1 ff ff       	call   801005b5 <panic>
      i += r;
80101414:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101417:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
8010141a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010141d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101420:	0f 8c 51 ff ff ff    	jl     80101377 <filewrite+0x64>
80101426:	eb 01                	jmp    80101429 <filewrite+0x116>
        break;
80101428:	90                   	nop
    }
    return i == n ? n : -1;
80101429:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010142f:	75 05                	jne    80101436 <filewrite+0x123>
80101431:	8b 45 10             	mov    0x10(%ebp),%eax
80101434:	eb 14                	jmp    8010144a <filewrite+0x137>
80101436:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010143b:	eb 0d                	jmp    8010144a <filewrite+0x137>
  }
  panic("filewrite");
8010143d:	83 ec 0c             	sub    $0xc,%esp
80101440:	68 44 88 10 80       	push   $0x80108844
80101445:	e8 6b f1 ff ff       	call   801005b5 <panic>
}
8010144a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010144d:	c9                   	leave  
8010144e:	c3                   	ret    

8010144f <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010144f:	55                   	push   %ebp
80101450:	89 e5                	mov    %esp,%ebp
80101452:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101455:	8b 45 08             	mov    0x8(%ebp),%eax
80101458:	83 ec 08             	sub    $0x8,%esp
8010145b:	6a 01                	push   $0x1
8010145d:	50                   	push   %eax
8010145e:	e8 6c ed ff ff       	call   801001cf <bread>
80101463:	83 c4 10             	add    $0x10,%esp
80101466:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101469:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010146c:	83 c0 5c             	add    $0x5c,%eax
8010146f:	83 ec 04             	sub    $0x4,%esp
80101472:	6a 1c                	push   $0x1c
80101474:	50                   	push   %eax
80101475:	ff 75 0c             	push   0xc(%ebp)
80101478:	e8 05 42 00 00       	call   80105682 <memmove>
8010147d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101480:	83 ec 0c             	sub    $0xc,%esp
80101483:	ff 75 f4             	push   -0xc(%ebp)
80101486:	e8 c6 ed ff ff       	call   80100251 <brelse>
8010148b:	83 c4 10             	add    $0x10,%esp
}
8010148e:	90                   	nop
8010148f:	c9                   	leave  
80101490:	c3                   	ret    

80101491 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101491:	55                   	push   %ebp
80101492:	89 e5                	mov    %esp,%ebp
80101494:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101497:	8b 55 0c             	mov    0xc(%ebp),%edx
8010149a:	8b 45 08             	mov    0x8(%ebp),%eax
8010149d:	83 ec 08             	sub    $0x8,%esp
801014a0:	52                   	push   %edx
801014a1:	50                   	push   %eax
801014a2:	e8 28 ed ff ff       	call   801001cf <bread>
801014a7:	83 c4 10             	add    $0x10,%esp
801014aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801014ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014b0:	83 c0 5c             	add    $0x5c,%eax
801014b3:	83 ec 04             	sub    $0x4,%esp
801014b6:	68 00 02 00 00       	push   $0x200
801014bb:	6a 00                	push   $0x0
801014bd:	50                   	push   %eax
801014be:	e8 00 41 00 00       	call   801055c3 <memset>
801014c3:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014c6:	83 ec 0c             	sub    $0xc,%esp
801014c9:	ff 75 f4             	push   -0xc(%ebp)
801014cc:	e8 d8 22 00 00       	call   801037a9 <log_write>
801014d1:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014d4:	83 ec 0c             	sub    $0xc,%esp
801014d7:	ff 75 f4             	push   -0xc(%ebp)
801014da:	e8 72 ed ff ff       	call   80100251 <brelse>
801014df:	83 c4 10             	add    $0x10,%esp
}
801014e2:	90                   	nop
801014e3:	c9                   	leave  
801014e4:	c3                   	ret    

801014e5 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014e5:	55                   	push   %ebp
801014e6:	89 e5                	mov    %esp,%ebp
801014e8:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014eb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014f9:	e9 0b 01 00 00       	jmp    80101609 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
801014fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101501:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101507:	85 c0                	test   %eax,%eax
80101509:	0f 48 c2             	cmovs  %edx,%eax
8010150c:	c1 f8 0c             	sar    $0xc,%eax
8010150f:	89 c2                	mov    %eax,%edx
80101511:	a1 d8 09 11 80       	mov    0x801109d8,%eax
80101516:	01 d0                	add    %edx,%eax
80101518:	83 ec 08             	sub    $0x8,%esp
8010151b:	50                   	push   %eax
8010151c:	ff 75 08             	push   0x8(%ebp)
8010151f:	e8 ab ec ff ff       	call   801001cf <bread>
80101524:	83 c4 10             	add    $0x10,%esp
80101527:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010152a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101531:	e9 9e 00 00 00       	jmp    801015d4 <balloc+0xef>
      m = 1 << (bi % 8);
80101536:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101539:	83 e0 07             	and    $0x7,%eax
8010153c:	ba 01 00 00 00       	mov    $0x1,%edx
80101541:	89 c1                	mov    %eax,%ecx
80101543:	d3 e2                	shl    %cl,%edx
80101545:	89 d0                	mov    %edx,%eax
80101547:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010154a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154d:	8d 50 07             	lea    0x7(%eax),%edx
80101550:	85 c0                	test   %eax,%eax
80101552:	0f 48 c2             	cmovs  %edx,%eax
80101555:	c1 f8 03             	sar    $0x3,%eax
80101558:	89 c2                	mov    %eax,%edx
8010155a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010155d:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101562:	0f b6 c0             	movzbl %al,%eax
80101565:	23 45 e8             	and    -0x18(%ebp),%eax
80101568:	85 c0                	test   %eax,%eax
8010156a:	75 64                	jne    801015d0 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
8010156c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010156f:	8d 50 07             	lea    0x7(%eax),%edx
80101572:	85 c0                	test   %eax,%eax
80101574:	0f 48 c2             	cmovs  %edx,%eax
80101577:	c1 f8 03             	sar    $0x3,%eax
8010157a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010157d:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101582:	89 d1                	mov    %edx,%ecx
80101584:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101587:	09 ca                	or     %ecx,%edx
80101589:	89 d1                	mov    %edx,%ecx
8010158b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010158e:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101592:	83 ec 0c             	sub    $0xc,%esp
80101595:	ff 75 ec             	push   -0x14(%ebp)
80101598:	e8 0c 22 00 00       	call   801037a9 <log_write>
8010159d:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801015a0:	83 ec 0c             	sub    $0xc,%esp
801015a3:	ff 75 ec             	push   -0x14(%ebp)
801015a6:	e8 a6 ec ff ff       	call   80100251 <brelse>
801015ab:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801015ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b4:	01 c2                	add    %eax,%edx
801015b6:	8b 45 08             	mov    0x8(%ebp),%eax
801015b9:	83 ec 08             	sub    $0x8,%esp
801015bc:	52                   	push   %edx
801015bd:	50                   	push   %eax
801015be:	e8 ce fe ff ff       	call   80101491 <bzero>
801015c3:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015cc:	01 d0                	add    %edx,%eax
801015ce:	eb 57                	jmp    80101627 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015d0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015d4:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015db:	7f 17                	jg     801015f4 <balloc+0x10f>
801015dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e3:	01 d0                	add    %edx,%eax
801015e5:	89 c2                	mov    %eax,%edx
801015e7:	a1 c0 09 11 80       	mov    0x801109c0,%eax
801015ec:	39 c2                	cmp    %eax,%edx
801015ee:	0f 82 42 ff ff ff    	jb     80101536 <balloc+0x51>
      }
    }
    brelse(bp);
801015f4:	83 ec 0c             	sub    $0xc,%esp
801015f7:	ff 75 ec             	push   -0x14(%ebp)
801015fa:	e8 52 ec ff ff       	call   80100251 <brelse>
801015ff:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101602:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101609:	8b 15 c0 09 11 80    	mov    0x801109c0,%edx
8010160f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101612:	39 c2                	cmp    %eax,%edx
80101614:	0f 87 e4 fe ff ff    	ja     801014fe <balloc+0x19>
  }
  panic("balloc: out of blocks");
8010161a:	83 ec 0c             	sub    $0xc,%esp
8010161d:	68 50 88 10 80       	push   $0x80108850
80101622:	e8 8e ef ff ff       	call   801005b5 <panic>
}
80101627:	c9                   	leave  
80101628:	c3                   	ret    

80101629 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101629:	55                   	push   %ebp
8010162a:	89 e5                	mov    %esp,%ebp
8010162c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
8010162f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101632:	c1 e8 0c             	shr    $0xc,%eax
80101635:	89 c2                	mov    %eax,%edx
80101637:	a1 d8 09 11 80       	mov    0x801109d8,%eax
8010163c:	01 c2                	add    %eax,%edx
8010163e:	8b 45 08             	mov    0x8(%ebp),%eax
80101641:	83 ec 08             	sub    $0x8,%esp
80101644:	52                   	push   %edx
80101645:	50                   	push   %eax
80101646:	e8 84 eb ff ff       	call   801001cf <bread>
8010164b:	83 c4 10             	add    $0x10,%esp
8010164e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101651:	8b 45 0c             	mov    0xc(%ebp),%eax
80101654:	25 ff 0f 00 00       	and    $0xfff,%eax
80101659:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010165c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010165f:	83 e0 07             	and    $0x7,%eax
80101662:	ba 01 00 00 00       	mov    $0x1,%edx
80101667:	89 c1                	mov    %eax,%ecx
80101669:	d3 e2                	shl    %cl,%edx
8010166b:	89 d0                	mov    %edx,%eax
8010166d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101670:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101673:	8d 50 07             	lea    0x7(%eax),%edx
80101676:	85 c0                	test   %eax,%eax
80101678:	0f 48 c2             	cmovs  %edx,%eax
8010167b:	c1 f8 03             	sar    $0x3,%eax
8010167e:	89 c2                	mov    %eax,%edx
80101680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101683:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101688:	0f b6 c0             	movzbl %al,%eax
8010168b:	23 45 ec             	and    -0x14(%ebp),%eax
8010168e:	85 c0                	test   %eax,%eax
80101690:	75 0d                	jne    8010169f <bfree+0x76>
    panic("freeing free block");
80101692:	83 ec 0c             	sub    $0xc,%esp
80101695:	68 66 88 10 80       	push   $0x80108866
8010169a:	e8 16 ef ff ff       	call   801005b5 <panic>
  bp->data[bi/8] &= ~m;
8010169f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016a2:	8d 50 07             	lea    0x7(%eax),%edx
801016a5:	85 c0                	test   %eax,%eax
801016a7:	0f 48 c2             	cmovs  %edx,%eax
801016aa:	c1 f8 03             	sar    $0x3,%eax
801016ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016b0:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801016b5:	89 d1                	mov    %edx,%ecx
801016b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016ba:	f7 d2                	not    %edx
801016bc:	21 ca                	and    %ecx,%edx
801016be:	89 d1                	mov    %edx,%ecx
801016c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016c3:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801016c7:	83 ec 0c             	sub    $0xc,%esp
801016ca:	ff 75 f4             	push   -0xc(%ebp)
801016cd:	e8 d7 20 00 00       	call   801037a9 <log_write>
801016d2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016d5:	83 ec 0c             	sub    $0xc,%esp
801016d8:	ff 75 f4             	push   -0xc(%ebp)
801016db:	e8 71 eb ff ff       	call   80100251 <brelse>
801016e0:	83 c4 10             	add    $0x10,%esp
}
801016e3:	90                   	nop
801016e4:	c9                   	leave  
801016e5:	c3                   	ret    

801016e6 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016e6:	55                   	push   %ebp
801016e7:	89 e5                	mov    %esp,%ebp
801016e9:	57                   	push   %edi
801016ea:	56                   	push   %esi
801016eb:	53                   	push   %ebx
801016ec:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
801016ef:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801016f6:	83 ec 08             	sub    $0x8,%esp
801016f9:	68 79 88 10 80       	push   $0x80108879
801016fe:	68 e0 09 11 80       	push   $0x801109e0
80101703:	e8 13 3c 00 00       	call   8010531b <initlock>
80101708:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010170b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101712:	eb 2d                	jmp    80101741 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
80101714:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101717:	89 d0                	mov    %edx,%eax
80101719:	c1 e0 03             	shl    $0x3,%eax
8010171c:	01 d0                	add    %edx,%eax
8010171e:	c1 e0 04             	shl    $0x4,%eax
80101721:	83 c0 30             	add    $0x30,%eax
80101724:	05 e0 09 11 80       	add    $0x801109e0,%eax
80101729:	83 c0 10             	add    $0x10,%eax
8010172c:	83 ec 08             	sub    $0x8,%esp
8010172f:	68 80 88 10 80       	push   $0x80108880
80101734:	50                   	push   %eax
80101735:	e8 5e 3a 00 00       	call   80105198 <initsleeplock>
8010173a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010173d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101741:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101745:	7e cd                	jle    80101714 <iinit+0x2e>
  }

  readsb(dev, &sb);
80101747:	83 ec 08             	sub    $0x8,%esp
8010174a:	68 c0 09 11 80       	push   $0x801109c0
8010174f:	ff 75 08             	push   0x8(%ebp)
80101752:	e8 f8 fc ff ff       	call   8010144f <readsb>
80101757:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010175a:	a1 d8 09 11 80       	mov    0x801109d8,%eax
8010175f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101762:	8b 3d d4 09 11 80    	mov    0x801109d4,%edi
80101768:	8b 35 d0 09 11 80    	mov    0x801109d0,%esi
8010176e:	8b 1d cc 09 11 80    	mov    0x801109cc,%ebx
80101774:	8b 0d c8 09 11 80    	mov    0x801109c8,%ecx
8010177a:	8b 15 c4 09 11 80    	mov    0x801109c4,%edx
80101780:	a1 c0 09 11 80       	mov    0x801109c0,%eax
80101785:	ff 75 d4             	push   -0x2c(%ebp)
80101788:	57                   	push   %edi
80101789:	56                   	push   %esi
8010178a:	53                   	push   %ebx
8010178b:	51                   	push   %ecx
8010178c:	52                   	push   %edx
8010178d:	50                   	push   %eax
8010178e:	68 88 88 10 80       	push   $0x80108888
80101793:	e8 68 ec ff ff       	call   80100400 <cprintf>
80101798:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010179b:	90                   	nop
8010179c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010179f:	5b                   	pop    %ebx
801017a0:	5e                   	pop    %esi
801017a1:	5f                   	pop    %edi
801017a2:	5d                   	pop    %ebp
801017a3:	c3                   	ret    

801017a4 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801017a4:	55                   	push   %ebp
801017a5:	89 e5                	mov    %esp,%ebp
801017a7:	83 ec 28             	sub    $0x28,%esp
801017aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801017ad:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017b1:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017b8:	e9 9e 00 00 00       	jmp    8010185b <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801017bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c0:	c1 e8 03             	shr    $0x3,%eax
801017c3:	89 c2                	mov    %eax,%edx
801017c5:	a1 d4 09 11 80       	mov    0x801109d4,%eax
801017ca:	01 d0                	add    %edx,%eax
801017cc:	83 ec 08             	sub    $0x8,%esp
801017cf:	50                   	push   %eax
801017d0:	ff 75 08             	push   0x8(%ebp)
801017d3:	e8 f7 e9 ff ff       	call   801001cf <bread>
801017d8:	83 c4 10             	add    $0x10,%esp
801017db:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801017de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017e1:	8d 50 5c             	lea    0x5c(%eax),%edx
801017e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e7:	83 e0 07             	and    $0x7,%eax
801017ea:	c1 e0 06             	shl    $0x6,%eax
801017ed:	01 d0                	add    %edx,%eax
801017ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801017f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017f5:	0f b7 00             	movzwl (%eax),%eax
801017f8:	66 85 c0             	test   %ax,%ax
801017fb:	75 4c                	jne    80101849 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
801017fd:	83 ec 04             	sub    $0x4,%esp
80101800:	6a 40                	push   $0x40
80101802:	6a 00                	push   $0x0
80101804:	ff 75 ec             	push   -0x14(%ebp)
80101807:	e8 b7 3d 00 00       	call   801055c3 <memset>
8010180c:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
8010180f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101812:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101816:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101819:	83 ec 0c             	sub    $0xc,%esp
8010181c:	ff 75 f0             	push   -0x10(%ebp)
8010181f:	e8 85 1f 00 00       	call   801037a9 <log_write>
80101824:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101827:	83 ec 0c             	sub    $0xc,%esp
8010182a:	ff 75 f0             	push   -0x10(%ebp)
8010182d:	e8 1f ea ff ff       	call   80100251 <brelse>
80101832:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101838:	83 ec 08             	sub    $0x8,%esp
8010183b:	50                   	push   %eax
8010183c:	ff 75 08             	push   0x8(%ebp)
8010183f:	e8 f8 00 00 00       	call   8010193c <iget>
80101844:	83 c4 10             	add    $0x10,%esp
80101847:	eb 30                	jmp    80101879 <ialloc+0xd5>
    }
    brelse(bp);
80101849:	83 ec 0c             	sub    $0xc,%esp
8010184c:	ff 75 f0             	push   -0x10(%ebp)
8010184f:	e8 fd e9 ff ff       	call   80100251 <brelse>
80101854:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101857:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010185b:	8b 15 c8 09 11 80    	mov    0x801109c8,%edx
80101861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101864:	39 c2                	cmp    %eax,%edx
80101866:	0f 87 51 ff ff ff    	ja     801017bd <ialloc+0x19>
  }
  panic("ialloc: no inodes");
8010186c:	83 ec 0c             	sub    $0xc,%esp
8010186f:	68 db 88 10 80       	push   $0x801088db
80101874:	e8 3c ed ff ff       	call   801005b5 <panic>
}
80101879:	c9                   	leave  
8010187a:	c3                   	ret    

8010187b <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010187b:	55                   	push   %ebp
8010187c:	89 e5                	mov    %esp,%ebp
8010187e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101881:	8b 45 08             	mov    0x8(%ebp),%eax
80101884:	8b 40 04             	mov    0x4(%eax),%eax
80101887:	c1 e8 03             	shr    $0x3,%eax
8010188a:	89 c2                	mov    %eax,%edx
8010188c:	a1 d4 09 11 80       	mov    0x801109d4,%eax
80101891:	01 c2                	add    %eax,%edx
80101893:	8b 45 08             	mov    0x8(%ebp),%eax
80101896:	8b 00                	mov    (%eax),%eax
80101898:	83 ec 08             	sub    $0x8,%esp
8010189b:	52                   	push   %edx
8010189c:	50                   	push   %eax
8010189d:	e8 2d e9 ff ff       	call   801001cf <bread>
801018a2:	83 c4 10             	add    $0x10,%esp
801018a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801018a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ab:	8d 50 5c             	lea    0x5c(%eax),%edx
801018ae:	8b 45 08             	mov    0x8(%ebp),%eax
801018b1:	8b 40 04             	mov    0x4(%eax),%eax
801018b4:	83 e0 07             	and    $0x7,%eax
801018b7:	c1 e0 06             	shl    $0x6,%eax
801018ba:	01 d0                	add    %edx,%eax
801018bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801018bf:	8b 45 08             	mov    0x8(%ebp),%eax
801018c2:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801018c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018c9:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801018cc:	8b 45 08             	mov    0x8(%ebp),%eax
801018cf:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801018d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018d6:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801018da:	8b 45 08             	mov    0x8(%ebp),%eax
801018dd:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801018e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018e4:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801018e8:	8b 45 08             	mov    0x8(%ebp),%eax
801018eb:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801018ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f2:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801018f6:	8b 45 08             	mov    0x8(%ebp),%eax
801018f9:	8b 50 58             	mov    0x58(%eax),%edx
801018fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ff:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101902:	8b 45 08             	mov    0x8(%ebp),%eax
80101905:	8d 50 5c             	lea    0x5c(%eax),%edx
80101908:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010190b:	83 c0 0c             	add    $0xc,%eax
8010190e:	83 ec 04             	sub    $0x4,%esp
80101911:	6a 34                	push   $0x34
80101913:	52                   	push   %edx
80101914:	50                   	push   %eax
80101915:	e8 68 3d 00 00       	call   80105682 <memmove>
8010191a:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010191d:	83 ec 0c             	sub    $0xc,%esp
80101920:	ff 75 f4             	push   -0xc(%ebp)
80101923:	e8 81 1e 00 00       	call   801037a9 <log_write>
80101928:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010192b:	83 ec 0c             	sub    $0xc,%esp
8010192e:	ff 75 f4             	push   -0xc(%ebp)
80101931:	e8 1b e9 ff ff       	call   80100251 <brelse>
80101936:	83 c4 10             	add    $0x10,%esp
}
80101939:	90                   	nop
8010193a:	c9                   	leave  
8010193b:	c3                   	ret    

8010193c <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
8010193c:	55                   	push   %ebp
8010193d:	89 e5                	mov    %esp,%ebp
8010193f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101942:	83 ec 0c             	sub    $0xc,%esp
80101945:	68 e0 09 11 80       	push   $0x801109e0
8010194a:	e8 ee 39 00 00       	call   8010533d <acquire>
8010194f:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101952:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101959:	c7 45 f4 14 0a 11 80 	movl   $0x80110a14,-0xc(%ebp)
80101960:	eb 60                	jmp    801019c2 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101965:	8b 40 08             	mov    0x8(%eax),%eax
80101968:	85 c0                	test   %eax,%eax
8010196a:	7e 39                	jle    801019a5 <iget+0x69>
8010196c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196f:	8b 00                	mov    (%eax),%eax
80101971:	39 45 08             	cmp    %eax,0x8(%ebp)
80101974:	75 2f                	jne    801019a5 <iget+0x69>
80101976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101979:	8b 40 04             	mov    0x4(%eax),%eax
8010197c:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010197f:	75 24                	jne    801019a5 <iget+0x69>
      ip->ref++;
80101981:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101984:	8b 40 08             	mov    0x8(%eax),%eax
80101987:	8d 50 01             	lea    0x1(%eax),%edx
8010198a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198d:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101990:	83 ec 0c             	sub    $0xc,%esp
80101993:	68 e0 09 11 80       	push   $0x801109e0
80101998:	e8 0e 3a 00 00       	call   801053ab <release>
8010199d:	83 c4 10             	add    $0x10,%esp
      return ip;
801019a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a3:	eb 77                	jmp    80101a1c <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801019a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019a9:	75 10                	jne    801019bb <iget+0x7f>
801019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ae:	8b 40 08             	mov    0x8(%eax),%eax
801019b1:	85 c0                	test   %eax,%eax
801019b3:	75 06                	jne    801019bb <iget+0x7f>
      empty = ip;
801019b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019bb:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801019c2:	81 7d f4 34 26 11 80 	cmpl   $0x80112634,-0xc(%ebp)
801019c9:	72 97                	jb     80101962 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019cf:	75 0d                	jne    801019de <iget+0xa2>
    panic("iget: no inodes");
801019d1:	83 ec 0c             	sub    $0xc,%esp
801019d4:	68 ed 88 10 80       	push   $0x801088ed
801019d9:	e8 d7 eb ff ff       	call   801005b5 <panic>

  ip = empty;
801019de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801019e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e7:	8b 55 08             	mov    0x8(%ebp),%edx
801019ea:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801019ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ef:	8b 55 0c             	mov    0xc(%ebp),%edx
801019f2:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801019f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
801019ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a02:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a09:	83 ec 0c             	sub    $0xc,%esp
80101a0c:	68 e0 09 11 80       	push   $0x801109e0
80101a11:	e8 95 39 00 00       	call   801053ab <release>
80101a16:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a1c:	c9                   	leave  
80101a1d:	c3                   	ret    

80101a1e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a1e:	55                   	push   %ebp
80101a1f:	89 e5                	mov    %esp,%ebp
80101a21:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a24:	83 ec 0c             	sub    $0xc,%esp
80101a27:	68 e0 09 11 80       	push   $0x801109e0
80101a2c:	e8 0c 39 00 00       	call   8010533d <acquire>
80101a31:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a34:	8b 45 08             	mov    0x8(%ebp),%eax
80101a37:	8b 40 08             	mov    0x8(%eax),%eax
80101a3a:	8d 50 01             	lea    0x1(%eax),%edx
80101a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a40:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a43:	83 ec 0c             	sub    $0xc,%esp
80101a46:	68 e0 09 11 80       	push   $0x801109e0
80101a4b:	e8 5b 39 00 00       	call   801053ab <release>
80101a50:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a53:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a56:	c9                   	leave  
80101a57:	c3                   	ret    

80101a58 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a58:	55                   	push   %ebp
80101a59:	89 e5                	mov    %esp,%ebp
80101a5b:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a5e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a62:	74 0a                	je     80101a6e <ilock+0x16>
80101a64:	8b 45 08             	mov    0x8(%ebp),%eax
80101a67:	8b 40 08             	mov    0x8(%eax),%eax
80101a6a:	85 c0                	test   %eax,%eax
80101a6c:	7f 0d                	jg     80101a7b <ilock+0x23>
    panic("ilock");
80101a6e:	83 ec 0c             	sub    $0xc,%esp
80101a71:	68 fd 88 10 80       	push   $0x801088fd
80101a76:	e8 3a eb ff ff       	call   801005b5 <panic>

  acquiresleep(&ip->lock);
80101a7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7e:	83 c0 0c             	add    $0xc,%eax
80101a81:	83 ec 0c             	sub    $0xc,%esp
80101a84:	50                   	push   %eax
80101a85:	e8 4a 37 00 00       	call   801051d4 <acquiresleep>
80101a8a:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a90:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a93:	85 c0                	test   %eax,%eax
80101a95:	0f 85 cd 00 00 00    	jne    80101b68 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	8b 40 04             	mov    0x4(%eax),%eax
80101aa1:	c1 e8 03             	shr    $0x3,%eax
80101aa4:	89 c2                	mov    %eax,%edx
80101aa6:	a1 d4 09 11 80       	mov    0x801109d4,%eax
80101aab:	01 c2                	add    %eax,%edx
80101aad:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab0:	8b 00                	mov    (%eax),%eax
80101ab2:	83 ec 08             	sub    $0x8,%esp
80101ab5:	52                   	push   %edx
80101ab6:	50                   	push   %eax
80101ab7:	e8 13 e7 ff ff       	call   801001cf <bread>
80101abc:	83 c4 10             	add    $0x10,%esp
80101abf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac5:	8d 50 5c             	lea    0x5c(%eax),%edx
80101ac8:	8b 45 08             	mov    0x8(%ebp),%eax
80101acb:	8b 40 04             	mov    0x4(%eax),%eax
80101ace:	83 e0 07             	and    $0x7,%eax
80101ad1:	c1 e0 06             	shl    $0x6,%eax
80101ad4:	01 d0                	add    %edx,%eax
80101ad6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101ad9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101adc:	0f b7 10             	movzwl (%eax),%edx
80101adf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae2:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101ae6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ae9:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101aed:	8b 45 08             	mov    0x8(%ebp),%eax
80101af0:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101af7:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101afb:	8b 45 08             	mov    0x8(%ebp),%eax
80101afe:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b05:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b09:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0c:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b13:	8b 50 08             	mov    0x8(%eax),%edx
80101b16:	8b 45 08             	mov    0x8(%ebp),%eax
80101b19:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b1f:	8d 50 0c             	lea    0xc(%eax),%edx
80101b22:	8b 45 08             	mov    0x8(%ebp),%eax
80101b25:	83 c0 5c             	add    $0x5c,%eax
80101b28:	83 ec 04             	sub    $0x4,%esp
80101b2b:	6a 34                	push   $0x34
80101b2d:	52                   	push   %edx
80101b2e:	50                   	push   %eax
80101b2f:	e8 4e 3b 00 00       	call   80105682 <memmove>
80101b34:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b37:	83 ec 0c             	sub    $0xc,%esp
80101b3a:	ff 75 f4             	push   -0xc(%ebp)
80101b3d:	e8 0f e7 ff ff       	call   80100251 <brelse>
80101b42:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101b45:	8b 45 08             	mov    0x8(%ebp),%eax
80101b48:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b52:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101b56:	66 85 c0             	test   %ax,%ax
80101b59:	75 0d                	jne    80101b68 <ilock+0x110>
      panic("ilock: no type");
80101b5b:	83 ec 0c             	sub    $0xc,%esp
80101b5e:	68 03 89 10 80       	push   $0x80108903
80101b63:	e8 4d ea ff ff       	call   801005b5 <panic>
  }
}
80101b68:	90                   	nop
80101b69:	c9                   	leave  
80101b6a:	c3                   	ret    

80101b6b <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b6b:	55                   	push   %ebp
80101b6c:	89 e5                	mov    %esp,%ebp
80101b6e:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b71:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b75:	74 20                	je     80101b97 <iunlock+0x2c>
80101b77:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7a:	83 c0 0c             	add    $0xc,%eax
80101b7d:	83 ec 0c             	sub    $0xc,%esp
80101b80:	50                   	push   %eax
80101b81:	e8 00 37 00 00       	call   80105286 <holdingsleep>
80101b86:	83 c4 10             	add    $0x10,%esp
80101b89:	85 c0                	test   %eax,%eax
80101b8b:	74 0a                	je     80101b97 <iunlock+0x2c>
80101b8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b90:	8b 40 08             	mov    0x8(%eax),%eax
80101b93:	85 c0                	test   %eax,%eax
80101b95:	7f 0d                	jg     80101ba4 <iunlock+0x39>
    panic("iunlock");
80101b97:	83 ec 0c             	sub    $0xc,%esp
80101b9a:	68 12 89 10 80       	push   $0x80108912
80101b9f:	e8 11 ea ff ff       	call   801005b5 <panic>

  releasesleep(&ip->lock);
80101ba4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba7:	83 c0 0c             	add    $0xc,%eax
80101baa:	83 ec 0c             	sub    $0xc,%esp
80101bad:	50                   	push   %eax
80101bae:	e8 85 36 00 00       	call   80105238 <releasesleep>
80101bb3:	83 c4 10             	add    $0x10,%esp
}
80101bb6:	90                   	nop
80101bb7:	c9                   	leave  
80101bb8:	c3                   	ret    

80101bb9 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101bb9:	55                   	push   %ebp
80101bba:	89 e5                	mov    %esp,%ebp
80101bbc:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101bbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc2:	83 c0 0c             	add    $0xc,%eax
80101bc5:	83 ec 0c             	sub    $0xc,%esp
80101bc8:	50                   	push   %eax
80101bc9:	e8 06 36 00 00       	call   801051d4 <acquiresleep>
80101bce:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101bd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd4:	8b 40 4c             	mov    0x4c(%eax),%eax
80101bd7:	85 c0                	test   %eax,%eax
80101bd9:	74 6a                	je     80101c45 <iput+0x8c>
80101bdb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bde:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101be2:	66 85 c0             	test   %ax,%ax
80101be5:	75 5e                	jne    80101c45 <iput+0x8c>
    acquire(&icache.lock);
80101be7:	83 ec 0c             	sub    $0xc,%esp
80101bea:	68 e0 09 11 80       	push   $0x801109e0
80101bef:	e8 49 37 00 00       	call   8010533d <acquire>
80101bf4:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfa:	8b 40 08             	mov    0x8(%eax),%eax
80101bfd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c00:	83 ec 0c             	sub    $0xc,%esp
80101c03:	68 e0 09 11 80       	push   $0x801109e0
80101c08:	e8 9e 37 00 00       	call   801053ab <release>
80101c0d:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c10:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c14:	75 2f                	jne    80101c45 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c16:	83 ec 0c             	sub    $0xc,%esp
80101c19:	ff 75 08             	push   0x8(%ebp)
80101c1c:	e8 ad 01 00 00       	call   80101dce <itrunc>
80101c21:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101c24:	8b 45 08             	mov    0x8(%ebp),%eax
80101c27:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c2d:	83 ec 0c             	sub    $0xc,%esp
80101c30:	ff 75 08             	push   0x8(%ebp)
80101c33:	e8 43 fc ff ff       	call   8010187b <iupdate>
80101c38:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3e:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c45:	8b 45 08             	mov    0x8(%ebp),%eax
80101c48:	83 c0 0c             	add    $0xc,%eax
80101c4b:	83 ec 0c             	sub    $0xc,%esp
80101c4e:	50                   	push   %eax
80101c4f:	e8 e4 35 00 00       	call   80105238 <releasesleep>
80101c54:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c57:	83 ec 0c             	sub    $0xc,%esp
80101c5a:	68 e0 09 11 80       	push   $0x801109e0
80101c5f:	e8 d9 36 00 00       	call   8010533d <acquire>
80101c64:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c67:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6a:	8b 40 08             	mov    0x8(%eax),%eax
80101c6d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c70:	8b 45 08             	mov    0x8(%ebp),%eax
80101c73:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c76:	83 ec 0c             	sub    $0xc,%esp
80101c79:	68 e0 09 11 80       	push   $0x801109e0
80101c7e:	e8 28 37 00 00       	call   801053ab <release>
80101c83:	83 c4 10             	add    $0x10,%esp
}
80101c86:	90                   	nop
80101c87:	c9                   	leave  
80101c88:	c3                   	ret    

80101c89 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c89:	55                   	push   %ebp
80101c8a:	89 e5                	mov    %esp,%ebp
80101c8c:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c8f:	83 ec 0c             	sub    $0xc,%esp
80101c92:	ff 75 08             	push   0x8(%ebp)
80101c95:	e8 d1 fe ff ff       	call   80101b6b <iunlock>
80101c9a:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c9d:	83 ec 0c             	sub    $0xc,%esp
80101ca0:	ff 75 08             	push   0x8(%ebp)
80101ca3:	e8 11 ff ff ff       	call   80101bb9 <iput>
80101ca8:	83 c4 10             	add    $0x10,%esp
}
80101cab:	90                   	nop
80101cac:	c9                   	leave  
80101cad:	c3                   	ret    

80101cae <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101cae:	55                   	push   %ebp
80101caf:	89 e5                	mov    %esp,%ebp
80101cb1:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cb4:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101cb8:	77 42                	ja     80101cfc <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101cba:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbd:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cc0:	83 c2 14             	add    $0x14,%edx
80101cc3:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cce:	75 24                	jne    80101cf4 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd3:	8b 00                	mov    (%eax),%eax
80101cd5:	83 ec 0c             	sub    $0xc,%esp
80101cd8:	50                   	push   %eax
80101cd9:	e8 07 f8 ff ff       	call   801014e5 <balloc>
80101cde:	83 c4 10             	add    $0x10,%esp
80101ce1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ce4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cea:	8d 4a 14             	lea    0x14(%edx),%ecx
80101ced:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cf0:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cf7:	e9 d0 00 00 00       	jmp    80101dcc <bmap+0x11e>
  }
  bn -= NDIRECT;
80101cfc:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d00:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d04:	0f 87 b5 00 00 00    	ja     80101dbf <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0d:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d13:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d1a:	75 20                	jne    80101d3c <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1f:	8b 00                	mov    (%eax),%eax
80101d21:	83 ec 0c             	sub    $0xc,%esp
80101d24:	50                   	push   %eax
80101d25:	e8 bb f7 ff ff       	call   801014e5 <balloc>
80101d2a:	83 c4 10             	add    $0x10,%esp
80101d2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d30:	8b 45 08             	mov    0x8(%ebp),%eax
80101d33:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d36:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3f:	8b 00                	mov    (%eax),%eax
80101d41:	83 ec 08             	sub    $0x8,%esp
80101d44:	ff 75 f4             	push   -0xc(%ebp)
80101d47:	50                   	push   %eax
80101d48:	e8 82 e4 ff ff       	call   801001cf <bread>
80101d4d:	83 c4 10             	add    $0x10,%esp
80101d50:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d56:	83 c0 5c             	add    $0x5c,%eax
80101d59:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d5f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d66:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d69:	01 d0                	add    %edx,%eax
80101d6b:	8b 00                	mov    (%eax),%eax
80101d6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d74:	75 36                	jne    80101dac <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d76:	8b 45 08             	mov    0x8(%ebp),%eax
80101d79:	8b 00                	mov    (%eax),%eax
80101d7b:	83 ec 0c             	sub    $0xc,%esp
80101d7e:	50                   	push   %eax
80101d7f:	e8 61 f7 ff ff       	call   801014e5 <balloc>
80101d84:	83 c4 10             	add    $0x10,%esp
80101d87:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d94:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d97:	01 c2                	add    %eax,%edx
80101d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d9c:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d9e:	83 ec 0c             	sub    $0xc,%esp
80101da1:	ff 75 f0             	push   -0x10(%ebp)
80101da4:	e8 00 1a 00 00       	call   801037a9 <log_write>
80101da9:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101dac:	83 ec 0c             	sub    $0xc,%esp
80101daf:	ff 75 f0             	push   -0x10(%ebp)
80101db2:	e8 9a e4 ff ff       	call   80100251 <brelse>
80101db7:	83 c4 10             	add    $0x10,%esp
    return addr;
80101dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dbd:	eb 0d                	jmp    80101dcc <bmap+0x11e>
  }

  panic("bmap: out of range");
80101dbf:	83 ec 0c             	sub    $0xc,%esp
80101dc2:	68 1a 89 10 80       	push   $0x8010891a
80101dc7:	e8 e9 e7 ff ff       	call   801005b5 <panic>
}
80101dcc:	c9                   	leave  
80101dcd:	c3                   	ret    

80101dce <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101dce:	55                   	push   %ebp
80101dcf:	89 e5                	mov    %esp,%ebp
80101dd1:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101dd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ddb:	eb 45                	jmp    80101e22 <itrunc+0x54>
    if(ip->addrs[i]){
80101ddd:	8b 45 08             	mov    0x8(%ebp),%eax
80101de0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101de3:	83 c2 14             	add    $0x14,%edx
80101de6:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101dea:	85 c0                	test   %eax,%eax
80101dec:	74 30                	je     80101e1e <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101dee:	8b 45 08             	mov    0x8(%ebp),%eax
80101df1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101df4:	83 c2 14             	add    $0x14,%edx
80101df7:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101dfb:	8b 55 08             	mov    0x8(%ebp),%edx
80101dfe:	8b 12                	mov    (%edx),%edx
80101e00:	83 ec 08             	sub    $0x8,%esp
80101e03:	50                   	push   %eax
80101e04:	52                   	push   %edx
80101e05:	e8 1f f8 ff ff       	call   80101629 <bfree>
80101e0a:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e10:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e13:	83 c2 14             	add    $0x14,%edx
80101e16:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e1d:	00 
  for(i = 0; i < NDIRECT; i++){
80101e1e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e22:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e26:	7e b5                	jle    80101ddd <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101e28:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2b:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e31:	85 c0                	test   %eax,%eax
80101e33:	0f 84 aa 00 00 00    	je     80101ee3 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e39:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3c:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e42:	8b 45 08             	mov    0x8(%ebp),%eax
80101e45:	8b 00                	mov    (%eax),%eax
80101e47:	83 ec 08             	sub    $0x8,%esp
80101e4a:	52                   	push   %edx
80101e4b:	50                   	push   %eax
80101e4c:	e8 7e e3 ff ff       	call   801001cf <bread>
80101e51:	83 c4 10             	add    $0x10,%esp
80101e54:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e57:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e5a:	83 c0 5c             	add    $0x5c,%eax
80101e5d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e60:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e67:	eb 3c                	jmp    80101ea5 <itrunc+0xd7>
      if(a[j])
80101e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e6c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e73:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e76:	01 d0                	add    %edx,%eax
80101e78:	8b 00                	mov    (%eax),%eax
80101e7a:	85 c0                	test   %eax,%eax
80101e7c:	74 23                	je     80101ea1 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e81:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e88:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e8b:	01 d0                	add    %edx,%eax
80101e8d:	8b 00                	mov    (%eax),%eax
80101e8f:	8b 55 08             	mov    0x8(%ebp),%edx
80101e92:	8b 12                	mov    (%edx),%edx
80101e94:	83 ec 08             	sub    $0x8,%esp
80101e97:	50                   	push   %eax
80101e98:	52                   	push   %edx
80101e99:	e8 8b f7 ff ff       	call   80101629 <bfree>
80101e9e:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101ea1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea8:	83 f8 7f             	cmp    $0x7f,%eax
80101eab:	76 bc                	jbe    80101e69 <itrunc+0x9b>
    }
    brelse(bp);
80101ead:	83 ec 0c             	sub    $0xc,%esp
80101eb0:	ff 75 ec             	push   -0x14(%ebp)
80101eb3:	e8 99 e3 ff ff       	call   80100251 <brelse>
80101eb8:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ebb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebe:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ec4:	8b 55 08             	mov    0x8(%ebp),%edx
80101ec7:	8b 12                	mov    (%edx),%edx
80101ec9:	83 ec 08             	sub    $0x8,%esp
80101ecc:	50                   	push   %eax
80101ecd:	52                   	push   %edx
80101ece:	e8 56 f7 ff ff       	call   80101629 <bfree>
80101ed3:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101ed6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed9:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101ee0:	00 00 00 
  }

  ip->size = 0;
80101ee3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee6:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101eed:	83 ec 0c             	sub    $0xc,%esp
80101ef0:	ff 75 08             	push   0x8(%ebp)
80101ef3:	e8 83 f9 ff ff       	call   8010187b <iupdate>
80101ef8:	83 c4 10             	add    $0x10,%esp
}
80101efb:	90                   	nop
80101efc:	c9                   	leave  
80101efd:	c3                   	ret    

80101efe <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101efe:	55                   	push   %ebp
80101eff:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f01:	8b 45 08             	mov    0x8(%ebp),%eax
80101f04:	8b 00                	mov    (%eax),%eax
80101f06:	89 c2                	mov    %eax,%edx
80101f08:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f0b:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f11:	8b 50 04             	mov    0x4(%eax),%edx
80101f14:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f17:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1d:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101f21:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f24:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f27:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2a:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101f2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f31:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f35:	8b 45 08             	mov    0x8(%ebp),%eax
80101f38:	8b 50 58             	mov    0x58(%eax),%edx
80101f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f3e:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f41:	90                   	nop
80101f42:	5d                   	pop    %ebp
80101f43:	c3                   	ret    

80101f44 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f44:	55                   	push   %ebp
80101f45:	89 e5                	mov    %esp,%ebp
80101f47:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f51:	66 83 f8 03          	cmp    $0x3,%ax
80101f55:	75 5c                	jne    80101fb3 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f57:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f5e:	66 85 c0             	test   %ax,%ax
80101f61:	78 20                	js     80101f83 <readi+0x3f>
80101f63:	8b 45 08             	mov    0x8(%ebp),%eax
80101f66:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f6a:	66 83 f8 09          	cmp    $0x9,%ax
80101f6e:	7f 13                	jg     80101f83 <readi+0x3f>
80101f70:	8b 45 08             	mov    0x8(%ebp),%eax
80101f73:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f77:	98                   	cwtl   
80101f78:	8b 04 c5 c0 ff 10 80 	mov    -0x7fef0040(,%eax,8),%eax
80101f7f:	85 c0                	test   %eax,%eax
80101f81:	75 0a                	jne    80101f8d <readi+0x49>
      return -1;
80101f83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f88:	e9 0a 01 00 00       	jmp    80102097 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f90:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f94:	98                   	cwtl   
80101f95:	8b 04 c5 c0 ff 10 80 	mov    -0x7fef0040(,%eax,8),%eax
80101f9c:	8b 55 14             	mov    0x14(%ebp),%edx
80101f9f:	83 ec 04             	sub    $0x4,%esp
80101fa2:	52                   	push   %edx
80101fa3:	ff 75 0c             	push   0xc(%ebp)
80101fa6:	ff 75 08             	push   0x8(%ebp)
80101fa9:	ff d0                	call   *%eax
80101fab:	83 c4 10             	add    $0x10,%esp
80101fae:	e9 e4 00 00 00       	jmp    80102097 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb6:	8b 40 58             	mov    0x58(%eax),%eax
80101fb9:	39 45 10             	cmp    %eax,0x10(%ebp)
80101fbc:	77 0d                	ja     80101fcb <readi+0x87>
80101fbe:	8b 55 10             	mov    0x10(%ebp),%edx
80101fc1:	8b 45 14             	mov    0x14(%ebp),%eax
80101fc4:	01 d0                	add    %edx,%eax
80101fc6:	39 45 10             	cmp    %eax,0x10(%ebp)
80101fc9:	76 0a                	jbe    80101fd5 <readi+0x91>
    return -1;
80101fcb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fd0:	e9 c2 00 00 00       	jmp    80102097 <readi+0x153>
  if(off + n > ip->size)
80101fd5:	8b 55 10             	mov    0x10(%ebp),%edx
80101fd8:	8b 45 14             	mov    0x14(%ebp),%eax
80101fdb:	01 c2                	add    %eax,%edx
80101fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe0:	8b 40 58             	mov    0x58(%eax),%eax
80101fe3:	39 c2                	cmp    %eax,%edx
80101fe5:	76 0c                	jbe    80101ff3 <readi+0xaf>
    n = ip->size - off;
80101fe7:	8b 45 08             	mov    0x8(%ebp),%eax
80101fea:	8b 40 58             	mov    0x58(%eax),%eax
80101fed:	2b 45 10             	sub    0x10(%ebp),%eax
80101ff0:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ff3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ffa:	e9 89 00 00 00       	jmp    80102088 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fff:	8b 45 10             	mov    0x10(%ebp),%eax
80102002:	c1 e8 09             	shr    $0x9,%eax
80102005:	83 ec 08             	sub    $0x8,%esp
80102008:	50                   	push   %eax
80102009:	ff 75 08             	push   0x8(%ebp)
8010200c:	e8 9d fc ff ff       	call   80101cae <bmap>
80102011:	83 c4 10             	add    $0x10,%esp
80102014:	8b 55 08             	mov    0x8(%ebp),%edx
80102017:	8b 12                	mov    (%edx),%edx
80102019:	83 ec 08             	sub    $0x8,%esp
8010201c:	50                   	push   %eax
8010201d:	52                   	push   %edx
8010201e:	e8 ac e1 ff ff       	call   801001cf <bread>
80102023:	83 c4 10             	add    $0x10,%esp
80102026:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102029:	8b 45 10             	mov    0x10(%ebp),%eax
8010202c:	25 ff 01 00 00       	and    $0x1ff,%eax
80102031:	ba 00 02 00 00       	mov    $0x200,%edx
80102036:	29 c2                	sub    %eax,%edx
80102038:	8b 45 14             	mov    0x14(%ebp),%eax
8010203b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010203e:	39 c2                	cmp    %eax,%edx
80102040:	0f 46 c2             	cmovbe %edx,%eax
80102043:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102046:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102049:	8d 50 5c             	lea    0x5c(%eax),%edx
8010204c:	8b 45 10             	mov    0x10(%ebp),%eax
8010204f:	25 ff 01 00 00       	and    $0x1ff,%eax
80102054:	01 d0                	add    %edx,%eax
80102056:	83 ec 04             	sub    $0x4,%esp
80102059:	ff 75 ec             	push   -0x14(%ebp)
8010205c:	50                   	push   %eax
8010205d:	ff 75 0c             	push   0xc(%ebp)
80102060:	e8 1d 36 00 00       	call   80105682 <memmove>
80102065:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102068:	83 ec 0c             	sub    $0xc,%esp
8010206b:	ff 75 f0             	push   -0x10(%ebp)
8010206e:	e8 de e1 ff ff       	call   80100251 <brelse>
80102073:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102076:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102079:	01 45 f4             	add    %eax,-0xc(%ebp)
8010207c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010207f:	01 45 10             	add    %eax,0x10(%ebp)
80102082:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102085:	01 45 0c             	add    %eax,0xc(%ebp)
80102088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010208b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010208e:	0f 82 6b ff ff ff    	jb     80101fff <readi+0xbb>
  }
  return n;
80102094:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102097:	c9                   	leave  
80102098:	c3                   	ret    

80102099 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102099:	55                   	push   %ebp
8010209a:	89 e5                	mov    %esp,%ebp
8010209c:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010209f:	8b 45 08             	mov    0x8(%ebp),%eax
801020a2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801020a6:	66 83 f8 03          	cmp    $0x3,%ax
801020aa:	75 5c                	jne    80102108 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020ac:	8b 45 08             	mov    0x8(%ebp),%eax
801020af:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020b3:	66 85 c0             	test   %ax,%ax
801020b6:	78 20                	js     801020d8 <writei+0x3f>
801020b8:	8b 45 08             	mov    0x8(%ebp),%eax
801020bb:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020bf:	66 83 f8 09          	cmp    $0x9,%ax
801020c3:	7f 13                	jg     801020d8 <writei+0x3f>
801020c5:	8b 45 08             	mov    0x8(%ebp),%eax
801020c8:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020cc:	98                   	cwtl   
801020cd:	8b 04 c5 c4 ff 10 80 	mov    -0x7fef003c(,%eax,8),%eax
801020d4:	85 c0                	test   %eax,%eax
801020d6:	75 0a                	jne    801020e2 <writei+0x49>
      return -1;
801020d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020dd:	e9 3b 01 00 00       	jmp    8010221d <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
801020e2:	8b 45 08             	mov    0x8(%ebp),%eax
801020e5:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020e9:	98                   	cwtl   
801020ea:	8b 04 c5 c4 ff 10 80 	mov    -0x7fef003c(,%eax,8),%eax
801020f1:	8b 55 14             	mov    0x14(%ebp),%edx
801020f4:	83 ec 04             	sub    $0x4,%esp
801020f7:	52                   	push   %edx
801020f8:	ff 75 0c             	push   0xc(%ebp)
801020fb:	ff 75 08             	push   0x8(%ebp)
801020fe:	ff d0                	call   *%eax
80102100:	83 c4 10             	add    $0x10,%esp
80102103:	e9 15 01 00 00       	jmp    8010221d <writei+0x184>
  }

  if(off > ip->size || off + n < off)
80102108:	8b 45 08             	mov    0x8(%ebp),%eax
8010210b:	8b 40 58             	mov    0x58(%eax),%eax
8010210e:	39 45 10             	cmp    %eax,0x10(%ebp)
80102111:	77 0d                	ja     80102120 <writei+0x87>
80102113:	8b 55 10             	mov    0x10(%ebp),%edx
80102116:	8b 45 14             	mov    0x14(%ebp),%eax
80102119:	01 d0                	add    %edx,%eax
8010211b:	39 45 10             	cmp    %eax,0x10(%ebp)
8010211e:	76 0a                	jbe    8010212a <writei+0x91>
    return -1;
80102120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102125:	e9 f3 00 00 00       	jmp    8010221d <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
8010212a:	8b 55 10             	mov    0x10(%ebp),%edx
8010212d:	8b 45 14             	mov    0x14(%ebp),%eax
80102130:	01 d0                	add    %edx,%eax
80102132:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102137:	76 0a                	jbe    80102143 <writei+0xaa>
    return -1;
80102139:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010213e:	e9 da 00 00 00       	jmp    8010221d <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102143:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010214a:	e9 97 00 00 00       	jmp    801021e6 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010214f:	8b 45 10             	mov    0x10(%ebp),%eax
80102152:	c1 e8 09             	shr    $0x9,%eax
80102155:	83 ec 08             	sub    $0x8,%esp
80102158:	50                   	push   %eax
80102159:	ff 75 08             	push   0x8(%ebp)
8010215c:	e8 4d fb ff ff       	call   80101cae <bmap>
80102161:	83 c4 10             	add    $0x10,%esp
80102164:	8b 55 08             	mov    0x8(%ebp),%edx
80102167:	8b 12                	mov    (%edx),%edx
80102169:	83 ec 08             	sub    $0x8,%esp
8010216c:	50                   	push   %eax
8010216d:	52                   	push   %edx
8010216e:	e8 5c e0 ff ff       	call   801001cf <bread>
80102173:	83 c4 10             	add    $0x10,%esp
80102176:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102179:	8b 45 10             	mov    0x10(%ebp),%eax
8010217c:	25 ff 01 00 00       	and    $0x1ff,%eax
80102181:	ba 00 02 00 00       	mov    $0x200,%edx
80102186:	29 c2                	sub    %eax,%edx
80102188:	8b 45 14             	mov    0x14(%ebp),%eax
8010218b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010218e:	39 c2                	cmp    %eax,%edx
80102190:	0f 46 c2             	cmovbe %edx,%eax
80102193:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102196:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102199:	8d 50 5c             	lea    0x5c(%eax),%edx
8010219c:	8b 45 10             	mov    0x10(%ebp),%eax
8010219f:	25 ff 01 00 00       	and    $0x1ff,%eax
801021a4:	01 d0                	add    %edx,%eax
801021a6:	83 ec 04             	sub    $0x4,%esp
801021a9:	ff 75 ec             	push   -0x14(%ebp)
801021ac:	ff 75 0c             	push   0xc(%ebp)
801021af:	50                   	push   %eax
801021b0:	e8 cd 34 00 00       	call   80105682 <memmove>
801021b5:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801021b8:	83 ec 0c             	sub    $0xc,%esp
801021bb:	ff 75 f0             	push   -0x10(%ebp)
801021be:	e8 e6 15 00 00       	call   801037a9 <log_write>
801021c3:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801021c6:	83 ec 0c             	sub    $0xc,%esp
801021c9:	ff 75 f0             	push   -0x10(%ebp)
801021cc:	e8 80 e0 ff ff       	call   80100251 <brelse>
801021d1:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021d7:	01 45 f4             	add    %eax,-0xc(%ebp)
801021da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021dd:	01 45 10             	add    %eax,0x10(%ebp)
801021e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021e3:	01 45 0c             	add    %eax,0xc(%ebp)
801021e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021e9:	3b 45 14             	cmp    0x14(%ebp),%eax
801021ec:	0f 82 5d ff ff ff    	jb     8010214f <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
801021f2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801021f6:	74 22                	je     8010221a <writei+0x181>
801021f8:	8b 45 08             	mov    0x8(%ebp),%eax
801021fb:	8b 40 58             	mov    0x58(%eax),%eax
801021fe:	39 45 10             	cmp    %eax,0x10(%ebp)
80102201:	76 17                	jbe    8010221a <writei+0x181>
    ip->size = off;
80102203:	8b 45 08             	mov    0x8(%ebp),%eax
80102206:	8b 55 10             	mov    0x10(%ebp),%edx
80102209:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010220c:	83 ec 0c             	sub    $0xc,%esp
8010220f:	ff 75 08             	push   0x8(%ebp)
80102212:	e8 64 f6 ff ff       	call   8010187b <iupdate>
80102217:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010221a:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010221d:	c9                   	leave  
8010221e:	c3                   	ret    

8010221f <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010221f:	55                   	push   %ebp
80102220:	89 e5                	mov    %esp,%ebp
80102222:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102225:	83 ec 04             	sub    $0x4,%esp
80102228:	6a 0e                	push   $0xe
8010222a:	ff 75 0c             	push   0xc(%ebp)
8010222d:	ff 75 08             	push   0x8(%ebp)
80102230:	e8 e3 34 00 00       	call   80105718 <strncmp>
80102235:	83 c4 10             	add    $0x10,%esp
}
80102238:	c9                   	leave  
80102239:	c3                   	ret    

8010223a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010223a:	55                   	push   %ebp
8010223b:	89 e5                	mov    %esp,%ebp
8010223d:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102240:	8b 45 08             	mov    0x8(%ebp),%eax
80102243:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102247:	66 83 f8 01          	cmp    $0x1,%ax
8010224b:	74 0d                	je     8010225a <dirlookup+0x20>
    panic("dirlookup not DIR");
8010224d:	83 ec 0c             	sub    $0xc,%esp
80102250:	68 2d 89 10 80       	push   $0x8010892d
80102255:	e8 5b e3 ff ff       	call   801005b5 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010225a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102261:	eb 7b                	jmp    801022de <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102263:	6a 10                	push   $0x10
80102265:	ff 75 f4             	push   -0xc(%ebp)
80102268:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010226b:	50                   	push   %eax
8010226c:	ff 75 08             	push   0x8(%ebp)
8010226f:	e8 d0 fc ff ff       	call   80101f44 <readi>
80102274:	83 c4 10             	add    $0x10,%esp
80102277:	83 f8 10             	cmp    $0x10,%eax
8010227a:	74 0d                	je     80102289 <dirlookup+0x4f>
      panic("dirlookup read");
8010227c:	83 ec 0c             	sub    $0xc,%esp
8010227f:	68 3f 89 10 80       	push   $0x8010893f
80102284:	e8 2c e3 ff ff       	call   801005b5 <panic>
    if(de.inum == 0)
80102289:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010228d:	66 85 c0             	test   %ax,%ax
80102290:	74 47                	je     801022d9 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102292:	83 ec 08             	sub    $0x8,%esp
80102295:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102298:	83 c0 02             	add    $0x2,%eax
8010229b:	50                   	push   %eax
8010229c:	ff 75 0c             	push   0xc(%ebp)
8010229f:	e8 7b ff ff ff       	call   8010221f <namecmp>
801022a4:	83 c4 10             	add    $0x10,%esp
801022a7:	85 c0                	test   %eax,%eax
801022a9:	75 2f                	jne    801022da <dirlookup+0xa0>
      // entry matches path element
      if(poff)
801022ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022af:	74 08                	je     801022b9 <dirlookup+0x7f>
        *poff = off;
801022b1:	8b 45 10             	mov    0x10(%ebp),%eax
801022b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022b7:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801022b9:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022bd:	0f b7 c0             	movzwl %ax,%eax
801022c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801022c3:	8b 45 08             	mov    0x8(%ebp),%eax
801022c6:	8b 00                	mov    (%eax),%eax
801022c8:	83 ec 08             	sub    $0x8,%esp
801022cb:	ff 75 f0             	push   -0x10(%ebp)
801022ce:	50                   	push   %eax
801022cf:	e8 68 f6 ff ff       	call   8010193c <iget>
801022d4:	83 c4 10             	add    $0x10,%esp
801022d7:	eb 19                	jmp    801022f2 <dirlookup+0xb8>
      continue;
801022d9:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
801022da:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801022de:	8b 45 08             	mov    0x8(%ebp),%eax
801022e1:	8b 40 58             	mov    0x58(%eax),%eax
801022e4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801022e7:	0f 82 76 ff ff ff    	jb     80102263 <dirlookup+0x29>
    }
  }

  return 0;
801022ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022f2:	c9                   	leave  
801022f3:	c3                   	ret    

801022f4 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022f4:	55                   	push   %ebp
801022f5:	89 e5                	mov    %esp,%ebp
801022f7:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022fa:	83 ec 04             	sub    $0x4,%esp
801022fd:	6a 00                	push   $0x0
801022ff:	ff 75 0c             	push   0xc(%ebp)
80102302:	ff 75 08             	push   0x8(%ebp)
80102305:	e8 30 ff ff ff       	call   8010223a <dirlookup>
8010230a:	83 c4 10             	add    $0x10,%esp
8010230d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102310:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102314:	74 18                	je     8010232e <dirlink+0x3a>
    iput(ip);
80102316:	83 ec 0c             	sub    $0xc,%esp
80102319:	ff 75 f0             	push   -0x10(%ebp)
8010231c:	e8 98 f8 ff ff       	call   80101bb9 <iput>
80102321:	83 c4 10             	add    $0x10,%esp
    return -1;
80102324:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102329:	e9 9c 00 00 00       	jmp    801023ca <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010232e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102335:	eb 39                	jmp    80102370 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102337:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233a:	6a 10                	push   $0x10
8010233c:	50                   	push   %eax
8010233d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102340:	50                   	push   %eax
80102341:	ff 75 08             	push   0x8(%ebp)
80102344:	e8 fb fb ff ff       	call   80101f44 <readi>
80102349:	83 c4 10             	add    $0x10,%esp
8010234c:	83 f8 10             	cmp    $0x10,%eax
8010234f:	74 0d                	je     8010235e <dirlink+0x6a>
      panic("dirlink read");
80102351:	83 ec 0c             	sub    $0xc,%esp
80102354:	68 4e 89 10 80       	push   $0x8010894e
80102359:	e8 57 e2 ff ff       	call   801005b5 <panic>
    if(de.inum == 0)
8010235e:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102362:	66 85 c0             	test   %ax,%ax
80102365:	74 18                	je     8010237f <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010236a:	83 c0 10             	add    $0x10,%eax
8010236d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102370:	8b 45 08             	mov    0x8(%ebp),%eax
80102373:	8b 50 58             	mov    0x58(%eax),%edx
80102376:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102379:	39 c2                	cmp    %eax,%edx
8010237b:	77 ba                	ja     80102337 <dirlink+0x43>
8010237d:	eb 01                	jmp    80102380 <dirlink+0x8c>
      break;
8010237f:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102380:	83 ec 04             	sub    $0x4,%esp
80102383:	6a 0e                	push   $0xe
80102385:	ff 75 0c             	push   0xc(%ebp)
80102388:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010238b:	83 c0 02             	add    $0x2,%eax
8010238e:	50                   	push   %eax
8010238f:	e8 da 33 00 00       	call   8010576e <strncpy>
80102394:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102397:	8b 45 10             	mov    0x10(%ebp),%eax
8010239a:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010239e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a1:	6a 10                	push   $0x10
801023a3:	50                   	push   %eax
801023a4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023a7:	50                   	push   %eax
801023a8:	ff 75 08             	push   0x8(%ebp)
801023ab:	e8 e9 fc ff ff       	call   80102099 <writei>
801023b0:	83 c4 10             	add    $0x10,%esp
801023b3:	83 f8 10             	cmp    $0x10,%eax
801023b6:	74 0d                	je     801023c5 <dirlink+0xd1>
    panic("dirlink");
801023b8:	83 ec 0c             	sub    $0xc,%esp
801023bb:	68 5b 89 10 80       	push   $0x8010895b
801023c0:	e8 f0 e1 ff ff       	call   801005b5 <panic>

  return 0;
801023c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023ca:	c9                   	leave  
801023cb:	c3                   	ret    

801023cc <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801023cc:	55                   	push   %ebp
801023cd:	89 e5                	mov    %esp,%ebp
801023cf:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801023d2:	eb 04                	jmp    801023d8 <skipelem+0xc>
    path++;
801023d4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023d8:	8b 45 08             	mov    0x8(%ebp),%eax
801023db:	0f b6 00             	movzbl (%eax),%eax
801023de:	3c 2f                	cmp    $0x2f,%al
801023e0:	74 f2                	je     801023d4 <skipelem+0x8>
  if(*path == 0)
801023e2:	8b 45 08             	mov    0x8(%ebp),%eax
801023e5:	0f b6 00             	movzbl (%eax),%eax
801023e8:	84 c0                	test   %al,%al
801023ea:	75 07                	jne    801023f3 <skipelem+0x27>
    return 0;
801023ec:	b8 00 00 00 00       	mov    $0x0,%eax
801023f1:	eb 77                	jmp    8010246a <skipelem+0x9e>
  s = path;
801023f3:	8b 45 08             	mov    0x8(%ebp),%eax
801023f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023f9:	eb 04                	jmp    801023ff <skipelem+0x33>
    path++;
801023fb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801023ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102402:	0f b6 00             	movzbl (%eax),%eax
80102405:	3c 2f                	cmp    $0x2f,%al
80102407:	74 0a                	je     80102413 <skipelem+0x47>
80102409:	8b 45 08             	mov    0x8(%ebp),%eax
8010240c:	0f b6 00             	movzbl (%eax),%eax
8010240f:	84 c0                	test   %al,%al
80102411:	75 e8                	jne    801023fb <skipelem+0x2f>
  len = path - s;
80102413:	8b 45 08             	mov    0x8(%ebp),%eax
80102416:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102419:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010241c:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102420:	7e 15                	jle    80102437 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
80102422:	83 ec 04             	sub    $0x4,%esp
80102425:	6a 0e                	push   $0xe
80102427:	ff 75 f4             	push   -0xc(%ebp)
8010242a:	ff 75 0c             	push   0xc(%ebp)
8010242d:	e8 50 32 00 00       	call   80105682 <memmove>
80102432:	83 c4 10             	add    $0x10,%esp
80102435:	eb 26                	jmp    8010245d <skipelem+0x91>
  else {
    memmove(name, s, len);
80102437:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010243a:	83 ec 04             	sub    $0x4,%esp
8010243d:	50                   	push   %eax
8010243e:	ff 75 f4             	push   -0xc(%ebp)
80102441:	ff 75 0c             	push   0xc(%ebp)
80102444:	e8 39 32 00 00       	call   80105682 <memmove>
80102449:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010244c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010244f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102452:	01 d0                	add    %edx,%eax
80102454:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102457:	eb 04                	jmp    8010245d <skipelem+0x91>
    path++;
80102459:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010245d:	8b 45 08             	mov    0x8(%ebp),%eax
80102460:	0f b6 00             	movzbl (%eax),%eax
80102463:	3c 2f                	cmp    $0x2f,%al
80102465:	74 f2                	je     80102459 <skipelem+0x8d>
  return path;
80102467:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010246a:	c9                   	leave  
8010246b:	c3                   	ret    

8010246c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010246c:	55                   	push   %ebp
8010246d:	89 e5                	mov    %esp,%ebp
8010246f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102472:	8b 45 08             	mov    0x8(%ebp),%eax
80102475:	0f b6 00             	movzbl (%eax),%eax
80102478:	3c 2f                	cmp    $0x2f,%al
8010247a:	75 17                	jne    80102493 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010247c:	83 ec 08             	sub    $0x8,%esp
8010247f:	6a 01                	push   $0x1
80102481:	6a 01                	push   $0x1
80102483:	e8 b4 f4 ff ff       	call   8010193c <iget>
80102488:	83 c4 10             	add    $0x10,%esp
8010248b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010248e:	e9 ba 00 00 00       	jmp    8010254d <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102493:	e8 3f 1e 00 00       	call   801042d7 <myproc>
80102498:	8b 40 68             	mov    0x68(%eax),%eax
8010249b:	83 ec 0c             	sub    $0xc,%esp
8010249e:	50                   	push   %eax
8010249f:	e8 7a f5 ff ff       	call   80101a1e <idup>
801024a4:	83 c4 10             	add    $0x10,%esp
801024a7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801024aa:	e9 9e 00 00 00       	jmp    8010254d <namex+0xe1>
    ilock(ip);
801024af:	83 ec 0c             	sub    $0xc,%esp
801024b2:	ff 75 f4             	push   -0xc(%ebp)
801024b5:	e8 9e f5 ff ff       	call   80101a58 <ilock>
801024ba:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801024bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024c0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801024c4:	66 83 f8 01          	cmp    $0x1,%ax
801024c8:	74 18                	je     801024e2 <namex+0x76>
      iunlockput(ip);
801024ca:	83 ec 0c             	sub    $0xc,%esp
801024cd:	ff 75 f4             	push   -0xc(%ebp)
801024d0:	e8 b4 f7 ff ff       	call   80101c89 <iunlockput>
801024d5:	83 c4 10             	add    $0x10,%esp
      return 0;
801024d8:	b8 00 00 00 00       	mov    $0x0,%eax
801024dd:	e9 a7 00 00 00       	jmp    80102589 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
801024e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024e6:	74 20                	je     80102508 <namex+0x9c>
801024e8:	8b 45 08             	mov    0x8(%ebp),%eax
801024eb:	0f b6 00             	movzbl (%eax),%eax
801024ee:	84 c0                	test   %al,%al
801024f0:	75 16                	jne    80102508 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
801024f2:	83 ec 0c             	sub    $0xc,%esp
801024f5:	ff 75 f4             	push   -0xc(%ebp)
801024f8:	e8 6e f6 ff ff       	call   80101b6b <iunlock>
801024fd:	83 c4 10             	add    $0x10,%esp
      return ip;
80102500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102503:	e9 81 00 00 00       	jmp    80102589 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102508:	83 ec 04             	sub    $0x4,%esp
8010250b:	6a 00                	push   $0x0
8010250d:	ff 75 10             	push   0x10(%ebp)
80102510:	ff 75 f4             	push   -0xc(%ebp)
80102513:	e8 22 fd ff ff       	call   8010223a <dirlookup>
80102518:	83 c4 10             	add    $0x10,%esp
8010251b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010251e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102522:	75 15                	jne    80102539 <namex+0xcd>
      iunlockput(ip);
80102524:	83 ec 0c             	sub    $0xc,%esp
80102527:	ff 75 f4             	push   -0xc(%ebp)
8010252a:	e8 5a f7 ff ff       	call   80101c89 <iunlockput>
8010252f:	83 c4 10             	add    $0x10,%esp
      return 0;
80102532:	b8 00 00 00 00       	mov    $0x0,%eax
80102537:	eb 50                	jmp    80102589 <namex+0x11d>
    }
    iunlockput(ip);
80102539:	83 ec 0c             	sub    $0xc,%esp
8010253c:	ff 75 f4             	push   -0xc(%ebp)
8010253f:	e8 45 f7 ff ff       	call   80101c89 <iunlockput>
80102544:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102547:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010254a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
8010254d:	83 ec 08             	sub    $0x8,%esp
80102550:	ff 75 10             	push   0x10(%ebp)
80102553:	ff 75 08             	push   0x8(%ebp)
80102556:	e8 71 fe ff ff       	call   801023cc <skipelem>
8010255b:	83 c4 10             	add    $0x10,%esp
8010255e:	89 45 08             	mov    %eax,0x8(%ebp)
80102561:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102565:	0f 85 44 ff ff ff    	jne    801024af <namex+0x43>
  }
  if(nameiparent){
8010256b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010256f:	74 15                	je     80102586 <namex+0x11a>
    iput(ip);
80102571:	83 ec 0c             	sub    $0xc,%esp
80102574:	ff 75 f4             	push   -0xc(%ebp)
80102577:	e8 3d f6 ff ff       	call   80101bb9 <iput>
8010257c:	83 c4 10             	add    $0x10,%esp
    return 0;
8010257f:	b8 00 00 00 00       	mov    $0x0,%eax
80102584:	eb 03                	jmp    80102589 <namex+0x11d>
  }
  return ip;
80102586:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102589:	c9                   	leave  
8010258a:	c3                   	ret    

8010258b <namei>:

struct inode*
namei(char *path)
{
8010258b:	55                   	push   %ebp
8010258c:	89 e5                	mov    %esp,%ebp
8010258e:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102591:	83 ec 04             	sub    $0x4,%esp
80102594:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102597:	50                   	push   %eax
80102598:	6a 00                	push   $0x0
8010259a:	ff 75 08             	push   0x8(%ebp)
8010259d:	e8 ca fe ff ff       	call   8010246c <namex>
801025a2:	83 c4 10             	add    $0x10,%esp
}
801025a5:	c9                   	leave  
801025a6:	c3                   	ret    

801025a7 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801025a7:	55                   	push   %ebp
801025a8:	89 e5                	mov    %esp,%ebp
801025aa:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801025ad:	83 ec 04             	sub    $0x4,%esp
801025b0:	ff 75 0c             	push   0xc(%ebp)
801025b3:	6a 01                	push   $0x1
801025b5:	ff 75 08             	push   0x8(%ebp)
801025b8:	e8 af fe ff ff       	call   8010246c <namex>
801025bd:	83 c4 10             	add    $0x10,%esp
}
801025c0:	c9                   	leave  
801025c1:	c3                   	ret    

801025c2 <inb>:
{
801025c2:	55                   	push   %ebp
801025c3:	89 e5                	mov    %esp,%ebp
801025c5:	83 ec 14             	sub    $0x14,%esp
801025c8:	8b 45 08             	mov    0x8(%ebp),%eax
801025cb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025cf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801025d3:	89 c2                	mov    %eax,%edx
801025d5:	ec                   	in     (%dx),%al
801025d6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801025d9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801025dd:	c9                   	leave  
801025de:	c3                   	ret    

801025df <insl>:
{
801025df:	55                   	push   %ebp
801025e0:	89 e5                	mov    %esp,%ebp
801025e2:	57                   	push   %edi
801025e3:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801025e4:	8b 55 08             	mov    0x8(%ebp),%edx
801025e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025ea:	8b 45 10             	mov    0x10(%ebp),%eax
801025ed:	89 cb                	mov    %ecx,%ebx
801025ef:	89 df                	mov    %ebx,%edi
801025f1:	89 c1                	mov    %eax,%ecx
801025f3:	fc                   	cld    
801025f4:	f3 6d                	rep insl (%dx),%es:(%edi)
801025f6:	89 c8                	mov    %ecx,%eax
801025f8:	89 fb                	mov    %edi,%ebx
801025fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025fd:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102600:	90                   	nop
80102601:	5b                   	pop    %ebx
80102602:	5f                   	pop    %edi
80102603:	5d                   	pop    %ebp
80102604:	c3                   	ret    

80102605 <outb>:
{
80102605:	55                   	push   %ebp
80102606:	89 e5                	mov    %esp,%ebp
80102608:	83 ec 08             	sub    $0x8,%esp
8010260b:	8b 45 08             	mov    0x8(%ebp),%eax
8010260e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102611:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102615:	89 d0                	mov    %edx,%eax
80102617:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010261a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010261e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102622:	ee                   	out    %al,(%dx)
}
80102623:	90                   	nop
80102624:	c9                   	leave  
80102625:	c3                   	ret    

80102626 <outsl>:
{
80102626:	55                   	push   %ebp
80102627:	89 e5                	mov    %esp,%ebp
80102629:	56                   	push   %esi
8010262a:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010262b:	8b 55 08             	mov    0x8(%ebp),%edx
8010262e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102631:	8b 45 10             	mov    0x10(%ebp),%eax
80102634:	89 cb                	mov    %ecx,%ebx
80102636:	89 de                	mov    %ebx,%esi
80102638:	89 c1                	mov    %eax,%ecx
8010263a:	fc                   	cld    
8010263b:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010263d:	89 c8                	mov    %ecx,%eax
8010263f:	89 f3                	mov    %esi,%ebx
80102641:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102644:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102647:	90                   	nop
80102648:	5b                   	pop    %ebx
80102649:	5e                   	pop    %esi
8010264a:	5d                   	pop    %ebp
8010264b:	c3                   	ret    

8010264c <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010264c:	55                   	push   %ebp
8010264d:	89 e5                	mov    %esp,%ebp
8010264f:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102652:	90                   	nop
80102653:	68 f7 01 00 00       	push   $0x1f7
80102658:	e8 65 ff ff ff       	call   801025c2 <inb>
8010265d:	83 c4 04             	add    $0x4,%esp
80102660:	0f b6 c0             	movzbl %al,%eax
80102663:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102666:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102669:	25 c0 00 00 00       	and    $0xc0,%eax
8010266e:	83 f8 40             	cmp    $0x40,%eax
80102671:	75 e0                	jne    80102653 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102673:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102677:	74 11                	je     8010268a <idewait+0x3e>
80102679:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010267c:	83 e0 21             	and    $0x21,%eax
8010267f:	85 c0                	test   %eax,%eax
80102681:	74 07                	je     8010268a <idewait+0x3e>
    return -1;
80102683:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102688:	eb 05                	jmp    8010268f <idewait+0x43>
  return 0;
8010268a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010268f:	c9                   	leave  
80102690:	c3                   	ret    

80102691 <ideinit>:

void
ideinit(void)
{
80102691:	55                   	push   %ebp
80102692:	89 e5                	mov    %esp,%ebp
80102694:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102697:	83 ec 08             	sub    $0x8,%esp
8010269a:	68 63 89 10 80       	push   $0x80108963
8010269f:	68 40 26 11 80       	push   $0x80112640
801026a4:	e8 72 2c 00 00       	call   8010531b <initlock>
801026a9:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801026ac:	a1 40 2d 11 80       	mov    0x80112d40,%eax
801026b1:	83 e8 01             	sub    $0x1,%eax
801026b4:	83 ec 08             	sub    $0x8,%esp
801026b7:	50                   	push   %eax
801026b8:	6a 0e                	push   $0xe
801026ba:	e8 a3 04 00 00       	call   80102b62 <ioapicenable>
801026bf:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801026c2:	83 ec 0c             	sub    $0xc,%esp
801026c5:	6a 00                	push   $0x0
801026c7:	e8 80 ff ff ff       	call   8010264c <idewait>
801026cc:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801026cf:	83 ec 08             	sub    $0x8,%esp
801026d2:	68 f0 00 00 00       	push   $0xf0
801026d7:	68 f6 01 00 00       	push   $0x1f6
801026dc:	e8 24 ff ff ff       	call   80102605 <outb>
801026e1:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
801026e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026eb:	eb 24                	jmp    80102711 <ideinit+0x80>
    if(inb(0x1f7) != 0){
801026ed:	83 ec 0c             	sub    $0xc,%esp
801026f0:	68 f7 01 00 00       	push   $0x1f7
801026f5:	e8 c8 fe ff ff       	call   801025c2 <inb>
801026fa:	83 c4 10             	add    $0x10,%esp
801026fd:	84 c0                	test   %al,%al
801026ff:	74 0c                	je     8010270d <ideinit+0x7c>
      havedisk1 = 1;
80102701:	c7 05 78 26 11 80 01 	movl   $0x1,0x80112678
80102708:	00 00 00 
      break;
8010270b:	eb 0d                	jmp    8010271a <ideinit+0x89>
  for(i=0; i<1000; i++){
8010270d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102711:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102718:	7e d3                	jle    801026ed <ideinit+0x5c>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010271a:	83 ec 08             	sub    $0x8,%esp
8010271d:	68 e0 00 00 00       	push   $0xe0
80102722:	68 f6 01 00 00       	push   $0x1f6
80102727:	e8 d9 fe ff ff       	call   80102605 <outb>
8010272c:	83 c4 10             	add    $0x10,%esp
}
8010272f:	90                   	nop
80102730:	c9                   	leave  
80102731:	c3                   	ret    

80102732 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102732:	55                   	push   %ebp
80102733:	89 e5                	mov    %esp,%ebp
80102735:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102738:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010273c:	75 0d                	jne    8010274b <idestart+0x19>
    panic("idestart");
8010273e:	83 ec 0c             	sub    $0xc,%esp
80102741:	68 67 89 10 80       	push   $0x80108967
80102746:	e8 6a de ff ff       	call   801005b5 <panic>
  if(b->blockno >= FSSIZE)
8010274b:	8b 45 08             	mov    0x8(%ebp),%eax
8010274e:	8b 40 08             	mov    0x8(%eax),%eax
80102751:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102756:	76 0d                	jbe    80102765 <idestart+0x33>
    panic("incorrect blockno");
80102758:	83 ec 0c             	sub    $0xc,%esp
8010275b:	68 70 89 10 80       	push   $0x80108970
80102760:	e8 50 de ff ff       	call   801005b5 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102765:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
8010276c:	8b 45 08             	mov    0x8(%ebp),%eax
8010276f:	8b 50 08             	mov    0x8(%eax),%edx
80102772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102775:	0f af c2             	imul   %edx,%eax
80102778:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
8010277b:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010277f:	75 07                	jne    80102788 <idestart+0x56>
80102781:	b8 20 00 00 00       	mov    $0x20,%eax
80102786:	eb 05                	jmp    8010278d <idestart+0x5b>
80102788:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010278d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102790:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102794:	75 07                	jne    8010279d <idestart+0x6b>
80102796:	b8 30 00 00 00       	mov    $0x30,%eax
8010279b:	eb 05                	jmp    801027a2 <idestart+0x70>
8010279d:	b8 c5 00 00 00       	mov    $0xc5,%eax
801027a2:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801027a5:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801027a9:	7e 0d                	jle    801027b8 <idestart+0x86>
801027ab:	83 ec 0c             	sub    $0xc,%esp
801027ae:	68 67 89 10 80       	push   $0x80108967
801027b3:	e8 fd dd ff ff       	call   801005b5 <panic>

  idewait(0);
801027b8:	83 ec 0c             	sub    $0xc,%esp
801027bb:	6a 00                	push   $0x0
801027bd:	e8 8a fe ff ff       	call   8010264c <idewait>
801027c2:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801027c5:	83 ec 08             	sub    $0x8,%esp
801027c8:	6a 00                	push   $0x0
801027ca:	68 f6 03 00 00       	push   $0x3f6
801027cf:	e8 31 fe ff ff       	call   80102605 <outb>
801027d4:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
801027d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027da:	0f b6 c0             	movzbl %al,%eax
801027dd:	83 ec 08             	sub    $0x8,%esp
801027e0:	50                   	push   %eax
801027e1:	68 f2 01 00 00       	push   $0x1f2
801027e6:	e8 1a fe ff ff       	call   80102605 <outb>
801027eb:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
801027ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027f1:	0f b6 c0             	movzbl %al,%eax
801027f4:	83 ec 08             	sub    $0x8,%esp
801027f7:	50                   	push   %eax
801027f8:	68 f3 01 00 00       	push   $0x1f3
801027fd:	e8 03 fe ff ff       	call   80102605 <outb>
80102802:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102805:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102808:	c1 f8 08             	sar    $0x8,%eax
8010280b:	0f b6 c0             	movzbl %al,%eax
8010280e:	83 ec 08             	sub    $0x8,%esp
80102811:	50                   	push   %eax
80102812:	68 f4 01 00 00       	push   $0x1f4
80102817:	e8 e9 fd ff ff       	call   80102605 <outb>
8010281c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010281f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102822:	c1 f8 10             	sar    $0x10,%eax
80102825:	0f b6 c0             	movzbl %al,%eax
80102828:	83 ec 08             	sub    $0x8,%esp
8010282b:	50                   	push   %eax
8010282c:	68 f5 01 00 00       	push   $0x1f5
80102831:	e8 cf fd ff ff       	call   80102605 <outb>
80102836:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102839:	8b 45 08             	mov    0x8(%ebp),%eax
8010283c:	8b 40 04             	mov    0x4(%eax),%eax
8010283f:	c1 e0 04             	shl    $0x4,%eax
80102842:	83 e0 10             	and    $0x10,%eax
80102845:	89 c2                	mov    %eax,%edx
80102847:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010284a:	c1 f8 18             	sar    $0x18,%eax
8010284d:	83 e0 0f             	and    $0xf,%eax
80102850:	09 d0                	or     %edx,%eax
80102852:	83 c8 e0             	or     $0xffffffe0,%eax
80102855:	0f b6 c0             	movzbl %al,%eax
80102858:	83 ec 08             	sub    $0x8,%esp
8010285b:	50                   	push   %eax
8010285c:	68 f6 01 00 00       	push   $0x1f6
80102861:	e8 9f fd ff ff       	call   80102605 <outb>
80102866:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102869:	8b 45 08             	mov    0x8(%ebp),%eax
8010286c:	8b 00                	mov    (%eax),%eax
8010286e:	83 e0 04             	and    $0x4,%eax
80102871:	85 c0                	test   %eax,%eax
80102873:	74 35                	je     801028aa <idestart+0x178>
    outb(0x1f7, write_cmd);
80102875:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102878:	0f b6 c0             	movzbl %al,%eax
8010287b:	83 ec 08             	sub    $0x8,%esp
8010287e:	50                   	push   %eax
8010287f:	68 f7 01 00 00       	push   $0x1f7
80102884:	e8 7c fd ff ff       	call   80102605 <outb>
80102889:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
8010288c:	8b 45 08             	mov    0x8(%ebp),%eax
8010288f:	83 c0 5c             	add    $0x5c,%eax
80102892:	83 ec 04             	sub    $0x4,%esp
80102895:	68 80 00 00 00       	push   $0x80
8010289a:	50                   	push   %eax
8010289b:	68 f0 01 00 00       	push   $0x1f0
801028a0:	e8 81 fd ff ff       	call   80102626 <outsl>
801028a5:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
801028a8:	eb 17                	jmp    801028c1 <idestart+0x18f>
    outb(0x1f7, read_cmd);
801028aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801028ad:	0f b6 c0             	movzbl %al,%eax
801028b0:	83 ec 08             	sub    $0x8,%esp
801028b3:	50                   	push   %eax
801028b4:	68 f7 01 00 00       	push   $0x1f7
801028b9:	e8 47 fd ff ff       	call   80102605 <outb>
801028be:	83 c4 10             	add    $0x10,%esp
}
801028c1:	90                   	nop
801028c2:	c9                   	leave  
801028c3:	c3                   	ret    

801028c4 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801028c4:	55                   	push   %ebp
801028c5:	89 e5                	mov    %esp,%ebp
801028c7:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801028ca:	83 ec 0c             	sub    $0xc,%esp
801028cd:	68 40 26 11 80       	push   $0x80112640
801028d2:	e8 66 2a 00 00       	call   8010533d <acquire>
801028d7:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
801028da:	a1 74 26 11 80       	mov    0x80112674,%eax
801028df:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028e6:	75 15                	jne    801028fd <ideintr+0x39>
    release(&idelock);
801028e8:	83 ec 0c             	sub    $0xc,%esp
801028eb:	68 40 26 11 80       	push   $0x80112640
801028f0:	e8 b6 2a 00 00       	call   801053ab <release>
801028f5:	83 c4 10             	add    $0x10,%esp
    return;
801028f8:	e9 9a 00 00 00       	jmp    80102997 <ideintr+0xd3>
  }
  idequeue = b->qnext;
801028fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102900:	8b 40 58             	mov    0x58(%eax),%eax
80102903:	a3 74 26 11 80       	mov    %eax,0x80112674

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010290b:	8b 00                	mov    (%eax),%eax
8010290d:	83 e0 04             	and    $0x4,%eax
80102910:	85 c0                	test   %eax,%eax
80102912:	75 2d                	jne    80102941 <ideintr+0x7d>
80102914:	83 ec 0c             	sub    $0xc,%esp
80102917:	6a 01                	push   $0x1
80102919:	e8 2e fd ff ff       	call   8010264c <idewait>
8010291e:	83 c4 10             	add    $0x10,%esp
80102921:	85 c0                	test   %eax,%eax
80102923:	78 1c                	js     80102941 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102928:	83 c0 5c             	add    $0x5c,%eax
8010292b:	83 ec 04             	sub    $0x4,%esp
8010292e:	68 80 00 00 00       	push   $0x80
80102933:	50                   	push   %eax
80102934:	68 f0 01 00 00       	push   $0x1f0
80102939:	e8 a1 fc ff ff       	call   801025df <insl>
8010293e:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102944:	8b 00                	mov    (%eax),%eax
80102946:	83 c8 02             	or     $0x2,%eax
80102949:	89 c2                	mov    %eax,%edx
8010294b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010294e:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102953:	8b 00                	mov    (%eax),%eax
80102955:	83 e0 fb             	and    $0xfffffffb,%eax
80102958:	89 c2                	mov    %eax,%edx
8010295a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010295d:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010295f:	83 ec 0c             	sub    $0xc,%esp
80102962:	ff 75 f4             	push   -0xc(%ebp)
80102965:	e8 73 26 00 00       	call   80104fdd <wakeup>
8010296a:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
8010296d:	a1 74 26 11 80       	mov    0x80112674,%eax
80102972:	85 c0                	test   %eax,%eax
80102974:	74 11                	je     80102987 <ideintr+0xc3>
    idestart(idequeue);
80102976:	a1 74 26 11 80       	mov    0x80112674,%eax
8010297b:	83 ec 0c             	sub    $0xc,%esp
8010297e:	50                   	push   %eax
8010297f:	e8 ae fd ff ff       	call   80102732 <idestart>
80102984:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102987:	83 ec 0c             	sub    $0xc,%esp
8010298a:	68 40 26 11 80       	push   $0x80112640
8010298f:	e8 17 2a 00 00       	call   801053ab <release>
80102994:	83 c4 10             	add    $0x10,%esp
}
80102997:	c9                   	leave  
80102998:	c3                   	ret    

80102999 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102999:	55                   	push   %ebp
8010299a:	89 e5                	mov    %esp,%ebp
8010299c:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
8010299f:	8b 45 08             	mov    0x8(%ebp),%eax
801029a2:	83 c0 0c             	add    $0xc,%eax
801029a5:	83 ec 0c             	sub    $0xc,%esp
801029a8:	50                   	push   %eax
801029a9:	e8 d8 28 00 00       	call   80105286 <holdingsleep>
801029ae:	83 c4 10             	add    $0x10,%esp
801029b1:	85 c0                	test   %eax,%eax
801029b3:	75 0d                	jne    801029c2 <iderw+0x29>
    panic("iderw: buf not locked");
801029b5:	83 ec 0c             	sub    $0xc,%esp
801029b8:	68 82 89 10 80       	push   $0x80108982
801029bd:	e8 f3 db ff ff       	call   801005b5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029c2:	8b 45 08             	mov    0x8(%ebp),%eax
801029c5:	8b 00                	mov    (%eax),%eax
801029c7:	83 e0 06             	and    $0x6,%eax
801029ca:	83 f8 02             	cmp    $0x2,%eax
801029cd:	75 0d                	jne    801029dc <iderw+0x43>
    panic("iderw: nothing to do");
801029cf:	83 ec 0c             	sub    $0xc,%esp
801029d2:	68 98 89 10 80       	push   $0x80108998
801029d7:	e8 d9 db ff ff       	call   801005b5 <panic>
  if(b->dev != 0 && !havedisk1)
801029dc:	8b 45 08             	mov    0x8(%ebp),%eax
801029df:	8b 40 04             	mov    0x4(%eax),%eax
801029e2:	85 c0                	test   %eax,%eax
801029e4:	74 16                	je     801029fc <iderw+0x63>
801029e6:	a1 78 26 11 80       	mov    0x80112678,%eax
801029eb:	85 c0                	test   %eax,%eax
801029ed:	75 0d                	jne    801029fc <iderw+0x63>
    panic("iderw: ide disk 1 not present");
801029ef:	83 ec 0c             	sub    $0xc,%esp
801029f2:	68 ad 89 10 80       	push   $0x801089ad
801029f7:	e8 b9 db ff ff       	call   801005b5 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029fc:	83 ec 0c             	sub    $0xc,%esp
801029ff:	68 40 26 11 80       	push   $0x80112640
80102a04:	e8 34 29 00 00       	call   8010533d <acquire>
80102a09:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a0f:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a16:	c7 45 f4 74 26 11 80 	movl   $0x80112674,-0xc(%ebp)
80102a1d:	eb 0b                	jmp    80102a2a <iderw+0x91>
80102a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a22:	8b 00                	mov    (%eax),%eax
80102a24:	83 c0 58             	add    $0x58,%eax
80102a27:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a2d:	8b 00                	mov    (%eax),%eax
80102a2f:	85 c0                	test   %eax,%eax
80102a31:	75 ec                	jne    80102a1f <iderw+0x86>
    ;
  *pp = b;
80102a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a36:	8b 55 08             	mov    0x8(%ebp),%edx
80102a39:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102a3b:	a1 74 26 11 80       	mov    0x80112674,%eax
80102a40:	39 45 08             	cmp    %eax,0x8(%ebp)
80102a43:	75 23                	jne    80102a68 <iderw+0xcf>
    idestart(b);
80102a45:	83 ec 0c             	sub    $0xc,%esp
80102a48:	ff 75 08             	push   0x8(%ebp)
80102a4b:	e8 e2 fc ff ff       	call   80102732 <idestart>
80102a50:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a53:	eb 13                	jmp    80102a68 <iderw+0xcf>
    sleep(b, &idelock);
80102a55:	83 ec 08             	sub    $0x8,%esp
80102a58:	68 40 26 11 80       	push   $0x80112640
80102a5d:	ff 75 08             	push   0x8(%ebp)
80102a60:	e8 6a 24 00 00       	call   80104ecf <sleep>
80102a65:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a68:	8b 45 08             	mov    0x8(%ebp),%eax
80102a6b:	8b 00                	mov    (%eax),%eax
80102a6d:	83 e0 06             	and    $0x6,%eax
80102a70:	83 f8 02             	cmp    $0x2,%eax
80102a73:	75 e0                	jne    80102a55 <iderw+0xbc>
  }


  release(&idelock);
80102a75:	83 ec 0c             	sub    $0xc,%esp
80102a78:	68 40 26 11 80       	push   $0x80112640
80102a7d:	e8 29 29 00 00       	call   801053ab <release>
80102a82:	83 c4 10             	add    $0x10,%esp
}
80102a85:	90                   	nop
80102a86:	c9                   	leave  
80102a87:	c3                   	ret    

80102a88 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a88:	55                   	push   %ebp
80102a89:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a8b:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102a90:	8b 55 08             	mov    0x8(%ebp),%edx
80102a93:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a95:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102a9a:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a9d:	5d                   	pop    %ebp
80102a9e:	c3                   	ret    

80102a9f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a9f:	55                   	push   %ebp
80102aa0:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102aa2:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102aa7:	8b 55 08             	mov    0x8(%ebp),%edx
80102aaa:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102aac:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102ab1:	8b 55 0c             	mov    0xc(%ebp),%edx
80102ab4:	89 50 10             	mov    %edx,0x10(%eax)
}
80102ab7:	90                   	nop
80102ab8:	5d                   	pop    %ebp
80102ab9:	c3                   	ret    

80102aba <ioapicinit>:

void
ioapicinit(void)
{
80102aba:	55                   	push   %ebp
80102abb:	89 e5                	mov    %esp,%ebp
80102abd:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102ac0:	c7 05 7c 26 11 80 00 	movl   $0xfec00000,0x8011267c
80102ac7:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102aca:	6a 01                	push   $0x1
80102acc:	e8 b7 ff ff ff       	call   80102a88 <ioapicread>
80102ad1:	83 c4 04             	add    $0x4,%esp
80102ad4:	c1 e8 10             	shr    $0x10,%eax
80102ad7:	25 ff 00 00 00       	and    $0xff,%eax
80102adc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102adf:	6a 00                	push   $0x0
80102ae1:	e8 a2 ff ff ff       	call   80102a88 <ioapicread>
80102ae6:	83 c4 04             	add    $0x4,%esp
80102ae9:	c1 e8 18             	shr    $0x18,%eax
80102aec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102aef:	0f b6 05 44 2d 11 80 	movzbl 0x80112d44,%eax
80102af6:	0f b6 c0             	movzbl %al,%eax
80102af9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102afc:	74 10                	je     80102b0e <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102afe:	83 ec 0c             	sub    $0xc,%esp
80102b01:	68 cc 89 10 80       	push   $0x801089cc
80102b06:	e8 f5 d8 ff ff       	call   80100400 <cprintf>
80102b0b:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102b15:	eb 3f                	jmp    80102b56 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b1a:	83 c0 20             	add    $0x20,%eax
80102b1d:	0d 00 00 01 00       	or     $0x10000,%eax
80102b22:	89 c2                	mov    %eax,%edx
80102b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b27:	83 c0 08             	add    $0x8,%eax
80102b2a:	01 c0                	add    %eax,%eax
80102b2c:	83 ec 08             	sub    $0x8,%esp
80102b2f:	52                   	push   %edx
80102b30:	50                   	push   %eax
80102b31:	e8 69 ff ff ff       	call   80102a9f <ioapicwrite>
80102b36:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b3c:	83 c0 08             	add    $0x8,%eax
80102b3f:	01 c0                	add    %eax,%eax
80102b41:	83 c0 01             	add    $0x1,%eax
80102b44:	83 ec 08             	sub    $0x8,%esp
80102b47:	6a 00                	push   $0x0
80102b49:	50                   	push   %eax
80102b4a:	e8 50 ff ff ff       	call   80102a9f <ioapicwrite>
80102b4f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102b52:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b59:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b5c:	7e b9                	jle    80102b17 <ioapicinit+0x5d>
  }
}
80102b5e:	90                   	nop
80102b5f:	90                   	nop
80102b60:	c9                   	leave  
80102b61:	c3                   	ret    

80102b62 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b62:	55                   	push   %ebp
80102b63:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b65:	8b 45 08             	mov    0x8(%ebp),%eax
80102b68:	83 c0 20             	add    $0x20,%eax
80102b6b:	89 c2                	mov    %eax,%edx
80102b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b70:	83 c0 08             	add    $0x8,%eax
80102b73:	01 c0                	add    %eax,%eax
80102b75:	52                   	push   %edx
80102b76:	50                   	push   %eax
80102b77:	e8 23 ff ff ff       	call   80102a9f <ioapicwrite>
80102b7c:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b82:	c1 e0 18             	shl    $0x18,%eax
80102b85:	89 c2                	mov    %eax,%edx
80102b87:	8b 45 08             	mov    0x8(%ebp),%eax
80102b8a:	83 c0 08             	add    $0x8,%eax
80102b8d:	01 c0                	add    %eax,%eax
80102b8f:	83 c0 01             	add    $0x1,%eax
80102b92:	52                   	push   %edx
80102b93:	50                   	push   %eax
80102b94:	e8 06 ff ff ff       	call   80102a9f <ioapicwrite>
80102b99:	83 c4 08             	add    $0x8,%esp
}
80102b9c:	90                   	nop
80102b9d:	c9                   	leave  
80102b9e:	c3                   	ret    

80102b9f <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b9f:	55                   	push   %ebp
80102ba0:	89 e5                	mov    %esp,%ebp
80102ba2:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102ba5:	83 ec 08             	sub    $0x8,%esp
80102ba8:	68 fe 89 10 80       	push   $0x801089fe
80102bad:	68 80 26 11 80       	push   $0x80112680
80102bb2:	e8 64 27 00 00       	call   8010531b <initlock>
80102bb7:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102bba:	c7 05 b4 26 11 80 00 	movl   $0x0,0x801126b4
80102bc1:	00 00 00 
  freerange(vstart, vend);
80102bc4:	83 ec 08             	sub    $0x8,%esp
80102bc7:	ff 75 0c             	push   0xc(%ebp)
80102bca:	ff 75 08             	push   0x8(%ebp)
80102bcd:	e8 2a 00 00 00       	call   80102bfc <freerange>
80102bd2:	83 c4 10             	add    $0x10,%esp
}
80102bd5:	90                   	nop
80102bd6:	c9                   	leave  
80102bd7:	c3                   	ret    

80102bd8 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102bd8:	55                   	push   %ebp
80102bd9:	89 e5                	mov    %esp,%ebp
80102bdb:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102bde:	83 ec 08             	sub    $0x8,%esp
80102be1:	ff 75 0c             	push   0xc(%ebp)
80102be4:	ff 75 08             	push   0x8(%ebp)
80102be7:	e8 10 00 00 00       	call   80102bfc <freerange>
80102bec:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102bef:	c7 05 b4 26 11 80 01 	movl   $0x1,0x801126b4
80102bf6:	00 00 00 
}
80102bf9:	90                   	nop
80102bfa:	c9                   	leave  
80102bfb:	c3                   	ret    

80102bfc <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bfc:	55                   	push   %ebp
80102bfd:	89 e5                	mov    %esp,%ebp
80102bff:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102c02:	8b 45 08             	mov    0x8(%ebp),%eax
80102c05:	05 ff 0f 00 00       	add    $0xfff,%eax
80102c0a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102c0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c12:	eb 15                	jmp    80102c29 <freerange+0x2d>
    kfree(p);
80102c14:	83 ec 0c             	sub    $0xc,%esp
80102c17:	ff 75 f4             	push   -0xc(%ebp)
80102c1a:	e8 1b 00 00 00       	call   80102c3a <kfree>
80102c1f:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c22:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c2c:	05 00 10 00 00       	add    $0x1000,%eax
80102c31:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102c34:	73 de                	jae    80102c14 <freerange+0x18>
}
80102c36:	90                   	nop
80102c37:	90                   	nop
80102c38:	c9                   	leave  
80102c39:	c3                   	ret    

80102c3a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c3a:	55                   	push   %ebp
80102c3b:	89 e5                	mov    %esp,%ebp
80102c3d:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102c40:	8b 45 08             	mov    0x8(%ebp),%eax
80102c43:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c48:	85 c0                	test   %eax,%eax
80102c4a:	75 18                	jne    80102c64 <kfree+0x2a>
80102c4c:	81 7d 08 e0 69 11 80 	cmpl   $0x801169e0,0x8(%ebp)
80102c53:	72 0f                	jb     80102c64 <kfree+0x2a>
80102c55:	8b 45 08             	mov    0x8(%ebp),%eax
80102c58:	05 00 00 00 80       	add    $0x80000000,%eax
80102c5d:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c62:	76 0d                	jbe    80102c71 <kfree+0x37>
    panic("kfree");
80102c64:	83 ec 0c             	sub    $0xc,%esp
80102c67:	68 03 8a 10 80       	push   $0x80108a03
80102c6c:	e8 44 d9 ff ff       	call   801005b5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c71:	83 ec 04             	sub    $0x4,%esp
80102c74:	68 00 10 00 00       	push   $0x1000
80102c79:	6a 01                	push   $0x1
80102c7b:	ff 75 08             	push   0x8(%ebp)
80102c7e:	e8 40 29 00 00       	call   801055c3 <memset>
80102c83:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c86:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102c8b:	85 c0                	test   %eax,%eax
80102c8d:	74 10                	je     80102c9f <kfree+0x65>
    acquire(&kmem.lock);
80102c8f:	83 ec 0c             	sub    $0xc,%esp
80102c92:	68 80 26 11 80       	push   $0x80112680
80102c97:	e8 a1 26 00 00       	call   8010533d <acquire>
80102c9c:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c9f:	8b 45 08             	mov    0x8(%ebp),%eax
80102ca2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ca5:	8b 15 b8 26 11 80    	mov    0x801126b8,%edx
80102cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cae:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb3:	a3 b8 26 11 80       	mov    %eax,0x801126b8
  if(kmem.use_lock)
80102cb8:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102cbd:	85 c0                	test   %eax,%eax
80102cbf:	74 10                	je     80102cd1 <kfree+0x97>
    release(&kmem.lock);
80102cc1:	83 ec 0c             	sub    $0xc,%esp
80102cc4:	68 80 26 11 80       	push   $0x80112680
80102cc9:	e8 dd 26 00 00       	call   801053ab <release>
80102cce:	83 c4 10             	add    $0x10,%esp
}
80102cd1:	90                   	nop
80102cd2:	c9                   	leave  
80102cd3:	c3                   	ret    

80102cd4 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102cd4:	55                   	push   %ebp
80102cd5:	89 e5                	mov    %esp,%ebp
80102cd7:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102cda:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102cdf:	85 c0                	test   %eax,%eax
80102ce1:	74 10                	je     80102cf3 <kalloc+0x1f>
    acquire(&kmem.lock);
80102ce3:	83 ec 0c             	sub    $0xc,%esp
80102ce6:	68 80 26 11 80       	push   $0x80112680
80102ceb:	e8 4d 26 00 00       	call   8010533d <acquire>
80102cf0:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102cf3:	a1 b8 26 11 80       	mov    0x801126b8,%eax
80102cf8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cfb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cff:	74 0a                	je     80102d0b <kalloc+0x37>
    kmem.freelist = r->next;
80102d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d04:	8b 00                	mov    (%eax),%eax
80102d06:	a3 b8 26 11 80       	mov    %eax,0x801126b8
  if(kmem.use_lock)
80102d0b:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102d10:	85 c0                	test   %eax,%eax
80102d12:	74 10                	je     80102d24 <kalloc+0x50>
    release(&kmem.lock);
80102d14:	83 ec 0c             	sub    $0xc,%esp
80102d17:	68 80 26 11 80       	push   $0x80112680
80102d1c:	e8 8a 26 00 00       	call   801053ab <release>
80102d21:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d27:	c9                   	leave  
80102d28:	c3                   	ret    

80102d29 <inb>:
{
80102d29:	55                   	push   %ebp
80102d2a:	89 e5                	mov    %esp,%ebp
80102d2c:	83 ec 14             	sub    $0x14,%esp
80102d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80102d32:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d36:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d3a:	89 c2                	mov    %eax,%edx
80102d3c:	ec                   	in     (%dx),%al
80102d3d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d40:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d44:	c9                   	leave  
80102d45:	c3                   	ret    

80102d46 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d46:	55                   	push   %ebp
80102d47:	89 e5                	mov    %esp,%ebp
80102d49:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d4c:	6a 64                	push   $0x64
80102d4e:	e8 d6 ff ff ff       	call   80102d29 <inb>
80102d53:	83 c4 04             	add    $0x4,%esp
80102d56:	0f b6 c0             	movzbl %al,%eax
80102d59:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d5f:	83 e0 01             	and    $0x1,%eax
80102d62:	85 c0                	test   %eax,%eax
80102d64:	75 0a                	jne    80102d70 <kbdgetc+0x2a>
    return -1;
80102d66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d6b:	e9 23 01 00 00       	jmp    80102e93 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d70:	6a 60                	push   $0x60
80102d72:	e8 b2 ff ff ff       	call   80102d29 <inb>
80102d77:	83 c4 04             	add    $0x4,%esp
80102d7a:	0f b6 c0             	movzbl %al,%eax
80102d7d:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d80:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d87:	75 17                	jne    80102da0 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d89:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102d8e:	83 c8 40             	or     $0x40,%eax
80102d91:	a3 bc 26 11 80       	mov    %eax,0x801126bc
    return 0;
80102d96:	b8 00 00 00 00       	mov    $0x0,%eax
80102d9b:	e9 f3 00 00 00       	jmp    80102e93 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102da0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102da3:	25 80 00 00 00       	and    $0x80,%eax
80102da8:	85 c0                	test   %eax,%eax
80102daa:	74 45                	je     80102df1 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102dac:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102db1:	83 e0 40             	and    $0x40,%eax
80102db4:	85 c0                	test   %eax,%eax
80102db6:	75 08                	jne    80102dc0 <kbdgetc+0x7a>
80102db8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dbb:	83 e0 7f             	and    $0x7f,%eax
80102dbe:	eb 03                	jmp    80102dc3 <kbdgetc+0x7d>
80102dc0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102dc6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc9:	05 20 90 10 80       	add    $0x80109020,%eax
80102dce:	0f b6 00             	movzbl (%eax),%eax
80102dd1:	83 c8 40             	or     $0x40,%eax
80102dd4:	0f b6 c0             	movzbl %al,%eax
80102dd7:	f7 d0                	not    %eax
80102dd9:	89 c2                	mov    %eax,%edx
80102ddb:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102de0:	21 d0                	and    %edx,%eax
80102de2:	a3 bc 26 11 80       	mov    %eax,0x801126bc
    return 0;
80102de7:	b8 00 00 00 00       	mov    $0x0,%eax
80102dec:	e9 a2 00 00 00       	jmp    80102e93 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102df1:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102df6:	83 e0 40             	and    $0x40,%eax
80102df9:	85 c0                	test   %eax,%eax
80102dfb:	74 14                	je     80102e11 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102dfd:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102e04:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102e09:	83 e0 bf             	and    $0xffffffbf,%eax
80102e0c:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  }

  shift |= shiftcode[data];
80102e11:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e14:	05 20 90 10 80       	add    $0x80109020,%eax
80102e19:	0f b6 00             	movzbl (%eax),%eax
80102e1c:	0f b6 d0             	movzbl %al,%edx
80102e1f:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102e24:	09 d0                	or     %edx,%eax
80102e26:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  shift ^= togglecode[data];
80102e2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e2e:	05 20 91 10 80       	add    $0x80109120,%eax
80102e33:	0f b6 00             	movzbl (%eax),%eax
80102e36:	0f b6 d0             	movzbl %al,%edx
80102e39:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102e3e:	31 d0                	xor    %edx,%eax
80102e40:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  c = charcode[shift & (CTL | SHIFT)][data];
80102e45:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102e4a:	83 e0 03             	and    $0x3,%eax
80102e4d:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102e54:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e57:	01 d0                	add    %edx,%eax
80102e59:	0f b6 00             	movzbl (%eax),%eax
80102e5c:	0f b6 c0             	movzbl %al,%eax
80102e5f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e62:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102e67:	83 e0 08             	and    $0x8,%eax
80102e6a:	85 c0                	test   %eax,%eax
80102e6c:	74 22                	je     80102e90 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e6e:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e72:	76 0c                	jbe    80102e80 <kbdgetc+0x13a>
80102e74:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e78:	77 06                	ja     80102e80 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e7a:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e7e:	eb 10                	jmp    80102e90 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e80:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e84:	76 0a                	jbe    80102e90 <kbdgetc+0x14a>
80102e86:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e8a:	77 04                	ja     80102e90 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e8c:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e90:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e93:	c9                   	leave  
80102e94:	c3                   	ret    

80102e95 <kbdintr>:

void
kbdintr(void)
{
80102e95:	55                   	push   %ebp
80102e96:	89 e5                	mov    %esp,%ebp
80102e98:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e9b:	83 ec 0c             	sub    $0xc,%esp
80102e9e:	68 46 2d 10 80       	push   $0x80102d46
80102ea3:	e8 a7 d9 ff ff       	call   8010084f <consoleintr>
80102ea8:	83 c4 10             	add    $0x10,%esp
}
80102eab:	90                   	nop
80102eac:	c9                   	leave  
80102ead:	c3                   	ret    

80102eae <inb>:
{
80102eae:	55                   	push   %ebp
80102eaf:	89 e5                	mov    %esp,%ebp
80102eb1:	83 ec 14             	sub    $0x14,%esp
80102eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80102eb7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ebb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ebf:	89 c2                	mov    %eax,%edx
80102ec1:	ec                   	in     (%dx),%al
80102ec2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ec5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102ec9:	c9                   	leave  
80102eca:	c3                   	ret    

80102ecb <outb>:
{
80102ecb:	55                   	push   %ebp
80102ecc:	89 e5                	mov    %esp,%ebp
80102ece:	83 ec 08             	sub    $0x8,%esp
80102ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ed4:	8b 55 0c             	mov    0xc(%ebp),%edx
80102ed7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102edb:	89 d0                	mov    %edx,%eax
80102edd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ee0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102ee4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ee8:	ee                   	out    %al,(%dx)
}
80102ee9:	90                   	nop
80102eea:	c9                   	leave  
80102eeb:	c3                   	ret    

80102eec <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102eec:	55                   	push   %ebp
80102eed:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102eef:	8b 15 c0 26 11 80    	mov    0x801126c0,%edx
80102ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80102ef8:	c1 e0 02             	shl    $0x2,%eax
80102efb:	01 c2                	add    %eax,%edx
80102efd:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f00:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102f02:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80102f07:	83 c0 20             	add    $0x20,%eax
80102f0a:	8b 00                	mov    (%eax),%eax
}
80102f0c:	90                   	nop
80102f0d:	5d                   	pop    %ebp
80102f0e:	c3                   	ret    

80102f0f <lapicinit>:

void
lapicinit(void)
{
80102f0f:	55                   	push   %ebp
80102f10:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102f12:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80102f17:	85 c0                	test   %eax,%eax
80102f19:	0f 84 0c 01 00 00    	je     8010302b <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102f1f:	68 3f 01 00 00       	push   $0x13f
80102f24:	6a 3c                	push   $0x3c
80102f26:	e8 c1 ff ff ff       	call   80102eec <lapicw>
80102f2b:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102f2e:	6a 0b                	push   $0xb
80102f30:	68 f8 00 00 00       	push   $0xf8
80102f35:	e8 b2 ff ff ff       	call   80102eec <lapicw>
80102f3a:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f3d:	68 20 00 02 00       	push   $0x20020
80102f42:	68 c8 00 00 00       	push   $0xc8
80102f47:	e8 a0 ff ff ff       	call   80102eec <lapicw>
80102f4c:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102f4f:	68 80 96 98 00       	push   $0x989680
80102f54:	68 e0 00 00 00       	push   $0xe0
80102f59:	e8 8e ff ff ff       	call   80102eec <lapicw>
80102f5e:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f61:	68 00 00 01 00       	push   $0x10000
80102f66:	68 d4 00 00 00       	push   $0xd4
80102f6b:	e8 7c ff ff ff       	call   80102eec <lapicw>
80102f70:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f73:	68 00 00 01 00       	push   $0x10000
80102f78:	68 d8 00 00 00       	push   $0xd8
80102f7d:	e8 6a ff ff ff       	call   80102eec <lapicw>
80102f82:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f85:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80102f8a:	83 c0 30             	add    $0x30,%eax
80102f8d:	8b 00                	mov    (%eax),%eax
80102f8f:	c1 e8 10             	shr    $0x10,%eax
80102f92:	25 fc 00 00 00       	and    $0xfc,%eax
80102f97:	85 c0                	test   %eax,%eax
80102f99:	74 12                	je     80102fad <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102f9b:	68 00 00 01 00       	push   $0x10000
80102fa0:	68 d0 00 00 00       	push   $0xd0
80102fa5:	e8 42 ff ff ff       	call   80102eec <lapicw>
80102faa:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102fad:	6a 33                	push   $0x33
80102faf:	68 dc 00 00 00       	push   $0xdc
80102fb4:	e8 33 ff ff ff       	call   80102eec <lapicw>
80102fb9:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102fbc:	6a 00                	push   $0x0
80102fbe:	68 a0 00 00 00       	push   $0xa0
80102fc3:	e8 24 ff ff ff       	call   80102eec <lapicw>
80102fc8:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102fcb:	6a 00                	push   $0x0
80102fcd:	68 a0 00 00 00       	push   $0xa0
80102fd2:	e8 15 ff ff ff       	call   80102eec <lapicw>
80102fd7:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102fda:	6a 00                	push   $0x0
80102fdc:	6a 2c                	push   $0x2c
80102fde:	e8 09 ff ff ff       	call   80102eec <lapicw>
80102fe3:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102fe6:	6a 00                	push   $0x0
80102fe8:	68 c4 00 00 00       	push   $0xc4
80102fed:	e8 fa fe ff ff       	call   80102eec <lapicw>
80102ff2:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ff5:	68 00 85 08 00       	push   $0x88500
80102ffa:	68 c0 00 00 00       	push   $0xc0
80102fff:	e8 e8 fe ff ff       	call   80102eec <lapicw>
80103004:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80103007:	90                   	nop
80103008:	a1 c0 26 11 80       	mov    0x801126c0,%eax
8010300d:	05 00 03 00 00       	add    $0x300,%eax
80103012:	8b 00                	mov    (%eax),%eax
80103014:	25 00 10 00 00       	and    $0x1000,%eax
80103019:	85 c0                	test   %eax,%eax
8010301b:	75 eb                	jne    80103008 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010301d:	6a 00                	push   $0x0
8010301f:	6a 20                	push   $0x20
80103021:	e8 c6 fe ff ff       	call   80102eec <lapicw>
80103026:	83 c4 08             	add    $0x8,%esp
80103029:	eb 01                	jmp    8010302c <lapicinit+0x11d>
    return;
8010302b:	90                   	nop
}
8010302c:	c9                   	leave  
8010302d:	c3                   	ret    

8010302e <lapicid>:

int
lapicid(void)
{
8010302e:	55                   	push   %ebp
8010302f:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103031:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80103036:	85 c0                	test   %eax,%eax
80103038:	75 07                	jne    80103041 <lapicid+0x13>
    return 0;
8010303a:	b8 00 00 00 00       	mov    $0x0,%eax
8010303f:	eb 0d                	jmp    8010304e <lapicid+0x20>
  return lapic[ID] >> 24;
80103041:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80103046:	83 c0 20             	add    $0x20,%eax
80103049:	8b 00                	mov    (%eax),%eax
8010304b:	c1 e8 18             	shr    $0x18,%eax
}
8010304e:	5d                   	pop    %ebp
8010304f:	c3                   	ret    

80103050 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103050:	55                   	push   %ebp
80103051:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103053:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80103058:	85 c0                	test   %eax,%eax
8010305a:	74 0c                	je     80103068 <lapiceoi+0x18>
    lapicw(EOI, 0);
8010305c:	6a 00                	push   $0x0
8010305e:	6a 2c                	push   $0x2c
80103060:	e8 87 fe ff ff       	call   80102eec <lapicw>
80103065:	83 c4 08             	add    $0x8,%esp
}
80103068:	90                   	nop
80103069:	c9                   	leave  
8010306a:	c3                   	ret    

8010306b <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010306b:	55                   	push   %ebp
8010306c:	89 e5                	mov    %esp,%ebp
}
8010306e:	90                   	nop
8010306f:	5d                   	pop    %ebp
80103070:	c3                   	ret    

80103071 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103071:	55                   	push   %ebp
80103072:	89 e5                	mov    %esp,%ebp
80103074:	83 ec 14             	sub    $0x14,%esp
80103077:	8b 45 08             	mov    0x8(%ebp),%eax
8010307a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010307d:	6a 0f                	push   $0xf
8010307f:	6a 70                	push   $0x70
80103081:	e8 45 fe ff ff       	call   80102ecb <outb>
80103086:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103089:	6a 0a                	push   $0xa
8010308b:	6a 71                	push   $0x71
8010308d:	e8 39 fe ff ff       	call   80102ecb <outb>
80103092:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103095:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010309c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010309f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801030a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801030a7:	c1 e8 04             	shr    $0x4,%eax
801030aa:	89 c2                	mov    %eax,%edx
801030ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030af:	83 c0 02             	add    $0x2,%eax
801030b2:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801030b5:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030b9:	c1 e0 18             	shl    $0x18,%eax
801030bc:	50                   	push   %eax
801030bd:	68 c4 00 00 00       	push   $0xc4
801030c2:	e8 25 fe ff ff       	call   80102eec <lapicw>
801030c7:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801030ca:	68 00 c5 00 00       	push   $0xc500
801030cf:	68 c0 00 00 00       	push   $0xc0
801030d4:	e8 13 fe ff ff       	call   80102eec <lapicw>
801030d9:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030dc:	68 c8 00 00 00       	push   $0xc8
801030e1:	e8 85 ff ff ff       	call   8010306b <microdelay>
801030e6:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030e9:	68 00 85 00 00       	push   $0x8500
801030ee:	68 c0 00 00 00       	push   $0xc0
801030f3:	e8 f4 fd ff ff       	call   80102eec <lapicw>
801030f8:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030fb:	6a 64                	push   $0x64
801030fd:	e8 69 ff ff ff       	call   8010306b <microdelay>
80103102:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103105:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010310c:	eb 3d                	jmp    8010314b <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
8010310e:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103112:	c1 e0 18             	shl    $0x18,%eax
80103115:	50                   	push   %eax
80103116:	68 c4 00 00 00       	push   $0xc4
8010311b:	e8 cc fd ff ff       	call   80102eec <lapicw>
80103120:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103123:	8b 45 0c             	mov    0xc(%ebp),%eax
80103126:	c1 e8 0c             	shr    $0xc,%eax
80103129:	80 cc 06             	or     $0x6,%ah
8010312c:	50                   	push   %eax
8010312d:	68 c0 00 00 00       	push   $0xc0
80103132:	e8 b5 fd ff ff       	call   80102eec <lapicw>
80103137:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010313a:	68 c8 00 00 00       	push   $0xc8
8010313f:	e8 27 ff ff ff       	call   8010306b <microdelay>
80103144:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80103147:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010314b:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010314f:	7e bd                	jle    8010310e <lapicstartap+0x9d>
  }
}
80103151:	90                   	nop
80103152:	90                   	nop
80103153:	c9                   	leave  
80103154:	c3                   	ret    

80103155 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
80103155:	55                   	push   %ebp
80103156:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103158:	8b 45 08             	mov    0x8(%ebp),%eax
8010315b:	0f b6 c0             	movzbl %al,%eax
8010315e:	50                   	push   %eax
8010315f:	6a 70                	push   $0x70
80103161:	e8 65 fd ff ff       	call   80102ecb <outb>
80103166:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103169:	68 c8 00 00 00       	push   $0xc8
8010316e:	e8 f8 fe ff ff       	call   8010306b <microdelay>
80103173:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103176:	6a 71                	push   $0x71
80103178:	e8 31 fd ff ff       	call   80102eae <inb>
8010317d:	83 c4 04             	add    $0x4,%esp
80103180:	0f b6 c0             	movzbl %al,%eax
}
80103183:	c9                   	leave  
80103184:	c3                   	ret    

80103185 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
80103185:	55                   	push   %ebp
80103186:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103188:	6a 00                	push   $0x0
8010318a:	e8 c6 ff ff ff       	call   80103155 <cmos_read>
8010318f:	83 c4 04             	add    $0x4,%esp
80103192:	8b 55 08             	mov    0x8(%ebp),%edx
80103195:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103197:	6a 02                	push   $0x2
80103199:	e8 b7 ff ff ff       	call   80103155 <cmos_read>
8010319e:	83 c4 04             	add    $0x4,%esp
801031a1:	8b 55 08             	mov    0x8(%ebp),%edx
801031a4:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801031a7:	6a 04                	push   $0x4
801031a9:	e8 a7 ff ff ff       	call   80103155 <cmos_read>
801031ae:	83 c4 04             	add    $0x4,%esp
801031b1:	8b 55 08             	mov    0x8(%ebp),%edx
801031b4:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801031b7:	6a 07                	push   $0x7
801031b9:	e8 97 ff ff ff       	call   80103155 <cmos_read>
801031be:	83 c4 04             	add    $0x4,%esp
801031c1:	8b 55 08             	mov    0x8(%ebp),%edx
801031c4:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801031c7:	6a 08                	push   $0x8
801031c9:	e8 87 ff ff ff       	call   80103155 <cmos_read>
801031ce:	83 c4 04             	add    $0x4,%esp
801031d1:	8b 55 08             	mov    0x8(%ebp),%edx
801031d4:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801031d7:	6a 09                	push   $0x9
801031d9:	e8 77 ff ff ff       	call   80103155 <cmos_read>
801031de:	83 c4 04             	add    $0x4,%esp
801031e1:	8b 55 08             	mov    0x8(%ebp),%edx
801031e4:	89 42 14             	mov    %eax,0x14(%edx)
}
801031e7:	90                   	nop
801031e8:	c9                   	leave  
801031e9:	c3                   	ret    

801031ea <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801031ea:	55                   	push   %ebp
801031eb:	89 e5                	mov    %esp,%ebp
801031ed:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031f0:	6a 0b                	push   $0xb
801031f2:	e8 5e ff ff ff       	call   80103155 <cmos_read>
801031f7:	83 c4 04             	add    $0x4,%esp
801031fa:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103200:	83 e0 04             	and    $0x4,%eax
80103203:	85 c0                	test   %eax,%eax
80103205:	0f 94 c0             	sete   %al
80103208:	0f b6 c0             	movzbl %al,%eax
8010320b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010320e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103211:	50                   	push   %eax
80103212:	e8 6e ff ff ff       	call   80103185 <fill_rtcdate>
80103217:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010321a:	6a 0a                	push   $0xa
8010321c:	e8 34 ff ff ff       	call   80103155 <cmos_read>
80103221:	83 c4 04             	add    $0x4,%esp
80103224:	25 80 00 00 00       	and    $0x80,%eax
80103229:	85 c0                	test   %eax,%eax
8010322b:	75 27                	jne    80103254 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
8010322d:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103230:	50                   	push   %eax
80103231:	e8 4f ff ff ff       	call   80103185 <fill_rtcdate>
80103236:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103239:	83 ec 04             	sub    $0x4,%esp
8010323c:	6a 18                	push   $0x18
8010323e:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103241:	50                   	push   %eax
80103242:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103245:	50                   	push   %eax
80103246:	e8 df 23 00 00       	call   8010562a <memcmp>
8010324b:	83 c4 10             	add    $0x10,%esp
8010324e:	85 c0                	test   %eax,%eax
80103250:	74 05                	je     80103257 <cmostime+0x6d>
80103252:	eb ba                	jmp    8010320e <cmostime+0x24>
        continue;
80103254:	90                   	nop
    fill_rtcdate(&t1);
80103255:	eb b7                	jmp    8010320e <cmostime+0x24>
      break;
80103257:	90                   	nop
  }

  // convert
  if(bcd) {
80103258:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010325c:	0f 84 b4 00 00 00    	je     80103316 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103262:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103265:	c1 e8 04             	shr    $0x4,%eax
80103268:	89 c2                	mov    %eax,%edx
8010326a:	89 d0                	mov    %edx,%eax
8010326c:	c1 e0 02             	shl    $0x2,%eax
8010326f:	01 d0                	add    %edx,%eax
80103271:	01 c0                	add    %eax,%eax
80103273:	89 c2                	mov    %eax,%edx
80103275:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103278:	83 e0 0f             	and    $0xf,%eax
8010327b:	01 d0                	add    %edx,%eax
8010327d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103280:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103283:	c1 e8 04             	shr    $0x4,%eax
80103286:	89 c2                	mov    %eax,%edx
80103288:	89 d0                	mov    %edx,%eax
8010328a:	c1 e0 02             	shl    $0x2,%eax
8010328d:	01 d0                	add    %edx,%eax
8010328f:	01 c0                	add    %eax,%eax
80103291:	89 c2                	mov    %eax,%edx
80103293:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103296:	83 e0 0f             	and    $0xf,%eax
80103299:	01 d0                	add    %edx,%eax
8010329b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010329e:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032a1:	c1 e8 04             	shr    $0x4,%eax
801032a4:	89 c2                	mov    %eax,%edx
801032a6:	89 d0                	mov    %edx,%eax
801032a8:	c1 e0 02             	shl    $0x2,%eax
801032ab:	01 d0                	add    %edx,%eax
801032ad:	01 c0                	add    %eax,%eax
801032af:	89 c2                	mov    %eax,%edx
801032b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032b4:	83 e0 0f             	and    $0xf,%eax
801032b7:	01 d0                	add    %edx,%eax
801032b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801032bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032bf:	c1 e8 04             	shr    $0x4,%eax
801032c2:	89 c2                	mov    %eax,%edx
801032c4:	89 d0                	mov    %edx,%eax
801032c6:	c1 e0 02             	shl    $0x2,%eax
801032c9:	01 d0                	add    %edx,%eax
801032cb:	01 c0                	add    %eax,%eax
801032cd:	89 c2                	mov    %eax,%edx
801032cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032d2:	83 e0 0f             	and    $0xf,%eax
801032d5:	01 d0                	add    %edx,%eax
801032d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801032da:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032dd:	c1 e8 04             	shr    $0x4,%eax
801032e0:	89 c2                	mov    %eax,%edx
801032e2:	89 d0                	mov    %edx,%eax
801032e4:	c1 e0 02             	shl    $0x2,%eax
801032e7:	01 d0                	add    %edx,%eax
801032e9:	01 c0                	add    %eax,%eax
801032eb:	89 c2                	mov    %eax,%edx
801032ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032f0:	83 e0 0f             	and    $0xf,%eax
801032f3:	01 d0                	add    %edx,%eax
801032f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032fb:	c1 e8 04             	shr    $0x4,%eax
801032fe:	89 c2                	mov    %eax,%edx
80103300:	89 d0                	mov    %edx,%eax
80103302:	c1 e0 02             	shl    $0x2,%eax
80103305:	01 d0                	add    %edx,%eax
80103307:	01 c0                	add    %eax,%eax
80103309:	89 c2                	mov    %eax,%edx
8010330b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010330e:	83 e0 0f             	and    $0xf,%eax
80103311:	01 d0                	add    %edx,%eax
80103313:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103316:	8b 45 08             	mov    0x8(%ebp),%eax
80103319:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010331c:	89 10                	mov    %edx,(%eax)
8010331e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103321:	89 50 04             	mov    %edx,0x4(%eax)
80103324:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103327:	89 50 08             	mov    %edx,0x8(%eax)
8010332a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010332d:	89 50 0c             	mov    %edx,0xc(%eax)
80103330:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103333:	89 50 10             	mov    %edx,0x10(%eax)
80103336:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103339:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010333c:	8b 45 08             	mov    0x8(%ebp),%eax
8010333f:	8b 40 14             	mov    0x14(%eax),%eax
80103342:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103348:	8b 45 08             	mov    0x8(%ebp),%eax
8010334b:	89 50 14             	mov    %edx,0x14(%eax)
}
8010334e:	90                   	nop
8010334f:	c9                   	leave  
80103350:	c3                   	ret    

80103351 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103351:	55                   	push   %ebp
80103352:	89 e5                	mov    %esp,%ebp
80103354:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103357:	83 ec 08             	sub    $0x8,%esp
8010335a:	68 09 8a 10 80       	push   $0x80108a09
8010335f:	68 e0 26 11 80       	push   $0x801126e0
80103364:	e8 b2 1f 00 00       	call   8010531b <initlock>
80103369:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010336c:	83 ec 08             	sub    $0x8,%esp
8010336f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103372:	50                   	push   %eax
80103373:	ff 75 08             	push   0x8(%ebp)
80103376:	e8 d4 e0 ff ff       	call   8010144f <readsb>
8010337b:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010337e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103381:	a3 14 27 11 80       	mov    %eax,0x80112714
  log.size = sb.nlog;
80103386:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103389:	a3 18 27 11 80       	mov    %eax,0x80112718
  log.dev = dev;
8010338e:	8b 45 08             	mov    0x8(%ebp),%eax
80103391:	a3 24 27 11 80       	mov    %eax,0x80112724
  recover_from_log();
80103396:	e8 b3 01 00 00       	call   8010354e <recover_from_log>
}
8010339b:	90                   	nop
8010339c:	c9                   	leave  
8010339d:	c3                   	ret    

8010339e <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010339e:	55                   	push   %ebp
8010339f:	89 e5                	mov    %esp,%ebp
801033a1:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033ab:	e9 95 00 00 00       	jmp    80103445 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033b0:	8b 15 14 27 11 80    	mov    0x80112714,%edx
801033b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b9:	01 d0                	add    %edx,%eax
801033bb:	83 c0 01             	add    $0x1,%eax
801033be:	89 c2                	mov    %eax,%edx
801033c0:	a1 24 27 11 80       	mov    0x80112724,%eax
801033c5:	83 ec 08             	sub    $0x8,%esp
801033c8:	52                   	push   %edx
801033c9:	50                   	push   %eax
801033ca:	e8 00 ce ff ff       	call   801001cf <bread>
801033cf:	83 c4 10             	add    $0x10,%esp
801033d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801033d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033d8:	83 c0 10             	add    $0x10,%eax
801033db:	8b 04 85 ec 26 11 80 	mov    -0x7feed914(,%eax,4),%eax
801033e2:	89 c2                	mov    %eax,%edx
801033e4:	a1 24 27 11 80       	mov    0x80112724,%eax
801033e9:	83 ec 08             	sub    $0x8,%esp
801033ec:	52                   	push   %edx
801033ed:	50                   	push   %eax
801033ee:	e8 dc cd ff ff       	call   801001cf <bread>
801033f3:	83 c4 10             	add    $0x10,%esp
801033f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033fc:	8d 50 5c             	lea    0x5c(%eax),%edx
801033ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103402:	83 c0 5c             	add    $0x5c,%eax
80103405:	83 ec 04             	sub    $0x4,%esp
80103408:	68 00 02 00 00       	push   $0x200
8010340d:	52                   	push   %edx
8010340e:	50                   	push   %eax
8010340f:	e8 6e 22 00 00       	call   80105682 <memmove>
80103414:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103417:	83 ec 0c             	sub    $0xc,%esp
8010341a:	ff 75 ec             	push   -0x14(%ebp)
8010341d:	e8 e6 cd ff ff       	call   80100208 <bwrite>
80103422:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80103425:	83 ec 0c             	sub    $0xc,%esp
80103428:	ff 75 f0             	push   -0x10(%ebp)
8010342b:	e8 21 ce ff ff       	call   80100251 <brelse>
80103430:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103433:	83 ec 0c             	sub    $0xc,%esp
80103436:	ff 75 ec             	push   -0x14(%ebp)
80103439:	e8 13 ce ff ff       	call   80100251 <brelse>
8010343e:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103441:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103445:	a1 28 27 11 80       	mov    0x80112728,%eax
8010344a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010344d:	0f 8c 5d ff ff ff    	jl     801033b0 <install_trans+0x12>
  }
}
80103453:	90                   	nop
80103454:	90                   	nop
80103455:	c9                   	leave  
80103456:	c3                   	ret    

80103457 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103457:	55                   	push   %ebp
80103458:	89 e5                	mov    %esp,%ebp
8010345a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010345d:	a1 14 27 11 80       	mov    0x80112714,%eax
80103462:	89 c2                	mov    %eax,%edx
80103464:	a1 24 27 11 80       	mov    0x80112724,%eax
80103469:	83 ec 08             	sub    $0x8,%esp
8010346c:	52                   	push   %edx
8010346d:	50                   	push   %eax
8010346e:	e8 5c cd ff ff       	call   801001cf <bread>
80103473:	83 c4 10             	add    $0x10,%esp
80103476:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103479:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010347c:	83 c0 5c             	add    $0x5c,%eax
8010347f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103482:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103485:	8b 00                	mov    (%eax),%eax
80103487:	a3 28 27 11 80       	mov    %eax,0x80112728
  for (i = 0; i < log.lh.n; i++) {
8010348c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103493:	eb 1b                	jmp    801034b0 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103495:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103498:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010349b:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010349f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034a2:	83 c2 10             	add    $0x10,%edx
801034a5:	89 04 95 ec 26 11 80 	mov    %eax,-0x7feed914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801034ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034b0:	a1 28 27 11 80       	mov    0x80112728,%eax
801034b5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034b8:	7c db                	jl     80103495 <read_head+0x3e>
  }
  brelse(buf);
801034ba:	83 ec 0c             	sub    $0xc,%esp
801034bd:	ff 75 f0             	push   -0x10(%ebp)
801034c0:	e8 8c cd ff ff       	call   80100251 <brelse>
801034c5:	83 c4 10             	add    $0x10,%esp
}
801034c8:	90                   	nop
801034c9:	c9                   	leave  
801034ca:	c3                   	ret    

801034cb <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034cb:	55                   	push   %ebp
801034cc:	89 e5                	mov    %esp,%ebp
801034ce:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034d1:	a1 14 27 11 80       	mov    0x80112714,%eax
801034d6:	89 c2                	mov    %eax,%edx
801034d8:	a1 24 27 11 80       	mov    0x80112724,%eax
801034dd:	83 ec 08             	sub    $0x8,%esp
801034e0:	52                   	push   %edx
801034e1:	50                   	push   %eax
801034e2:	e8 e8 cc ff ff       	call   801001cf <bread>
801034e7:	83 c4 10             	add    $0x10,%esp
801034ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034f0:	83 c0 5c             	add    $0x5c,%eax
801034f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034f6:	8b 15 28 27 11 80    	mov    0x80112728,%edx
801034fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ff:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103501:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103508:	eb 1b                	jmp    80103525 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
8010350a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010350d:	83 c0 10             	add    $0x10,%eax
80103510:	8b 0c 85 ec 26 11 80 	mov    -0x7feed914(,%eax,4),%ecx
80103517:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010351a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010351d:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103521:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103525:	a1 28 27 11 80       	mov    0x80112728,%eax
8010352a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010352d:	7c db                	jl     8010350a <write_head+0x3f>
  }
  bwrite(buf);
8010352f:	83 ec 0c             	sub    $0xc,%esp
80103532:	ff 75 f0             	push   -0x10(%ebp)
80103535:	e8 ce cc ff ff       	call   80100208 <bwrite>
8010353a:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010353d:	83 ec 0c             	sub    $0xc,%esp
80103540:	ff 75 f0             	push   -0x10(%ebp)
80103543:	e8 09 cd ff ff       	call   80100251 <brelse>
80103548:	83 c4 10             	add    $0x10,%esp
}
8010354b:	90                   	nop
8010354c:	c9                   	leave  
8010354d:	c3                   	ret    

8010354e <recover_from_log>:

static void
recover_from_log(void)
{
8010354e:	55                   	push   %ebp
8010354f:	89 e5                	mov    %esp,%ebp
80103551:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103554:	e8 fe fe ff ff       	call   80103457 <read_head>
  install_trans(); // if committed, copy from log to disk
80103559:	e8 40 fe ff ff       	call   8010339e <install_trans>
  log.lh.n = 0;
8010355e:	c7 05 28 27 11 80 00 	movl   $0x0,0x80112728
80103565:	00 00 00 
  write_head(); // clear the log
80103568:	e8 5e ff ff ff       	call   801034cb <write_head>
}
8010356d:	90                   	nop
8010356e:	c9                   	leave  
8010356f:	c3                   	ret    

80103570 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103570:	55                   	push   %ebp
80103571:	89 e5                	mov    %esp,%ebp
80103573:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103576:	83 ec 0c             	sub    $0xc,%esp
80103579:	68 e0 26 11 80       	push   $0x801126e0
8010357e:	e8 ba 1d 00 00       	call   8010533d <acquire>
80103583:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103586:	a1 20 27 11 80       	mov    0x80112720,%eax
8010358b:	85 c0                	test   %eax,%eax
8010358d:	74 17                	je     801035a6 <begin_op+0x36>
      sleep(&log, &log.lock);
8010358f:	83 ec 08             	sub    $0x8,%esp
80103592:	68 e0 26 11 80       	push   $0x801126e0
80103597:	68 e0 26 11 80       	push   $0x801126e0
8010359c:	e8 2e 19 00 00       	call   80104ecf <sleep>
801035a1:	83 c4 10             	add    $0x10,%esp
801035a4:	eb e0                	jmp    80103586 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801035a6:	8b 0d 28 27 11 80    	mov    0x80112728,%ecx
801035ac:	a1 1c 27 11 80       	mov    0x8011271c,%eax
801035b1:	8d 50 01             	lea    0x1(%eax),%edx
801035b4:	89 d0                	mov    %edx,%eax
801035b6:	c1 e0 02             	shl    $0x2,%eax
801035b9:	01 d0                	add    %edx,%eax
801035bb:	01 c0                	add    %eax,%eax
801035bd:	01 c8                	add    %ecx,%eax
801035bf:	83 f8 1e             	cmp    $0x1e,%eax
801035c2:	7e 17                	jle    801035db <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801035c4:	83 ec 08             	sub    $0x8,%esp
801035c7:	68 e0 26 11 80       	push   $0x801126e0
801035cc:	68 e0 26 11 80       	push   $0x801126e0
801035d1:	e8 f9 18 00 00       	call   80104ecf <sleep>
801035d6:	83 c4 10             	add    $0x10,%esp
801035d9:	eb ab                	jmp    80103586 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801035db:	a1 1c 27 11 80       	mov    0x8011271c,%eax
801035e0:	83 c0 01             	add    $0x1,%eax
801035e3:	a3 1c 27 11 80       	mov    %eax,0x8011271c
      release(&log.lock);
801035e8:	83 ec 0c             	sub    $0xc,%esp
801035eb:	68 e0 26 11 80       	push   $0x801126e0
801035f0:	e8 b6 1d 00 00       	call   801053ab <release>
801035f5:	83 c4 10             	add    $0x10,%esp
      break;
801035f8:	90                   	nop
    }
  }
}
801035f9:	90                   	nop
801035fa:	c9                   	leave  
801035fb:	c3                   	ret    

801035fc <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035fc:	55                   	push   %ebp
801035fd:	89 e5                	mov    %esp,%ebp
801035ff:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103602:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103609:	83 ec 0c             	sub    $0xc,%esp
8010360c:	68 e0 26 11 80       	push   $0x801126e0
80103611:	e8 27 1d 00 00       	call   8010533d <acquire>
80103616:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103619:	a1 1c 27 11 80       	mov    0x8011271c,%eax
8010361e:	83 e8 01             	sub    $0x1,%eax
80103621:	a3 1c 27 11 80       	mov    %eax,0x8011271c
  if(log.committing)
80103626:	a1 20 27 11 80       	mov    0x80112720,%eax
8010362b:	85 c0                	test   %eax,%eax
8010362d:	74 0d                	je     8010363c <end_op+0x40>
    panic("log.committing");
8010362f:	83 ec 0c             	sub    $0xc,%esp
80103632:	68 0d 8a 10 80       	push   $0x80108a0d
80103637:	e8 79 cf ff ff       	call   801005b5 <panic>
  if(log.outstanding == 0){
8010363c:	a1 1c 27 11 80       	mov    0x8011271c,%eax
80103641:	85 c0                	test   %eax,%eax
80103643:	75 13                	jne    80103658 <end_op+0x5c>
    do_commit = 1;
80103645:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010364c:	c7 05 20 27 11 80 01 	movl   $0x1,0x80112720
80103653:	00 00 00 
80103656:	eb 10                	jmp    80103668 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103658:	83 ec 0c             	sub    $0xc,%esp
8010365b:	68 e0 26 11 80       	push   $0x801126e0
80103660:	e8 78 19 00 00       	call   80104fdd <wakeup>
80103665:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103668:	83 ec 0c             	sub    $0xc,%esp
8010366b:	68 e0 26 11 80       	push   $0x801126e0
80103670:	e8 36 1d 00 00       	call   801053ab <release>
80103675:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103678:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010367c:	74 3f                	je     801036bd <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010367e:	e8 f6 00 00 00       	call   80103779 <commit>
    acquire(&log.lock);
80103683:	83 ec 0c             	sub    $0xc,%esp
80103686:	68 e0 26 11 80       	push   $0x801126e0
8010368b:	e8 ad 1c 00 00       	call   8010533d <acquire>
80103690:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103693:	c7 05 20 27 11 80 00 	movl   $0x0,0x80112720
8010369a:	00 00 00 
    wakeup(&log);
8010369d:	83 ec 0c             	sub    $0xc,%esp
801036a0:	68 e0 26 11 80       	push   $0x801126e0
801036a5:	e8 33 19 00 00       	call   80104fdd <wakeup>
801036aa:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801036ad:	83 ec 0c             	sub    $0xc,%esp
801036b0:	68 e0 26 11 80       	push   $0x801126e0
801036b5:	e8 f1 1c 00 00       	call   801053ab <release>
801036ba:	83 c4 10             	add    $0x10,%esp
  }
}
801036bd:	90                   	nop
801036be:	c9                   	leave  
801036bf:	c3                   	ret    

801036c0 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801036c0:	55                   	push   %ebp
801036c1:	89 e5                	mov    %esp,%ebp
801036c3:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036cd:	e9 95 00 00 00       	jmp    80103767 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036d2:	8b 15 14 27 11 80    	mov    0x80112714,%edx
801036d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036db:	01 d0                	add    %edx,%eax
801036dd:	83 c0 01             	add    $0x1,%eax
801036e0:	89 c2                	mov    %eax,%edx
801036e2:	a1 24 27 11 80       	mov    0x80112724,%eax
801036e7:	83 ec 08             	sub    $0x8,%esp
801036ea:	52                   	push   %edx
801036eb:	50                   	push   %eax
801036ec:	e8 de ca ff ff       	call   801001cf <bread>
801036f1:	83 c4 10             	add    $0x10,%esp
801036f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036fa:	83 c0 10             	add    $0x10,%eax
801036fd:	8b 04 85 ec 26 11 80 	mov    -0x7feed914(,%eax,4),%eax
80103704:	89 c2                	mov    %eax,%edx
80103706:	a1 24 27 11 80       	mov    0x80112724,%eax
8010370b:	83 ec 08             	sub    $0x8,%esp
8010370e:	52                   	push   %edx
8010370f:	50                   	push   %eax
80103710:	e8 ba ca ff ff       	call   801001cf <bread>
80103715:	83 c4 10             	add    $0x10,%esp
80103718:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010371b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010371e:	8d 50 5c             	lea    0x5c(%eax),%edx
80103721:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103724:	83 c0 5c             	add    $0x5c,%eax
80103727:	83 ec 04             	sub    $0x4,%esp
8010372a:	68 00 02 00 00       	push   $0x200
8010372f:	52                   	push   %edx
80103730:	50                   	push   %eax
80103731:	e8 4c 1f 00 00       	call   80105682 <memmove>
80103736:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103739:	83 ec 0c             	sub    $0xc,%esp
8010373c:	ff 75 f0             	push   -0x10(%ebp)
8010373f:	e8 c4 ca ff ff       	call   80100208 <bwrite>
80103744:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	ff 75 ec             	push   -0x14(%ebp)
8010374d:	e8 ff ca ff ff       	call   80100251 <brelse>
80103752:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103755:	83 ec 0c             	sub    $0xc,%esp
80103758:	ff 75 f0             	push   -0x10(%ebp)
8010375b:	e8 f1 ca ff ff       	call   80100251 <brelse>
80103760:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103763:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103767:	a1 28 27 11 80       	mov    0x80112728,%eax
8010376c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010376f:	0f 8c 5d ff ff ff    	jl     801036d2 <write_log+0x12>
  }
}
80103775:	90                   	nop
80103776:	90                   	nop
80103777:	c9                   	leave  
80103778:	c3                   	ret    

80103779 <commit>:

static void
commit()
{
80103779:	55                   	push   %ebp
8010377a:	89 e5                	mov    %esp,%ebp
8010377c:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010377f:	a1 28 27 11 80       	mov    0x80112728,%eax
80103784:	85 c0                	test   %eax,%eax
80103786:	7e 1e                	jle    801037a6 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103788:	e8 33 ff ff ff       	call   801036c0 <write_log>
    write_head();    // Write header to disk -- the real commit
8010378d:	e8 39 fd ff ff       	call   801034cb <write_head>
    install_trans(); // Now install writes to home locations
80103792:	e8 07 fc ff ff       	call   8010339e <install_trans>
    log.lh.n = 0;
80103797:	c7 05 28 27 11 80 00 	movl   $0x0,0x80112728
8010379e:	00 00 00 
    write_head();    // Erase the transaction from the log
801037a1:	e8 25 fd ff ff       	call   801034cb <write_head>
  }
}
801037a6:	90                   	nop
801037a7:	c9                   	leave  
801037a8:	c3                   	ret    

801037a9 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801037a9:	55                   	push   %ebp
801037aa:	89 e5                	mov    %esp,%ebp
801037ac:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801037af:	a1 28 27 11 80       	mov    0x80112728,%eax
801037b4:	83 f8 1d             	cmp    $0x1d,%eax
801037b7:	7f 12                	jg     801037cb <log_write+0x22>
801037b9:	a1 28 27 11 80       	mov    0x80112728,%eax
801037be:	8b 15 18 27 11 80    	mov    0x80112718,%edx
801037c4:	83 ea 01             	sub    $0x1,%edx
801037c7:	39 d0                	cmp    %edx,%eax
801037c9:	7c 0d                	jl     801037d8 <log_write+0x2f>
    panic("too big a transaction");
801037cb:	83 ec 0c             	sub    $0xc,%esp
801037ce:	68 1c 8a 10 80       	push   $0x80108a1c
801037d3:	e8 dd cd ff ff       	call   801005b5 <panic>
  if (log.outstanding < 1)
801037d8:	a1 1c 27 11 80       	mov    0x8011271c,%eax
801037dd:	85 c0                	test   %eax,%eax
801037df:	7f 0d                	jg     801037ee <log_write+0x45>
    panic("log_write outside of trans");
801037e1:	83 ec 0c             	sub    $0xc,%esp
801037e4:	68 32 8a 10 80       	push   $0x80108a32
801037e9:	e8 c7 cd ff ff       	call   801005b5 <panic>

  acquire(&log.lock);
801037ee:	83 ec 0c             	sub    $0xc,%esp
801037f1:	68 e0 26 11 80       	push   $0x801126e0
801037f6:	e8 42 1b 00 00       	call   8010533d <acquire>
801037fb:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103805:	eb 1d                	jmp    80103824 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103807:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010380a:	83 c0 10             	add    $0x10,%eax
8010380d:	8b 04 85 ec 26 11 80 	mov    -0x7feed914(,%eax,4),%eax
80103814:	89 c2                	mov    %eax,%edx
80103816:	8b 45 08             	mov    0x8(%ebp),%eax
80103819:	8b 40 08             	mov    0x8(%eax),%eax
8010381c:	39 c2                	cmp    %eax,%edx
8010381e:	74 10                	je     80103830 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
80103820:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103824:	a1 28 27 11 80       	mov    0x80112728,%eax
80103829:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010382c:	7c d9                	jl     80103807 <log_write+0x5e>
8010382e:	eb 01                	jmp    80103831 <log_write+0x88>
      break;
80103830:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103831:	8b 45 08             	mov    0x8(%ebp),%eax
80103834:	8b 40 08             	mov    0x8(%eax),%eax
80103837:	89 c2                	mov    %eax,%edx
80103839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383c:	83 c0 10             	add    $0x10,%eax
8010383f:	89 14 85 ec 26 11 80 	mov    %edx,-0x7feed914(,%eax,4)
  if (i == log.lh.n)
80103846:	a1 28 27 11 80       	mov    0x80112728,%eax
8010384b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010384e:	75 0d                	jne    8010385d <log_write+0xb4>
    log.lh.n++;
80103850:	a1 28 27 11 80       	mov    0x80112728,%eax
80103855:	83 c0 01             	add    $0x1,%eax
80103858:	a3 28 27 11 80       	mov    %eax,0x80112728
  b->flags |= B_DIRTY; // prevent eviction
8010385d:	8b 45 08             	mov    0x8(%ebp),%eax
80103860:	8b 00                	mov    (%eax),%eax
80103862:	83 c8 04             	or     $0x4,%eax
80103865:	89 c2                	mov    %eax,%edx
80103867:	8b 45 08             	mov    0x8(%ebp),%eax
8010386a:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010386c:	83 ec 0c             	sub    $0xc,%esp
8010386f:	68 e0 26 11 80       	push   $0x801126e0
80103874:	e8 32 1b 00 00       	call   801053ab <release>
80103879:	83 c4 10             	add    $0x10,%esp
}
8010387c:	90                   	nop
8010387d:	c9                   	leave  
8010387e:	c3                   	ret    

8010387f <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010387f:	55                   	push   %ebp
80103880:	89 e5                	mov    %esp,%ebp
80103882:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103885:	8b 55 08             	mov    0x8(%ebp),%edx
80103888:	8b 45 0c             	mov    0xc(%ebp),%eax
8010388b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010388e:	f0 87 02             	lock xchg %eax,(%edx)
80103891:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103894:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103897:	c9                   	leave  
80103898:	c3                   	ret    

80103899 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103899:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010389d:	83 e4 f0             	and    $0xfffffff0,%esp
801038a0:	ff 71 fc             	push   -0x4(%ecx)
801038a3:	55                   	push   %ebp
801038a4:	89 e5                	mov    %esp,%ebp
801038a6:	51                   	push   %ecx
801038a7:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038aa:	83 ec 08             	sub    $0x8,%esp
801038ad:	68 00 00 40 80       	push   $0x80400000
801038b2:	68 e0 69 11 80       	push   $0x801169e0
801038b7:	e8 e3 f2 ff ff       	call   80102b9f <kinit1>
801038bc:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801038bf:	e8 17 47 00 00       	call   80107fdb <kvmalloc>
  mpinit();        // detect other processors
801038c4:	e8 bd 03 00 00       	call   80103c86 <mpinit>
  lapicinit();     // interrupt controller
801038c9:	e8 41 f6 ff ff       	call   80102f0f <lapicinit>
  seginit();       // segment descriptors
801038ce:	e8 f3 41 00 00       	call   80107ac6 <seginit>
  picinit();       // disable pic
801038d3:	e8 15 05 00 00       	call   80103ded <picinit>
  ioapicinit();    // another interrupt controller
801038d8:	e8 dd f1 ff ff       	call   80102aba <ioapicinit>
  consoleinit();   // console hardware
801038dd:	e8 96 d2 ff ff       	call   80100b78 <consoleinit>
  uartinit();      // serial port
801038e2:	e8 78 35 00 00       	call   80106e5f <uartinit>
  pinit();         // process table
801038e7:	e8 3a 09 00 00       	call   80104226 <pinit>
  tvinit();        // trap vectors
801038ec:	e8 4e 31 00 00       	call   80106a3f <tvinit>
  binit();         // buffer cache
801038f1:	e8 3e c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801038f6:	e8 45 d7 ff ff       	call   80101040 <fileinit>
  ideinit();       // disk 
801038fb:	e8 91 ed ff ff       	call   80102691 <ideinit>
  startothers();   // start other processors
80103900:	e8 80 00 00 00       	call   80103985 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103905:	83 ec 08             	sub    $0x8,%esp
80103908:	68 00 00 00 8e       	push   $0x8e000000
8010390d:	68 00 00 40 80       	push   $0x80400000
80103912:	e8 c1 f2 ff ff       	call   80102bd8 <kinit2>
80103917:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
8010391a:	e8 e8 0a 00 00       	call   80104407 <userinit>
  mpmain();        // finish this processor's setup
8010391f:	e8 1a 00 00 00       	call   8010393e <mpmain>

80103924 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103924:	55                   	push   %ebp
80103925:	89 e5                	mov    %esp,%ebp
80103927:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
8010392a:	e8 c4 46 00 00       	call   80107ff3 <switchkvm>
  seginit();
8010392f:	e8 92 41 00 00       	call   80107ac6 <seginit>
  lapicinit();
80103934:	e8 d6 f5 ff ff       	call   80102f0f <lapicinit>
  mpmain();
80103939:	e8 00 00 00 00       	call   8010393e <mpmain>

8010393e <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010393e:	55                   	push   %ebp
8010393f:	89 e5                	mov    %esp,%ebp
80103941:	53                   	push   %ebx
80103942:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103945:	e8 fa 08 00 00       	call   80104244 <cpuid>
8010394a:	89 c3                	mov    %eax,%ebx
8010394c:	e8 f3 08 00 00       	call   80104244 <cpuid>
80103951:	83 ec 04             	sub    $0x4,%esp
80103954:	53                   	push   %ebx
80103955:	50                   	push   %eax
80103956:	68 4d 8a 10 80       	push   $0x80108a4d
8010395b:	e8 a0 ca ff ff       	call   80100400 <cprintf>
80103960:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103963:	e8 4d 32 00 00       	call   80106bb5 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103968:	e8 f2 08 00 00       	call   8010425f <mycpu>
8010396d:	05 a0 00 00 00       	add    $0xa0,%eax
80103972:	83 ec 08             	sub    $0x8,%esp
80103975:	6a 01                	push   $0x1
80103977:	50                   	push   %eax
80103978:	e8 02 ff ff ff       	call   8010387f <xchg>
8010397d:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103980:	e8 0a 11 00 00       	call   80104a8f <scheduler>

80103985 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103985:	55                   	push   %ebp
80103986:	89 e5                	mov    %esp,%ebp
80103988:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010398b:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103992:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103997:	83 ec 04             	sub    $0x4,%esp
8010399a:	50                   	push   %eax
8010399b:	68 ec b4 10 80       	push   $0x8010b4ec
801039a0:	ff 75 f0             	push   -0x10(%ebp)
801039a3:	e8 da 1c 00 00       	call   80105682 <memmove>
801039a8:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801039ab:	c7 45 f4 c0 27 11 80 	movl   $0x801127c0,-0xc(%ebp)
801039b2:	eb 79                	jmp    80103a2d <startothers+0xa8>
    if(c == mycpu())  // We've started already.
801039b4:	e8 a6 08 00 00       	call   8010425f <mycpu>
801039b9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039bc:	74 67                	je     80103a25 <startothers+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801039be:	e8 11 f3 ff ff       	call   80102cd4 <kalloc>
801039c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801039c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039c9:	83 e8 04             	sub    $0x4,%eax
801039cc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801039cf:	81 c2 00 10 00 00    	add    $0x1000,%edx
801039d5:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
801039d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039da:	83 e8 08             	sub    $0x8,%eax
801039dd:	c7 00 24 39 10 80    	movl   $0x80103924,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801039e3:	b8 00 a0 10 80       	mov    $0x8010a000,%eax
801039e8:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039f1:	83 e8 0c             	sub    $0xc,%eax
801039f4:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801039f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039f9:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a02:	0f b6 00             	movzbl (%eax),%eax
80103a05:	0f b6 c0             	movzbl %al,%eax
80103a08:	83 ec 08             	sub    $0x8,%esp
80103a0b:	52                   	push   %edx
80103a0c:	50                   	push   %eax
80103a0d:	e8 5f f6 ff ff       	call   80103071 <lapicstartap>
80103a12:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a15:	90                   	nop
80103a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a19:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103a1f:	85 c0                	test   %eax,%eax
80103a21:	74 f3                	je     80103a16 <startothers+0x91>
80103a23:	eb 01                	jmp    80103a26 <startothers+0xa1>
      continue;
80103a25:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103a26:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103a2d:	a1 40 2d 11 80       	mov    0x80112d40,%eax
80103a32:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a38:	05 c0 27 11 80       	add    $0x801127c0,%eax
80103a3d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a40:	0f 82 6e ff ff ff    	jb     801039b4 <startothers+0x2f>
      ;
  }
}
80103a46:	90                   	nop
80103a47:	90                   	nop
80103a48:	c9                   	leave  
80103a49:	c3                   	ret    

80103a4a <inb>:
{
80103a4a:	55                   	push   %ebp
80103a4b:	89 e5                	mov    %esp,%ebp
80103a4d:	83 ec 14             	sub    $0x14,%esp
80103a50:	8b 45 08             	mov    0x8(%ebp),%eax
80103a53:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103a57:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103a5b:	89 c2                	mov    %eax,%edx
80103a5d:	ec                   	in     (%dx),%al
80103a5e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103a61:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103a65:	c9                   	leave  
80103a66:	c3                   	ret    

80103a67 <outb>:
{
80103a67:	55                   	push   %ebp
80103a68:	89 e5                	mov    %esp,%ebp
80103a6a:	83 ec 08             	sub    $0x8,%esp
80103a6d:	8b 45 08             	mov    0x8(%ebp),%eax
80103a70:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a73:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103a77:	89 d0                	mov    %edx,%eax
80103a79:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a7c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a80:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a84:	ee                   	out    %al,(%dx)
}
80103a85:	90                   	nop
80103a86:	c9                   	leave  
80103a87:	c3                   	ret    

80103a88 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103a88:	55                   	push   %ebp
80103a89:	89 e5                	mov    %esp,%ebp
80103a8b:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103a8e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a95:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a9c:	eb 15                	jmp    80103ab3 <sum+0x2b>
    sum += addr[i];
80103a9e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103aa1:	8b 45 08             	mov    0x8(%ebp),%eax
80103aa4:	01 d0                	add    %edx,%eax
80103aa6:	0f b6 00             	movzbl (%eax),%eax
80103aa9:	0f b6 c0             	movzbl %al,%eax
80103aac:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103aaf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103ab3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103ab6:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103ab9:	7c e3                	jl     80103a9e <sum+0x16>
  return sum;
80103abb:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103abe:	c9                   	leave  
80103abf:	c3                   	ret    

80103ac0 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103ac0:	55                   	push   %ebp
80103ac1:	89 e5                	mov    %esp,%ebp
80103ac3:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac9:	05 00 00 00 80       	add    $0x80000000,%eax
80103ace:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103ad1:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ad4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ad7:	01 d0                	add    %edx,%eax
80103ad9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103adf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ae2:	eb 36                	jmp    80103b1a <mpsearch1+0x5a>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103ae4:	83 ec 04             	sub    $0x4,%esp
80103ae7:	6a 04                	push   $0x4
80103ae9:	68 64 8a 10 80       	push   $0x80108a64
80103aee:	ff 75 f4             	push   -0xc(%ebp)
80103af1:	e8 34 1b 00 00       	call   8010562a <memcmp>
80103af6:	83 c4 10             	add    $0x10,%esp
80103af9:	85 c0                	test   %eax,%eax
80103afb:	75 19                	jne    80103b16 <mpsearch1+0x56>
80103afd:	83 ec 08             	sub    $0x8,%esp
80103b00:	6a 10                	push   $0x10
80103b02:	ff 75 f4             	push   -0xc(%ebp)
80103b05:	e8 7e ff ff ff       	call   80103a88 <sum>
80103b0a:	83 c4 10             	add    $0x10,%esp
80103b0d:	84 c0                	test   %al,%al
80103b0f:	75 05                	jne    80103b16 <mpsearch1+0x56>
      return (struct mp*)p;
80103b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b14:	eb 11                	jmp    80103b27 <mpsearch1+0x67>
  for(p = addr; p < e; p += sizeof(struct mp))
80103b16:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b1d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b20:	72 c2                	jb     80103ae4 <mpsearch1+0x24>
  return 0;
80103b22:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b27:	c9                   	leave  
80103b28:	c3                   	ret    

80103b29 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b29:	55                   	push   %ebp
80103b2a:	89 e5                	mov    %esp,%ebp
80103b2c:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103b2f:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b39:	83 c0 0f             	add    $0xf,%eax
80103b3c:	0f b6 00             	movzbl (%eax),%eax
80103b3f:	0f b6 c0             	movzbl %al,%eax
80103b42:	c1 e0 08             	shl    $0x8,%eax
80103b45:	89 c2                	mov    %eax,%edx
80103b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4a:	83 c0 0e             	add    $0xe,%eax
80103b4d:	0f b6 00             	movzbl (%eax),%eax
80103b50:	0f b6 c0             	movzbl %al,%eax
80103b53:	09 d0                	or     %edx,%eax
80103b55:	c1 e0 04             	shl    $0x4,%eax
80103b58:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b5b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b5f:	74 21                	je     80103b82 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103b61:	83 ec 08             	sub    $0x8,%esp
80103b64:	68 00 04 00 00       	push   $0x400
80103b69:	ff 75 f0             	push   -0x10(%ebp)
80103b6c:	e8 4f ff ff ff       	call   80103ac0 <mpsearch1>
80103b71:	83 c4 10             	add    $0x10,%esp
80103b74:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b77:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b7b:	74 51                	je     80103bce <mpsearch+0xa5>
      return mp;
80103b7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b80:	eb 61                	jmp    80103be3 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b85:	83 c0 14             	add    $0x14,%eax
80103b88:	0f b6 00             	movzbl (%eax),%eax
80103b8b:	0f b6 c0             	movzbl %al,%eax
80103b8e:	c1 e0 08             	shl    $0x8,%eax
80103b91:	89 c2                	mov    %eax,%edx
80103b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b96:	83 c0 13             	add    $0x13,%eax
80103b99:	0f b6 00             	movzbl (%eax),%eax
80103b9c:	0f b6 c0             	movzbl %al,%eax
80103b9f:	09 d0                	or     %edx,%eax
80103ba1:	c1 e0 0a             	shl    $0xa,%eax
80103ba4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103baa:	2d 00 04 00 00       	sub    $0x400,%eax
80103baf:	83 ec 08             	sub    $0x8,%esp
80103bb2:	68 00 04 00 00       	push   $0x400
80103bb7:	50                   	push   %eax
80103bb8:	e8 03 ff ff ff       	call   80103ac0 <mpsearch1>
80103bbd:	83 c4 10             	add    $0x10,%esp
80103bc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bc3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bc7:	74 05                	je     80103bce <mpsearch+0xa5>
      return mp;
80103bc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bcc:	eb 15                	jmp    80103be3 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103bce:	83 ec 08             	sub    $0x8,%esp
80103bd1:	68 00 00 01 00       	push   $0x10000
80103bd6:	68 00 00 0f 00       	push   $0xf0000
80103bdb:	e8 e0 fe ff ff       	call   80103ac0 <mpsearch1>
80103be0:	83 c4 10             	add    $0x10,%esp
}
80103be3:	c9                   	leave  
80103be4:	c3                   	ret    

80103be5 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103be5:	55                   	push   %ebp
80103be6:	89 e5                	mov    %esp,%ebp
80103be8:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103beb:	e8 39 ff ff ff       	call   80103b29 <mpsearch>
80103bf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bf3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103bf7:	74 0a                	je     80103c03 <mpconfig+0x1e>
80103bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfc:	8b 40 04             	mov    0x4(%eax),%eax
80103bff:	85 c0                	test   %eax,%eax
80103c01:	75 07                	jne    80103c0a <mpconfig+0x25>
    return 0;
80103c03:	b8 00 00 00 00       	mov    $0x0,%eax
80103c08:	eb 7a                	jmp    80103c84 <mpconfig+0x9f>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0d:	8b 40 04             	mov    0x4(%eax),%eax
80103c10:	05 00 00 00 80       	add    $0x80000000,%eax
80103c15:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c18:	83 ec 04             	sub    $0x4,%esp
80103c1b:	6a 04                	push   $0x4
80103c1d:	68 69 8a 10 80       	push   $0x80108a69
80103c22:	ff 75 f0             	push   -0x10(%ebp)
80103c25:	e8 00 1a 00 00       	call   8010562a <memcmp>
80103c2a:	83 c4 10             	add    $0x10,%esp
80103c2d:	85 c0                	test   %eax,%eax
80103c2f:	74 07                	je     80103c38 <mpconfig+0x53>
    return 0;
80103c31:	b8 00 00 00 00       	mov    $0x0,%eax
80103c36:	eb 4c                	jmp    80103c84 <mpconfig+0x9f>
  if(conf->version != 1 && conf->version != 4)
80103c38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c3b:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c3f:	3c 01                	cmp    $0x1,%al
80103c41:	74 12                	je     80103c55 <mpconfig+0x70>
80103c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c46:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c4a:	3c 04                	cmp    $0x4,%al
80103c4c:	74 07                	je     80103c55 <mpconfig+0x70>
    return 0;
80103c4e:	b8 00 00 00 00       	mov    $0x0,%eax
80103c53:	eb 2f                	jmp    80103c84 <mpconfig+0x9f>
  if(sum((uchar*)conf, conf->length) != 0)
80103c55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c58:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c5c:	0f b7 c0             	movzwl %ax,%eax
80103c5f:	83 ec 08             	sub    $0x8,%esp
80103c62:	50                   	push   %eax
80103c63:	ff 75 f0             	push   -0x10(%ebp)
80103c66:	e8 1d fe ff ff       	call   80103a88 <sum>
80103c6b:	83 c4 10             	add    $0x10,%esp
80103c6e:	84 c0                	test   %al,%al
80103c70:	74 07                	je     80103c79 <mpconfig+0x94>
    return 0;
80103c72:	b8 00 00 00 00       	mov    $0x0,%eax
80103c77:	eb 0b                	jmp    80103c84 <mpconfig+0x9f>
  *pmp = mp;
80103c79:	8b 45 08             	mov    0x8(%ebp),%eax
80103c7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c7f:	89 10                	mov    %edx,(%eax)
  return conf;
80103c81:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c84:	c9                   	leave  
80103c85:	c3                   	ret    

80103c86 <mpinit>:

void
mpinit(void)
{
80103c86:	55                   	push   %ebp
80103c87:	89 e5                	mov    %esp,%ebp
80103c89:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103c8c:	83 ec 0c             	sub    $0xc,%esp
80103c8f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103c92:	50                   	push   %eax
80103c93:	e8 4d ff ff ff       	call   80103be5 <mpconfig>
80103c98:	83 c4 10             	add    $0x10,%esp
80103c9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c9e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ca2:	75 0d                	jne    80103cb1 <mpinit+0x2b>
    panic("Expect to run on an SMP");
80103ca4:	83 ec 0c             	sub    $0xc,%esp
80103ca7:	68 6e 8a 10 80       	push   $0x80108a6e
80103cac:	e8 04 c9 ff ff       	call   801005b5 <panic>
  ismp = 1;
80103cb1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103cb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cbb:	8b 40 24             	mov    0x24(%eax),%eax
80103cbe:	a3 c0 26 11 80       	mov    %eax,0x801126c0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103cc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cc6:	83 c0 2c             	add    $0x2c,%eax
80103cc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ccc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ccf:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cd3:	0f b7 d0             	movzwl %ax,%edx
80103cd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cd9:	01 d0                	add    %edx,%eax
80103cdb:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103cde:	e9 8c 00 00 00       	jmp    80103d6f <mpinit+0xe9>
    switch(*p){
80103ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce6:	0f b6 00             	movzbl (%eax),%eax
80103ce9:	0f b6 c0             	movzbl %al,%eax
80103cec:	83 f8 04             	cmp    $0x4,%eax
80103cef:	7f 76                	jg     80103d67 <mpinit+0xe1>
80103cf1:	83 f8 03             	cmp    $0x3,%eax
80103cf4:	7d 6b                	jge    80103d61 <mpinit+0xdb>
80103cf6:	83 f8 02             	cmp    $0x2,%eax
80103cf9:	74 4e                	je     80103d49 <mpinit+0xc3>
80103cfb:	83 f8 02             	cmp    $0x2,%eax
80103cfe:	7f 67                	jg     80103d67 <mpinit+0xe1>
80103d00:	85 c0                	test   %eax,%eax
80103d02:	74 07                	je     80103d0b <mpinit+0x85>
80103d04:	83 f8 01             	cmp    $0x1,%eax
80103d07:	74 58                	je     80103d61 <mpinit+0xdb>
80103d09:	eb 5c                	jmp    80103d67 <mpinit+0xe1>
    case MPPROC:
      proc = (struct mpproc*)p;
80103d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0e:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103d11:	a1 40 2d 11 80       	mov    0x80112d40,%eax
80103d16:	83 f8 07             	cmp    $0x7,%eax
80103d19:	7f 28                	jg     80103d43 <mpinit+0xbd>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103d1b:	8b 15 40 2d 11 80    	mov    0x80112d40,%edx
80103d21:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d24:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d28:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103d2e:	81 c2 c0 27 11 80    	add    $0x801127c0,%edx
80103d34:	88 02                	mov    %al,(%edx)
        ncpu++;
80103d36:	a1 40 2d 11 80       	mov    0x80112d40,%eax
80103d3b:	83 c0 01             	add    $0x1,%eax
80103d3e:	a3 40 2d 11 80       	mov    %eax,0x80112d40
      }
      p += sizeof(struct mpproc);
80103d43:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d47:	eb 26                	jmp    80103d6f <mpinit+0xe9>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d4c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d52:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d56:	a2 44 2d 11 80       	mov    %al,0x80112d44
      p += sizeof(struct mpioapic);
80103d5b:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d5f:	eb 0e                	jmp    80103d6f <mpinit+0xe9>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d61:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d65:	eb 08                	jmp    80103d6f <mpinit+0xe9>
    default:
      ismp = 0;
80103d67:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103d6e:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d72:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103d75:	0f 82 68 ff ff ff    	jb     80103ce3 <mpinit+0x5d>
    }
  }
  if(!ismp)
80103d7b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d7f:	75 0d                	jne    80103d8e <mpinit+0x108>
    panic("Didn't find a suitable machine");
80103d81:	83 ec 0c             	sub    $0xc,%esp
80103d84:	68 88 8a 10 80       	push   $0x80108a88
80103d89:	e8 27 c8 ff ff       	call   801005b5 <panic>

  if(mp->imcrp){
80103d8e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d91:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d95:	84 c0                	test   %al,%al
80103d97:	74 30                	je     80103dc9 <mpinit+0x143>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d99:	83 ec 08             	sub    $0x8,%esp
80103d9c:	6a 70                	push   $0x70
80103d9e:	6a 22                	push   $0x22
80103da0:	e8 c2 fc ff ff       	call   80103a67 <outb>
80103da5:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103da8:	83 ec 0c             	sub    $0xc,%esp
80103dab:	6a 23                	push   $0x23
80103dad:	e8 98 fc ff ff       	call   80103a4a <inb>
80103db2:	83 c4 10             	add    $0x10,%esp
80103db5:	83 c8 01             	or     $0x1,%eax
80103db8:	0f b6 c0             	movzbl %al,%eax
80103dbb:	83 ec 08             	sub    $0x8,%esp
80103dbe:	50                   	push   %eax
80103dbf:	6a 23                	push   $0x23
80103dc1:	e8 a1 fc ff ff       	call   80103a67 <outb>
80103dc6:	83 c4 10             	add    $0x10,%esp
  }
}
80103dc9:	90                   	nop
80103dca:	c9                   	leave  
80103dcb:	c3                   	ret    

80103dcc <outb>:
{
80103dcc:	55                   	push   %ebp
80103dcd:	89 e5                	mov    %esp,%ebp
80103dcf:	83 ec 08             	sub    $0x8,%esp
80103dd2:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd5:	8b 55 0c             	mov    0xc(%ebp),%edx
80103dd8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103ddc:	89 d0                	mov    %edx,%eax
80103dde:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103de1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103de5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103de9:	ee                   	out    %al,(%dx)
}
80103dea:	90                   	nop
80103deb:	c9                   	leave  
80103dec:	c3                   	ret    

80103ded <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103ded:	55                   	push   %ebp
80103dee:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103df0:	68 ff 00 00 00       	push   $0xff
80103df5:	6a 21                	push   $0x21
80103df7:	e8 d0 ff ff ff       	call   80103dcc <outb>
80103dfc:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103dff:	68 ff 00 00 00       	push   $0xff
80103e04:	68 a1 00 00 00       	push   $0xa1
80103e09:	e8 be ff ff ff       	call   80103dcc <outb>
80103e0e:	83 c4 08             	add    $0x8,%esp
}
80103e11:	90                   	nop
80103e12:	c9                   	leave  
80103e13:	c3                   	ret    

80103e14 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103e14:	55                   	push   %ebp
80103e15:	89 e5                	mov    %esp,%ebp
80103e17:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103e1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103e21:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e24:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e2d:	8b 10                	mov    (%eax),%edx
80103e2f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e32:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103e34:	e8 25 d2 ff ff       	call   8010105e <filealloc>
80103e39:	8b 55 08             	mov    0x8(%ebp),%edx
80103e3c:	89 02                	mov    %eax,(%edx)
80103e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e41:	8b 00                	mov    (%eax),%eax
80103e43:	85 c0                	test   %eax,%eax
80103e45:	0f 84 c8 00 00 00    	je     80103f13 <pipealloc+0xff>
80103e4b:	e8 0e d2 ff ff       	call   8010105e <filealloc>
80103e50:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e53:	89 02                	mov    %eax,(%edx)
80103e55:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e58:	8b 00                	mov    (%eax),%eax
80103e5a:	85 c0                	test   %eax,%eax
80103e5c:	0f 84 b1 00 00 00    	je     80103f13 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103e62:	e8 6d ee ff ff       	call   80102cd4 <kalloc>
80103e67:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e6a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e6e:	0f 84 a2 00 00 00    	je     80103f16 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
80103e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e77:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103e7e:	00 00 00 
  p->writeopen = 1;
80103e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e84:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103e8b:	00 00 00 
  p->nwrite = 0;
80103e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e91:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103e98:	00 00 00 
  p->nread = 0;
80103e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e9e:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103ea5:	00 00 00 
  initlock(&p->lock, "pipe");
80103ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eab:	83 ec 08             	sub    $0x8,%esp
80103eae:	68 a7 8a 10 80       	push   $0x80108aa7
80103eb3:	50                   	push   %eax
80103eb4:	e8 62 14 00 00       	call   8010531b <initlock>
80103eb9:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103ebc:	8b 45 08             	mov    0x8(%ebp),%eax
80103ebf:	8b 00                	mov    (%eax),%eax
80103ec1:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80103eca:	8b 00                	mov    (%eax),%eax
80103ecc:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103ed0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed3:	8b 00                	mov    (%eax),%eax
80103ed5:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103ed9:	8b 45 08             	mov    0x8(%ebp),%eax
80103edc:	8b 00                	mov    (%eax),%eax
80103ede:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ee1:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103ee4:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ee7:	8b 00                	mov    (%eax),%eax
80103ee9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103eef:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ef2:	8b 00                	mov    (%eax),%eax
80103ef4:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103ef8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103efb:	8b 00                	mov    (%eax),%eax
80103efd:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103f01:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f04:	8b 00                	mov    (%eax),%eax
80103f06:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f09:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103f0c:	b8 00 00 00 00       	mov    $0x0,%eax
80103f11:	eb 51                	jmp    80103f64 <pipealloc+0x150>
    goto bad;
80103f13:	90                   	nop
80103f14:	eb 01                	jmp    80103f17 <pipealloc+0x103>
    goto bad;
80103f16:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103f17:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f1b:	74 0e                	je     80103f2b <pipealloc+0x117>
    kfree((char*)p);
80103f1d:	83 ec 0c             	sub    $0xc,%esp
80103f20:	ff 75 f4             	push   -0xc(%ebp)
80103f23:	e8 12 ed ff ff       	call   80102c3a <kfree>
80103f28:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2e:	8b 00                	mov    (%eax),%eax
80103f30:	85 c0                	test   %eax,%eax
80103f32:	74 11                	je     80103f45 <pipealloc+0x131>
    fileclose(*f0);
80103f34:	8b 45 08             	mov    0x8(%ebp),%eax
80103f37:	8b 00                	mov    (%eax),%eax
80103f39:	83 ec 0c             	sub    $0xc,%esp
80103f3c:	50                   	push   %eax
80103f3d:	e8 da d1 ff ff       	call   8010111c <fileclose>
80103f42:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103f45:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f48:	8b 00                	mov    (%eax),%eax
80103f4a:	85 c0                	test   %eax,%eax
80103f4c:	74 11                	je     80103f5f <pipealloc+0x14b>
    fileclose(*f1);
80103f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f51:	8b 00                	mov    (%eax),%eax
80103f53:	83 ec 0c             	sub    $0xc,%esp
80103f56:	50                   	push   %eax
80103f57:	e8 c0 d1 ff ff       	call   8010111c <fileclose>
80103f5c:	83 c4 10             	add    $0x10,%esp
  return -1;
80103f5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f64:	c9                   	leave  
80103f65:	c3                   	ret    

80103f66 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103f66:	55                   	push   %ebp
80103f67:	89 e5                	mov    %esp,%ebp
80103f69:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103f6c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6f:	83 ec 0c             	sub    $0xc,%esp
80103f72:	50                   	push   %eax
80103f73:	e8 c5 13 00 00       	call   8010533d <acquire>
80103f78:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103f7b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103f7f:	74 23                	je     80103fa4 <pipeclose+0x3e>
    p->writeopen = 0;
80103f81:	8b 45 08             	mov    0x8(%ebp),%eax
80103f84:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103f8b:	00 00 00 
    wakeup(&p->nread);
80103f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f91:	05 34 02 00 00       	add    $0x234,%eax
80103f96:	83 ec 0c             	sub    $0xc,%esp
80103f99:	50                   	push   %eax
80103f9a:	e8 3e 10 00 00       	call   80104fdd <wakeup>
80103f9f:	83 c4 10             	add    $0x10,%esp
80103fa2:	eb 21                	jmp    80103fc5 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa7:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103fae:	00 00 00 
    wakeup(&p->nwrite);
80103fb1:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb4:	05 38 02 00 00       	add    $0x238,%eax
80103fb9:	83 ec 0c             	sub    $0xc,%esp
80103fbc:	50                   	push   %eax
80103fbd:	e8 1b 10 00 00       	call   80104fdd <wakeup>
80103fc2:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103fc5:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc8:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103fce:	85 c0                	test   %eax,%eax
80103fd0:	75 2c                	jne    80103ffe <pipeclose+0x98>
80103fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd5:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103fdb:	85 c0                	test   %eax,%eax
80103fdd:	75 1f                	jne    80103ffe <pipeclose+0x98>
    release(&p->lock);
80103fdf:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe2:	83 ec 0c             	sub    $0xc,%esp
80103fe5:	50                   	push   %eax
80103fe6:	e8 c0 13 00 00       	call   801053ab <release>
80103feb:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103fee:	83 ec 0c             	sub    $0xc,%esp
80103ff1:	ff 75 08             	push   0x8(%ebp)
80103ff4:	e8 41 ec ff ff       	call   80102c3a <kfree>
80103ff9:	83 c4 10             	add    $0x10,%esp
80103ffc:	eb 10                	jmp    8010400e <pipeclose+0xa8>
  } else
    release(&p->lock);
80103ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80104001:	83 ec 0c             	sub    $0xc,%esp
80104004:	50                   	push   %eax
80104005:	e8 a1 13 00 00       	call   801053ab <release>
8010400a:	83 c4 10             	add    $0x10,%esp
}
8010400d:	90                   	nop
8010400e:	90                   	nop
8010400f:	c9                   	leave  
80104010:	c3                   	ret    

80104011 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104011:	55                   	push   %ebp
80104012:	89 e5                	mov    %esp,%ebp
80104014:	53                   	push   %ebx
80104015:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104018:	8b 45 08             	mov    0x8(%ebp),%eax
8010401b:	83 ec 0c             	sub    $0xc,%esp
8010401e:	50                   	push   %eax
8010401f:	e8 19 13 00 00       	call   8010533d <acquire>
80104024:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104027:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010402e:	e9 ad 00 00 00       	jmp    801040e0 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80104033:	8b 45 08             	mov    0x8(%ebp),%eax
80104036:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010403c:	85 c0                	test   %eax,%eax
8010403e:	74 0c                	je     8010404c <pipewrite+0x3b>
80104040:	e8 92 02 00 00       	call   801042d7 <myproc>
80104045:	8b 40 24             	mov    0x24(%eax),%eax
80104048:	85 c0                	test   %eax,%eax
8010404a:	74 19                	je     80104065 <pipewrite+0x54>
        release(&p->lock);
8010404c:	8b 45 08             	mov    0x8(%ebp),%eax
8010404f:	83 ec 0c             	sub    $0xc,%esp
80104052:	50                   	push   %eax
80104053:	e8 53 13 00 00       	call   801053ab <release>
80104058:	83 c4 10             	add    $0x10,%esp
        return -1;
8010405b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104060:	e9 a9 00 00 00       	jmp    8010410e <pipewrite+0xfd>
      }
      wakeup(&p->nread);
80104065:	8b 45 08             	mov    0x8(%ebp),%eax
80104068:	05 34 02 00 00       	add    $0x234,%eax
8010406d:	83 ec 0c             	sub    $0xc,%esp
80104070:	50                   	push   %eax
80104071:	e8 67 0f 00 00       	call   80104fdd <wakeup>
80104076:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104079:	8b 45 08             	mov    0x8(%ebp),%eax
8010407c:	8b 55 08             	mov    0x8(%ebp),%edx
8010407f:	81 c2 38 02 00 00    	add    $0x238,%edx
80104085:	83 ec 08             	sub    $0x8,%esp
80104088:	50                   	push   %eax
80104089:	52                   	push   %edx
8010408a:	e8 40 0e 00 00       	call   80104ecf <sleep>
8010408f:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104092:	8b 45 08             	mov    0x8(%ebp),%eax
80104095:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010409b:	8b 45 08             	mov    0x8(%ebp),%eax
8010409e:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801040a4:	05 00 02 00 00       	add    $0x200,%eax
801040a9:	39 c2                	cmp    %eax,%edx
801040ab:	74 86                	je     80104033 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801040ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b3:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801040b6:	8b 45 08             	mov    0x8(%ebp),%eax
801040b9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801040bf:	8d 48 01             	lea    0x1(%eax),%ecx
801040c2:	8b 55 08             	mov    0x8(%ebp),%edx
801040c5:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801040cb:	25 ff 01 00 00       	and    $0x1ff,%eax
801040d0:	89 c1                	mov    %eax,%ecx
801040d2:	0f b6 13             	movzbl (%ebx),%edx
801040d5:	8b 45 08             	mov    0x8(%ebp),%eax
801040d8:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
801040dc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801040e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e3:	3b 45 10             	cmp    0x10(%ebp),%eax
801040e6:	7c aa                	jl     80104092 <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801040e8:	8b 45 08             	mov    0x8(%ebp),%eax
801040eb:	05 34 02 00 00       	add    $0x234,%eax
801040f0:	83 ec 0c             	sub    $0xc,%esp
801040f3:	50                   	push   %eax
801040f4:	e8 e4 0e 00 00       	call   80104fdd <wakeup>
801040f9:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801040fc:	8b 45 08             	mov    0x8(%ebp),%eax
801040ff:	83 ec 0c             	sub    $0xc,%esp
80104102:	50                   	push   %eax
80104103:	e8 a3 12 00 00       	call   801053ab <release>
80104108:	83 c4 10             	add    $0x10,%esp
  return n;
8010410b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010410e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104111:	c9                   	leave  
80104112:	c3                   	ret    

80104113 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104113:	55                   	push   %ebp
80104114:	89 e5                	mov    %esp,%ebp
80104116:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104119:	8b 45 08             	mov    0x8(%ebp),%eax
8010411c:	83 ec 0c             	sub    $0xc,%esp
8010411f:	50                   	push   %eax
80104120:	e8 18 12 00 00       	call   8010533d <acquire>
80104125:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104128:	eb 3e                	jmp    80104168 <piperead+0x55>
    if(myproc()->killed){
8010412a:	e8 a8 01 00 00       	call   801042d7 <myproc>
8010412f:	8b 40 24             	mov    0x24(%eax),%eax
80104132:	85 c0                	test   %eax,%eax
80104134:	74 19                	je     8010414f <piperead+0x3c>
      release(&p->lock);
80104136:	8b 45 08             	mov    0x8(%ebp),%eax
80104139:	83 ec 0c             	sub    $0xc,%esp
8010413c:	50                   	push   %eax
8010413d:	e8 69 12 00 00       	call   801053ab <release>
80104142:	83 c4 10             	add    $0x10,%esp
      return -1;
80104145:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010414a:	e9 be 00 00 00       	jmp    8010420d <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010414f:	8b 45 08             	mov    0x8(%ebp),%eax
80104152:	8b 55 08             	mov    0x8(%ebp),%edx
80104155:	81 c2 34 02 00 00    	add    $0x234,%edx
8010415b:	83 ec 08             	sub    $0x8,%esp
8010415e:	50                   	push   %eax
8010415f:	52                   	push   %edx
80104160:	e8 6a 0d 00 00       	call   80104ecf <sleep>
80104165:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104168:	8b 45 08             	mov    0x8(%ebp),%eax
8010416b:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104171:	8b 45 08             	mov    0x8(%ebp),%eax
80104174:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010417a:	39 c2                	cmp    %eax,%edx
8010417c:	75 0d                	jne    8010418b <piperead+0x78>
8010417e:	8b 45 08             	mov    0x8(%ebp),%eax
80104181:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104187:	85 c0                	test   %eax,%eax
80104189:	75 9f                	jne    8010412a <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010418b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104192:	eb 48                	jmp    801041dc <piperead+0xc9>
    if(p->nread == p->nwrite)
80104194:	8b 45 08             	mov    0x8(%ebp),%eax
80104197:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010419d:	8b 45 08             	mov    0x8(%ebp),%eax
801041a0:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041a6:	39 c2                	cmp    %eax,%edx
801041a8:	74 3c                	je     801041e6 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801041aa:	8b 45 08             	mov    0x8(%ebp),%eax
801041ad:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041b3:	8d 48 01             	lea    0x1(%eax),%ecx
801041b6:	8b 55 08             	mov    0x8(%ebp),%edx
801041b9:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801041bf:	25 ff 01 00 00       	and    $0x1ff,%eax
801041c4:	89 c1                	mov    %eax,%ecx
801041c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801041cc:	01 c2                	add    %eax,%edx
801041ce:	8b 45 08             	mov    0x8(%ebp),%eax
801041d1:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
801041d6:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801041d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041df:	3b 45 10             	cmp    0x10(%ebp),%eax
801041e2:	7c b0                	jl     80104194 <piperead+0x81>
801041e4:	eb 01                	jmp    801041e7 <piperead+0xd4>
      break;
801041e6:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801041e7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ea:	05 38 02 00 00       	add    $0x238,%eax
801041ef:	83 ec 0c             	sub    $0xc,%esp
801041f2:	50                   	push   %eax
801041f3:	e8 e5 0d 00 00       	call   80104fdd <wakeup>
801041f8:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801041fb:	8b 45 08             	mov    0x8(%ebp),%eax
801041fe:	83 ec 0c             	sub    $0xc,%esp
80104201:	50                   	push   %eax
80104202:	e8 a4 11 00 00       	call   801053ab <release>
80104207:	83 c4 10             	add    $0x10,%esp
  return i;
8010420a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010420d:	c9                   	leave  
8010420e:	c3                   	ret    

8010420f <readeflags>:
{
8010420f:	55                   	push   %ebp
80104210:	89 e5                	mov    %esp,%ebp
80104212:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104215:	9c                   	pushf  
80104216:	58                   	pop    %eax
80104217:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010421a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010421d:	c9                   	leave  
8010421e:	c3                   	ret    

8010421f <sti>:
{
8010421f:	55                   	push   %ebp
80104220:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104222:	fb                   	sti    
}
80104223:	90                   	nop
80104224:	5d                   	pop    %ebp
80104225:	c3                   	ret    

80104226 <pinit>:
extern void trapret(void);

static void wakeup1(void *chan);

void pinit(void)
{
80104226:	55                   	push   %ebp
80104227:	89 e5                	mov    %esp,%ebp
80104229:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010422c:	83 ec 08             	sub    $0x8,%esp
8010422f:	68 ac 8a 10 80       	push   $0x80108aac
80104234:	68 60 2d 11 80       	push   $0x80112d60
80104239:	e8 dd 10 00 00       	call   8010531b <initlock>
8010423e:	83 c4 10             	add    $0x10,%esp
}
80104241:	90                   	nop
80104242:	c9                   	leave  
80104243:	c3                   	ret    

80104244 <cpuid>:

// Must be called with interrupts disabled
int cpuid()
{
80104244:	55                   	push   %ebp
80104245:	89 e5                	mov    %esp,%ebp
80104247:	83 ec 08             	sub    $0x8,%esp
  return mycpu() - cpus;
8010424a:	e8 10 00 00 00       	call   8010425f <mycpu>
8010424f:	2d c0 27 11 80       	sub    $0x801127c0,%eax
80104254:	c1 f8 04             	sar    $0x4,%eax
80104257:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
8010425d:	c9                   	leave  
8010425e:	c3                   	ret    

8010425f <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu *
mycpu(void)
{
8010425f:	55                   	push   %ebp
80104260:	89 e5                	mov    %esp,%ebp
80104262:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;

  if (readeflags() & FL_IF)
80104265:	e8 a5 ff ff ff       	call   8010420f <readeflags>
8010426a:	25 00 02 00 00       	and    $0x200,%eax
8010426f:	85 c0                	test   %eax,%eax
80104271:	74 0d                	je     80104280 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
80104273:	83 ec 0c             	sub    $0xc,%esp
80104276:	68 b4 8a 10 80       	push   $0x80108ab4
8010427b:	e8 35 c3 ff ff       	call   801005b5 <panic>

  apicid = lapicid();
80104280:	e8 a9 ed ff ff       	call   8010302e <lapicid>
80104285:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i)
80104288:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010428f:	eb 2d                	jmp    801042be <mycpu+0x5f>
  {
    if (cpus[i].apicid == apicid)
80104291:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104294:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010429a:	05 c0 27 11 80       	add    $0x801127c0,%eax
8010429f:	0f b6 00             	movzbl (%eax),%eax
801042a2:	0f b6 c0             	movzbl %al,%eax
801042a5:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801042a8:	75 10                	jne    801042ba <mycpu+0x5b>
      return &cpus[i];
801042aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ad:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801042b3:	05 c0 27 11 80       	add    $0x801127c0,%eax
801042b8:	eb 1b                	jmp    801042d5 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i)
801042ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042be:	a1 40 2d 11 80       	mov    0x80112d40,%eax
801042c3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801042c6:	7c c9                	jl     80104291 <mycpu+0x32>
  }
  panic("unknown apicid\n");
801042c8:	83 ec 0c             	sub    $0xc,%esp
801042cb:	68 da 8a 10 80       	push   $0x80108ada
801042d0:	e8 e0 c2 ff ff       	call   801005b5 <panic>
}
801042d5:	c9                   	leave  
801042d6:	c3                   	ret    

801042d7 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc *
myproc(void)
{
801042d7:	55                   	push   %ebp
801042d8:	89 e5                	mov    %esp,%ebp
801042da:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801042dd:	e8 d6 11 00 00       	call   801054b8 <pushcli>
  c = mycpu();
801042e2:	e8 78 ff ff ff       	call   8010425f <mycpu>
801042e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801042ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ed:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801042f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801042f6:	e8 0a 12 00 00       	call   80105505 <popcli>
  return p;
801042fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801042fe:	c9                   	leave  
801042ff:	c3                   	ret    

80104300 <allocproc>:
//  If found, change state to EMBRYO and initialize
//  state required to run in the kernel.
//  Otherwise return 0.
static struct proc *
allocproc(void)
{
80104300:	55                   	push   %ebp
80104301:	89 e5                	mov    %esp,%ebp
80104303:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104306:	83 ec 0c             	sub    $0xc,%esp
80104309:	68 60 2d 11 80       	push   $0x80112d60
8010430e:	e8 2a 10 00 00       	call   8010533d <acquire>
80104313:	83 c4 10             	add    $0x10,%esp

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104316:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
8010431d:	eb 11                	jmp    80104330 <allocproc+0x30>
    if (p->state == UNUSED)
8010431f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104322:	8b 40 0c             	mov    0xc(%eax),%eax
80104325:	85 c0                	test   %eax,%eax
80104327:	74 2a                	je     80104353 <allocproc+0x53>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104329:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104330:	81 7d f4 94 51 11 80 	cmpl   $0x80115194,-0xc(%ebp)
80104337:	72 e6                	jb     8010431f <allocproc+0x1f>
      goto found;

  release(&ptable.lock);
80104339:	83 ec 0c             	sub    $0xc,%esp
8010433c:	68 60 2d 11 80       	push   $0x80112d60
80104341:	e8 65 10 00 00       	call   801053ab <release>
80104346:	83 c4 10             	add    $0x10,%esp
  return 0;
80104349:	b8 00 00 00 00       	mov    $0x0,%eax
8010434e:	e9 b2 00 00 00       	jmp    80104405 <allocproc+0x105>
      goto found;
80104353:	90                   	nop

found:
  p->state = EMBRYO;
80104354:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104357:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010435e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80104363:	8d 50 01             	lea    0x1(%eax),%edx
80104366:	89 15 00 b0 10 80    	mov    %edx,0x8010b000
8010436c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010436f:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80104372:	83 ec 0c             	sub    $0xc,%esp
80104375:	68 60 2d 11 80       	push   $0x80112d60
8010437a:	e8 2c 10 00 00       	call   801053ab <release>
8010437f:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if ((p->kstack = kalloc()) == 0)
80104382:	e8 4d e9 ff ff       	call   80102cd4 <kalloc>
80104387:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010438a:	89 42 08             	mov    %eax,0x8(%edx)
8010438d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104390:	8b 40 08             	mov    0x8(%eax),%eax
80104393:	85 c0                	test   %eax,%eax
80104395:	75 11                	jne    801043a8 <allocproc+0xa8>
  {
    p->state = UNUSED;
80104397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043a1:	b8 00 00 00 00       	mov    $0x0,%eax
801043a6:	eb 5d                	jmp    80104405 <allocproc+0x105>
  }
  sp = p->kstack + KSTACKSIZE;
801043a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ab:	8b 40 08             	mov    0x8(%eax),%eax
801043ae:	05 00 10 00 00       	add    $0x1000,%eax
801043b3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801043b6:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe *)sp;
801043ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043c0:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801043c3:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint *)sp = (uint)trapret;
801043c7:	ba f9 69 10 80       	mov    $0x801069f9,%edx
801043cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043cf:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801043d1:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context *)sp;
801043d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043db:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801043de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e1:	8b 40 1c             	mov    0x1c(%eax),%eax
801043e4:	83 ec 04             	sub    $0x4,%esp
801043e7:	6a 14                	push   $0x14
801043e9:	6a 00                	push   $0x0
801043eb:	50                   	push   %eax
801043ec:	e8 d2 11 00 00       	call   801055c3 <memset>
801043f1:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801043f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f7:	8b 40 1c             	mov    0x1c(%eax),%eax
801043fa:	ba 89 4e 10 80       	mov    $0x80104e89,%edx
801043ff:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104402:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104405:	c9                   	leave  
80104406:	c3                   	ret    

80104407 <userinit>:

// PAGEBREAK: 32
//  Set up first user process.
void userinit(void)
{
80104407:	55                   	push   %ebp
80104408:	89 e5                	mov    %esp,%ebp
8010440a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
8010440d:	e8 ee fe ff ff       	call   80104300 <allocproc>
80104412:	89 45 f4             	mov    %eax,-0xc(%ebp)

  initproc = p;
80104415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104418:	a3 94 51 11 80       	mov    %eax,0x80115194
  if ((p->pgdir = setupkvm()) == 0)
8010441d:	e8 20 3b 00 00       	call   80107f42 <setupkvm>
80104422:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104425:	89 42 04             	mov    %eax,0x4(%edx)
80104428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442b:	8b 40 04             	mov    0x4(%eax),%eax
8010442e:	85 c0                	test   %eax,%eax
80104430:	75 0d                	jne    8010443f <userinit+0x38>
    panic("userinit: out of memory?");
80104432:	83 ec 0c             	sub    $0xc,%esp
80104435:	68 ea 8a 10 80       	push   $0x80108aea
8010443a:	e8 76 c1 ff ff       	call   801005b5 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010443f:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104447:	8b 40 04             	mov    0x4(%eax),%eax
8010444a:	83 ec 04             	sub    $0x4,%esp
8010444d:	52                   	push   %edx
8010444e:	68 c0 b4 10 80       	push   $0x8010b4c0
80104453:	50                   	push   %eax
80104454:	e8 52 3d 00 00       	call   801081ab <inituvm>
80104459:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
8010445c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104468:	8b 40 18             	mov    0x18(%eax),%eax
8010446b:	83 ec 04             	sub    $0x4,%esp
8010446e:	6a 4c                	push   $0x4c
80104470:	6a 00                	push   $0x0
80104472:	50                   	push   %eax
80104473:	e8 4b 11 00 00       	call   801055c3 <memset>
80104478:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010447b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447e:	8b 40 18             	mov    0x18(%eax),%eax
80104481:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448a:	8b 40 18             	mov    0x18(%eax),%eax
8010448d:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104496:	8b 50 18             	mov    0x18(%eax),%edx
80104499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449c:	8b 40 18             	mov    0x18(%eax),%eax
8010449f:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044a3:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801044a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044aa:	8b 50 18             	mov    0x18(%eax),%edx
801044ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b0:	8b 40 18             	mov    0x18(%eax),%eax
801044b3:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044b7:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801044bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044be:	8b 40 18             	mov    0x18(%eax),%eax
801044c1:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801044c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044cb:	8b 40 18             	mov    0x18(%eax),%eax
801044ce:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0; // beginning of initcode.S
801044d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d8:	8b 40 18             	mov    0x18(%eax),%eax
801044db:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801044e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e5:	83 c0 6c             	add    $0x6c,%eax
801044e8:	83 ec 04             	sub    $0x4,%esp
801044eb:	6a 10                	push   $0x10
801044ed:	68 03 8b 10 80       	push   $0x80108b03
801044f2:	50                   	push   %eax
801044f3:	e8 ce 12 00 00       	call   801057c6 <safestrcpy>
801044f8:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801044fb:	83 ec 0c             	sub    $0xc,%esp
801044fe:	68 0c 8b 10 80       	push   $0x80108b0c
80104503:	e8 83 e0 ff ff       	call   8010258b <namei>
80104508:	83 c4 10             	add    $0x10,%esp
8010450b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010450e:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104511:	83 ec 0c             	sub    $0xc,%esp
80104514:	68 60 2d 11 80       	push   $0x80112d60
80104519:	e8 1f 0e 00 00       	call   8010533d <acquire>
8010451e:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104524:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010452b:	83 ec 0c             	sub    $0xc,%esp
8010452e:	68 60 2d 11 80       	push   $0x80112d60
80104533:	e8 73 0e 00 00       	call   801053ab <release>
80104538:	83 c4 10             	add    $0x10,%esp
}
8010453b:	90                   	nop
8010453c:	c9                   	leave  
8010453d:	c3                   	ret    

8010453e <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int growproc(int n)
{
8010453e:	55                   	push   %ebp
8010453f:	89 e5                	mov    %esp,%ebp
80104541:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80104544:	e8 8e fd ff ff       	call   801042d7 <myproc>
80104549:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
8010454c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010454f:	8b 00                	mov    (%eax),%eax
80104551:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (n > 0)
80104554:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104558:	7e 2e                	jle    80104588 <growproc+0x4a>
  {
    if ((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010455a:	8b 55 08             	mov    0x8(%ebp),%edx
8010455d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104560:	01 c2                	add    %eax,%edx
80104562:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104565:	8b 40 04             	mov    0x4(%eax),%eax
80104568:	83 ec 04             	sub    $0x4,%esp
8010456b:	52                   	push   %edx
8010456c:	ff 75 f4             	push   -0xc(%ebp)
8010456f:	50                   	push   %eax
80104570:	e8 73 3d 00 00       	call   801082e8 <allocuvm>
80104575:	83 c4 10             	add    $0x10,%esp
80104578:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010457b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010457f:	75 3b                	jne    801045bc <growproc+0x7e>
      return -1;
80104581:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104586:	eb 4f                	jmp    801045d7 <growproc+0x99>
  }
  else if (n < 0)
80104588:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010458c:	79 2e                	jns    801045bc <growproc+0x7e>
  {
    if ((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010458e:	8b 55 08             	mov    0x8(%ebp),%edx
80104591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104594:	01 c2                	add    %eax,%edx
80104596:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104599:	8b 40 04             	mov    0x4(%eax),%eax
8010459c:	83 ec 04             	sub    $0x4,%esp
8010459f:	52                   	push   %edx
801045a0:	ff 75 f4             	push   -0xc(%ebp)
801045a3:	50                   	push   %eax
801045a4:	e8 44 3e 00 00       	call   801083ed <deallocuvm>
801045a9:	83 c4 10             	add    $0x10,%esp
801045ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045b3:	75 07                	jne    801045bc <growproc+0x7e>
      return -1;
801045b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ba:	eb 1b                	jmp    801045d7 <growproc+0x99>
  }
  curproc->sz = sz;
801045bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045c2:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801045c4:	83 ec 0c             	sub    $0xc,%esp
801045c7:	ff 75 f0             	push   -0x10(%ebp)
801045ca:	e8 3d 3a 00 00       	call   8010800c <switchuvm>
801045cf:	83 c4 10             	add    $0x10,%esp
  return 0;
801045d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045d7:	c9                   	leave  
801045d8:	c3                   	ret    

801045d9 <fork>:

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int fork(void)
{
801045d9:	55                   	push   %ebp
801045da:	89 e5                	mov    %esp,%ebp
801045dc:	57                   	push   %edi
801045dd:	56                   	push   %esi
801045de:	53                   	push   %ebx
801045df:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801045e2:	e8 f0 fc ff ff       	call   801042d7 <myproc>
801045e7:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if ((np = allocproc()) == 0)
801045ea:	e8 11 fd ff ff       	call   80104300 <allocproc>
801045ef:	89 45 dc             	mov    %eax,-0x24(%ebp)
801045f2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801045f6:	75 0a                	jne    80104602 <fork+0x29>
  {
    return -1;
801045f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045fd:	e9 48 01 00 00       	jmp    8010474a <fork+0x171>
  }

  // Copy process state from proc.
  if ((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0)
80104602:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104605:	8b 10                	mov    (%eax),%edx
80104607:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010460a:	8b 40 04             	mov    0x4(%eax),%eax
8010460d:	83 ec 08             	sub    $0x8,%esp
80104610:	52                   	push   %edx
80104611:	50                   	push   %eax
80104612:	e8 74 3f 00 00       	call   8010858b <copyuvm>
80104617:	83 c4 10             	add    $0x10,%esp
8010461a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010461d:	89 42 04             	mov    %eax,0x4(%edx)
80104620:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104623:	8b 40 04             	mov    0x4(%eax),%eax
80104626:	85 c0                	test   %eax,%eax
80104628:	75 30                	jne    8010465a <fork+0x81>
  {
    kfree(np->kstack);
8010462a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010462d:	8b 40 08             	mov    0x8(%eax),%eax
80104630:	83 ec 0c             	sub    $0xc,%esp
80104633:	50                   	push   %eax
80104634:	e8 01 e6 ff ff       	call   80102c3a <kfree>
80104639:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010463c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010463f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104646:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104649:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104650:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104655:	e9 f0 00 00 00       	jmp    8010474a <fork+0x171>
  }
  np->sz = curproc->sz;
8010465a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010465d:	8b 10                	mov    (%eax),%edx
8010465f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104662:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104664:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104667:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010466a:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
8010466d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104670:	8b 48 18             	mov    0x18(%eax),%ecx
80104673:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104676:	8b 40 18             	mov    0x18(%eax),%eax
80104679:	89 c2                	mov    %eax,%edx
8010467b:	89 cb                	mov    %ecx,%ebx
8010467d:	b8 13 00 00 00       	mov    $0x13,%eax
80104682:	89 d7                	mov    %edx,%edi
80104684:	89 de                	mov    %ebx,%esi
80104686:	89 c1                	mov    %eax,%ecx
80104688:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010468a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010468d:	8b 40 18             	mov    0x18(%eax),%eax
80104690:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for (i = 0; i < NOFILE; i++)
80104697:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010469e:	eb 3b                	jmp    801046db <fork+0x102>
    if (curproc->ofile[i])
801046a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046a6:	83 c2 08             	add    $0x8,%edx
801046a9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046ad:	85 c0                	test   %eax,%eax
801046af:	74 26                	je     801046d7 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
801046b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046b7:	83 c2 08             	add    $0x8,%edx
801046ba:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046be:	83 ec 0c             	sub    $0xc,%esp
801046c1:	50                   	push   %eax
801046c2:	e8 04 ca ff ff       	call   801010cb <filedup>
801046c7:	83 c4 10             	add    $0x10,%esp
801046ca:	8b 55 dc             	mov    -0x24(%ebp),%edx
801046cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801046d0:	83 c1 08             	add    $0x8,%ecx
801046d3:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for (i = 0; i < NOFILE; i++)
801046d7:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801046db:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801046df:	7e bf                	jle    801046a0 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
801046e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e4:	8b 40 68             	mov    0x68(%eax),%eax
801046e7:	83 ec 0c             	sub    $0xc,%esp
801046ea:	50                   	push   %eax
801046eb:	e8 2e d3 ff ff       	call   80101a1e <idup>
801046f0:	83 c4 10             	add    $0x10,%esp
801046f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
801046f6:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801046f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046fc:	8d 50 6c             	lea    0x6c(%eax),%edx
801046ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104702:	83 c0 6c             	add    $0x6c,%eax
80104705:	83 ec 04             	sub    $0x4,%esp
80104708:	6a 10                	push   $0x10
8010470a:	52                   	push   %edx
8010470b:	50                   	push   %eax
8010470c:	e8 b5 10 00 00       	call   801057c6 <safestrcpy>
80104711:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104714:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104717:	8b 40 10             	mov    0x10(%eax),%eax
8010471a:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
8010471d:	83 ec 0c             	sub    $0xc,%esp
80104720:	68 60 2d 11 80       	push   $0x80112d60
80104725:	e8 13 0c 00 00       	call   8010533d <acquire>
8010472a:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
8010472d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104730:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104737:	83 ec 0c             	sub    $0xc,%esp
8010473a:	68 60 2d 11 80       	push   $0x80112d60
8010473f:	e8 67 0c 00 00       	call   801053ab <release>
80104744:	83 c4 10             	add    $0x10,%esp

  return pid;
80104747:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
8010474a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010474d:	5b                   	pop    %ebx
8010474e:	5e                   	pop    %esi
8010474f:	5f                   	pop    %edi
80104750:	5d                   	pop    %ebp
80104751:	c3                   	ret    

80104752 <exit>:

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void exit(void)
{
80104752:	55                   	push   %ebp
80104753:	89 e5                	mov    %esp,%ebp
80104755:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104758:	e8 7a fb ff ff       	call   801042d7 <myproc>
8010475d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if (curproc == initproc)
80104760:	a1 94 51 11 80       	mov    0x80115194,%eax
80104765:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104768:	75 0d                	jne    80104777 <exit+0x25>
    panic("init exiting");
8010476a:	83 ec 0c             	sub    $0xc,%esp
8010476d:	68 0e 8b 10 80       	push   $0x80108b0e
80104772:	e8 3e be ff ff       	call   801005b5 <panic>

  // Close all open files.
  for (fd = 0; fd < NOFILE; fd++)
80104777:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010477e:	eb 3f                	jmp    801047bf <exit+0x6d>
  {
    if (curproc->ofile[fd])
80104780:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104783:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104786:	83 c2 08             	add    $0x8,%edx
80104789:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010478d:	85 c0                	test   %eax,%eax
8010478f:	74 2a                	je     801047bb <exit+0x69>
    {
      fileclose(curproc->ofile[fd]);
80104791:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104794:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104797:	83 c2 08             	add    $0x8,%edx
8010479a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010479e:	83 ec 0c             	sub    $0xc,%esp
801047a1:	50                   	push   %eax
801047a2:	e8 75 c9 ff ff       	call   8010111c <fileclose>
801047a7:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801047aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047b0:	83 c2 08             	add    $0x8,%edx
801047b3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801047ba:	00 
  for (fd = 0; fd < NOFILE; fd++)
801047bb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801047bf:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801047c3:	7e bb                	jle    80104780 <exit+0x2e>
    }
  }

  begin_op();
801047c5:	e8 a6 ed ff ff       	call   80103570 <begin_op>
  iput(curproc->cwd);
801047ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047cd:	8b 40 68             	mov    0x68(%eax),%eax
801047d0:	83 ec 0c             	sub    $0xc,%esp
801047d3:	50                   	push   %eax
801047d4:	e8 e0 d3 ff ff       	call   80101bb9 <iput>
801047d9:	83 c4 10             	add    $0x10,%esp
  end_op();
801047dc:	e8 1b ee ff ff       	call   801035fc <end_op>
  curproc->cwd = 0;
801047e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047e4:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801047eb:	83 ec 0c             	sub    $0xc,%esp
801047ee:	68 60 2d 11 80       	push   $0x80112d60
801047f3:	e8 45 0b 00 00       	call   8010533d <acquire>
801047f8:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801047fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047fe:	8b 40 14             	mov    0x14(%eax),%eax
80104801:	83 ec 0c             	sub    $0xc,%esp
80104804:	50                   	push   %eax
80104805:	e8 6c 07 00 00       	call   80104f76 <wakeup1>
8010480a:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010480d:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
80104814:	eb 3a                	jmp    80104850 <exit+0xfe>
  {
    if (p->parent == curproc)
80104816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104819:	8b 40 14             	mov    0x14(%eax),%eax
8010481c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010481f:	75 28                	jne    80104849 <exit+0xf7>
    {
      p->parent = initproc;
80104821:	8b 15 94 51 11 80    	mov    0x80115194,%edx
80104827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010482a:	89 50 14             	mov    %edx,0x14(%eax)
      if (p->state == ZOMBIE)
8010482d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104830:	8b 40 0c             	mov    0xc(%eax),%eax
80104833:	83 f8 05             	cmp    $0x5,%eax
80104836:	75 11                	jne    80104849 <exit+0xf7>
        wakeup1(initproc);
80104838:	a1 94 51 11 80       	mov    0x80115194,%eax
8010483d:	83 ec 0c             	sub    $0xc,%esp
80104840:	50                   	push   %eax
80104841:	e8 30 07 00 00       	call   80104f76 <wakeup1>
80104846:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104849:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104850:	81 7d f4 94 51 11 80 	cmpl   $0x80115194,-0xc(%ebp)
80104857:	72 bd                	jb     80104816 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104859:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010485c:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104863:	e8 2e 05 00 00       	call   80104d96 <sched>
  panic("zombie exit");
80104868:	83 ec 0c             	sub    $0xc,%esp
8010486b:	68 1b 8b 10 80       	push   $0x80108b1b
80104870:	e8 40 bd ff ff       	call   801005b5 <panic>

80104875 <wait>:
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int wait(void)
{
80104875:	55                   	push   %ebp
80104876:	89 e5                	mov    %esp,%ebp
80104878:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010487b:	e8 57 fa ff ff       	call   801042d7 <myproc>
80104880:	89 45 ec             	mov    %eax,-0x14(%ebp)

  acquire(&ptable.lock);
80104883:	83 ec 0c             	sub    $0xc,%esp
80104886:	68 60 2d 11 80       	push   $0x80112d60
8010488b:	e8 ad 0a 00 00       	call   8010533d <acquire>
80104890:	83 c4 10             	add    $0x10,%esp
  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
80104893:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010489a:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
801048a1:	e9 a4 00 00 00       	jmp    8010494a <wait+0xd5>
    {
      if (p->parent != curproc)
801048a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a9:	8b 40 14             	mov    0x14(%eax),%eax
801048ac:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801048af:	0f 85 8d 00 00 00    	jne    80104942 <wait+0xcd>
        continue;
      havekids = 1;
801048b5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if (p->state == ZOMBIE)
801048bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048bf:	8b 40 0c             	mov    0xc(%eax),%eax
801048c2:	83 f8 05             	cmp    $0x5,%eax
801048c5:	75 7c                	jne    80104943 <wait+0xce>
      {
        // Found one.
        pid = p->pid;
801048c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ca:	8b 40 10             	mov    0x10(%eax),%eax
801048cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801048d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d3:	8b 40 08             	mov    0x8(%eax),%eax
801048d6:	83 ec 0c             	sub    $0xc,%esp
801048d9:	50                   	push   %eax
801048da:	e8 5b e3 ff ff       	call   80102c3a <kfree>
801048df:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801048e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801048ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ef:	8b 40 04             	mov    0x4(%eax),%eax
801048f2:	83 ec 0c             	sub    $0xc,%esp
801048f5:	50                   	push   %eax
801048f6:	e8 b6 3b 00 00       	call   801084b1 <freevm>
801048fb:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801048fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104901:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104915:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491c:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104926:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010492d:	83 ec 0c             	sub    $0xc,%esp
80104930:	68 60 2d 11 80       	push   $0x80112d60
80104935:	e8 71 0a 00 00       	call   801053ab <release>
8010493a:	83 c4 10             	add    $0x10,%esp
        return pid;
8010493d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104940:	eb 54                	jmp    80104996 <wait+0x121>
        continue;
80104942:	90                   	nop
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104943:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010494a:	81 7d f4 94 51 11 80 	cmpl   $0x80115194,-0xc(%ebp)
80104951:	0f 82 4f ff ff ff    	jb     801048a6 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if (!havekids || curproc->killed)
80104957:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010495b:	74 0a                	je     80104967 <wait+0xf2>
8010495d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104960:	8b 40 24             	mov    0x24(%eax),%eax
80104963:	85 c0                	test   %eax,%eax
80104965:	74 17                	je     8010497e <wait+0x109>
    {
      release(&ptable.lock);
80104967:	83 ec 0c             	sub    $0xc,%esp
8010496a:	68 60 2d 11 80       	push   $0x80112d60
8010496f:	e8 37 0a 00 00       	call   801053ab <release>
80104974:	83 c4 10             	add    $0x10,%esp
      return -1;
80104977:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010497c:	eb 18                	jmp    80104996 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock); // DOC: wait-sleep
8010497e:	83 ec 08             	sub    $0x8,%esp
80104981:	68 60 2d 11 80       	push   $0x80112d60
80104986:	ff 75 ec             	push   -0x14(%ebp)
80104989:	e8 41 05 00 00       	call   80104ecf <sleep>
8010498e:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104991:	e9 fd fe ff ff       	jmp    80104893 <wait+0x1e>
  }
}
80104996:	c9                   	leave  
80104997:	c3                   	ret    

80104998 <decay>:

/// @brief
/// @param cpu
/// @return
int decay(int cpu)
{
80104998:	55                   	push   %ebp
80104999:	89 e5                	mov    %esp,%ebp
  return cpu / 2;
8010499b:	8b 45 08             	mov    0x8(%ebp),%eax
8010499e:	89 c2                	mov    %eax,%edx
801049a0:	c1 ea 1f             	shr    $0x1f,%edx
801049a3:	01 d0                	add    %edx,%eax
801049a5:	d1 f8                	sar    %eax
}
801049a7:	5d                   	pop    %ebp
801049a8:	c3                   	ret    

801049a9 <populate_pschedinfo>:

/// @brief
/// @param pinfo
void populate_pschedinfo(struct pschedinfo* pinfo)
{
801049a9:	55                   	push   %ebp
801049aa:	89 e5                	mov    %esp,%ebp
801049ac:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801049af:	83 ec 0c             	sub    $0xc,%esp
801049b2:	68 60 2d 11 80       	push   $0x80112d60
801049b7:	e8 81 09 00 00       	call   8010533d <acquire>
801049bc:	83 c4 10             	add    $0x10,%esp
  
  for(int i = 0; i<NPROC; i++) {
801049bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801049c6:	e9 a7 00 00 00       	jmp    80104a72 <populate_pschedinfo+0xc9>
    if (ptable.proc[i].state == UNUSED) pinfo->inuse[i] = 0;
801049cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049ce:	89 d0                	mov    %edx,%eax
801049d0:	c1 e0 03             	shl    $0x3,%eax
801049d3:	01 d0                	add    %edx,%eax
801049d5:	c1 e0 04             	shl    $0x4,%eax
801049d8:	05 a0 2d 11 80       	add    $0x80112da0,%eax
801049dd:	8b 00                	mov    (%eax),%eax
801049df:	85 c0                	test   %eax,%eax
801049e1:	75 0f                	jne    801049f2 <populate_pschedinfo+0x49>
801049e3:	8b 45 08             	mov    0x8(%ebp),%eax
801049e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049e9:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
801049f0:	eb 0d                	jmp    801049ff <populate_pschedinfo+0x56>
    else
    {
      pinfo->inuse[i] = 1;
801049f2:	8b 45 08             	mov    0x8(%ebp),%eax
801049f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049f8:	c7 04 90 01 00 00 00 	movl   $0x1,(%eax,%edx,4)
    }      
    p = &ptable.proc[i];
801049ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a02:	89 d0                	mov    %edx,%eax
80104a04:	c1 e0 03             	shl    $0x3,%eax
80104a07:	01 d0                	add    %edx,%eax
80104a09:	c1 e0 04             	shl    $0x4,%eax
80104a0c:	83 c0 30             	add    $0x30,%eax
80104a0f:	05 60 2d 11 80       	add    $0x80112d60,%eax
80104a14:	83 c0 04             	add    $0x4,%eax
80104a17:	89 45 f0             	mov    %eax,-0x10(%ebp)
    pinfo->priority[i] = p->priority;
80104a1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a1d:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104a23:	8b 45 08             	mov    0x8(%ebp),%eax
80104a26:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104a29:	83 c1 40             	add    $0x40,%ecx
80104a2c:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    pinfo->nice[i] = p->nice;
80104a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a32:	8b 50 7c             	mov    0x7c(%eax),%edx
80104a35:	8b 45 08             	mov    0x8(%ebp),%eax
80104a38:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104a3b:	83 e9 80             	sub    $0xffffff80,%ecx
80104a3e:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    pinfo->pid[i] = p->pid;
80104a41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a44:	8b 50 10             	mov    0x10(%eax),%edx
80104a47:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104a4d:	81 c1 c0 00 00 00    	add    $0xc0,%ecx
80104a53:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    pinfo->ticks[i] = p->ticks;
80104a56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a59:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80104a5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a62:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104a65:	81 c1 00 01 00 00    	add    $0x100,%ecx
80104a6b:	89 14 88             	mov    %edx,(%eax,%ecx,4)
  for(int i = 0; i<NPROC; i++) {
80104a6e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a72:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104a76:	0f 8e 4f ff ff ff    	jle    801049cb <populate_pschedinfo+0x22>
    // cprintf("copied over: %s [pid: %d, priority: %d, ticks: %d], inuse? %d\n", p->name, pinfo->pid[idx], pinfo->priority[idx], pinfo->inuse[idx], pinfo->ticks[idx]);
  }
  release(&ptable.lock);
80104a7c:	83 ec 0c             	sub    $0xc,%esp
80104a7f:	68 60 2d 11 80       	push   $0x80112d60
80104a84:	e8 22 09 00 00       	call   801053ab <release>
80104a89:	83 c4 10             	add    $0x10,%esp
}
80104a8c:	90                   	nop
80104a8d:	c9                   	leave  
80104a8e:	c3                   	ret    

80104a8f <scheduler>:
//   - choose a process to run
//   - swtch to start running that process
//   - eventually that process transfers control
//       via swtch back to the scheduler.
void scheduler(void)
{
80104a8f:	55                   	push   %ebp
80104a90:	89 e5                	mov    %esp,%ebp
80104a92:	81 ec 28 01 00 00    	sub    $0x128,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104a98:	e8 c2 f7 ff ff       	call   8010425f <mycpu>
80104a9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  c->proc = 0;
80104aa0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104aa3:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104aaa:	00 00 00 

  struct proc *pq[NPROC];
  int pq_size = 0;
80104aad:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  int highest_priority = 2147483647;
80104ab4:	c7 45 f0 ff ff ff 7f 	movl   $0x7fffffff,-0x10(%ebp)

  for (;;)
  {
    if(ticks%10==0) {
80104abb:	8b 0d d4 59 11 80    	mov    0x801159d4,%ecx
80104ac1:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
80104ac6:	89 c8                	mov    %ecx,%eax
80104ac8:	f7 e2                	mul    %edx
80104aca:	c1 ea 03             	shr    $0x3,%edx
80104acd:	89 d0                	mov    %edx,%eax
80104acf:	c1 e0 02             	shl    $0x2,%eax
80104ad2:	01 d0                	add    %edx,%eax
80104ad4:	01 c0                	add    %eax,%eax
80104ad6:	29 c1                	sub    %eax,%ecx
80104ad8:	89 ca                	mov    %ecx,%edx
80104ada:	85 d2                	test   %edx,%edx
80104adc:	75 6f                	jne    80104b4d <scheduler+0xbe>
      cprintf("%d,", ticks);
80104ade:	a1 d4 59 11 80       	mov    0x801159d4,%eax
80104ae3:	83 ec 08             	sub    $0x8,%esp
80104ae6:	50                   	push   %eax
80104ae7:	68 27 8b 10 80       	push   $0x80108b27
80104aec:	e8 0f b9 ff ff       	call   80100400 <cprintf>
80104af1:	83 c4 10             	add    $0x10,%esp
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104af4:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
80104afb:	eb 37                	jmp    80104b34 <scheduler+0xa5>
         if(p->state == RUNNABLE || p->state == SLEEPING) cprintf("%d,", p->ticks);
80104afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b00:	8b 40 0c             	mov    0xc(%eax),%eax
80104b03:	83 f8 03             	cmp    $0x3,%eax
80104b06:	74 0b                	je     80104b13 <scheduler+0x84>
80104b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0b:	8b 40 0c             	mov    0xc(%eax),%eax
80104b0e:	83 f8 02             	cmp    $0x2,%eax
80104b11:	75 1a                	jne    80104b2d <scheduler+0x9e>
80104b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b16:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80104b1c:	83 ec 08             	sub    $0x8,%esp
80104b1f:	50                   	push   %eax
80104b20:	68 27 8b 10 80       	push   $0x80108b27
80104b25:	e8 d6 b8 ff ff       	call   80100400 <cprintf>
80104b2a:	83 c4 10             	add    $0x10,%esp
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104b2d:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104b34:	81 7d f4 94 51 11 80 	cmpl   $0x80115194,-0xc(%ebp)
80104b3b:	72 c0                	jb     80104afd <scheduler+0x6e>
      }
      cprintf("\n");
80104b3d:	83 ec 0c             	sub    $0xc,%esp
80104b40:	68 2b 8b 10 80       	push   $0x80108b2b
80104b45:	e8 b6 b8 ff ff       	call   80100400 <cprintf>
80104b4a:	83 c4 10             	add    $0x10,%esp
    }

    // Enable interrupts on this processor.
    sti();
80104b4d:	e8 cd f6 ff ff       	call   8010421f <sti>

    // recalculate procs priorities every 100 ticks
    if (ticks % 100 == 0)
80104b52:	8b 0d d4 59 11 80    	mov    0x801159d4,%ecx
80104b58:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
80104b5d:	89 c8                	mov    %ecx,%eax
80104b5f:	f7 e2                	mul    %edx
80104b61:	89 d0                	mov    %edx,%eax
80104b63:	c1 e8 05             	shr    $0x5,%eax
80104b66:	6b d0 64             	imul   $0x64,%eax,%edx
80104b69:	89 c8                	mov    %ecx,%eax
80104b6b:	29 d0                	sub    %edx,%eax
80104b6d:	85 c0                	test   %eax,%eax
80104b6f:	0f 85 c7 00 00 00    	jne    80104c3c <scheduler+0x1ad>
    {
      acquire(&ptable.lock);
80104b75:	83 ec 0c             	sub    $0xc,%esp
80104b78:	68 60 2d 11 80       	push   $0x80112d60
80104b7d:	e8 bb 07 00 00       	call   8010533d <acquire>
80104b82:	83 c4 10             	add    $0x10,%esp

      highest_priority = 2147483647;
80104b85:	c7 45 f0 ff ff ff 7f 	movl   $0x7fffffff,-0x10(%ebp)
      // Iterate over process table to recalculate each processes' priority
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b8c:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
80104b93:	e9 87 00 00 00       	jmp    80104c1f <scheduler+0x190>
      {
        // don't check null or non-runnable procs
        if (p->pid != 0)
80104b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b9b:	8b 40 10             	mov    0x10(%eax),%eax
80104b9e:	85 c0                	test   %eax,%eax
80104ba0:	74 76                	je     80104c18 <scheduler+0x189>
        {
          if(p->priority!=1) {
80104ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba5:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104bab:	83 f8 01             	cmp    $0x1,%eax
80104bae:	74 43                	je     80104bf3 <scheduler+0x164>
            // recalculate priority
          p->cpu = decay(p->cpu);
80104bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb3:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104bb9:	83 ec 0c             	sub    $0xc,%esp
80104bbc:	50                   	push   %eax
80104bbd:	e8 d6 fd ff ff       	call   80104998 <decay>
80104bc2:	83 c4 10             	add    $0x10,%esp
80104bc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bc8:	89 82 80 00 00 00    	mov    %eax,0x80(%edx)
          p->priority = (p->cpu / 2) + p->nice;
80104bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd1:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104bd7:	89 c2                	mov    %eax,%edx
80104bd9:	c1 ea 1f             	shr    $0x1f,%edx
80104bdc:	01 d0                	add    %edx,%eax
80104bde:	d1 f8                	sar    %eax
80104be0:	89 c2                	mov    %eax,%edx
80104be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be5:	8b 40 7c             	mov    0x7c(%eax),%eax
80104be8:	01 c2                	add    %eax,%edx
80104bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bed:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
          }
          // cprintf("100 ticks, %s pid: %d, priority: %d\n", p->name, p->pid, p->priority);

          // find highest (lowest value) priority
          if (p->state == RUNNABLE && p->priority < highest_priority)
80104bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf6:	8b 40 0c             	mov    0xc(%eax),%eax
80104bf9:	83 f8 03             	cmp    $0x3,%eax
80104bfc:	75 1a                	jne    80104c18 <scheduler+0x189>
80104bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c01:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104c07:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104c0a:	7e 0c                	jle    80104c18 <scheduler+0x189>
          {
            highest_priority = p->priority;
80104c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c0f:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104c15:	89 45 f0             	mov    %eax,-0x10(%ebp)
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c18:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104c1f:	81 7d f4 94 51 11 80 	cmpl   $0x80115194,-0xc(%ebp)
80104c26:	0f 82 6c ff ff ff    	jb     80104b98 <scheduler+0x109>
            // cprintf("100 ticks, highest priority: %d\n", highest_priority);
          }
        }
      }
      release(&ptable.lock);
80104c2c:	83 ec 0c             	sub    $0xc,%esp
80104c2f:	68 60 2d 11 80       	push   $0x80112d60
80104c34:	e8 72 07 00 00       	call   801053ab <release>
80104c39:	83 c4 10             	add    $0x10,%esp
    }

    acquire(&ptable.lock);
80104c3c:	83 ec 0c             	sub    $0xc,%esp
80104c3f:	68 60 2d 11 80       	push   $0x80112d60
80104c44:	e8 f4 06 00 00       	call   8010533d <acquire>
80104c49:	83 c4 10             	add    $0x10,%esp

    int idx = 0;
80104c4c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    // Iterate over process table again to collect process(es) of highest priority
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c53:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
80104c5a:	eb 30                	jmp    80104c8c <scheduler+0x1fd>
    {
      // don't check null or non-runnable procs
      if (p->pid != 0)
80104c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c5f:	8b 40 10             	mov    0x10(%eax),%eax
80104c62:	85 c0                	test   %eax,%eax
80104c64:	74 1f                	je     80104c85 <scheduler+0x1f6>
      {
        // find highest (lowest value) priority process based on identified highest priority
        if (p->priority == highest_priority)
80104c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c69:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104c6f:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104c72:	75 11                	jne    80104c85 <scheduler+0x1f6>
        {
          pq[idx] = p;
80104c74:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c77:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c7a:	89 94 85 d8 fe ff ff 	mov    %edx,-0x128(%ebp,%eax,4)
          idx += 1;
80104c81:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c85:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104c8c:	81 7d f4 94 51 11 80 	cmpl   $0x80115194,-0xc(%ebp)
80104c93:	72 c7                	jb     80104c5c <scheduler+0x1cd>
        }
      }
    }
    pq_size = idx;
80104c95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c98:	89 45 e0             	mov    %eax,-0x20(%ebp)
     
          
    // iterate over the priority array of highest priority proc(s)
    for (int i = 0; i < pq_size; i++) {
80104c9b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80104ca2:	eb 11                	jmp    80104cb5 <scheduler+0x226>
      p = pq[i];
80104ca4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104ca7:	8b 84 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%eax
80104cae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (int i = 0; i < pq_size; i++) {
80104cb1:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80104cb5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104cb8:	3b 45 e0             	cmp    -0x20(%ebp),%eax
80104cbb:	7c e7                	jl     80104ca4 <scheduler+0x215>
    }
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cbd:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
80104cc4:	e9 ab 00 00 00       	jmp    80104d74 <scheduler+0x2e5>
    {
    //  p = pq[i];
      
      if (p->state != RUNNABLE)
80104cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ccc:	8b 40 0c             	mov    0xc(%eax),%eax
80104ccf:	83 f8 03             	cmp    $0x3,%eax
80104cd2:	0f 85 94 00 00 00    	jne    80104d6c <scheduler+0x2dd>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104cd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cdb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cde:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104ce4:	83 ec 0c             	sub    $0xc,%esp
80104ce7:	ff 75 f4             	push   -0xc(%ebp)
80104cea:	e8 1d 33 00 00       	call   8010800c <switchuvm>
80104cef:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf5:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      // cprintf("about to run: %s [pid: %d, priority: %d, ticks: %d]\n", p->name, p->pid, p->priority, p->ticks);
      int ticks0 = ticks;
80104cfc:	a1 d4 59 11 80       	mov    0x801159d4,%eax
80104d01:	89 45 dc             	mov    %eax,-0x24(%ebp)
      swtch(&(c->scheduler), p->context);
80104d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d07:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d0a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d0d:	83 c2 04             	add    $0x4,%edx
80104d10:	83 ec 08             	sub    $0x8,%esp
80104d13:	50                   	push   %eax
80104d14:	52                   	push   %edx
80104d15:	e8 1e 0b 00 00       	call   80105838 <swtch>
80104d1a:	83 c4 10             	add    $0x10,%esp
      int duration = ticks - ticks0;
80104d1d:	a1 d4 59 11 80       	mov    0x801159d4,%eax
80104d22:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104d25:	29 d0                	sub    %edx,%eax
80104d27:	89 45 d8             	mov    %eax,-0x28(%ebp)
      p->cpu += duration;
80104d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2d:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104d33:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104d36:	01 c2                	add    %eax,%edx
80104d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d3b:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
      p->ticks += duration;
80104d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d44:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80104d4a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104d4d:	01 c2                	add    %eax,%edx
80104d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d52:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
      switchkvm();
80104d58:	e8 96 32 00 00       	call   80107ff3 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104d5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d60:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104d67:	00 00 00 
80104d6a:	eb 01                	jmp    80104d6d <scheduler+0x2de>
        continue;
80104d6c:	90                   	nop
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104d6d:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104d74:	81 7d f4 94 51 11 80 	cmpl   $0x80115194,-0xc(%ebp)
80104d7b:	0f 82 48 ff ff ff    	jb     80104cc9 <scheduler+0x23a>
    }
    
    release(&ptable.lock);
80104d81:	83 ec 0c             	sub    $0xc,%esp
80104d84:	68 60 2d 11 80       	push   $0x80112d60
80104d89:	e8 1d 06 00 00       	call   801053ab <release>
80104d8e:	83 c4 10             	add    $0x10,%esp
  {
80104d91:	e9 25 fd ff ff       	jmp    80104abb <scheduler+0x2c>

80104d96 <sched>:
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void sched(void)
{
80104d96:	55                   	push   %ebp
80104d97:	89 e5                	mov    %esp,%ebp
80104d99:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104d9c:	e8 36 f5 ff ff       	call   801042d7 <myproc>
80104da1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if (!holding(&ptable.lock))
80104da4:	83 ec 0c             	sub    $0xc,%esp
80104da7:	68 60 2d 11 80       	push   $0x80112d60
80104dac:	e8 c7 06 00 00       	call   80105478 <holding>
80104db1:	83 c4 10             	add    $0x10,%esp
80104db4:	85 c0                	test   %eax,%eax
80104db6:	75 0d                	jne    80104dc5 <sched+0x2f>
    panic("sched ptable.lock");
80104db8:	83 ec 0c             	sub    $0xc,%esp
80104dbb:	68 2d 8b 10 80       	push   $0x80108b2d
80104dc0:	e8 f0 b7 ff ff       	call   801005b5 <panic>
  if (mycpu()->ncli != 1)
80104dc5:	e8 95 f4 ff ff       	call   8010425f <mycpu>
80104dca:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104dd0:	83 f8 01             	cmp    $0x1,%eax
80104dd3:	74 0d                	je     80104de2 <sched+0x4c>
    panic("sched locks");
80104dd5:	83 ec 0c             	sub    $0xc,%esp
80104dd8:	68 3f 8b 10 80       	push   $0x80108b3f
80104ddd:	e8 d3 b7 ff ff       	call   801005b5 <panic>
  if (p->state == RUNNING)
80104de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de5:	8b 40 0c             	mov    0xc(%eax),%eax
80104de8:	83 f8 04             	cmp    $0x4,%eax
80104deb:	75 0d                	jne    80104dfa <sched+0x64>
    panic("sched running");
80104ded:	83 ec 0c             	sub    $0xc,%esp
80104df0:	68 4b 8b 10 80       	push   $0x80108b4b
80104df5:	e8 bb b7 ff ff       	call   801005b5 <panic>
  if (readeflags() & FL_IF)
80104dfa:	e8 10 f4 ff ff       	call   8010420f <readeflags>
80104dff:	25 00 02 00 00       	and    $0x200,%eax
80104e04:	85 c0                	test   %eax,%eax
80104e06:	74 0d                	je     80104e15 <sched+0x7f>
    panic("sched interruptible");
80104e08:	83 ec 0c             	sub    $0xc,%esp
80104e0b:	68 59 8b 10 80       	push   $0x80108b59
80104e10:	e8 a0 b7 ff ff       	call   801005b5 <panic>
  intena = mycpu()->intena;
80104e15:	e8 45 f4 ff ff       	call   8010425f <mycpu>
80104e1a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104e20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104e23:	e8 37 f4 ff ff       	call   8010425f <mycpu>
80104e28:	8b 40 04             	mov    0x4(%eax),%eax
80104e2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e2e:	83 c2 1c             	add    $0x1c,%edx
80104e31:	83 ec 08             	sub    $0x8,%esp
80104e34:	50                   	push   %eax
80104e35:	52                   	push   %edx
80104e36:	e8 fd 09 00 00       	call   80105838 <swtch>
80104e3b:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104e3e:	e8 1c f4 ff ff       	call   8010425f <mycpu>
80104e43:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e46:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104e4c:	90                   	nop
80104e4d:	c9                   	leave  
80104e4e:	c3                   	ret    

80104e4f <yield>:

// Give up the CPU for one scheduling round.
void yield(void)
{
80104e4f:	55                   	push   %ebp
80104e50:	89 e5                	mov    %esp,%ebp
80104e52:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock); // DOC: yieldlock
80104e55:	83 ec 0c             	sub    $0xc,%esp
80104e58:	68 60 2d 11 80       	push   $0x80112d60
80104e5d:	e8 db 04 00 00       	call   8010533d <acquire>
80104e62:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104e65:	e8 6d f4 ff ff       	call   801042d7 <myproc>
80104e6a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  // myproc()->cpu += 1;
  // myproc()->ticks += 1;
  sched();
80104e71:	e8 20 ff ff ff       	call   80104d96 <sched>
  release(&ptable.lock);
80104e76:	83 ec 0c             	sub    $0xc,%esp
80104e79:	68 60 2d 11 80       	push   $0x80112d60
80104e7e:	e8 28 05 00 00       	call   801053ab <release>
80104e83:	83 c4 10             	add    $0x10,%esp
}
80104e86:	90                   	nop
80104e87:	c9                   	leave  
80104e88:	c3                   	ret    

80104e89 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void forkret(void)
{
80104e89:	55                   	push   %ebp
80104e8a:	89 e5                	mov    %esp,%ebp
80104e8c:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e8f:	83 ec 0c             	sub    $0xc,%esp
80104e92:	68 60 2d 11 80       	push   $0x80112d60
80104e97:	e8 0f 05 00 00       	call   801053ab <release>
80104e9c:	83 c4 10             	add    $0x10,%esp

  if (first)
80104e9f:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104ea4:	85 c0                	test   %eax,%eax
80104ea6:	74 24                	je     80104ecc <forkret+0x43>
  {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104ea8:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
80104eaf:	00 00 00 
    iinit(ROOTDEV);
80104eb2:	83 ec 0c             	sub    $0xc,%esp
80104eb5:	6a 01                	push   $0x1
80104eb7:	e8 2a c8 ff ff       	call   801016e6 <iinit>
80104ebc:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104ebf:	83 ec 0c             	sub    $0xc,%esp
80104ec2:	6a 01                	push   $0x1
80104ec4:	e8 88 e4 ff ff       	call   80103351 <initlog>
80104ec9:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104ecc:	90                   	nop
80104ecd:	c9                   	leave  
80104ece:	c3                   	ret    

80104ecf <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
80104ecf:	55                   	push   %ebp
80104ed0:	89 e5                	mov    %esp,%ebp
80104ed2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104ed5:	e8 fd f3 ff ff       	call   801042d7 <myproc>
80104eda:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if (p == 0)
80104edd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ee1:	75 0d                	jne    80104ef0 <sleep+0x21>
    panic("sleep");
80104ee3:	83 ec 0c             	sub    $0xc,%esp
80104ee6:	68 6d 8b 10 80       	push   $0x80108b6d
80104eeb:	e8 c5 b6 ff ff       	call   801005b5 <panic>

  if (lk == 0)
80104ef0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104ef4:	75 0d                	jne    80104f03 <sleep+0x34>
    panic("sleep without lk");
80104ef6:	83 ec 0c             	sub    $0xc,%esp
80104ef9:	68 73 8b 10 80       	push   $0x80108b73
80104efe:	e8 b2 b6 ff ff       	call   801005b5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if (lk != &ptable.lock)
80104f03:	81 7d 0c 60 2d 11 80 	cmpl   $0x80112d60,0xc(%ebp)
80104f0a:	74 1e                	je     80104f2a <sleep+0x5b>
  {                        // DOC: sleeplock0
    acquire(&ptable.lock); // DOC: sleeplock1
80104f0c:	83 ec 0c             	sub    $0xc,%esp
80104f0f:	68 60 2d 11 80       	push   $0x80112d60
80104f14:	e8 24 04 00 00       	call   8010533d <acquire>
80104f19:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104f1c:	83 ec 0c             	sub    $0xc,%esp
80104f1f:	ff 75 0c             	push   0xc(%ebp)
80104f22:	e8 84 04 00 00       	call   801053ab <release>
80104f27:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f2d:	8b 55 08             	mov    0x8(%ebp),%edx
80104f30:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104f33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f36:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104f3d:	e8 54 fe ff ff       	call   80104d96 <sched>

  // Tidy up.
  p->chan = 0;
80104f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f45:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if (lk != &ptable.lock)
80104f4c:	81 7d 0c 60 2d 11 80 	cmpl   $0x80112d60,0xc(%ebp)
80104f53:	74 1e                	je     80104f73 <sleep+0xa4>
  { // DOC: sleeplock2
    release(&ptable.lock);
80104f55:	83 ec 0c             	sub    $0xc,%esp
80104f58:	68 60 2d 11 80       	push   $0x80112d60
80104f5d:	e8 49 04 00 00       	call   801053ab <release>
80104f62:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104f65:	83 ec 0c             	sub    $0xc,%esp
80104f68:	ff 75 0c             	push   0xc(%ebp)
80104f6b:	e8 cd 03 00 00       	call   8010533d <acquire>
80104f70:	83 c4 10             	add    $0x10,%esp
  }
}
80104f73:	90                   	nop
80104f74:	c9                   	leave  
80104f75:	c3                   	ret    

80104f76 <wakeup1>:
// PAGEBREAK!
//  Wake up all processes sleeping on chan.
//  The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104f76:	55                   	push   %ebp
80104f77:	89 e5                	mov    %esp,%ebp
80104f79:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f7c:	c7 45 fc 94 2d 11 80 	movl   $0x80112d94,-0x4(%ebp)
80104f83:	eb 4b                	jmp    80104fd0 <wakeup1+0x5a>
  {
    if (p->sleep_ticks > 0) {
80104f85:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f88:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104f8e:	85 c0                	test   %eax,%eax
80104f90:	7e 17                	jle    80104fa9 <wakeup1+0x33>
      // cprintf("process is still sleeping: %s [pid: %d, priority: %d, ticks: %d\n", p->name, p->pid, p->priority, p->ticks);
      p->sleep_ticks -= 1;
80104f92:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f95:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104f9b:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fa1:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
80104fa7:	eb 20                	jmp    80104fc9 <wakeup1+0x53>
    }
    else if (p->state == SLEEPING && p->chan == chan) {
80104fa9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fac:	8b 40 0c             	mov    0xc(%eax),%eax
80104faf:	83 f8 02             	cmp    $0x2,%eax
80104fb2:	75 15                	jne    80104fc9 <wakeup1+0x53>
80104fb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fb7:	8b 40 20             	mov    0x20(%eax),%eax
80104fba:	39 45 08             	cmp    %eax,0x8(%ebp)
80104fbd:	75 0a                	jne    80104fc9 <wakeup1+0x53>
      // only if the process has finished all its intended sleep ticks, wake it
      p->state = RUNNABLE;
80104fbf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fc2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fc9:	81 45 fc 90 00 00 00 	addl   $0x90,-0x4(%ebp)
80104fd0:	81 7d fc 94 51 11 80 	cmpl   $0x80115194,-0x4(%ebp)
80104fd7:	72 ac                	jb     80104f85 <wakeup1+0xf>
    }
  }
}
80104fd9:	90                   	nop
80104fda:	90                   	nop
80104fdb:	c9                   	leave  
80104fdc:	c3                   	ret    

80104fdd <wakeup>:

// Wake up all processes sleeping on chan.
void wakeup(void *chan)
{
80104fdd:	55                   	push   %ebp
80104fde:	89 e5                	mov    %esp,%ebp
80104fe0:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104fe3:	83 ec 0c             	sub    $0xc,%esp
80104fe6:	68 60 2d 11 80       	push   $0x80112d60
80104feb:	e8 4d 03 00 00       	call   8010533d <acquire>
80104ff0:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104ff3:	83 ec 0c             	sub    $0xc,%esp
80104ff6:	ff 75 08             	push   0x8(%ebp)
80104ff9:	e8 78 ff ff ff       	call   80104f76 <wakeup1>
80104ffe:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105001:	83 ec 0c             	sub    $0xc,%esp
80105004:	68 60 2d 11 80       	push   $0x80112d60
80105009:	e8 9d 03 00 00       	call   801053ab <release>
8010500e:	83 c4 10             	add    $0x10,%esp
}
80105011:	90                   	nop
80105012:	c9                   	leave  
80105013:	c3                   	ret    

80105014 <kill>:

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int kill(int pid)
{
80105014:	55                   	push   %ebp
80105015:	89 e5                	mov    %esp,%ebp
80105017:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010501a:	83 ec 0c             	sub    $0xc,%esp
8010501d:	68 60 2d 11 80       	push   $0x80112d60
80105022:	e8 16 03 00 00       	call   8010533d <acquire>
80105027:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010502a:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
80105031:	eb 48                	jmp    8010507b <kill+0x67>
  {
    if (p->pid == pid)
80105033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105036:	8b 40 10             	mov    0x10(%eax),%eax
80105039:	39 45 08             	cmp    %eax,0x8(%ebp)
8010503c:	75 36                	jne    80105074 <kill+0x60>
    {
      p->killed = 1;
8010503e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105041:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if (p->state == SLEEPING)
80105048:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010504b:	8b 40 0c             	mov    0xc(%eax),%eax
8010504e:	83 f8 02             	cmp    $0x2,%eax
80105051:	75 0a                	jne    8010505d <kill+0x49>
        p->state = RUNNABLE;
80105053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105056:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010505d:	83 ec 0c             	sub    $0xc,%esp
80105060:	68 60 2d 11 80       	push   $0x80112d60
80105065:	e8 41 03 00 00       	call   801053ab <release>
8010506a:	83 c4 10             	add    $0x10,%esp
      return 0;
8010506d:	b8 00 00 00 00       	mov    $0x0,%eax
80105072:	eb 25                	jmp    80105099 <kill+0x85>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105074:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010507b:	81 7d f4 94 51 11 80 	cmpl   $0x80115194,-0xc(%ebp)
80105082:	72 af                	jb     80105033 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80105084:	83 ec 0c             	sub    $0xc,%esp
80105087:	68 60 2d 11 80       	push   $0x80112d60
8010508c:	e8 1a 03 00 00       	call   801053ab <release>
80105091:	83 c4 10             	add    $0x10,%esp
  return -1;
80105094:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105099:	c9                   	leave  
8010509a:	c3                   	ret    

8010509b <procdump>:
// PAGEBREAK: 36
//  Print a process listing to console.  For debugging.
//  Runs when user types ^P on console.
//  No lock to avoid wedging a stuck machine further.
void procdump(void)
{
8010509b:	55                   	push   %ebp
8010509c:	89 e5                	mov    %esp,%ebp
8010509e:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801050a1:	c7 45 f0 94 2d 11 80 	movl   $0x80112d94,-0x10(%ebp)
801050a8:	e9 da 00 00 00       	jmp    80105187 <procdump+0xec>
  {
    if (p->state == UNUSED)
801050ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050b0:	8b 40 0c             	mov    0xc(%eax),%eax
801050b3:	85 c0                	test   %eax,%eax
801050b5:	0f 84 c4 00 00 00    	je     8010517f <procdump+0xe4>
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
801050bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050be:	8b 40 0c             	mov    0xc(%eax),%eax
801050c1:	83 f8 05             	cmp    $0x5,%eax
801050c4:	77 23                	ja     801050e9 <procdump+0x4e>
801050c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050c9:	8b 40 0c             	mov    0xc(%eax),%eax
801050cc:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
801050d3:	85 c0                	test   %eax,%eax
801050d5:	74 12                	je     801050e9 <procdump+0x4e>
      state = states[p->state];
801050d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050da:	8b 40 0c             	mov    0xc(%eax),%eax
801050dd:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
801050e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801050e7:	eb 07                	jmp    801050f0 <procdump+0x55>
    else
      state = "???";
801050e9:	c7 45 ec 84 8b 10 80 	movl   $0x80108b84,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801050f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050f3:	8d 50 6c             	lea    0x6c(%eax),%edx
801050f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050f9:	8b 40 10             	mov    0x10(%eax),%eax
801050fc:	52                   	push   %edx
801050fd:	ff 75 ec             	push   -0x14(%ebp)
80105100:	50                   	push   %eax
80105101:	68 88 8b 10 80       	push   $0x80108b88
80105106:	e8 f5 b2 ff ff       	call   80100400 <cprintf>
8010510b:	83 c4 10             	add    $0x10,%esp
    if (p->state == SLEEPING)
8010510e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105111:	8b 40 0c             	mov    0xc(%eax),%eax
80105114:	83 f8 02             	cmp    $0x2,%eax
80105117:	75 54                	jne    8010516d <procdump+0xd2>
    {
      getcallerpcs((uint *)p->context->ebp + 2, pc);
80105119:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010511c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010511f:	8b 40 0c             	mov    0xc(%eax),%eax
80105122:	83 c0 08             	add    $0x8,%eax
80105125:	89 c2                	mov    %eax,%edx
80105127:	83 ec 08             	sub    $0x8,%esp
8010512a:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010512d:	50                   	push   %eax
8010512e:	52                   	push   %edx
8010512f:	e8 c9 02 00 00       	call   801053fd <getcallerpcs>
80105134:	83 c4 10             	add    $0x10,%esp
      for (i = 0; i < 10 && pc[i] != 0; i++)
80105137:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010513e:	eb 1c                	jmp    8010515c <procdump+0xc1>
        cprintf(" %p", pc[i]);
80105140:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105143:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105147:	83 ec 08             	sub    $0x8,%esp
8010514a:	50                   	push   %eax
8010514b:	68 91 8b 10 80       	push   $0x80108b91
80105150:	e8 ab b2 ff ff       	call   80100400 <cprintf>
80105155:	83 c4 10             	add    $0x10,%esp
      for (i = 0; i < 10 && pc[i] != 0; i++)
80105158:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010515c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105160:	7f 0b                	jg     8010516d <procdump+0xd2>
80105162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105165:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105169:	85 c0                	test   %eax,%eax
8010516b:	75 d3                	jne    80105140 <procdump+0xa5>
    }
    cprintf("\n");
8010516d:	83 ec 0c             	sub    $0xc,%esp
80105170:	68 2b 8b 10 80       	push   $0x80108b2b
80105175:	e8 86 b2 ff ff       	call   80100400 <cprintf>
8010517a:	83 c4 10             	add    $0x10,%esp
8010517d:	eb 01                	jmp    80105180 <procdump+0xe5>
      continue;
8010517f:	90                   	nop
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105180:	81 45 f0 90 00 00 00 	addl   $0x90,-0x10(%ebp)
80105187:	81 7d f0 94 51 11 80 	cmpl   $0x80115194,-0x10(%ebp)
8010518e:	0f 82 19 ff ff ff    	jb     801050ad <procdump+0x12>
  }
}
80105194:	90                   	nop
80105195:	90                   	nop
80105196:	c9                   	leave  
80105197:	c3                   	ret    

80105198 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105198:	55                   	push   %ebp
80105199:	89 e5                	mov    %esp,%ebp
8010519b:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
8010519e:	8b 45 08             	mov    0x8(%ebp),%eax
801051a1:	83 c0 04             	add    $0x4,%eax
801051a4:	83 ec 08             	sub    $0x8,%esp
801051a7:	68 bf 8b 10 80       	push   $0x80108bbf
801051ac:	50                   	push   %eax
801051ad:	e8 69 01 00 00       	call   8010531b <initlock>
801051b2:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801051b5:	8b 45 08             	mov    0x8(%ebp),%eax
801051b8:	8b 55 0c             	mov    0xc(%ebp),%edx
801051bb:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801051be:	8b 45 08             	mov    0x8(%ebp),%eax
801051c1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801051c7:	8b 45 08             	mov    0x8(%ebp),%eax
801051ca:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801051d1:	90                   	nop
801051d2:	c9                   	leave  
801051d3:	c3                   	ret    

801051d4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801051d4:	55                   	push   %ebp
801051d5:	89 e5                	mov    %esp,%ebp
801051d7:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801051da:	8b 45 08             	mov    0x8(%ebp),%eax
801051dd:	83 c0 04             	add    $0x4,%eax
801051e0:	83 ec 0c             	sub    $0xc,%esp
801051e3:	50                   	push   %eax
801051e4:	e8 54 01 00 00       	call   8010533d <acquire>
801051e9:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801051ec:	eb 15                	jmp    80105203 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
801051ee:	8b 45 08             	mov    0x8(%ebp),%eax
801051f1:	83 c0 04             	add    $0x4,%eax
801051f4:	83 ec 08             	sub    $0x8,%esp
801051f7:	50                   	push   %eax
801051f8:	ff 75 08             	push   0x8(%ebp)
801051fb:	e8 cf fc ff ff       	call   80104ecf <sleep>
80105200:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105203:	8b 45 08             	mov    0x8(%ebp),%eax
80105206:	8b 00                	mov    (%eax),%eax
80105208:	85 c0                	test   %eax,%eax
8010520a:	75 e2                	jne    801051ee <acquiresleep+0x1a>
  }
  lk->locked = 1;
8010520c:	8b 45 08             	mov    0x8(%ebp),%eax
8010520f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80105215:	e8 bd f0 ff ff       	call   801042d7 <myproc>
8010521a:	8b 50 10             	mov    0x10(%eax),%edx
8010521d:	8b 45 08             	mov    0x8(%ebp),%eax
80105220:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105223:	8b 45 08             	mov    0x8(%ebp),%eax
80105226:	83 c0 04             	add    $0x4,%eax
80105229:	83 ec 0c             	sub    $0xc,%esp
8010522c:	50                   	push   %eax
8010522d:	e8 79 01 00 00       	call   801053ab <release>
80105232:	83 c4 10             	add    $0x10,%esp
}
80105235:	90                   	nop
80105236:	c9                   	leave  
80105237:	c3                   	ret    

80105238 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105238:	55                   	push   %ebp
80105239:	89 e5                	mov    %esp,%ebp
8010523b:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010523e:	8b 45 08             	mov    0x8(%ebp),%eax
80105241:	83 c0 04             	add    $0x4,%eax
80105244:	83 ec 0c             	sub    $0xc,%esp
80105247:	50                   	push   %eax
80105248:	e8 f0 00 00 00       	call   8010533d <acquire>
8010524d:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80105250:	8b 45 08             	mov    0x8(%ebp),%eax
80105253:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105259:	8b 45 08             	mov    0x8(%ebp),%eax
8010525c:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105263:	83 ec 0c             	sub    $0xc,%esp
80105266:	ff 75 08             	push   0x8(%ebp)
80105269:	e8 6f fd ff ff       	call   80104fdd <wakeup>
8010526e:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80105271:	8b 45 08             	mov    0x8(%ebp),%eax
80105274:	83 c0 04             	add    $0x4,%eax
80105277:	83 ec 0c             	sub    $0xc,%esp
8010527a:	50                   	push   %eax
8010527b:	e8 2b 01 00 00       	call   801053ab <release>
80105280:	83 c4 10             	add    $0x10,%esp
}
80105283:	90                   	nop
80105284:	c9                   	leave  
80105285:	c3                   	ret    

80105286 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105286:	55                   	push   %ebp
80105287:	89 e5                	mov    %esp,%ebp
80105289:	53                   	push   %ebx
8010528a:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
8010528d:	8b 45 08             	mov    0x8(%ebp),%eax
80105290:	83 c0 04             	add    $0x4,%eax
80105293:	83 ec 0c             	sub    $0xc,%esp
80105296:	50                   	push   %eax
80105297:	e8 a1 00 00 00       	call   8010533d <acquire>
8010529c:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
8010529f:	8b 45 08             	mov    0x8(%ebp),%eax
801052a2:	8b 00                	mov    (%eax),%eax
801052a4:	85 c0                	test   %eax,%eax
801052a6:	74 19                	je     801052c1 <holdingsleep+0x3b>
801052a8:	8b 45 08             	mov    0x8(%ebp),%eax
801052ab:	8b 58 3c             	mov    0x3c(%eax),%ebx
801052ae:	e8 24 f0 ff ff       	call   801042d7 <myproc>
801052b3:	8b 40 10             	mov    0x10(%eax),%eax
801052b6:	39 c3                	cmp    %eax,%ebx
801052b8:	75 07                	jne    801052c1 <holdingsleep+0x3b>
801052ba:	b8 01 00 00 00       	mov    $0x1,%eax
801052bf:	eb 05                	jmp    801052c6 <holdingsleep+0x40>
801052c1:	b8 00 00 00 00       	mov    $0x0,%eax
801052c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801052c9:	8b 45 08             	mov    0x8(%ebp),%eax
801052cc:	83 c0 04             	add    $0x4,%eax
801052cf:	83 ec 0c             	sub    $0xc,%esp
801052d2:	50                   	push   %eax
801052d3:	e8 d3 00 00 00       	call   801053ab <release>
801052d8:	83 c4 10             	add    $0x10,%esp
  return r;
801052db:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801052de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052e1:	c9                   	leave  
801052e2:	c3                   	ret    

801052e3 <readeflags>:
{
801052e3:	55                   	push   %ebp
801052e4:	89 e5                	mov    %esp,%ebp
801052e6:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801052e9:	9c                   	pushf  
801052ea:	58                   	pop    %eax
801052eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801052ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052f1:	c9                   	leave  
801052f2:	c3                   	ret    

801052f3 <cli>:
{
801052f3:	55                   	push   %ebp
801052f4:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801052f6:	fa                   	cli    
}
801052f7:	90                   	nop
801052f8:	5d                   	pop    %ebp
801052f9:	c3                   	ret    

801052fa <sti>:
{
801052fa:	55                   	push   %ebp
801052fb:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801052fd:	fb                   	sti    
}
801052fe:	90                   	nop
801052ff:	5d                   	pop    %ebp
80105300:	c3                   	ret    

80105301 <xchg>:
{
80105301:	55                   	push   %ebp
80105302:	89 e5                	mov    %esp,%ebp
80105304:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80105307:	8b 55 08             	mov    0x8(%ebp),%edx
8010530a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010530d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105310:	f0 87 02             	lock xchg %eax,(%edx)
80105313:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80105316:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105319:	c9                   	leave  
8010531a:	c3                   	ret    

8010531b <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010531b:	55                   	push   %ebp
8010531c:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010531e:	8b 45 08             	mov    0x8(%ebp),%eax
80105321:	8b 55 0c             	mov    0xc(%ebp),%edx
80105324:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105327:	8b 45 08             	mov    0x8(%ebp),%eax
8010532a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105330:	8b 45 08             	mov    0x8(%ebp),%eax
80105333:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010533a:	90                   	nop
8010533b:	5d                   	pop    %ebp
8010533c:	c3                   	ret    

8010533d <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010533d:	55                   	push   %ebp
8010533e:	89 e5                	mov    %esp,%ebp
80105340:	53                   	push   %ebx
80105341:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105344:	e8 6f 01 00 00       	call   801054b8 <pushcli>
  if(holding(lk))
80105349:	8b 45 08             	mov    0x8(%ebp),%eax
8010534c:	83 ec 0c             	sub    $0xc,%esp
8010534f:	50                   	push   %eax
80105350:	e8 23 01 00 00       	call   80105478 <holding>
80105355:	83 c4 10             	add    $0x10,%esp
80105358:	85 c0                	test   %eax,%eax
8010535a:	74 0d                	je     80105369 <acquire+0x2c>
    panic("acquire");
8010535c:	83 ec 0c             	sub    $0xc,%esp
8010535f:	68 ca 8b 10 80       	push   $0x80108bca
80105364:	e8 4c b2 ff ff       	call   801005b5 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105369:	90                   	nop
8010536a:	8b 45 08             	mov    0x8(%ebp),%eax
8010536d:	83 ec 08             	sub    $0x8,%esp
80105370:	6a 01                	push   $0x1
80105372:	50                   	push   %eax
80105373:	e8 89 ff ff ff       	call   80105301 <xchg>
80105378:	83 c4 10             	add    $0x10,%esp
8010537b:	85 c0                	test   %eax,%eax
8010537d:	75 eb                	jne    8010536a <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010537f:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105384:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105387:	e8 d3 ee ff ff       	call   8010425f <mycpu>
8010538c:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010538f:	8b 45 08             	mov    0x8(%ebp),%eax
80105392:	83 c0 0c             	add    $0xc,%eax
80105395:	83 ec 08             	sub    $0x8,%esp
80105398:	50                   	push   %eax
80105399:	8d 45 08             	lea    0x8(%ebp),%eax
8010539c:	50                   	push   %eax
8010539d:	e8 5b 00 00 00       	call   801053fd <getcallerpcs>
801053a2:	83 c4 10             	add    $0x10,%esp
}
801053a5:	90                   	nop
801053a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801053a9:	c9                   	leave  
801053aa:	c3                   	ret    

801053ab <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801053ab:	55                   	push   %ebp
801053ac:	89 e5                	mov    %esp,%ebp
801053ae:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801053b1:	83 ec 0c             	sub    $0xc,%esp
801053b4:	ff 75 08             	push   0x8(%ebp)
801053b7:	e8 bc 00 00 00       	call   80105478 <holding>
801053bc:	83 c4 10             	add    $0x10,%esp
801053bf:	85 c0                	test   %eax,%eax
801053c1:	75 0d                	jne    801053d0 <release+0x25>
    panic("release");
801053c3:	83 ec 0c             	sub    $0xc,%esp
801053c6:	68 d2 8b 10 80       	push   $0x80108bd2
801053cb:	e8 e5 b1 ff ff       	call   801005b5 <panic>

  lk->pcs[0] = 0;
801053d0:	8b 45 08             	mov    0x8(%ebp),%eax
801053d3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801053da:	8b 45 08             	mov    0x8(%ebp),%eax
801053dd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801053e4:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801053e9:	8b 45 08             	mov    0x8(%ebp),%eax
801053ec:	8b 55 08             	mov    0x8(%ebp),%edx
801053ef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801053f5:	e8 0b 01 00 00       	call   80105505 <popcli>
}
801053fa:	90                   	nop
801053fb:	c9                   	leave  
801053fc:	c3                   	ret    

801053fd <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801053fd:	55                   	push   %ebp
801053fe:	89 e5                	mov    %esp,%ebp
80105400:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105403:	8b 45 08             	mov    0x8(%ebp),%eax
80105406:	83 e8 08             	sub    $0x8,%eax
80105409:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010540c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105413:	eb 38                	jmp    8010544d <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105415:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105419:	74 53                	je     8010546e <getcallerpcs+0x71>
8010541b:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105422:	76 4a                	jbe    8010546e <getcallerpcs+0x71>
80105424:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105428:	74 44                	je     8010546e <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010542a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010542d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105434:	8b 45 0c             	mov    0xc(%ebp),%eax
80105437:	01 c2                	add    %eax,%edx
80105439:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010543c:	8b 40 04             	mov    0x4(%eax),%eax
8010543f:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105441:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105444:	8b 00                	mov    (%eax),%eax
80105446:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105449:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010544d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105451:	7e c2                	jle    80105415 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80105453:	eb 19                	jmp    8010546e <getcallerpcs+0x71>
    pcs[i] = 0;
80105455:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105458:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010545f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105462:	01 d0                	add    %edx,%eax
80105464:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010546a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010546e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105472:	7e e1                	jle    80105455 <getcallerpcs+0x58>
}
80105474:	90                   	nop
80105475:	90                   	nop
80105476:	c9                   	leave  
80105477:	c3                   	ret    

80105478 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105478:	55                   	push   %ebp
80105479:	89 e5                	mov    %esp,%ebp
8010547b:	53                   	push   %ebx
8010547c:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
8010547f:	e8 34 00 00 00       	call   801054b8 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80105484:	8b 45 08             	mov    0x8(%ebp),%eax
80105487:	8b 00                	mov    (%eax),%eax
80105489:	85 c0                	test   %eax,%eax
8010548b:	74 16                	je     801054a3 <holding+0x2b>
8010548d:	8b 45 08             	mov    0x8(%ebp),%eax
80105490:	8b 58 08             	mov    0x8(%eax),%ebx
80105493:	e8 c7 ed ff ff       	call   8010425f <mycpu>
80105498:	39 c3                	cmp    %eax,%ebx
8010549a:	75 07                	jne    801054a3 <holding+0x2b>
8010549c:	b8 01 00 00 00       	mov    $0x1,%eax
801054a1:	eb 05                	jmp    801054a8 <holding+0x30>
801054a3:	b8 00 00 00 00       	mov    $0x0,%eax
801054a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
801054ab:	e8 55 00 00 00       	call   80105505 <popcli>
  return r;
801054b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801054b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801054b6:	c9                   	leave  
801054b7:	c3                   	ret    

801054b8 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801054b8:	55                   	push   %ebp
801054b9:	89 e5                	mov    %esp,%ebp
801054bb:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801054be:	e8 20 fe ff ff       	call   801052e3 <readeflags>
801054c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801054c6:	e8 28 fe ff ff       	call   801052f3 <cli>
  if(mycpu()->ncli == 0)
801054cb:	e8 8f ed ff ff       	call   8010425f <mycpu>
801054d0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801054d6:	85 c0                	test   %eax,%eax
801054d8:	75 14                	jne    801054ee <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801054da:	e8 80 ed ff ff       	call   8010425f <mycpu>
801054df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054e2:	81 e2 00 02 00 00    	and    $0x200,%edx
801054e8:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801054ee:	e8 6c ed ff ff       	call   8010425f <mycpu>
801054f3:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801054f9:	83 c2 01             	add    $0x1,%edx
801054fc:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105502:	90                   	nop
80105503:	c9                   	leave  
80105504:	c3                   	ret    

80105505 <popcli>:

void
popcli(void)
{
80105505:	55                   	push   %ebp
80105506:	89 e5                	mov    %esp,%ebp
80105508:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010550b:	e8 d3 fd ff ff       	call   801052e3 <readeflags>
80105510:	25 00 02 00 00       	and    $0x200,%eax
80105515:	85 c0                	test   %eax,%eax
80105517:	74 0d                	je     80105526 <popcli+0x21>
    panic("popcli - interruptible");
80105519:	83 ec 0c             	sub    $0xc,%esp
8010551c:	68 da 8b 10 80       	push   $0x80108bda
80105521:	e8 8f b0 ff ff       	call   801005b5 <panic>
  if(--mycpu()->ncli < 0)
80105526:	e8 34 ed ff ff       	call   8010425f <mycpu>
8010552b:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105531:	83 ea 01             	sub    $0x1,%edx
80105534:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010553a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105540:	85 c0                	test   %eax,%eax
80105542:	79 0d                	jns    80105551 <popcli+0x4c>
    panic("popcli");
80105544:	83 ec 0c             	sub    $0xc,%esp
80105547:	68 f1 8b 10 80       	push   $0x80108bf1
8010554c:	e8 64 b0 ff ff       	call   801005b5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105551:	e8 09 ed ff ff       	call   8010425f <mycpu>
80105556:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010555c:	85 c0                	test   %eax,%eax
8010555e:	75 14                	jne    80105574 <popcli+0x6f>
80105560:	e8 fa ec ff ff       	call   8010425f <mycpu>
80105565:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010556b:	85 c0                	test   %eax,%eax
8010556d:	74 05                	je     80105574 <popcli+0x6f>
    sti();
8010556f:	e8 86 fd ff ff       	call   801052fa <sti>
}
80105574:	90                   	nop
80105575:	c9                   	leave  
80105576:	c3                   	ret    

80105577 <stosb>:
{
80105577:	55                   	push   %ebp
80105578:	89 e5                	mov    %esp,%ebp
8010557a:	57                   	push   %edi
8010557b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010557c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010557f:	8b 55 10             	mov    0x10(%ebp),%edx
80105582:	8b 45 0c             	mov    0xc(%ebp),%eax
80105585:	89 cb                	mov    %ecx,%ebx
80105587:	89 df                	mov    %ebx,%edi
80105589:	89 d1                	mov    %edx,%ecx
8010558b:	fc                   	cld    
8010558c:	f3 aa                	rep stos %al,%es:(%edi)
8010558e:	89 ca                	mov    %ecx,%edx
80105590:	89 fb                	mov    %edi,%ebx
80105592:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105595:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105598:	90                   	nop
80105599:	5b                   	pop    %ebx
8010559a:	5f                   	pop    %edi
8010559b:	5d                   	pop    %ebp
8010559c:	c3                   	ret    

8010559d <stosl>:
{
8010559d:	55                   	push   %ebp
8010559e:	89 e5                	mov    %esp,%ebp
801055a0:	57                   	push   %edi
801055a1:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801055a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
801055a5:	8b 55 10             	mov    0x10(%ebp),%edx
801055a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ab:	89 cb                	mov    %ecx,%ebx
801055ad:	89 df                	mov    %ebx,%edi
801055af:	89 d1                	mov    %edx,%ecx
801055b1:	fc                   	cld    
801055b2:	f3 ab                	rep stos %eax,%es:(%edi)
801055b4:	89 ca                	mov    %ecx,%edx
801055b6:	89 fb                	mov    %edi,%ebx
801055b8:	89 5d 08             	mov    %ebx,0x8(%ebp)
801055bb:	89 55 10             	mov    %edx,0x10(%ebp)
}
801055be:	90                   	nop
801055bf:	5b                   	pop    %ebx
801055c0:	5f                   	pop    %edi
801055c1:	5d                   	pop    %ebp
801055c2:	c3                   	ret    

801055c3 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801055c3:	55                   	push   %ebp
801055c4:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801055c6:	8b 45 08             	mov    0x8(%ebp),%eax
801055c9:	83 e0 03             	and    $0x3,%eax
801055cc:	85 c0                	test   %eax,%eax
801055ce:	75 43                	jne    80105613 <memset+0x50>
801055d0:	8b 45 10             	mov    0x10(%ebp),%eax
801055d3:	83 e0 03             	and    $0x3,%eax
801055d6:	85 c0                	test   %eax,%eax
801055d8:	75 39                	jne    80105613 <memset+0x50>
    c &= 0xFF;
801055da:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801055e1:	8b 45 10             	mov    0x10(%ebp),%eax
801055e4:	c1 e8 02             	shr    $0x2,%eax
801055e7:	89 c2                	mov    %eax,%edx
801055e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ec:	c1 e0 18             	shl    $0x18,%eax
801055ef:	89 c1                	mov    %eax,%ecx
801055f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f4:	c1 e0 10             	shl    $0x10,%eax
801055f7:	09 c1                	or     %eax,%ecx
801055f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801055fc:	c1 e0 08             	shl    $0x8,%eax
801055ff:	09 c8                	or     %ecx,%eax
80105601:	0b 45 0c             	or     0xc(%ebp),%eax
80105604:	52                   	push   %edx
80105605:	50                   	push   %eax
80105606:	ff 75 08             	push   0x8(%ebp)
80105609:	e8 8f ff ff ff       	call   8010559d <stosl>
8010560e:	83 c4 0c             	add    $0xc,%esp
80105611:	eb 12                	jmp    80105625 <memset+0x62>
  } else
    stosb(dst, c, n);
80105613:	8b 45 10             	mov    0x10(%ebp),%eax
80105616:	50                   	push   %eax
80105617:	ff 75 0c             	push   0xc(%ebp)
8010561a:	ff 75 08             	push   0x8(%ebp)
8010561d:	e8 55 ff ff ff       	call   80105577 <stosb>
80105622:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105625:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105628:	c9                   	leave  
80105629:	c3                   	ret    

8010562a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010562a:	55                   	push   %ebp
8010562b:	89 e5                	mov    %esp,%ebp
8010562d:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105630:	8b 45 08             	mov    0x8(%ebp),%eax
80105633:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105636:	8b 45 0c             	mov    0xc(%ebp),%eax
80105639:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010563c:	eb 30                	jmp    8010566e <memcmp+0x44>
    if(*s1 != *s2)
8010563e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105641:	0f b6 10             	movzbl (%eax),%edx
80105644:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105647:	0f b6 00             	movzbl (%eax),%eax
8010564a:	38 c2                	cmp    %al,%dl
8010564c:	74 18                	je     80105666 <memcmp+0x3c>
      return *s1 - *s2;
8010564e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105651:	0f b6 00             	movzbl (%eax),%eax
80105654:	0f b6 d0             	movzbl %al,%edx
80105657:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010565a:	0f b6 00             	movzbl (%eax),%eax
8010565d:	0f b6 c8             	movzbl %al,%ecx
80105660:	89 d0                	mov    %edx,%eax
80105662:	29 c8                	sub    %ecx,%eax
80105664:	eb 1a                	jmp    80105680 <memcmp+0x56>
    s1++, s2++;
80105666:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010566a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
8010566e:	8b 45 10             	mov    0x10(%ebp),%eax
80105671:	8d 50 ff             	lea    -0x1(%eax),%edx
80105674:	89 55 10             	mov    %edx,0x10(%ebp)
80105677:	85 c0                	test   %eax,%eax
80105679:	75 c3                	jne    8010563e <memcmp+0x14>
  }

  return 0;
8010567b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105680:	c9                   	leave  
80105681:	c3                   	ret    

80105682 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105682:	55                   	push   %ebp
80105683:	89 e5                	mov    %esp,%ebp
80105685:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105688:	8b 45 0c             	mov    0xc(%ebp),%eax
8010568b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010568e:	8b 45 08             	mov    0x8(%ebp),%eax
80105691:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105694:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105697:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010569a:	73 54                	jae    801056f0 <memmove+0x6e>
8010569c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010569f:	8b 45 10             	mov    0x10(%ebp),%eax
801056a2:	01 d0                	add    %edx,%eax
801056a4:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801056a7:	73 47                	jae    801056f0 <memmove+0x6e>
    s += n;
801056a9:	8b 45 10             	mov    0x10(%ebp),%eax
801056ac:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801056af:	8b 45 10             	mov    0x10(%ebp),%eax
801056b2:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801056b5:	eb 13                	jmp    801056ca <memmove+0x48>
      *--d = *--s;
801056b7:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801056bb:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801056bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056c2:	0f b6 10             	movzbl (%eax),%edx
801056c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056c8:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801056ca:	8b 45 10             	mov    0x10(%ebp),%eax
801056cd:	8d 50 ff             	lea    -0x1(%eax),%edx
801056d0:	89 55 10             	mov    %edx,0x10(%ebp)
801056d3:	85 c0                	test   %eax,%eax
801056d5:	75 e0                	jne    801056b7 <memmove+0x35>
  if(s < d && s + n > d){
801056d7:	eb 24                	jmp    801056fd <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
801056d9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056dc:	8d 42 01             	lea    0x1(%edx),%eax
801056df:	89 45 fc             	mov    %eax,-0x4(%ebp)
801056e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056e5:	8d 48 01             	lea    0x1(%eax),%ecx
801056e8:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801056eb:	0f b6 12             	movzbl (%edx),%edx
801056ee:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801056f0:	8b 45 10             	mov    0x10(%ebp),%eax
801056f3:	8d 50 ff             	lea    -0x1(%eax),%edx
801056f6:	89 55 10             	mov    %edx,0x10(%ebp)
801056f9:	85 c0                	test   %eax,%eax
801056fb:	75 dc                	jne    801056d9 <memmove+0x57>

  return dst;
801056fd:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105700:	c9                   	leave  
80105701:	c3                   	ret    

80105702 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105702:	55                   	push   %ebp
80105703:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105705:	ff 75 10             	push   0x10(%ebp)
80105708:	ff 75 0c             	push   0xc(%ebp)
8010570b:	ff 75 08             	push   0x8(%ebp)
8010570e:	e8 6f ff ff ff       	call   80105682 <memmove>
80105713:	83 c4 0c             	add    $0xc,%esp
}
80105716:	c9                   	leave  
80105717:	c3                   	ret    

80105718 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105718:	55                   	push   %ebp
80105719:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010571b:	eb 0c                	jmp    80105729 <strncmp+0x11>
    n--, p++, q++;
8010571d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105721:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105725:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105729:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010572d:	74 1a                	je     80105749 <strncmp+0x31>
8010572f:	8b 45 08             	mov    0x8(%ebp),%eax
80105732:	0f b6 00             	movzbl (%eax),%eax
80105735:	84 c0                	test   %al,%al
80105737:	74 10                	je     80105749 <strncmp+0x31>
80105739:	8b 45 08             	mov    0x8(%ebp),%eax
8010573c:	0f b6 10             	movzbl (%eax),%edx
8010573f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105742:	0f b6 00             	movzbl (%eax),%eax
80105745:	38 c2                	cmp    %al,%dl
80105747:	74 d4                	je     8010571d <strncmp+0x5>
  if(n == 0)
80105749:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010574d:	75 07                	jne    80105756 <strncmp+0x3e>
    return 0;
8010574f:	b8 00 00 00 00       	mov    $0x0,%eax
80105754:	eb 16                	jmp    8010576c <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105756:	8b 45 08             	mov    0x8(%ebp),%eax
80105759:	0f b6 00             	movzbl (%eax),%eax
8010575c:	0f b6 d0             	movzbl %al,%edx
8010575f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105762:	0f b6 00             	movzbl (%eax),%eax
80105765:	0f b6 c8             	movzbl %al,%ecx
80105768:	89 d0                	mov    %edx,%eax
8010576a:	29 c8                	sub    %ecx,%eax
}
8010576c:	5d                   	pop    %ebp
8010576d:	c3                   	ret    

8010576e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010576e:	55                   	push   %ebp
8010576f:	89 e5                	mov    %esp,%ebp
80105771:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105774:	8b 45 08             	mov    0x8(%ebp),%eax
80105777:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010577a:	90                   	nop
8010577b:	8b 45 10             	mov    0x10(%ebp),%eax
8010577e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105781:	89 55 10             	mov    %edx,0x10(%ebp)
80105784:	85 c0                	test   %eax,%eax
80105786:	7e 2c                	jle    801057b4 <strncpy+0x46>
80105788:	8b 55 0c             	mov    0xc(%ebp),%edx
8010578b:	8d 42 01             	lea    0x1(%edx),%eax
8010578e:	89 45 0c             	mov    %eax,0xc(%ebp)
80105791:	8b 45 08             	mov    0x8(%ebp),%eax
80105794:	8d 48 01             	lea    0x1(%eax),%ecx
80105797:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010579a:	0f b6 12             	movzbl (%edx),%edx
8010579d:	88 10                	mov    %dl,(%eax)
8010579f:	0f b6 00             	movzbl (%eax),%eax
801057a2:	84 c0                	test   %al,%al
801057a4:	75 d5                	jne    8010577b <strncpy+0xd>
    ;
  while(n-- > 0)
801057a6:	eb 0c                	jmp    801057b4 <strncpy+0x46>
    *s++ = 0;
801057a8:	8b 45 08             	mov    0x8(%ebp),%eax
801057ab:	8d 50 01             	lea    0x1(%eax),%edx
801057ae:	89 55 08             	mov    %edx,0x8(%ebp)
801057b1:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801057b4:	8b 45 10             	mov    0x10(%ebp),%eax
801057b7:	8d 50 ff             	lea    -0x1(%eax),%edx
801057ba:	89 55 10             	mov    %edx,0x10(%ebp)
801057bd:	85 c0                	test   %eax,%eax
801057bf:	7f e7                	jg     801057a8 <strncpy+0x3a>
  return os;
801057c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057c4:	c9                   	leave  
801057c5:	c3                   	ret    

801057c6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801057c6:	55                   	push   %ebp
801057c7:	89 e5                	mov    %esp,%ebp
801057c9:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801057cc:	8b 45 08             	mov    0x8(%ebp),%eax
801057cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801057d2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057d6:	7f 05                	jg     801057dd <safestrcpy+0x17>
    return os;
801057d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057db:	eb 32                	jmp    8010580f <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
801057dd:	90                   	nop
801057de:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801057e2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057e6:	7e 1e                	jle    80105806 <safestrcpy+0x40>
801057e8:	8b 55 0c             	mov    0xc(%ebp),%edx
801057eb:	8d 42 01             	lea    0x1(%edx),%eax
801057ee:	89 45 0c             	mov    %eax,0xc(%ebp)
801057f1:	8b 45 08             	mov    0x8(%ebp),%eax
801057f4:	8d 48 01             	lea    0x1(%eax),%ecx
801057f7:	89 4d 08             	mov    %ecx,0x8(%ebp)
801057fa:	0f b6 12             	movzbl (%edx),%edx
801057fd:	88 10                	mov    %dl,(%eax)
801057ff:	0f b6 00             	movzbl (%eax),%eax
80105802:	84 c0                	test   %al,%al
80105804:	75 d8                	jne    801057de <safestrcpy+0x18>
    ;
  *s = 0;
80105806:	8b 45 08             	mov    0x8(%ebp),%eax
80105809:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010580c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010580f:	c9                   	leave  
80105810:	c3                   	ret    

80105811 <strlen>:

int
strlen(const char *s)
{
80105811:	55                   	push   %ebp
80105812:	89 e5                	mov    %esp,%ebp
80105814:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105817:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010581e:	eb 04                	jmp    80105824 <strlen+0x13>
80105820:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105824:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105827:	8b 45 08             	mov    0x8(%ebp),%eax
8010582a:	01 d0                	add    %edx,%eax
8010582c:	0f b6 00             	movzbl (%eax),%eax
8010582f:	84 c0                	test   %al,%al
80105831:	75 ed                	jne    80105820 <strlen+0xf>
    ;
  return n;
80105833:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105836:	c9                   	leave  
80105837:	c3                   	ret    

80105838 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105838:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010583c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80105840:	55                   	push   %ebp
  pushl %ebx
80105841:	53                   	push   %ebx
  pushl %esi
80105842:	56                   	push   %esi
  pushl %edi
80105843:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105844:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105846:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80105848:	5f                   	pop    %edi
  popl %esi
80105849:	5e                   	pop    %esi
  popl %ebx
8010584a:	5b                   	pop    %ebx
  popl %ebp
8010584b:	5d                   	pop    %ebp
  ret
8010584c:	c3                   	ret    

8010584d <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010584d:	55                   	push   %ebp
8010584e:	89 e5                	mov    %esp,%ebp
80105850:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105853:	e8 7f ea ff ff       	call   801042d7 <myproc>
80105858:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010585b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010585e:	8b 00                	mov    (%eax),%eax
80105860:	39 45 08             	cmp    %eax,0x8(%ebp)
80105863:	73 0f                	jae    80105874 <fetchint+0x27>
80105865:	8b 45 08             	mov    0x8(%ebp),%eax
80105868:	8d 50 04             	lea    0x4(%eax),%edx
8010586b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010586e:	8b 00                	mov    (%eax),%eax
80105870:	39 c2                	cmp    %eax,%edx
80105872:	76 07                	jbe    8010587b <fetchint+0x2e>
    return -1;
80105874:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105879:	eb 0f                	jmp    8010588a <fetchint+0x3d>
  *ip = *(int*)(addr);
8010587b:	8b 45 08             	mov    0x8(%ebp),%eax
8010587e:	8b 10                	mov    (%eax),%edx
80105880:	8b 45 0c             	mov    0xc(%ebp),%eax
80105883:	89 10                	mov    %edx,(%eax)
  return 0;
80105885:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010588a:	c9                   	leave  
8010588b:	c3                   	ret    

8010588c <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010588c:	55                   	push   %ebp
8010588d:	89 e5                	mov    %esp,%ebp
8010588f:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105892:	e8 40 ea ff ff       	call   801042d7 <myproc>
80105897:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010589a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010589d:	8b 00                	mov    (%eax),%eax
8010589f:	39 45 08             	cmp    %eax,0x8(%ebp)
801058a2:	72 07                	jb     801058ab <fetchstr+0x1f>
    return -1;
801058a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058a9:	eb 41                	jmp    801058ec <fetchstr+0x60>
  *pp = (char*)addr;
801058ab:	8b 55 08             	mov    0x8(%ebp),%edx
801058ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801058b1:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801058b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b6:	8b 00                	mov    (%eax),%eax
801058b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801058bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801058be:	8b 00                	mov    (%eax),%eax
801058c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058c3:	eb 1a                	jmp    801058df <fetchstr+0x53>
    if(*s == 0)
801058c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c8:	0f b6 00             	movzbl (%eax),%eax
801058cb:	84 c0                	test   %al,%al
801058cd:	75 0c                	jne    801058db <fetchstr+0x4f>
      return s - *pp;
801058cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801058d2:	8b 10                	mov    (%eax),%edx
801058d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d7:	29 d0                	sub    %edx,%eax
801058d9:	eb 11                	jmp    801058ec <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
801058db:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801058df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801058e5:	72 de                	jb     801058c5 <fetchstr+0x39>
  }
  return -1;
801058e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058ec:	c9                   	leave  
801058ed:	c3                   	ret    

801058ee <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801058ee:	55                   	push   %ebp
801058ef:	89 e5                	mov    %esp,%ebp
801058f1:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801058f4:	e8 de e9 ff ff       	call   801042d7 <myproc>
801058f9:	8b 40 18             	mov    0x18(%eax),%eax
801058fc:	8b 50 44             	mov    0x44(%eax),%edx
801058ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105902:	c1 e0 02             	shl    $0x2,%eax
80105905:	01 d0                	add    %edx,%eax
80105907:	83 c0 04             	add    $0x4,%eax
8010590a:	83 ec 08             	sub    $0x8,%esp
8010590d:	ff 75 0c             	push   0xc(%ebp)
80105910:	50                   	push   %eax
80105911:	e8 37 ff ff ff       	call   8010584d <fetchint>
80105916:	83 c4 10             	add    $0x10,%esp
}
80105919:	c9                   	leave  
8010591a:	c3                   	ret    

8010591b <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010591b:	55                   	push   %ebp
8010591c:	89 e5                	mov    %esp,%ebp
8010591e:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105921:	e8 b1 e9 ff ff       	call   801042d7 <myproc>
80105926:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105929:	83 ec 08             	sub    $0x8,%esp
8010592c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010592f:	50                   	push   %eax
80105930:	ff 75 08             	push   0x8(%ebp)
80105933:	e8 b6 ff ff ff       	call   801058ee <argint>
80105938:	83 c4 10             	add    $0x10,%esp
8010593b:	85 c0                	test   %eax,%eax
8010593d:	79 07                	jns    80105946 <argptr+0x2b>
    return -1;
8010593f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105944:	eb 3b                	jmp    80105981 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105946:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010594a:	78 1f                	js     8010596b <argptr+0x50>
8010594c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594f:	8b 00                	mov    (%eax),%eax
80105951:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105954:	39 d0                	cmp    %edx,%eax
80105956:	76 13                	jbe    8010596b <argptr+0x50>
80105958:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010595b:	89 c2                	mov    %eax,%edx
8010595d:	8b 45 10             	mov    0x10(%ebp),%eax
80105960:	01 c2                	add    %eax,%edx
80105962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105965:	8b 00                	mov    (%eax),%eax
80105967:	39 c2                	cmp    %eax,%edx
80105969:	76 07                	jbe    80105972 <argptr+0x57>
    return -1;
8010596b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105970:	eb 0f                	jmp    80105981 <argptr+0x66>
  *pp = (char*)i;
80105972:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105975:	89 c2                	mov    %eax,%edx
80105977:	8b 45 0c             	mov    0xc(%ebp),%eax
8010597a:	89 10                	mov    %edx,(%eax)
  return 0;
8010597c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105981:	c9                   	leave  
80105982:	c3                   	ret    

80105983 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105983:	55                   	push   %ebp
80105984:	89 e5                	mov    %esp,%ebp
80105986:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105989:	83 ec 08             	sub    $0x8,%esp
8010598c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010598f:	50                   	push   %eax
80105990:	ff 75 08             	push   0x8(%ebp)
80105993:	e8 56 ff ff ff       	call   801058ee <argint>
80105998:	83 c4 10             	add    $0x10,%esp
8010599b:	85 c0                	test   %eax,%eax
8010599d:	79 07                	jns    801059a6 <argstr+0x23>
    return -1;
8010599f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059a4:	eb 12                	jmp    801059b8 <argstr+0x35>
  return fetchstr(addr, pp);
801059a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a9:	83 ec 08             	sub    $0x8,%esp
801059ac:	ff 75 0c             	push   0xc(%ebp)
801059af:	50                   	push   %eax
801059b0:	e8 d7 fe ff ff       	call   8010588c <fetchstr>
801059b5:	83 c4 10             	add    $0x10,%esp
}
801059b8:	c9                   	leave  
801059b9:	c3                   	ret    

801059ba <syscall>:
[SYS_getschedstate] sys_getschedstate,
};

void
syscall(void)
{
801059ba:	55                   	push   %ebp
801059bb:	89 e5                	mov    %esp,%ebp
801059bd:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801059c0:	e8 12 e9 ff ff       	call   801042d7 <myproc>
801059c5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801059c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059cb:	8b 40 18             	mov    0x18(%eax),%eax
801059ce:	8b 40 1c             	mov    0x1c(%eax),%eax
801059d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801059d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059d8:	7e 2f                	jle    80105a09 <syscall+0x4f>
801059da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059dd:	83 f8 17             	cmp    $0x17,%eax
801059e0:	77 27                	ja     80105a09 <syscall+0x4f>
801059e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e5:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
801059ec:	85 c0                	test   %eax,%eax
801059ee:	74 19                	je     80105a09 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
801059f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f3:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
801059fa:	ff d0                	call   *%eax
801059fc:	89 c2                	mov    %eax,%edx
801059fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a01:	8b 40 18             	mov    0x18(%eax),%eax
80105a04:	89 50 1c             	mov    %edx,0x1c(%eax)
80105a07:	eb 2c                	jmp    80105a35 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a0c:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a12:	8b 40 10             	mov    0x10(%eax),%eax
80105a15:	ff 75 f0             	push   -0x10(%ebp)
80105a18:	52                   	push   %edx
80105a19:	50                   	push   %eax
80105a1a:	68 f8 8b 10 80       	push   $0x80108bf8
80105a1f:	e8 dc a9 ff ff       	call   80100400 <cprintf>
80105a24:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a2a:	8b 40 18             	mov    0x18(%eax),%eax
80105a2d:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105a34:	90                   	nop
80105a35:	90                   	nop
80105a36:	c9                   	leave  
80105a37:	c3                   	ret    

80105a38 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105a38:	55                   	push   %ebp
80105a39:	89 e5                	mov    %esp,%ebp
80105a3b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105a3e:	83 ec 08             	sub    $0x8,%esp
80105a41:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a44:	50                   	push   %eax
80105a45:	ff 75 08             	push   0x8(%ebp)
80105a48:	e8 a1 fe ff ff       	call   801058ee <argint>
80105a4d:	83 c4 10             	add    $0x10,%esp
80105a50:	85 c0                	test   %eax,%eax
80105a52:	79 07                	jns    80105a5b <argfd+0x23>
    return -1;
80105a54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a59:	eb 4f                	jmp    80105aaa <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105a5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a5e:	85 c0                	test   %eax,%eax
80105a60:	78 20                	js     80105a82 <argfd+0x4a>
80105a62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a65:	83 f8 0f             	cmp    $0xf,%eax
80105a68:	7f 18                	jg     80105a82 <argfd+0x4a>
80105a6a:	e8 68 e8 ff ff       	call   801042d7 <myproc>
80105a6f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a72:	83 c2 08             	add    $0x8,%edx
80105a75:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a79:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a7c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a80:	75 07                	jne    80105a89 <argfd+0x51>
    return -1;
80105a82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a87:	eb 21                	jmp    80105aaa <argfd+0x72>
  if(pfd)
80105a89:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105a8d:	74 08                	je     80105a97 <argfd+0x5f>
    *pfd = fd;
80105a8f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a92:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a95:	89 10                	mov    %edx,(%eax)
  if(pf)
80105a97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a9b:	74 08                	je     80105aa5 <argfd+0x6d>
    *pf = f;
80105a9d:	8b 45 10             	mov    0x10(%ebp),%eax
80105aa0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105aa3:	89 10                	mov    %edx,(%eax)
  return 0;
80105aa5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105aaa:	c9                   	leave  
80105aab:	c3                   	ret    

80105aac <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105aac:	55                   	push   %ebp
80105aad:	89 e5                	mov    %esp,%ebp
80105aaf:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105ab2:	e8 20 e8 ff ff       	call   801042d7 <myproc>
80105ab7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105aba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ac1:	eb 2a                	jmp    80105aed <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105ac3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ac6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ac9:	83 c2 08             	add    $0x8,%edx
80105acc:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105ad0:	85 c0                	test   %eax,%eax
80105ad2:	75 15                	jne    80105ae9 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105ad4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ada:	8d 4a 08             	lea    0x8(%edx),%ecx
80105add:	8b 55 08             	mov    0x8(%ebp),%edx
80105ae0:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae7:	eb 0f                	jmp    80105af8 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105ae9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105aed:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105af1:	7e d0                	jle    80105ac3 <fdalloc+0x17>
    }
  }
  return -1;
80105af3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105af8:	c9                   	leave  
80105af9:	c3                   	ret    

80105afa <sys_dup>:

int
sys_dup(void)
{
80105afa:	55                   	push   %ebp
80105afb:	89 e5                	mov    %esp,%ebp
80105afd:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105b00:	83 ec 04             	sub    $0x4,%esp
80105b03:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b06:	50                   	push   %eax
80105b07:	6a 00                	push   $0x0
80105b09:	6a 00                	push   $0x0
80105b0b:	e8 28 ff ff ff       	call   80105a38 <argfd>
80105b10:	83 c4 10             	add    $0x10,%esp
80105b13:	85 c0                	test   %eax,%eax
80105b15:	79 07                	jns    80105b1e <sys_dup+0x24>
    return -1;
80105b17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b1c:	eb 31                	jmp    80105b4f <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b21:	83 ec 0c             	sub    $0xc,%esp
80105b24:	50                   	push   %eax
80105b25:	e8 82 ff ff ff       	call   80105aac <fdalloc>
80105b2a:	83 c4 10             	add    $0x10,%esp
80105b2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b30:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b34:	79 07                	jns    80105b3d <sys_dup+0x43>
    return -1;
80105b36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b3b:	eb 12                	jmp    80105b4f <sys_dup+0x55>
  filedup(f);
80105b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b40:	83 ec 0c             	sub    $0xc,%esp
80105b43:	50                   	push   %eax
80105b44:	e8 82 b5 ff ff       	call   801010cb <filedup>
80105b49:	83 c4 10             	add    $0x10,%esp
  return fd;
80105b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b4f:	c9                   	leave  
80105b50:	c3                   	ret    

80105b51 <sys_read>:

int
sys_read(void)
{
80105b51:	55                   	push   %ebp
80105b52:	89 e5                	mov    %esp,%ebp
80105b54:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b57:	83 ec 04             	sub    $0x4,%esp
80105b5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b5d:	50                   	push   %eax
80105b5e:	6a 00                	push   $0x0
80105b60:	6a 00                	push   $0x0
80105b62:	e8 d1 fe ff ff       	call   80105a38 <argfd>
80105b67:	83 c4 10             	add    $0x10,%esp
80105b6a:	85 c0                	test   %eax,%eax
80105b6c:	78 2e                	js     80105b9c <sys_read+0x4b>
80105b6e:	83 ec 08             	sub    $0x8,%esp
80105b71:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b74:	50                   	push   %eax
80105b75:	6a 02                	push   $0x2
80105b77:	e8 72 fd ff ff       	call   801058ee <argint>
80105b7c:	83 c4 10             	add    $0x10,%esp
80105b7f:	85 c0                	test   %eax,%eax
80105b81:	78 19                	js     80105b9c <sys_read+0x4b>
80105b83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b86:	83 ec 04             	sub    $0x4,%esp
80105b89:	50                   	push   %eax
80105b8a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b8d:	50                   	push   %eax
80105b8e:	6a 01                	push   $0x1
80105b90:	e8 86 fd ff ff       	call   8010591b <argptr>
80105b95:	83 c4 10             	add    $0x10,%esp
80105b98:	85 c0                	test   %eax,%eax
80105b9a:	79 07                	jns    80105ba3 <sys_read+0x52>
    return -1;
80105b9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ba1:	eb 17                	jmp    80105bba <sys_read+0x69>
  return fileread(f, p, n);
80105ba3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105ba6:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bac:	83 ec 04             	sub    $0x4,%esp
80105baf:	51                   	push   %ecx
80105bb0:	52                   	push   %edx
80105bb1:	50                   	push   %eax
80105bb2:	e8 a4 b6 ff ff       	call   8010125b <fileread>
80105bb7:	83 c4 10             	add    $0x10,%esp
}
80105bba:	c9                   	leave  
80105bbb:	c3                   	ret    

80105bbc <sys_write>:

int
sys_write(void)
{
80105bbc:	55                   	push   %ebp
80105bbd:	89 e5                	mov    %esp,%ebp
80105bbf:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105bc2:	83 ec 04             	sub    $0x4,%esp
80105bc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bc8:	50                   	push   %eax
80105bc9:	6a 00                	push   $0x0
80105bcb:	6a 00                	push   $0x0
80105bcd:	e8 66 fe ff ff       	call   80105a38 <argfd>
80105bd2:	83 c4 10             	add    $0x10,%esp
80105bd5:	85 c0                	test   %eax,%eax
80105bd7:	78 2e                	js     80105c07 <sys_write+0x4b>
80105bd9:	83 ec 08             	sub    $0x8,%esp
80105bdc:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bdf:	50                   	push   %eax
80105be0:	6a 02                	push   $0x2
80105be2:	e8 07 fd ff ff       	call   801058ee <argint>
80105be7:	83 c4 10             	add    $0x10,%esp
80105bea:	85 c0                	test   %eax,%eax
80105bec:	78 19                	js     80105c07 <sys_write+0x4b>
80105bee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bf1:	83 ec 04             	sub    $0x4,%esp
80105bf4:	50                   	push   %eax
80105bf5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bf8:	50                   	push   %eax
80105bf9:	6a 01                	push   $0x1
80105bfb:	e8 1b fd ff ff       	call   8010591b <argptr>
80105c00:	83 c4 10             	add    $0x10,%esp
80105c03:	85 c0                	test   %eax,%eax
80105c05:	79 07                	jns    80105c0e <sys_write+0x52>
    return -1;
80105c07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c0c:	eb 17                	jmp    80105c25 <sys_write+0x69>
  return filewrite(f, p, n);
80105c0e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c11:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c17:	83 ec 04             	sub    $0x4,%esp
80105c1a:	51                   	push   %ecx
80105c1b:	52                   	push   %edx
80105c1c:	50                   	push   %eax
80105c1d:	e8 f1 b6 ff ff       	call   80101313 <filewrite>
80105c22:	83 c4 10             	add    $0x10,%esp
}
80105c25:	c9                   	leave  
80105c26:	c3                   	ret    

80105c27 <sys_close>:

int
sys_close(void)
{
80105c27:	55                   	push   %ebp
80105c28:	89 e5                	mov    %esp,%ebp
80105c2a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105c2d:	83 ec 04             	sub    $0x4,%esp
80105c30:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c33:	50                   	push   %eax
80105c34:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c37:	50                   	push   %eax
80105c38:	6a 00                	push   $0x0
80105c3a:	e8 f9 fd ff ff       	call   80105a38 <argfd>
80105c3f:	83 c4 10             	add    $0x10,%esp
80105c42:	85 c0                	test   %eax,%eax
80105c44:	79 07                	jns    80105c4d <sys_close+0x26>
    return -1;
80105c46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c4b:	eb 27                	jmp    80105c74 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105c4d:	e8 85 e6 ff ff       	call   801042d7 <myproc>
80105c52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c55:	83 c2 08             	add    $0x8,%edx
80105c58:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c5f:	00 
  fileclose(f);
80105c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c63:	83 ec 0c             	sub    $0xc,%esp
80105c66:	50                   	push   %eax
80105c67:	e8 b0 b4 ff ff       	call   8010111c <fileclose>
80105c6c:	83 c4 10             	add    $0x10,%esp
  return 0;
80105c6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c74:	c9                   	leave  
80105c75:	c3                   	ret    

80105c76 <sys_fstat>:

int
sys_fstat(void)
{
80105c76:	55                   	push   %ebp
80105c77:	89 e5                	mov    %esp,%ebp
80105c79:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105c7c:	83 ec 04             	sub    $0x4,%esp
80105c7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c82:	50                   	push   %eax
80105c83:	6a 00                	push   $0x0
80105c85:	6a 00                	push   $0x0
80105c87:	e8 ac fd ff ff       	call   80105a38 <argfd>
80105c8c:	83 c4 10             	add    $0x10,%esp
80105c8f:	85 c0                	test   %eax,%eax
80105c91:	78 17                	js     80105caa <sys_fstat+0x34>
80105c93:	83 ec 04             	sub    $0x4,%esp
80105c96:	6a 14                	push   $0x14
80105c98:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c9b:	50                   	push   %eax
80105c9c:	6a 01                	push   $0x1
80105c9e:	e8 78 fc ff ff       	call   8010591b <argptr>
80105ca3:	83 c4 10             	add    $0x10,%esp
80105ca6:	85 c0                	test   %eax,%eax
80105ca8:	79 07                	jns    80105cb1 <sys_fstat+0x3b>
    return -1;
80105caa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105caf:	eb 13                	jmp    80105cc4 <sys_fstat+0x4e>
  return filestat(f, st);
80105cb1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb7:	83 ec 08             	sub    $0x8,%esp
80105cba:	52                   	push   %edx
80105cbb:	50                   	push   %eax
80105cbc:	e8 43 b5 ff ff       	call   80101204 <filestat>
80105cc1:	83 c4 10             	add    $0x10,%esp
}
80105cc4:	c9                   	leave  
80105cc5:	c3                   	ret    

80105cc6 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105cc6:	55                   	push   %ebp
80105cc7:	89 e5                	mov    %esp,%ebp
80105cc9:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105ccc:	83 ec 08             	sub    $0x8,%esp
80105ccf:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105cd2:	50                   	push   %eax
80105cd3:	6a 00                	push   $0x0
80105cd5:	e8 a9 fc ff ff       	call   80105983 <argstr>
80105cda:	83 c4 10             	add    $0x10,%esp
80105cdd:	85 c0                	test   %eax,%eax
80105cdf:	78 15                	js     80105cf6 <sys_link+0x30>
80105ce1:	83 ec 08             	sub    $0x8,%esp
80105ce4:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105ce7:	50                   	push   %eax
80105ce8:	6a 01                	push   $0x1
80105cea:	e8 94 fc ff ff       	call   80105983 <argstr>
80105cef:	83 c4 10             	add    $0x10,%esp
80105cf2:	85 c0                	test   %eax,%eax
80105cf4:	79 0a                	jns    80105d00 <sys_link+0x3a>
    return -1;
80105cf6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cfb:	e9 68 01 00 00       	jmp    80105e68 <sys_link+0x1a2>

  begin_op();
80105d00:	e8 6b d8 ff ff       	call   80103570 <begin_op>
  if((ip = namei(old)) == 0){
80105d05:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105d08:	83 ec 0c             	sub    $0xc,%esp
80105d0b:	50                   	push   %eax
80105d0c:	e8 7a c8 ff ff       	call   8010258b <namei>
80105d11:	83 c4 10             	add    $0x10,%esp
80105d14:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d17:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d1b:	75 0f                	jne    80105d2c <sys_link+0x66>
    end_op();
80105d1d:	e8 da d8 ff ff       	call   801035fc <end_op>
    return -1;
80105d22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d27:	e9 3c 01 00 00       	jmp    80105e68 <sys_link+0x1a2>
  }

  ilock(ip);
80105d2c:	83 ec 0c             	sub    $0xc,%esp
80105d2f:	ff 75 f4             	push   -0xc(%ebp)
80105d32:	e8 21 bd ff ff       	call   80101a58 <ilock>
80105d37:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d3d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d41:	66 83 f8 01          	cmp    $0x1,%ax
80105d45:	75 1d                	jne    80105d64 <sys_link+0x9e>
    iunlockput(ip);
80105d47:	83 ec 0c             	sub    $0xc,%esp
80105d4a:	ff 75 f4             	push   -0xc(%ebp)
80105d4d:	e8 37 bf ff ff       	call   80101c89 <iunlockput>
80105d52:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d55:	e8 a2 d8 ff ff       	call   801035fc <end_op>
    return -1;
80105d5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d5f:	e9 04 01 00 00       	jmp    80105e68 <sys_link+0x1a2>
  }

  ip->nlink++;
80105d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d67:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d6b:	83 c0 01             	add    $0x1,%eax
80105d6e:	89 c2                	mov    %eax,%edx
80105d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d73:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d77:	83 ec 0c             	sub    $0xc,%esp
80105d7a:	ff 75 f4             	push   -0xc(%ebp)
80105d7d:	e8 f9 ba ff ff       	call   8010187b <iupdate>
80105d82:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105d85:	83 ec 0c             	sub    $0xc,%esp
80105d88:	ff 75 f4             	push   -0xc(%ebp)
80105d8b:	e8 db bd ff ff       	call   80101b6b <iunlock>
80105d90:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105d93:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105d96:	83 ec 08             	sub    $0x8,%esp
80105d99:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105d9c:	52                   	push   %edx
80105d9d:	50                   	push   %eax
80105d9e:	e8 04 c8 ff ff       	call   801025a7 <nameiparent>
80105da3:	83 c4 10             	add    $0x10,%esp
80105da6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105da9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dad:	74 71                	je     80105e20 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105daf:	83 ec 0c             	sub    $0xc,%esp
80105db2:	ff 75 f0             	push   -0x10(%ebp)
80105db5:	e8 9e bc ff ff       	call   80101a58 <ilock>
80105dba:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc0:	8b 10                	mov    (%eax),%edx
80105dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc5:	8b 00                	mov    (%eax),%eax
80105dc7:	39 c2                	cmp    %eax,%edx
80105dc9:	75 1d                	jne    80105de8 <sys_link+0x122>
80105dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dce:	8b 40 04             	mov    0x4(%eax),%eax
80105dd1:	83 ec 04             	sub    $0x4,%esp
80105dd4:	50                   	push   %eax
80105dd5:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105dd8:	50                   	push   %eax
80105dd9:	ff 75 f0             	push   -0x10(%ebp)
80105ddc:	e8 13 c5 ff ff       	call   801022f4 <dirlink>
80105de1:	83 c4 10             	add    $0x10,%esp
80105de4:	85 c0                	test   %eax,%eax
80105de6:	79 10                	jns    80105df8 <sys_link+0x132>
    iunlockput(dp);
80105de8:	83 ec 0c             	sub    $0xc,%esp
80105deb:	ff 75 f0             	push   -0x10(%ebp)
80105dee:	e8 96 be ff ff       	call   80101c89 <iunlockput>
80105df3:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105df6:	eb 29                	jmp    80105e21 <sys_link+0x15b>
  }
  iunlockput(dp);
80105df8:	83 ec 0c             	sub    $0xc,%esp
80105dfb:	ff 75 f0             	push   -0x10(%ebp)
80105dfe:	e8 86 be ff ff       	call   80101c89 <iunlockput>
80105e03:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105e06:	83 ec 0c             	sub    $0xc,%esp
80105e09:	ff 75 f4             	push   -0xc(%ebp)
80105e0c:	e8 a8 bd ff ff       	call   80101bb9 <iput>
80105e11:	83 c4 10             	add    $0x10,%esp

  end_op();
80105e14:	e8 e3 d7 ff ff       	call   801035fc <end_op>

  return 0;
80105e19:	b8 00 00 00 00       	mov    $0x0,%eax
80105e1e:	eb 48                	jmp    80105e68 <sys_link+0x1a2>
    goto bad;
80105e20:	90                   	nop

bad:
  ilock(ip);
80105e21:	83 ec 0c             	sub    $0xc,%esp
80105e24:	ff 75 f4             	push   -0xc(%ebp)
80105e27:	e8 2c bc ff ff       	call   80101a58 <ilock>
80105e2c:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e32:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e36:	83 e8 01             	sub    $0x1,%eax
80105e39:	89 c2                	mov    %eax,%edx
80105e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e3e:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e42:	83 ec 0c             	sub    $0xc,%esp
80105e45:	ff 75 f4             	push   -0xc(%ebp)
80105e48:	e8 2e ba ff ff       	call   8010187b <iupdate>
80105e4d:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e50:	83 ec 0c             	sub    $0xc,%esp
80105e53:	ff 75 f4             	push   -0xc(%ebp)
80105e56:	e8 2e be ff ff       	call   80101c89 <iunlockput>
80105e5b:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e5e:	e8 99 d7 ff ff       	call   801035fc <end_op>
  return -1;
80105e63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e68:	c9                   	leave  
80105e69:	c3                   	ret    

80105e6a <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105e6a:	55                   	push   %ebp
80105e6b:	89 e5                	mov    %esp,%ebp
80105e6d:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e70:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105e77:	eb 40                	jmp    80105eb9 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7c:	6a 10                	push   $0x10
80105e7e:	50                   	push   %eax
80105e7f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e82:	50                   	push   %eax
80105e83:	ff 75 08             	push   0x8(%ebp)
80105e86:	e8 b9 c0 ff ff       	call   80101f44 <readi>
80105e8b:	83 c4 10             	add    $0x10,%esp
80105e8e:	83 f8 10             	cmp    $0x10,%eax
80105e91:	74 0d                	je     80105ea0 <isdirempty+0x36>
      panic("isdirempty: readi");
80105e93:	83 ec 0c             	sub    $0xc,%esp
80105e96:	68 14 8c 10 80       	push   $0x80108c14
80105e9b:	e8 15 a7 ff ff       	call   801005b5 <panic>
    if(de.inum != 0)
80105ea0:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105ea4:	66 85 c0             	test   %ax,%ax
80105ea7:	74 07                	je     80105eb0 <isdirempty+0x46>
      return 0;
80105ea9:	b8 00 00 00 00       	mov    $0x0,%eax
80105eae:	eb 1b                	jmp    80105ecb <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb3:	83 c0 10             	add    $0x10,%eax
80105eb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80105ebc:	8b 50 58             	mov    0x58(%eax),%edx
80105ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec2:	39 c2                	cmp    %eax,%edx
80105ec4:	77 b3                	ja     80105e79 <isdirempty+0xf>
  }
  return 1;
80105ec6:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105ecb:	c9                   	leave  
80105ecc:	c3                   	ret    

80105ecd <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105ecd:	55                   	push   %ebp
80105ece:	89 e5                	mov    %esp,%ebp
80105ed0:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105ed3:	83 ec 08             	sub    $0x8,%esp
80105ed6:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105ed9:	50                   	push   %eax
80105eda:	6a 00                	push   $0x0
80105edc:	e8 a2 fa ff ff       	call   80105983 <argstr>
80105ee1:	83 c4 10             	add    $0x10,%esp
80105ee4:	85 c0                	test   %eax,%eax
80105ee6:	79 0a                	jns    80105ef2 <sys_unlink+0x25>
    return -1;
80105ee8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eed:	e9 bf 01 00 00       	jmp    801060b1 <sys_unlink+0x1e4>

  begin_op();
80105ef2:	e8 79 d6 ff ff       	call   80103570 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105ef7:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105efa:	83 ec 08             	sub    $0x8,%esp
80105efd:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105f00:	52                   	push   %edx
80105f01:	50                   	push   %eax
80105f02:	e8 a0 c6 ff ff       	call   801025a7 <nameiparent>
80105f07:	83 c4 10             	add    $0x10,%esp
80105f0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f11:	75 0f                	jne    80105f22 <sys_unlink+0x55>
    end_op();
80105f13:	e8 e4 d6 ff ff       	call   801035fc <end_op>
    return -1;
80105f18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f1d:	e9 8f 01 00 00       	jmp    801060b1 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105f22:	83 ec 0c             	sub    $0xc,%esp
80105f25:	ff 75 f4             	push   -0xc(%ebp)
80105f28:	e8 2b bb ff ff       	call   80101a58 <ilock>
80105f2d:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f30:	83 ec 08             	sub    $0x8,%esp
80105f33:	68 26 8c 10 80       	push   $0x80108c26
80105f38:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f3b:	50                   	push   %eax
80105f3c:	e8 de c2 ff ff       	call   8010221f <namecmp>
80105f41:	83 c4 10             	add    $0x10,%esp
80105f44:	85 c0                	test   %eax,%eax
80105f46:	0f 84 49 01 00 00    	je     80106095 <sys_unlink+0x1c8>
80105f4c:	83 ec 08             	sub    $0x8,%esp
80105f4f:	68 28 8c 10 80       	push   $0x80108c28
80105f54:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f57:	50                   	push   %eax
80105f58:	e8 c2 c2 ff ff       	call   8010221f <namecmp>
80105f5d:	83 c4 10             	add    $0x10,%esp
80105f60:	85 c0                	test   %eax,%eax
80105f62:	0f 84 2d 01 00 00    	je     80106095 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105f68:	83 ec 04             	sub    $0x4,%esp
80105f6b:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105f6e:	50                   	push   %eax
80105f6f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f72:	50                   	push   %eax
80105f73:	ff 75 f4             	push   -0xc(%ebp)
80105f76:	e8 bf c2 ff ff       	call   8010223a <dirlookup>
80105f7b:	83 c4 10             	add    $0x10,%esp
80105f7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f81:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f85:	0f 84 0d 01 00 00    	je     80106098 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105f8b:	83 ec 0c             	sub    $0xc,%esp
80105f8e:	ff 75 f0             	push   -0x10(%ebp)
80105f91:	e8 c2 ba ff ff       	call   80101a58 <ilock>
80105f96:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f9c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105fa0:	66 85 c0             	test   %ax,%ax
80105fa3:	7f 0d                	jg     80105fb2 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105fa5:	83 ec 0c             	sub    $0xc,%esp
80105fa8:	68 2b 8c 10 80       	push   $0x80108c2b
80105fad:	e8 03 a6 ff ff       	call   801005b5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105fb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105fb9:	66 83 f8 01          	cmp    $0x1,%ax
80105fbd:	75 25                	jne    80105fe4 <sys_unlink+0x117>
80105fbf:	83 ec 0c             	sub    $0xc,%esp
80105fc2:	ff 75 f0             	push   -0x10(%ebp)
80105fc5:	e8 a0 fe ff ff       	call   80105e6a <isdirempty>
80105fca:	83 c4 10             	add    $0x10,%esp
80105fcd:	85 c0                	test   %eax,%eax
80105fcf:	75 13                	jne    80105fe4 <sys_unlink+0x117>
    iunlockput(ip);
80105fd1:	83 ec 0c             	sub    $0xc,%esp
80105fd4:	ff 75 f0             	push   -0x10(%ebp)
80105fd7:	e8 ad bc ff ff       	call   80101c89 <iunlockput>
80105fdc:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105fdf:	e9 b5 00 00 00       	jmp    80106099 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105fe4:	83 ec 04             	sub    $0x4,%esp
80105fe7:	6a 10                	push   $0x10
80105fe9:	6a 00                	push   $0x0
80105feb:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105fee:	50                   	push   %eax
80105fef:	e8 cf f5 ff ff       	call   801055c3 <memset>
80105ff4:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ff7:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105ffa:	6a 10                	push   $0x10
80105ffc:	50                   	push   %eax
80105ffd:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106000:	50                   	push   %eax
80106001:	ff 75 f4             	push   -0xc(%ebp)
80106004:	e8 90 c0 ff ff       	call   80102099 <writei>
80106009:	83 c4 10             	add    $0x10,%esp
8010600c:	83 f8 10             	cmp    $0x10,%eax
8010600f:	74 0d                	je     8010601e <sys_unlink+0x151>
    panic("unlink: writei");
80106011:	83 ec 0c             	sub    $0xc,%esp
80106014:	68 3d 8c 10 80       	push   $0x80108c3d
80106019:	e8 97 a5 ff ff       	call   801005b5 <panic>
  if(ip->type == T_DIR){
8010601e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106021:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106025:	66 83 f8 01          	cmp    $0x1,%ax
80106029:	75 21                	jne    8010604c <sys_unlink+0x17f>
    dp->nlink--;
8010602b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010602e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106032:	83 e8 01             	sub    $0x1,%eax
80106035:	89 c2                	mov    %eax,%edx
80106037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010603a:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010603e:	83 ec 0c             	sub    $0xc,%esp
80106041:	ff 75 f4             	push   -0xc(%ebp)
80106044:	e8 32 b8 ff ff       	call   8010187b <iupdate>
80106049:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010604c:	83 ec 0c             	sub    $0xc,%esp
8010604f:	ff 75 f4             	push   -0xc(%ebp)
80106052:	e8 32 bc ff ff       	call   80101c89 <iunlockput>
80106057:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010605a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010605d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106061:	83 e8 01             	sub    $0x1,%eax
80106064:	89 c2                	mov    %eax,%edx
80106066:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106069:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010606d:	83 ec 0c             	sub    $0xc,%esp
80106070:	ff 75 f0             	push   -0x10(%ebp)
80106073:	e8 03 b8 ff ff       	call   8010187b <iupdate>
80106078:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010607b:	83 ec 0c             	sub    $0xc,%esp
8010607e:	ff 75 f0             	push   -0x10(%ebp)
80106081:	e8 03 bc ff ff       	call   80101c89 <iunlockput>
80106086:	83 c4 10             	add    $0x10,%esp

  end_op();
80106089:	e8 6e d5 ff ff       	call   801035fc <end_op>

  return 0;
8010608e:	b8 00 00 00 00       	mov    $0x0,%eax
80106093:	eb 1c                	jmp    801060b1 <sys_unlink+0x1e4>
    goto bad;
80106095:	90                   	nop
80106096:	eb 01                	jmp    80106099 <sys_unlink+0x1cc>
    goto bad;
80106098:	90                   	nop

bad:
  iunlockput(dp);
80106099:	83 ec 0c             	sub    $0xc,%esp
8010609c:	ff 75 f4             	push   -0xc(%ebp)
8010609f:	e8 e5 bb ff ff       	call   80101c89 <iunlockput>
801060a4:	83 c4 10             	add    $0x10,%esp
  end_op();
801060a7:	e8 50 d5 ff ff       	call   801035fc <end_op>
  return -1;
801060ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060b1:	c9                   	leave  
801060b2:	c3                   	ret    

801060b3 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801060b3:	55                   	push   %ebp
801060b4:	89 e5                	mov    %esp,%ebp
801060b6:	83 ec 38             	sub    $0x38,%esp
801060b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801060bc:	8b 55 10             	mov    0x10(%ebp),%edx
801060bf:	8b 45 14             	mov    0x14(%ebp),%eax
801060c2:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801060c6:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801060ca:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801060ce:	83 ec 08             	sub    $0x8,%esp
801060d1:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801060d4:	50                   	push   %eax
801060d5:	ff 75 08             	push   0x8(%ebp)
801060d8:	e8 ca c4 ff ff       	call   801025a7 <nameiparent>
801060dd:	83 c4 10             	add    $0x10,%esp
801060e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060e7:	75 0a                	jne    801060f3 <create+0x40>
    return 0;
801060e9:	b8 00 00 00 00       	mov    $0x0,%eax
801060ee:	e9 8e 01 00 00       	jmp    80106281 <create+0x1ce>
  ilock(dp);
801060f3:	83 ec 0c             	sub    $0xc,%esp
801060f6:	ff 75 f4             	push   -0xc(%ebp)
801060f9:	e8 5a b9 ff ff       	call   80101a58 <ilock>
801060fe:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
80106101:	83 ec 04             	sub    $0x4,%esp
80106104:	6a 00                	push   $0x0
80106106:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106109:	50                   	push   %eax
8010610a:	ff 75 f4             	push   -0xc(%ebp)
8010610d:	e8 28 c1 ff ff       	call   8010223a <dirlookup>
80106112:	83 c4 10             	add    $0x10,%esp
80106115:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106118:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010611c:	74 50                	je     8010616e <create+0xbb>
    iunlockput(dp);
8010611e:	83 ec 0c             	sub    $0xc,%esp
80106121:	ff 75 f4             	push   -0xc(%ebp)
80106124:	e8 60 bb ff ff       	call   80101c89 <iunlockput>
80106129:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010612c:	83 ec 0c             	sub    $0xc,%esp
8010612f:	ff 75 f0             	push   -0x10(%ebp)
80106132:	e8 21 b9 ff ff       	call   80101a58 <ilock>
80106137:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010613a:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010613f:	75 15                	jne    80106156 <create+0xa3>
80106141:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106144:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106148:	66 83 f8 02          	cmp    $0x2,%ax
8010614c:	75 08                	jne    80106156 <create+0xa3>
      return ip;
8010614e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106151:	e9 2b 01 00 00       	jmp    80106281 <create+0x1ce>
    iunlockput(ip);
80106156:	83 ec 0c             	sub    $0xc,%esp
80106159:	ff 75 f0             	push   -0x10(%ebp)
8010615c:	e8 28 bb ff ff       	call   80101c89 <iunlockput>
80106161:	83 c4 10             	add    $0x10,%esp
    return 0;
80106164:	b8 00 00 00 00       	mov    $0x0,%eax
80106169:	e9 13 01 00 00       	jmp    80106281 <create+0x1ce>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010616e:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106172:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106175:	8b 00                	mov    (%eax),%eax
80106177:	83 ec 08             	sub    $0x8,%esp
8010617a:	52                   	push   %edx
8010617b:	50                   	push   %eax
8010617c:	e8 23 b6 ff ff       	call   801017a4 <ialloc>
80106181:	83 c4 10             	add    $0x10,%esp
80106184:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106187:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010618b:	75 0d                	jne    8010619a <create+0xe7>
    panic("create: ialloc");
8010618d:	83 ec 0c             	sub    $0xc,%esp
80106190:	68 4c 8c 10 80       	push   $0x80108c4c
80106195:	e8 1b a4 ff ff       	call   801005b5 <panic>

  ilock(ip);
8010619a:	83 ec 0c             	sub    $0xc,%esp
8010619d:	ff 75 f0             	push   -0x10(%ebp)
801061a0:	e8 b3 b8 ff ff       	call   80101a58 <ilock>
801061a5:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801061a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ab:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801061af:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801061b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061b6:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801061ba:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801061be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c1:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801061c7:	83 ec 0c             	sub    $0xc,%esp
801061ca:	ff 75 f0             	push   -0x10(%ebp)
801061cd:	e8 a9 b6 ff ff       	call   8010187b <iupdate>
801061d2:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801061d5:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801061da:	75 6a                	jne    80106246 <create+0x193>
    dp->nlink++;  // for ".."
801061dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061df:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801061e3:	83 c0 01             	add    $0x1,%eax
801061e6:	89 c2                	mov    %eax,%edx
801061e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061eb:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801061ef:	83 ec 0c             	sub    $0xc,%esp
801061f2:	ff 75 f4             	push   -0xc(%ebp)
801061f5:	e8 81 b6 ff ff       	call   8010187b <iupdate>
801061fa:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801061fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106200:	8b 40 04             	mov    0x4(%eax),%eax
80106203:	83 ec 04             	sub    $0x4,%esp
80106206:	50                   	push   %eax
80106207:	68 26 8c 10 80       	push   $0x80108c26
8010620c:	ff 75 f0             	push   -0x10(%ebp)
8010620f:	e8 e0 c0 ff ff       	call   801022f4 <dirlink>
80106214:	83 c4 10             	add    $0x10,%esp
80106217:	85 c0                	test   %eax,%eax
80106219:	78 1e                	js     80106239 <create+0x186>
8010621b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010621e:	8b 40 04             	mov    0x4(%eax),%eax
80106221:	83 ec 04             	sub    $0x4,%esp
80106224:	50                   	push   %eax
80106225:	68 28 8c 10 80       	push   $0x80108c28
8010622a:	ff 75 f0             	push   -0x10(%ebp)
8010622d:	e8 c2 c0 ff ff       	call   801022f4 <dirlink>
80106232:	83 c4 10             	add    $0x10,%esp
80106235:	85 c0                	test   %eax,%eax
80106237:	79 0d                	jns    80106246 <create+0x193>
      panic("create dots");
80106239:	83 ec 0c             	sub    $0xc,%esp
8010623c:	68 5b 8c 10 80       	push   $0x80108c5b
80106241:	e8 6f a3 ff ff       	call   801005b5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106246:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106249:	8b 40 04             	mov    0x4(%eax),%eax
8010624c:	83 ec 04             	sub    $0x4,%esp
8010624f:	50                   	push   %eax
80106250:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106253:	50                   	push   %eax
80106254:	ff 75 f4             	push   -0xc(%ebp)
80106257:	e8 98 c0 ff ff       	call   801022f4 <dirlink>
8010625c:	83 c4 10             	add    $0x10,%esp
8010625f:	85 c0                	test   %eax,%eax
80106261:	79 0d                	jns    80106270 <create+0x1bd>
    panic("create: dirlink");
80106263:	83 ec 0c             	sub    $0xc,%esp
80106266:	68 67 8c 10 80       	push   $0x80108c67
8010626b:	e8 45 a3 ff ff       	call   801005b5 <panic>

  iunlockput(dp);
80106270:	83 ec 0c             	sub    $0xc,%esp
80106273:	ff 75 f4             	push   -0xc(%ebp)
80106276:	e8 0e ba ff ff       	call   80101c89 <iunlockput>
8010627b:	83 c4 10             	add    $0x10,%esp

  return ip;
8010627e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106281:	c9                   	leave  
80106282:	c3                   	ret    

80106283 <sys_open>:

int
sys_open(void)
{
80106283:	55                   	push   %ebp
80106284:	89 e5                	mov    %esp,%ebp
80106286:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106289:	83 ec 08             	sub    $0x8,%esp
8010628c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010628f:	50                   	push   %eax
80106290:	6a 00                	push   $0x0
80106292:	e8 ec f6 ff ff       	call   80105983 <argstr>
80106297:	83 c4 10             	add    $0x10,%esp
8010629a:	85 c0                	test   %eax,%eax
8010629c:	78 15                	js     801062b3 <sys_open+0x30>
8010629e:	83 ec 08             	sub    $0x8,%esp
801062a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062a4:	50                   	push   %eax
801062a5:	6a 01                	push   $0x1
801062a7:	e8 42 f6 ff ff       	call   801058ee <argint>
801062ac:	83 c4 10             	add    $0x10,%esp
801062af:	85 c0                	test   %eax,%eax
801062b1:	79 0a                	jns    801062bd <sys_open+0x3a>
    return -1;
801062b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062b8:	e9 61 01 00 00       	jmp    8010641e <sys_open+0x19b>

  begin_op();
801062bd:	e8 ae d2 ff ff       	call   80103570 <begin_op>

  if(omode & O_CREATE){
801062c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062c5:	25 00 02 00 00       	and    $0x200,%eax
801062ca:	85 c0                	test   %eax,%eax
801062cc:	74 2a                	je     801062f8 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801062ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062d1:	6a 00                	push   $0x0
801062d3:	6a 00                	push   $0x0
801062d5:	6a 02                	push   $0x2
801062d7:	50                   	push   %eax
801062d8:	e8 d6 fd ff ff       	call   801060b3 <create>
801062dd:	83 c4 10             	add    $0x10,%esp
801062e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801062e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062e7:	75 75                	jne    8010635e <sys_open+0xdb>
      end_op();
801062e9:	e8 0e d3 ff ff       	call   801035fc <end_op>
      return -1;
801062ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f3:	e9 26 01 00 00       	jmp    8010641e <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801062f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062fb:	83 ec 0c             	sub    $0xc,%esp
801062fe:	50                   	push   %eax
801062ff:	e8 87 c2 ff ff       	call   8010258b <namei>
80106304:	83 c4 10             	add    $0x10,%esp
80106307:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010630a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010630e:	75 0f                	jne    8010631f <sys_open+0x9c>
      end_op();
80106310:	e8 e7 d2 ff ff       	call   801035fc <end_op>
      return -1;
80106315:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010631a:	e9 ff 00 00 00       	jmp    8010641e <sys_open+0x19b>
    }
    ilock(ip);
8010631f:	83 ec 0c             	sub    $0xc,%esp
80106322:	ff 75 f4             	push   -0xc(%ebp)
80106325:	e8 2e b7 ff ff       	call   80101a58 <ilock>
8010632a:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010632d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106330:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106334:	66 83 f8 01          	cmp    $0x1,%ax
80106338:	75 24                	jne    8010635e <sys_open+0xdb>
8010633a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010633d:	85 c0                	test   %eax,%eax
8010633f:	74 1d                	je     8010635e <sys_open+0xdb>
      iunlockput(ip);
80106341:	83 ec 0c             	sub    $0xc,%esp
80106344:	ff 75 f4             	push   -0xc(%ebp)
80106347:	e8 3d b9 ff ff       	call   80101c89 <iunlockput>
8010634c:	83 c4 10             	add    $0x10,%esp
      end_op();
8010634f:	e8 a8 d2 ff ff       	call   801035fc <end_op>
      return -1;
80106354:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106359:	e9 c0 00 00 00       	jmp    8010641e <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010635e:	e8 fb ac ff ff       	call   8010105e <filealloc>
80106363:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106366:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010636a:	74 17                	je     80106383 <sys_open+0x100>
8010636c:	83 ec 0c             	sub    $0xc,%esp
8010636f:	ff 75 f0             	push   -0x10(%ebp)
80106372:	e8 35 f7 ff ff       	call   80105aac <fdalloc>
80106377:	83 c4 10             	add    $0x10,%esp
8010637a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010637d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106381:	79 2e                	jns    801063b1 <sys_open+0x12e>
    if(f)
80106383:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106387:	74 0e                	je     80106397 <sys_open+0x114>
      fileclose(f);
80106389:	83 ec 0c             	sub    $0xc,%esp
8010638c:	ff 75 f0             	push   -0x10(%ebp)
8010638f:	e8 88 ad ff ff       	call   8010111c <fileclose>
80106394:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106397:	83 ec 0c             	sub    $0xc,%esp
8010639a:	ff 75 f4             	push   -0xc(%ebp)
8010639d:	e8 e7 b8 ff ff       	call   80101c89 <iunlockput>
801063a2:	83 c4 10             	add    $0x10,%esp
    end_op();
801063a5:	e8 52 d2 ff ff       	call   801035fc <end_op>
    return -1;
801063aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063af:	eb 6d                	jmp    8010641e <sys_open+0x19b>
  }
  iunlock(ip);
801063b1:	83 ec 0c             	sub    $0xc,%esp
801063b4:	ff 75 f4             	push   -0xc(%ebp)
801063b7:	e8 af b7 ff ff       	call   80101b6b <iunlock>
801063bc:	83 c4 10             	add    $0x10,%esp
  end_op();
801063bf:	e8 38 d2 ff ff       	call   801035fc <end_op>

  f->type = FD_INODE;
801063c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c7:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801063cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063d3:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801063d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d9:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801063e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063e3:	83 e0 01             	and    $0x1,%eax
801063e6:	85 c0                	test   %eax,%eax
801063e8:	0f 94 c0             	sete   %al
801063eb:	89 c2                	mov    %eax,%edx
801063ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f0:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801063f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063f6:	83 e0 01             	and    $0x1,%eax
801063f9:	85 c0                	test   %eax,%eax
801063fb:	75 0a                	jne    80106407 <sys_open+0x184>
801063fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106400:	83 e0 02             	and    $0x2,%eax
80106403:	85 c0                	test   %eax,%eax
80106405:	74 07                	je     8010640e <sys_open+0x18b>
80106407:	b8 01 00 00 00       	mov    $0x1,%eax
8010640c:	eb 05                	jmp    80106413 <sys_open+0x190>
8010640e:	b8 00 00 00 00       	mov    $0x0,%eax
80106413:	89 c2                	mov    %eax,%edx
80106415:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106418:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010641b:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010641e:	c9                   	leave  
8010641f:	c3                   	ret    

80106420 <sys_mkdir>:

int
sys_mkdir(void)
{
80106420:	55                   	push   %ebp
80106421:	89 e5                	mov    %esp,%ebp
80106423:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106426:	e8 45 d1 ff ff       	call   80103570 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010642b:	83 ec 08             	sub    $0x8,%esp
8010642e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106431:	50                   	push   %eax
80106432:	6a 00                	push   $0x0
80106434:	e8 4a f5 ff ff       	call   80105983 <argstr>
80106439:	83 c4 10             	add    $0x10,%esp
8010643c:	85 c0                	test   %eax,%eax
8010643e:	78 1b                	js     8010645b <sys_mkdir+0x3b>
80106440:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106443:	6a 00                	push   $0x0
80106445:	6a 00                	push   $0x0
80106447:	6a 01                	push   $0x1
80106449:	50                   	push   %eax
8010644a:	e8 64 fc ff ff       	call   801060b3 <create>
8010644f:	83 c4 10             	add    $0x10,%esp
80106452:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106455:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106459:	75 0c                	jne    80106467 <sys_mkdir+0x47>
    end_op();
8010645b:	e8 9c d1 ff ff       	call   801035fc <end_op>
    return -1;
80106460:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106465:	eb 18                	jmp    8010647f <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106467:	83 ec 0c             	sub    $0xc,%esp
8010646a:	ff 75 f4             	push   -0xc(%ebp)
8010646d:	e8 17 b8 ff ff       	call   80101c89 <iunlockput>
80106472:	83 c4 10             	add    $0x10,%esp
  end_op();
80106475:	e8 82 d1 ff ff       	call   801035fc <end_op>
  return 0;
8010647a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010647f:	c9                   	leave  
80106480:	c3                   	ret    

80106481 <sys_mknod>:

int
sys_mknod(void)
{
80106481:	55                   	push   %ebp
80106482:	89 e5                	mov    %esp,%ebp
80106484:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106487:	e8 e4 d0 ff ff       	call   80103570 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010648c:	83 ec 08             	sub    $0x8,%esp
8010648f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106492:	50                   	push   %eax
80106493:	6a 00                	push   $0x0
80106495:	e8 e9 f4 ff ff       	call   80105983 <argstr>
8010649a:	83 c4 10             	add    $0x10,%esp
8010649d:	85 c0                	test   %eax,%eax
8010649f:	78 4f                	js     801064f0 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
801064a1:	83 ec 08             	sub    $0x8,%esp
801064a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064a7:	50                   	push   %eax
801064a8:	6a 01                	push   $0x1
801064aa:	e8 3f f4 ff ff       	call   801058ee <argint>
801064af:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801064b2:	85 c0                	test   %eax,%eax
801064b4:	78 3a                	js     801064f0 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
801064b6:	83 ec 08             	sub    $0x8,%esp
801064b9:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064bc:	50                   	push   %eax
801064bd:	6a 02                	push   $0x2
801064bf:	e8 2a f4 ff ff       	call   801058ee <argint>
801064c4:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801064c7:	85 c0                	test   %eax,%eax
801064c9:	78 25                	js     801064f0 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
801064cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064ce:	0f bf c8             	movswl %ax,%ecx
801064d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064d4:	0f bf d0             	movswl %ax,%edx
801064d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064da:	51                   	push   %ecx
801064db:	52                   	push   %edx
801064dc:	6a 03                	push   $0x3
801064de:	50                   	push   %eax
801064df:	e8 cf fb ff ff       	call   801060b3 <create>
801064e4:	83 c4 10             	add    $0x10,%esp
801064e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801064ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064ee:	75 0c                	jne    801064fc <sys_mknod+0x7b>
    end_op();
801064f0:	e8 07 d1 ff ff       	call   801035fc <end_op>
    return -1;
801064f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064fa:	eb 18                	jmp    80106514 <sys_mknod+0x93>
  }
  iunlockput(ip);
801064fc:	83 ec 0c             	sub    $0xc,%esp
801064ff:	ff 75 f4             	push   -0xc(%ebp)
80106502:	e8 82 b7 ff ff       	call   80101c89 <iunlockput>
80106507:	83 c4 10             	add    $0x10,%esp
  end_op();
8010650a:	e8 ed d0 ff ff       	call   801035fc <end_op>
  return 0;
8010650f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106514:	c9                   	leave  
80106515:	c3                   	ret    

80106516 <sys_chdir>:

int
sys_chdir(void)
{
80106516:	55                   	push   %ebp
80106517:	89 e5                	mov    %esp,%ebp
80106519:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010651c:	e8 b6 dd ff ff       	call   801042d7 <myproc>
80106521:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106524:	e8 47 d0 ff ff       	call   80103570 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106529:	83 ec 08             	sub    $0x8,%esp
8010652c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010652f:	50                   	push   %eax
80106530:	6a 00                	push   $0x0
80106532:	e8 4c f4 ff ff       	call   80105983 <argstr>
80106537:	83 c4 10             	add    $0x10,%esp
8010653a:	85 c0                	test   %eax,%eax
8010653c:	78 18                	js     80106556 <sys_chdir+0x40>
8010653e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106541:	83 ec 0c             	sub    $0xc,%esp
80106544:	50                   	push   %eax
80106545:	e8 41 c0 ff ff       	call   8010258b <namei>
8010654a:	83 c4 10             	add    $0x10,%esp
8010654d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106550:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106554:	75 0c                	jne    80106562 <sys_chdir+0x4c>
    end_op();
80106556:	e8 a1 d0 ff ff       	call   801035fc <end_op>
    return -1;
8010655b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106560:	eb 68                	jmp    801065ca <sys_chdir+0xb4>
  }
  ilock(ip);
80106562:	83 ec 0c             	sub    $0xc,%esp
80106565:	ff 75 f0             	push   -0x10(%ebp)
80106568:	e8 eb b4 ff ff       	call   80101a58 <ilock>
8010656d:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106570:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106573:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106577:	66 83 f8 01          	cmp    $0x1,%ax
8010657b:	74 1a                	je     80106597 <sys_chdir+0x81>
    iunlockput(ip);
8010657d:	83 ec 0c             	sub    $0xc,%esp
80106580:	ff 75 f0             	push   -0x10(%ebp)
80106583:	e8 01 b7 ff ff       	call   80101c89 <iunlockput>
80106588:	83 c4 10             	add    $0x10,%esp
    end_op();
8010658b:	e8 6c d0 ff ff       	call   801035fc <end_op>
    return -1;
80106590:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106595:	eb 33                	jmp    801065ca <sys_chdir+0xb4>
  }
  iunlock(ip);
80106597:	83 ec 0c             	sub    $0xc,%esp
8010659a:	ff 75 f0             	push   -0x10(%ebp)
8010659d:	e8 c9 b5 ff ff       	call   80101b6b <iunlock>
801065a2:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801065a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a8:	8b 40 68             	mov    0x68(%eax),%eax
801065ab:	83 ec 0c             	sub    $0xc,%esp
801065ae:	50                   	push   %eax
801065af:	e8 05 b6 ff ff       	call   80101bb9 <iput>
801065b4:	83 c4 10             	add    $0x10,%esp
  end_op();
801065b7:	e8 40 d0 ff ff       	call   801035fc <end_op>
  curproc->cwd = ip;
801065bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065c2:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801065c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065ca:	c9                   	leave  
801065cb:	c3                   	ret    

801065cc <sys_exec>:

int
sys_exec(void)
{
801065cc:	55                   	push   %ebp
801065cd:	89 e5                	mov    %esp,%ebp
801065cf:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801065d5:	83 ec 08             	sub    $0x8,%esp
801065d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065db:	50                   	push   %eax
801065dc:	6a 00                	push   $0x0
801065de:	e8 a0 f3 ff ff       	call   80105983 <argstr>
801065e3:	83 c4 10             	add    $0x10,%esp
801065e6:	85 c0                	test   %eax,%eax
801065e8:	78 18                	js     80106602 <sys_exec+0x36>
801065ea:	83 ec 08             	sub    $0x8,%esp
801065ed:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801065f3:	50                   	push   %eax
801065f4:	6a 01                	push   $0x1
801065f6:	e8 f3 f2 ff ff       	call   801058ee <argint>
801065fb:	83 c4 10             	add    $0x10,%esp
801065fe:	85 c0                	test   %eax,%eax
80106600:	79 0a                	jns    8010660c <sys_exec+0x40>
    return -1;
80106602:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106607:	e9 c6 00 00 00       	jmp    801066d2 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
8010660c:	83 ec 04             	sub    $0x4,%esp
8010660f:	68 80 00 00 00       	push   $0x80
80106614:	6a 00                	push   $0x0
80106616:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010661c:	50                   	push   %eax
8010661d:	e8 a1 ef ff ff       	call   801055c3 <memset>
80106622:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106625:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010662c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010662f:	83 f8 1f             	cmp    $0x1f,%eax
80106632:	76 0a                	jbe    8010663e <sys_exec+0x72>
      return -1;
80106634:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106639:	e9 94 00 00 00       	jmp    801066d2 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010663e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106641:	c1 e0 02             	shl    $0x2,%eax
80106644:	89 c2                	mov    %eax,%edx
80106646:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010664c:	01 c2                	add    %eax,%edx
8010664e:	83 ec 08             	sub    $0x8,%esp
80106651:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106657:	50                   	push   %eax
80106658:	52                   	push   %edx
80106659:	e8 ef f1 ff ff       	call   8010584d <fetchint>
8010665e:	83 c4 10             	add    $0x10,%esp
80106661:	85 c0                	test   %eax,%eax
80106663:	79 07                	jns    8010666c <sys_exec+0xa0>
      return -1;
80106665:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010666a:	eb 66                	jmp    801066d2 <sys_exec+0x106>
    if(uarg == 0){
8010666c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106672:	85 c0                	test   %eax,%eax
80106674:	75 27                	jne    8010669d <sys_exec+0xd1>
      argv[i] = 0;
80106676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106679:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106680:	00 00 00 00 
      break;
80106684:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106685:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106688:	83 ec 08             	sub    $0x8,%esp
8010668b:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106691:	52                   	push   %edx
80106692:	50                   	push   %eax
80106693:	e8 2b a5 ff ff       	call   80100bc3 <exec>
80106698:	83 c4 10             	add    $0x10,%esp
8010669b:	eb 35                	jmp    801066d2 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
8010669d:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801066a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a6:	c1 e0 02             	shl    $0x2,%eax
801066a9:	01 c2                	add    %eax,%edx
801066ab:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066b1:	83 ec 08             	sub    $0x8,%esp
801066b4:	52                   	push   %edx
801066b5:	50                   	push   %eax
801066b6:	e8 d1 f1 ff ff       	call   8010588c <fetchstr>
801066bb:	83 c4 10             	add    $0x10,%esp
801066be:	85 c0                	test   %eax,%eax
801066c0:	79 07                	jns    801066c9 <sys_exec+0xfd>
      return -1;
801066c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066c7:	eb 09                	jmp    801066d2 <sys_exec+0x106>
  for(i=0;; i++){
801066c9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801066cd:	e9 5a ff ff ff       	jmp    8010662c <sys_exec+0x60>
}
801066d2:	c9                   	leave  
801066d3:	c3                   	ret    

801066d4 <sys_pipe>:

int
sys_pipe(void)
{
801066d4:	55                   	push   %ebp
801066d5:	89 e5                	mov    %esp,%ebp
801066d7:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801066da:	83 ec 04             	sub    $0x4,%esp
801066dd:	6a 08                	push   $0x8
801066df:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066e2:	50                   	push   %eax
801066e3:	6a 00                	push   $0x0
801066e5:	e8 31 f2 ff ff       	call   8010591b <argptr>
801066ea:	83 c4 10             	add    $0x10,%esp
801066ed:	85 c0                	test   %eax,%eax
801066ef:	79 0a                	jns    801066fb <sys_pipe+0x27>
    return -1;
801066f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f6:	e9 ae 00 00 00       	jmp    801067a9 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
801066fb:	83 ec 08             	sub    $0x8,%esp
801066fe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106701:	50                   	push   %eax
80106702:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106705:	50                   	push   %eax
80106706:	e8 09 d7 ff ff       	call   80103e14 <pipealloc>
8010670b:	83 c4 10             	add    $0x10,%esp
8010670e:	85 c0                	test   %eax,%eax
80106710:	79 0a                	jns    8010671c <sys_pipe+0x48>
    return -1;
80106712:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106717:	e9 8d 00 00 00       	jmp    801067a9 <sys_pipe+0xd5>
  fd0 = -1;
8010671c:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106723:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106726:	83 ec 0c             	sub    $0xc,%esp
80106729:	50                   	push   %eax
8010672a:	e8 7d f3 ff ff       	call   80105aac <fdalloc>
8010672f:	83 c4 10             	add    $0x10,%esp
80106732:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106735:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106739:	78 18                	js     80106753 <sys_pipe+0x7f>
8010673b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010673e:	83 ec 0c             	sub    $0xc,%esp
80106741:	50                   	push   %eax
80106742:	e8 65 f3 ff ff       	call   80105aac <fdalloc>
80106747:	83 c4 10             	add    $0x10,%esp
8010674a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010674d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106751:	79 3e                	jns    80106791 <sys_pipe+0xbd>
    if(fd0 >= 0)
80106753:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106757:	78 13                	js     8010676c <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80106759:	e8 79 db ff ff       	call   801042d7 <myproc>
8010675e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106761:	83 c2 08             	add    $0x8,%edx
80106764:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010676b:	00 
    fileclose(rf);
8010676c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010676f:	83 ec 0c             	sub    $0xc,%esp
80106772:	50                   	push   %eax
80106773:	e8 a4 a9 ff ff       	call   8010111c <fileclose>
80106778:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010677b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010677e:	83 ec 0c             	sub    $0xc,%esp
80106781:	50                   	push   %eax
80106782:	e8 95 a9 ff ff       	call   8010111c <fileclose>
80106787:	83 c4 10             	add    $0x10,%esp
    return -1;
8010678a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010678f:	eb 18                	jmp    801067a9 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80106791:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106794:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106797:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106799:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010679c:	8d 50 04             	lea    0x4(%eax),%edx
8010679f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067a2:	89 02                	mov    %eax,(%edx)
  return 0;
801067a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067a9:	c9                   	leave  
801067aa:	c3                   	ret    

801067ab <sys_nice>:
/// @brief nice system call for proc to voluntarily decrease priority
/// @param n ticks count to set process priority to
/// @return the old nice value, pre replacement  
int
sys_nice(void)
{
801067ab:	55                   	push   %ebp
801067ac:	89 e5                	mov    %esp,%ebp
801067ae:	83 ec 18             	sub    $0x18,%esp
  int n;
 
  if (argint(0, &n) < 0) return -1;
801067b1:	83 ec 08             	sub    $0x8,%esp
801067b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067b7:	50                   	push   %eax
801067b8:	6a 00                	push   $0x0
801067ba:	e8 2f f1 ff ff       	call   801058ee <argint>
801067bf:	83 c4 10             	add    $0x10,%esp
801067c2:	85 c0                	test   %eax,%eax
801067c4:	79 07                	jns    801067cd <sys_nice+0x22>
801067c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067cb:	eb 2f                	jmp    801067fc <sys_nice+0x51>

  if (n < 0 || n > 20) return -1;
801067cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067d0:	85 c0                	test   %eax,%eax
801067d2:	78 08                	js     801067dc <sys_nice+0x31>
801067d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067d7:	83 f8 14             	cmp    $0x14,%eax
801067da:	7e 07                	jle    801067e3 <sys_nice+0x38>
801067dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067e1:	eb 19                	jmp    801067fc <sys_nice+0x51>

  int prev_nice = myproc()->nice;
801067e3:	e8 ef da ff ff       	call   801042d7 <myproc>
801067e8:	8b 40 7c             	mov    0x7c(%eax),%eax
801067eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  myproc()->nice = n;
801067ee:	e8 e4 da ff ff       	call   801042d7 <myproc>
801067f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801067f6:	89 50 7c             	mov    %edx,0x7c(%eax)
  return prev_nice;
801067f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801067fc:	c9                   	leave  
801067fd:	c3                   	ret    

801067fe <sys_getschedstate>:

/// @brief getschedstate system call for user process to view state of scheduled processes
/// @param pinfo user-provided structure for population with scheduler info
/// @return status code
int
sys_getschedstate(void) {
801067fe:	55                   	push   %ebp
801067ff:	89 e5                	mov    %esp,%ebp
80106801:	83 ec 18             	sub    $0x18,%esp
  struct pschedinfo* pinfo;

  if (argptr(0, (void*)&pinfo, sizeof(*pinfo)) < 0) return -1;
80106804:	83 ec 04             	sub    $0x4,%esp
80106807:	68 00 05 00 00       	push   $0x500
8010680c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010680f:	50                   	push   %eax
80106810:	6a 00                	push   $0x0
80106812:	e8 04 f1 ff ff       	call   8010591b <argptr>
80106817:	83 c4 10             	add    $0x10,%esp
8010681a:	85 c0                	test   %eax,%eax
8010681c:	79 07                	jns    80106825 <sys_getschedstate+0x27>
8010681e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106823:	eb 22                	jmp    80106847 <sys_getschedstate+0x49>
  if ((void *) pinfo == (void *) 0) return -1;
80106825:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106828:	85 c0                	test   %eax,%eax
8010682a:	75 07                	jne    80106833 <sys_getschedstate+0x35>
8010682c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106831:	eb 14                	jmp    80106847 <sys_getschedstate+0x49>

  populate_pschedinfo(pinfo);
80106833:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106836:	83 ec 0c             	sub    $0xc,%esp
80106839:	50                   	push   %eax
8010683a:	e8 6a e1 ff ff       	call   801049a9 <populate_pschedinfo>
8010683f:	83 c4 10             	add    $0x10,%esp
  return 0;
80106842:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106847:	c9                   	leave  
80106848:	c3                   	ret    

80106849 <sys_fork>:
* END OF ADDED CODE FOR P4
*/

int
sys_fork(void)
{
80106849:	55                   	push   %ebp
8010684a:	89 e5                	mov    %esp,%ebp
8010684c:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010684f:	e8 85 dd ff ff       	call   801045d9 <fork>
}
80106854:	c9                   	leave  
80106855:	c3                   	ret    

80106856 <sys_exit>:

int
sys_exit(void)
{
80106856:	55                   	push   %ebp
80106857:	89 e5                	mov    %esp,%ebp
80106859:	83 ec 08             	sub    $0x8,%esp
  exit();
8010685c:	e8 f1 de ff ff       	call   80104752 <exit>
  return 0;  // not reached
80106861:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106866:	c9                   	leave  
80106867:	c3                   	ret    

80106868 <sys_wait>:

int
sys_wait(void)
{
80106868:	55                   	push   %ebp
80106869:	89 e5                	mov    %esp,%ebp
8010686b:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010686e:	e8 02 e0 ff ff       	call   80104875 <wait>
}
80106873:	c9                   	leave  
80106874:	c3                   	ret    

80106875 <sys_kill>:

int
sys_kill(void)
{
80106875:	55                   	push   %ebp
80106876:	89 e5                	mov    %esp,%ebp
80106878:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010687b:	83 ec 08             	sub    $0x8,%esp
8010687e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106881:	50                   	push   %eax
80106882:	6a 00                	push   $0x0
80106884:	e8 65 f0 ff ff       	call   801058ee <argint>
80106889:	83 c4 10             	add    $0x10,%esp
8010688c:	85 c0                	test   %eax,%eax
8010688e:	79 07                	jns    80106897 <sys_kill+0x22>
    return -1;
80106890:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106895:	eb 0f                	jmp    801068a6 <sys_kill+0x31>
  return kill(pid);
80106897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010689a:	83 ec 0c             	sub    $0xc,%esp
8010689d:	50                   	push   %eax
8010689e:	e8 71 e7 ff ff       	call   80105014 <kill>
801068a3:	83 c4 10             	add    $0x10,%esp
}
801068a6:	c9                   	leave  
801068a7:	c3                   	ret    

801068a8 <sys_getpid>:

int
sys_getpid(void)
{
801068a8:	55                   	push   %ebp
801068a9:	89 e5                	mov    %esp,%ebp
801068ab:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801068ae:	e8 24 da ff ff       	call   801042d7 <myproc>
801068b3:	8b 40 10             	mov    0x10(%eax),%eax
}
801068b6:	c9                   	leave  
801068b7:	c3                   	ret    

801068b8 <sys_sbrk>:

int
sys_sbrk(void)
{
801068b8:	55                   	push   %ebp
801068b9:	89 e5                	mov    %esp,%ebp
801068bb:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801068be:	83 ec 08             	sub    $0x8,%esp
801068c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068c4:	50                   	push   %eax
801068c5:	6a 00                	push   $0x0
801068c7:	e8 22 f0 ff ff       	call   801058ee <argint>
801068cc:	83 c4 10             	add    $0x10,%esp
801068cf:	85 c0                	test   %eax,%eax
801068d1:	79 07                	jns    801068da <sys_sbrk+0x22>
    return -1;
801068d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068d8:	eb 27                	jmp    80106901 <sys_sbrk+0x49>
  addr = myproc()->sz;
801068da:	e8 f8 d9 ff ff       	call   801042d7 <myproc>
801068df:	8b 00                	mov    (%eax),%eax
801068e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801068e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068e7:	83 ec 0c             	sub    $0xc,%esp
801068ea:	50                   	push   %eax
801068eb:	e8 4e dc ff ff       	call   8010453e <growproc>
801068f0:	83 c4 10             	add    $0x10,%esp
801068f3:	85 c0                	test   %eax,%eax
801068f5:	79 07                	jns    801068fe <sys_sbrk+0x46>
    return -1;
801068f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068fc:	eb 03                	jmp    80106901 <sys_sbrk+0x49>
  return addr;
801068fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106901:	c9                   	leave  
80106902:	c3                   	ret    

80106903 <sys_sleep>:

int
sys_sleep(void)
{
80106903:	55                   	push   %ebp
80106904:	89 e5                	mov    %esp,%ebp
80106906:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
    
  
  if(argint(0, &n) < 0)
80106909:	83 ec 08             	sub    $0x8,%esp
8010690c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010690f:	50                   	push   %eax
80106910:	6a 00                	push   $0x0
80106912:	e8 d7 ef ff ff       	call   801058ee <argint>
80106917:	83 c4 10             	add    $0x10,%esp
8010691a:	85 c0                	test   %eax,%eax
8010691c:	79 0a                	jns    80106928 <sys_sleep+0x25>
    return -1;
8010691e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106923:	e9 84 00 00 00       	jmp    801069ac <sys_sleep+0xa9>
  acquire(&tickslock);
80106928:	83 ec 0c             	sub    $0xc,%esp
8010692b:	68 a0 59 11 80       	push   $0x801159a0
80106930:	e8 08 ea ff ff       	call   8010533d <acquire>
80106935:	83 c4 10             	add    $0x10,%esp
  
  myproc()->sleep_ticks = n;
80106938:	e8 9a d9 ff ff       	call   801042d7 <myproc>
8010693d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106940:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)

  ticks0 = ticks;
80106946:	a1 d4 59 11 80       	mov    0x801159d4,%eax
8010694b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010694e:	eb 38                	jmp    80106988 <sys_sleep+0x85>
    if(myproc()->killed){
80106950:	e8 82 d9 ff ff       	call   801042d7 <myproc>
80106955:	8b 40 24             	mov    0x24(%eax),%eax
80106958:	85 c0                	test   %eax,%eax
8010695a:	74 17                	je     80106973 <sys_sleep+0x70>
      release(&tickslock);
8010695c:	83 ec 0c             	sub    $0xc,%esp
8010695f:	68 a0 59 11 80       	push   $0x801159a0
80106964:	e8 42 ea ff ff       	call   801053ab <release>
80106969:	83 c4 10             	add    $0x10,%esp
      return -1;
8010696c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106971:	eb 39                	jmp    801069ac <sys_sleep+0xa9>
    }
    sleep(&ticks, &tickslock);
80106973:	83 ec 08             	sub    $0x8,%esp
80106976:	68 a0 59 11 80       	push   $0x801159a0
8010697b:	68 d4 59 11 80       	push   $0x801159d4
80106980:	e8 4a e5 ff ff       	call   80104ecf <sleep>
80106985:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106988:	a1 d4 59 11 80       	mov    0x801159d4,%eax
8010698d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106990:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106993:	39 d0                	cmp    %edx,%eax
80106995:	72 b9                	jb     80106950 <sys_sleep+0x4d>
  }

  release(&tickslock);
80106997:	83 ec 0c             	sub    $0xc,%esp
8010699a:	68 a0 59 11 80       	push   $0x801159a0
8010699f:	e8 07 ea ff ff       	call   801053ab <release>
801069a4:	83 c4 10             	add    $0x10,%esp
  return 0;
801069a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069ac:	c9                   	leave  
801069ad:	c3                   	ret    

801069ae <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801069ae:	55                   	push   %ebp
801069af:	89 e5                	mov    %esp,%ebp
801069b1:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801069b4:	83 ec 0c             	sub    $0xc,%esp
801069b7:	68 a0 59 11 80       	push   $0x801159a0
801069bc:	e8 7c e9 ff ff       	call   8010533d <acquire>
801069c1:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801069c4:	a1 d4 59 11 80       	mov    0x801159d4,%eax
801069c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801069cc:	83 ec 0c             	sub    $0xc,%esp
801069cf:	68 a0 59 11 80       	push   $0x801159a0
801069d4:	e8 d2 e9 ff ff       	call   801053ab <release>
801069d9:	83 c4 10             	add    $0x10,%esp
  return xticks;
801069dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801069df:	c9                   	leave  
801069e0:	c3                   	ret    

801069e1 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801069e1:	1e                   	push   %ds
  pushl %es
801069e2:	06                   	push   %es
  pushl %fs
801069e3:	0f a0                	push   %fs
  pushl %gs
801069e5:	0f a8                	push   %gs
  pushal
801069e7:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801069e8:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801069ec:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801069ee:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801069f0:	54                   	push   %esp
  call trap
801069f1:	e8 d7 01 00 00       	call   80106bcd <trap>
  addl $4, %esp
801069f6:	83 c4 04             	add    $0x4,%esp

801069f9 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801069f9:	61                   	popa   
  popl %gs
801069fa:	0f a9                	pop    %gs
  popl %fs
801069fc:	0f a1                	pop    %fs
  popl %es
801069fe:	07                   	pop    %es
  popl %ds
801069ff:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106a00:	83 c4 08             	add    $0x8,%esp
  iret
80106a03:	cf                   	iret   

80106a04 <lidt>:
{
80106a04:	55                   	push   %ebp
80106a05:	89 e5                	mov    %esp,%ebp
80106a07:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a0d:	83 e8 01             	sub    $0x1,%eax
80106a10:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106a14:	8b 45 08             	mov    0x8(%ebp),%eax
80106a17:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106a1b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a1e:	c1 e8 10             	shr    $0x10,%eax
80106a21:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106a25:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106a28:	0f 01 18             	lidtl  (%eax)
}
80106a2b:	90                   	nop
80106a2c:	c9                   	leave  
80106a2d:	c3                   	ret    

80106a2e <rcr2>:

static inline uint
rcr2(void)
{
80106a2e:	55                   	push   %ebp
80106a2f:	89 e5                	mov    %esp,%ebp
80106a31:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106a34:	0f 20 d0             	mov    %cr2,%eax
80106a37:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106a3a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106a3d:	c9                   	leave  
80106a3e:	c3                   	ret    

80106a3f <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106a3f:	55                   	push   %ebp
80106a40:	89 e5                	mov    %esp,%ebp
80106a42:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106a45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106a4c:	e9 c3 00 00 00       	jmp    80106b14 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a54:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
80106a5b:	89 c2                	mov    %eax,%edx
80106a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a60:	66 89 14 c5 a0 51 11 	mov    %dx,-0x7feeae60(,%eax,8)
80106a67:	80 
80106a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a6b:	66 c7 04 c5 a2 51 11 	movw   $0x8,-0x7feeae5e(,%eax,8)
80106a72:	80 08 00 
80106a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a78:	0f b6 14 c5 a4 51 11 	movzbl -0x7feeae5c(,%eax,8),%edx
80106a7f:	80 
80106a80:	83 e2 e0             	and    $0xffffffe0,%edx
80106a83:	88 14 c5 a4 51 11 80 	mov    %dl,-0x7feeae5c(,%eax,8)
80106a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a8d:	0f b6 14 c5 a4 51 11 	movzbl -0x7feeae5c(,%eax,8),%edx
80106a94:	80 
80106a95:	83 e2 1f             	and    $0x1f,%edx
80106a98:	88 14 c5 a4 51 11 80 	mov    %dl,-0x7feeae5c(,%eax,8)
80106a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aa2:	0f b6 14 c5 a5 51 11 	movzbl -0x7feeae5b(,%eax,8),%edx
80106aa9:	80 
80106aaa:	83 e2 f0             	and    $0xfffffff0,%edx
80106aad:	83 ca 0e             	or     $0xe,%edx
80106ab0:	88 14 c5 a5 51 11 80 	mov    %dl,-0x7feeae5b(,%eax,8)
80106ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aba:	0f b6 14 c5 a5 51 11 	movzbl -0x7feeae5b(,%eax,8),%edx
80106ac1:	80 
80106ac2:	83 e2 ef             	and    $0xffffffef,%edx
80106ac5:	88 14 c5 a5 51 11 80 	mov    %dl,-0x7feeae5b(,%eax,8)
80106acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106acf:	0f b6 14 c5 a5 51 11 	movzbl -0x7feeae5b(,%eax,8),%edx
80106ad6:	80 
80106ad7:	83 e2 9f             	and    $0xffffff9f,%edx
80106ada:	88 14 c5 a5 51 11 80 	mov    %dl,-0x7feeae5b(,%eax,8)
80106ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae4:	0f b6 14 c5 a5 51 11 	movzbl -0x7feeae5b(,%eax,8),%edx
80106aeb:	80 
80106aec:	83 ca 80             	or     $0xffffff80,%edx
80106aef:	88 14 c5 a5 51 11 80 	mov    %dl,-0x7feeae5b(,%eax,8)
80106af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af9:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
80106b00:	c1 e8 10             	shr    $0x10,%eax
80106b03:	89 c2                	mov    %eax,%edx
80106b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b08:	66 89 14 c5 a6 51 11 	mov    %dx,-0x7feeae5a(,%eax,8)
80106b0f:	80 
  for(i = 0; i < 256; i++)
80106b10:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106b14:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106b1b:	0f 8e 30 ff ff ff    	jle    80106a51 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106b21:	a1 80 b1 10 80       	mov    0x8010b180,%eax
80106b26:	66 a3 a0 53 11 80    	mov    %ax,0x801153a0
80106b2c:	66 c7 05 a2 53 11 80 	movw   $0x8,0x801153a2
80106b33:	08 00 
80106b35:	0f b6 05 a4 53 11 80 	movzbl 0x801153a4,%eax
80106b3c:	83 e0 e0             	and    $0xffffffe0,%eax
80106b3f:	a2 a4 53 11 80       	mov    %al,0x801153a4
80106b44:	0f b6 05 a4 53 11 80 	movzbl 0x801153a4,%eax
80106b4b:	83 e0 1f             	and    $0x1f,%eax
80106b4e:	a2 a4 53 11 80       	mov    %al,0x801153a4
80106b53:	0f b6 05 a5 53 11 80 	movzbl 0x801153a5,%eax
80106b5a:	83 c8 0f             	or     $0xf,%eax
80106b5d:	a2 a5 53 11 80       	mov    %al,0x801153a5
80106b62:	0f b6 05 a5 53 11 80 	movzbl 0x801153a5,%eax
80106b69:	83 e0 ef             	and    $0xffffffef,%eax
80106b6c:	a2 a5 53 11 80       	mov    %al,0x801153a5
80106b71:	0f b6 05 a5 53 11 80 	movzbl 0x801153a5,%eax
80106b78:	83 c8 60             	or     $0x60,%eax
80106b7b:	a2 a5 53 11 80       	mov    %al,0x801153a5
80106b80:	0f b6 05 a5 53 11 80 	movzbl 0x801153a5,%eax
80106b87:	83 c8 80             	or     $0xffffff80,%eax
80106b8a:	a2 a5 53 11 80       	mov    %al,0x801153a5
80106b8f:	a1 80 b1 10 80       	mov    0x8010b180,%eax
80106b94:	c1 e8 10             	shr    $0x10,%eax
80106b97:	66 a3 a6 53 11 80    	mov    %ax,0x801153a6

  initlock(&tickslock, "time");
80106b9d:	83 ec 08             	sub    $0x8,%esp
80106ba0:	68 78 8c 10 80       	push   $0x80108c78
80106ba5:	68 a0 59 11 80       	push   $0x801159a0
80106baa:	e8 6c e7 ff ff       	call   8010531b <initlock>
80106baf:	83 c4 10             	add    $0x10,%esp
}
80106bb2:	90                   	nop
80106bb3:	c9                   	leave  
80106bb4:	c3                   	ret    

80106bb5 <idtinit>:

void
idtinit(void)
{
80106bb5:	55                   	push   %ebp
80106bb6:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106bb8:	68 00 08 00 00       	push   $0x800
80106bbd:	68 a0 51 11 80       	push   $0x801151a0
80106bc2:	e8 3d fe ff ff       	call   80106a04 <lidt>
80106bc7:	83 c4 08             	add    $0x8,%esp
}
80106bca:	90                   	nop
80106bcb:	c9                   	leave  
80106bcc:	c3                   	ret    

80106bcd <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106bcd:	55                   	push   %ebp
80106bce:	89 e5                	mov    %esp,%ebp
80106bd0:	57                   	push   %edi
80106bd1:	56                   	push   %esi
80106bd2:	53                   	push   %ebx
80106bd3:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80106bd9:	8b 40 30             	mov    0x30(%eax),%eax
80106bdc:	83 f8 40             	cmp    $0x40,%eax
80106bdf:	75 3b                	jne    80106c1c <trap+0x4f>
    if(myproc()->killed)
80106be1:	e8 f1 d6 ff ff       	call   801042d7 <myproc>
80106be6:	8b 40 24             	mov    0x24(%eax),%eax
80106be9:	85 c0                	test   %eax,%eax
80106beb:	74 05                	je     80106bf2 <trap+0x25>
      exit();
80106bed:	e8 60 db ff ff       	call   80104752 <exit>
    myproc()->tf = tf;
80106bf2:	e8 e0 d6 ff ff       	call   801042d7 <myproc>
80106bf7:	8b 55 08             	mov    0x8(%ebp),%edx
80106bfa:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106bfd:	e8 b8 ed ff ff       	call   801059ba <syscall>
    if(myproc()->killed)
80106c02:	e8 d0 d6 ff ff       	call   801042d7 <myproc>
80106c07:	8b 40 24             	mov    0x24(%eax),%eax
80106c0a:	85 c0                	test   %eax,%eax
80106c0c:	0f 84 06 02 00 00    	je     80106e18 <trap+0x24b>
      exit();
80106c12:	e8 3b db ff ff       	call   80104752 <exit>
    return;
80106c17:	e9 fc 01 00 00       	jmp    80106e18 <trap+0x24b>
  }

  switch(tf->trapno){
80106c1c:	8b 45 08             	mov    0x8(%ebp),%eax
80106c1f:	8b 40 30             	mov    0x30(%eax),%eax
80106c22:	83 e8 20             	sub    $0x20,%eax
80106c25:	83 f8 1f             	cmp    $0x1f,%eax
80106c28:	0f 87 b5 00 00 00    	ja     80106ce3 <trap+0x116>
80106c2e:	8b 04 85 20 8d 10 80 	mov    -0x7fef72e0(,%eax,4),%eax
80106c35:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106c37:	e8 08 d6 ff ff       	call   80104244 <cpuid>
80106c3c:	85 c0                	test   %eax,%eax
80106c3e:	75 3d                	jne    80106c7d <trap+0xb0>
      acquire(&tickslock);
80106c40:	83 ec 0c             	sub    $0xc,%esp
80106c43:	68 a0 59 11 80       	push   $0x801159a0
80106c48:	e8 f0 e6 ff ff       	call   8010533d <acquire>
80106c4d:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106c50:	a1 d4 59 11 80       	mov    0x801159d4,%eax
80106c55:	83 c0 01             	add    $0x1,%eax
80106c58:	a3 d4 59 11 80       	mov    %eax,0x801159d4
      wakeup(&ticks);
80106c5d:	83 ec 0c             	sub    $0xc,%esp
80106c60:	68 d4 59 11 80       	push   $0x801159d4
80106c65:	e8 73 e3 ff ff       	call   80104fdd <wakeup>
80106c6a:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106c6d:	83 ec 0c             	sub    $0xc,%esp
80106c70:	68 a0 59 11 80       	push   $0x801159a0
80106c75:	e8 31 e7 ff ff       	call   801053ab <release>
80106c7a:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106c7d:	e8 ce c3 ff ff       	call   80103050 <lapiceoi>
    break;
80106c82:	e9 11 01 00 00       	jmp    80106d98 <trap+0x1cb>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106c87:	e8 38 bc ff ff       	call   801028c4 <ideintr>
    lapiceoi();
80106c8c:	e8 bf c3 ff ff       	call   80103050 <lapiceoi>
    break;
80106c91:	e9 02 01 00 00       	jmp    80106d98 <trap+0x1cb>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106c96:	e8 fa c1 ff ff       	call   80102e95 <kbdintr>
    lapiceoi();
80106c9b:	e8 b0 c3 ff ff       	call   80103050 <lapiceoi>
    break;
80106ca0:	e9 f3 00 00 00       	jmp    80106d98 <trap+0x1cb>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106ca5:	e8 44 03 00 00       	call   80106fee <uartintr>
    lapiceoi();
80106caa:	e8 a1 c3 ff ff       	call   80103050 <lapiceoi>
    break;
80106caf:	e9 e4 00 00 00       	jmp    80106d98 <trap+0x1cb>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106cb4:	8b 45 08             	mov    0x8(%ebp),%eax
80106cb7:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106cba:	8b 45 08             	mov    0x8(%ebp),%eax
80106cbd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106cc1:	0f b7 d8             	movzwl %ax,%ebx
80106cc4:	e8 7b d5 ff ff       	call   80104244 <cpuid>
80106cc9:	56                   	push   %esi
80106cca:	53                   	push   %ebx
80106ccb:	50                   	push   %eax
80106ccc:	68 80 8c 10 80       	push   $0x80108c80
80106cd1:	e8 2a 97 ff ff       	call   80100400 <cprintf>
80106cd6:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106cd9:	e8 72 c3 ff ff       	call   80103050 <lapiceoi>
    break;
80106cde:	e9 b5 00 00 00       	jmp    80106d98 <trap+0x1cb>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106ce3:	e8 ef d5 ff ff       	call   801042d7 <myproc>
80106ce8:	85 c0                	test   %eax,%eax
80106cea:	74 11                	je     80106cfd <trap+0x130>
80106cec:	8b 45 08             	mov    0x8(%ebp),%eax
80106cef:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106cf3:	0f b7 c0             	movzwl %ax,%eax
80106cf6:	83 e0 03             	and    $0x3,%eax
80106cf9:	85 c0                	test   %eax,%eax
80106cfb:	75 39                	jne    80106d36 <trap+0x169>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106cfd:	e8 2c fd ff ff       	call   80106a2e <rcr2>
80106d02:	89 c3                	mov    %eax,%ebx
80106d04:	8b 45 08             	mov    0x8(%ebp),%eax
80106d07:	8b 70 38             	mov    0x38(%eax),%esi
80106d0a:	e8 35 d5 ff ff       	call   80104244 <cpuid>
80106d0f:	8b 55 08             	mov    0x8(%ebp),%edx
80106d12:	8b 52 30             	mov    0x30(%edx),%edx
80106d15:	83 ec 0c             	sub    $0xc,%esp
80106d18:	53                   	push   %ebx
80106d19:	56                   	push   %esi
80106d1a:	50                   	push   %eax
80106d1b:	52                   	push   %edx
80106d1c:	68 a4 8c 10 80       	push   $0x80108ca4
80106d21:	e8 da 96 ff ff       	call   80100400 <cprintf>
80106d26:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106d29:	83 ec 0c             	sub    $0xc,%esp
80106d2c:	68 d6 8c 10 80       	push   $0x80108cd6
80106d31:	e8 7f 98 ff ff       	call   801005b5 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d36:	e8 f3 fc ff ff       	call   80106a2e <rcr2>
80106d3b:	89 c6                	mov    %eax,%esi
80106d3d:	8b 45 08             	mov    0x8(%ebp),%eax
80106d40:	8b 40 38             	mov    0x38(%eax),%eax
80106d43:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106d46:	e8 f9 d4 ff ff       	call   80104244 <cpuid>
80106d4b:	89 c3                	mov    %eax,%ebx
80106d4d:	8b 45 08             	mov    0x8(%ebp),%eax
80106d50:	8b 48 34             	mov    0x34(%eax),%ecx
80106d53:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80106d56:	8b 45 08             	mov    0x8(%ebp),%eax
80106d59:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106d5c:	e8 76 d5 ff ff       	call   801042d7 <myproc>
80106d61:	8d 50 6c             	lea    0x6c(%eax),%edx
80106d64:	89 55 dc             	mov    %edx,-0x24(%ebp)
80106d67:	e8 6b d5 ff ff       	call   801042d7 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d6c:	8b 40 10             	mov    0x10(%eax),%eax
80106d6f:	56                   	push   %esi
80106d70:	ff 75 e4             	push   -0x1c(%ebp)
80106d73:	53                   	push   %ebx
80106d74:	ff 75 e0             	push   -0x20(%ebp)
80106d77:	57                   	push   %edi
80106d78:	ff 75 dc             	push   -0x24(%ebp)
80106d7b:	50                   	push   %eax
80106d7c:	68 dc 8c 10 80       	push   $0x80108cdc
80106d81:	e8 7a 96 ff ff       	call   80100400 <cprintf>
80106d86:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106d89:	e8 49 d5 ff ff       	call   801042d7 <myproc>
80106d8e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106d95:	eb 01                	jmp    80106d98 <trap+0x1cb>
    break;
80106d97:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106d98:	e8 3a d5 ff ff       	call   801042d7 <myproc>
80106d9d:	85 c0                	test   %eax,%eax
80106d9f:	74 23                	je     80106dc4 <trap+0x1f7>
80106da1:	e8 31 d5 ff ff       	call   801042d7 <myproc>
80106da6:	8b 40 24             	mov    0x24(%eax),%eax
80106da9:	85 c0                	test   %eax,%eax
80106dab:	74 17                	je     80106dc4 <trap+0x1f7>
80106dad:	8b 45 08             	mov    0x8(%ebp),%eax
80106db0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106db4:	0f b7 c0             	movzwl %ax,%eax
80106db7:	83 e0 03             	and    $0x3,%eax
80106dba:	83 f8 03             	cmp    $0x3,%eax
80106dbd:	75 05                	jne    80106dc4 <trap+0x1f7>
    exit();
80106dbf:	e8 8e d9 ff ff       	call   80104752 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106dc4:	e8 0e d5 ff ff       	call   801042d7 <myproc>
80106dc9:	85 c0                	test   %eax,%eax
80106dcb:	74 1d                	je     80106dea <trap+0x21d>
80106dcd:	e8 05 d5 ff ff       	call   801042d7 <myproc>
80106dd2:	8b 40 0c             	mov    0xc(%eax),%eax
80106dd5:	83 f8 04             	cmp    $0x4,%eax
80106dd8:	75 10                	jne    80106dea <trap+0x21d>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106dda:	8b 45 08             	mov    0x8(%ebp),%eax
80106ddd:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106de0:	83 f8 20             	cmp    $0x20,%eax
80106de3:	75 05                	jne    80106dea <trap+0x21d>
    yield();
80106de5:	e8 65 e0 ff ff       	call   80104e4f <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106dea:	e8 e8 d4 ff ff       	call   801042d7 <myproc>
80106def:	85 c0                	test   %eax,%eax
80106df1:	74 26                	je     80106e19 <trap+0x24c>
80106df3:	e8 df d4 ff ff       	call   801042d7 <myproc>
80106df8:	8b 40 24             	mov    0x24(%eax),%eax
80106dfb:	85 c0                	test   %eax,%eax
80106dfd:	74 1a                	je     80106e19 <trap+0x24c>
80106dff:	8b 45 08             	mov    0x8(%ebp),%eax
80106e02:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e06:	0f b7 c0             	movzwl %ax,%eax
80106e09:	83 e0 03             	and    $0x3,%eax
80106e0c:	83 f8 03             	cmp    $0x3,%eax
80106e0f:	75 08                	jne    80106e19 <trap+0x24c>
    exit();
80106e11:	e8 3c d9 ff ff       	call   80104752 <exit>
80106e16:	eb 01                	jmp    80106e19 <trap+0x24c>
    return;
80106e18:	90                   	nop
}
80106e19:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106e1c:	5b                   	pop    %ebx
80106e1d:	5e                   	pop    %esi
80106e1e:	5f                   	pop    %edi
80106e1f:	5d                   	pop    %ebp
80106e20:	c3                   	ret    

80106e21 <inb>:
{
80106e21:	55                   	push   %ebp
80106e22:	89 e5                	mov    %esp,%ebp
80106e24:	83 ec 14             	sub    $0x14,%esp
80106e27:	8b 45 08             	mov    0x8(%ebp),%eax
80106e2a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106e2e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106e32:	89 c2                	mov    %eax,%edx
80106e34:	ec                   	in     (%dx),%al
80106e35:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106e38:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106e3c:	c9                   	leave  
80106e3d:	c3                   	ret    

80106e3e <outb>:
{
80106e3e:	55                   	push   %ebp
80106e3f:	89 e5                	mov    %esp,%ebp
80106e41:	83 ec 08             	sub    $0x8,%esp
80106e44:	8b 45 08             	mov    0x8(%ebp),%eax
80106e47:	8b 55 0c             	mov    0xc(%ebp),%edx
80106e4a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106e4e:	89 d0                	mov    %edx,%eax
80106e50:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106e53:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106e57:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106e5b:	ee                   	out    %al,(%dx)
}
80106e5c:	90                   	nop
80106e5d:	c9                   	leave  
80106e5e:	c3                   	ret    

80106e5f <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106e5f:	55                   	push   %ebp
80106e60:	89 e5                	mov    %esp,%ebp
80106e62:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106e65:	6a 00                	push   $0x0
80106e67:	68 fa 03 00 00       	push   $0x3fa
80106e6c:	e8 cd ff ff ff       	call   80106e3e <outb>
80106e71:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106e74:	68 80 00 00 00       	push   $0x80
80106e79:	68 fb 03 00 00       	push   $0x3fb
80106e7e:	e8 bb ff ff ff       	call   80106e3e <outb>
80106e83:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106e86:	6a 0c                	push   $0xc
80106e88:	68 f8 03 00 00       	push   $0x3f8
80106e8d:	e8 ac ff ff ff       	call   80106e3e <outb>
80106e92:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106e95:	6a 00                	push   $0x0
80106e97:	68 f9 03 00 00       	push   $0x3f9
80106e9c:	e8 9d ff ff ff       	call   80106e3e <outb>
80106ea1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106ea4:	6a 03                	push   $0x3
80106ea6:	68 fb 03 00 00       	push   $0x3fb
80106eab:	e8 8e ff ff ff       	call   80106e3e <outb>
80106eb0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106eb3:	6a 00                	push   $0x0
80106eb5:	68 fc 03 00 00       	push   $0x3fc
80106eba:	e8 7f ff ff ff       	call   80106e3e <outb>
80106ebf:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106ec2:	6a 01                	push   $0x1
80106ec4:	68 f9 03 00 00       	push   $0x3f9
80106ec9:	e8 70 ff ff ff       	call   80106e3e <outb>
80106ece:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106ed1:	68 fd 03 00 00       	push   $0x3fd
80106ed6:	e8 46 ff ff ff       	call   80106e21 <inb>
80106edb:	83 c4 04             	add    $0x4,%esp
80106ede:	3c ff                	cmp    $0xff,%al
80106ee0:	74 61                	je     80106f43 <uartinit+0xe4>
    return;
  uart = 1;
80106ee2:	c7 05 d8 59 11 80 01 	movl   $0x1,0x801159d8
80106ee9:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106eec:	68 fa 03 00 00       	push   $0x3fa
80106ef1:	e8 2b ff ff ff       	call   80106e21 <inb>
80106ef6:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106ef9:	68 f8 03 00 00       	push   $0x3f8
80106efe:	e8 1e ff ff ff       	call   80106e21 <inb>
80106f03:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106f06:	83 ec 08             	sub    $0x8,%esp
80106f09:	6a 00                	push   $0x0
80106f0b:	6a 04                	push   $0x4
80106f0d:	e8 50 bc ff ff       	call   80102b62 <ioapicenable>
80106f12:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106f15:	c7 45 f4 a0 8d 10 80 	movl   $0x80108da0,-0xc(%ebp)
80106f1c:	eb 19                	jmp    80106f37 <uartinit+0xd8>
    uartputc(*p);
80106f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f21:	0f b6 00             	movzbl (%eax),%eax
80106f24:	0f be c0             	movsbl %al,%eax
80106f27:	83 ec 0c             	sub    $0xc,%esp
80106f2a:	50                   	push   %eax
80106f2b:	e8 16 00 00 00       	call   80106f46 <uartputc>
80106f30:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106f33:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f3a:	0f b6 00             	movzbl (%eax),%eax
80106f3d:	84 c0                	test   %al,%al
80106f3f:	75 dd                	jne    80106f1e <uartinit+0xbf>
80106f41:	eb 01                	jmp    80106f44 <uartinit+0xe5>
    return;
80106f43:	90                   	nop
}
80106f44:	c9                   	leave  
80106f45:	c3                   	ret    

80106f46 <uartputc>:

void
uartputc(int c)
{
80106f46:	55                   	push   %ebp
80106f47:	89 e5                	mov    %esp,%ebp
80106f49:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106f4c:	a1 d8 59 11 80       	mov    0x801159d8,%eax
80106f51:	85 c0                	test   %eax,%eax
80106f53:	74 53                	je     80106fa8 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106f5c:	eb 11                	jmp    80106f6f <uartputc+0x29>
    microdelay(10);
80106f5e:	83 ec 0c             	sub    $0xc,%esp
80106f61:	6a 0a                	push   $0xa
80106f63:	e8 03 c1 ff ff       	call   8010306b <microdelay>
80106f68:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f6b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106f6f:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106f73:	7f 1a                	jg     80106f8f <uartputc+0x49>
80106f75:	83 ec 0c             	sub    $0xc,%esp
80106f78:	68 fd 03 00 00       	push   $0x3fd
80106f7d:	e8 9f fe ff ff       	call   80106e21 <inb>
80106f82:	83 c4 10             	add    $0x10,%esp
80106f85:	0f b6 c0             	movzbl %al,%eax
80106f88:	83 e0 20             	and    $0x20,%eax
80106f8b:	85 c0                	test   %eax,%eax
80106f8d:	74 cf                	je     80106f5e <uartputc+0x18>
  outb(COM1+0, c);
80106f8f:	8b 45 08             	mov    0x8(%ebp),%eax
80106f92:	0f b6 c0             	movzbl %al,%eax
80106f95:	83 ec 08             	sub    $0x8,%esp
80106f98:	50                   	push   %eax
80106f99:	68 f8 03 00 00       	push   $0x3f8
80106f9e:	e8 9b fe ff ff       	call   80106e3e <outb>
80106fa3:	83 c4 10             	add    $0x10,%esp
80106fa6:	eb 01                	jmp    80106fa9 <uartputc+0x63>
    return;
80106fa8:	90                   	nop
}
80106fa9:	c9                   	leave  
80106faa:	c3                   	ret    

80106fab <uartgetc>:

static int
uartgetc(void)
{
80106fab:	55                   	push   %ebp
80106fac:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106fae:	a1 d8 59 11 80       	mov    0x801159d8,%eax
80106fb3:	85 c0                	test   %eax,%eax
80106fb5:	75 07                	jne    80106fbe <uartgetc+0x13>
    return -1;
80106fb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fbc:	eb 2e                	jmp    80106fec <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106fbe:	68 fd 03 00 00       	push   $0x3fd
80106fc3:	e8 59 fe ff ff       	call   80106e21 <inb>
80106fc8:	83 c4 04             	add    $0x4,%esp
80106fcb:	0f b6 c0             	movzbl %al,%eax
80106fce:	83 e0 01             	and    $0x1,%eax
80106fd1:	85 c0                	test   %eax,%eax
80106fd3:	75 07                	jne    80106fdc <uartgetc+0x31>
    return -1;
80106fd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fda:	eb 10                	jmp    80106fec <uartgetc+0x41>
  return inb(COM1+0);
80106fdc:	68 f8 03 00 00       	push   $0x3f8
80106fe1:	e8 3b fe ff ff       	call   80106e21 <inb>
80106fe6:	83 c4 04             	add    $0x4,%esp
80106fe9:	0f b6 c0             	movzbl %al,%eax
}
80106fec:	c9                   	leave  
80106fed:	c3                   	ret    

80106fee <uartintr>:

void
uartintr(void)
{
80106fee:	55                   	push   %ebp
80106fef:	89 e5                	mov    %esp,%ebp
80106ff1:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106ff4:	83 ec 0c             	sub    $0xc,%esp
80106ff7:	68 ab 6f 10 80       	push   $0x80106fab
80106ffc:	e8 4e 98 ff ff       	call   8010084f <consoleintr>
80107001:	83 c4 10             	add    $0x10,%esp
}
80107004:	90                   	nop
80107005:	c9                   	leave  
80107006:	c3                   	ret    

80107007 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107007:	6a 00                	push   $0x0
  pushl $0
80107009:	6a 00                	push   $0x0
  jmp alltraps
8010700b:	e9 d1 f9 ff ff       	jmp    801069e1 <alltraps>

80107010 <vector1>:
.globl vector1
vector1:
  pushl $0
80107010:	6a 00                	push   $0x0
  pushl $1
80107012:	6a 01                	push   $0x1
  jmp alltraps
80107014:	e9 c8 f9 ff ff       	jmp    801069e1 <alltraps>

80107019 <vector2>:
.globl vector2
vector2:
  pushl $0
80107019:	6a 00                	push   $0x0
  pushl $2
8010701b:	6a 02                	push   $0x2
  jmp alltraps
8010701d:	e9 bf f9 ff ff       	jmp    801069e1 <alltraps>

80107022 <vector3>:
.globl vector3
vector3:
  pushl $0
80107022:	6a 00                	push   $0x0
  pushl $3
80107024:	6a 03                	push   $0x3
  jmp alltraps
80107026:	e9 b6 f9 ff ff       	jmp    801069e1 <alltraps>

8010702b <vector4>:
.globl vector4
vector4:
  pushl $0
8010702b:	6a 00                	push   $0x0
  pushl $4
8010702d:	6a 04                	push   $0x4
  jmp alltraps
8010702f:	e9 ad f9 ff ff       	jmp    801069e1 <alltraps>

80107034 <vector5>:
.globl vector5
vector5:
  pushl $0
80107034:	6a 00                	push   $0x0
  pushl $5
80107036:	6a 05                	push   $0x5
  jmp alltraps
80107038:	e9 a4 f9 ff ff       	jmp    801069e1 <alltraps>

8010703d <vector6>:
.globl vector6
vector6:
  pushl $0
8010703d:	6a 00                	push   $0x0
  pushl $6
8010703f:	6a 06                	push   $0x6
  jmp alltraps
80107041:	e9 9b f9 ff ff       	jmp    801069e1 <alltraps>

80107046 <vector7>:
.globl vector7
vector7:
  pushl $0
80107046:	6a 00                	push   $0x0
  pushl $7
80107048:	6a 07                	push   $0x7
  jmp alltraps
8010704a:	e9 92 f9 ff ff       	jmp    801069e1 <alltraps>

8010704f <vector8>:
.globl vector8
vector8:
  pushl $8
8010704f:	6a 08                	push   $0x8
  jmp alltraps
80107051:	e9 8b f9 ff ff       	jmp    801069e1 <alltraps>

80107056 <vector9>:
.globl vector9
vector9:
  pushl $0
80107056:	6a 00                	push   $0x0
  pushl $9
80107058:	6a 09                	push   $0x9
  jmp alltraps
8010705a:	e9 82 f9 ff ff       	jmp    801069e1 <alltraps>

8010705f <vector10>:
.globl vector10
vector10:
  pushl $10
8010705f:	6a 0a                	push   $0xa
  jmp alltraps
80107061:	e9 7b f9 ff ff       	jmp    801069e1 <alltraps>

80107066 <vector11>:
.globl vector11
vector11:
  pushl $11
80107066:	6a 0b                	push   $0xb
  jmp alltraps
80107068:	e9 74 f9 ff ff       	jmp    801069e1 <alltraps>

8010706d <vector12>:
.globl vector12
vector12:
  pushl $12
8010706d:	6a 0c                	push   $0xc
  jmp alltraps
8010706f:	e9 6d f9 ff ff       	jmp    801069e1 <alltraps>

80107074 <vector13>:
.globl vector13
vector13:
  pushl $13
80107074:	6a 0d                	push   $0xd
  jmp alltraps
80107076:	e9 66 f9 ff ff       	jmp    801069e1 <alltraps>

8010707b <vector14>:
.globl vector14
vector14:
  pushl $14
8010707b:	6a 0e                	push   $0xe
  jmp alltraps
8010707d:	e9 5f f9 ff ff       	jmp    801069e1 <alltraps>

80107082 <vector15>:
.globl vector15
vector15:
  pushl $0
80107082:	6a 00                	push   $0x0
  pushl $15
80107084:	6a 0f                	push   $0xf
  jmp alltraps
80107086:	e9 56 f9 ff ff       	jmp    801069e1 <alltraps>

8010708b <vector16>:
.globl vector16
vector16:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $16
8010708d:	6a 10                	push   $0x10
  jmp alltraps
8010708f:	e9 4d f9 ff ff       	jmp    801069e1 <alltraps>

80107094 <vector17>:
.globl vector17
vector17:
  pushl $17
80107094:	6a 11                	push   $0x11
  jmp alltraps
80107096:	e9 46 f9 ff ff       	jmp    801069e1 <alltraps>

8010709b <vector18>:
.globl vector18
vector18:
  pushl $0
8010709b:	6a 00                	push   $0x0
  pushl $18
8010709d:	6a 12                	push   $0x12
  jmp alltraps
8010709f:	e9 3d f9 ff ff       	jmp    801069e1 <alltraps>

801070a4 <vector19>:
.globl vector19
vector19:
  pushl $0
801070a4:	6a 00                	push   $0x0
  pushl $19
801070a6:	6a 13                	push   $0x13
  jmp alltraps
801070a8:	e9 34 f9 ff ff       	jmp    801069e1 <alltraps>

801070ad <vector20>:
.globl vector20
vector20:
  pushl $0
801070ad:	6a 00                	push   $0x0
  pushl $20
801070af:	6a 14                	push   $0x14
  jmp alltraps
801070b1:	e9 2b f9 ff ff       	jmp    801069e1 <alltraps>

801070b6 <vector21>:
.globl vector21
vector21:
  pushl $0
801070b6:	6a 00                	push   $0x0
  pushl $21
801070b8:	6a 15                	push   $0x15
  jmp alltraps
801070ba:	e9 22 f9 ff ff       	jmp    801069e1 <alltraps>

801070bf <vector22>:
.globl vector22
vector22:
  pushl $0
801070bf:	6a 00                	push   $0x0
  pushl $22
801070c1:	6a 16                	push   $0x16
  jmp alltraps
801070c3:	e9 19 f9 ff ff       	jmp    801069e1 <alltraps>

801070c8 <vector23>:
.globl vector23
vector23:
  pushl $0
801070c8:	6a 00                	push   $0x0
  pushl $23
801070ca:	6a 17                	push   $0x17
  jmp alltraps
801070cc:	e9 10 f9 ff ff       	jmp    801069e1 <alltraps>

801070d1 <vector24>:
.globl vector24
vector24:
  pushl $0
801070d1:	6a 00                	push   $0x0
  pushl $24
801070d3:	6a 18                	push   $0x18
  jmp alltraps
801070d5:	e9 07 f9 ff ff       	jmp    801069e1 <alltraps>

801070da <vector25>:
.globl vector25
vector25:
  pushl $0
801070da:	6a 00                	push   $0x0
  pushl $25
801070dc:	6a 19                	push   $0x19
  jmp alltraps
801070de:	e9 fe f8 ff ff       	jmp    801069e1 <alltraps>

801070e3 <vector26>:
.globl vector26
vector26:
  pushl $0
801070e3:	6a 00                	push   $0x0
  pushl $26
801070e5:	6a 1a                	push   $0x1a
  jmp alltraps
801070e7:	e9 f5 f8 ff ff       	jmp    801069e1 <alltraps>

801070ec <vector27>:
.globl vector27
vector27:
  pushl $0
801070ec:	6a 00                	push   $0x0
  pushl $27
801070ee:	6a 1b                	push   $0x1b
  jmp alltraps
801070f0:	e9 ec f8 ff ff       	jmp    801069e1 <alltraps>

801070f5 <vector28>:
.globl vector28
vector28:
  pushl $0
801070f5:	6a 00                	push   $0x0
  pushl $28
801070f7:	6a 1c                	push   $0x1c
  jmp alltraps
801070f9:	e9 e3 f8 ff ff       	jmp    801069e1 <alltraps>

801070fe <vector29>:
.globl vector29
vector29:
  pushl $0
801070fe:	6a 00                	push   $0x0
  pushl $29
80107100:	6a 1d                	push   $0x1d
  jmp alltraps
80107102:	e9 da f8 ff ff       	jmp    801069e1 <alltraps>

80107107 <vector30>:
.globl vector30
vector30:
  pushl $0
80107107:	6a 00                	push   $0x0
  pushl $30
80107109:	6a 1e                	push   $0x1e
  jmp alltraps
8010710b:	e9 d1 f8 ff ff       	jmp    801069e1 <alltraps>

80107110 <vector31>:
.globl vector31
vector31:
  pushl $0
80107110:	6a 00                	push   $0x0
  pushl $31
80107112:	6a 1f                	push   $0x1f
  jmp alltraps
80107114:	e9 c8 f8 ff ff       	jmp    801069e1 <alltraps>

80107119 <vector32>:
.globl vector32
vector32:
  pushl $0
80107119:	6a 00                	push   $0x0
  pushl $32
8010711b:	6a 20                	push   $0x20
  jmp alltraps
8010711d:	e9 bf f8 ff ff       	jmp    801069e1 <alltraps>

80107122 <vector33>:
.globl vector33
vector33:
  pushl $0
80107122:	6a 00                	push   $0x0
  pushl $33
80107124:	6a 21                	push   $0x21
  jmp alltraps
80107126:	e9 b6 f8 ff ff       	jmp    801069e1 <alltraps>

8010712b <vector34>:
.globl vector34
vector34:
  pushl $0
8010712b:	6a 00                	push   $0x0
  pushl $34
8010712d:	6a 22                	push   $0x22
  jmp alltraps
8010712f:	e9 ad f8 ff ff       	jmp    801069e1 <alltraps>

80107134 <vector35>:
.globl vector35
vector35:
  pushl $0
80107134:	6a 00                	push   $0x0
  pushl $35
80107136:	6a 23                	push   $0x23
  jmp alltraps
80107138:	e9 a4 f8 ff ff       	jmp    801069e1 <alltraps>

8010713d <vector36>:
.globl vector36
vector36:
  pushl $0
8010713d:	6a 00                	push   $0x0
  pushl $36
8010713f:	6a 24                	push   $0x24
  jmp alltraps
80107141:	e9 9b f8 ff ff       	jmp    801069e1 <alltraps>

80107146 <vector37>:
.globl vector37
vector37:
  pushl $0
80107146:	6a 00                	push   $0x0
  pushl $37
80107148:	6a 25                	push   $0x25
  jmp alltraps
8010714a:	e9 92 f8 ff ff       	jmp    801069e1 <alltraps>

8010714f <vector38>:
.globl vector38
vector38:
  pushl $0
8010714f:	6a 00                	push   $0x0
  pushl $38
80107151:	6a 26                	push   $0x26
  jmp alltraps
80107153:	e9 89 f8 ff ff       	jmp    801069e1 <alltraps>

80107158 <vector39>:
.globl vector39
vector39:
  pushl $0
80107158:	6a 00                	push   $0x0
  pushl $39
8010715a:	6a 27                	push   $0x27
  jmp alltraps
8010715c:	e9 80 f8 ff ff       	jmp    801069e1 <alltraps>

80107161 <vector40>:
.globl vector40
vector40:
  pushl $0
80107161:	6a 00                	push   $0x0
  pushl $40
80107163:	6a 28                	push   $0x28
  jmp alltraps
80107165:	e9 77 f8 ff ff       	jmp    801069e1 <alltraps>

8010716a <vector41>:
.globl vector41
vector41:
  pushl $0
8010716a:	6a 00                	push   $0x0
  pushl $41
8010716c:	6a 29                	push   $0x29
  jmp alltraps
8010716e:	e9 6e f8 ff ff       	jmp    801069e1 <alltraps>

80107173 <vector42>:
.globl vector42
vector42:
  pushl $0
80107173:	6a 00                	push   $0x0
  pushl $42
80107175:	6a 2a                	push   $0x2a
  jmp alltraps
80107177:	e9 65 f8 ff ff       	jmp    801069e1 <alltraps>

8010717c <vector43>:
.globl vector43
vector43:
  pushl $0
8010717c:	6a 00                	push   $0x0
  pushl $43
8010717e:	6a 2b                	push   $0x2b
  jmp alltraps
80107180:	e9 5c f8 ff ff       	jmp    801069e1 <alltraps>

80107185 <vector44>:
.globl vector44
vector44:
  pushl $0
80107185:	6a 00                	push   $0x0
  pushl $44
80107187:	6a 2c                	push   $0x2c
  jmp alltraps
80107189:	e9 53 f8 ff ff       	jmp    801069e1 <alltraps>

8010718e <vector45>:
.globl vector45
vector45:
  pushl $0
8010718e:	6a 00                	push   $0x0
  pushl $45
80107190:	6a 2d                	push   $0x2d
  jmp alltraps
80107192:	e9 4a f8 ff ff       	jmp    801069e1 <alltraps>

80107197 <vector46>:
.globl vector46
vector46:
  pushl $0
80107197:	6a 00                	push   $0x0
  pushl $46
80107199:	6a 2e                	push   $0x2e
  jmp alltraps
8010719b:	e9 41 f8 ff ff       	jmp    801069e1 <alltraps>

801071a0 <vector47>:
.globl vector47
vector47:
  pushl $0
801071a0:	6a 00                	push   $0x0
  pushl $47
801071a2:	6a 2f                	push   $0x2f
  jmp alltraps
801071a4:	e9 38 f8 ff ff       	jmp    801069e1 <alltraps>

801071a9 <vector48>:
.globl vector48
vector48:
  pushl $0
801071a9:	6a 00                	push   $0x0
  pushl $48
801071ab:	6a 30                	push   $0x30
  jmp alltraps
801071ad:	e9 2f f8 ff ff       	jmp    801069e1 <alltraps>

801071b2 <vector49>:
.globl vector49
vector49:
  pushl $0
801071b2:	6a 00                	push   $0x0
  pushl $49
801071b4:	6a 31                	push   $0x31
  jmp alltraps
801071b6:	e9 26 f8 ff ff       	jmp    801069e1 <alltraps>

801071bb <vector50>:
.globl vector50
vector50:
  pushl $0
801071bb:	6a 00                	push   $0x0
  pushl $50
801071bd:	6a 32                	push   $0x32
  jmp alltraps
801071bf:	e9 1d f8 ff ff       	jmp    801069e1 <alltraps>

801071c4 <vector51>:
.globl vector51
vector51:
  pushl $0
801071c4:	6a 00                	push   $0x0
  pushl $51
801071c6:	6a 33                	push   $0x33
  jmp alltraps
801071c8:	e9 14 f8 ff ff       	jmp    801069e1 <alltraps>

801071cd <vector52>:
.globl vector52
vector52:
  pushl $0
801071cd:	6a 00                	push   $0x0
  pushl $52
801071cf:	6a 34                	push   $0x34
  jmp alltraps
801071d1:	e9 0b f8 ff ff       	jmp    801069e1 <alltraps>

801071d6 <vector53>:
.globl vector53
vector53:
  pushl $0
801071d6:	6a 00                	push   $0x0
  pushl $53
801071d8:	6a 35                	push   $0x35
  jmp alltraps
801071da:	e9 02 f8 ff ff       	jmp    801069e1 <alltraps>

801071df <vector54>:
.globl vector54
vector54:
  pushl $0
801071df:	6a 00                	push   $0x0
  pushl $54
801071e1:	6a 36                	push   $0x36
  jmp alltraps
801071e3:	e9 f9 f7 ff ff       	jmp    801069e1 <alltraps>

801071e8 <vector55>:
.globl vector55
vector55:
  pushl $0
801071e8:	6a 00                	push   $0x0
  pushl $55
801071ea:	6a 37                	push   $0x37
  jmp alltraps
801071ec:	e9 f0 f7 ff ff       	jmp    801069e1 <alltraps>

801071f1 <vector56>:
.globl vector56
vector56:
  pushl $0
801071f1:	6a 00                	push   $0x0
  pushl $56
801071f3:	6a 38                	push   $0x38
  jmp alltraps
801071f5:	e9 e7 f7 ff ff       	jmp    801069e1 <alltraps>

801071fa <vector57>:
.globl vector57
vector57:
  pushl $0
801071fa:	6a 00                	push   $0x0
  pushl $57
801071fc:	6a 39                	push   $0x39
  jmp alltraps
801071fe:	e9 de f7 ff ff       	jmp    801069e1 <alltraps>

80107203 <vector58>:
.globl vector58
vector58:
  pushl $0
80107203:	6a 00                	push   $0x0
  pushl $58
80107205:	6a 3a                	push   $0x3a
  jmp alltraps
80107207:	e9 d5 f7 ff ff       	jmp    801069e1 <alltraps>

8010720c <vector59>:
.globl vector59
vector59:
  pushl $0
8010720c:	6a 00                	push   $0x0
  pushl $59
8010720e:	6a 3b                	push   $0x3b
  jmp alltraps
80107210:	e9 cc f7 ff ff       	jmp    801069e1 <alltraps>

80107215 <vector60>:
.globl vector60
vector60:
  pushl $0
80107215:	6a 00                	push   $0x0
  pushl $60
80107217:	6a 3c                	push   $0x3c
  jmp alltraps
80107219:	e9 c3 f7 ff ff       	jmp    801069e1 <alltraps>

8010721e <vector61>:
.globl vector61
vector61:
  pushl $0
8010721e:	6a 00                	push   $0x0
  pushl $61
80107220:	6a 3d                	push   $0x3d
  jmp alltraps
80107222:	e9 ba f7 ff ff       	jmp    801069e1 <alltraps>

80107227 <vector62>:
.globl vector62
vector62:
  pushl $0
80107227:	6a 00                	push   $0x0
  pushl $62
80107229:	6a 3e                	push   $0x3e
  jmp alltraps
8010722b:	e9 b1 f7 ff ff       	jmp    801069e1 <alltraps>

80107230 <vector63>:
.globl vector63
vector63:
  pushl $0
80107230:	6a 00                	push   $0x0
  pushl $63
80107232:	6a 3f                	push   $0x3f
  jmp alltraps
80107234:	e9 a8 f7 ff ff       	jmp    801069e1 <alltraps>

80107239 <vector64>:
.globl vector64
vector64:
  pushl $0
80107239:	6a 00                	push   $0x0
  pushl $64
8010723b:	6a 40                	push   $0x40
  jmp alltraps
8010723d:	e9 9f f7 ff ff       	jmp    801069e1 <alltraps>

80107242 <vector65>:
.globl vector65
vector65:
  pushl $0
80107242:	6a 00                	push   $0x0
  pushl $65
80107244:	6a 41                	push   $0x41
  jmp alltraps
80107246:	e9 96 f7 ff ff       	jmp    801069e1 <alltraps>

8010724b <vector66>:
.globl vector66
vector66:
  pushl $0
8010724b:	6a 00                	push   $0x0
  pushl $66
8010724d:	6a 42                	push   $0x42
  jmp alltraps
8010724f:	e9 8d f7 ff ff       	jmp    801069e1 <alltraps>

80107254 <vector67>:
.globl vector67
vector67:
  pushl $0
80107254:	6a 00                	push   $0x0
  pushl $67
80107256:	6a 43                	push   $0x43
  jmp alltraps
80107258:	e9 84 f7 ff ff       	jmp    801069e1 <alltraps>

8010725d <vector68>:
.globl vector68
vector68:
  pushl $0
8010725d:	6a 00                	push   $0x0
  pushl $68
8010725f:	6a 44                	push   $0x44
  jmp alltraps
80107261:	e9 7b f7 ff ff       	jmp    801069e1 <alltraps>

80107266 <vector69>:
.globl vector69
vector69:
  pushl $0
80107266:	6a 00                	push   $0x0
  pushl $69
80107268:	6a 45                	push   $0x45
  jmp alltraps
8010726a:	e9 72 f7 ff ff       	jmp    801069e1 <alltraps>

8010726f <vector70>:
.globl vector70
vector70:
  pushl $0
8010726f:	6a 00                	push   $0x0
  pushl $70
80107271:	6a 46                	push   $0x46
  jmp alltraps
80107273:	e9 69 f7 ff ff       	jmp    801069e1 <alltraps>

80107278 <vector71>:
.globl vector71
vector71:
  pushl $0
80107278:	6a 00                	push   $0x0
  pushl $71
8010727a:	6a 47                	push   $0x47
  jmp alltraps
8010727c:	e9 60 f7 ff ff       	jmp    801069e1 <alltraps>

80107281 <vector72>:
.globl vector72
vector72:
  pushl $0
80107281:	6a 00                	push   $0x0
  pushl $72
80107283:	6a 48                	push   $0x48
  jmp alltraps
80107285:	e9 57 f7 ff ff       	jmp    801069e1 <alltraps>

8010728a <vector73>:
.globl vector73
vector73:
  pushl $0
8010728a:	6a 00                	push   $0x0
  pushl $73
8010728c:	6a 49                	push   $0x49
  jmp alltraps
8010728e:	e9 4e f7 ff ff       	jmp    801069e1 <alltraps>

80107293 <vector74>:
.globl vector74
vector74:
  pushl $0
80107293:	6a 00                	push   $0x0
  pushl $74
80107295:	6a 4a                	push   $0x4a
  jmp alltraps
80107297:	e9 45 f7 ff ff       	jmp    801069e1 <alltraps>

8010729c <vector75>:
.globl vector75
vector75:
  pushl $0
8010729c:	6a 00                	push   $0x0
  pushl $75
8010729e:	6a 4b                	push   $0x4b
  jmp alltraps
801072a0:	e9 3c f7 ff ff       	jmp    801069e1 <alltraps>

801072a5 <vector76>:
.globl vector76
vector76:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $76
801072a7:	6a 4c                	push   $0x4c
  jmp alltraps
801072a9:	e9 33 f7 ff ff       	jmp    801069e1 <alltraps>

801072ae <vector77>:
.globl vector77
vector77:
  pushl $0
801072ae:	6a 00                	push   $0x0
  pushl $77
801072b0:	6a 4d                	push   $0x4d
  jmp alltraps
801072b2:	e9 2a f7 ff ff       	jmp    801069e1 <alltraps>

801072b7 <vector78>:
.globl vector78
vector78:
  pushl $0
801072b7:	6a 00                	push   $0x0
  pushl $78
801072b9:	6a 4e                	push   $0x4e
  jmp alltraps
801072bb:	e9 21 f7 ff ff       	jmp    801069e1 <alltraps>

801072c0 <vector79>:
.globl vector79
vector79:
  pushl $0
801072c0:	6a 00                	push   $0x0
  pushl $79
801072c2:	6a 4f                	push   $0x4f
  jmp alltraps
801072c4:	e9 18 f7 ff ff       	jmp    801069e1 <alltraps>

801072c9 <vector80>:
.globl vector80
vector80:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $80
801072cb:	6a 50                	push   $0x50
  jmp alltraps
801072cd:	e9 0f f7 ff ff       	jmp    801069e1 <alltraps>

801072d2 <vector81>:
.globl vector81
vector81:
  pushl $0
801072d2:	6a 00                	push   $0x0
  pushl $81
801072d4:	6a 51                	push   $0x51
  jmp alltraps
801072d6:	e9 06 f7 ff ff       	jmp    801069e1 <alltraps>

801072db <vector82>:
.globl vector82
vector82:
  pushl $0
801072db:	6a 00                	push   $0x0
  pushl $82
801072dd:	6a 52                	push   $0x52
  jmp alltraps
801072df:	e9 fd f6 ff ff       	jmp    801069e1 <alltraps>

801072e4 <vector83>:
.globl vector83
vector83:
  pushl $0
801072e4:	6a 00                	push   $0x0
  pushl $83
801072e6:	6a 53                	push   $0x53
  jmp alltraps
801072e8:	e9 f4 f6 ff ff       	jmp    801069e1 <alltraps>

801072ed <vector84>:
.globl vector84
vector84:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $84
801072ef:	6a 54                	push   $0x54
  jmp alltraps
801072f1:	e9 eb f6 ff ff       	jmp    801069e1 <alltraps>

801072f6 <vector85>:
.globl vector85
vector85:
  pushl $0
801072f6:	6a 00                	push   $0x0
  pushl $85
801072f8:	6a 55                	push   $0x55
  jmp alltraps
801072fa:	e9 e2 f6 ff ff       	jmp    801069e1 <alltraps>

801072ff <vector86>:
.globl vector86
vector86:
  pushl $0
801072ff:	6a 00                	push   $0x0
  pushl $86
80107301:	6a 56                	push   $0x56
  jmp alltraps
80107303:	e9 d9 f6 ff ff       	jmp    801069e1 <alltraps>

80107308 <vector87>:
.globl vector87
vector87:
  pushl $0
80107308:	6a 00                	push   $0x0
  pushl $87
8010730a:	6a 57                	push   $0x57
  jmp alltraps
8010730c:	e9 d0 f6 ff ff       	jmp    801069e1 <alltraps>

80107311 <vector88>:
.globl vector88
vector88:
  pushl $0
80107311:	6a 00                	push   $0x0
  pushl $88
80107313:	6a 58                	push   $0x58
  jmp alltraps
80107315:	e9 c7 f6 ff ff       	jmp    801069e1 <alltraps>

8010731a <vector89>:
.globl vector89
vector89:
  pushl $0
8010731a:	6a 00                	push   $0x0
  pushl $89
8010731c:	6a 59                	push   $0x59
  jmp alltraps
8010731e:	e9 be f6 ff ff       	jmp    801069e1 <alltraps>

80107323 <vector90>:
.globl vector90
vector90:
  pushl $0
80107323:	6a 00                	push   $0x0
  pushl $90
80107325:	6a 5a                	push   $0x5a
  jmp alltraps
80107327:	e9 b5 f6 ff ff       	jmp    801069e1 <alltraps>

8010732c <vector91>:
.globl vector91
vector91:
  pushl $0
8010732c:	6a 00                	push   $0x0
  pushl $91
8010732e:	6a 5b                	push   $0x5b
  jmp alltraps
80107330:	e9 ac f6 ff ff       	jmp    801069e1 <alltraps>

80107335 <vector92>:
.globl vector92
vector92:
  pushl $0
80107335:	6a 00                	push   $0x0
  pushl $92
80107337:	6a 5c                	push   $0x5c
  jmp alltraps
80107339:	e9 a3 f6 ff ff       	jmp    801069e1 <alltraps>

8010733e <vector93>:
.globl vector93
vector93:
  pushl $0
8010733e:	6a 00                	push   $0x0
  pushl $93
80107340:	6a 5d                	push   $0x5d
  jmp alltraps
80107342:	e9 9a f6 ff ff       	jmp    801069e1 <alltraps>

80107347 <vector94>:
.globl vector94
vector94:
  pushl $0
80107347:	6a 00                	push   $0x0
  pushl $94
80107349:	6a 5e                	push   $0x5e
  jmp alltraps
8010734b:	e9 91 f6 ff ff       	jmp    801069e1 <alltraps>

80107350 <vector95>:
.globl vector95
vector95:
  pushl $0
80107350:	6a 00                	push   $0x0
  pushl $95
80107352:	6a 5f                	push   $0x5f
  jmp alltraps
80107354:	e9 88 f6 ff ff       	jmp    801069e1 <alltraps>

80107359 <vector96>:
.globl vector96
vector96:
  pushl $0
80107359:	6a 00                	push   $0x0
  pushl $96
8010735b:	6a 60                	push   $0x60
  jmp alltraps
8010735d:	e9 7f f6 ff ff       	jmp    801069e1 <alltraps>

80107362 <vector97>:
.globl vector97
vector97:
  pushl $0
80107362:	6a 00                	push   $0x0
  pushl $97
80107364:	6a 61                	push   $0x61
  jmp alltraps
80107366:	e9 76 f6 ff ff       	jmp    801069e1 <alltraps>

8010736b <vector98>:
.globl vector98
vector98:
  pushl $0
8010736b:	6a 00                	push   $0x0
  pushl $98
8010736d:	6a 62                	push   $0x62
  jmp alltraps
8010736f:	e9 6d f6 ff ff       	jmp    801069e1 <alltraps>

80107374 <vector99>:
.globl vector99
vector99:
  pushl $0
80107374:	6a 00                	push   $0x0
  pushl $99
80107376:	6a 63                	push   $0x63
  jmp alltraps
80107378:	e9 64 f6 ff ff       	jmp    801069e1 <alltraps>

8010737d <vector100>:
.globl vector100
vector100:
  pushl $0
8010737d:	6a 00                	push   $0x0
  pushl $100
8010737f:	6a 64                	push   $0x64
  jmp alltraps
80107381:	e9 5b f6 ff ff       	jmp    801069e1 <alltraps>

80107386 <vector101>:
.globl vector101
vector101:
  pushl $0
80107386:	6a 00                	push   $0x0
  pushl $101
80107388:	6a 65                	push   $0x65
  jmp alltraps
8010738a:	e9 52 f6 ff ff       	jmp    801069e1 <alltraps>

8010738f <vector102>:
.globl vector102
vector102:
  pushl $0
8010738f:	6a 00                	push   $0x0
  pushl $102
80107391:	6a 66                	push   $0x66
  jmp alltraps
80107393:	e9 49 f6 ff ff       	jmp    801069e1 <alltraps>

80107398 <vector103>:
.globl vector103
vector103:
  pushl $0
80107398:	6a 00                	push   $0x0
  pushl $103
8010739a:	6a 67                	push   $0x67
  jmp alltraps
8010739c:	e9 40 f6 ff ff       	jmp    801069e1 <alltraps>

801073a1 <vector104>:
.globl vector104
vector104:
  pushl $0
801073a1:	6a 00                	push   $0x0
  pushl $104
801073a3:	6a 68                	push   $0x68
  jmp alltraps
801073a5:	e9 37 f6 ff ff       	jmp    801069e1 <alltraps>

801073aa <vector105>:
.globl vector105
vector105:
  pushl $0
801073aa:	6a 00                	push   $0x0
  pushl $105
801073ac:	6a 69                	push   $0x69
  jmp alltraps
801073ae:	e9 2e f6 ff ff       	jmp    801069e1 <alltraps>

801073b3 <vector106>:
.globl vector106
vector106:
  pushl $0
801073b3:	6a 00                	push   $0x0
  pushl $106
801073b5:	6a 6a                	push   $0x6a
  jmp alltraps
801073b7:	e9 25 f6 ff ff       	jmp    801069e1 <alltraps>

801073bc <vector107>:
.globl vector107
vector107:
  pushl $0
801073bc:	6a 00                	push   $0x0
  pushl $107
801073be:	6a 6b                	push   $0x6b
  jmp alltraps
801073c0:	e9 1c f6 ff ff       	jmp    801069e1 <alltraps>

801073c5 <vector108>:
.globl vector108
vector108:
  pushl $0
801073c5:	6a 00                	push   $0x0
  pushl $108
801073c7:	6a 6c                	push   $0x6c
  jmp alltraps
801073c9:	e9 13 f6 ff ff       	jmp    801069e1 <alltraps>

801073ce <vector109>:
.globl vector109
vector109:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $109
801073d0:	6a 6d                	push   $0x6d
  jmp alltraps
801073d2:	e9 0a f6 ff ff       	jmp    801069e1 <alltraps>

801073d7 <vector110>:
.globl vector110
vector110:
  pushl $0
801073d7:	6a 00                	push   $0x0
  pushl $110
801073d9:	6a 6e                	push   $0x6e
  jmp alltraps
801073db:	e9 01 f6 ff ff       	jmp    801069e1 <alltraps>

801073e0 <vector111>:
.globl vector111
vector111:
  pushl $0
801073e0:	6a 00                	push   $0x0
  pushl $111
801073e2:	6a 6f                	push   $0x6f
  jmp alltraps
801073e4:	e9 f8 f5 ff ff       	jmp    801069e1 <alltraps>

801073e9 <vector112>:
.globl vector112
vector112:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $112
801073eb:	6a 70                	push   $0x70
  jmp alltraps
801073ed:	e9 ef f5 ff ff       	jmp    801069e1 <alltraps>

801073f2 <vector113>:
.globl vector113
vector113:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $113
801073f4:	6a 71                	push   $0x71
  jmp alltraps
801073f6:	e9 e6 f5 ff ff       	jmp    801069e1 <alltraps>

801073fb <vector114>:
.globl vector114
vector114:
  pushl $0
801073fb:	6a 00                	push   $0x0
  pushl $114
801073fd:	6a 72                	push   $0x72
  jmp alltraps
801073ff:	e9 dd f5 ff ff       	jmp    801069e1 <alltraps>

80107404 <vector115>:
.globl vector115
vector115:
  pushl $0
80107404:	6a 00                	push   $0x0
  pushl $115
80107406:	6a 73                	push   $0x73
  jmp alltraps
80107408:	e9 d4 f5 ff ff       	jmp    801069e1 <alltraps>

8010740d <vector116>:
.globl vector116
vector116:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $116
8010740f:	6a 74                	push   $0x74
  jmp alltraps
80107411:	e9 cb f5 ff ff       	jmp    801069e1 <alltraps>

80107416 <vector117>:
.globl vector117
vector117:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $117
80107418:	6a 75                	push   $0x75
  jmp alltraps
8010741a:	e9 c2 f5 ff ff       	jmp    801069e1 <alltraps>

8010741f <vector118>:
.globl vector118
vector118:
  pushl $0
8010741f:	6a 00                	push   $0x0
  pushl $118
80107421:	6a 76                	push   $0x76
  jmp alltraps
80107423:	e9 b9 f5 ff ff       	jmp    801069e1 <alltraps>

80107428 <vector119>:
.globl vector119
vector119:
  pushl $0
80107428:	6a 00                	push   $0x0
  pushl $119
8010742a:	6a 77                	push   $0x77
  jmp alltraps
8010742c:	e9 b0 f5 ff ff       	jmp    801069e1 <alltraps>

80107431 <vector120>:
.globl vector120
vector120:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $120
80107433:	6a 78                	push   $0x78
  jmp alltraps
80107435:	e9 a7 f5 ff ff       	jmp    801069e1 <alltraps>

8010743a <vector121>:
.globl vector121
vector121:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $121
8010743c:	6a 79                	push   $0x79
  jmp alltraps
8010743e:	e9 9e f5 ff ff       	jmp    801069e1 <alltraps>

80107443 <vector122>:
.globl vector122
vector122:
  pushl $0
80107443:	6a 00                	push   $0x0
  pushl $122
80107445:	6a 7a                	push   $0x7a
  jmp alltraps
80107447:	e9 95 f5 ff ff       	jmp    801069e1 <alltraps>

8010744c <vector123>:
.globl vector123
vector123:
  pushl $0
8010744c:	6a 00                	push   $0x0
  pushl $123
8010744e:	6a 7b                	push   $0x7b
  jmp alltraps
80107450:	e9 8c f5 ff ff       	jmp    801069e1 <alltraps>

80107455 <vector124>:
.globl vector124
vector124:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $124
80107457:	6a 7c                	push   $0x7c
  jmp alltraps
80107459:	e9 83 f5 ff ff       	jmp    801069e1 <alltraps>

8010745e <vector125>:
.globl vector125
vector125:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $125
80107460:	6a 7d                	push   $0x7d
  jmp alltraps
80107462:	e9 7a f5 ff ff       	jmp    801069e1 <alltraps>

80107467 <vector126>:
.globl vector126
vector126:
  pushl $0
80107467:	6a 00                	push   $0x0
  pushl $126
80107469:	6a 7e                	push   $0x7e
  jmp alltraps
8010746b:	e9 71 f5 ff ff       	jmp    801069e1 <alltraps>

80107470 <vector127>:
.globl vector127
vector127:
  pushl $0
80107470:	6a 00                	push   $0x0
  pushl $127
80107472:	6a 7f                	push   $0x7f
  jmp alltraps
80107474:	e9 68 f5 ff ff       	jmp    801069e1 <alltraps>

80107479 <vector128>:
.globl vector128
vector128:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $128
8010747b:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107480:	e9 5c f5 ff ff       	jmp    801069e1 <alltraps>

80107485 <vector129>:
.globl vector129
vector129:
  pushl $0
80107485:	6a 00                	push   $0x0
  pushl $129
80107487:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010748c:	e9 50 f5 ff ff       	jmp    801069e1 <alltraps>

80107491 <vector130>:
.globl vector130
vector130:
  pushl $0
80107491:	6a 00                	push   $0x0
  pushl $130
80107493:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107498:	e9 44 f5 ff ff       	jmp    801069e1 <alltraps>

8010749d <vector131>:
.globl vector131
vector131:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $131
8010749f:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801074a4:	e9 38 f5 ff ff       	jmp    801069e1 <alltraps>

801074a9 <vector132>:
.globl vector132
vector132:
  pushl $0
801074a9:	6a 00                	push   $0x0
  pushl $132
801074ab:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801074b0:	e9 2c f5 ff ff       	jmp    801069e1 <alltraps>

801074b5 <vector133>:
.globl vector133
vector133:
  pushl $0
801074b5:	6a 00                	push   $0x0
  pushl $133
801074b7:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801074bc:	e9 20 f5 ff ff       	jmp    801069e1 <alltraps>

801074c1 <vector134>:
.globl vector134
vector134:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $134
801074c3:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801074c8:	e9 14 f5 ff ff       	jmp    801069e1 <alltraps>

801074cd <vector135>:
.globl vector135
vector135:
  pushl $0
801074cd:	6a 00                	push   $0x0
  pushl $135
801074cf:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801074d4:	e9 08 f5 ff ff       	jmp    801069e1 <alltraps>

801074d9 <vector136>:
.globl vector136
vector136:
  pushl $0
801074d9:	6a 00                	push   $0x0
  pushl $136
801074db:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801074e0:	e9 fc f4 ff ff       	jmp    801069e1 <alltraps>

801074e5 <vector137>:
.globl vector137
vector137:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $137
801074e7:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801074ec:	e9 f0 f4 ff ff       	jmp    801069e1 <alltraps>

801074f1 <vector138>:
.globl vector138
vector138:
  pushl $0
801074f1:	6a 00                	push   $0x0
  pushl $138
801074f3:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801074f8:	e9 e4 f4 ff ff       	jmp    801069e1 <alltraps>

801074fd <vector139>:
.globl vector139
vector139:
  pushl $0
801074fd:	6a 00                	push   $0x0
  pushl $139
801074ff:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107504:	e9 d8 f4 ff ff       	jmp    801069e1 <alltraps>

80107509 <vector140>:
.globl vector140
vector140:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $140
8010750b:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107510:	e9 cc f4 ff ff       	jmp    801069e1 <alltraps>

80107515 <vector141>:
.globl vector141
vector141:
  pushl $0
80107515:	6a 00                	push   $0x0
  pushl $141
80107517:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010751c:	e9 c0 f4 ff ff       	jmp    801069e1 <alltraps>

80107521 <vector142>:
.globl vector142
vector142:
  pushl $0
80107521:	6a 00                	push   $0x0
  pushl $142
80107523:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107528:	e9 b4 f4 ff ff       	jmp    801069e1 <alltraps>

8010752d <vector143>:
.globl vector143
vector143:
  pushl $0
8010752d:	6a 00                	push   $0x0
  pushl $143
8010752f:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107534:	e9 a8 f4 ff ff       	jmp    801069e1 <alltraps>

80107539 <vector144>:
.globl vector144
vector144:
  pushl $0
80107539:	6a 00                	push   $0x0
  pushl $144
8010753b:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107540:	e9 9c f4 ff ff       	jmp    801069e1 <alltraps>

80107545 <vector145>:
.globl vector145
vector145:
  pushl $0
80107545:	6a 00                	push   $0x0
  pushl $145
80107547:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010754c:	e9 90 f4 ff ff       	jmp    801069e1 <alltraps>

80107551 <vector146>:
.globl vector146
vector146:
  pushl $0
80107551:	6a 00                	push   $0x0
  pushl $146
80107553:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107558:	e9 84 f4 ff ff       	jmp    801069e1 <alltraps>

8010755d <vector147>:
.globl vector147
vector147:
  pushl $0
8010755d:	6a 00                	push   $0x0
  pushl $147
8010755f:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107564:	e9 78 f4 ff ff       	jmp    801069e1 <alltraps>

80107569 <vector148>:
.globl vector148
vector148:
  pushl $0
80107569:	6a 00                	push   $0x0
  pushl $148
8010756b:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107570:	e9 6c f4 ff ff       	jmp    801069e1 <alltraps>

80107575 <vector149>:
.globl vector149
vector149:
  pushl $0
80107575:	6a 00                	push   $0x0
  pushl $149
80107577:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010757c:	e9 60 f4 ff ff       	jmp    801069e1 <alltraps>

80107581 <vector150>:
.globl vector150
vector150:
  pushl $0
80107581:	6a 00                	push   $0x0
  pushl $150
80107583:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107588:	e9 54 f4 ff ff       	jmp    801069e1 <alltraps>

8010758d <vector151>:
.globl vector151
vector151:
  pushl $0
8010758d:	6a 00                	push   $0x0
  pushl $151
8010758f:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107594:	e9 48 f4 ff ff       	jmp    801069e1 <alltraps>

80107599 <vector152>:
.globl vector152
vector152:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $152
8010759b:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801075a0:	e9 3c f4 ff ff       	jmp    801069e1 <alltraps>

801075a5 <vector153>:
.globl vector153
vector153:
  pushl $0
801075a5:	6a 00                	push   $0x0
  pushl $153
801075a7:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801075ac:	e9 30 f4 ff ff       	jmp    801069e1 <alltraps>

801075b1 <vector154>:
.globl vector154
vector154:
  pushl $0
801075b1:	6a 00                	push   $0x0
  pushl $154
801075b3:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801075b8:	e9 24 f4 ff ff       	jmp    801069e1 <alltraps>

801075bd <vector155>:
.globl vector155
vector155:
  pushl $0
801075bd:	6a 00                	push   $0x0
  pushl $155
801075bf:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801075c4:	e9 18 f4 ff ff       	jmp    801069e1 <alltraps>

801075c9 <vector156>:
.globl vector156
vector156:
  pushl $0
801075c9:	6a 00                	push   $0x0
  pushl $156
801075cb:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801075d0:	e9 0c f4 ff ff       	jmp    801069e1 <alltraps>

801075d5 <vector157>:
.globl vector157
vector157:
  pushl $0
801075d5:	6a 00                	push   $0x0
  pushl $157
801075d7:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801075dc:	e9 00 f4 ff ff       	jmp    801069e1 <alltraps>

801075e1 <vector158>:
.globl vector158
vector158:
  pushl $0
801075e1:	6a 00                	push   $0x0
  pushl $158
801075e3:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801075e8:	e9 f4 f3 ff ff       	jmp    801069e1 <alltraps>

801075ed <vector159>:
.globl vector159
vector159:
  pushl $0
801075ed:	6a 00                	push   $0x0
  pushl $159
801075ef:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801075f4:	e9 e8 f3 ff ff       	jmp    801069e1 <alltraps>

801075f9 <vector160>:
.globl vector160
vector160:
  pushl $0
801075f9:	6a 00                	push   $0x0
  pushl $160
801075fb:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107600:	e9 dc f3 ff ff       	jmp    801069e1 <alltraps>

80107605 <vector161>:
.globl vector161
vector161:
  pushl $0
80107605:	6a 00                	push   $0x0
  pushl $161
80107607:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010760c:	e9 d0 f3 ff ff       	jmp    801069e1 <alltraps>

80107611 <vector162>:
.globl vector162
vector162:
  pushl $0
80107611:	6a 00                	push   $0x0
  pushl $162
80107613:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107618:	e9 c4 f3 ff ff       	jmp    801069e1 <alltraps>

8010761d <vector163>:
.globl vector163
vector163:
  pushl $0
8010761d:	6a 00                	push   $0x0
  pushl $163
8010761f:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107624:	e9 b8 f3 ff ff       	jmp    801069e1 <alltraps>

80107629 <vector164>:
.globl vector164
vector164:
  pushl $0
80107629:	6a 00                	push   $0x0
  pushl $164
8010762b:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107630:	e9 ac f3 ff ff       	jmp    801069e1 <alltraps>

80107635 <vector165>:
.globl vector165
vector165:
  pushl $0
80107635:	6a 00                	push   $0x0
  pushl $165
80107637:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010763c:	e9 a0 f3 ff ff       	jmp    801069e1 <alltraps>

80107641 <vector166>:
.globl vector166
vector166:
  pushl $0
80107641:	6a 00                	push   $0x0
  pushl $166
80107643:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107648:	e9 94 f3 ff ff       	jmp    801069e1 <alltraps>

8010764d <vector167>:
.globl vector167
vector167:
  pushl $0
8010764d:	6a 00                	push   $0x0
  pushl $167
8010764f:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107654:	e9 88 f3 ff ff       	jmp    801069e1 <alltraps>

80107659 <vector168>:
.globl vector168
vector168:
  pushl $0
80107659:	6a 00                	push   $0x0
  pushl $168
8010765b:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107660:	e9 7c f3 ff ff       	jmp    801069e1 <alltraps>

80107665 <vector169>:
.globl vector169
vector169:
  pushl $0
80107665:	6a 00                	push   $0x0
  pushl $169
80107667:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010766c:	e9 70 f3 ff ff       	jmp    801069e1 <alltraps>

80107671 <vector170>:
.globl vector170
vector170:
  pushl $0
80107671:	6a 00                	push   $0x0
  pushl $170
80107673:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107678:	e9 64 f3 ff ff       	jmp    801069e1 <alltraps>

8010767d <vector171>:
.globl vector171
vector171:
  pushl $0
8010767d:	6a 00                	push   $0x0
  pushl $171
8010767f:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107684:	e9 58 f3 ff ff       	jmp    801069e1 <alltraps>

80107689 <vector172>:
.globl vector172
vector172:
  pushl $0
80107689:	6a 00                	push   $0x0
  pushl $172
8010768b:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107690:	e9 4c f3 ff ff       	jmp    801069e1 <alltraps>

80107695 <vector173>:
.globl vector173
vector173:
  pushl $0
80107695:	6a 00                	push   $0x0
  pushl $173
80107697:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010769c:	e9 40 f3 ff ff       	jmp    801069e1 <alltraps>

801076a1 <vector174>:
.globl vector174
vector174:
  pushl $0
801076a1:	6a 00                	push   $0x0
  pushl $174
801076a3:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801076a8:	e9 34 f3 ff ff       	jmp    801069e1 <alltraps>

801076ad <vector175>:
.globl vector175
vector175:
  pushl $0
801076ad:	6a 00                	push   $0x0
  pushl $175
801076af:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801076b4:	e9 28 f3 ff ff       	jmp    801069e1 <alltraps>

801076b9 <vector176>:
.globl vector176
vector176:
  pushl $0
801076b9:	6a 00                	push   $0x0
  pushl $176
801076bb:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801076c0:	e9 1c f3 ff ff       	jmp    801069e1 <alltraps>

801076c5 <vector177>:
.globl vector177
vector177:
  pushl $0
801076c5:	6a 00                	push   $0x0
  pushl $177
801076c7:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801076cc:	e9 10 f3 ff ff       	jmp    801069e1 <alltraps>

801076d1 <vector178>:
.globl vector178
vector178:
  pushl $0
801076d1:	6a 00                	push   $0x0
  pushl $178
801076d3:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801076d8:	e9 04 f3 ff ff       	jmp    801069e1 <alltraps>

801076dd <vector179>:
.globl vector179
vector179:
  pushl $0
801076dd:	6a 00                	push   $0x0
  pushl $179
801076df:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801076e4:	e9 f8 f2 ff ff       	jmp    801069e1 <alltraps>

801076e9 <vector180>:
.globl vector180
vector180:
  pushl $0
801076e9:	6a 00                	push   $0x0
  pushl $180
801076eb:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801076f0:	e9 ec f2 ff ff       	jmp    801069e1 <alltraps>

801076f5 <vector181>:
.globl vector181
vector181:
  pushl $0
801076f5:	6a 00                	push   $0x0
  pushl $181
801076f7:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801076fc:	e9 e0 f2 ff ff       	jmp    801069e1 <alltraps>

80107701 <vector182>:
.globl vector182
vector182:
  pushl $0
80107701:	6a 00                	push   $0x0
  pushl $182
80107703:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107708:	e9 d4 f2 ff ff       	jmp    801069e1 <alltraps>

8010770d <vector183>:
.globl vector183
vector183:
  pushl $0
8010770d:	6a 00                	push   $0x0
  pushl $183
8010770f:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107714:	e9 c8 f2 ff ff       	jmp    801069e1 <alltraps>

80107719 <vector184>:
.globl vector184
vector184:
  pushl $0
80107719:	6a 00                	push   $0x0
  pushl $184
8010771b:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107720:	e9 bc f2 ff ff       	jmp    801069e1 <alltraps>

80107725 <vector185>:
.globl vector185
vector185:
  pushl $0
80107725:	6a 00                	push   $0x0
  pushl $185
80107727:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010772c:	e9 b0 f2 ff ff       	jmp    801069e1 <alltraps>

80107731 <vector186>:
.globl vector186
vector186:
  pushl $0
80107731:	6a 00                	push   $0x0
  pushl $186
80107733:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107738:	e9 a4 f2 ff ff       	jmp    801069e1 <alltraps>

8010773d <vector187>:
.globl vector187
vector187:
  pushl $0
8010773d:	6a 00                	push   $0x0
  pushl $187
8010773f:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107744:	e9 98 f2 ff ff       	jmp    801069e1 <alltraps>

80107749 <vector188>:
.globl vector188
vector188:
  pushl $0
80107749:	6a 00                	push   $0x0
  pushl $188
8010774b:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107750:	e9 8c f2 ff ff       	jmp    801069e1 <alltraps>

80107755 <vector189>:
.globl vector189
vector189:
  pushl $0
80107755:	6a 00                	push   $0x0
  pushl $189
80107757:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010775c:	e9 80 f2 ff ff       	jmp    801069e1 <alltraps>

80107761 <vector190>:
.globl vector190
vector190:
  pushl $0
80107761:	6a 00                	push   $0x0
  pushl $190
80107763:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107768:	e9 74 f2 ff ff       	jmp    801069e1 <alltraps>

8010776d <vector191>:
.globl vector191
vector191:
  pushl $0
8010776d:	6a 00                	push   $0x0
  pushl $191
8010776f:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107774:	e9 68 f2 ff ff       	jmp    801069e1 <alltraps>

80107779 <vector192>:
.globl vector192
vector192:
  pushl $0
80107779:	6a 00                	push   $0x0
  pushl $192
8010777b:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107780:	e9 5c f2 ff ff       	jmp    801069e1 <alltraps>

80107785 <vector193>:
.globl vector193
vector193:
  pushl $0
80107785:	6a 00                	push   $0x0
  pushl $193
80107787:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010778c:	e9 50 f2 ff ff       	jmp    801069e1 <alltraps>

80107791 <vector194>:
.globl vector194
vector194:
  pushl $0
80107791:	6a 00                	push   $0x0
  pushl $194
80107793:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107798:	e9 44 f2 ff ff       	jmp    801069e1 <alltraps>

8010779d <vector195>:
.globl vector195
vector195:
  pushl $0
8010779d:	6a 00                	push   $0x0
  pushl $195
8010779f:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801077a4:	e9 38 f2 ff ff       	jmp    801069e1 <alltraps>

801077a9 <vector196>:
.globl vector196
vector196:
  pushl $0
801077a9:	6a 00                	push   $0x0
  pushl $196
801077ab:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801077b0:	e9 2c f2 ff ff       	jmp    801069e1 <alltraps>

801077b5 <vector197>:
.globl vector197
vector197:
  pushl $0
801077b5:	6a 00                	push   $0x0
  pushl $197
801077b7:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801077bc:	e9 20 f2 ff ff       	jmp    801069e1 <alltraps>

801077c1 <vector198>:
.globl vector198
vector198:
  pushl $0
801077c1:	6a 00                	push   $0x0
  pushl $198
801077c3:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801077c8:	e9 14 f2 ff ff       	jmp    801069e1 <alltraps>

801077cd <vector199>:
.globl vector199
vector199:
  pushl $0
801077cd:	6a 00                	push   $0x0
  pushl $199
801077cf:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801077d4:	e9 08 f2 ff ff       	jmp    801069e1 <alltraps>

801077d9 <vector200>:
.globl vector200
vector200:
  pushl $0
801077d9:	6a 00                	push   $0x0
  pushl $200
801077db:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801077e0:	e9 fc f1 ff ff       	jmp    801069e1 <alltraps>

801077e5 <vector201>:
.globl vector201
vector201:
  pushl $0
801077e5:	6a 00                	push   $0x0
  pushl $201
801077e7:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801077ec:	e9 f0 f1 ff ff       	jmp    801069e1 <alltraps>

801077f1 <vector202>:
.globl vector202
vector202:
  pushl $0
801077f1:	6a 00                	push   $0x0
  pushl $202
801077f3:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801077f8:	e9 e4 f1 ff ff       	jmp    801069e1 <alltraps>

801077fd <vector203>:
.globl vector203
vector203:
  pushl $0
801077fd:	6a 00                	push   $0x0
  pushl $203
801077ff:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107804:	e9 d8 f1 ff ff       	jmp    801069e1 <alltraps>

80107809 <vector204>:
.globl vector204
vector204:
  pushl $0
80107809:	6a 00                	push   $0x0
  pushl $204
8010780b:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107810:	e9 cc f1 ff ff       	jmp    801069e1 <alltraps>

80107815 <vector205>:
.globl vector205
vector205:
  pushl $0
80107815:	6a 00                	push   $0x0
  pushl $205
80107817:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010781c:	e9 c0 f1 ff ff       	jmp    801069e1 <alltraps>

80107821 <vector206>:
.globl vector206
vector206:
  pushl $0
80107821:	6a 00                	push   $0x0
  pushl $206
80107823:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107828:	e9 b4 f1 ff ff       	jmp    801069e1 <alltraps>

8010782d <vector207>:
.globl vector207
vector207:
  pushl $0
8010782d:	6a 00                	push   $0x0
  pushl $207
8010782f:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107834:	e9 a8 f1 ff ff       	jmp    801069e1 <alltraps>

80107839 <vector208>:
.globl vector208
vector208:
  pushl $0
80107839:	6a 00                	push   $0x0
  pushl $208
8010783b:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107840:	e9 9c f1 ff ff       	jmp    801069e1 <alltraps>

80107845 <vector209>:
.globl vector209
vector209:
  pushl $0
80107845:	6a 00                	push   $0x0
  pushl $209
80107847:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010784c:	e9 90 f1 ff ff       	jmp    801069e1 <alltraps>

80107851 <vector210>:
.globl vector210
vector210:
  pushl $0
80107851:	6a 00                	push   $0x0
  pushl $210
80107853:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107858:	e9 84 f1 ff ff       	jmp    801069e1 <alltraps>

8010785d <vector211>:
.globl vector211
vector211:
  pushl $0
8010785d:	6a 00                	push   $0x0
  pushl $211
8010785f:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107864:	e9 78 f1 ff ff       	jmp    801069e1 <alltraps>

80107869 <vector212>:
.globl vector212
vector212:
  pushl $0
80107869:	6a 00                	push   $0x0
  pushl $212
8010786b:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107870:	e9 6c f1 ff ff       	jmp    801069e1 <alltraps>

80107875 <vector213>:
.globl vector213
vector213:
  pushl $0
80107875:	6a 00                	push   $0x0
  pushl $213
80107877:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010787c:	e9 60 f1 ff ff       	jmp    801069e1 <alltraps>

80107881 <vector214>:
.globl vector214
vector214:
  pushl $0
80107881:	6a 00                	push   $0x0
  pushl $214
80107883:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107888:	e9 54 f1 ff ff       	jmp    801069e1 <alltraps>

8010788d <vector215>:
.globl vector215
vector215:
  pushl $0
8010788d:	6a 00                	push   $0x0
  pushl $215
8010788f:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107894:	e9 48 f1 ff ff       	jmp    801069e1 <alltraps>

80107899 <vector216>:
.globl vector216
vector216:
  pushl $0
80107899:	6a 00                	push   $0x0
  pushl $216
8010789b:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801078a0:	e9 3c f1 ff ff       	jmp    801069e1 <alltraps>

801078a5 <vector217>:
.globl vector217
vector217:
  pushl $0
801078a5:	6a 00                	push   $0x0
  pushl $217
801078a7:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801078ac:	e9 30 f1 ff ff       	jmp    801069e1 <alltraps>

801078b1 <vector218>:
.globl vector218
vector218:
  pushl $0
801078b1:	6a 00                	push   $0x0
  pushl $218
801078b3:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801078b8:	e9 24 f1 ff ff       	jmp    801069e1 <alltraps>

801078bd <vector219>:
.globl vector219
vector219:
  pushl $0
801078bd:	6a 00                	push   $0x0
  pushl $219
801078bf:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801078c4:	e9 18 f1 ff ff       	jmp    801069e1 <alltraps>

801078c9 <vector220>:
.globl vector220
vector220:
  pushl $0
801078c9:	6a 00                	push   $0x0
  pushl $220
801078cb:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801078d0:	e9 0c f1 ff ff       	jmp    801069e1 <alltraps>

801078d5 <vector221>:
.globl vector221
vector221:
  pushl $0
801078d5:	6a 00                	push   $0x0
  pushl $221
801078d7:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801078dc:	e9 00 f1 ff ff       	jmp    801069e1 <alltraps>

801078e1 <vector222>:
.globl vector222
vector222:
  pushl $0
801078e1:	6a 00                	push   $0x0
  pushl $222
801078e3:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801078e8:	e9 f4 f0 ff ff       	jmp    801069e1 <alltraps>

801078ed <vector223>:
.globl vector223
vector223:
  pushl $0
801078ed:	6a 00                	push   $0x0
  pushl $223
801078ef:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801078f4:	e9 e8 f0 ff ff       	jmp    801069e1 <alltraps>

801078f9 <vector224>:
.globl vector224
vector224:
  pushl $0
801078f9:	6a 00                	push   $0x0
  pushl $224
801078fb:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107900:	e9 dc f0 ff ff       	jmp    801069e1 <alltraps>

80107905 <vector225>:
.globl vector225
vector225:
  pushl $0
80107905:	6a 00                	push   $0x0
  pushl $225
80107907:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010790c:	e9 d0 f0 ff ff       	jmp    801069e1 <alltraps>

80107911 <vector226>:
.globl vector226
vector226:
  pushl $0
80107911:	6a 00                	push   $0x0
  pushl $226
80107913:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107918:	e9 c4 f0 ff ff       	jmp    801069e1 <alltraps>

8010791d <vector227>:
.globl vector227
vector227:
  pushl $0
8010791d:	6a 00                	push   $0x0
  pushl $227
8010791f:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107924:	e9 b8 f0 ff ff       	jmp    801069e1 <alltraps>

80107929 <vector228>:
.globl vector228
vector228:
  pushl $0
80107929:	6a 00                	push   $0x0
  pushl $228
8010792b:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107930:	e9 ac f0 ff ff       	jmp    801069e1 <alltraps>

80107935 <vector229>:
.globl vector229
vector229:
  pushl $0
80107935:	6a 00                	push   $0x0
  pushl $229
80107937:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010793c:	e9 a0 f0 ff ff       	jmp    801069e1 <alltraps>

80107941 <vector230>:
.globl vector230
vector230:
  pushl $0
80107941:	6a 00                	push   $0x0
  pushl $230
80107943:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107948:	e9 94 f0 ff ff       	jmp    801069e1 <alltraps>

8010794d <vector231>:
.globl vector231
vector231:
  pushl $0
8010794d:	6a 00                	push   $0x0
  pushl $231
8010794f:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107954:	e9 88 f0 ff ff       	jmp    801069e1 <alltraps>

80107959 <vector232>:
.globl vector232
vector232:
  pushl $0
80107959:	6a 00                	push   $0x0
  pushl $232
8010795b:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107960:	e9 7c f0 ff ff       	jmp    801069e1 <alltraps>

80107965 <vector233>:
.globl vector233
vector233:
  pushl $0
80107965:	6a 00                	push   $0x0
  pushl $233
80107967:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010796c:	e9 70 f0 ff ff       	jmp    801069e1 <alltraps>

80107971 <vector234>:
.globl vector234
vector234:
  pushl $0
80107971:	6a 00                	push   $0x0
  pushl $234
80107973:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107978:	e9 64 f0 ff ff       	jmp    801069e1 <alltraps>

8010797d <vector235>:
.globl vector235
vector235:
  pushl $0
8010797d:	6a 00                	push   $0x0
  pushl $235
8010797f:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107984:	e9 58 f0 ff ff       	jmp    801069e1 <alltraps>

80107989 <vector236>:
.globl vector236
vector236:
  pushl $0
80107989:	6a 00                	push   $0x0
  pushl $236
8010798b:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107990:	e9 4c f0 ff ff       	jmp    801069e1 <alltraps>

80107995 <vector237>:
.globl vector237
vector237:
  pushl $0
80107995:	6a 00                	push   $0x0
  pushl $237
80107997:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010799c:	e9 40 f0 ff ff       	jmp    801069e1 <alltraps>

801079a1 <vector238>:
.globl vector238
vector238:
  pushl $0
801079a1:	6a 00                	push   $0x0
  pushl $238
801079a3:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801079a8:	e9 34 f0 ff ff       	jmp    801069e1 <alltraps>

801079ad <vector239>:
.globl vector239
vector239:
  pushl $0
801079ad:	6a 00                	push   $0x0
  pushl $239
801079af:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801079b4:	e9 28 f0 ff ff       	jmp    801069e1 <alltraps>

801079b9 <vector240>:
.globl vector240
vector240:
  pushl $0
801079b9:	6a 00                	push   $0x0
  pushl $240
801079bb:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801079c0:	e9 1c f0 ff ff       	jmp    801069e1 <alltraps>

801079c5 <vector241>:
.globl vector241
vector241:
  pushl $0
801079c5:	6a 00                	push   $0x0
  pushl $241
801079c7:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801079cc:	e9 10 f0 ff ff       	jmp    801069e1 <alltraps>

801079d1 <vector242>:
.globl vector242
vector242:
  pushl $0
801079d1:	6a 00                	push   $0x0
  pushl $242
801079d3:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801079d8:	e9 04 f0 ff ff       	jmp    801069e1 <alltraps>

801079dd <vector243>:
.globl vector243
vector243:
  pushl $0
801079dd:	6a 00                	push   $0x0
  pushl $243
801079df:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801079e4:	e9 f8 ef ff ff       	jmp    801069e1 <alltraps>

801079e9 <vector244>:
.globl vector244
vector244:
  pushl $0
801079e9:	6a 00                	push   $0x0
  pushl $244
801079eb:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801079f0:	e9 ec ef ff ff       	jmp    801069e1 <alltraps>

801079f5 <vector245>:
.globl vector245
vector245:
  pushl $0
801079f5:	6a 00                	push   $0x0
  pushl $245
801079f7:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801079fc:	e9 e0 ef ff ff       	jmp    801069e1 <alltraps>

80107a01 <vector246>:
.globl vector246
vector246:
  pushl $0
80107a01:	6a 00                	push   $0x0
  pushl $246
80107a03:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107a08:	e9 d4 ef ff ff       	jmp    801069e1 <alltraps>

80107a0d <vector247>:
.globl vector247
vector247:
  pushl $0
80107a0d:	6a 00                	push   $0x0
  pushl $247
80107a0f:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107a14:	e9 c8 ef ff ff       	jmp    801069e1 <alltraps>

80107a19 <vector248>:
.globl vector248
vector248:
  pushl $0
80107a19:	6a 00                	push   $0x0
  pushl $248
80107a1b:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107a20:	e9 bc ef ff ff       	jmp    801069e1 <alltraps>

80107a25 <vector249>:
.globl vector249
vector249:
  pushl $0
80107a25:	6a 00                	push   $0x0
  pushl $249
80107a27:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107a2c:	e9 b0 ef ff ff       	jmp    801069e1 <alltraps>

80107a31 <vector250>:
.globl vector250
vector250:
  pushl $0
80107a31:	6a 00                	push   $0x0
  pushl $250
80107a33:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107a38:	e9 a4 ef ff ff       	jmp    801069e1 <alltraps>

80107a3d <vector251>:
.globl vector251
vector251:
  pushl $0
80107a3d:	6a 00                	push   $0x0
  pushl $251
80107a3f:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107a44:	e9 98 ef ff ff       	jmp    801069e1 <alltraps>

80107a49 <vector252>:
.globl vector252
vector252:
  pushl $0
80107a49:	6a 00                	push   $0x0
  pushl $252
80107a4b:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107a50:	e9 8c ef ff ff       	jmp    801069e1 <alltraps>

80107a55 <vector253>:
.globl vector253
vector253:
  pushl $0
80107a55:	6a 00                	push   $0x0
  pushl $253
80107a57:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107a5c:	e9 80 ef ff ff       	jmp    801069e1 <alltraps>

80107a61 <vector254>:
.globl vector254
vector254:
  pushl $0
80107a61:	6a 00                	push   $0x0
  pushl $254
80107a63:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107a68:	e9 74 ef ff ff       	jmp    801069e1 <alltraps>

80107a6d <vector255>:
.globl vector255
vector255:
  pushl $0
80107a6d:	6a 00                	push   $0x0
  pushl $255
80107a6f:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107a74:	e9 68 ef ff ff       	jmp    801069e1 <alltraps>

80107a79 <lgdt>:
{
80107a79:	55                   	push   %ebp
80107a7a:	89 e5                	mov    %esp,%ebp
80107a7c:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a82:	83 e8 01             	sub    $0x1,%eax
80107a85:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107a89:	8b 45 08             	mov    0x8(%ebp),%eax
80107a8c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107a90:	8b 45 08             	mov    0x8(%ebp),%eax
80107a93:	c1 e8 10             	shr    $0x10,%eax
80107a96:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107a9a:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107a9d:	0f 01 10             	lgdtl  (%eax)
}
80107aa0:	90                   	nop
80107aa1:	c9                   	leave  
80107aa2:	c3                   	ret    

80107aa3 <ltr>:
{
80107aa3:	55                   	push   %ebp
80107aa4:	89 e5                	mov    %esp,%ebp
80107aa6:	83 ec 04             	sub    $0x4,%esp
80107aa9:	8b 45 08             	mov    0x8(%ebp),%eax
80107aac:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107ab0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107ab4:	0f 00 d8             	ltr    %ax
}
80107ab7:	90                   	nop
80107ab8:	c9                   	leave  
80107ab9:	c3                   	ret    

80107aba <lcr3>:

static inline void
lcr3(uint val)
{
80107aba:	55                   	push   %ebp
80107abb:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107abd:	8b 45 08             	mov    0x8(%ebp),%eax
80107ac0:	0f 22 d8             	mov    %eax,%cr3
}
80107ac3:	90                   	nop
80107ac4:	5d                   	pop    %ebp
80107ac5:	c3                   	ret    

80107ac6 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107ac6:	55                   	push   %ebp
80107ac7:	89 e5                	mov    %esp,%ebp
80107ac9:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107acc:	e8 73 c7 ff ff       	call   80104244 <cpuid>
80107ad1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107ad7:	05 c0 27 11 80       	add    $0x801127c0,%eax
80107adc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae2:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aeb:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af4:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107aff:	83 e2 f0             	and    $0xfffffff0,%edx
80107b02:	83 ca 0a             	or     $0xa,%edx
80107b05:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b0f:	83 ca 10             	or     $0x10,%edx
80107b12:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b18:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b1c:	83 e2 9f             	and    $0xffffff9f,%edx
80107b1f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b25:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b29:	83 ca 80             	or     $0xffffff80,%edx
80107b2c:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b32:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b36:	83 ca 0f             	or     $0xf,%edx
80107b39:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b43:	83 e2 ef             	and    $0xffffffef,%edx
80107b46:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b50:	83 e2 df             	and    $0xffffffdf,%edx
80107b53:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b59:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b5d:	83 ca 40             	or     $0x40,%edx
80107b60:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b66:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b6a:	83 ca 80             	or     $0xffffff80,%edx
80107b6d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b73:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107b81:	ff ff 
80107b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b86:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107b8d:	00 00 
80107b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b92:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ba3:	83 e2 f0             	and    $0xfffffff0,%edx
80107ba6:	83 ca 02             	or     $0x2,%edx
80107ba9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107bb9:	83 ca 10             	or     $0x10,%edx
80107bbc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107bcc:	83 e2 9f             	and    $0xffffff9f,%edx
80107bcf:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107bdf:	83 ca 80             	or     $0xffffff80,%edx
80107be2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107beb:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bf2:	83 ca 0f             	or     $0xf,%edx
80107bf5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfe:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c05:	83 e2 ef             	and    $0xffffffef,%edx
80107c08:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c11:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c18:	83 e2 df             	and    $0xffffffdf,%edx
80107c1b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c24:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c2b:	83 ca 40             	or     $0x40,%edx
80107c2e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c37:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c3e:	83 ca 80             	or     $0xffffff80,%edx
80107c41:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c54:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107c5b:	ff ff 
80107c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c60:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107c67:	00 00 
80107c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6c:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c76:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107c7d:	83 e2 f0             	and    $0xfffffff0,%edx
80107c80:	83 ca 0a             	or     $0xa,%edx
80107c83:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107c93:	83 ca 10             	or     $0x10,%edx
80107c96:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ca6:	83 ca 60             	or     $0x60,%edx
80107ca9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107cb9:	83 ca 80             	or     $0xffffff80,%edx
80107cbc:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ccc:	83 ca 0f             	or     $0xf,%edx
80107ccf:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107cdf:	83 e2 ef             	and    $0xffffffef,%edx
80107ce2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ceb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107cf2:	83 e2 df             	and    $0xffffffdf,%edx
80107cf5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfe:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d05:	83 ca 40             	or     $0x40,%edx
80107d08:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d11:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d18:	83 ca 80             	or     $0xffffff80,%edx
80107d1b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d24:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2e:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107d35:	ff ff 
80107d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3a:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107d41:	00 00 
80107d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d46:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d50:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d57:	83 e2 f0             	and    $0xfffffff0,%edx
80107d5a:	83 ca 02             	or     $0x2,%edx
80107d5d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d66:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d6d:	83 ca 10             	or     $0x10,%edx
80107d70:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d79:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d80:	83 ca 60             	or     $0x60,%edx
80107d83:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d93:	83 ca 80             	or     $0xffffff80,%edx
80107d96:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107da6:	83 ca 0f             	or     $0xf,%edx
80107da9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107db9:	83 e2 ef             	and    $0xffffffef,%edx
80107dbc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107dcc:	83 e2 df             	and    $0xffffffdf,%edx
80107dcf:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ddf:	83 ca 40             	or     $0x40,%edx
80107de2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107deb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107df2:	83 ca 80             	or     $0xffffff80,%edx
80107df5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfe:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e08:	83 c0 70             	add    $0x70,%eax
80107e0b:	83 ec 08             	sub    $0x8,%esp
80107e0e:	6a 30                	push   $0x30
80107e10:	50                   	push   %eax
80107e11:	e8 63 fc ff ff       	call   80107a79 <lgdt>
80107e16:	83 c4 10             	add    $0x10,%esp
}
80107e19:	90                   	nop
80107e1a:	c9                   	leave  
80107e1b:	c3                   	ret    

80107e1c <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107e1c:	55                   	push   %ebp
80107e1d:	89 e5                	mov    %esp,%ebp
80107e1f:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107e22:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e25:	c1 e8 16             	shr    $0x16,%eax
80107e28:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e2f:	8b 45 08             	mov    0x8(%ebp),%eax
80107e32:	01 d0                	add    %edx,%eax
80107e34:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e3a:	8b 00                	mov    (%eax),%eax
80107e3c:	83 e0 01             	and    $0x1,%eax
80107e3f:	85 c0                	test   %eax,%eax
80107e41:	74 14                	je     80107e57 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107e43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e46:	8b 00                	mov    (%eax),%eax
80107e48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e4d:	05 00 00 00 80       	add    $0x80000000,%eax
80107e52:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e55:	eb 42                	jmp    80107e99 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107e57:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107e5b:	74 0e                	je     80107e6b <walkpgdir+0x4f>
80107e5d:	e8 72 ae ff ff       	call   80102cd4 <kalloc>
80107e62:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e69:	75 07                	jne    80107e72 <walkpgdir+0x56>
      return 0;
80107e6b:	b8 00 00 00 00       	mov    $0x0,%eax
80107e70:	eb 3e                	jmp    80107eb0 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107e72:	83 ec 04             	sub    $0x4,%esp
80107e75:	68 00 10 00 00       	push   $0x1000
80107e7a:	6a 00                	push   $0x0
80107e7c:	ff 75 f4             	push   -0xc(%ebp)
80107e7f:	e8 3f d7 ff ff       	call   801055c3 <memset>
80107e84:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8a:	05 00 00 00 80       	add    $0x80000000,%eax
80107e8f:	83 c8 07             	or     $0x7,%eax
80107e92:	89 c2                	mov    %eax,%edx
80107e94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e97:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107e99:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e9c:	c1 e8 0c             	shr    $0xc,%eax
80107e9f:	25 ff 03 00 00       	and    $0x3ff,%eax
80107ea4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eae:	01 d0                	add    %edx,%eax
}
80107eb0:	c9                   	leave  
80107eb1:	c3                   	ret    

80107eb2 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107eb2:	55                   	push   %ebp
80107eb3:	89 e5                	mov    %esp,%ebp
80107eb5:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ebb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ec0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107ec3:	8b 55 0c             	mov    0xc(%ebp),%edx
80107ec6:	8b 45 10             	mov    0x10(%ebp),%eax
80107ec9:	01 d0                	add    %edx,%eax
80107ecb:	83 e8 01             	sub    $0x1,%eax
80107ece:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ed3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107ed6:	83 ec 04             	sub    $0x4,%esp
80107ed9:	6a 01                	push   $0x1
80107edb:	ff 75 f4             	push   -0xc(%ebp)
80107ede:	ff 75 08             	push   0x8(%ebp)
80107ee1:	e8 36 ff ff ff       	call   80107e1c <walkpgdir>
80107ee6:	83 c4 10             	add    $0x10,%esp
80107ee9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107eec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ef0:	75 07                	jne    80107ef9 <mappages+0x47>
      return -1;
80107ef2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ef7:	eb 47                	jmp    80107f40 <mappages+0x8e>
    if(*pte & PTE_P)
80107ef9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107efc:	8b 00                	mov    (%eax),%eax
80107efe:	83 e0 01             	and    $0x1,%eax
80107f01:	85 c0                	test   %eax,%eax
80107f03:	74 0d                	je     80107f12 <mappages+0x60>
      panic("remap");
80107f05:	83 ec 0c             	sub    $0xc,%esp
80107f08:	68 a8 8d 10 80       	push   $0x80108da8
80107f0d:	e8 a3 86 ff ff       	call   801005b5 <panic>
    *pte = pa | perm | PTE_P;
80107f12:	8b 45 18             	mov    0x18(%ebp),%eax
80107f15:	0b 45 14             	or     0x14(%ebp),%eax
80107f18:	83 c8 01             	or     $0x1,%eax
80107f1b:	89 c2                	mov    %eax,%edx
80107f1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f20:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f25:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107f28:	74 10                	je     80107f3a <mappages+0x88>
      break;
    a += PGSIZE;
80107f2a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107f31:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107f38:	eb 9c                	jmp    80107ed6 <mappages+0x24>
      break;
80107f3a:	90                   	nop
  }
  return 0;
80107f3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f40:	c9                   	leave  
80107f41:	c3                   	ret    

80107f42 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107f42:	55                   	push   %ebp
80107f43:	89 e5                	mov    %esp,%ebp
80107f45:	53                   	push   %ebx
80107f46:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107f49:	e8 86 ad ff ff       	call   80102cd4 <kalloc>
80107f4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f51:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f55:	75 07                	jne    80107f5e <setupkvm+0x1c>
    return 0;
80107f57:	b8 00 00 00 00       	mov    $0x0,%eax
80107f5c:	eb 78                	jmp    80107fd6 <setupkvm+0x94>
  memset(pgdir, 0, PGSIZE);
80107f5e:	83 ec 04             	sub    $0x4,%esp
80107f61:	68 00 10 00 00       	push   $0x1000
80107f66:	6a 00                	push   $0x0
80107f68:	ff 75 f0             	push   -0x10(%ebp)
80107f6b:	e8 53 d6 ff ff       	call   801055c3 <memset>
80107f70:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f73:	c7 45 f4 80 b4 10 80 	movl   $0x8010b480,-0xc(%ebp)
80107f7a:	eb 4e                	jmp    80107fca <setupkvm+0x88>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7f:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f85:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8b:	8b 58 08             	mov    0x8(%eax),%ebx
80107f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f91:	8b 40 04             	mov    0x4(%eax),%eax
80107f94:	29 c3                	sub    %eax,%ebx
80107f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f99:	8b 00                	mov    (%eax),%eax
80107f9b:	83 ec 0c             	sub    $0xc,%esp
80107f9e:	51                   	push   %ecx
80107f9f:	52                   	push   %edx
80107fa0:	53                   	push   %ebx
80107fa1:	50                   	push   %eax
80107fa2:	ff 75 f0             	push   -0x10(%ebp)
80107fa5:	e8 08 ff ff ff       	call   80107eb2 <mappages>
80107faa:	83 c4 20             	add    $0x20,%esp
80107fad:	85 c0                	test   %eax,%eax
80107faf:	79 15                	jns    80107fc6 <setupkvm+0x84>
      freevm(pgdir);
80107fb1:	83 ec 0c             	sub    $0xc,%esp
80107fb4:	ff 75 f0             	push   -0x10(%ebp)
80107fb7:	e8 f5 04 00 00       	call   801084b1 <freevm>
80107fbc:	83 c4 10             	add    $0x10,%esp
      return 0;
80107fbf:	b8 00 00 00 00       	mov    $0x0,%eax
80107fc4:	eb 10                	jmp    80107fd6 <setupkvm+0x94>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107fc6:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107fca:	81 7d f4 c0 b4 10 80 	cmpl   $0x8010b4c0,-0xc(%ebp)
80107fd1:	72 a9                	jb     80107f7c <setupkvm+0x3a>
    }
  return pgdir;
80107fd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107fd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107fd9:	c9                   	leave  
80107fda:	c3                   	ret    

80107fdb <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107fdb:	55                   	push   %ebp
80107fdc:	89 e5                	mov    %esp,%ebp
80107fde:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107fe1:	e8 5c ff ff ff       	call   80107f42 <setupkvm>
80107fe6:	a3 dc 59 11 80       	mov    %eax,0x801159dc
  switchkvm();
80107feb:	e8 03 00 00 00       	call   80107ff3 <switchkvm>
}
80107ff0:	90                   	nop
80107ff1:	c9                   	leave  
80107ff2:	c3                   	ret    

80107ff3 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107ff3:	55                   	push   %ebp
80107ff4:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107ff6:	a1 dc 59 11 80       	mov    0x801159dc,%eax
80107ffb:	05 00 00 00 80       	add    $0x80000000,%eax
80108000:	50                   	push   %eax
80108001:	e8 b4 fa ff ff       	call   80107aba <lcr3>
80108006:	83 c4 04             	add    $0x4,%esp
}
80108009:	90                   	nop
8010800a:	c9                   	leave  
8010800b:	c3                   	ret    

8010800c <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010800c:	55                   	push   %ebp
8010800d:	89 e5                	mov    %esp,%ebp
8010800f:	56                   	push   %esi
80108010:	53                   	push   %ebx
80108011:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80108014:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108018:	75 0d                	jne    80108027 <switchuvm+0x1b>
    panic("switchuvm: no process");
8010801a:	83 ec 0c             	sub    $0xc,%esp
8010801d:	68 ae 8d 10 80       	push   $0x80108dae
80108022:	e8 8e 85 ff ff       	call   801005b5 <panic>
  if(p->kstack == 0)
80108027:	8b 45 08             	mov    0x8(%ebp),%eax
8010802a:	8b 40 08             	mov    0x8(%eax),%eax
8010802d:	85 c0                	test   %eax,%eax
8010802f:	75 0d                	jne    8010803e <switchuvm+0x32>
    panic("switchuvm: no kstack");
80108031:	83 ec 0c             	sub    $0xc,%esp
80108034:	68 c4 8d 10 80       	push   $0x80108dc4
80108039:	e8 77 85 ff ff       	call   801005b5 <panic>
  if(p->pgdir == 0)
8010803e:	8b 45 08             	mov    0x8(%ebp),%eax
80108041:	8b 40 04             	mov    0x4(%eax),%eax
80108044:	85 c0                	test   %eax,%eax
80108046:	75 0d                	jne    80108055 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80108048:	83 ec 0c             	sub    $0xc,%esp
8010804b:	68 d9 8d 10 80       	push   $0x80108dd9
80108050:	e8 60 85 ff ff       	call   801005b5 <panic>

  pushcli();
80108055:	e8 5e d4 ff ff       	call   801054b8 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010805a:	e8 00 c2 ff ff       	call   8010425f <mycpu>
8010805f:	89 c3                	mov    %eax,%ebx
80108061:	e8 f9 c1 ff ff       	call   8010425f <mycpu>
80108066:	83 c0 08             	add    $0x8,%eax
80108069:	89 c6                	mov    %eax,%esi
8010806b:	e8 ef c1 ff ff       	call   8010425f <mycpu>
80108070:	83 c0 08             	add    $0x8,%eax
80108073:	c1 e8 10             	shr    $0x10,%eax
80108076:	88 45 f7             	mov    %al,-0x9(%ebp)
80108079:	e8 e1 c1 ff ff       	call   8010425f <mycpu>
8010807e:	83 c0 08             	add    $0x8,%eax
80108081:	c1 e8 18             	shr    $0x18,%eax
80108084:	89 c2                	mov    %eax,%edx
80108086:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
8010808d:	67 00 
8010808f:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108096:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
8010809a:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801080a0:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801080a7:	83 e0 f0             	and    $0xfffffff0,%eax
801080aa:	83 c8 09             	or     $0x9,%eax
801080ad:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801080b3:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801080ba:	83 c8 10             	or     $0x10,%eax
801080bd:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801080c3:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801080ca:	83 e0 9f             	and    $0xffffff9f,%eax
801080cd:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801080d3:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801080da:	83 c8 80             	or     $0xffffff80,%eax
801080dd:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801080e3:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801080ea:	83 e0 f0             	and    $0xfffffff0,%eax
801080ed:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801080f3:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801080fa:	83 e0 ef             	and    $0xffffffef,%eax
801080fd:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108103:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010810a:	83 e0 df             	and    $0xffffffdf,%eax
8010810d:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108113:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010811a:	83 c8 40             	or     $0x40,%eax
8010811d:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108123:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010812a:	83 e0 7f             	and    $0x7f,%eax
8010812d:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108133:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108139:	e8 21 c1 ff ff       	call   8010425f <mycpu>
8010813e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108145:	83 e2 ef             	and    $0xffffffef,%edx
80108148:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010814e:	e8 0c c1 ff ff       	call   8010425f <mycpu>
80108153:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108159:	8b 45 08             	mov    0x8(%ebp),%eax
8010815c:	8b 40 08             	mov    0x8(%eax),%eax
8010815f:	89 c3                	mov    %eax,%ebx
80108161:	e8 f9 c0 ff ff       	call   8010425f <mycpu>
80108166:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
8010816c:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010816f:	e8 eb c0 ff ff       	call   8010425f <mycpu>
80108174:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
8010817a:	83 ec 0c             	sub    $0xc,%esp
8010817d:	6a 28                	push   $0x28
8010817f:	e8 1f f9 ff ff       	call   80107aa3 <ltr>
80108184:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108187:	8b 45 08             	mov    0x8(%ebp),%eax
8010818a:	8b 40 04             	mov    0x4(%eax),%eax
8010818d:	05 00 00 00 80       	add    $0x80000000,%eax
80108192:	83 ec 0c             	sub    $0xc,%esp
80108195:	50                   	push   %eax
80108196:	e8 1f f9 ff ff       	call   80107aba <lcr3>
8010819b:	83 c4 10             	add    $0x10,%esp
  popcli();
8010819e:	e8 62 d3 ff ff       	call   80105505 <popcli>
}
801081a3:	90                   	nop
801081a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801081a7:	5b                   	pop    %ebx
801081a8:	5e                   	pop    %esi
801081a9:	5d                   	pop    %ebp
801081aa:	c3                   	ret    

801081ab <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801081ab:	55                   	push   %ebp
801081ac:	89 e5                	mov    %esp,%ebp
801081ae:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
801081b1:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801081b8:	76 0d                	jbe    801081c7 <inituvm+0x1c>
    panic("inituvm: more than a page");
801081ba:	83 ec 0c             	sub    $0xc,%esp
801081bd:	68 ed 8d 10 80       	push   $0x80108ded
801081c2:	e8 ee 83 ff ff       	call   801005b5 <panic>
  mem = kalloc();
801081c7:	e8 08 ab ff ff       	call   80102cd4 <kalloc>
801081cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801081cf:	83 ec 04             	sub    $0x4,%esp
801081d2:	68 00 10 00 00       	push   $0x1000
801081d7:	6a 00                	push   $0x0
801081d9:	ff 75 f4             	push   -0xc(%ebp)
801081dc:	e8 e2 d3 ff ff       	call   801055c3 <memset>
801081e1:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801081e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e7:	05 00 00 00 80       	add    $0x80000000,%eax
801081ec:	83 ec 0c             	sub    $0xc,%esp
801081ef:	6a 06                	push   $0x6
801081f1:	50                   	push   %eax
801081f2:	68 00 10 00 00       	push   $0x1000
801081f7:	6a 00                	push   $0x0
801081f9:	ff 75 08             	push   0x8(%ebp)
801081fc:	e8 b1 fc ff ff       	call   80107eb2 <mappages>
80108201:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108204:	83 ec 04             	sub    $0x4,%esp
80108207:	ff 75 10             	push   0x10(%ebp)
8010820a:	ff 75 0c             	push   0xc(%ebp)
8010820d:	ff 75 f4             	push   -0xc(%ebp)
80108210:	e8 6d d4 ff ff       	call   80105682 <memmove>
80108215:	83 c4 10             	add    $0x10,%esp
}
80108218:	90                   	nop
80108219:	c9                   	leave  
8010821a:	c3                   	ret    

8010821b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010821b:	55                   	push   %ebp
8010821c:	89 e5                	mov    %esp,%ebp
8010821e:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108221:	8b 45 0c             	mov    0xc(%ebp),%eax
80108224:	25 ff 0f 00 00       	and    $0xfff,%eax
80108229:	85 c0                	test   %eax,%eax
8010822b:	74 0d                	je     8010823a <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010822d:	83 ec 0c             	sub    $0xc,%esp
80108230:	68 08 8e 10 80       	push   $0x80108e08
80108235:	e8 7b 83 ff ff       	call   801005b5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010823a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108241:	e9 8f 00 00 00       	jmp    801082d5 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108246:	8b 55 0c             	mov    0xc(%ebp),%edx
80108249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824c:	01 d0                	add    %edx,%eax
8010824e:	83 ec 04             	sub    $0x4,%esp
80108251:	6a 00                	push   $0x0
80108253:	50                   	push   %eax
80108254:	ff 75 08             	push   0x8(%ebp)
80108257:	e8 c0 fb ff ff       	call   80107e1c <walkpgdir>
8010825c:	83 c4 10             	add    $0x10,%esp
8010825f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108262:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108266:	75 0d                	jne    80108275 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80108268:	83 ec 0c             	sub    $0xc,%esp
8010826b:	68 2b 8e 10 80       	push   $0x80108e2b
80108270:	e8 40 83 ff ff       	call   801005b5 <panic>
    pa = PTE_ADDR(*pte);
80108275:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108278:	8b 00                	mov    (%eax),%eax
8010827a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010827f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108282:	8b 45 18             	mov    0x18(%ebp),%eax
80108285:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108288:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010828d:	77 0b                	ja     8010829a <loaduvm+0x7f>
      n = sz - i;
8010828f:	8b 45 18             	mov    0x18(%ebp),%eax
80108292:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108295:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108298:	eb 07                	jmp    801082a1 <loaduvm+0x86>
    else
      n = PGSIZE;
8010829a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801082a1:	8b 55 14             	mov    0x14(%ebp),%edx
801082a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a7:	01 d0                	add    %edx,%eax
801082a9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801082ac:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801082b2:	ff 75 f0             	push   -0x10(%ebp)
801082b5:	50                   	push   %eax
801082b6:	52                   	push   %edx
801082b7:	ff 75 10             	push   0x10(%ebp)
801082ba:	e8 85 9c ff ff       	call   80101f44 <readi>
801082bf:	83 c4 10             	add    $0x10,%esp
801082c2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801082c5:	74 07                	je     801082ce <loaduvm+0xb3>
      return -1;
801082c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801082cc:	eb 18                	jmp    801082e6 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
801082ce:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d8:	3b 45 18             	cmp    0x18(%ebp),%eax
801082db:	0f 82 65 ff ff ff    	jb     80108246 <loaduvm+0x2b>
  }
  return 0;
801082e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801082e6:	c9                   	leave  
801082e7:	c3                   	ret    

801082e8 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801082e8:	55                   	push   %ebp
801082e9:	89 e5                	mov    %esp,%ebp
801082eb:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801082ee:	8b 45 10             	mov    0x10(%ebp),%eax
801082f1:	85 c0                	test   %eax,%eax
801082f3:	79 0a                	jns    801082ff <allocuvm+0x17>
    return 0;
801082f5:	b8 00 00 00 00       	mov    $0x0,%eax
801082fa:	e9 ec 00 00 00       	jmp    801083eb <allocuvm+0x103>
  if(newsz < oldsz)
801082ff:	8b 45 10             	mov    0x10(%ebp),%eax
80108302:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108305:	73 08                	jae    8010830f <allocuvm+0x27>
    return oldsz;
80108307:	8b 45 0c             	mov    0xc(%ebp),%eax
8010830a:	e9 dc 00 00 00       	jmp    801083eb <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
8010830f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108312:	05 ff 0f 00 00       	add    $0xfff,%eax
80108317:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010831c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010831f:	e9 b8 00 00 00       	jmp    801083dc <allocuvm+0xf4>
    mem = kalloc();
80108324:	e8 ab a9 ff ff       	call   80102cd4 <kalloc>
80108329:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010832c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108330:	75 2e                	jne    80108360 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80108332:	83 ec 0c             	sub    $0xc,%esp
80108335:	68 49 8e 10 80       	push   $0x80108e49
8010833a:	e8 c1 80 ff ff       	call   80100400 <cprintf>
8010833f:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108342:	83 ec 04             	sub    $0x4,%esp
80108345:	ff 75 0c             	push   0xc(%ebp)
80108348:	ff 75 10             	push   0x10(%ebp)
8010834b:	ff 75 08             	push   0x8(%ebp)
8010834e:	e8 9a 00 00 00       	call   801083ed <deallocuvm>
80108353:	83 c4 10             	add    $0x10,%esp
      return 0;
80108356:	b8 00 00 00 00       	mov    $0x0,%eax
8010835b:	e9 8b 00 00 00       	jmp    801083eb <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80108360:	83 ec 04             	sub    $0x4,%esp
80108363:	68 00 10 00 00       	push   $0x1000
80108368:	6a 00                	push   $0x0
8010836a:	ff 75 f0             	push   -0x10(%ebp)
8010836d:	e8 51 d2 ff ff       	call   801055c3 <memset>
80108372:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108375:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108378:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010837e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108381:	83 ec 0c             	sub    $0xc,%esp
80108384:	6a 06                	push   $0x6
80108386:	52                   	push   %edx
80108387:	68 00 10 00 00       	push   $0x1000
8010838c:	50                   	push   %eax
8010838d:	ff 75 08             	push   0x8(%ebp)
80108390:	e8 1d fb ff ff       	call   80107eb2 <mappages>
80108395:	83 c4 20             	add    $0x20,%esp
80108398:	85 c0                	test   %eax,%eax
8010839a:	79 39                	jns    801083d5 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
8010839c:	83 ec 0c             	sub    $0xc,%esp
8010839f:	68 61 8e 10 80       	push   $0x80108e61
801083a4:	e8 57 80 ff ff       	call   80100400 <cprintf>
801083a9:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801083ac:	83 ec 04             	sub    $0x4,%esp
801083af:	ff 75 0c             	push   0xc(%ebp)
801083b2:	ff 75 10             	push   0x10(%ebp)
801083b5:	ff 75 08             	push   0x8(%ebp)
801083b8:	e8 30 00 00 00       	call   801083ed <deallocuvm>
801083bd:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801083c0:	83 ec 0c             	sub    $0xc,%esp
801083c3:	ff 75 f0             	push   -0x10(%ebp)
801083c6:	e8 6f a8 ff ff       	call   80102c3a <kfree>
801083cb:	83 c4 10             	add    $0x10,%esp
      return 0;
801083ce:	b8 00 00 00 00       	mov    $0x0,%eax
801083d3:	eb 16                	jmp    801083eb <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
801083d5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083df:	3b 45 10             	cmp    0x10(%ebp),%eax
801083e2:	0f 82 3c ff ff ff    	jb     80108324 <allocuvm+0x3c>
    }
  }
  return newsz;
801083e8:	8b 45 10             	mov    0x10(%ebp),%eax
}
801083eb:	c9                   	leave  
801083ec:	c3                   	ret    

801083ed <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801083ed:	55                   	push   %ebp
801083ee:	89 e5                	mov    %esp,%ebp
801083f0:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801083f3:	8b 45 10             	mov    0x10(%ebp),%eax
801083f6:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083f9:	72 08                	jb     80108403 <deallocuvm+0x16>
    return oldsz;
801083fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801083fe:	e9 ac 00 00 00       	jmp    801084af <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108403:	8b 45 10             	mov    0x10(%ebp),%eax
80108406:	05 ff 0f 00 00       	add    $0xfff,%eax
8010840b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108410:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108413:	e9 88 00 00 00       	jmp    801084a0 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841b:	83 ec 04             	sub    $0x4,%esp
8010841e:	6a 00                	push   $0x0
80108420:	50                   	push   %eax
80108421:	ff 75 08             	push   0x8(%ebp)
80108424:	e8 f3 f9 ff ff       	call   80107e1c <walkpgdir>
80108429:	83 c4 10             	add    $0x10,%esp
8010842c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010842f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108433:	75 16                	jne    8010844b <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108435:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108438:	c1 e8 16             	shr    $0x16,%eax
8010843b:	83 c0 01             	add    $0x1,%eax
8010843e:	c1 e0 16             	shl    $0x16,%eax
80108441:	2d 00 10 00 00       	sub    $0x1000,%eax
80108446:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108449:	eb 4e                	jmp    80108499 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
8010844b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010844e:	8b 00                	mov    (%eax),%eax
80108450:	83 e0 01             	and    $0x1,%eax
80108453:	85 c0                	test   %eax,%eax
80108455:	74 42                	je     80108499 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108457:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010845a:	8b 00                	mov    (%eax),%eax
8010845c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108461:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108464:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108468:	75 0d                	jne    80108477 <deallocuvm+0x8a>
        panic("kfree");
8010846a:	83 ec 0c             	sub    $0xc,%esp
8010846d:	68 7d 8e 10 80       	push   $0x80108e7d
80108472:	e8 3e 81 ff ff       	call   801005b5 <panic>
      char *v = P2V(pa);
80108477:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010847a:	05 00 00 00 80       	add    $0x80000000,%eax
8010847f:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108482:	83 ec 0c             	sub    $0xc,%esp
80108485:	ff 75 e8             	push   -0x18(%ebp)
80108488:	e8 ad a7 ff ff       	call   80102c3a <kfree>
8010848d:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108490:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108493:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108499:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084a6:	0f 82 6c ff ff ff    	jb     80108418 <deallocuvm+0x2b>
    }
  }
  return newsz;
801084ac:	8b 45 10             	mov    0x10(%ebp),%eax
}
801084af:	c9                   	leave  
801084b0:	c3                   	ret    

801084b1 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801084b1:	55                   	push   %ebp
801084b2:	89 e5                	mov    %esp,%ebp
801084b4:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801084b7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801084bb:	75 0d                	jne    801084ca <freevm+0x19>
    panic("freevm: no pgdir");
801084bd:	83 ec 0c             	sub    $0xc,%esp
801084c0:	68 83 8e 10 80       	push   $0x80108e83
801084c5:	e8 eb 80 ff ff       	call   801005b5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801084ca:	83 ec 04             	sub    $0x4,%esp
801084cd:	6a 00                	push   $0x0
801084cf:	68 00 00 00 80       	push   $0x80000000
801084d4:	ff 75 08             	push   0x8(%ebp)
801084d7:	e8 11 ff ff ff       	call   801083ed <deallocuvm>
801084dc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801084df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084e6:	eb 48                	jmp    80108530 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801084e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084eb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801084f2:	8b 45 08             	mov    0x8(%ebp),%eax
801084f5:	01 d0                	add    %edx,%eax
801084f7:	8b 00                	mov    (%eax),%eax
801084f9:	83 e0 01             	and    $0x1,%eax
801084fc:	85 c0                	test   %eax,%eax
801084fe:	74 2c                	je     8010852c <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108503:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010850a:	8b 45 08             	mov    0x8(%ebp),%eax
8010850d:	01 d0                	add    %edx,%eax
8010850f:	8b 00                	mov    (%eax),%eax
80108511:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108516:	05 00 00 00 80       	add    $0x80000000,%eax
8010851b:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010851e:	83 ec 0c             	sub    $0xc,%esp
80108521:	ff 75 f0             	push   -0x10(%ebp)
80108524:	e8 11 a7 ff ff       	call   80102c3a <kfree>
80108529:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010852c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108530:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108537:	76 af                	jbe    801084e8 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80108539:	83 ec 0c             	sub    $0xc,%esp
8010853c:	ff 75 08             	push   0x8(%ebp)
8010853f:	e8 f6 a6 ff ff       	call   80102c3a <kfree>
80108544:	83 c4 10             	add    $0x10,%esp
}
80108547:	90                   	nop
80108548:	c9                   	leave  
80108549:	c3                   	ret    

8010854a <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010854a:	55                   	push   %ebp
8010854b:	89 e5                	mov    %esp,%ebp
8010854d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108550:	83 ec 04             	sub    $0x4,%esp
80108553:	6a 00                	push   $0x0
80108555:	ff 75 0c             	push   0xc(%ebp)
80108558:	ff 75 08             	push   0x8(%ebp)
8010855b:	e8 bc f8 ff ff       	call   80107e1c <walkpgdir>
80108560:	83 c4 10             	add    $0x10,%esp
80108563:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108566:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010856a:	75 0d                	jne    80108579 <clearpteu+0x2f>
    panic("clearpteu");
8010856c:	83 ec 0c             	sub    $0xc,%esp
8010856f:	68 94 8e 10 80       	push   $0x80108e94
80108574:	e8 3c 80 ff ff       	call   801005b5 <panic>
  *pte &= ~PTE_U;
80108579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010857c:	8b 00                	mov    (%eax),%eax
8010857e:	83 e0 fb             	and    $0xfffffffb,%eax
80108581:	89 c2                	mov    %eax,%edx
80108583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108586:	89 10                	mov    %edx,(%eax)
}
80108588:	90                   	nop
80108589:	c9                   	leave  
8010858a:	c3                   	ret    

8010858b <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010858b:	55                   	push   %ebp
8010858c:	89 e5                	mov    %esp,%ebp
8010858e:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108591:	e8 ac f9 ff ff       	call   80107f42 <setupkvm>
80108596:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108599:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010859d:	75 0a                	jne    801085a9 <copyuvm+0x1e>
    return 0;
8010859f:	b8 00 00 00 00       	mov    $0x0,%eax
801085a4:	e9 f8 00 00 00       	jmp    801086a1 <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
801085a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085b0:	e9 c7 00 00 00       	jmp    8010867c <copyuvm+0xf1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801085b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b8:	83 ec 04             	sub    $0x4,%esp
801085bb:	6a 00                	push   $0x0
801085bd:	50                   	push   %eax
801085be:	ff 75 08             	push   0x8(%ebp)
801085c1:	e8 56 f8 ff ff       	call   80107e1c <walkpgdir>
801085c6:	83 c4 10             	add    $0x10,%esp
801085c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801085cc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085d0:	75 0d                	jne    801085df <copyuvm+0x54>
      panic("copyuvm: pte should exist");
801085d2:	83 ec 0c             	sub    $0xc,%esp
801085d5:	68 9e 8e 10 80       	push   $0x80108e9e
801085da:	e8 d6 7f ff ff       	call   801005b5 <panic>
    if(!(*pte & PTE_P))
801085df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085e2:	8b 00                	mov    (%eax),%eax
801085e4:	83 e0 01             	and    $0x1,%eax
801085e7:	85 c0                	test   %eax,%eax
801085e9:	75 0d                	jne    801085f8 <copyuvm+0x6d>
      panic("copyuvm: page not present");
801085eb:	83 ec 0c             	sub    $0xc,%esp
801085ee:	68 b8 8e 10 80       	push   $0x80108eb8
801085f3:	e8 bd 7f ff ff       	call   801005b5 <panic>
    pa = PTE_ADDR(*pte);
801085f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085fb:	8b 00                	mov    (%eax),%eax
801085fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108602:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108605:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108608:	8b 00                	mov    (%eax),%eax
8010860a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010860f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108612:	e8 bd a6 ff ff       	call   80102cd4 <kalloc>
80108617:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010861a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010861e:	74 6d                	je     8010868d <copyuvm+0x102>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108620:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108623:	05 00 00 00 80       	add    $0x80000000,%eax
80108628:	83 ec 04             	sub    $0x4,%esp
8010862b:	68 00 10 00 00       	push   $0x1000
80108630:	50                   	push   %eax
80108631:	ff 75 e0             	push   -0x20(%ebp)
80108634:	e8 49 d0 ff ff       	call   80105682 <memmove>
80108639:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010863c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010863f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108642:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864b:	83 ec 0c             	sub    $0xc,%esp
8010864e:	52                   	push   %edx
8010864f:	51                   	push   %ecx
80108650:	68 00 10 00 00       	push   $0x1000
80108655:	50                   	push   %eax
80108656:	ff 75 f0             	push   -0x10(%ebp)
80108659:	e8 54 f8 ff ff       	call   80107eb2 <mappages>
8010865e:	83 c4 20             	add    $0x20,%esp
80108661:	85 c0                	test   %eax,%eax
80108663:	79 10                	jns    80108675 <copyuvm+0xea>
      kfree(mem);
80108665:	83 ec 0c             	sub    $0xc,%esp
80108668:	ff 75 e0             	push   -0x20(%ebp)
8010866b:	e8 ca a5 ff ff       	call   80102c3a <kfree>
80108670:	83 c4 10             	add    $0x10,%esp
      goto bad;
80108673:	eb 19                	jmp    8010868e <copyuvm+0x103>
  for(i = 0; i < sz; i += PGSIZE){
80108675:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010867c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108682:	0f 82 2d ff ff ff    	jb     801085b5 <copyuvm+0x2a>
    }
  }
  return d;
80108688:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010868b:	eb 14                	jmp    801086a1 <copyuvm+0x116>
      goto bad;
8010868d:	90                   	nop

bad:
  freevm(d);
8010868e:	83 ec 0c             	sub    $0xc,%esp
80108691:	ff 75 f0             	push   -0x10(%ebp)
80108694:	e8 18 fe ff ff       	call   801084b1 <freevm>
80108699:	83 c4 10             	add    $0x10,%esp
  return 0;
8010869c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801086a1:	c9                   	leave  
801086a2:	c3                   	ret    

801086a3 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801086a3:	55                   	push   %ebp
801086a4:	89 e5                	mov    %esp,%ebp
801086a6:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801086a9:	83 ec 04             	sub    $0x4,%esp
801086ac:	6a 00                	push   $0x0
801086ae:	ff 75 0c             	push   0xc(%ebp)
801086b1:	ff 75 08             	push   0x8(%ebp)
801086b4:	e8 63 f7 ff ff       	call   80107e1c <walkpgdir>
801086b9:	83 c4 10             	add    $0x10,%esp
801086bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801086bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c2:	8b 00                	mov    (%eax),%eax
801086c4:	83 e0 01             	and    $0x1,%eax
801086c7:	85 c0                	test   %eax,%eax
801086c9:	75 07                	jne    801086d2 <uva2ka+0x2f>
    return 0;
801086cb:	b8 00 00 00 00       	mov    $0x0,%eax
801086d0:	eb 22                	jmp    801086f4 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
801086d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d5:	8b 00                	mov    (%eax),%eax
801086d7:	83 e0 04             	and    $0x4,%eax
801086da:	85 c0                	test   %eax,%eax
801086dc:	75 07                	jne    801086e5 <uva2ka+0x42>
    return 0;
801086de:	b8 00 00 00 00       	mov    $0x0,%eax
801086e3:	eb 0f                	jmp    801086f4 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
801086e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e8:	8b 00                	mov    (%eax),%eax
801086ea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086ef:	05 00 00 00 80       	add    $0x80000000,%eax
}
801086f4:	c9                   	leave  
801086f5:	c3                   	ret    

801086f6 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801086f6:	55                   	push   %ebp
801086f7:	89 e5                	mov    %esp,%ebp
801086f9:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801086fc:	8b 45 10             	mov    0x10(%ebp),%eax
801086ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108702:	eb 7f                	jmp    80108783 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108704:	8b 45 0c             	mov    0xc(%ebp),%eax
80108707:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010870c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010870f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108712:	83 ec 08             	sub    $0x8,%esp
80108715:	50                   	push   %eax
80108716:	ff 75 08             	push   0x8(%ebp)
80108719:	e8 85 ff ff ff       	call   801086a3 <uva2ka>
8010871e:	83 c4 10             	add    $0x10,%esp
80108721:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108724:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108728:	75 07                	jne    80108731 <copyout+0x3b>
      return -1;
8010872a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010872f:	eb 61                	jmp    80108792 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108731:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108734:	2b 45 0c             	sub    0xc(%ebp),%eax
80108737:	05 00 10 00 00       	add    $0x1000,%eax
8010873c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010873f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108742:	3b 45 14             	cmp    0x14(%ebp),%eax
80108745:	76 06                	jbe    8010874d <copyout+0x57>
      n = len;
80108747:	8b 45 14             	mov    0x14(%ebp),%eax
8010874a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010874d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108750:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108753:	89 c2                	mov    %eax,%edx
80108755:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108758:	01 d0                	add    %edx,%eax
8010875a:	83 ec 04             	sub    $0x4,%esp
8010875d:	ff 75 f0             	push   -0x10(%ebp)
80108760:	ff 75 f4             	push   -0xc(%ebp)
80108763:	50                   	push   %eax
80108764:	e8 19 cf ff ff       	call   80105682 <memmove>
80108769:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010876c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010876f:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108772:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108775:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108778:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010877b:	05 00 10 00 00       	add    $0x1000,%eax
80108780:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108783:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108787:	0f 85 77 ff ff ff    	jne    80108704 <copyout+0xe>
  }
  return 0;
8010878d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108792:	c9                   	leave  
80108793:	c3                   	ret    
