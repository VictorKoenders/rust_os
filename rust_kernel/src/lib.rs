#![feature(panic_implementation, abi_x86_interrupt, lang_items)]
#![crate_type = "dylib"]
#![no_std]

use core::panic::PanicInfo;
use core::ptr;

#[no_mangle]
pub unsafe extern "C" fn _start() {
    let memory = 0xb8000 as *mut u8;
    for (index, c) in b"Hello from Rust".into_iter().enumerate() {
        ptr::write_volatile(memory.offset(index as isize * 2), *c);
    }
}

#[panic_implementation]
fn my_panic(_pi: &PanicInfo) -> ! {
    loop {}
}

#[lang = "eh_personality"] extern fn eh_personality() {}
