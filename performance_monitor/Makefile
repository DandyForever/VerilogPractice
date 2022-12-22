MODULE_DIR := $(shell pwd)

EU_CONTROL = $(MODULE_DIR)/rtl/eu_controller.sv
CU_CONTROL = $(MODULE_DIR)/rtl/cu_controller.sv
PMON       = $(MODULE_DIR)/rtl/performance_monitor.sv

CONTROL_TB = $(MODULE_DIR)/tb/eu_controller_tb.sv
TOP_TB = $(MODULE_DIR)/tb/top_tb.sv

SRC = $(EU_CONTROL) + $(CU_CONTROL) + $(PMON) + $(TOP_TB)

pmon:
	rm -rf sim && mkdir sim
	cd $(MODULE_DIR)/sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps $(SRC) &
pmon_gui:
	rm -rf sim && mkdir sim
	cd $(MODULE_DIR)/sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps -gui $(SRC) &
clean:
	cd $(MODULE_DIR)/sim && rm -rf ./*
