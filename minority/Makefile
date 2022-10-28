MODULE_DIR := $(shell pwd)

MINORITY = $(MODULE_DIR)/minority.sv

MINORITY_TB = $(MODULE_DIR)/minority_tb.sv

SRC = $(MINORITY) + $(MINORITY_TB)

minority:
	rm -rf minority_sim && mkdir minority_sim
	cd $(MODULE_DIR)/minority_sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps $(SRC) > $(MODULE_DIR)/minority_sim/minority.log \
			&& vim $(MODULE_DIR)/minority_sim/minority.log

minority_gui:
	rm -rf minority_sim && mkdir minority_sim
	cd $(MODULE_DIR)/minority_sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps -gui $(SRC) &

clean:
	cd $(MODULE_DIR)/minority_sim && rm -rf ./*
