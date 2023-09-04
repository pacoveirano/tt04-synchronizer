import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

# https://docs.cocotb.org/en/stable/quickstart.html

clk_T = 5 # in ns
clk2_T = 10 # in ns

async def generate_clock(dut):
		while True:
				"""Generate clock pulses."""
				dut.clk.value = 0
				await Timer(clk_T/2, units="ns")
				dut.clk.value = 1
				await Timer(clk_T/2, units="ns")	
	
	
async def generate_clock2(dut):
		while True:
				"""Generate clock 2 pulses."""
				dut.clk_2.value = 0
				await Timer(clk2_T/2, units="ns")
				dut.clk_2.value = 1
				await Timer(clk2_T/2, units="ns")	

async def reset_dut(reset_n):
		reset_n.value = 0
		await Timer(2*clk_T, units="ns")
		reset_n.value = 1
		reset_n._log.debug("Reset complete")




@cocotb.test()
async def test_my_design(dut):
		dut._log.info("start")
		dut.sel.value = 0
		dut.ena.value = 0
		dut.ena_blk.value = 0
		dut.pulse_in.value = 0
		dut.stb.value = 0
		dut.trg.value = 0
		
		dut.uio_in.value = 0b00000000 				  
		clk_thread = cocotb.start_soon(generate_clock(dut))  # run the clock "in the background"
		clk2_thread = cocotb.start_soon(generate_clock2(dut))  # run the clock2 "in the background"
		await cocotb.start(reset_dut(dut.rst_n))  
		dut.ena.value = 1
		await cocotb.triggers.ClockCycles(dut.clk, 5, rising=True)
		dut.ena.value = 1
		dut.ena_blk.value = 1
		dut.sel.value = 0
		dut.uio_in.value = 0b01010101 
		await cocotb.triggers.ClockCycles(dut.clk, 5, rising=True)
		
		dut.sel.value = 1
		dut.uio_in.value = 0b11111111 
		await cocotb.triggers.ClockCycles(dut.clk, 5, rising=True)
		
		dut.sel.value = 2
		dut.uio_in.value = 0b00000000 
		await cocotb.triggers.ClockCycles(dut.clk, 3, rising=True)
		
		dut.sel.value = 3
		dut.uio_in.value = 0b11111111 
		await cocotb.triggers.ClockCycles(dut.clk, 3, rising=True)
		dut.stb.value = 1
		await cocotb.triggers.ClockCycles(dut.clk, 1, rising=True)
		dut.stb.value = 0
		await cocotb.triggers.ClockCycles(dut.clk, 50, rising=True)
		
		dut.sel.value = 4
		dut.uio_in.value = 0xAB 
		await cocotb.triggers.ClockCycles(dut.clk, 3, rising=True)
		dut.pulse_in.value = 1
		await cocotb.triggers.ClockCycles(dut.clk, 1, rising=True)
		dut.pulse_in.value = 0
		await cocotb.triggers.ClockCycles(dut.clk, 50, rising=True)
		
		dut.sel.value = 5
		dut.uio_in.value = 0xDA 
		await cocotb.triggers.ClockCycles(dut.clk, 3, rising=True)
		dut.pulse_in.value = 1
		await cocotb.triggers.ClockCycles(dut.clk, 1, rising=True)
		dut.pulse_in.value = 0
		await cocotb.triggers.ClockCycles(dut.clk, 50, rising=True)
		
		dut.ena_blk.value = 0
	 
		await cocotb.triggers.ClockCycles(dut.clk, 10, rising=True)		
		dut.uio_in.value = 0x00 	
		await cocotb.triggers.ClockCycles(dut.clk, 5, rising=True)				
		dut.uio_in.value = 0xAB
		dut.sel.value = 1
		dut.pulse_in.value = 1				
		dut.stb.value = 1	
		dut.trg.value = 1	
		await cocotb.triggers.ClockCycles(dut.clk, 1, rising=True)
		dut.trg.value = 0
		dut.stb.value = 0
		dut.pulse_in.value = 0				
		dut.uio_in.value = 0x00 		
		await cocotb.triggers.ClockCycles(dut.clk, 50, rising=True)
		dut.sel.value = 0
		await cocotb.triggers.ClockCycles(dut.clk, 1, rising=True)
		dut.sel.value = 1
		await cocotb.triggers.ClockCycles(dut.clk, 1, rising=True)
		dut.sel.value = 2
		await cocotb.triggers.ClockCycles(dut.clk, 1, rising=True)
		dut.sel.value = 3
		await cocotb.triggers.ClockCycles(dut.clk, 1, rising=True)
		dut.sel.value = 4
		await cocotb.triggers.ClockCycles(dut.clk, 1, rising=True)
		dut.sel.value = 5
		await cocotb.triggers.ClockCycles(dut.clk, 1, rising=True)
		dut.sel.value = 6
		await cocotb.triggers.ClockCycles(dut.clk, 1, rising=True)
		dut.sel.value = 7
		await cocotb.triggers.ClockCycles(dut.clk, 1, rising=True)
				

