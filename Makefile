.PHONY: venv.init build switchd port.up port.show port.clear ptf clean
export PATH := bin:$(PATH)

RUN_DIR=./run

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
	sde build tna_basic.p4

switchd:
	if [ ! -d $(RUN_DIR) ]; then mkdir -p $(RUN_DIR); fi
	if [ -d $(RUN_DIR) ]; then cd $(RUN_DIR) && sde switchd tna_basic; fi

port.up:
	sde bfshell bfshell/port18.bfsh

port.show:
	sde bfshell bfshell/show.bfsh

port.clear:
	sde bfshell bfshell/port18-stats-clr.bfsh

ptf:
	if [ -d $(RUN_DIR) ]; then cd $(RUN_DIR) && sde test ../ptf; fi

clean:
	rm -f *.swp *.swo *.pyc cscope.* ptf.* tags run/*
