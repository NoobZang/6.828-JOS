
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
    movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 12 01 00    	add    $0x112be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 58 08 ff ff    	lea    -0xf7a8(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 91 0a 00 00       	call   f0100af4 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7f 2b                	jg     f0100095 <test_backtrace+0x55>
		test_backtrace(x-1);
	else
		mon_backtrace(0, 0, 0);
f010006a:	83 ec 04             	sub    $0x4,%esp
f010006d:	6a 00                	push   $0x0
f010006f:	6a 00                	push   $0x0
f0100071:	6a 00                	push   $0x0
f0100073:	e8 22 08 00 00       	call   f010089a <mon_backtrace>
f0100078:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007b:	83 ec 08             	sub    $0x8,%esp
f010007e:	56                   	push   %esi
f010007f:	8d 83 74 08 ff ff    	lea    -0xf78c(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 69 0a 00 00       	call   f0100af4 <cprintf>
}
f010008b:	83 c4 10             	add    $0x10,%esp
f010008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100091:	5b                   	pop    %ebx
f0100092:	5e                   	pop    %esi
f0100093:	5d                   	pop    %ebp
f0100094:	c3                   	ret    
		test_backtrace(x-1);
f0100095:	83 ec 0c             	sub    $0xc,%esp
f0100098:	8d 46 ff             	lea    -0x1(%esi),%eax
f010009b:	50                   	push   %eax
f010009c:	e8 9f ff ff ff       	call   f0100040 <test_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d5                	jmp    f010007b <test_backtrace+0x3b>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 12 01 00    	add    $0x11256,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000be:	c7 c0 a0 36 11 f0    	mov    $0xf01136a0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 3a 16 00 00       	call   f0101709 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 3d 05 00 00       	call   f0100611 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 8f 08 ff ff    	lea    -0xf771(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 0c 0a 00 00       	call   f0100af4 <cprintf>
        
    // Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 3b 08 00 00       	call   f010093c <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	57                   	push   %edi
f010010a:	56                   	push   %esi
f010010b:	53                   	push   %ebx
f010010c:	83 ec 0c             	sub    $0xc,%esp
f010010f:	e8 a8 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100114:	81 c3 f4 11 01 00    	add    $0x111f4,%ebx
f010011a:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f010011d:	c7 c0 a4 36 11 f0    	mov    $0xf01136a4,%eax
f0100123:	83 38 00             	cmpl   $0x0,(%eax)
f0100126:	74 0f                	je     f0100137 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100128:	83 ec 0c             	sub    $0xc,%esp
f010012b:	6a 00                	push   $0x0
f010012d:	e8 0a 08 00 00       	call   f010093c <monitor>
f0100132:	83 c4 10             	add    $0x10,%esp
f0100135:	eb f1                	jmp    f0100128 <_panic+0x22>
	panicstr = fmt;
f0100137:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100139:	fa                   	cli    
f010013a:	fc                   	cld    
	va_start(ap, fmt);
f010013b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013e:	83 ec 04             	sub    $0x4,%esp
f0100141:	ff 75 0c             	pushl  0xc(%ebp)
f0100144:	ff 75 08             	pushl  0x8(%ebp)
f0100147:	8d 83 aa 08 ff ff    	lea    -0xf756(%ebx),%eax
f010014d:	50                   	push   %eax
f010014e:	e8 a1 09 00 00       	call   f0100af4 <cprintf>
	vcprintf(fmt, ap);
f0100153:	83 c4 08             	add    $0x8,%esp
f0100156:	56                   	push   %esi
f0100157:	57                   	push   %edi
f0100158:	e8 60 09 00 00       	call   f0100abd <vcprintf>
	cprintf("\n");
f010015d:	8d 83 e6 08 ff ff    	lea    -0xf71a(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 89 09 00 00       	call   f0100af4 <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb b8                	jmp    f0100128 <_panic+0x22>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 8e 11 01 00    	add    $0x1118e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	pushl  0xc(%ebp)
f0100189:	ff 75 08             	pushl  0x8(%ebp)
f010018c:	8d 83 c2 08 ff ff    	lea    -0xf73e(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 5c 09 00 00       	call   f0100af4 <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 19 09 00 00       	call   f0100abd <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 e6 08 ff ff    	lea    -0xf71a(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 42 09 00 00       	call   f0100af4 <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c9:	a8 01                	test   $0x1,%al
f01001cb:	74 0b                	je     f01001d8 <serial_proc_data+0x18>
f01001cd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d3:	0f b6 c0             	movzbl %al,%eax
}
f01001d6:	5d                   	pop    %ebp
f01001d7:	c3                   	ret    
		return -1;
f01001d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001dd:	eb f7                	jmp    f01001d6 <serial_proc_data+0x16>

f01001df <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001df:	55                   	push   %ebp
f01001e0:	89 e5                	mov    %esp,%ebp
f01001e2:	56                   	push   %esi
f01001e3:	53                   	push   %ebx
f01001e4:	e8 d3 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01001e9:	81 c3 1f 11 01 00    	add    $0x1111f,%ebx
f01001ef:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001f1:	ff d6                	call   *%esi
f01001f3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f6:	74 2e                	je     f0100226 <cons_intr+0x47>
		if (c == 0)
f01001f8:	85 c0                	test   %eax,%eax
f01001fa:	74 f5                	je     f01001f1 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001fc:	8b 8b 7c 1f 00 00    	mov    0x1f7c(%ebx),%ecx
f0100202:	8d 51 01             	lea    0x1(%ecx),%edx
f0100205:	89 93 7c 1f 00 00    	mov    %edx,0x1f7c(%ebx)
f010020b:	88 84 0b 78 1d 00 00 	mov    %al,0x1d78(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100212:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100218:	75 d7                	jne    f01001f1 <cons_intr+0x12>
			cons.wpos = 0;
f010021a:	c7 83 7c 1f 00 00 00 	movl   $0x0,0x1f7c(%ebx)
f0100221:	00 00 00 
f0100224:	eb cb                	jmp    f01001f1 <cons_intr+0x12>
	}
}
f0100226:	5b                   	pop    %ebx
f0100227:	5e                   	pop    %esi
f0100228:	5d                   	pop    %ebp
f0100229:	c3                   	ret    

f010022a <kbd_proc_data>:
{
f010022a:	55                   	push   %ebp
f010022b:	89 e5                	mov    %esp,%ebp
f010022d:	56                   	push   %esi
f010022e:	53                   	push   %ebx
f010022f:	e8 88 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100234:	81 c3 d4 10 01 00    	add    $0x110d4,%ebx
f010023a:	ba 64 00 00 00       	mov    $0x64,%edx
f010023f:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100240:	a8 01                	test   $0x1,%al
f0100242:	0f 84 06 01 00 00    	je     f010034e <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f0100248:	a8 20                	test   $0x20,%al
f010024a:	0f 85 05 01 00 00    	jne    f0100355 <kbd_proc_data+0x12b>
f0100250:	ba 60 00 00 00       	mov    $0x60,%edx
f0100255:	ec                   	in     (%dx),%al
f0100256:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100258:	3c e0                	cmp    $0xe0,%al
f010025a:	0f 84 93 00 00 00    	je     f01002f3 <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f0100260:	84 c0                	test   %al,%al
f0100262:	0f 88 a0 00 00 00    	js     f0100308 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100268:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010026e:	f6 c1 40             	test   $0x40,%cl
f0100271:	74 0e                	je     f0100281 <kbd_proc_data+0x57>
		data |= 0x80;
f0100273:	83 c8 80             	or     $0xffffff80,%eax
f0100276:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100278:	83 e1 bf             	and    $0xffffffbf,%ecx
f010027b:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f0100281:	0f b6 d2             	movzbl %dl,%edx
f0100284:	0f b6 84 13 18 0a ff 	movzbl -0xf5e8(%ebx,%edx,1),%eax
f010028b:	ff 
f010028c:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f0100292:	0f b6 8c 13 18 09 ff 	movzbl -0xf6e8(%ebx,%edx,1),%ecx
f0100299:	ff 
f010029a:	31 c8                	xor    %ecx,%eax
f010029c:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002a2:	89 c1                	mov    %eax,%ecx
f01002a4:	83 e1 03             	and    $0x3,%ecx
f01002a7:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002ae:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002b2:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002b5:	a8 08                	test   $0x8,%al
f01002b7:	74 0d                	je     f01002c6 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f01002b9:	89 f2                	mov    %esi,%edx
f01002bb:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002be:	83 f9 19             	cmp    $0x19,%ecx
f01002c1:	77 7a                	ja     f010033d <kbd_proc_data+0x113>
			c += 'A' - 'a';
f01002c3:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002c6:	f7 d0                	not    %eax
f01002c8:	a8 06                	test   $0x6,%al
f01002ca:	75 33                	jne    f01002ff <kbd_proc_data+0xd5>
f01002cc:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002d2:	75 2b                	jne    f01002ff <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f01002d4:	83 ec 0c             	sub    $0xc,%esp
f01002d7:	8d 83 dc 08 ff ff    	lea    -0xf724(%ebx),%eax
f01002dd:	50                   	push   %eax
f01002de:	e8 11 08 00 00       	call   f0100af4 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e8:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ed:	ee                   	out    %al,(%dx)
f01002ee:	83 c4 10             	add    $0x10,%esp
f01002f1:	eb 0c                	jmp    f01002ff <kbd_proc_data+0xd5>
		shift |= E0ESC;
f01002f3:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002fa:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002ff:	89 f0                	mov    %esi,%eax
f0100301:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100304:	5b                   	pop    %ebx
f0100305:	5e                   	pop    %esi
f0100306:	5d                   	pop    %ebp
f0100307:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100308:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010030e:	89 ce                	mov    %ecx,%esi
f0100310:	83 e6 40             	and    $0x40,%esi
f0100313:	83 e0 7f             	and    $0x7f,%eax
f0100316:	85 f6                	test   %esi,%esi
f0100318:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010031b:	0f b6 d2             	movzbl %dl,%edx
f010031e:	0f b6 84 13 18 0a ff 	movzbl -0xf5e8(%ebx,%edx,1),%eax
f0100325:	ff 
f0100326:	83 c8 40             	or     $0x40,%eax
f0100329:	0f b6 c0             	movzbl %al,%eax
f010032c:	f7 d0                	not    %eax
f010032e:	21 c8                	and    %ecx,%eax
f0100330:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f0100336:	be 00 00 00 00       	mov    $0x0,%esi
f010033b:	eb c2                	jmp    f01002ff <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f010033d:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100340:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100343:	83 fa 1a             	cmp    $0x1a,%edx
f0100346:	0f 42 f1             	cmovb  %ecx,%esi
f0100349:	e9 78 ff ff ff       	jmp    f01002c6 <kbd_proc_data+0x9c>
		return -1;
f010034e:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100353:	eb aa                	jmp    f01002ff <kbd_proc_data+0xd5>
		return -1;
f0100355:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035a:	eb a3                	jmp    f01002ff <kbd_proc_data+0xd5>

f010035c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010035c:	55                   	push   %ebp
f010035d:	89 e5                	mov    %esp,%ebp
f010035f:	57                   	push   %edi
f0100360:	56                   	push   %esi
f0100361:	53                   	push   %ebx
f0100362:	83 ec 1c             	sub    $0x1c,%esp
f0100365:	e8 52 fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010036a:	81 c3 9e 0f 01 00    	add    $0x10f9e,%ebx
f0100370:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100373:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100378:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010037d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100382:	eb 09                	jmp    f010038d <cons_putc+0x31>
f0100384:	89 ca                	mov    %ecx,%edx
f0100386:	ec                   	in     (%dx),%al
f0100387:	ec                   	in     (%dx),%al
f0100388:	ec                   	in     (%dx),%al
f0100389:	ec                   	in     (%dx),%al
	     i++)
f010038a:	83 c6 01             	add    $0x1,%esi
f010038d:	89 fa                	mov    %edi,%edx
f010038f:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100390:	a8 20                	test   $0x20,%al
f0100392:	75 08                	jne    f010039c <cons_putc+0x40>
f0100394:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010039a:	7e e8                	jle    f0100384 <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f010039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010039f:	89 f8                	mov    %edi,%eax
f01003a1:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003a9:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003aa:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003af:	bf 79 03 00 00       	mov    $0x379,%edi
f01003b4:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b9:	eb 09                	jmp    f01003c4 <cons_putc+0x68>
f01003bb:	89 ca                	mov    %ecx,%edx
f01003bd:	ec                   	in     (%dx),%al
f01003be:	ec                   	in     (%dx),%al
f01003bf:	ec                   	in     (%dx),%al
f01003c0:	ec                   	in     (%dx),%al
f01003c1:	83 c6 01             	add    $0x1,%esi
f01003c4:	89 fa                	mov    %edi,%edx
f01003c6:	ec                   	in     (%dx),%al
f01003c7:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003cd:	7f 04                	jg     f01003d3 <cons_putc+0x77>
f01003cf:	84 c0                	test   %al,%al
f01003d1:	79 e8                	jns    f01003bb <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d3:	ba 78 03 00 00       	mov    $0x378,%edx
f01003d8:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003dc:	ee                   	out    %al,(%dx)
f01003dd:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003e7:	ee                   	out    %al,(%dx)
f01003e8:	b8 08 00 00 00       	mov    $0x8,%eax
f01003ed:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003f1:	89 fa                	mov    %edi,%edx
f01003f3:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003f9:	89 f8                	mov    %edi,%eax
f01003fb:	80 cc 07             	or     $0x7,%ah
f01003fe:	85 d2                	test   %edx,%edx
f0100400:	0f 45 c7             	cmovne %edi,%eax
f0100403:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100406:	0f b6 c0             	movzbl %al,%eax
f0100409:	83 f8 09             	cmp    $0x9,%eax
f010040c:	0f 84 b9 00 00 00    	je     f01004cb <cons_putc+0x16f>
f0100412:	83 f8 09             	cmp    $0x9,%eax
f0100415:	7e 74                	jle    f010048b <cons_putc+0x12f>
f0100417:	83 f8 0a             	cmp    $0xa,%eax
f010041a:	0f 84 9e 00 00 00    	je     f01004be <cons_putc+0x162>
f0100420:	83 f8 0d             	cmp    $0xd,%eax
f0100423:	0f 85 d9 00 00 00    	jne    f0100502 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100429:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100430:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100436:	c1 e8 16             	shr    $0x16,%eax
f0100439:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010043c:	c1 e0 04             	shl    $0x4,%eax
f010043f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100446:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010044d:	cf 07 
f010044f:	0f 87 d4 00 00 00    	ja     f0100529 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100455:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f010045b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100460:	89 ca                	mov    %ecx,%edx
f0100462:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100463:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f010046a:	8d 71 01             	lea    0x1(%ecx),%esi
f010046d:	89 d8                	mov    %ebx,%eax
f010046f:	66 c1 e8 08          	shr    $0x8,%ax
f0100473:	89 f2                	mov    %esi,%edx
f0100475:	ee                   	out    %al,(%dx)
f0100476:	b8 0f 00 00 00       	mov    $0xf,%eax
f010047b:	89 ca                	mov    %ecx,%edx
f010047d:	ee                   	out    %al,(%dx)
f010047e:	89 d8                	mov    %ebx,%eax
f0100480:	89 f2                	mov    %esi,%edx
f0100482:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100483:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100486:	5b                   	pop    %ebx
f0100487:	5e                   	pop    %esi
f0100488:	5f                   	pop    %edi
f0100489:	5d                   	pop    %ebp
f010048a:	c3                   	ret    
	switch (c & 0xff) {
f010048b:	83 f8 08             	cmp    $0x8,%eax
f010048e:	75 72                	jne    f0100502 <cons_putc+0x1a6>
		if (crt_pos > 0) {
f0100490:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100497:	66 85 c0             	test   %ax,%ax
f010049a:	74 b9                	je     f0100455 <cons_putc+0xf9>
			crt_pos--;
f010049c:	83 e8 01             	sub    $0x1,%eax
f010049f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a6:	0f b7 c0             	movzwl %ax,%eax
f01004a9:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004ad:	b2 00                	mov    $0x0,%dl
f01004af:	83 ca 20             	or     $0x20,%edx
f01004b2:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f01004b8:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004bc:	eb 88                	jmp    f0100446 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f01004be:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f01004c5:	50 
f01004c6:	e9 5e ff ff ff       	jmp    f0100429 <cons_putc+0xcd>
		cons_putc(' ');
f01004cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d0:	e8 87 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004d5:	b8 20 00 00 00       	mov    $0x20,%eax
f01004da:	e8 7d fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004df:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e4:	e8 73 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004e9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ee:	e8 69 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f8:	e8 5f fe ff ff       	call   f010035c <cons_putc>
f01004fd:	e9 44 ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100502:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100509:	8d 50 01             	lea    0x1(%eax),%edx
f010050c:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100513:	0f b7 c0             	movzwl %ax,%eax
f0100516:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010051c:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100520:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100524:	e9 1d ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100529:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010052f:	83 ec 04             	sub    $0x4,%esp
f0100532:	68 00 0f 00 00       	push   $0xf00
f0100537:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010053d:	52                   	push   %edx
f010053e:	50                   	push   %eax
f010053f:	e8 12 12 00 00       	call   f0101756 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100544:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010054a:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100550:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100556:	83 c4 10             	add    $0x10,%esp
f0100559:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010055e:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100561:	39 d0                	cmp    %edx,%eax
f0100563:	75 f4                	jne    f0100559 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100565:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010056c:	50 
f010056d:	e9 e3 fe ff ff       	jmp    f0100455 <cons_putc+0xf9>

f0100572 <serial_intr>:
{
f0100572:	e8 e7 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f0100577:	05 91 0d 01 00       	add    $0x10d91,%eax
	if (serial_exists)
f010057c:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100583:	75 02                	jne    f0100587 <serial_intr+0x15>
f0100585:	f3 c3                	repz ret 
{
f0100587:	55                   	push   %ebp
f0100588:	89 e5                	mov    %esp,%ebp
f010058a:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010058d:	8d 80 b8 ee fe ff    	lea    -0x11148(%eax),%eax
f0100593:	e8 47 fc ff ff       	call   f01001df <cons_intr>
}
f0100598:	c9                   	leave  
f0100599:	c3                   	ret    

f010059a <kbd_intr>:
{
f010059a:	55                   	push   %ebp
f010059b:	89 e5                	mov    %esp,%ebp
f010059d:	83 ec 08             	sub    $0x8,%esp
f01005a0:	e8 b9 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f01005a5:	05 63 0d 01 00       	add    $0x10d63,%eax
	cons_intr(kbd_proc_data);
f01005aa:	8d 80 22 ef fe ff    	lea    -0x110de(%eax),%eax
f01005b0:	e8 2a fc ff ff       	call   f01001df <cons_intr>
}
f01005b5:	c9                   	leave  
f01005b6:	c3                   	ret    

f01005b7 <cons_getc>:
{
f01005b7:	55                   	push   %ebp
f01005b8:	89 e5                	mov    %esp,%ebp
f01005ba:	53                   	push   %ebx
f01005bb:	83 ec 04             	sub    $0x4,%esp
f01005be:	e8 f9 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005c3:	81 c3 45 0d 01 00    	add    $0x10d45,%ebx
	serial_intr();
f01005c9:	e8 a4 ff ff ff       	call   f0100572 <serial_intr>
	kbd_intr();
f01005ce:	e8 c7 ff ff ff       	call   f010059a <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005d3:	8b 93 78 1f 00 00    	mov    0x1f78(%ebx),%edx
	return 0;
f01005d9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005de:	3b 93 7c 1f 00 00    	cmp    0x1f7c(%ebx),%edx
f01005e4:	74 19                	je     f01005ff <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
f01005e9:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
f01005ef:	0f b6 84 13 78 1d 00 	movzbl 0x1d78(%ebx,%edx,1),%eax
f01005f6:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005f7:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005fd:	74 06                	je     f0100605 <cons_getc+0x4e>
}
f01005ff:	83 c4 04             	add    $0x4,%esp
f0100602:	5b                   	pop    %ebx
f0100603:	5d                   	pop    %ebp
f0100604:	c3                   	ret    
			cons.rpos = 0;
f0100605:	c7 83 78 1f 00 00 00 	movl   $0x0,0x1f78(%ebx)
f010060c:	00 00 00 
f010060f:	eb ee                	jmp    f01005ff <cons_getc+0x48>

f0100611 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100611:	55                   	push   %ebp
f0100612:	89 e5                	mov    %esp,%ebp
f0100614:	57                   	push   %edi
f0100615:	56                   	push   %esi
f0100616:	53                   	push   %ebx
f0100617:	83 ec 1c             	sub    $0x1c,%esp
f010061a:	e8 9d fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010061f:	81 c3 e9 0c 01 00    	add    $0x10ce9,%ebx
	was = *cp;
f0100625:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010062c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100633:	5a a5 
	if (*cp != 0xA55A) {
f0100635:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010063c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100640:	0f 84 bc 00 00 00    	je     f0100702 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100646:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f010064d:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100650:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100657:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f010065d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100662:	89 fa                	mov    %edi,%edx
f0100664:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100665:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100668:	89 ca                	mov    %ecx,%edx
f010066a:	ec                   	in     (%dx),%al
f010066b:	0f b6 f0             	movzbl %al,%esi
f010066e:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100671:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100676:	89 fa                	mov    %edi,%edx
f0100678:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100679:	89 ca                	mov    %ecx,%edx
f010067b:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010067f:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f0100685:	0f b6 c0             	movzbl %al,%eax
f0100688:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010068a:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100691:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100696:	89 c8                	mov    %ecx,%eax
f0100698:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010069d:	ee                   	out    %al,(%dx)
f010069e:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006a3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a8:	89 fa                	mov    %edi,%edx
f01006aa:	ee                   	out    %al,(%dx)
f01006ab:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006b0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006b5:	ee                   	out    %al,(%dx)
f01006b6:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006bb:	89 c8                	mov    %ecx,%eax
f01006bd:	89 f2                	mov    %esi,%edx
f01006bf:	ee                   	out    %al,(%dx)
f01006c0:	b8 03 00 00 00       	mov    $0x3,%eax
f01006c5:	89 fa                	mov    %edi,%edx
f01006c7:	ee                   	out    %al,(%dx)
f01006c8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006cd:	89 c8                	mov    %ecx,%eax
f01006cf:	ee                   	out    %al,(%dx)
f01006d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01006d5:	89 f2                	mov    %esi,%edx
f01006d7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006dd:	ec                   	in     (%dx),%al
f01006de:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006e0:	3c ff                	cmp    $0xff,%al
f01006e2:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f01006e9:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006ee:	ec                   	in     (%dx),%al
f01006ef:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006f4:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006f5:	80 f9 ff             	cmp    $0xff,%cl
f01006f8:	74 25                	je     f010071f <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006fd:	5b                   	pop    %ebx
f01006fe:	5e                   	pop    %esi
f01006ff:	5f                   	pop    %edi
f0100700:	5d                   	pop    %ebp
f0100701:	c3                   	ret    
		*cp = was;
f0100702:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100709:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f0100710:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100713:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f010071a:	e9 38 ff ff ff       	jmp    f0100657 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f010071f:	83 ec 0c             	sub    $0xc,%esp
f0100722:	8d 83 e8 08 ff ff    	lea    -0xf718(%ebx),%eax
f0100728:	50                   	push   %eax
f0100729:	e8 c6 03 00 00       	call   f0100af4 <cprintf>
f010072e:	83 c4 10             	add    $0x10,%esp
}
f0100731:	eb c7                	jmp    f01006fa <cons_init+0xe9>

f0100733 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100733:	55                   	push   %ebp
f0100734:	89 e5                	mov    %esp,%ebp
f0100736:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100739:	8b 45 08             	mov    0x8(%ebp),%eax
f010073c:	e8 1b fc ff ff       	call   f010035c <cons_putc>
}
f0100741:	c9                   	leave  
f0100742:	c3                   	ret    

f0100743 <getchar>:

int
getchar(void)
{
f0100743:	55                   	push   %ebp
f0100744:	89 e5                	mov    %esp,%ebp
f0100746:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100749:	e8 69 fe ff ff       	call   f01005b7 <cons_getc>
f010074e:	85 c0                	test   %eax,%eax
f0100750:	74 f7                	je     f0100749 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100752:	c9                   	leave  
f0100753:	c3                   	ret    

f0100754 <iscons>:

int
iscons(int fdnum)
{
f0100754:	55                   	push   %ebp
f0100755:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100757:	b8 01 00 00 00       	mov    $0x1,%eax
f010075c:	5d                   	pop    %ebp
f010075d:	c3                   	ret    

f010075e <__x86.get_pc_thunk.ax>:
f010075e:	8b 04 24             	mov    (%esp),%eax
f0100761:	c3                   	ret    

f0100762 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100762:	55                   	push   %ebp
f0100763:	89 e5                	mov    %esp,%ebp
f0100765:	56                   	push   %esi
f0100766:	53                   	push   %ebx
f0100767:	e8 50 fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010076c:	81 c3 9c 0b 01 00    	add    $0x10b9c,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100772:	83 ec 04             	sub    $0x4,%esp
f0100775:	8d 83 18 0b ff ff    	lea    -0xf4e8(%ebx),%eax
f010077b:	50                   	push   %eax
f010077c:	8d 83 36 0b ff ff    	lea    -0xf4ca(%ebx),%eax
f0100782:	50                   	push   %eax
f0100783:	8d b3 3b 0b ff ff    	lea    -0xf4c5(%ebx),%esi
f0100789:	56                   	push   %esi
f010078a:	e8 65 03 00 00       	call   f0100af4 <cprintf>
f010078f:	83 c4 0c             	add    $0xc,%esp
f0100792:	8d 83 d4 0b ff ff    	lea    -0xf42c(%ebx),%eax
f0100798:	50                   	push   %eax
f0100799:	8d 83 44 0b ff ff    	lea    -0xf4bc(%ebx),%eax
f010079f:	50                   	push   %eax
f01007a0:	56                   	push   %esi
f01007a1:	e8 4e 03 00 00       	call   f0100af4 <cprintf>
f01007a6:	83 c4 0c             	add    $0xc,%esp
f01007a9:	8d 83 fc 0b ff ff    	lea    -0xf404(%ebx),%eax
f01007af:	50                   	push   %eax
f01007b0:	8d 83 4d 0b ff ff    	lea    -0xf4b3(%ebx),%eax
f01007b6:	50                   	push   %eax
f01007b7:	56                   	push   %esi
f01007b8:	e8 37 03 00 00       	call   f0100af4 <cprintf>
	return 0;
}
f01007bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01007c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007c5:	5b                   	pop    %ebx
f01007c6:	5e                   	pop    %esi
f01007c7:	5d                   	pop    %ebp
f01007c8:	c3                   	ret    

f01007c9 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007c9:	55                   	push   %ebp
f01007ca:	89 e5                	mov    %esp,%ebp
f01007cc:	57                   	push   %edi
f01007cd:	56                   	push   %esi
f01007ce:	53                   	push   %ebx
f01007cf:	83 ec 18             	sub    $0x18,%esp
f01007d2:	e8 e5 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007d7:	81 c3 31 0b 01 00    	add    $0x10b31,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007dd:	8d 83 57 0b ff ff    	lea    -0xf4a9(%ebx),%eax
f01007e3:	50                   	push   %eax
f01007e4:	e8 0b 03 00 00       	call   f0100af4 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007e9:	83 c4 08             	add    $0x8,%esp
f01007ec:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007f2:	8d 83 20 0c ff ff    	lea    -0xf3e0(%ebx),%eax
f01007f8:	50                   	push   %eax
f01007f9:	e8 f6 02 00 00       	call   f0100af4 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007fe:	83 c4 0c             	add    $0xc,%esp
f0100801:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f0100807:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f010080d:	50                   	push   %eax
f010080e:	57                   	push   %edi
f010080f:	8d 83 48 0c ff ff    	lea    -0xf3b8(%ebx),%eax
f0100815:	50                   	push   %eax
f0100816:	e8 d9 02 00 00       	call   f0100af4 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010081b:	83 c4 0c             	add    $0xc,%esp
f010081e:	c7 c0 49 1b 10 f0    	mov    $0xf0101b49,%eax
f0100824:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010082a:	52                   	push   %edx
f010082b:	50                   	push   %eax
f010082c:	8d 83 6c 0c ff ff    	lea    -0xf394(%ebx),%eax
f0100832:	50                   	push   %eax
f0100833:	e8 bc 02 00 00       	call   f0100af4 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100838:	83 c4 0c             	add    $0xc,%esp
f010083b:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f0100841:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100847:	52                   	push   %edx
f0100848:	50                   	push   %eax
f0100849:	8d 83 90 0c ff ff    	lea    -0xf370(%ebx),%eax
f010084f:	50                   	push   %eax
f0100850:	e8 9f 02 00 00       	call   f0100af4 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100855:	83 c4 0c             	add    $0xc,%esp
f0100858:	c7 c6 a0 36 11 f0    	mov    $0xf01136a0,%esi
f010085e:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100864:	50                   	push   %eax
f0100865:	56                   	push   %esi
f0100866:	8d 83 b4 0c ff ff    	lea    -0xf34c(%ebx),%eax
f010086c:	50                   	push   %eax
f010086d:	e8 82 02 00 00       	call   f0100af4 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100872:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100875:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f010087b:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f010087d:	c1 fe 0a             	sar    $0xa,%esi
f0100880:	56                   	push   %esi
f0100881:	8d 83 d8 0c ff ff    	lea    -0xf328(%ebx),%eax
f0100887:	50                   	push   %eax
f0100888:	e8 67 02 00 00       	call   f0100af4 <cprintf>
	return 0;
}
f010088d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100892:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100895:	5b                   	pop    %ebx
f0100896:	5e                   	pop    %esi
f0100897:	5f                   	pop    %edi
f0100898:	5d                   	pop    %ebp
f0100899:	c3                   	ret    

f010089a <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010089a:	55                   	push   %ebp
f010089b:	89 e5                	mov    %esp,%ebp
f010089d:	57                   	push   %edi
f010089e:	56                   	push   %esi
f010089f:	53                   	push   %ebx
f01008a0:	83 ec 48             	sub    $0x48,%esp
f01008a3:	e8 14 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01008a8:	81 c3 60 0a 01 00    	add    $0x10a60,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ae:	89 ee                	mov    %ebp,%esi
f01008b0:	89 f7                	mov    %esi,%edi
    uint32_t ebp = read_ebp();
	uint32_t *prev;
    prev = (uint32_t *)ebp;
    struct Eipdebuginfo info;

    cprintf("Stack backtrace:\n");
f01008b2:	8d 83 70 0b ff ff    	lea    -0xf490(%ebx),%eax
f01008b8:	50                   	push   %eax
f01008b9:	e8 36 02 00 00       	call   f0100af4 <cprintf>
    while(ebp != 0 && debuginfo_eip(prev[1], &info) == 0)
f01008be:	83 c4 10             	add    $0x10,%esp
f01008c1:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008c4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    {
        //cprintf("ebp %x &ebp %p prev %p *prev %x\n", ebp, &ebp, prev, *prev);

        //cprintf("prev[0] %x prev[1] %x prev[2] %x\n", prev[0], prev[1], prev[2]);
        cprintf("ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", ebp, prev[1], prev[2], prev[3], prev[4], prev[5], prev[6]);
f01008c7:	8d 83 04 0d ff ff    	lea    -0xf2fc(%ebx),%eax
f01008cd:	89 45 c0             	mov    %eax,-0x40(%ebp)
    while(ebp != 0 && debuginfo_eip(prev[1], &info) == 0)
f01008d0:	eb 44                	jmp    f0100916 <mon_backtrace+0x7c>
        cprintf("ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", ebp, prev[1], prev[2], prev[3], prev[4], prev[5], prev[6]);
f01008d2:	ff 76 18             	pushl  0x18(%esi)
f01008d5:	ff 76 14             	pushl  0x14(%esi)
f01008d8:	ff 76 10             	pushl  0x10(%esi)
f01008db:	ff 76 0c             	pushl  0xc(%esi)
f01008de:	ff 76 08             	pushl  0x8(%esi)
f01008e1:	ff 76 04             	pushl  0x4(%esi)
f01008e4:	57                   	push   %edi
f01008e5:	ff 75 c0             	pushl  -0x40(%ebp)
f01008e8:	e8 07 02 00 00       	call   f0100af4 <cprintf>
        cprintf("     %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, prev[1] - info.eip_fn_addr);
f01008ed:	83 c4 18             	add    $0x18,%esp
f01008f0:	8b 46 04             	mov    0x4(%esi),%eax
f01008f3:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01008f6:	50                   	push   %eax
f01008f7:	ff 75 d8             	pushl  -0x28(%ebp)
f01008fa:	ff 75 dc             	pushl  -0x24(%ebp)
f01008fd:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100900:	ff 75 d0             	pushl  -0x30(%ebp)
f0100903:	8d 83 82 0b ff ff    	lea    -0xf47e(%ebx),%eax
f0100909:	50                   	push   %eax
f010090a:	e8 e5 01 00 00       	call   f0100af4 <cprintf>
        ebp = *prev;
f010090f:	8b 3e                	mov    (%esi),%edi
        prev = (uint32_t *)ebp;
f0100911:	89 fe                	mov    %edi,%esi
f0100913:	83 c4 20             	add    $0x20,%esp
    while(ebp != 0 && debuginfo_eip(prev[1], &info) == 0)
f0100916:	85 ff                	test   %edi,%edi
f0100918:	74 15                	je     f010092f <mon_backtrace+0x95>
f010091a:	83 ec 08             	sub    $0x8,%esp
f010091d:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100920:	ff 76 04             	pushl  0x4(%esi)
f0100923:	e8 d0 02 00 00       	call   f0100bf8 <debuginfo_eip>
f0100928:	83 c4 10             	add    $0x10,%esp
f010092b:	85 c0                	test   %eax,%eax
f010092d:	74 a3                	je     f01008d2 <mon_backtrace+0x38>
        

    }
	return 0;
}
f010092f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100934:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100937:	5b                   	pop    %ebx
f0100938:	5e                   	pop    %esi
f0100939:	5f                   	pop    %edi
f010093a:	5d                   	pop    %ebp
f010093b:	c3                   	ret    

f010093c <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010093c:	55                   	push   %ebp
f010093d:	89 e5                	mov    %esp,%ebp
f010093f:	57                   	push   %edi
f0100940:	56                   	push   %esi
f0100941:	53                   	push   %ebx
f0100942:	83 ec 68             	sub    $0x68,%esp
f0100945:	e8 72 f8 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010094a:	81 c3 be 09 01 00    	add    $0x109be,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100950:	8d 83 34 0d ff ff    	lea    -0xf2cc(%ebx),%eax
f0100956:	50                   	push   %eax
f0100957:	e8 98 01 00 00       	call   f0100af4 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010095c:	8d 83 58 0d ff ff    	lea    -0xf2a8(%ebx),%eax
f0100962:	89 04 24             	mov    %eax,(%esp)
f0100965:	e8 8a 01 00 00       	call   f0100af4 <cprintf>
f010096a:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010096d:	8d bb 9b 0b ff ff    	lea    -0xf465(%ebx),%edi
f0100973:	eb 4a                	jmp    f01009bf <monitor+0x83>
f0100975:	83 ec 08             	sub    $0x8,%esp
f0100978:	0f be c0             	movsbl %al,%eax
f010097b:	50                   	push   %eax
f010097c:	57                   	push   %edi
f010097d:	e8 4a 0d 00 00       	call   f01016cc <strchr>
f0100982:	83 c4 10             	add    $0x10,%esp
f0100985:	85 c0                	test   %eax,%eax
f0100987:	74 08                	je     f0100991 <monitor+0x55>
			*buf++ = 0;
f0100989:	c6 06 00             	movb   $0x0,(%esi)
f010098c:	8d 76 01             	lea    0x1(%esi),%esi
f010098f:	eb 79                	jmp    f0100a0a <monitor+0xce>
		if (*buf == 0)
f0100991:	80 3e 00             	cmpb   $0x0,(%esi)
f0100994:	74 7f                	je     f0100a15 <monitor+0xd9>
		if (argc == MAXARGS-1) {
f0100996:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f010099a:	74 0f                	je     f01009ab <monitor+0x6f>
		argv[argc++] = buf;
f010099c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010099f:	8d 48 01             	lea    0x1(%eax),%ecx
f01009a2:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009a5:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f01009a9:	eb 44                	jmp    f01009ef <monitor+0xb3>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009ab:	83 ec 08             	sub    $0x8,%esp
f01009ae:	6a 10                	push   $0x10
f01009b0:	8d 83 a0 0b ff ff    	lea    -0xf460(%ebx),%eax
f01009b6:	50                   	push   %eax
f01009b7:	e8 38 01 00 00       	call   f0100af4 <cprintf>
f01009bc:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01009bf:	8d 83 97 0b ff ff    	lea    -0xf469(%ebx),%eax
f01009c5:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01009c8:	83 ec 0c             	sub    $0xc,%esp
f01009cb:	ff 75 a4             	pushl  -0x5c(%ebp)
f01009ce:	e8 c1 0a 00 00       	call   f0101494 <readline>
f01009d3:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01009d5:	83 c4 10             	add    $0x10,%esp
f01009d8:	85 c0                	test   %eax,%eax
f01009da:	74 ec                	je     f01009c8 <monitor+0x8c>
	argv[argc] = 0;
f01009dc:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009e3:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01009ea:	eb 1e                	jmp    f0100a0a <monitor+0xce>
			buf++;
f01009ec:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009ef:	0f b6 06             	movzbl (%esi),%eax
f01009f2:	84 c0                	test   %al,%al
f01009f4:	74 14                	je     f0100a0a <monitor+0xce>
f01009f6:	83 ec 08             	sub    $0x8,%esp
f01009f9:	0f be c0             	movsbl %al,%eax
f01009fc:	50                   	push   %eax
f01009fd:	57                   	push   %edi
f01009fe:	e8 c9 0c 00 00       	call   f01016cc <strchr>
f0100a03:	83 c4 10             	add    $0x10,%esp
f0100a06:	85 c0                	test   %eax,%eax
f0100a08:	74 e2                	je     f01009ec <monitor+0xb0>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a0a:	0f b6 06             	movzbl (%esi),%eax
f0100a0d:	84 c0                	test   %al,%al
f0100a0f:	0f 85 60 ff ff ff    	jne    f0100975 <monitor+0x39>
	argv[argc] = 0;
f0100a15:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a18:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a1f:	00 
	if (argc == 0)
f0100a20:	85 c0                	test   %eax,%eax
f0100a22:	74 9b                	je     f01009bf <monitor+0x83>
f0100a24:	8d b3 18 1d 00 00    	lea    0x1d18(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a2a:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%ebp)
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a31:	83 ec 08             	sub    $0x8,%esp
f0100a34:	ff 36                	pushl  (%esi)
f0100a36:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a39:	e8 30 0c 00 00       	call   f010166e <strcmp>
f0100a3e:	83 c4 10             	add    $0x10,%esp
f0100a41:	85 c0                	test   %eax,%eax
f0100a43:	74 29                	je     f0100a6e <monitor+0x132>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a45:	83 45 a0 01          	addl   $0x1,-0x60(%ebp)
f0100a49:	8b 45 a0             	mov    -0x60(%ebp),%eax
f0100a4c:	83 c6 0c             	add    $0xc,%esi
f0100a4f:	83 f8 03             	cmp    $0x3,%eax
f0100a52:	75 dd                	jne    f0100a31 <monitor+0xf5>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a54:	83 ec 08             	sub    $0x8,%esp
f0100a57:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a5a:	8d 83 bd 0b ff ff    	lea    -0xf443(%ebx),%eax
f0100a60:	50                   	push   %eax
f0100a61:	e8 8e 00 00 00       	call   f0100af4 <cprintf>
f0100a66:	83 c4 10             	add    $0x10,%esp
f0100a69:	e9 51 ff ff ff       	jmp    f01009bf <monitor+0x83>
			return commands[i].func(argc, argv, tf);
f0100a6e:	83 ec 04             	sub    $0x4,%esp
f0100a71:	8b 45 a0             	mov    -0x60(%ebp),%eax
f0100a74:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a77:	ff 75 08             	pushl  0x8(%ebp)
f0100a7a:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a7d:	52                   	push   %edx
f0100a7e:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100a81:	ff 94 83 20 1d 00 00 	call   *0x1d20(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a88:	83 c4 10             	add    $0x10,%esp
f0100a8b:	85 c0                	test   %eax,%eax
f0100a8d:	0f 89 2c ff ff ff    	jns    f01009bf <monitor+0x83>
				break;
	}
}
f0100a93:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a96:	5b                   	pop    %ebx
f0100a97:	5e                   	pop    %esi
f0100a98:	5f                   	pop    %edi
f0100a99:	5d                   	pop    %ebp
f0100a9a:	c3                   	ret    

f0100a9b <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100a9b:	55                   	push   %ebp
f0100a9c:	89 e5                	mov    %esp,%ebp
f0100a9e:	53                   	push   %ebx
f0100a9f:	83 ec 10             	sub    $0x10,%esp
f0100aa2:	e8 15 f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100aa7:	81 c3 61 08 01 00    	add    $0x10861,%ebx
	cputchar(ch);
f0100aad:	ff 75 08             	pushl  0x8(%ebp)
f0100ab0:	e8 7e fc ff ff       	call   f0100733 <cputchar>
	*cnt++;
}
f0100ab5:	83 c4 10             	add    $0x10,%esp
f0100ab8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100abb:	c9                   	leave  
f0100abc:	c3                   	ret    

f0100abd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100abd:	55                   	push   %ebp
f0100abe:	89 e5                	mov    %esp,%ebp
f0100ac0:	53                   	push   %ebx
f0100ac1:	83 ec 14             	sub    $0x14,%esp
f0100ac4:	e8 f3 f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100ac9:	81 c3 3f 08 01 00    	add    $0x1083f,%ebx
	int cnt = 0;
f0100acf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100ad6:	ff 75 0c             	pushl  0xc(%ebp)
f0100ad9:	ff 75 08             	pushl  0x8(%ebp)
f0100adc:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100adf:	50                   	push   %eax
f0100ae0:	8d 83 93 f7 fe ff    	lea    -0x1086d(%ebx),%eax
f0100ae6:	50                   	push   %eax
f0100ae7:	e8 98 04 00 00       	call   f0100f84 <vprintfmt>
	return cnt;
}
f0100aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100aef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100af2:	c9                   	leave  
f0100af3:	c3                   	ret    

f0100af4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100af4:	55                   	push   %ebp
f0100af5:	89 e5                	mov    %esp,%ebp
f0100af7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100afa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100afd:	50                   	push   %eax
f0100afe:	ff 75 08             	pushl  0x8(%ebp)
f0100b01:	e8 b7 ff ff ff       	call   f0100abd <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b06:	c9                   	leave  
f0100b07:	c3                   	ret    

f0100b08 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b08:	55                   	push   %ebp
f0100b09:	89 e5                	mov    %esp,%ebp
f0100b0b:	57                   	push   %edi
f0100b0c:	56                   	push   %esi
f0100b0d:	53                   	push   %ebx
f0100b0e:	83 ec 14             	sub    $0x14,%esp
f0100b11:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b14:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b17:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b1a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b1d:	8b 32                	mov    (%edx),%esi
f0100b1f:	8b 01                	mov    (%ecx),%eax
f0100b21:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b24:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b2b:	eb 2f                	jmp    f0100b5c <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100b2d:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b30:	39 c6                	cmp    %eax,%esi
f0100b32:	7f 49                	jg     f0100b7d <stab_binsearch+0x75>
f0100b34:	0f b6 0a             	movzbl (%edx),%ecx
f0100b37:	83 ea 0c             	sub    $0xc,%edx
f0100b3a:	39 f9                	cmp    %edi,%ecx
f0100b3c:	75 ef                	jne    f0100b2d <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b3e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b41:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b44:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b48:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b4b:	73 35                	jae    f0100b82 <stab_binsearch+0x7a>
			*region_left = m;
f0100b4d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b50:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100b52:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0100b55:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100b5c:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100b5f:	7f 4e                	jg     f0100baf <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0100b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b64:	01 f0                	add    %esi,%eax
f0100b66:	89 c3                	mov    %eax,%ebx
f0100b68:	c1 eb 1f             	shr    $0x1f,%ebx
f0100b6b:	01 c3                	add    %eax,%ebx
f0100b6d:	d1 fb                	sar    %ebx
f0100b6f:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b72:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b75:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100b79:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b7b:	eb b3                	jmp    f0100b30 <stab_binsearch+0x28>
			l = true_m + 1;
f0100b7d:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100b80:	eb da                	jmp    f0100b5c <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100b82:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b85:	76 14                	jbe    f0100b9b <stab_binsearch+0x93>
			*region_right = m - 1;
f0100b87:	83 e8 01             	sub    $0x1,%eax
f0100b8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b8d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100b90:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100b92:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b99:	eb c1                	jmp    f0100b5c <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100b9b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b9e:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100ba0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100ba4:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100ba6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bad:	eb ad                	jmp    f0100b5c <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100baf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100bb3:	74 16                	je     f0100bcb <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100bb5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bb8:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100bba:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bbd:	8b 0e                	mov    (%esi),%ecx
f0100bbf:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bc2:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100bc5:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100bc9:	eb 12                	jmp    f0100bdd <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0100bcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bce:	8b 00                	mov    (%eax),%eax
f0100bd0:	83 e8 01             	sub    $0x1,%eax
f0100bd3:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100bd6:	89 07                	mov    %eax,(%edi)
f0100bd8:	eb 16                	jmp    f0100bf0 <stab_binsearch+0xe8>
		     l--)
f0100bda:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100bdd:	39 c1                	cmp    %eax,%ecx
f0100bdf:	7d 0a                	jge    f0100beb <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0100be1:	0f b6 1a             	movzbl (%edx),%ebx
f0100be4:	83 ea 0c             	sub    $0xc,%edx
f0100be7:	39 fb                	cmp    %edi,%ebx
f0100be9:	75 ef                	jne    f0100bda <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0100beb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100bee:	89 07                	mov    %eax,(%edi)
	}
}
f0100bf0:	83 c4 14             	add    $0x14,%esp
f0100bf3:	5b                   	pop    %ebx
f0100bf4:	5e                   	pop    %esi
f0100bf5:	5f                   	pop    %edi
f0100bf6:	5d                   	pop    %ebp
f0100bf7:	c3                   	ret    

