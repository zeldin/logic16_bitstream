logic16_bitstream
=================

This is an open reimplementation of the FPGA bitstream(s) used
with the Saleae Logic16 logic analyzer.  The goal is to create
fully redistributable bitstreams allowing the logic analyzer to
be used with open source software.


Building
--------

To build this, the Xilinx ISE is needed.

First, edit the Makefile to adjust the path to the Xilinx ISE
binary directory.  Then, run make and the bitstreams will be
generated into the bin directory.

