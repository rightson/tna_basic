.PHONY: venv.init build switchd port.up port.show port.clear ptf clean

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
	rt build tna_basic.p4

switchd:
	if [ ! -d $(RUN_DIR) ]; then mkdir -p $(RUN_DIR); fi
	if [ -d $(RUN_DIR) ]; then cd $(RUN_DIR) && rt switchd tna_basic; fi

port.up:
	rt bfshell bfshell/port18.bfsh

port.show:
	rt bfshell bfshell/show.bfsh

port.clear:
	rt bfshell bfshell/port18-stats-clr.bfsh

ptf:
	if [ -d $(RUN_DIR) ]; then cd $(RUN_DIR) && rt test ../ptf; fi

clean:
	rm -f *.swp *.swo *.pyc cscope.* ptf.* tags run/*
