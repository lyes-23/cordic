CFLAGS=-Wall -O3 -std=c99 #-DDEBUG
LDFLAGS=-lm
MODEL=cordic

ADDRWD  = 8#		bit width of addresses for the rom
VALWD   = 8#		bit width of operands for the rom
CYCLES  = 4000#		number of cycles to simulate (should be suffisant for all triplets)
VALNB   = $(shell awk -v ADDRWD=$(ADDRWD) 'BEGIN{print int((2**ADDRWD)/3) }')
LASTPT  = $(shell awk -v VALNB=$(VALNB) 'BEGIN{print 3*VALNB-1}')

ALLIANCE=/home/skaikru/alliance/install
CMOS = $(ALLIANCE)/etc/cmos.rds
SLIB = $(ALLIANCE)/cells/sxlib
PLIB = $(ALLIANCE)/cells/pxlib

ASIM = export MBK_WORK_LIB=.; MBK_CATA_LIB=$(SLIB); asimut
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


simul_gpat_par: vasy ## Simule un jeu de patterns générés
	export MODEL=$(MODEL) CYCLES=50 TYPE=BEH; genpat patterns/$(MODEL)
	$(ASIM) -b $(MODEL)_v $(MODEL)_gen $(MODEL)_gres
	@if [[ "$(VERBOSE)" == "1" ]]; then $(XPAT) -l $(MODEL)_gres; fi

valid_cordic: ##genpat $(MODEL)_pat
	$(CC) $(CFLAGS) rom.c -o rom
	./rom	$(ADDRWD) $(VALWD) > rom.txt
	export PATNAME=$(MODEL)_tb ADDRWD=$(ADDRWD) VALWD=$(VALWD) CYCLES=$(CYCLES);\
	
	gcc -w -E -DADDRWD=$(ADDRWD) -DVALWD=$(VALWD) -DLASTPT=$(LASTPT) $(MODEL)_data.vhd.c\
	| grep -v "^#" > $(MODEL)_data.vhd
	vasy -a -I vhd -p -o one_to_three one_to_three
	vasy -a -I vhd -p -o two_to_one   two_to_one
	vasy -a -I vhd -p -o $(MODEL)_ctl $(MODEL)_ctl
	vasy -a -I vhd -p -o $(MODEL)_dp $(MODEL)_dp
	vasy -a -I vhd -p -o $(MODEL)_data $(MODEL)_data 
	vasy -a -I vhd -p -o $(MODEL)_tb   $(MODEL)_tb  
	asimut	$(MODEL)_tb $(MODEL)_tb $(MODEL)_tbres |\
	awk '/pattern/{printf("->"$$3" "$$4"\r")}END{print}'
	@grep ": ?1" $(MODEL)_tbres.pat || echo "Lucky no error"

clean: ##		$(MODEL)_tb.pat
	rm  Makefile.*\
		$(MODEL)_cor.vbe\
		$(MODEL)_net.vbe\
		$(MODEL)_net.vst\
		$(MODEL)_ctl.vbe\
		$(MODEL)_data.vhd\
		$(MODEL)_data.vbe\
		$(MODEL)_dp.vbe\
		one_to_three.vbe\
		two_to_one.vbe\
		$(MODEL)_tb.vst\
		$(MODEL)_tb.pat\
		default.pat\
		rom rom.txt\
		2> /dev/null || true
