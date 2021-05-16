.PHONY: venv.init build switchd port port.up port.show port.clear mac mac.show test clean
export PATH := $(PWD)/bin:$(PATH)

RUN_DIR = ./run
P4_NAME = tna_basic


usage:
	@echo "Targets:"
	@grep -e '^.PHONY' Makefile | sed 's/.PHONY://g'


build:
	sde build $(P4_NAME).p4

switchd:
	if [ ! -d $(RUN_DIR) ]; then mkdir -p $(RUN_DIR); fi
	if [ -d $(RUN_DIR) ]; then cd $(RUN_DIR) && sde switchd $(P4_NAME); fi

port: port.up sleep port.clear port.show
port.up:
	sde bfshell conf/port.bfsh
port.show:
	sde bfshell conf/show.bfsh
port.clear:
	sde bfshell conf/port-stats-clr.bfsh

sleep:
	sleep 5;

mac: mac.show
mac.show:
	sde bfshell conf/port-mac.bfsh

test:
	if [ -d $(RUN_DIR) ]; then cd $(RUN_DIR) && sde test ../ptf; fi

clean:
	rm -f *.swp *.swo *.pyc cscope.* ptf.* tags run/*

