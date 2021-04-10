usage:
	@echo "Targets:"
	@echo "  build"
	@echo "  switchd.run"
	@echo "  port.conf"
	@echo "  port.show"
	@echo "  port.watch"
	@echo "  rule.add"
	@echo "  test"
	@echo "  venv.init"
	@echo "  code.gen"
	@echo "  m3.ping"


venv.init:
	if [ ! -d venv ]; then \
		python -m venv venv --copies; \
		venv/bin/pip install -U pip; \
		venv/bin/pip install -r py/requirements.txt; \
	fi

code.gen:
	venv/bin/python py/p4gen.py p4src/conquest.p4template p4src/conquest.p4

build:
	rt build tna_basic.p4

switchd.run:
	rt switchd tna_basic

port.conf:
	rt bfshell conf/pm.bfsh && sleep 3 && rt bfshell conf/show.bfsh

port.show:
	rt bfshell conf/show.bfsh

port.watch:
	watch -n 1 "rt bfshell conf/show.bfsh"

rule.add:
	rt test conf

test:
	rt test test

m3.ping:
	ssh p4user@192.168.132.83 ping -I eno3 10.0.10.43 -c 5
