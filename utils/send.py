#!/usr/bin/env python
import argparse
import sys
import socket
import random
import struct
import argparse

from scapy.all import sendp, send, get_if_list, get_if_hwaddr, hexdump
from scapy.all import Packet
from scapy.all import Ether, IP, UDP, TCP

def get_if():
    ifs=get_if_list()
    iface=None # "h1-eth0"
    for i in get_if_list():
        if "eth0" in i:
            iface=i
            break;
    if not iface:
        print "Cannot find eth0 interface"
        exit(1)
    return iface

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('ip_addr', type=str, help="The destination IP address to use")
    parser.add_argument('message', type=str, help="The message to include in packet")
    parser.add_argument('--iface', type=str, help="The iface of the packet", default=get_if)
    parser.add_argument('--dst_mac', type=str, help="The dst_mac of the packet", default='ff:ff:ff:ff:ff:ff')
    args = parser.parse_args()

    addr = socket.gethostbyname(args.ip_addr)
    iface = args.iface
    print(iface)

    print "sending on interface {} to IP addr {}".format(iface, str(addr))
    pkt =  Ether(src=get_if_hwaddr(iface), dst=args.dst_mac)
    pkt = pkt / IP(dst=addr) / TCP(dport=1234, sport=random.randint(49152,65535)) / args.message

    pkt.show2()
    hexdump(pkt)
    print "len(pkt) = ", len(pkt)
    sendp(pkt, iface=iface, verbose=False)


if __name__ == '__main__':
    main()
