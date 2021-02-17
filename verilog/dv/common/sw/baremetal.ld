
MEMORY
{
	ram(rwx) : ORIGIN = 0x80000000, LENGTH = 0x01000000
}

SECTIONS
{
    /* default entry point */
	.text : {
        *(.text.start)
		CREATE_OBJECT_SYMBOLS
		. += 0x40;
        *(.text.init)
/*        *(.text .text.* .gnu.linkonce.t.*) */
        *(.text .gnu.linkonce.t.*)
        *(.plt)
        *(.gnu.warning)
        *(.glue_7t) *(.glue_7)

        . = ALIGN(0x4);

        /* Static constructor / destructors */
        KEEP (*crtbegin.o(.ctors))
        KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))
        KEEP (*(SORT(.ctors.*)))
        KEEP (*crtend.o(.ctors))
        KEEP (*crtbegin.o(.dtors))
        KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))
        KEEP (*(SORT(.dtors.*)))
        KEEP (*crtend.o(.dtors))

        *(.rodata .rodata.* .gnu.linkonce.r.*)

        *(.init)
        *(.fini)
        . = ALIGN(0x4);
    } >ram
    
	_dtb = .; PROVIDE(dtb = .);
	
    .rodata.dtb : { 
    	*(.rodata.dtb) 
    } >ram

    .init_array : {
        __init_array_start = .;
        _init = .;
        *(.init_array)
        . = ALIGN(0x4);
    } >ram
    __init_array_end = .;

    _etext = .;

    .ramvec : {
        *(.ramvec)
        . = ALIGN(0x4);
    } >ram

    . = ALIGN(16); 

    .data ALIGN(0x10) : {
        . = ALIGN(0x4); 
        _data_load = LOADADDR(.data);
        _data_start = .;
        KEEP(*(.jcr))
        *(.got.plt) *(.got)
        *(.shdata)
        *(.data .data.* .gnu.linkonce.d.*)
        . = ALIGN(4);
        _data_end = .;
        _edata = .;
    } >ram

    .bss ALIGN(0x4): {
        _bss_start = .;
        *(.shbss)
        *(.bss .bss.* .gnu.linkonce.b.*)
        *(COMMON)
        . = ALIGN(4);
        _bss_end = .;
    } >ram

	.heap ALIGN(0x10): {
		. = ALIGN(0x4);
		_boot_heap_base = .; PROVIDE(boot_heap_base = .);
	} > ram
	
    PROVIDE(_memory_end = ORIGIN(ram) + LENGTH(ram));
    PROVIDE(_stack_top = ORIGIN(ram) + LENGTH(ram));

}
