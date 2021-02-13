/*
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef INCLUDED_FWRISC_TESTSOC_H
#define INCLUDED_FWRISC_TESTSOC_H

#include <soc_common.h>
#include <devicetree.h>

/* lib-c hooks required RAM defined variables */
#define RISCV_RAM_BASE    DT_SRAM_BASE_ADDR_ADDRESS
#define RISCV_RAM_SIZE    DT_SRAM_SIZE

#endif /* INCLUDED_FWRISC_TESTSOC_H */