f0100bf8 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100bf8:	55                   	push   %ebp
f0100bf9:	89 e5                	mov    %esp,%ebp
f0100bfb:	57                   	push   %edi
f0100bfc:	56                   	push   %esi
f0100bfd:	53                   	push   %ebx
f0100bfe:	83 ec 3c             	sub    $0x3c,%esp
f0100c01:	e8 b6 f5 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100c06:	81 c3 02 07 01 00    	add    $0x10702,%ebx
f0100c0c:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100c0f:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c12:	8d 83 80 0d ff ff    	lea    -0xf280(%ebx),%eax
f0100c18:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100c1a:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100c21:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100c24:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100c2b:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100c2e:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c35:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100c3b:	0f 86 37 01 00 00    	jbe    f0100d78 <debuginfo_eip+0x180>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c41:	c7 c0 b9 5f 10 f0    	mov    $0xf0105fb9,%eax
f0100c47:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100c4d:	0f 86 04 02 00 00    	jbe    f0100e57 <debuginfo_eip+0x25f>
f0100c53:	c7 c0 42 79 10 f0    	mov    $0xf0107942,%eax
f0100c59:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100c5d:	0f 85 fb 01 00 00    	jne    f0100e5e <debuginfo_eip+0x266>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c63:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c6a:	c7 c0 a4 22 10 f0    	mov    $0xf01022a4,%eax
f0100c70:	c7 c2 b8 5f 10 f0    	mov    $0xf0105fb8,%edx
f0100c76:	29 c2                	sub    %eax,%edx
f0100c78:	c1 fa 02             	sar    $0x2,%edx
f0100c7b:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100c81:	83 ea 01             	sub    $0x1,%edx
f0100c84:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100c87:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100c8a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100c8d:	83 ec 08             	sub    $0x8,%esp
f0100c90:	57                   	push   %edi
f0100c91:	6a 64                	push   $0x64
f0100c93:	e8 70 fe ff ff       	call   f0100b08 <stab_binsearch>
	if (lfile == 0)
