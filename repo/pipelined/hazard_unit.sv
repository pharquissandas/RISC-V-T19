module hazard_unit (
    input  logic [4:0] Rs1D,
    input  logic [4:0] Rs2D,
    input  logic       MemReadE,      // load in EX stage
    input  logic [4:0] RdE,           // destination of load
    input  logic       BranchTakenE,  // branch resolved in EX
    input  logic [1:0] JumpE,         // JAL / JALR
    input  logic       JALRE,         // alternate JALR flag if needed

    output logic PCWrite,
    output logic IFIDWrite,
    output logic FlushE,
    output logic FlushD
);

    logic load_use_hazard;
    logic control_hazard;

    // Load-use hazard:
    // If instruction in EX is a load (MemReadE = 1)
    // and ID uses its result => stall
    assign load_use_hazard = MemReadE && ((RdE == Rs1D) || (RdE == Rs2D));

    // Control hazard:
    // BranchTakenE = branch taken in EX
    // JumpE != 0   = JAL or JALR in EX
    assign control_hazard = BranchTakenE || (JumpE != 2'b00) || JALRE;

    // Outputs
    // Stalls on load-use
    assign PCWrite   = ~load_use_hazard;
    assign IFIDWrite = ~load_use_hazard;

    // Flush EX for both:
    //   - load-use hazard (insert bubble)
    //   - control hazard (flush on branch/jump)
    assign FlushE = load_use_hazard;
    assign FlushD = control_hazard;
endmodule
