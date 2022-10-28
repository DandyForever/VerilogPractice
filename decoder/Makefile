MODULE_DIR := $(shell pwd)

DECODER = $(MODULE_DIR)/decoder.sv

DECODER_TB = $(MODULE_DIR)/decoder_tb.sv

SRC = $(DECODER) + $(DECODER_TB)

decoder:
	rm -rf decoder_sim && mkdir decoder_sim
	cd $(MODULE_DIR)/decoder_sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps $(SRC) > $(MODULE_DIR)/decoder_sim/decoder.log \
			&& vim $(MODULE_DIR)/decoder_sim/decoder.log

decoder_gui:
	rm -rf decoder_sim && mkdir decoder_sim
	cd $(MODULE_DIR)/decoder_sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps -gui $(SRC) &

clean:
	cd $(MODULE_DIR)/decoder_sim && rm -rf ./*
