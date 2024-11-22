CFLAGS=-Wall -O3 -std=c99 #-DDEBUG
LDFLAGS=-lm
MODEL=cordic

ALLIANCE=/users/outil/alliance/alliance/Linux.el7_64/install
CMOS = $(ALLIANCE)/etc/cmos.rds
SLIB = $(ALLIANCE)/cells/sxlib
PLIB = $(ALLIANCE)/cells/pxlib


BOOM = export MBK_WORK_LIB=.; boom
BOOG = export MBK_WORK_LIB=. MBK_TARGET_LIB=$(SLIB); MBK_OUT_LO=vst; boog
XSCH = export MBK_WORK_LIB=. MBK_CATA_LIB=$(SLIB); xsch
VASY = export MBK_WORK_LIB=.; vasy
XPAT = export MBK_WORK_LIB=.; xpat
LOON = export MBK_CATA_LIB =. MBK_CATA_LIB=$(SLIB); loon


help:
	@echo ""
	@echo "  Cordic model validation"
	@echo "  -----------------------"
	@echo "  Usage: make <plot|valid_cor|valid_net|clean>"
	@echo "  - plot      : test if the cordic algorithm gives the right values"
	@echo "  - valid_cor : valid the vhdl behavior with generated patterns"
	@echo "  - valid_net : valid the control and datapath netlist with patterns"
	@echo "  - clean     : delete all generated files"
	@echo ""

plot: cercle
	./cercle
	gnuplot \
            -e 'plot [-130:130] [-130:130] "$(MODEL).dat" with lines;'\
            -e 'replot "cossin.dat" with lines;' \
            -e 'pause -1' 

valid_cor: 
	vasy -a -I vhd -p -o $(MODEL)_cor $(MODEL)_cor 
	export PATNAME=$(MODEL)_cor DECSIG; genpat $(MODEL)_pat
	asimut -b $(MODEL)_cor $(MODEL)_cor $(MODEL)_cor_res

valid_net: 
	vasy -a -I vhd -p -o $(MODEL)_dp $(MODEL)_dp 
	vasy -a -I vhd -p -o $(MODEL)_ctl $(MODEL)_ctl 
	vasy -a -I vhd -p -o $(MODEL)_net $(MODEL)_net 
	export PATNAME=$(MODEL)_net; genpat $(MODEL)_pat
	asimut $(MODEL)_net $(MODEL)_net $(MODEL)_net_res

valid_cordic_par: 
	vasy -a -I vhd -p -o $(MODEL)_par $(MODEL)_par_v 
	export PATNAME=$(MODEL)_par DECSIG; genpat $(MODEL)_par_pat
	asimut -b $(MODEL)_par $(MODEL)_par $(MODEL)_par_res


simul_gpat_par: vasy ## Simule un jeu de patterns générés
	export MODEL=$(MODEL) CYCLES=50 TYPE=BEH; genpat patterns/$(MODEL)
	$(ASIM) -b $(MODEL)_v $(MODEL)_gen $(MODEL)_gres
	@if [[ "$(VERBOSE)" == "1" ]]; then $(XPAT) -l $(MODEL)_gres; fi

clean:
	rm  *.dat *~ cercle Makefile.*\
		$(MODEL)_cor.vbe \
		$(MODEL)_cor.pat $(MODEL)_cor_res.pat \
		$(MODEL)_dp.vbe $(MODEL)_ctl.vbe $(MODEL)_net.vst \
		$(MODEL)_net.pat $(MODEL)_net_res.pat