f0100c98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c9b:	83 c4 10             	add    $0x10,%esp
f0100c9e:	85 c0                	test   %eax,%eax
f0100ca0:	0f 84 bf 01 00 00    	je     f0100e65 <debuginfo_eip+0x26d>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100ca6:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100ca9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cac:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100caf:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100cb2:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100cb5:	83 ec 08             	sub    $0x8,%esp
f0100cb8:	57                   	push   %edi
f0100cb9:	6a 24                	push   $0x24
f0100cbb:	c7 c0 a4 22 10 f0    	mov    $0xf01022a4,%eax
f0100cc1:	e8 42 fe ff ff       	call   f0100b08 <stab_binsearch>

	if (lfun <= rfun) {
f0100cc6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cc9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100ccc:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100ccf:	83 c4 10             	add    $0x10,%esp
f0100cd2:	39 c8                	cmp    %ecx,%eax
f0100cd4:	0f 8f b6 00 00 00    	jg     f0100d90 <debuginfo_eip+0x198>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100cda:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100cdd:	c7 c1 a4 22 10 f0    	mov    $0xf01022a4,%ecx
f0100ce3:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100ce6:	8b 11                	mov    (%ecx),%edx
f0100ce8:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0100ceb:	c7 c2 42 79 10 f0    	mov    $0xf0107942,%edx
f0100cf1:	81 ea b9 5f 10 f0    	sub    $0xf0105fb9,%edx
f0100cf7:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f0100cfa:	73 0c                	jae    f0100d08 <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100cfc:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100cff:	81 c2 b9 5f 10 f0    	add    $0xf0105fb9,%edx
f0100d05:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d08:	8b 51 08             	mov    0x8(%ecx),%edx
f0100d0b:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100d0e:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100d10:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100d13:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100d16:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d19:	83 ec 08             	sub    $0x8,%esp
f0100d1c:	6a 3a                	push   $0x3a
f0100d1e:	ff 76 08             	pushl  0x8(%esi)
f0100d21:	e8 c7 09 00 00       	call   f01016ed <strfind>
f0100d26:	2b 46 08             	sub    0x8(%esi),%eax
f0100d29:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100d2c:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100d2f:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100d32:	83 c4 08             	add    $0x8,%esp
f0100d35:	57                   	push   %edi
f0100d36:	6a 44                	push   $0x44
f0100d38:	c7 c0 a4 22 10 f0    	mov    $0xf01022a4,%eax
f0100d3e:	e8 c5 fd ff ff       	call   f0100b08 <stab_binsearch>
	if (lline <= rline) {
f0100d43:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100d46:	83 c4 10             	add    $0x10,%esp
f0100d49:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100d4c:	0f 8f 1a 01 00 00    	jg     f0100e6c <debuginfo_eip+0x274>
	    info->eip_line = stabs[lline].n_desc;
f0100d52:	89 d0                	mov    %edx,%eax
f0100d54:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100d57:	c1 e2 02             	shl    $0x2,%edx
f0100d5a:	c7 c1 a4 22 10 f0    	mov    $0xf01022a4,%ecx
f0100d60:	0f b7 7c 0a 06       	movzwl 0x6(%edx,%ecx,1),%edi
f0100d65:	89 7e 04             	mov    %edi,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d68:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d6b:	8d 54 0a 04          	lea    0x4(%edx,%ecx,1),%edx
f0100d6f:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0100d73:	89 75 0c             	mov    %esi,0xc(%ebp)
f0100d76:	eb 36                	jmp    f0100dae <debuginfo_eip+0x1b6>
  	        panic("User address");
f0100d78:	83 ec 04             	sub    $0x4,%esp
f0100d7b:	8d 83 8a 0d ff ff    	lea    -0xf276(%ebx),%eax
f0100d81:	50                   	push   %eax
f0100d82:	6a 7f                	push   $0x7f
f0100d84:	8d 83 97 0d ff ff    	lea    -0xf269(%ebx),%eax
f0100d8a:	50                   	push   %eax
f0100d8b:	e8 76 f3 ff ff       	call   f0100106 <_panic>
		info->eip_fn_addr = addr;
f0100d90:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100d93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d96:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100d99:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d9c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d9f:	e9 75 ff ff ff       	jmp    f0100d19 <debuginfo_eip+0x121>
f0100da4:	83 e8 01             	sub    $0x1,%eax
f0100da7:	83 ea 0c             	sub    $0xc,%edx
f0100daa:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0100dae:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0100db1:	39 c7                	cmp    %eax,%edi
f0100db3:	7f 24                	jg     f0100dd9 <debuginfo_eip+0x1e1>
	       && stabs[lline].n_type != N_SOL
f0100db5:	0f b6 0a             	movzbl (%edx),%ecx
f0100db8:	80 f9 84             	cmp    $0x84,%cl
f0100dbb:	74 46                	je     f0100e03 <debuginfo_eip+0x20b>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100dbd:	80 f9 64             	cmp    $0x64,%cl
f0100dc0:	75 e2                	jne    f0100da4 <debuginfo_eip+0x1ac>
f0100dc2:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0100dc6:	74 dc                	je     f0100da4 <debuginfo_eip+0x1ac>
f0100dc8:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100dcb:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100dcf:	74 3b                	je     f0100e0c <debuginfo_eip+0x214>
f0100dd1:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100dd4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100dd7:	eb 33                	jmp    f0100e0c <debuginfo_eip+0x214>
f0100dd9:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100ddc:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ddf:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100de2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100de7:	39 fa                	cmp    %edi,%edx
f0100de9:	0f 8d 89 00 00 00    	jge    f0100e78 <debuginfo_eip+0x280>
		for (lline = lfun + 1;
f0100def:	83 c2 01             	add    $0x1,%edx
f0100df2:	89 d0                	mov    %edx,%eax
f0100df4:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0100df7:	c7 c2 a4 22 10 f0    	mov    $0xf01022a4,%edx
f0100dfd:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100e01:	eb 3b                	jmp    f0100e3e <debuginfo_eip+0x246>
f0100e03:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100e06:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100e0a:	75 26                	jne    f0100e32 <debuginfo_eip+0x23a>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e0c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100e0f:	c7 c0 a4 22 10 f0    	mov    $0xf01022a4,%eax
f0100e15:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100e18:	c7 c0 42 79 10 f0    	mov    $0xf0107942,%eax
f0100e1e:	81 e8 b9 5f 10 f0    	sub    $0xf0105fb9,%eax
f0100e24:	39 c2                	cmp    %eax,%edx
f0100e26:	73 b4                	jae    f0100ddc <debuginfo_eip+0x1e4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e28:	81 c2 b9 5f 10 f0    	add    $0xf0105fb9,%edx
f0100e2e:	89 16                	mov    %edx,(%esi)
f0100e30:	eb aa                	jmp    f0100ddc <debuginfo_eip+0x1e4>
f0100e32:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100e35:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e38:	eb d2                	jmp    f0100e0c <debuginfo_eip+0x214>
			info->eip_fn_narg++;
f0100e3a:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100e3e:	39 c7                	cmp    %eax,%edi
f0100e40:	7e 31                	jle    f0100e73 <debuginfo_eip+0x27b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e42:	0f b6 0a             	movzbl (%edx),%ecx
f0100e45:	83 c0 01             	add    $0x1,%eax
f0100e48:	83 c2 0c             	add    $0xc,%edx
f0100e4b:	80 f9 a0             	cmp    $0xa0,%cl
f0100e4e:	74 ea                	je     f0100e3a <debuginfo_eip+0x242>
	return 0;
f0100e50:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e55:	eb 21                	jmp    f0100e78 <debuginfo_eip+0x280>
		return -1;
f0100e57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e5c:	eb 1a                	jmp    f0100e78 <debuginfo_eip+0x280>
f0100e5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e63:	eb 13                	jmp    f0100e78 <debuginfo_eip+0x280>
		return -1;
f0100e65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e6a:	eb 0c                	jmp    f0100e78 <debuginfo_eip+0x280>
	    return -1;
f0100e6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e71:	eb 05                	jmp    f0100e78 <debuginfo_eip+0x280>
	return 0;
f0100e73:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100e78:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e7b:	5b                   	pop    %ebx
f0100e7c:	5e                   	pop    %esi
f0100e7d:	5f                   	pop    %edi
f0100e7e:	5d                   	pop    %ebp
f0100e7f:	c3                   	ret    

f0100e80 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100e80:	55                   	push   %ebp
f0100e81:	89 e5                	mov    %esp,%ebp
f0100e83:	57                   	push   %edi
f0100e84:	56                   	push   %esi
f0100e85:	53                   	push   %ebx
f0100e86:	83 ec 2c             	sub    $0x2c,%esp
f0100e89:	e8 02 06 00 00       	call   f0101490 <__x86.get_pc_thunk.cx>
f0100e8e:	81 c1 7a 04 01 00    	add    $0x1047a,%ecx
f0100e94:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100e97:	89 c7                	mov    %eax,%edi
f0100e99:	89 d6                	mov    %edx,%esi
f0100e9b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e9e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ea1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100ea4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100ea7:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100eaa:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100eaf:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0100eb2:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0100eb5:	39 d3                	cmp    %edx,%ebx
f0100eb7:	72 09                	jb     f0100ec2 <printnum+0x42>
f0100eb9:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100ebc:	0f 87 83 00 00 00    	ja     f0100f45 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100ec2:	83 ec 0c             	sub    $0xc,%esp
f0100ec5:	ff 75 18             	pushl  0x18(%ebp)
f0100ec8:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ecb:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100ece:	53                   	push   %ebx
f0100ecf:	ff 75 10             	pushl  0x10(%ebp)
f0100ed2:	83 ec 08             	sub    $0x8,%esp
f0100ed5:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ed8:	ff 75 d8             	pushl  -0x28(%ebp)
f0100edb:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100ede:	ff 75 d0             	pushl  -0x30(%ebp)
f0100ee1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100ee4:	e8 27 0a 00 00       	call   f0101910 <__udivdi3>
f0100ee9:	83 c4 18             	add    $0x18,%esp
f0100eec:	52                   	push   %edx
f0100eed:	50                   	push   %eax
f0100eee:	89 f2                	mov    %esi,%edx
f0100ef0:	89 f8                	mov    %edi,%eax
f0100ef2:	e8 89 ff ff ff       	call   f0100e80 <printnum>
f0100ef7:	83 c4 20             	add    $0x20,%esp
f0100efa:	eb 13                	jmp    f0100f0f <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100efc:	83 ec 08             	sub    $0x8,%esp
f0100eff:	56                   	push   %esi
f0100f00:	ff 75 18             	pushl  0x18(%ebp)
f0100f03:	ff d7                	call   *%edi
f0100f05:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100f08:	83 eb 01             	sub    $0x1,%ebx
f0100f0b:	85 db                	test   %ebx,%ebx
f0100f0d:	7f ed                	jg     f0100efc <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100f0f:	83 ec 08             	sub    $0x8,%esp
f0100f12:	56                   	push   %esi
f0100f13:	83 ec 04             	sub    $0x4,%esp
f0100f16:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f19:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f1c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f1f:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f22:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100f25:	89 f3                	mov    %esi,%ebx
f0100f27:	e8 04 0b 00 00       	call   f0101a30 <__umoddi3>
f0100f2c:	83 c4 14             	add    $0x14,%esp
f0100f2f:	0f be 84 06 a5 0d ff 	movsbl -0xf25b(%esi,%eax,1),%eax
f0100f36:	ff 
f0100f37:	50                   	push   %eax
f0100f38:	ff d7                	call   *%edi
}
f0100f3a:	83 c4 10             	add    $0x10,%esp
f0100f3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f40:	5b                   	pop    %ebx
f0100f41:	5e                   	pop    %esi
f0100f42:	5f                   	pop    %edi
f0100f43:	5d                   	pop    %ebp
f0100f44:	c3                   	ret    
f0100f45:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100f48:	eb be                	jmp    f0100f08 <printnum+0x88>

f0100f4a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f4a:	55                   	push   %ebp
f0100f4b:	89 e5                	mov    %esp,%ebp
f0100f4d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f50:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100f54:	8b 10                	mov    (%eax),%edx
f0100f56:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f59:	73 0a                	jae    f0100f65 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100f5b:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100f5e:	89 08                	mov    %ecx,(%eax)
f0100f60:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f63:	88 02                	mov    %al,(%edx)
}
f0100f65:	5d                   	pop    %ebp
f0100f66:	c3                   	ret    

f0100f67 <printfmt>:
{
f0100f67:	55                   	push   %ebp
f0100f68:	89 e5                	mov    %esp,%ebp
f0100f6a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100f6d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f70:	50                   	push   %eax
f0100f71:	ff 75 10             	pushl  0x10(%ebp)
f0100f74:	ff 75 0c             	pushl  0xc(%ebp)
f0100f77:	ff 75 08             	pushl  0x8(%ebp)
f0100f7a:	e8 05 00 00 00       	call   f0100f84 <vprintfmt>
}
f0100f7f:	83 c4 10             	add    $0x10,%esp
f0100f82:	c9                   	leave  
f0100f83:	c3                   	ret    

f0100f84 <vprintfmt>:
{
f0100f84:	55                   	push   %ebp
f0100f85:	89 e5                	mov    %esp,%ebp
f0100f87:	57                   	push   %edi
f0100f88:	56                   	push   %esi
f0100f89:	53                   	push   %ebx
f0100f8a:	83 ec 2c             	sub    $0x2c,%esp
f0100f8d:	e8 2a f2 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100f92:	81 c3 76 03 01 00    	add    $0x10376,%ebx
f0100f98:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100f9b:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100f9e:	e9 c3 03 00 00       	jmp    f0101366 <.L35+0x48>
		padc = ' ';
f0100fa3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100fa7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100fae:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0100fb5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100fbc:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100fc1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100fc4:	8d 47 01             	lea    0x1(%edi),%eax
f0100fc7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100fca:	0f b6 17             	movzbl (%edi),%edx
f0100fcd:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100fd0:	3c 55                	cmp    $0x55,%al
f0100fd2:	0f 87 16 04 00 00    	ja     f01013ee <.L22>
f0100fd8:	0f b6 c0             	movzbl %al,%eax
f0100fdb:	89 d9                	mov    %ebx,%ecx
f0100fdd:	03 8c 83 34 0e ff ff 	add    -0xf1cc(%ebx,%eax,4),%ecx
f0100fe4:	ff e1                	jmp    *%ecx

f0100fe6 <.L69>:
f0100fe6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0100fe9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100fed:	eb d5                	jmp    f0100fc4 <vprintfmt+0x40>

f0100fef <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f0100fef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0100ff2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100ff6:	eb cc                	jmp    f0100fc4 <vprintfmt+0x40>

f0100ff8 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f0100ff8:	0f b6 d2             	movzbl %dl,%edx
f0100ffb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0100ffe:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f0101003:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101006:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010100a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010100d:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0101010:	83 f9 09             	cmp    $0x9,%ecx
f0101013:	77 55                	ja     f010106a <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f0101015:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0101018:	eb e9                	jmp    f0101003 <.L29+0xb>

f010101a <.L26>:
			precision = va_arg(ap, int);
f010101a:	8b 45 14             	mov    0x14(%ebp),%eax
f010101d:	8b 00                	mov    (%eax),%eax
f010101f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101022:	8b 45 14             	mov    0x14(%ebp),%eax
f0101025:	8d 40 04             	lea    0x4(%eax),%eax
f0101028:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010102b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f010102e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101032:	79 90                	jns    f0100fc4 <vprintfmt+0x40>
				width = precision, precision = -1;
f0101034:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101037:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010103a:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0101041:	eb 81                	jmp    f0100fc4 <vprintfmt+0x40>

f0101043 <.L27>:
f0101043:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101046:	85 c0                	test   %eax,%eax
f0101048:	ba 00 00 00 00       	mov    $0x0,%edx
f010104d:	0f 49 d0             	cmovns %eax,%edx
f0101050:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101053:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101056:	e9 69 ff ff ff       	jmp    f0100fc4 <vprintfmt+0x40>

f010105b <.L23>:
f010105b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f010105e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0101065:	e9 5a ff ff ff       	jmp    f0100fc4 <vprintfmt+0x40>
f010106a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010106d:	eb bf                	jmp    f010102e <.L26+0x14>

f010106f <.L33>:
			lflag++;
f010106f:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101073:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0101076:	e9 49 ff ff ff       	jmp    f0100fc4 <vprintfmt+0x40>

f010107b <.L30>:
			putch(va_arg(ap, int), putdat);
f010107b:	8b 45 14             	mov    0x14(%ebp),%eax
f010107e:	8d 78 04             	lea    0x4(%eax),%edi
f0101081:	83 ec 08             	sub    $0x8,%esp
f0101084:	56                   	push   %esi
f0101085:	ff 30                	pushl  (%eax)
f0101087:	ff 55 08             	call   *0x8(%ebp)
			break;
f010108a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f010108d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0101090:	e9 ce 02 00 00       	jmp    f0101363 <.L35+0x45>

f0101095 <.L32>:
			err = va_arg(ap, int);
f0101095:	8b 45 14             	mov    0x14(%ebp),%eax
f0101098:	8d 78 04             	lea    0x4(%eax),%edi
f010109b:	8b 00                	mov    (%eax),%eax
f010109d:	99                   	cltd   
f010109e:	31 d0                	xor    %edx,%eax
f01010a0:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01010a2:	83 f8 06             	cmp    $0x6,%eax
f01010a5:	7f 27                	jg     f01010ce <.L32+0x39>
f01010a7:	8b 94 83 3c 1d 00 00 	mov    0x1d3c(%ebx,%eax,4),%edx
f01010ae:	85 d2                	test   %edx,%edx
f01010b0:	74 1c                	je     f01010ce <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f01010b2:	52                   	push   %edx
f01010b3:	8d 83 c6 0d ff ff    	lea    -0xf23a(%ebx),%eax
f01010b9:	50                   	push   %eax
f01010ba:	56                   	push   %esi
f01010bb:	ff 75 08             	pushl  0x8(%ebp)
f01010be:	e8 a4 fe ff ff       	call   f0100f67 <printfmt>
f01010c3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010c6:	89 7d 14             	mov    %edi,0x14(%ebp)
f01010c9:	e9 95 02 00 00       	jmp    f0101363 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f01010ce:	50                   	push   %eax
f01010cf:	8d 83 bd 0d ff ff    	lea    -0xf243(%ebx),%eax
f01010d5:	50                   	push   %eax
f01010d6:	56                   	push   %esi
f01010d7:	ff 75 08             	pushl  0x8(%ebp)
f01010da:	e8 88 fe ff ff       	call   f0100f67 <printfmt>
f01010df:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010e2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01010e5:	e9 79 02 00 00       	jmp    f0101363 <.L35+0x45>

f01010ea <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f01010ea:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ed:	83 c0 04             	add    $0x4,%eax
f01010f0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01010f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01010f8:	85 ff                	test   %edi,%edi
f01010fa:	8d 83 b6 0d ff ff    	lea    -0xf24a(%ebx),%eax
f0101100:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0101103:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101107:	0f 8e b5 00 00 00    	jle    f01011c2 <.L36+0xd8>
f010110d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0101111:	75 08                	jne    f010111b <.L36+0x31>
f0101113:	89 75 0c             	mov    %esi,0xc(%ebp)
f0101116:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101119:	eb 6d                	jmp    f0101188 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f010111b:	83 ec 08             	sub    $0x8,%esp
f010111e:	ff 75 cc             	pushl  -0x34(%ebp)
f0101121:	57                   	push   %edi
f0101122:	e8 82 04 00 00       	call   f01015a9 <strnlen>
f0101127:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010112a:	29 c2                	sub    %eax,%edx
f010112c:	89 55 c8             	mov    %edx,-0x38(%ebp)
f010112f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0101132:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101136:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101139:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010113c:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f010113e:	eb 10                	jmp    f0101150 <.L36+0x66>
					putch(padc, putdat);
f0101140:	83 ec 08             	sub    $0x8,%esp
f0101143:	56                   	push   %esi
f0101144:	ff 75 e0             	pushl  -0x20(%ebp)
f0101147:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f010114a:	83 ef 01             	sub    $0x1,%edi
f010114d:	83 c4 10             	add    $0x10,%esp
f0101150:	85 ff                	test   %edi,%edi
f0101152:	7f ec                	jg     f0101140 <.L36+0x56>
f0101154:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101157:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010115a:	85 d2                	test   %edx,%edx
f010115c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101161:	0f 49 c2             	cmovns %edx,%eax
f0101164:	29 c2                	sub    %eax,%edx
f0101166:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101169:	89 75 0c             	mov    %esi,0xc(%ebp)
f010116c:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010116f:	eb 17                	jmp    f0101188 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f0101171:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101175:	75 30                	jne    f01011a7 <.L36+0xbd>
					putch(ch, putdat);
f0101177:	83 ec 08             	sub    $0x8,%esp
f010117a:	ff 75 0c             	pushl  0xc(%ebp)
f010117d:	50                   	push   %eax
f010117e:	ff 55 08             	call   *0x8(%ebp)
f0101181:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101184:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f0101188:	83 c7 01             	add    $0x1,%edi
f010118b:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f010118f:	0f be c2             	movsbl %dl,%eax
f0101192:	85 c0                	test   %eax,%eax
f0101194:	74 52                	je     f01011e8 <.L36+0xfe>
f0101196:	85 f6                	test   %esi,%esi
f0101198:	78 d7                	js     f0101171 <.L36+0x87>
f010119a:	83 ee 01             	sub    $0x1,%esi
f010119d:	79 d2                	jns    f0101171 <.L36+0x87>
f010119f:	8b 75 0c             	mov    0xc(%ebp),%esi
f01011a2:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01011a5:	eb 32                	jmp    f01011d9 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f01011a7:	0f be d2             	movsbl %dl,%edx
f01011aa:	83 ea 20             	sub    $0x20,%edx
f01011ad:	83 fa 5e             	cmp    $0x5e,%edx
f01011b0:	76 c5                	jbe    f0101177 <.L36+0x8d>
					putch('?', putdat);
f01011b2:	83 ec 08             	sub    $0x8,%esp
f01011b5:	ff 75 0c             	pushl  0xc(%ebp)
f01011b8:	6a 3f                	push   $0x3f
f01011ba:	ff 55 08             	call   *0x8(%ebp)
f01011bd:	83 c4 10             	add    $0x10,%esp
f01011c0:	eb c2                	jmp    f0101184 <.L36+0x9a>
f01011c2:	89 75 0c             	mov    %esi,0xc(%ebp)
f01011c5:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01011c8:	eb be                	jmp    f0101188 <.L36+0x9e>
				putch(' ', putdat);
f01011ca:	83 ec 08             	sub    $0x8,%esp
f01011cd:	56                   	push   %esi
f01011ce:	6a 20                	push   $0x20
f01011d0:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f01011d3:	83 ef 01             	sub    $0x1,%edi
f01011d6:	83 c4 10             	add    $0x10,%esp
f01011d9:	85 ff                	test   %edi,%edi
f01011db:	7f ed                	jg     f01011ca <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f01011dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01011e0:	89 45 14             	mov    %eax,0x14(%ebp)
f01011e3:	e9 7b 01 00 00       	jmp    f0101363 <.L35+0x45>
f01011e8:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01011eb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01011ee:	eb e9                	jmp    f01011d9 <.L36+0xef>

f01011f0 <.L31>:
f01011f0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01011f3:	83 f9 01             	cmp    $0x1,%ecx
f01011f6:	7e 40                	jle    f0101238 <.L31+0x48>
		return va_arg(*ap, long long);
f01011f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01011fb:	8b 50 04             	mov    0x4(%eax),%edx
f01011fe:	8b 00                	mov    (%eax),%eax
f0101200:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101203:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101206:	8b 45 14             	mov    0x14(%ebp),%eax
f0101209:	8d 40 08             	lea    0x8(%eax),%eax
f010120c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f010120f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101213:	79 55                	jns    f010126a <.L31+0x7a>
				putch('-', putdat);
f0101215:	83 ec 08             	sub    $0x8,%esp
f0101218:	56                   	push   %esi
f0101219:	6a 2d                	push   $0x2d
f010121b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010121e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101221:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101224:	f7 da                	neg    %edx
f0101226:	83 d1 00             	adc    $0x0,%ecx
f0101229:	f7 d9                	neg    %ecx
f010122b:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010122e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101233:	e9 10 01 00 00       	jmp    f0101348 <.L35+0x2a>
	else if (lflag)
f0101238:	85 c9                	test   %ecx,%ecx
f010123a:	75 17                	jne    f0101253 <.L31+0x63>
		return va_arg(*ap, int);
f010123c:	8b 45 14             	mov    0x14(%ebp),%eax
f010123f:	8b 00                	mov    (%eax),%eax
f0101241:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101244:	99                   	cltd   
f0101245:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101248:	8b 45 14             	mov    0x14(%ebp),%eax
f010124b:	8d 40 04             	lea    0x4(%eax),%eax
f010124e:	89 45 14             	mov    %eax,0x14(%ebp)
f0101251:	eb bc                	jmp    f010120f <.L31+0x1f>
		return va_arg(*ap, long);
f0101253:	8b 45 14             	mov    0x14(%ebp),%eax
f0101256:	8b 00                	mov    (%eax),%eax
f0101258:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010125b:	99                   	cltd   
f010125c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010125f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101262:	8d 40 04             	lea    0x4(%eax),%eax
f0101265:	89 45 14             	mov    %eax,0x14(%ebp)
f0101268:	eb a5                	jmp    f010120f <.L31+0x1f>
			num = getint(&ap, lflag);
f010126a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010126d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0101270:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101275:	e9 ce 00 00 00       	jmp    f0101348 <.L35+0x2a>

f010127a <.L37>:
f010127a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f010127d:	83 f9 01             	cmp    $0x1,%ecx
f0101280:	7e 18                	jle    f010129a <.L37+0x20>
		return va_arg(*ap, unsigned long long);
f0101282:	8b 45 14             	mov    0x14(%ebp),%eax
f0101285:	8b 10                	mov    (%eax),%edx
f0101287:	8b 48 04             	mov    0x4(%eax),%ecx
f010128a:	8d 40 08             	lea    0x8(%eax),%eax
f010128d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101290:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101295:	e9 ae 00 00 00       	jmp    f0101348 <.L35+0x2a>
	else if (lflag)
f010129a:	85 c9                	test   %ecx,%ecx
f010129c:	75 1a                	jne    f01012b8 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
f010129e:	8b 45 14             	mov    0x14(%ebp),%eax
f01012a1:	8b 10                	mov    (%eax),%edx
f01012a3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012a8:	8d 40 04             	lea    0x4(%eax),%eax
f01012ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012ae:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012b3:	e9 90 00 00 00       	jmp    f0101348 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f01012b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01012bb:	8b 10                	mov    (%eax),%edx
f01012bd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012c2:	8d 40 04             	lea    0x4(%eax),%eax
f01012c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012c8:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012cd:	eb 79                	jmp    f0101348 <.L35+0x2a>

f01012cf <.L34>:
f01012cf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01012d2:	83 f9 01             	cmp    $0x1,%ecx
f01012d5:	7e 15                	jle    f01012ec <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
f01012d7:	8b 45 14             	mov    0x14(%ebp),%eax
f01012da:	8b 10                	mov    (%eax),%edx
f01012dc:	8b 48 04             	mov    0x4(%eax),%ecx
f01012df:	8d 40 08             	lea    0x8(%eax),%eax
f01012e2:	89 45 14             	mov    %eax,0x14(%ebp)
            base = 8;
f01012e5:	b8 08 00 00 00       	mov    $0x8,%eax
f01012ea:	eb 5c                	jmp    f0101348 <.L35+0x2a>
	else if (lflag)
f01012ec:	85 c9                	test   %ecx,%ecx
f01012ee:	75 17                	jne    f0101307 <.L34+0x38>
		return va_arg(*ap, unsigned int);
f01012f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01012f3:	8b 10                	mov    (%eax),%edx
f01012f5:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012fa:	8d 40 04             	lea    0x4(%eax),%eax
f01012fd:	89 45 14             	mov    %eax,0x14(%ebp)
            base = 8;
f0101300:	b8 08 00 00 00       	mov    $0x8,%eax
f0101305:	eb 41                	jmp    f0101348 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0101307:	8b 45 14             	mov    0x14(%ebp),%eax
f010130a:	8b 10                	mov    (%eax),%edx
f010130c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101311:	8d 40 04             	lea    0x4(%eax),%eax
f0101314:	89 45 14             	mov    %eax,0x14(%ebp)
            base = 8;
f0101317:	b8 08 00 00 00       	mov    $0x8,%eax
f010131c:	eb 2a                	jmp    f0101348 <.L35+0x2a>

f010131e <.L35>:
			putch('0', putdat);
f010131e:	83 ec 08             	sub    $0x8,%esp
f0101321:	56                   	push   %esi
f0101322:	6a 30                	push   $0x30
f0101324:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101327:	83 c4 08             	add    $0x8,%esp
f010132a:	56                   	push   %esi
f010132b:	6a 78                	push   $0x78
f010132d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0101330:	8b 45 14             	mov    0x14(%ebp),%eax
f0101333:	8b 10                	mov    (%eax),%edx
f0101335:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010133a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010133d:	8d 40 04             	lea    0x4(%eax),%eax
f0101340:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101343:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0101348:	83 ec 0c             	sub    $0xc,%esp
f010134b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010134f:	57                   	push   %edi
f0101350:	ff 75 e0             	pushl  -0x20(%ebp)
f0101353:	50                   	push   %eax
f0101354:	51                   	push   %ecx
f0101355:	52                   	push   %edx
f0101356:	89 f2                	mov    %esi,%edx
f0101358:	8b 45 08             	mov    0x8(%ebp),%eax
f010135b:	e8 20 fb ff ff       	call   f0100e80 <printnum>
			break;
f0101360:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0101363:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101366:	83 c7 01             	add    $0x1,%edi
f0101369:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010136d:	83 f8 25             	cmp    $0x25,%eax
f0101370:	0f 84 2d fc ff ff    	je     f0100fa3 <vprintfmt+0x1f>
			if (ch == '\0')
f0101376:	85 c0                	test   %eax,%eax
f0101378:	0f 84 91 00 00 00    	je     f010140f <.L22+0x21>
			putch(ch, putdat);
f010137e:	83 ec 08             	sub    $0x8,%esp
f0101381:	56                   	push   %esi
f0101382:	50                   	push   %eax
f0101383:	ff 55 08             	call   *0x8(%ebp)
f0101386:	83 c4 10             	add    $0x10,%esp
f0101389:	eb db                	jmp    f0101366 <.L35+0x48>

f010138b <.L38>:
f010138b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f010138e:	83 f9 01             	cmp    $0x1,%ecx
f0101391:	7e 15                	jle    f01013a8 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f0101393:	8b 45 14             	mov    0x14(%ebp),%eax
f0101396:	8b 10                	mov    (%eax),%edx
f0101398:	8b 48 04             	mov    0x4(%eax),%ecx
f010139b:	8d 40 08             	lea    0x8(%eax),%eax
f010139e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013a1:	b8 10 00 00 00       	mov    $0x10,%eax
f01013a6:	eb a0                	jmp    f0101348 <.L35+0x2a>
	else if (lflag)
f01013a8:	85 c9                	test   %ecx,%ecx
f01013aa:	75 17                	jne    f01013c3 <.L38+0x38>
		return va_arg(*ap, unsigned int);
f01013ac:	8b 45 14             	mov    0x14(%ebp),%eax
f01013af:	8b 10                	mov    (%eax),%edx
f01013b1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013b6:	8d 40 04             	lea    0x4(%eax),%eax
f01013b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013bc:	b8 10 00 00 00       	mov    $0x10,%eax
f01013c1:	eb 85                	jmp    f0101348 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f01013c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01013c6:	8b 10                	mov    (%eax),%edx
f01013c8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013cd:	8d 40 04             	lea    0x4(%eax),%eax
f01013d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013d3:	b8 10 00 00 00       	mov    $0x10,%eax
f01013d8:	e9 6b ff ff ff       	jmp    f0101348 <.L35+0x2a>

f01013dd <.L25>:
			putch(ch, putdat);
f01013dd:	83 ec 08             	sub    $0x8,%esp
f01013e0:	56                   	push   %esi
f01013e1:	6a 25                	push   $0x25
f01013e3:	ff 55 08             	call   *0x8(%ebp)
			break;
f01013e6:	83 c4 10             	add    $0x10,%esp
f01013e9:	e9 75 ff ff ff       	jmp    f0101363 <.L35+0x45>

f01013ee <.L22>:
			putch('%', putdat);
f01013ee:	83 ec 08             	sub    $0x8,%esp
f01013f1:	56                   	push   %esi
f01013f2:	6a 25                	push   $0x25
f01013f4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01013f7:	83 c4 10             	add    $0x10,%esp
f01013fa:	89 f8                	mov    %edi,%eax
f01013fc:	eb 03                	jmp    f0101401 <.L22+0x13>
f01013fe:	83 e8 01             	sub    $0x1,%eax
f0101401:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0101405:	75 f7                	jne    f01013fe <.L22+0x10>
f0101407:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010140a:	e9 54 ff ff ff       	jmp    f0101363 <.L35+0x45>
}
f010140f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101412:	5b                   	pop    %ebx
f0101413:	5e                   	pop    %esi
f0101414:	5f                   	pop    %edi
f0101415:	5d                   	pop    %ebp
f0101416:	c3                   	ret    

f0101417 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101417:	55                   	push   %ebp
f0101418:	89 e5                	mov    %esp,%ebp
f010141a:	53                   	push   %ebx
f010141b:	83 ec 14             	sub    $0x14,%esp
f010141e:	e8 99 ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0101423:	81 c3 e5 fe 00 00    	add    $0xfee5,%ebx
f0101429:	8b 45 08             	mov    0x8(%ebp),%eax
f010142c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010142f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101432:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101436:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101439:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101440:	85 c0                	test   %eax,%eax
f0101442:	74 2b                	je     f010146f <vsnprintf+0x58>
f0101444:	85 d2                	test   %edx,%edx
f0101446:	7e 27                	jle    f010146f <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101448:	ff 75 14             	pushl  0x14(%ebp)
f010144b:	ff 75 10             	pushl  0x10(%ebp)
f010144e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101451:	50                   	push   %eax
f0101452:	8d 83 42 fc fe ff    	lea    -0x103be(%ebx),%eax
f0101458:	50                   	push   %eax
f0101459:	e8 26 fb ff ff       	call   f0100f84 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010145e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101461:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101464:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101467:	83 c4 10             	add    $0x10,%esp
}
f010146a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010146d:	c9                   	leave  
f010146e:	c3                   	ret    
		return -E_INVAL;
