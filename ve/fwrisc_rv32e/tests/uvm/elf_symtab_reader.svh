/****************************************************************************
 * elf_symtab_reader.svh
 ****************************************************************************/
 
import "DPI-C" function chandle elf_symtab_reader_new(string file);
import "DPI-C" function int unsigned elf_symtab_reader_get_sym(chandle r, string name);
import "DPI-C" function int unsigned elf_data_reader_read32(string file, int unsigned addr);

/**
 * Class: elf_symtab_reader
 * 
 * TODO: Add class documentation
 */
class elf_symtab_reader;
	chandle				_reader;

	function new(string image);
		_reader = elf_symtab_reader_new(image);
	endfunction
	
	function int unsigned get_sym(string name);
		return elf_symtab_reader_get_sym(_reader, name);
	endfunction
	
endclass



