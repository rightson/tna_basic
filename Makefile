.PHONY: venv.init build switchd port.up port.show port.clear test clean
export PATH := $(PWD)/bin:$(PATH)

RUN_DIR = ./run
P4_NAME = tna_basic


usage:
	@echo "Targets:"
	@grep -e '^.PHONY' Makefile | sed 's/.PHONY://g'


venv.init:
	if [ ! -d venv ]; then \
		python -m venv venv --copies; \
		venv/bin/pip install -U pip; \
		venv/bin/pip install -r py/requirements.txt; \
	fi

build:
	sde build $(P4_NAME).p4

switchd:
	if [ ! -d $(RUN_DIR) ]; then mkdir -p $(RUN_DIR); fi
	if [ -d $(RUN_DIR) ]; then cd $(RUN_DIR) && sde switchd $(P4_NAME); fi

port.up:
	sde bfshell conf/port.bfsh

port.show:
	sde bfshell conf/show.bfsh

port: port.up
	sleep 5;
	make port.show

port.clear:
	sde bfshell conf/port-stats-clr.bfsh

test:
	if [ -d $(RUN_DIR) ]; then cd $(RUN_DIR) && sde test ../ptf; fi

clean:
	rm -f *.swp *.swo *.pyc cscope.* ptf.* tags run/*

