// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
    { "backtrace", "Display stack backtrace information", mon_backtrace },
	{ "showmap", "Display the physical address of virtual address", mon_showmap }
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
    uint32_t ebp = read_ebp();
	uint32_t *prev;
    prev = (uint32_t *)ebp;
    struct Eipdebuginfo info;

    cprintf("Stack backtrace:\n");
    while(ebp != 0 && debuginfo_eip(prev[1], &info) == 0)
    {
        //cprintf("ebp %x &ebp %p prev %p *prev %x\n", ebp, &ebp, prev, *prev);

        //cprintf("prev[0] %x prev[1] %x prev[2] %x\n", prev[0], prev[1], prev[2]);
        cprintf("ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", ebp, prev[1], prev[2], prev[3], prev[4], prev[5], prev[6]);
        cprintf("     %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, prev[1] - info.eip_fn_addr);
        ebp = *prev;
        prev = (uint32_t *)ebp;
        

    }
	return 0;
}

int
mon_showmap(int argc, char **argv, struct Trapframe *tf)
{

    static const char *msg = 
    "Usage: showmappings <start> [<length>]\nlength represents a 4KB page\n";
 
    if (argc < 2)
        goto help;
 
    uintptr_t vstart, vend;
    size_t vlen;
    pte_t *pte;
 
    vstart = (uintptr_t)strtol(argv[1], 0, 0);
    vlen = argc >= 3 ? (size_t)strtol(argv[2], 0, 0) : 1;
    vend = vstart + vlen*PGSIZE;
 
    vstart = ROUNDDOWN(vstart, PGSIZE);
    vend = ROUNDDOWN(vend, PGSIZE);

    while(vstart < vend)
    {
        pte = pgdir_walk(kern_pgdir, (void *)vstart, 0);
        if(pte && (*pte & PTE_P)) {
            cprintf("VA: 0x%08x, PA: 0x%08x, U-bit: %d, W-bit: %d\n", vstart, PTE_ADDR(*pte), !!(*pte & PTE_U), !!(*pte & PTE_W));
        }
        else {
            cprintf("VA: 0x%08x, PA: No Mapping\n", vstart);
        }
        vstart += PGSIZE;
    }
    return 0;

help:
    cprintf(msg);
    return 0;
}


/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