f010146f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101474:	eb f4                	jmp    f010146a <vsnprintf+0x53>

f0101476 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101476:	55                   	push   %ebp
f0101477:	89 e5                	mov    %esp,%ebp
f0101479:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010147c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010147f:	50                   	push   %eax
f0101480:	ff 75 10             	pushl  0x10(%ebp)
f0101483:	ff 75 0c             	pushl  0xc(%ebp)
f0101486:	ff 75 08             	pushl  0x8(%ebp)
f0101489:	e8 89 ff ff ff       	call   f0101417 <vsnprintf>
	va_end(ap);

	return rc;
}
f010148e:	c9                   	leave  
f010148f:	c3                   	ret    

f0101490 <__x86.get_pc_thunk.cx>:
f0101490:	8b 0c 24             	mov    (%esp),%ecx
f0101493:	c3                   	ret    

f0101494 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101494:	55                   	push   %ebp
f0101495:	89 e5                	mov    %esp,%ebp
f0101497:	57                   	push   %edi
f0101498:	56                   	push   %esi
f0101499:	53                   	push   %ebx
f010149a:	83 ec 1c             	sub    $0x1c,%esp
f010149d:	e8 1a ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01014a2:	81 c3 66 fe 00 00    	add    $0xfe66,%ebx
f01014a8:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01014ab:	85 c0                	test   %eax,%eax
f01014ad:	74 13                	je     f01014c2 <readline+0x2e>
		cprintf("%s", prompt);
