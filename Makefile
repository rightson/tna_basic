.PHONY: venv.init build switchd port port.up port.show port.clear mac mac.show test clean
export PATH := $(PWD)/utils:$(SDE):$(SDE_INSTALL)/bin:$(PATH)

RUN_DIR = ./run
P4_NAME = tna_basic


usage:
	@echo "Targets:"
	@grep -e '^.PHONY' Makefile | sed 's/.PHONY://g'

run:
	if [ ! -d $(RUN_DIR) ]; then mkdir -p $(RUN_DIR); fi

model: run
	cd run && run_tofino_model.sh -p $(P4_NAME)

build: run
	p4_build-9.0.0.sh $(P4_NAME).p4

switchd: run
	cd $(RUN_DIR) && run_switchd.sh -p $(P4_NAME)

test: run
	cd $(RUN_DIR) && run_p4_tests.sh -p $(P4_NAME) -t ../ptf

veth_setup:
	sudo $(SDE_INSTALL)/bin/veth_setup.sh

veth_teardown:
	sudo $(SDE_INSTALL)/bin/veth_teardown.sh

port: port.up sleep port.clear port.show
port.up:
	run_bfshell.sh -p $(P4_NAME) utils/port.bfsh
port.show:
	run_bfshell.sh -p $(P4_NAME) utils/show.bfsh
port.clear:
	run_bfshell.sh -p $(P4_NAME) utils/port-stats-clr.bfsh

sleep:
	sleep 5;

mac: mac.show
mac.show:
	run_bfshell.sh -p $(P4_NAME) utils/port-mac.bfsh

clean:
	rm -f *.swp *.swo *.pyc cscope.* ptf.* tags run/*

