class ulss_monitor extends uvm_monitor;

    // Factory registration
    `uvm_component_utils(ulss_monitor)
     virtual ulss_interface vif;

    // Analysis port to send transactions to the scoreboard
     uvm_analysis_port #(ulss_tx) analysis_port;

    // Constructor
    function new(string name = "ulss_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual ulss_interface)::get(this, "*", "ulss_interface", vif)) begin
            `uvm_fatal(get_full_name(), "Error while getting read interface from top monitor")
        end
        analysis_port = new("analysis_port", this); 
    endfunction

    // Run phase (Captures transactions)
    task run_phase(uvm_phase phase);
        super.run_phase(phase);

    endtask

endclass

