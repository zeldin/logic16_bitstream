ifeq ($(origin _),command line)

XILINXBIN := /opt/Xilinx/14.7/ISE_DS/ISE/bin/lin64

SRC := $(SRCDIR)src

saleae-logic16-fpga-33_DEVICE := xc3s200a-4vq100
saleae-logic16-fpga-33_TOP_MODULE := logic_top

saleae-logic16-fpga-33_VERILOG_SOURCES := \
	$(SRC)/logic_top.v \
	$(SRC)/normal_clock_domain.v \
	$(SRC)/regaccess.v \
	$(SRC)/spi_slave.v \
	$(SRC)/clock_generator.v

saleae-logic16-fpga-33_IPCORES := \
	fifo_generator_v9_3

saleae-logic16-fpga-33_CONSTRAINT_FILES := \
	$(SRC)/logic_top.ucf \
	$(SRC)/logic-33.ucf

saleae-logic16-fpga-18_DEVICE := $(saleae-logic16-fpga-33_DEVICE)
saleae-logic16-fpga-18_TOP_MODULE := $(saleae-logic16-fpga-33_TOP_MODULE)

saleae-logic16-fpga-18_VERILOG_SOURCES := $(saleae-logic16-fpga-33_VERILOG_SOURCES)

saleae-logic16-fpga-18_IPCORES := $(saleae-logic16-fpga-33_IPCORES)

saleae-logic16-fpga-18_CONSTRAINT_FILES := \
	$(SRC)/logic_top.ucf \
	$(SRC)/logic-18.ucf

IPCORE_DIR = $(SRC)/ipcore

all : saleae-logic16-fpga-33.bit

.SECONDARY:

include $(SRCDIR)xilinx.mk

else

# Run make in object directory

SRCDIR?=$(dir $(lastword $(MAKEFILE_LIST)))
SUB_SRCDIR:=$(if $(filter /%,$(SRCDIR)),,../)$(SRCDIR)
O=obj
.DEFAULT_GOAL:=dummy

%: | $O
	@$(MAKE) --no-print-directory -C $O -f $(SUB_SRCDIR)/Makefile SRCDIR=$(SUB_SRCDIR) _= $(if $(MAKECMDGOALS),$@,)

clean:
	rm -rf $O

$O:
	mkdir -p $@

endif