f01014af:	83 ec 08             	sub    $0x8,%esp
f01014b2:	50                   	push   %eax
f01014b3:	8d 83 c6 0d ff ff    	lea    -0xf23a(%ebx),%eax
f01014b9:	50                   	push   %eax
f01014ba:	e8 35 f6 ff ff       	call   f0100af4 <cprintf>
f01014bf:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01014c2:	83 ec 0c             	sub    $0xc,%esp
f01014c5:	6a 00                	push   $0x0
f01014c7:	e8 88 f2 ff ff       	call   f0100754 <iscons>
f01014cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01014cf:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01014d2:	bf 00 00 00 00       	mov    $0x0,%edi
f01014d7:	eb 46                	jmp    f010151f <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01014d9:	83 ec 08             	sub    $0x8,%esp
f01014dc:	50                   	push   %eax
f01014dd:	8d 83 8c 0f ff ff    	lea    -0xf074(%ebx),%eax
f01014e3:	50                   	push   %eax
f01014e4:	e8 0b f6 ff ff       	call   f0100af4 <cprintf>
			return NULL;
f01014e9:	83 c4 10             	add    $0x10,%esp
f01014ec:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01014f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014f4:	5b                   	pop    %ebx
f01014f5:	5e                   	pop    %esi
f01014f6:	5f                   	pop    %edi
f01014f7:	5d                   	pop    %ebp
f01014f8:	c3                   	ret    
			if (echoing)
