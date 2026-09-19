
# AMBA 3 APB Slave Protocol Core Implementation with Wait-State Logic

## 1. Project Overview
This repository contains a synthesizable, parameterized **AMBA 3 APB (Advanced Peripheral Bus) Slave** IP core integrated with an internal memory array, implemented in Verilog HDL. 

The hardware architecture follows the official ARM AMBA specifications to drive low-power, non-pipelined bus communication between a master bridge (e.g., Processor/Host) and secondary chip peripherals (e.g., UART, Timers, SPI). The design completely models the foundational APB State Machine and handles flexible data transactions utilizing bus handshake parameters.

---

## 2. Key Architecture & Features
* **Compliant 3-State FSM:** Implements a strict, deterministic Finite State Machine handling `IDLE`, `SETUP`, and `ACCESS` transitions smoothly across clock trees.
* **Wait-State & Handshake Logic:** Fully drives the `PREADY` control strobe, allowing the hardware slave interface to safely acknowledge read/write cycles or inject stall wait-states if needed.
* **Synchronous Matrix Memory:** Embedded with an active 256x32-bit parameterized structural register matrix that handles synchronous dual-directional read/write routines.
* **Clean Code Modularity:** Parameterized via `DATA_WIDTH` (32-bit baseline) and `ADDR_WIDTH` (8-bit baseline) configurations to easily match different system-bus scales.

---

## 3. Hardware Architecture Layout (Structural RTL Design)

The architecture diagram below displays the structural connectivity mapping, register matrix partitioning, and bus signal paths running inside the slave IP core:

```text
========================================================================================================
                                     AMBA APB SLAVE TOP HIERARCHY
========================================================================================================

          +-------------------------------------------------------------------------------+

          |                              amba_apb_slave (DUT)                             |
          |                                                                               |
          |     +-------------------------+                   +-----------------------+   |
          |     |                         |                   |                       |   |
----->--->|     |    APB STATE MACHINE    |                   |   SLAVE MEMORY REG    |   |
 PCLK     |     |   [IDLE->SETUP->ACCESS] |                   |    [256 x 32 Bits]    |   |

          |     |                         |                   |                       |   |
----->--->|     |   Control Decoder:      |                   |                       |   |
 PRESETn  |     |   - Processes PSEL      |                   |                       |   |

          |     |   - Processes PENABLE   |                   |                       |   |
----->--->|     |   - Processes PWRITE    |                   |                       |   |
 PSEL     |     |                         |                   |                       |   |

          |     +-------------------------+                   +-----------------------+   |
----->--->|          |                  |                                 ^               |
 PENABLE  |          |                  | internal_write_strobe           |               |

          |          |                  +---------------------------------+               |
----->--->|          |                                                    |               |
 PWRITE   |          | waddr / raddr bus                                  |               |

          |          v                                                    v               |
----->--->|======[ PADDR Bus - 8 Bits ]==================================>|               |
 PADDR    |                                                               |               |

          |                                                               |               |
----->--->|======[ PWDATA Bus - 32 Bits ]================================>|               |
 PWDATA   |                                                               |               |

          |                                                               |               |
<-----<---|======[ PRDATA Bus - 32 Bits ]=================================+               |
 PRDATA   |                                                                               |

          |                                                                               |
<-----<---|------[ PREADY Acknowledge Wire ]                                              |
 PREADY   |                                                                               |
          +-------------------------------------------------------------------------------+
```

---

## 4. Input / Output Signal Table

| Signal Name | Direction | Width | Description / Function |
| :--- | :--- | :--- | :--- |
| `PCLK` | Input | 1 bit | Master Bus Clock Line |
| `PRESETn` | Input | 1 bit | Synchronous Active-Low Reset Line |
| `PADDR[7:0]` | Input | 8 bits | 8-bit Address Bus selecting up to 256 internal register offsets |
| `PSEL` | Input | 1 bit | Slave Select indicator driven by the master interconnect |
| `PENABLE` | Input | 1 bit | APB Strobe enable line indicating the 2nd cycle (Access phase) |
| `PWRITE` | Input | 1 bit | Transfer Direction (1 = WRITE transfer, 0 = READ transfer) |
| `PWDATA[31:0]` | Input | 32 bits | 32-bit incoming parallel write payload bus from the host bridge |
| `PREADY` | Output | 1 bit | Handshake wire asserted by the slave to close current transfers |
| `PRDATA[31:0]` | Output | 32 bits | 32-bit outbound read database driven to the host master |

---

## 5. Verification Scenarios & Waveform Analysis
The design was verified using human-style master transaction tasks driven through an active **SystemVerilog Testbench** environment compiled via **Icarus Verilog 12.0** on EDA Playground.

### Key Verified Testcases:
* **Consecutive Bus Write Audits:** Forced sequential master write payloads (`32'hDEADBEEF`, `32'hCAFEBABE`) targeting offsets `8'h04` and `8'h0C`. Verified that the FSM latches to the `SETUP` phase, sets up lines, and commits bytes during the `ACCESS` phase upon receiving `PREADY`.
* **Read-Back Content Validation:** Executed read tasks to the same addresses. Verified that `PRDATA` accurately reflects the values stored in the internal array with zero cycle-slippage or timing glitches.

---

## 6. Simulation Waveforms
### APB Slave Core Simulation Waveform (`waveform.png`)
*(Include your generated EPWave plot screenshot here to showcase the transition from IDLE to SETUP to ACCESS phases alongside stable data transfer marks).*
