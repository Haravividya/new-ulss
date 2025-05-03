////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class zero_packet_count_sequence extends uvm_sequence#(ulss_tx);

  // Factory registration
  `uvm_object_utils(zero_packet_count_sequence)

  // Creating sequence item handle
  ulss_tx tx;

  int scenario;

  // Constructor
  function new(string name="zero_packet_count_sequence");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), "zero_packet_count_sequence: inside body", UVM_LOW);
    
    // Create the transaction
    tx = ulss_tx::type_id::create("tx");
    
    
    // De-assert reset and configure OUT_STREAM_2_REG
    `uvm_do_with(tx, { 
      tx.rate_limiter_16to4_rstn == 1'b1;
      tx.sch_reg_wr_en   == 1'b1;
      tx.sch_reg_wr_addr == 5'd3; // OUT_STREAM_3_REG
      tx.sch_reg_wr_data == 64'h0000_0000_0000_2000; // Map in_stream_13 to out_stream_3
    });
    
    `uvm_info(get_type_name(), $sformatf("OUT_STREAM_3_REG=0x%0h", tx.sch_reg_wr_data), UVM_LOW);
    
    // Wait for register write to complete
    repeat(10) #10;
    
    // Configure IN_STREAM_13_REG
    `uvm_do_with(tx, {
      tx.rate_limiter_16to4_rstn == 1'b1;
      tx.sch_reg_wr_en   == 1'b1;
      tx.sch_reg_wr_addr == 5'd17; // IN_STREAM_13_REG (4 + 9 = 13)
      tx.sch_reg_wr_data[14:0]  == 15'd3;  // 3 tokens wait
      tx.sch_reg_wr_data[63:15] == 49'd0;  // 1 packet
    });
    
    `uvm_info(get_type_name(), $sformatf("IN_STREAM_13_REG=0x%0h", tx.sch_reg_wr_data), UVM_LOW);
    
      // Wait for stable state
    repeat(15) #10;
    
    // SOP cycle - Start of Packet on stream 13
    `uvm_do_with(tx, {
      tx.rate_limiter_16to4_rstn == 1'b1;
      tx.sch_reg_wr_en == 1'b0;
      
      // Set empty flags for all streams - only stream 13 is not empty
      tx.pck_str_empty_0 == 1'b1;
      tx.pck_str_empty_1 == 1'b1;
      tx.pck_str_empty_2 == 1'b1;
      tx.pck_str_empty_3 == 1'b1;
      tx.pck_str_empty_4 == 1'b1;
      tx.pck_str_empty_5 == 1'b1;
      tx.pck_str_empty_6 == 1'b1;
      tx.pck_str_empty_7 == 1'b1;
      tx.pck_str_empty_8 == 1'b1;
      tx.pck_str_empty_9 == 1'b1; // empty
      tx.pck_str_empty_10 == 1'b1;
      tx.pck_str_empty_11 == 1'b1;
      tx.pck_str_empty_12 == 1'b1;
      tx.pck_str_empty_13 == 1'b0;
      tx.pck_str_empty_14 == 1'b1;
      tx.pck_str_empty_15 == 1'b1;
      
      // Start of packet
      tx.in_sop_13 == 1'b1;
      //tx.in_stream_13 == 64'h1111_1111_1111_1111;
       tx.in_stream_13 inside {[64'h0000000000000000 : 64'hFFFFFFFFFFFFFFFF],
                             [64'h8000000000000000 : 64'h7FFFFFFFFFFFFFFF]}; 
      tx.in_eop_13 == 1'b1; 
    });
    
    `uvm_info(get_type_name(), $sformatf("Sent SOP on stream 13 with data=0x%0h", tx.in_stream_9), UVM_LOW);
     repeat(15) #10;
    

    // Clear the packet signals
    `uvm_do_with(tx, {
      tx.rate_limiter_16to4_rstn == 1'b1;
      tx.sch_reg_wr_en == 1'b0;
      
      // Set all streams to empty
      tx.pck_str_empty_0 == 1'b1;
      tx.pck_str_empty_1 == 1'b1;
      tx.pck_str_empty_2 == 1'b1;
      tx.pck_str_empty_3 == 1'b1;
      tx.pck_str_empty_4 == 1'b1;
      tx.pck_str_empty_5 == 1'b1;
      tx.pck_str_empty_6 == 1'b1;
      tx.pck_str_empty_7 == 1'b1;
      tx.pck_str_empty_8 == 1'b1;
      tx.pck_str_empty_9 == 1'b1; // Empty again
      tx.pck_str_empty_10 == 1'b1;
      tx.pck_str_empty_11 == 1'b1;
      tx.pck_str_empty_12 == 1'b1;
      tx.pck_str_empty_13 == 1'b1;
      tx.pck_str_empty_14 == 1'b1;
      tx.pck_str_empty_15 == 1'b1;
      
      // Clear all signals for stream 9
      tx.in_sop_13 == 1'b0;
      tx.in_stream_13 == 64'h0;
      tx.in_eop_13 == 1'b0;
    });
    
    // Allow time for grant signals to stabilize
    repeat(15) #10;
    
    // Final drain/clear state to ensure correct completion
    `uvm_do_with(tx, {
      tx.rate_limiter_16to4_rstn == 1'b1;
      tx.sch_reg_wr_en == 1'b0;
      tx.pck_str_empty_13 == 1'b1;
      tx.in_sop_13 == 1'b0;
      tx.in_stream_13 == 64'h0;
      tx.in_eop_13 == 1'b0;
    });
    
    // Final wait to ensure completion
    repeat(10) #10;
    
    `uvm_info(get_type_name(), "zero_packet_count_sequence completed successfully", UVM_LOW);
  endtask
endclass  



/////////////////////////////////////////////////////////////////////////////////////////////////////