f01014f9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01014fd:	75 05                	jne    f0101504 <readline+0x70>
			i--;
f01014ff:	83 ef 01             	sub    $0x1,%edi
f0101502:	eb 1b                	jmp    f010151f <readline+0x8b>
				cputchar('\b');
f0101504:	83 ec 0c             	sub    $0xc,%esp
f0101507:	6a 08                	push   $0x8
f0101509:	e8 25 f2 ff ff       	call   f0100733 <cputchar>
f010150e:	83 c4 10             	add    $0x10,%esp
f0101511:	eb ec                	jmp    f01014ff <readline+0x6b>
			buf[i++] = c;
f0101513:	89 f0                	mov    %esi,%eax
f0101515:	88 84 3b 98 1f 00 00 	mov    %al,0x1f98(%ebx,%edi,1)
f010151c:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f010151f:	e8 1f f2 ff ff       	call   f0100743 <getchar>
f0101524:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0101526:	85 c0                	test   %eax,%eax
f0101528:	78 af                	js     f01014d9 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010152a:	83 f8 08             	cmp    $0x8,%eax
f010152d:	0f 94 c2             	sete   %dl
f0101530:	83 f8 7f             	cmp    $0x7f,%eax
f0101533:	0f 94 c0             	sete   %al
f0101536:	08 c2                	or     %al,%dl
f0101538:	74 04                	je     f010153e <readline+0xaa>
f010153a:	85 ff                	test   %edi,%edi
f010153c:	7f bb                	jg     f01014f9 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010153e:	83 fe 1f             	cmp    $0x1f,%esi
f0101541:	7e 1c                	jle    f010155f <readline+0xcb>
f0101543:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101549:	7f 14                	jg     f010155f <readline+0xcb>
			if (echoing)
f010154b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010154f:	74 c2                	je     f0101513 <readline+0x7f>
				cputchar(c);
f0101551:	83 ec 0c             	sub    $0xc,%esp
f0101554:	56                   	push   %esi
f0101555:	e8 d9 f1 ff ff       	call   f0100733 <cputchar>
f010155a:	83 c4 10             	add    $0x10,%esp
f010155d:	eb b4                	jmp    f0101513 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f010155f:	83 fe 0a             	cmp    $0xa,%esi
f0101562:	74 05                	je     f0101569 <readline+0xd5>
f0101564:	83 fe 0d             	cmp    $0xd,%esi
f0101567:	75 b6                	jne    f010151f <readline+0x8b>
			if (echoing)
f0101569:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010156d:	75 13                	jne    f0101582 <readline+0xee>
			buf[i] = 0;
f010156f:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f0101576:	00 
			return buf;
f0101577:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f010157d:	e9 6f ff ff ff       	jmp    f01014f1 <readline+0x5d>
				cputchar('\n');
f0101582:	83 ec 0c             	sub    $0xc,%esp
f0101585:	6a 0a                	push   $0xa
f0101587:	e8 a7 f1 ff ff       	call   f0100733 <cputchar>
f010158c:	83 c4 10             	add    $0x10,%esp
f010158f:	eb de                	jmp    f010156f <readline+0xdb>

f0101591 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101591:	55                   	push   %ebp
f0101592:	89 e5                	mov    %esp,%ebp
f0101594:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101597:	b8 00 00 00 00       	mov    $0x0,%eax
f010159c:	eb 03                	jmp    f01015a1 <strlen+0x10>
		n++;
f010159e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01015a1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01015a5:	75 f7                	jne    f010159e <strlen+0xd>
	return n;
}
f01015a7:	5d                   	pop    %ebp
f01015a8:	c3                   	ret    

f01015a9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01015a9:	55                   	push   %ebp
f01015aa:	89 e5                	mov    %esp,%ebp
f01015ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015af:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01015b7:	eb 03                	jmp    f01015bc <strnlen+0x13>
		n++;
f01015b9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015bc:	39 d0                	cmp    %edx,%eax
f01015be:	74 06                	je     f01015c6 <strnlen+0x1d>
f01015c0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01015c4:	75 f3                	jne    f01015b9 <strnlen+0x10>
	return n;
}
f01015c6:	5d                   	pop    %ebp
f01015c7:	c3                   	ret    

f01015c8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01015c8:	55                   	push   %ebp
f01015c9:	89 e5                	mov    %esp,%ebp
f01015cb:	53                   	push   %ebx
f01015cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01015cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01015d2:	89 c2                	mov    %eax,%edx
f01015d4:	83 c1 01             	add    $0x1,%ecx
f01015d7:	83 c2 01             	add    $0x1,%edx
f01015da:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01015de:	88 5a ff             	mov    %bl,-0x1(%edx)
f01015e1:	84 db                	test   %bl,%bl
f01015e3:	75 ef                	jne    f01015d4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01015e5:	5b                   	pop    %ebx
f01015e6:	5d                   	pop    %ebp
f01015e7:	c3                   	ret    

f01015e8 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01015e8:	55                   	push   %ebp
f01015e9:	89 e5                	mov    %esp,%ebp
f01015eb:	53                   	push   %ebx
f01015ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01015ef:	53                   	push   %ebx
f01015f0:	e8 9c ff ff ff       	call   f0101591 <strlen>
f01015f5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01015f8:	ff 75 0c             	pushl  0xc(%ebp)
f01015fb:	01 d8                	add    %ebx,%eax
f01015fd:	50                   	push   %eax
f01015fe:	e8 c5 ff ff ff       	call   f01015c8 <strcpy>
	return dst;
}
f0101603:	89 d8                	mov    %ebx,%eax
f0101605:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101608:	c9                   	leave  
f0101609:	c3                   	ret    

f010160a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010160a:	55                   	push   %ebp
f010160b:	89 e5                	mov    %esp,%ebp
f010160d:	56                   	push   %esi
f010160e:	53                   	push   %ebx
f010160f:	8b 75 08             	mov    0x8(%ebp),%esi
f0101612:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101615:	89 f3                	mov    %esi,%ebx
f0101617:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010161a:	89 f2                	mov    %esi,%edx
f010161c:	eb 0f                	jmp    f010162d <strncpy+0x23>
		*dst++ = *src;
