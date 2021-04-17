import logging
import time

from bfruntime_client_base_tests import BfRuntimeTest
import bfrt_grpc.client as gc

logger = logging.getLogger('Test')


class ruleTest(BfRuntimeTest):
    def setUp(self):
        self.p4_name = "tna_basic"
        BfRuntimeTest.setUp(self, client_id=0, self.p4_name)

    def tearDown(self):
        BfRuntimeTest.tearDown(self)

    def runTest(self):
        logger.info('Adding rule')

        bfrt_info = self.interface.bfrt_info_get(self.p4_name)

        table = bfrt_info.table_get('IngressPipeline.forward')
        table.info.key_field_annotation_add("hdr.ipv4.dst_addr", "ipv4")
        table.info.data_field_annotation_add("dst_addr", "ipv4_forward", "mac")

        rules = [
            {
                'key': {
                    'dst_addr': '10.0.10.33',
                },
                'data': {
                    'dst_addr': '08:94:ef:92:e6:76',
                    'dst_port': 12,
                },
            },
            {
                'key': {
                    'dst_addr': '10.0.10.43',
                },
                'data': {
                    'dst_addr': '08:94:ef:94:24:8a',
                    'dst_port': 14,
                },
            }
        ]

        for rule in rules:
            key = table.make_key(
                [
                    gc.KeyTuple('hdr.ipv4.dst_addr',
                                rule['key']['dst_addr'])
                ]
            )
            data = table.make_data(
                [
                    gc.DataTuple('dst_addr', rule['data']['dst_addr']),
                    gc.DataTuple('dst_port', rule['data']['dst_port']),
                ],
                'IngressPipeline.ipv4_forward'
            )

            target = gc.Target(device_id=0, pipe_id=0xffff)
            try:
                table.entry_del(target, [key])
            except:
                pass
            print('entry_add:  {key: %s, data: %s}' % (key, data))
            table.entry_add(target, [key], [data])

