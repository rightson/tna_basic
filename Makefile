M3_IP = 192.168.132.83
M3_IF = eno3
M4_VIP = 10.0.10.43

usage:
	@echo targets: build run.switchd port.conf port.show port.watch test

build:
	rt build tna_basic.p4

run.switchd:
	rt switchd tna_basic

port.conf:
	rt bfshell pm.bfsh

port.show:
	rt bfshell show.bfsh

port.watch:
	watch -n 1 "rt bfshell show.bfsh"

test:
	rt test $(PWD)

ping.m3:
	ssh p4user@$(M3_IP) ping -I $(M3_IF) $(M4_VIP) -c 5
