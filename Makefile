usage:
	@echo targets: build run.switchd port.conf port.show port.watch test

build:
	rt build tna_basic.p4

run.switchd:
	rt switchd tna_basic

port.conf:
	rt bfshell conf/pm.bfsh

port.show:
	rt bfshell conf/show.bfsh

port.watch:
	watch -n 1 "rt bfshell conf/show.bfsh"

test:
	rt test conf

ping.m3:
	ssh p4user@192.168.132.83 ping -I eno3 10.0.10.43 -c 5
