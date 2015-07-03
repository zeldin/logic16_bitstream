
.SECONDEXPANSION:

%.ngc : $$($$*_VERILOG_SOURCES) $$(addprefix ipcore_dir/,$$(addsuffix .v,$$($$*_IPCORES)))
	@for s in $^; do echo 'verilog work "'"$$s"'"'; done > $*.prj
	@/bin/echo -e > $*.xst 'set -loop_iteration_limit 1000\nrun\n-ifn $*.prj\n-top $($*_TOP_MODULE)\n-p $($*_DEVICE)\n-ofn $@\n-opt_mode speed\n-opt_level 1\n-netlist_hierarchy rebuilt'
	$(XILINXBIN)/xst -ifn $*.xst -ofn $*.srp

%.ngd : %.ngc $$($$*_CONSTRAINT_FILES)
	$(XILINXBIN)/ngdbuild -p $($*_DEVICE) -dd _ngo -sd ipcore_dir $(foreach ucf,$($*_CONSTRAINT_FILES),-uc $(ucf)) $< $@

%_routed.ncd : %.ncd %.pcf
	$(XILINXBIN)/par -w $< $@

%.ncd %.pcf : %.ngd
	$(XILINXBIN)/map -p $($*_DEVICE) -timing -w -o $*.ncd $<

%.twr : %_routed.ncd %.pcf
	$(XILINXBIN)/trce -o $@ -v 12 -fastpaths $< $*.pcf

%.bit : %_routed.ncd %.pcf
	$(XILINXBIN)/bitgen $< $@ $*.pcf -g Binary:Yes -g Compress -w

ipcore_dir/%.v: $(IPCORE_DIR)/%.xco ipcore_dir/coregen.cgc
	$(XILINXBIN)/coregen -p ipcore_dir -b $<

ipcore_dir/coregen.cgc : $(IPCORE_DIR)/coregen.cgc | ipcore_dir
	cp $< $@

ipcore_dir:
	mkdir -p $@
