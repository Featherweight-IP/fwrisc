

zephyr_sources(
	soc_irq.S
	vector.S
	idle.c
	irq.c)

zephyr_compile_options(-march=rv32i)