f010161e:	83 c2 01             	add    $0x1,%edx
f0101621:	0f b6 01             	movzbl (%ecx),%eax
f0101624:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101627:	80 39 01             	cmpb   $0x1,(%ecx)
f010162a:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f010162d:	39 da                	cmp    %ebx,%edx
f010162f:	75 ed                	jne    f010161e <strncpy+0x14>
	}
	return ret;
}
f0101631:	89 f0                	mov    %esi,%eax
f0101633:	5b                   	pop    %ebx
f0101634:	5e                   	pop    %esi
f0101635:	5d                   	pop    %ebp
f0101636:	c3                   	ret    

f0101637 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101637:	55                   	push   %ebp
f0101638:	89 e5                	mov    %esp,%ebp
f010163a:	56                   	push   %esi
f010163b:	53                   	push   %ebx
f010163c:	8b 75 08             	mov    0x8(%ebp),%esi
f010163f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101642:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101645:	89 f0                	mov    %esi,%eax
f0101647:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010164b:	85 c9                	test   %ecx,%ecx
f010164d:	75 0b                	jne    f010165a <strlcpy+0x23>
f010164f:	eb 17                	jmp    f0101668 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101651:	83 c2 01             	add    $0x1,%edx
f0101654:	83 c0 01             	add    $0x1,%eax
f0101657:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f010165a:	39 d8                	cmp    %ebx,%eax
f010165c:	74 07                	je     f0101665 <strlcpy+0x2e>
f010165e:	0f b6 0a             	movzbl (%edx),%ecx
f0101661:	84 c9                	test   %cl,%cl
f0101663:	75 ec                	jne    f0101651 <strlcpy+0x1a>
		*dst = '\0';
f0101665:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101668:	29 f0                	sub    %esi,%eax
}
f010166a:	5b                   	pop    %ebx
f010166b:	5e                   	pop    %esi
f010166c:	5d                   	pop    %ebp
f010166d:	c3                   	ret    

f010166e <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010166e:	55                   	push   %ebp
f010166f:	89 e5                	mov    %esp,%ebp
f0101671:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101674:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101677:	eb 06                	jmp    f010167f <strcmp+0x11>
		p++, q++;
f0101679:	83 c1 01             	add    $0x1,%ecx
f010167c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f010167f:	0f b6 01             	movzbl (%ecx),%eax
f0101682:	84 c0                	test   %al,%al
f0101684:	74 04                	je     f010168a <strcmp+0x1c>
f0101686:	3a 02                	cmp    (%edx),%al
f0101688:	74 ef                	je     f0101679 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010168a:	0f b6 c0             	movzbl %al,%eax
f010168d:	0f b6 12             	movzbl (%edx),%edx
f0101690:	29 d0                	sub    %edx,%eax
}
f0101692:	5d                   	pop    %ebp
f0101693:	c3                   	ret    

f0101694 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101694:	55                   	push   %ebp
f0101695:	89 e5                	mov    %esp,%ebp
f0101697:	53                   	push   %ebx
f0101698:	8b 45 08             	mov    0x8(%ebp),%eax
f010169b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010169e:	89 c3                	mov    %eax,%ebx
f01016a0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01016a3:	eb 06                	jmp    f01016ab <strncmp+0x17>
		n--, p++, q++;
f01016a5:	83 c0 01             	add    $0x1,%eax
f01016a8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01016ab:	39 d8                	cmp    %ebx,%eax
f01016ad:	74 16                	je     f01016c5 <strncmp+0x31>
f01016af:	0f b6 08             	movzbl (%eax),%ecx
f01016b2:	84 c9                	test   %cl,%cl
f01016b4:	74 04                	je     f01016ba <strncmp+0x26>
f01016b6:	3a 0a                	cmp    (%edx),%cl
f01016b8:	74 eb                	je     f01016a5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01016ba:	0f b6 00             	movzbl (%eax),%eax
f01016bd:	0f b6 12             	movzbl (%edx),%edx
f01016c0:	29 d0                	sub    %edx,%eax
}
f01016c2:	5b                   	pop    %ebx
f01016c3:	5d                   	pop    %ebp
f01016c4:	c3                   	ret    
		return 0;
f01016c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01016ca:	eb f6                	jmp    f01016c2 <strncmp+0x2e>

f01016cc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01016cc:	55                   	push   %ebp
f01016cd:	89 e5                	mov    %esp,%ebp
f01016cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01016d2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01016d6:	0f b6 10             	movzbl (%eax),%edx
f01016d9:	84 d2                	test   %dl,%dl
f01016db:	74 09                	je     f01016e6 <strchr+0x1a>
		if (*s == c)
f01016dd:	38 ca                	cmp    %cl,%dl
f01016df:	74 0a                	je     f01016eb <strchr+0x1f>
	for (; *s; s++)
f01016e1:	83 c0 01             	add    $0x1,%eax
f01016e4:	eb f0                	jmp    f01016d6 <strchr+0xa>
			return (char *) s;
	return 0;
f01016e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01016eb:	5d                   	pop    %ebp
f01016ec:	c3                   	ret    

f01016ed <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01016ed:	55                   	push   %ebp
f01016ee:	89 e5                	mov    %esp,%ebp
f01016f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01016f3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01016f7:	eb 03                	jmp    f01016fc <strfind+0xf>
f01016f9:	83 c0 01             	add    $0x1,%eax
f01016fc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01016ff:	38 ca                	cmp    %cl,%dl
f0101701:	74 04                	je     f0101707 <strfind+0x1a>
f0101703:	84 d2                	test   %dl,%dl
f0101705:	75 f2                	jne    f01016f9 <strfind+0xc>
			break;
	return (char *) s;
}
f0101707:	5d                   	pop    %ebp
f0101708:	c3                   	ret    

f0101709 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101709:	55                   	push   %ebp
f010170a:	89 e5                	mov    %esp,%ebp
f010170c:	57                   	push   %edi
f010170d:	56                   	push   %esi
f010170e:	53                   	push   %ebx
f010170f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101712:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101715:	85 c9                	test   %ecx,%ecx
f0101717:	74 13                	je     f010172c <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101719:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010171f:	75 05                	jne    f0101726 <memset+0x1d>
f0101721:	f6 c1 03             	test   $0x3,%cl
f0101724:	74 0d                	je     f0101733 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101726:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101729:	fc                   	cld    
f010172a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010172c:	89 f8                	mov    %edi,%eax
f010172e:	5b                   	pop    %ebx
f010172f:	5e                   	pop    %esi
f0101730:	5f                   	pop    %edi
f0101731:	5d                   	pop    %ebp
f0101732:	c3                   	ret    
		c &= 0xFF;
f0101733:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101737:	89 d3                	mov    %edx,%ebx
f0101739:	c1 e3 08             	shl    $0x8,%ebx
f010173c:	89 d0                	mov    %edx,%eax
f010173e:	c1 e0 18             	shl    $0x18,%eax
f0101741:	89 d6                	mov    %edx,%esi
f0101743:	c1 e6 10             	shl    $0x10,%esi
f0101746:	09 f0                	or     %esi,%eax
f0101748:	09 c2                	or     %eax,%edx
f010174a:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f010174c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010174f:	89 d0                	mov    %edx,%eax
f0101751:	fc                   	cld    
f0101752:	f3 ab                	rep stos %eax,%es:(%edi)
f0101754:	eb d6                	jmp    f010172c <memset+0x23>

f0101756 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101756:	55                   	push   %ebp
f0101757:	89 e5                	mov    %esp,%ebp
f0101759:	57                   	push   %edi
f010175a:	56                   	push   %esi
f010175b:	8b 45 08             	mov    0x8(%ebp),%eax
f010175e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101761:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101764:	39 c6                	cmp    %eax,%esi
f0101766:	73 35                	jae    f010179d <memmove+0x47>
f0101768:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010176b:	39 c2                	cmp    %eax,%edx
f010176d:	76 2e                	jbe    f010179d <memmove+0x47>
		s += n;
		d += n;
f010176f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101772:	89 d6                	mov    %edx,%esi
f0101774:	09 fe                	or     %edi,%esi
f0101776:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010177c:	74 0c                	je     f010178a <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010177e:	83 ef 01             	sub    $0x1,%edi
f0101781:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101784:	fd                   	std    
f0101785:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101787:	fc                   	cld    
f0101788:	eb 21                	jmp    f01017ab <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010178a:	f6 c1 03             	test   $0x3,%cl
f010178d:	75 ef                	jne    f010177e <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010178f:	83 ef 04             	sub    $0x4,%edi
f0101792:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101795:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101798:	fd                   	std    
f0101799:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010179b:	eb ea                	jmp    f0101787 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010179d:	89 f2                	mov    %esi,%edx
f010179f:	09 c2                	or     %eax,%edx
f01017a1:	f6 c2 03             	test   $0x3,%dl
f01017a4:	74 09                	je     f01017af <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01017a6:	89 c7                	mov    %eax,%edi
f01017a8:	fc                   	cld    
f01017a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01017ab:	5e                   	pop    %esi
f01017ac:	5f                   	pop    %edi
f01017ad:	5d                   	pop    %ebp
f01017ae:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017af:	f6 c1 03             	test   $0x3,%cl
f01017b2:	75 f2                	jne    f01017a6 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01017b4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01017b7:	89 c7                	mov    %eax,%edi
f01017b9:	fc                   	cld    
f01017ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017bc:	eb ed                	jmp    f01017ab <memmove+0x55>

f01017be <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01017be:	55                   	push   %ebp
f01017bf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01017c1:	ff 75 10             	pushl  0x10(%ebp)
f01017c4:	ff 75 0c             	pushl  0xc(%ebp)
f01017c7:	ff 75 08             	pushl  0x8(%ebp)
f01017ca:	e8 87 ff ff ff       	call   f0101756 <memmove>
}
f01017cf:	c9                   	leave  
f01017d0:	c3                   	ret    

f01017d1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01017d1:	55                   	push   %ebp
f01017d2:	89 e5                	mov    %esp,%ebp
f01017d4:	56                   	push   %esi
f01017d5:	53                   	push   %ebx
f01017d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01017d9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01017dc:	89 c6                	mov    %eax,%esi
f01017de:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01017e1:	39 f0                	cmp    %esi,%eax
f01017e3:	74 1c                	je     f0101801 <memcmp+0x30>
		if (*s1 != *s2)
f01017e5:	0f b6 08             	movzbl (%eax),%ecx
f01017e8:	0f b6 1a             	movzbl (%edx),%ebx
f01017eb:	38 d9                	cmp    %bl,%cl
f01017ed:	75 08                	jne    f01017f7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01017ef:	83 c0 01             	add    $0x1,%eax
f01017f2:	83 c2 01             	add    $0x1,%edx
f01017f5:	eb ea                	jmp    f01017e1 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01017f7:	0f b6 c1             	movzbl %cl,%eax
f01017fa:	0f b6 db             	movzbl %bl,%ebx
f01017fd:	29 d8                	sub    %ebx,%eax
f01017ff:	eb 05                	jmp    f0101806 <memcmp+0x35>
	}

	return 0;
f0101801:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101806:	5b                   	pop    %ebx
f0101807:	5e                   	pop    %esi
f0101808:	5d                   	pop    %ebp
f0101809:	c3                   	ret    

f010180a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010180a:	55                   	push   %ebp
f010180b:	89 e5                	mov    %esp,%ebp
f010180d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101810:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101813:	89 c2                	mov    %eax,%edx
f0101815:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101818:	39 d0                	cmp    %edx,%eax
f010181a:	73 09                	jae    f0101825 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f010181c:	38 08                	cmp    %cl,(%eax)
f010181e:	74 05                	je     f0101825 <memfind+0x1b>
	for (; s < ends; s++)
f0101820:	83 c0 01             	add    $0x1,%eax
f0101823:	eb f3                	jmp    f0101818 <memfind+0xe>
			break;
	return (void *) s;
}
f0101825:	5d                   	pop    %ebp
f0101826:	c3                   	ret    

f0101827 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101827:	55                   	push   %ebp
f0101828:	89 e5                	mov    %esp,%ebp
f010182a:	57                   	push   %edi
f010182b:	56                   	push   %esi
f010182c:	53                   	push   %ebx
f010182d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101830:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101833:	eb 03                	jmp    f0101838 <strtol+0x11>
		s++;
f0101835:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101838:	0f b6 01             	movzbl (%ecx),%eax
f010183b:	3c 20                	cmp    $0x20,%al
f010183d:	74 f6                	je     f0101835 <strtol+0xe>
f010183f:	3c 09                	cmp    $0x9,%al
f0101841:	74 f2                	je     f0101835 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0101843:	3c 2b                	cmp    $0x2b,%al
f0101845:	74 2e                	je     f0101875 <strtol+0x4e>
	int neg = 0;
f0101847:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f010184c:	3c 2d                	cmp    $0x2d,%al
f010184e:	74 2f                	je     f010187f <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101850:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101856:	75 05                	jne    f010185d <strtol+0x36>
f0101858:	80 39 30             	cmpb   $0x30,(%ecx)
f010185b:	74 2c                	je     f0101889 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010185d:	85 db                	test   %ebx,%ebx
f010185f:	75 0a                	jne    f010186b <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101861:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0101866:	80 39 30             	cmpb   $0x30,(%ecx)
f0101869:	74 28                	je     f0101893 <strtol+0x6c>
		base = 10;
f010186b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101870:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101873:	eb 50                	jmp    f01018c5 <strtol+0x9e>
		s++;
f0101875:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0101878:	bf 00 00 00 00       	mov    $0x0,%edi
f010187d:	eb d1                	jmp    f0101850 <strtol+0x29>
		s++, neg = 1;
f010187f:	83 c1 01             	add    $0x1,%ecx
f0101882:	bf 01 00 00 00       	mov    $0x1,%edi
f0101887:	eb c7                	jmp    f0101850 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101889:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010188d:	74 0e                	je     f010189d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f010188f:	85 db                	test   %ebx,%ebx
f0101891:	75 d8                	jne    f010186b <strtol+0x44>
		s++, base = 8;
f0101893:	83 c1 01             	add    $0x1,%ecx
f0101896:	bb 08 00 00 00       	mov    $0x8,%ebx
f010189b:	eb ce                	jmp    f010186b <strtol+0x44>
		s += 2, base = 16;
f010189d:	83 c1 02             	add    $0x2,%ecx
f01018a0:	bb 10 00 00 00       	mov    $0x10,%ebx
f01018a5:	eb c4                	jmp    f010186b <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01018a7:	8d 72 9f             	lea    -0x61(%edx),%esi
f01018aa:	89 f3                	mov    %esi,%ebx
f01018ac:	80 fb 19             	cmp    $0x19,%bl
f01018af:	77 29                	ja     f01018da <strtol+0xb3>
			dig = *s - 'a' + 10;
f01018b1:	0f be d2             	movsbl %dl,%edx
f01018b4:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01018b7:	3b 55 10             	cmp    0x10(%ebp),%edx
f01018ba:	7d 30                	jge    f01018ec <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01018bc:	83 c1 01             	add    $0x1,%ecx
f01018bf:	0f af 45 10          	imul   0x10(%ebp),%eax
f01018c3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01018c5:	0f b6 11             	movzbl (%ecx),%edx
f01018c8:	8d 72 d0             	lea    -0x30(%edx),%esi
f01018cb:	89 f3                	mov    %esi,%ebx
f01018cd:	80 fb 09             	cmp    $0x9,%bl
f01018d0:	77 d5                	ja     f01018a7 <strtol+0x80>
			dig = *s - '0';
