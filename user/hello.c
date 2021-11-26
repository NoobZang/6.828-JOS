// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	//cprintf("hello, world\n");
    int a = 10;
    char *ptr = (void *)0x8000d4;
    cprintf("before modify:%02x %02x %02x %02x %02x %02x %02x\n", (unsigned char)*ptr, (unsigned char)*(ptr+1), (unsigned char)*(ptr+2), (unsigned char)*(ptr+3), (unsigned char)*(ptr+4), (unsigned char)*(ptr+5), (unsigned char)*(ptr+6));
    memset((void *)0x8000d5, 0x80, 1);
    cprintf("after modify:%02x %02x %02x %02x %02x %02x %02x\n", (unsigned char)*ptr, (unsigned char)*(ptr+1), (unsigned char)*(ptr+2), (unsigned char)*(ptr+3), (unsigned char)*(ptr+4), (unsigned char)*(ptr+5), (unsigned char)*(ptr+6));
    //cprintf("i am environment %08x\n", thisenv->env_id);
    cprintf("a: %d\n", a);
}
