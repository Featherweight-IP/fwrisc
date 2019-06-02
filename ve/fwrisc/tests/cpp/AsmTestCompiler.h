/*
 * AsmTestCompiler.h
 *
 *  Created on: Oct 28, 2018
 *      Author: ballance
 */

#ifndef INCLUDED_ASM_TEST_COMPILER_H
#define INCLUDED_ASM_TEST_COMPILER_H
#include <string>

class AsmTestCompiler {
public:
	static bool compile(
			const std::string	&basename,
			const std::string 	&program,
			const std::string 	&out="ram.hex");

protected:
	AsmTestCompiler(
			const std::string	&basename,
			const std::string 	&program,
			const std::string 	&out="ram.hex");

	virtual ~AsmTestCompiler();

	virtual bool compile();

	bool tohex(const std::string &file_vlog, const std::string &file_hex);

private:
	std::string					m_basename;
	std::string					m_program;
	std::string					m_out;
};

#endif /* INCLUDED_ASM_TEST_COMPILER_H */
