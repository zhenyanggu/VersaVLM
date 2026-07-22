// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 FuxionLab

// Portable, synthesizable replacements for the foundry SRAM simulation models.
// Controls are active low. Reads are synchronous and read-first; simultaneous
// writes to the same address are intentionally unspecified.

module sram_8_1024_dp #(
  parameter ASSERT_PREFIX = "",
  parameter BITS = 8,
  parameter WORDS = 1024,
  parameter MUX = 16,
  parameter MEM_WIDTH = 128,
  parameter MEM_HEIGHT = 64,
  parameter WP_SIZE = 1,
  parameter UPM_WIDTH = 3,
  parameter UPMW_WIDTH = 2,
  parameter UPMS_WIDTH = 1
) (
`ifdef POWER_PINS
  inout VDDCE, VDDPE, VSSE,
`endif
  output logic CENYA, output logic [7:0] WENYA, output logic [9:0] AYA,
  output logic CENYB, output logic [7:0] WENYB, output logic [9:0] AYB,
  output logic GWENYA, output logic GWENYB,
  output logic [7:0] QA, output logic [7:0] QB,
  output logic [1:0] SOA, output logic [1:0] SOB,
  input logic CLKA, input logic CENA, input logic [7:0] WENA,
  input logic [9:0] AA, input logic [7:0] DA,
  input logic CLKB, input logic CENB, input logic [7:0] WENB,
  input logic [9:0] AB, input logic [7:0] DB,
  input logic [2:0] EMAA, input logic [1:0] EMAWA, input logic EMASA,
  input logic [2:0] EMAB, input logic [1:0] EMAWB, input logic EMASB,
  input logic TENA, input logic TCENA, input logic [7:0] TWENA,
  input logic [9:0] TAA, input logic [7:0] TDA,
  input logic TENB, input logic TCENB, input logic [7:0] TWENB,
  input logic [9:0] TAB, input logic [7:0] TDB,
  input logic GWENA, input logic GWENB, input logic TGWENA, input logic TGWENB,
  input logic RET1N, input logic [1:0] SIA, input logic SEA,
  input logic DFTRAMBYP, input logic [1:0] SIB, input logic SEB, input logic COLLDISN
);
  logic [7:0] mem [0:1023];
  integer ia;
  integer ib;

  always_comb begin
    CENYA = CENA; WENYA = WENA; AYA = AA; GWENYA = GWENA;
    CENYB = CENB; WENYB = WENB; AYB = AB; GWENYB = GWENB;
    SOA = 2'b00; SOB = 2'b00;
  end

  always @(posedge CLKA) begin
    if (!CENA) begin
      QA <= mem[AA];
      if (!GWENA)
        for (ia = 0; ia < 8; ia = ia + 1)
          if (!WENA[ia]) mem[AA][ia] <= DA[ia];
    end
  end

  always @(posedge CLKB) begin
    if (!CENB) begin
      QB <= mem[AB];
      if (!GWENB)
        for (ib = 0; ib < 8; ib = ib + 1)
          if (!WENB[ib]) mem[AB][ib] <= DB[ib];
    end
  end
endmodule

