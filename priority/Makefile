MODULE_DIR := $(shell pwd)

PRIORITY = $(MODULE_DIR)/priority.sv

PRIORITY_TB = $(MODULE_DIR)/priority_tb.sv

SRC = $(PRIORITY) + $(PRIORITY_TB)

priority:
	rm -rf priority_sim && mkdir priority_sim
	cd $(MODULE_DIR)/priority_sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps $(SRC) > $(MODULE_DIR)/priority_sim/priority.log \
			&& vim $(MODULE_DIR)/priority_sim/priority.log

priority_gui:
	rm -rf priority_sim && mkdir priority_sim
	cd $(MODULE_DIR)/priority_sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps -gui $(SRC) &

clean:
	cd $(MODULE_DIR)/priority_sim && rm -rf ./*
