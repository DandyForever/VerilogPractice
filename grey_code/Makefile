MODULE_DIR := $(shell pwd)

GREY = $(MODULE_DIR)/grey.sv

GREY_TB = $(MODULE_DIR)/grey_tb.sv

SRC = $(GREY) + $(GREY_TB)

grey_gui:
	rm -rf grey_sim && mkdir grey_sim
	cd $(MODULE_DIR)/grey_sim && xrun -64bit -sv -access +rwc \
			-linedebug -timescale 1ns/10ps -gui $(SRC) &

clean:
	cd $(MODULE_DIR)/grey_sim && rm -rf ./*
