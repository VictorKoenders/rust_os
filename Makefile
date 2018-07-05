# Automatically generate lists of sources using wildcards.
C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)
ASM_FILES = $(wildcard boot/*.asm boot/disk/*.asm boot/pm/*.asm boot/print/*.asm)

# TODO: Make sources dep on all header files.

# Convert the *.c filenames to *.o to give a list of object files to build
OBJ = ${C_SOURCES:.c=.o}

# Defaul build target
all: os-image

# Run bochs to simulate booting of our code.
run: all
	qemu-system-x86_64 -drive format=raw,file=os-image

# This is the actual disk image that the computer loads
# which is the combination of our compiled bootsector and kernel
os-image: boot/boot_sect.bin kernel.bin
	cat $^ > os-image

# This builds the binary of our kernel from two object files:
#  - the kernel_entry , which jumps to main() in our kernel
#  - the compiled C kernel
kernel.bin: kernel/kernel_entry.o ${OBJ}
	ld -T NUL -o kernel.tmp -Ttext 0x1000 $^
	objcopy -O binary -j .text kernel.tmp $@

# Generic rule for compiling C code to an object file
# For simplicity , we C files depend on all header files.
%.o : %.c ${HEADERS}
	gcc -ffreestanding -c $< -o $@

# Assemble the kernel_entry.
%.o : %.asm
	nasm $< -f elf -o $@

boot/boot_sect.bin : boot/boot_sect.bin ${ASM_FILES}
	nasm $< -f bin -I '../../16 bit/' -o $@

%.bin : %.asm
	nasm $< -f bin -I '../../16 bit/' -o $@

clean:
	rm -rf *.bin *.dis *.o os-image *.tmp
	rm -rf kernel/*.o boot/*.bin drivers/*.o
	rm -rf boot/disk/*.bin boot/print/*.bin

# Disassemble our kernel - might be useful for debugging.
kernel.dis: kernel.bin
	ndisasm -b 32 $< > $@
