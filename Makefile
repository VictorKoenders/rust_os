# Automatically generate lists of sources using wildcards.
C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)
ASM_FILES = $(wildcard boot/*.asm boot/disk/*.asm boot/pm/*.asm boot/print/*.asm)

# TODO: Make sources dep on all header files.

# Convert the *.c filenames to *.o to give a list of object files to build
OBJ = ${C_SOURCES:.c=.o}

# Defaul build target
all: os-image disk/disk.bin

# Run bochs to simulate booting of our code.
run: all
	qemu-system-x86_64 \
		-drive index=0,format=raw,file=os-image \
		-drive index=1,format=raw,file=disk/disk.bin

# This is the actual disk image that the computer loads
# which is the combination of our compiled bootsector and kernel
os-image: boot/boot_sect.bin kernel.bin
	cat $^ > os-image

# This builds the binary of our kernel from two object files:
#  - the kernel_entry , which jumps to main() in our kernel
#  - the compiled C kernel
# kernel.bin: kernel/kernel_entry.o ${OBJ}
# 	ld -T NUL -o kernel.tmp -Ttext 0x1000 $^
# 	objcopy -O binary -j .text kernel.tmp $@

kernel.bin: kernel/kernel_entry.o librust_kernel.o
	ld -T NUL -o kernel.tmp -Ttext 0x1000 $^
	objcopy -O binary -j .text kernel.tmp $@

librust_kernel.o: rust_kernel/*.toml rust_kernel/src/*.rs
	(cd rust_kernel && cargo xbuild --target i686-unknown-linux-gnu)
	ld rust_kernel/target/i686-unknown-linux-gnu/debug/librust_kernel.rlib -o librust_kernel.o

# Generic rule for compiling C code to an object file
# For simplicity, every C file depends on all header files.
%.o : %.c ${HEADERS}
	gcc -ffreestanding -c $< -o $@

# Assemble the kernel_entry.
%.o : %.asm
	nasm $< -f elf -o $@

boot/boot_sect.bin : boot/boot_sect.asm kernel.bin ${ASM_FILES}
	nasm $< -f bin -I '../../16 bit/' -o $@ -DKERNEL_SIZE=$(shell ls -nl kernel.bin | awk '{print $$5}')

%.bin : %.asm
	nasm $< -f bin -I '../../16 bit/' -o $@

clean:
	rm -rf *.bin *.dis *.o os-image *.tmp *.rlib
	rm -rf kernel/*.o boot/*.bin drivers/*.o
	rm -rf boot/disk/*.bin boot/print/*.bin
	(cd rust_kernel && cargo clean)

# Disassemble our kernel - might be useful for debugging.
kernel.dis: kernel.bin
	ndisasm -b 32 $< > $@
