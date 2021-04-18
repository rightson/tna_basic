#include <tna.p4>
#include "./common/headers.p4"
#include "./common/util.p4"

struct metadata_t {
    bit<16> port1;
    bit<16> port2;
}

parser IngressParser(
        packet_in pkt,
        out header_t hdr,
        out metadata_t md,
        out ingress_intrinsic_metadata_t intr_md) {

    TofinoIngressParser() tofino_parser;

    state start {
        tofino_parser.apply(pkt, intr_md);
        transition parse_ethernet;
    }

    state parse_ethernet{
        pkt.extract(hdr.ethernet);
        transition select (hdr.ethernet.ether_type) {
            ETHERTYPE_IPV4: parse_ipv4;
            default : accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition accept;
    }
}

control IngressPipeline(
        inout header_t hdr,
        inout metadata_t md,
        in ingress_intrinsic_metadata_t intr_md,
        in ingress_intrinsic_metadata_from_parser_t intr_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t intr_dprs_md,
        inout ingress_intrinsic_metadata_for_tm_t intr_tm_md) {

    action drop () {
        intr_dprs_md.drop_ctl = 0x1;
    }

    action noop () {

    }

    action ipv4_forward (mac_addr_t dst_addr, PortId_t dst_port) {
        intr_tm_md.ucast_egress_port = dst_port;
        hdr.ethernet.src_addr = hdr.ethernet.dst_addr;
        hdr.ethernet.dst_addr = dst_addr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table forward {
        key = {
            hdr.ipv4.dst_addr: exact;
        }
        actions = {
            ipv4_forward;
            @defaultonly noop;
        }
        default_action = noop;
        size = 1024;
    }

    apply {
        forward.apply();
        intr_tm_md.bypass_egress = 1w1;
    }
}

control IngressDeparser(
        packet_out pkt,
        inout header_t hdr,
        in metadata_t ig_md,
        in ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md) {
    apply {
        pkt.emit(hdr.ethernet);
        pkt.emit(hdr.ipv4);
    }
}

parser EgressParser(
        packet_in pkt,
        out header_t hdr,
        out metadata_t md,
        out egress_intrinsic_metadata_t intr_md) {

    state start {
        transition accept;
    }
}

control EgressPipeline(
        inout header_t hdr,
        inout metadata_t eg_md,
        in egress_intrinsic_metadata_t eg_intr_md,
        in egress_intrinsic_metadata_from_parser_t eg_intr_md_from_prsr,
        inout egress_intrinsic_metadata_for_deparser_t eg_intr_dprs_md,
        inout egress_intrinsic_metadata_for_output_port_t eg_intr_oport_md) {
    apply {}
}

control EgressDeparser(
        packet_out pkt,
        inout header_t hdr,
        in metadata_t md,
        in egress_intrinsic_metadata_for_deparser_t intr_dprs_md) {
    apply {
        pkt.emit(hdr.ethernet);
        pkt.emit(hdr.ipv4);
    }
}


Pipeline(
    IngressParser(),
    IngressPipeline(),
    IngressDeparser(),
    EgressParser(),
    EgressPipeline(),
    EgressDeparser()
) pipe;

Switch(pipe) main;
