// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

module mprj2_logic_high (
`ifdef USE_POWER_PINS
    inout	   vccd2,
    inout	   vssd2,
`endif
    output         HI
);
`ifndef CARAVEL_FPGA
sky130_fd_sc_hd__conb_1 inst (
`ifdef USE_POWER_PINS
                .VPWR(vccd2),
                .VGND(vssd2),
                .VPB(vccd2),
                .VNB(vssd2),
`endif
                .HI(HI),
                .LO()
        );
`else
    assign HI = ~0;
`endif
endmodule
