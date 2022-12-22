MODULE_DIR := $(shell pwd)

ST_CNT     = $(MODULE_DIR)/rtl/static_counter.sv
CONF_CNT   = $(MODULE_DIR)/rtl/conf_counter.sv
PERF_CNT   = $(MODULE_DIR)/rtl/perf_counters.sv
EU_CONTROL = $(MODULE_DIR)/rtl/eu_controller.sv
CU_CONTROL = $(MODULE_DIR)/rtl/cu_controller.sv
PMON       = $(MODULE_DIR)/rtl/performance_monitor.sv

CONTROL_TB = $(MODULE_DIR)/tb/eu_controller_tb.sv
TOP_TB = $(MODULE_DIR)/tb/top_tb.sv

SRC = $(ST_CNT) + $(CONF_CNT) + $(PERF_CNT) + $(EU_CONTROL) + $(CU_CONTROL) + $(PMON) + $(TOP_TB)

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