f01018d2:	0f be d2             	movsbl %dl,%edx
f01018d5:	83 ea 30             	sub    $0x30,%edx
f01018d8:	eb dd                	jmp    f01018b7 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f01018da:	8d 72 bf             	lea    -0x41(%edx),%esi
f01018dd:	89 f3                	mov    %esi,%ebx
f01018df:	80 fb 19             	cmp    $0x19,%bl
f01018e2:	77 08                	ja     f01018ec <strtol+0xc5>
			dig = *s - 'A' + 10;
f01018e4:	0f be d2             	movsbl %dl,%edx
f01018e7:	83 ea 37             	sub    $0x37,%edx
f01018ea:	eb cb                	jmp    f01018b7 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f01018ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01018f0:	74 05                	je     f01018f7 <strtol+0xd0>
		*endptr = (char *) s;
f01018f2:	8b 75 0c             	mov    0xc(%ebp),%esi
f01018f5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01018f7:	89 c2                	mov    %eax,%edx
f01018f9:	f7 da                	neg    %edx
f01018fb:	85 ff                	test   %edi,%edi
f01018fd:	0f 45 c2             	cmovne %edx,%eax
}
f0101900:	5b                   	pop    %ebx
f0101901:	5e                   	pop    %esi
f0101902:	5f                   	pop    %edi
f0101903:	5d                   	pop    %ebp
f0101904:	c3                   	ret    
f0101905:	66 90                	xchg   %ax,%ax
f0101907:	66 90                	xchg   %ax,%ax
f0101909:	66 90                	xchg   %ax,%ax
f010190b:	66 90                	xchg   %ax,%ax
f010190d:	66 90                	xchg   %ax,%ax
f010190f:	90                   	nop

f0101910 <__udivdi3>:
f0101910:	55                   	push   %ebp
f0101911:	57                   	push   %edi
f0101912:	56                   	push   %esi
f0101913:	53                   	push   %ebx
f0101914:	83 ec 1c             	sub    $0x1c,%esp
f0101917:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010191b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010191f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101923:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101927:	85 d2                	test   %edx,%edx
f0101929:	75 35                	jne    f0101960 <__udivdi3+0x50>
f010192b:	39 f3                	cmp    %esi,%ebx
f010192d:	0f 87 bd 00 00 00    	ja     f01019f0 <__udivdi3+0xe0>
f0101933:	85 db                	test   %ebx,%ebx
f0101935:	89 d9                	mov    %ebx,%ecx
f0101937:	75 0b                	jne    f0101944 <__udivdi3+0x34>
f0101939:	b8 01 00 00 00       	mov    $0x1,%eax
f010193e:	31 d2                	xor    %edx,%edx
f0101940:	f7 f3                	div    %ebx
f0101942:	89 c1                	mov    %eax,%ecx
f0101944:	31 d2                	xor    %edx,%edx
f0101946:	89 f0                	mov    %esi,%eax
f0101948:	f7 f1                	div    %ecx
f010194a:	89 c6                	mov    %eax,%esi
f010194c:	89 e8                	mov    %ebp,%eax
f010194e:	89 f7                	mov    %esi,%edi
f0101950:	f7 f1                	div    %ecx
f0101952:	89 fa                	mov    %edi,%edx
f0101954:	83 c4 1c             	add    $0x1c,%esp
f0101957:	5b                   	pop    %ebx
f0101958:	5e                   	pop    %esi
f0101959:	5f                   	pop    %edi
f010195a:	5d                   	pop    %ebp
f010195b:	c3                   	ret    
f010195c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101960:	39 f2                	cmp    %esi,%edx
f0101962:	77 7c                	ja     f01019e0 <__udivdi3+0xd0>
f0101964:	0f bd fa             	bsr    %edx,%edi
f0101967:	83 f7 1f             	xor    $0x1f,%edi
f010196a:	0f 84 98 00 00 00    	je     f0101a08 <__udivdi3+0xf8>
f0101970:	89 f9                	mov    %edi,%ecx
f0101972:	b8 20 00 00 00       	mov    $0x20,%eax
f0101977:	29 f8                	sub    %edi,%eax
f0101979:	d3 e2                	shl    %cl,%edx
f010197b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010197f:	89 c1                	mov    %eax,%ecx
f0101981:	89 da                	mov    %ebx,%edx
f0101983:	d3 ea                	shr    %cl,%edx
f0101985:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101989:	09 d1                	or     %edx,%ecx
f010198b:	89 f2                	mov    %esi,%edx
f010198d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101991:	89 f9                	mov    %edi,%ecx
f0101993:	d3 e3                	shl    %cl,%ebx
f0101995:	89 c1                	mov    %eax,%ecx
f0101997:	d3 ea                	shr    %cl,%edx
f0101999:	89 f9                	mov    %edi,%ecx
f010199b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010199f:	d3 e6                	shl    %cl,%esi
f01019a1:	89 eb                	mov    %ebp,%ebx
f01019a3:	89 c1                	mov    %eax,%ecx
f01019a5:	d3 eb                	shr    %cl,%ebx
f01019a7:	09 de                	or     %ebx,%esi
f01019a9:	89 f0                	mov    %esi,%eax
f01019ab:	f7 74 24 08          	divl   0x8(%esp)
f01019af:	89 d6                	mov    %edx,%esi
f01019b1:	89 c3                	mov    %eax,%ebx
f01019b3:	f7 64 24 0c          	mull   0xc(%esp)
f01019b7:	39 d6                	cmp    %edx,%esi
f01019b9:	72 0c                	jb     f01019c7 <__udivdi3+0xb7>
f01019bb:	89 f9                	mov    %edi,%ecx
f01019bd:	d3 e5                	shl    %cl,%ebp
f01019bf:	39 c5                	cmp    %eax,%ebp
f01019c1:	73 5d                	jae    f0101a20 <__udivdi3+0x110>
f01019c3:	39 d6                	cmp    %edx,%esi
f01019c5:	75 59                	jne    f0101a20 <__udivdi3+0x110>
f01019c7:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01019ca:	31 ff                	xor    %edi,%edi
f01019cc:	89 fa                	mov    %edi,%edx
f01019ce:	83 c4 1c             	add    $0x1c,%esp
f01019d1:	5b                   	pop    %ebx
f01019d2:	5e                   	pop    %esi
f01019d3:	5f                   	pop    %edi
f01019d4:	5d                   	pop    %ebp
f01019d5:	c3                   	ret    
f01019d6:	8d 76 00             	lea    0x0(%esi),%esi
f01019d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01019e0:	31 ff                	xor    %edi,%edi
f01019e2:	31 c0                	xor    %eax,%eax
f01019e4:	89 fa                	mov    %edi,%edx
f01019e6:	83 c4 1c             	add    $0x1c,%esp
f01019e9:	5b                   	pop    %ebx
f01019ea:	5e                   	pop    %esi
f01019eb:	5f                   	pop    %edi
f01019ec:	5d                   	pop    %ebp
f01019ed:	c3                   	ret    
f01019ee:	66 90                	xchg   %ax,%ax
f01019f0:	31 ff                	xor    %edi,%edi
f01019f2:	89 e8                	mov    %ebp,%eax
f01019f4:	89 f2                	mov    %esi,%edx
f01019f6:	f7 f3                	div    %ebx
f01019f8:	89 fa                	mov    %edi,%edx
f01019fa:	83 c4 1c             	add    $0x1c,%esp
f01019fd:	5b                   	pop    %ebx
f01019fe:	5e                   	pop    %esi
f01019ff:	5f                   	pop    %edi
f0101a00:	5d                   	pop    %ebp
f0101a01:	c3                   	ret    
f0101a02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a08:	39 f2                	cmp    %esi,%edx
f0101a0a:	72 06                	jb     f0101a12 <__udivdi3+0x102>
f0101a0c:	31 c0                	xor    %eax,%eax
f0101a0e:	39 eb                	cmp    %ebp,%ebx
f0101a10:	77 d2                	ja     f01019e4 <__udivdi3+0xd4>
f0101a12:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a17:	eb cb                	jmp    f01019e4 <__udivdi3+0xd4>
f0101a19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a20:	89 d8                	mov    %ebx,%eax
f0101a22:	31 ff                	xor    %edi,%edi
f0101a24:	eb be                	jmp    f01019e4 <__udivdi3+0xd4>
f0101a26:	66 90                	xchg   %ax,%ax
f0101a28:	66 90                	xchg   %ax,%ax
f0101a2a:	66 90                	xchg   %ax,%ax
f0101a2c:	66 90                	xchg   %ax,%ax
f0101a2e:	66 90                	xchg   %ax,%ax

f0101a30 <__umoddi3>:
f0101a30:	55                   	push   %ebp
f0101a31:	57                   	push   %edi
f0101a32:	56                   	push   %esi
f0101a33:	53                   	push   %ebx
f0101a34:	83 ec 1c             	sub    $0x1c,%esp
f0101a37:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0101a3b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101a3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101a43:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101a47:	85 ed                	test   %ebp,%ebp
f0101a49:	89 f0                	mov    %esi,%eax
f0101a4b:	89 da                	mov    %ebx,%edx
f0101a4d:	75 19                	jne    f0101a68 <__umoddi3+0x38>
f0101a4f:	39 df                	cmp    %ebx,%edi
f0101a51:	0f 86 b1 00 00 00    	jbe    f0101b08 <__umoddi3+0xd8>
f0101a57:	f7 f7                	div    %edi
f0101a59:	89 d0                	mov    %edx,%eax
f0101a5b:	31 d2                	xor    %edx,%edx
f0101a5d:	83 c4 1c             	add    $0x1c,%esp
f0101a60:	5b                   	pop    %ebx
f0101a61:	5e                   	pop    %esi
f0101a62:	5f                   	pop    %edi
f0101a63:	5d                   	pop    %ebp
f0101a64:	c3                   	ret    
f0101a65:	8d 76 00             	lea    0x0(%esi),%esi
f0101a68:	39 dd                	cmp    %ebx,%ebp
f0101a6a:	77 f1                	ja     f0101a5d <__umoddi3+0x2d>
f0101a6c:	0f bd cd             	bsr    %ebp,%ecx
f0101a6f:	83 f1 1f             	xor    $0x1f,%ecx
f0101a72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101a76:	0f 84 b4 00 00 00    	je     f0101b30 <__umoddi3+0x100>
f0101a7c:	b8 20 00 00 00       	mov    $0x20,%eax
f0101a81:	89 c2                	mov    %eax,%edx
f0101a83:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101a87:	29 c2                	sub    %eax,%edx
f0101a89:	89 c1                	mov    %eax,%ecx
f0101a8b:	89 f8                	mov    %edi,%eax
f0101a8d:	d3 e5                	shl    %cl,%ebp
f0101a8f:	89 d1                	mov    %edx,%ecx
f0101a91:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101a95:	d3 e8                	shr    %cl,%eax
f0101a97:	09 c5                	or     %eax,%ebp
f0101a99:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101a9d:	89 c1                	mov    %eax,%ecx
f0101a9f:	d3 e7                	shl    %cl,%edi
f0101aa1:	89 d1                	mov    %edx,%ecx
f0101aa3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101aa7:	89 df                	mov    %ebx,%edi
f0101aa9:	d3 ef                	shr    %cl,%edi
f0101aab:	89 c1                	mov    %eax,%ecx
f0101aad:	89 f0                	mov    %esi,%eax
f0101aaf:	d3 e3                	shl    %cl,%ebx
f0101ab1:	89 d1                	mov    %edx,%ecx
f0101ab3:	89 fa                	mov    %edi,%edx
f0101ab5:	d3 e8                	shr    %cl,%eax
f0101ab7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101abc:	09 d8                	or     %ebx,%eax
f0101abe:	f7 f5                	div    %ebp
f0101ac0:	d3 e6                	shl    %cl,%esi
f0101ac2:	89 d1                	mov    %edx,%ecx
f0101ac4:	f7 64 24 08          	mull   0x8(%esp)
f0101ac8:	39 d1                	cmp    %edx,%ecx
f0101aca:	89 c3                	mov    %eax,%ebx
f0101acc:	89 d7                	mov    %edx,%edi
f0101ace:	72 06                	jb     f0101ad6 <__umoddi3+0xa6>
f0101ad0:	75 0e                	jne    f0101ae0 <__umoddi3+0xb0>
f0101ad2:	39 c6                	cmp    %eax,%esi
f0101ad4:	73 0a                	jae    f0101ae0 <__umoddi3+0xb0>
f0101ad6:	2b 44 24 08          	sub    0x8(%esp),%eax
f0101ada:	19 ea                	sbb    %ebp,%edx
f0101adc:	89 d7                	mov    %edx,%edi
f0101ade:	89 c3                	mov    %eax,%ebx
f0101ae0:	89 ca                	mov    %ecx,%edx
f0101ae2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101ae7:	29 de                	sub    %ebx,%esi
f0101ae9:	19 fa                	sbb    %edi,%edx
f0101aeb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0101aef:	89 d0                	mov    %edx,%eax
f0101af1:	d3 e0                	shl    %cl,%eax
f0101af3:	89 d9                	mov    %ebx,%ecx
f0101af5:	d3 ee                	shr    %cl,%esi
f0101af7:	d3 ea                	shr    %cl,%edx
f0101af9:	09 f0                	or     %esi,%eax
f0101afb:	83 c4 1c             	add    $0x1c,%esp
f0101afe:	5b                   	pop    %ebx
f0101aff:	5e                   	pop    %esi
f0101b00:	5f                   	pop    %edi
f0101b01:	5d                   	pop    %ebp
f0101b02:	c3                   	ret    
f0101b03:	90                   	nop
f0101b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b08:	85 ff                	test   %edi,%edi
f0101b0a:	89 f9                	mov    %edi,%ecx
f0101b0c:	75 0b                	jne    f0101b19 <__umoddi3+0xe9>
f0101b0e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b13:	31 d2                	xor    %edx,%edx
f0101b15:	f7 f7                	div    %edi
f0101b17:	89 c1                	mov    %eax,%ecx
f0101b19:	89 d8                	mov    %ebx,%eax
f0101b1b:	31 d2                	xor    %edx,%edx
f0101b1d:	f7 f1                	div    %ecx
f0101b1f:	89 f0                	mov    %esi,%eax
f0101b21:	f7 f1                	div    %ecx
f0101b23:	e9 31 ff ff ff       	jmp    f0101a59 <__umoddi3+0x29>
f0101b28:	90                   	nop
f0101b29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b30:	39 dd                	cmp    %ebx,%ebp
f0101b32:	72 08                	jb     f0101b3c <__umoddi3+0x10c>
f0101b34:	39 f7                	cmp    %esi,%edi
f0101b36:	0f 87 21 ff ff ff    	ja     f0101a5d <__umoddi3+0x2d>
f0101b3c:	89 da                	mov    %ebx,%edx
f0101b3e:	89 f0                	mov    %esi,%eax
f0101b40:	29 f8                	sub    %edi,%eax
f0101b42:	19 ea                	sbb    %ebp,%edx
f0101b44:	e9 14 ff ff ff       	jmp    f0101a5d <__umoddi3+0x2d>
