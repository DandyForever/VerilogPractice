MODULE_DIR := $(shell pwd)

MUX_LOGIC = $(MODULE_DIR)/mux_logic.sv
MUX8      = $(MODULE_DIR)/../mux8/mux8.sv

MUX_LOGIC_TB = $(MODULE_DIR)/mux_logic_tb.sv

SRC = $(MUX8) + $(MUX_LOGIC) + $(MUX_LOGIC_TB)

mux_logic:
	rm -rf mux_logic_sim && mkdir mux_logic_sim
	cd $(MODULE_DIR)/mux_logic_sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps $(SRC) > $(MODULE_DIR)/mux_logic_sim/mux_logic.log \
			&& vim $(MODULE_DIR)/mux_logic_sim/mux_logic.log

mux_logic_gui:
	rm -rf mux_logic_sim && mkdir mux_logic_sim
	cd $(MODULE_DIR)/mux_logic_sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps -gui $(SRC) &

clean:
	cd $(MODULE_DIR)/mux_logic_sim && rm -rf ./*
