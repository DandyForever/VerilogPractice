MODULE_DIR := $(shell pwd)

XOR4 = $(MODULE_DIR)/xor4.sv

XOR4_TB = $(MODULE_DIR)/xor4_tb.sv

SRC = $(XOR4) + $(XOR4_TB)

xor4:
	rm -rf xor4_sim && mkdir xor4_sim
	cd $(MODULE_DIR)/xor4_sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps $(SRC) > $(MODULE_DIR)/xor4_sim/xor4.log \
			&& vim $(MODULE_DIR)/xor4_sim/xor4.log

xor4_gui:
	rm -rf xor4_sim && mkdir xor4_sim
	cd $(MODULE_DIR)/xor4_sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps -gui $(SRC) &

clean:
	cd $(MODULE_DIR)/xor4_sim && rm -rf ./*
