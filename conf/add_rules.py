import logging

from bfruntime_client_base_tests import BfRuntimeTest
import bfrt_grpc.client as gc

logger = logging.getLogger('Test')


class ConfigTest(BfRuntimeTest):
    def setUp(self):
        client_id = 0
        self.p4_name = "tna_basic"
        BfRuntimeTest.setUp(self, client_id, self.p4_name)

    def tearDown(self):
        BfRuntimeTest.tearDown(self)

    def runTest(self):
        logger.info('Adding rule')

        bfrt_info = self.interface.bfrt_info_get(self.p4_name)

        table = bfrt_info.table_get('IngressPipeline.forward')
        table.info.key_field_annotation_add("hdr.ipv4.dst_addr", "ipv4")

        # eno3: 28, eno4: 29
        # eno3: 30, eno4: 31

        dst_port = 30
        dst_addr = '10.0.10.43'

        key = table.make_key([
            gc.KeyTuple('hdr.ipv4.dst_addr', dst_addr)])
        data = table.make_data([
            gc.DataTuple('dst_port', dst_port)],
            'IngressPipeline.ipv4_forward')

        target = gc.Target(device_id=0, pipe_id=0xffff)
        try:
            table.entry_del(target, key)
        except:
            pass
        table.entry_add(target, [key], [data])

