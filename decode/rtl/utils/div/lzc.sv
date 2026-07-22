// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 FuxionLab

// Leading/trailing zero counter implemented independently for VersaVLM.
module lzc #(
  parameter int unsigned WIDTH = 2,
  parameter bit          MODE  = 1'b0,
  parameter int unsigned CNT_WIDTH = $clog2(WIDTH)
) (
  input  logic [WIDTH-1:0]     in_i,
  output logic [CNT_WIDTH-1:0] cnt_o,
  output logic                 empty_o
);
  integer i;
  logic found;

  always_comb begin
    empty_o = ~(|in_i);
    cnt_o = CNT_WIDTH'(WIDTH - 1);
    found = 1'b0;

    if (MODE) begin
      for (i = WIDTH - 1; i >= 0; i = i - 1) begin
        if (!found && in_i[i]) begin
          cnt_o = CNT_WIDTH'(WIDTH - 1 - i);
          found = 1'b1;
        end
      end
    end else begin
      for (i = 0; i < WIDTH; i = i + 1) begin
        if (!found && in_i[i]) begin
          cnt_o = CNT_WIDTH'(i);
          found = 1'b1;
        end
      end
    end
  end

`ifndef SYNTHESIS
  initial begin
    if (WIDTH < 2) $error("lzc WIDTH must be at least 2");
  end
`endif
endmodule
