MODULE_DIR := $(shell pwd)

MUX8 = $(MODULE_DIR)/mux8.sv

MUX8_TB = $(MODULE_DIR)/mux8_tb.sv

SRC = $(MUX8) + $(MUX8_TB)

mux8:
	rm -rf mux8_sim && mkdir mux8_sim
	cd $(MODULE_DIR)/mux8_sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps $(SRC) > $(MODULE_DIR)/mux8_sim/mux8.log \
			&& vim $(MODULE_DIR)/mux8_sim/mux8.log

mux8_gui:
	rm -rf mux8_sim && mkdir mux8_sim
	cd $(MODULE_DIR)/mux8_sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps -gui $(SRC) &

clean:
	cd $(MODULE_DIR)/mux8_sim && rm -rf ./*
