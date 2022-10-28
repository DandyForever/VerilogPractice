MODULE_DIR := $(shell pwd)

NEG = $(MODULE_DIR)/neg.sv

NEG_TB = $(MODULE_DIR)/neg_tb.sv

SRC = $(NEG) + $(NEG_TB)

neg:
	rm -rf neg_sim && mkdir neg_sim
	cd $(MODULE_DIR)/neg_sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps $(SRC) > $(MODULE_DIR)/neg_sim/neg.log \
			&& vim $(MODULE_DIR)/neg_sim/neg.log

neg_gui:
	rm -rf neg_sim && mkdir neg_sim
	cd $(MODULE_DIR)/neg_sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps -gui $(SRC) &

clean:
	cd $(MODULE_DIR)/neg_sim && rm -rf ./*
