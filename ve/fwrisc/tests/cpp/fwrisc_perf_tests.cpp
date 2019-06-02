/*
 * fwrisc_perf_tests.cpp
 *
 *  Created on: Nov 18, 2018
 *      Author: ballance
 */

#include "fwrisc_perf_tests.h"

fwrisc_perf_tests::fwrisc_perf_tests() {
	m_instr_count = 0;
	m_mem_writes  = 0;
	// TODO Auto-generated constructor stub

}

fwrisc_perf_tests::~fwrisc_perf_tests() {
	// TODO Auto-generated destructor stub
}

void fwrisc_perf_tests::regwrite(uint32_t raddr, uint32_t rdata) {

}

void fwrisc_perf_tests::exec(uint32_t addr, uint32_t instr) {
	m_instr_count++;

	if (m_halt_addr == addr) {

	}

}

void fwrisc_perf_tests::memwrite(uint32_t addr, uint8_t mask, uint32_t data) {
	m_mem_writes++;

}
