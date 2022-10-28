MODULE_DIR := $(shell pwd)

CONTROLLER = $(MODULE_DIR)/controller.sv

CONTROLLER_TB = $(MODULE_DIR)/controller_tb.sv

SRC = $(CONTROLLER) + $(CONTROLLER_TB)

controller_gui:
	rm -rf controller_sim && mkdir controller_sim
	cd $(MODULE_DIR)/controller_sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps -gui $(SRC) &

clean:
	cd $(MODULE_DIR)/controller_sim && rm -rf ./*