module sram_32_1024_dp #(
  parameter ASSERT_PREFIX = "",
  parameter BITS = 32,
  parameter WORDS = 1024,
  parameter MUX = 16,
  parameter MEM_WIDTH = 512,
  parameter MEM_HEIGHT = 64,
  parameter WP_SIZE = 1,
  parameter UPM_WIDTH = 3,
  parameter UPMW_WIDTH = 2,
  parameter UPMS_WIDTH = 1
) (
`ifdef POWER_PINS
  inout VDDCE, VDDPE, VSSE,
`endif
  output logic CENYA, output logic [31:0] WENYA, output logic [9:0] AYA,
  output logic CENYB, output logic [31:0] WENYB, output logic [9:0] AYB,
  output logic GWENYA, output logic GWENYB,
  output logic [31:0] QA, output logic [31:0] QB,
  output logic [1:0] SOA, output logic [1:0] SOB,
  input logic CLKA, input logic CENA, input logic [31:0] WENA,
  input logic [9:0] AA, input logic [31:0] DA,
  input logic CLKB, input logic CENB, input logic [31:0] WENB,
  input logic [9:0] AB, input logic [31:0] DB,
  input logic [2:0] EMAA, input logic [1:0] EMAWA, input logic EMASA,
  input logic [2:0] EMAB, input logic [1:0] EMAWB, input logic EMASB,
  input logic TENA, input logic TCENA, input logic [31:0] TWENA,
  input logic [9:0] TAA, input logic [31:0] TDA,
  input logic TENB, input logic TCENB, input logic [31:0] TWENB,
  input logic [9:0] TAB, input logic [31:0] TDB,
  input logic GWENA, input logic GWENB, input logic TGWENA, input logic TGWENB,
  input logic RET1N, input logic [1:0] SIA, input logic SEA,
  input logic DFTRAMBYP, input logic [1:0] SIB, input logic SEB, input logic COLLDISN
);
  logic [31:0] mem [0:1023];
  integer ia;
  integer ib;

  always_comb begin
    CENYA = CENA; WENYA = WENA; AYA = AA; GWENYA = GWENA;
    CENYB = CENB; WENYB = WENB; AYB = AB; GWENYB = GWENB;
    SOA = 2'b00; SOB = 2'b00;
  end

  always @(posedge CLKA) begin
    if (!CENA) begin
      QA <= mem[AA];
      if (!GWENA)
        for (ia = 0; ia < 32; ia = ia + 1)
          if (!WENA[ia]) mem[AA][ia] <= DA[ia];
    end
  end

  always @(posedge CLKB) begin
    if (!CENB) begin
      QB <= mem[AB];
      if (!GWENB)
        for (ib = 0; ib < 32; ib = ib + 1)
          if (!WENB[ib]) mem[AB][ib] <= DB[ib];
    end
  end
endmodule

module sram_128_1024_dp #(
  parameter ASSERT_PREFIX = "",
  parameter BITS = 128,
  parameter WORDS = 1024,
  parameter MUX = 4,
  parameter MEM_WIDTH = 512,
  parameter MEM_HEIGHT = 256,
  parameter WP_SIZE = 1,
  parameter UPM_WIDTH = 3,
  parameter UPMW_WIDTH = 2,
  parameter UPMS_WIDTH = 1
) (
`ifdef POWER_PINS
  inout VDDCE, VDDPE, VSSE,
`endif
  output logic CENYA, output logic [127:0] WENYA, output logic [9:0] AYA,
  output logic CENYB, output logic [127:0] WENYB, output logic [9:0] AYB,
  output logic GWENYA, output logic GWENYB,
  output logic [127:0] QA, output logic [127:0] QB,
  output logic [1:0] SOA, output logic [1:0] SOB,
  input logic CLKA, input logic CENA, input logic [127:0] WENA,
  input logic [9:0] AA, input logic [127:0] DA,
  input logic CLKB, input logic CENB, input logic [127:0] WENB,
  input logic [9:0] AB, input logic [127:0] DB,
  input logic [2:0] EMAA, input logic [1:0] EMAWA, input logic EMASA,
  input logic [2:0] EMAB, input logic [1:0] EMAWB, input logic EMASB,
  input logic TENA, input logic TCENA, input logic [127:0] TWENA,
  input logic [9:0] TAA, input logic [127:0] TDA,
  input logic TENB, input logic TCENB, input logic [127:0] TWENB,
  input logic [9:0] TAB, input logic [127:0] TDB,
  input logic GWENA, input logic GWENB, input logic TGWENA, input logic TGWENB,
  input logic RET1N, input logic [1:0] SIA, input logic SEA,
  input logic DFTRAMBYP, input logic [1:0] SIB, input logic SEB, input logic COLLDISN
);
  logic [127:0] mem [0:1023];
  integer ia;
  integer ib;

  always_comb begin
    CENYA = CENA; WENYA = WENA; AYA = AA; GWENYA = GWENA;
    CENYB = CENB; WENYB = WENB; AYB = AB; GWENYB = GWENB;
    SOA = 2'b00; SOB = 2'b00;
  end

  always @(posedge CLKA) begin
    if (!CENA) begin
      QA <= mem[AA];
      if (!GWENA)
        for (ia = 0; ia < 128; ia = ia + 1)
          if (!WENA[ia]) mem[AA][ia] <= DA[ia];
    end
  end

  always @(posedge CLKB) begin
    if (!CENB) begin
      QB <= mem[AB];
      if (!GWENB)
        for (ib = 0; ib < 128; ib = ib + 1)
          if (!WENB[ib]) mem[AB][ib] <= DB[ib];
    end
  end
endmodule
