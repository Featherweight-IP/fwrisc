
#include <irq.h>

void arch_irq_enable(unsigned int irq)
{
}

void arch_irq_disable(unsigned int irq)
{
};

int arch_irq_is_enabled(unsigned int irq)
{
	return 0;
}

#if defined(CONFIG_RISCV_SOC_INTERRUPT_INIT)
void soc_interrupt_init(void)
{
	/* ensure that all interrupts are disabled */
	(void)irq_lock();
}
#endif
