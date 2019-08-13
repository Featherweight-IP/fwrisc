/*
 * fwrisc_ripe_tests.h
 *
 *  Created on: Aug 12, 2019
 *      Author: ballance
 */

#ifndef VE_FWRISC_TESTS_CPP_FWRISC_RIPE_TESTS_H_
#define VE_FWRISC_TESTS_CPP_FWRISC_RIPE_TESTS_H_
#include "fwrisc_zephyr_tests.h"
#include <set>

class fwrisc_ripe_tests : public fwrisc_zephyr_tests {
public:
	fwrisc_ripe_tests();

	virtual ~fwrisc_ripe_tests();

	virtual void SetUp();

	virtual void enter_func(uint32_t addr, const std::string &name);

	virtual void leave_func(uint32_t addr, const std::string &name);

private:
	std::set<std::string>		m_intrusion_functions;
	bool						m_attack_attempted;

};

#endif /* VE_FWRISC_TESTS_CPP_FWRISC_RIPE_TESTS_H_ */
