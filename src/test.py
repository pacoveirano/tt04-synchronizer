import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

# https://docs.cocotb.org/en/stable/quickstart.html

async def generate_clock(dut):
		for cycle in range(1000):
				"""Generate clock 2 pulses."""
				dut.clk.value = 0
				await Timer(90, units="ns")
				dut.clk.value = 1
				await Timer(90, units="ns")	
	
	
async def generate_clock2(dut):
		for cycle in range(1000):
				"""Generate clock 2 pulses."""
				dut.clk_2.value = 0
				await Timer(40, units="ns")
				dut.clk_2.value = 1
				await Timer(40, units="ns")	

async def reset_dut(reset_n, duration_ns):
		reset_n.value = 0
		await Timer(duration_ns, units="ns")
		reset_n.value = 1
		reset_n._log.debug("Reset complete")


@cocotb.test()
async def test_my_design(dut):
		dut._log.info("start")
    
		reset_thread = cocotb.start_soon(reset_dut(dut.rst_n, duration_ns=500))    
		clk_thread = cocotb.start_soon(generate_clock(dut))  # run the clock "in the background"
		clk2_thread = cocotb.start_soon(generate_clock2(dut))  # run the clock2 "in the background"
		await Timer(100000, units="ns")
#    cocotb.triggers.ClockCycles(signal, num_cycles, rising=True)
#		await Timer(40, units="ns")	
#		dut.INPUT.value = 1
#		await Timer(1, units="ms")
#		assert dut.OUTPUT.value == 0
