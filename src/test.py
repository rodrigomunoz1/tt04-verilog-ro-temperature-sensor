import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

rx_1 = [0,0,0,0,0,0,0,0,0,1]
rx_2 = [0,1,0,0,0,0,0,0,0,1]

@cocotb.test()
async def test_ro_temp_sensor(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 100, units="us") #clock 50MHz
    cocotb.start_soon(clock.start())

    print(dir(dut))

    # reset
    dut._log.info("reset")
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.clk_external.value = 0
    dut.clk_sel.value = 1
    dut.osc_sel.value = 0
    dut.en_inv_osc.value = 0
    dut.en_nand_osc.value = 0
    dut.rx.value = 1
    await Timer(100000,units='ns')
    dut.en_inv_osc.value = 1
    dut.en_nand_osc.value = 1
    await Timer(15000,'ns')
    dut.rst_n.value = 1
    await Timer(52083,'ns')
    for i in range(10):
        await Timer(1000000,'ns')
        dut.rx.value = rx_1[i]
    await Timer(100000000,'ns')
"""
    dut.clk_sel.value = 1
    dut.osc_sel.value = 1
    await Timer(100000000,'ns')
    dut.en_inv_osc.value = 0
    dut.en_nand_osc.value = 1
    for i in range(10):
        await Timer(1000000,'ns')
        dut.rx.value = rx_2[i]
    await Timer(100000000,'ns')
    for i in range(10):
        await Timer(1000000,'ns')
        dut.rx.value = rx_1[i]
    await Timer(100000000,'ns')
"""
"""
    # the compare value is shifted 10 bits inside the design to allow slower counting
    max_count = dut.ui_in.value << 10
    dut._log.info(f"check all segments with MAX_COUNT set to {max_count}")
    # check all segments and roll over
    for i in range(15):
        dut._log.info("check segment {}".format(i))
        await ClockCycles(dut.clk, max_count)
        assert int(dut.segments.value) == segments[i % 10]

        # all bidirectionals are set to output
        assert dut.uio_oe == 0xFF

    # reset
    dut.rst_n.value = 0
    # set a different compare value
    dut.ui_in.value = 3
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    max_count = dut.ui_in.value << 10
    dut._log.info(f"check all segments with MAX_COUNT set to {max_count}")
    # check all segments and roll over
    for i in range(15):
        dut._log.info("check segment {}".format(i))
        await ClockCycles(dut.clk, max_count)
        assert int(dut.segments.value) == segments[i % 10]
"""
