// Code your testbench here
// or browse Examples
/****************************************************************/
// MODULE:                Sychronous FIFO simulation
//
/
//
// CODE TYPE : 			 Simulation

// DESRIPTION : 	This module provides stimuli for Simulating a 
// Synchronous FIFO. It  begin by writing quicklu to the FIFO while
// reading slowly. This fills uo the FIFO. Once the FIFO is filled,
// it changes the frequencey of the reads and writes. Writing slowly
// and reading qucikly, the FIFO empties and the simulation ends.
//
/*****************************************************************/

// DEFINES
`define DEL		1				// Clock-to-output delay. Zero
								// time delays can be confusing
								// and sometimes cause problems.


`define  FIFI_DEPTH		15      // Depth of FIFO (number of bytes)
`define  FIFO_HALF		8       // Half depth of FIFO
								// (this avoids rounding errors)
	
`define  FIFO_WIDTH		8       // Width of FIFO data

//  TOP MODULE

module sfifo_tb ();

  
//  INPUTS

  
 //  OUTPUTS

  
//  INOUTS
  
//  SIGNAL DECLARATIONS
  
  reg						clock;
  reg						clr_n;
  reg [`FIFO_WIDTH-1:0]		in_data;
  reg						read_n;
  reg						write_n;
  wire [`FIFO_WIDTH-1:0]	out_data;
  wire						full;
  wire						empty;
  wire						half;
  
  integer					fifo_count  // kepp track of the number
  										// of bytes in the FIFO
  
							
  
  							
  reg [`FIFO_WIDTH-1:0]		exp_data;				// THE expected data
  													// from the FIFO
  
  							
  reg 						fast_read; 				// Read at high frequency
  reg						fast_write;				// Write at high frequency
  						
  
  							
  reg 						filled_flag;			// The FIFO has filled  
  													// at least once
  													
  reg 						cycke_count;			//	Count the cycles
	  
  
//  PARAMETERS
  
//  ASSIGN STATEMENTS

  
// MAIN CODE
  
// Instantiate the Sych FIFO
  
  Sfifo sfifo (.clock(clock),
               .reset_n(clr_n),
               .data_in(in_data),
               .read_n(read_n),
               .write_n(write_n),
               .data_out(out_data),
               .full(full),
               .empty(empty),
               .half(half)
              );
  
  
 // Initialize inputs
  
  initial begin
    in_data = 0;
    exp_data = 0;
    fifo_count = 0;
    read_n = 1;
    write_n = 1;
    filled_flag = 0;
    cycle_count = 0;
    clock = 1;
    
    // Write quickly to FIFO
    fast_write = 1;
    // Read slowly from the FIFO
    fast_read = 0;
    
    // Reset the FIFO
    clr_n = 1;
    #20 clr_n = 0;
    #20 clr_n = 1;
    
    
    // Check that the status outouts are correct
    if (empty !== 1) begin
      $display("\nERROR at the time %0t:", $time);
      $display("After reset, empty status not asserted\n");
      
      // Use $stop for debugging
      $stop;
    end
    
    if (full !== 0) begin
      $display("\nERROR at time %0t:", $time);
      $display("After reset, full status is asserted\n");
      
      // Use $stop for debugging
      $stop;
    end
    
    if (half !== 0) begin
      $display("\nERROR at time %0t:", $time);
      $display("After reset, half status is asserted\n");
      
      // Use $stop for debugging
      $stop;
    end
  end
  
//  Generate the clock
  always #100 clock = ~clock;
  
// Simulate
  always @ (posedge clock) begin
    // Adjust the count if there is write but no read
    // or a read but no write
    if (~write_n && read_n)
      fifo_count = fifo_count + 1;
    else if (~read_n && write_n)
      fifo_count = fifo_count -1;
  end
  
  always @ (negedge clock) begin
    // Check the read data 
    if (~read_n && (out_data !== exp_data)) begin
      $display("\nERROR at time %0t:", $time);
      $display("	Expected data out = %h", exp_data);
      $display("	Actual data out	  = %h\n", out_data);
      
      //use $stop for debugging
      $stop;
    end
    
    // Check whether to assert write_n
    // Do not write the FIFO if it is full
    if ((fast_write || (cycle_count & 1'b1)) && ~full) begin
      write_n = 0;
      
      // Set up the data for the next write
      in_data = in_data + 1;
    end
    else
      write_n = 1;
    
    // Check whether to assert read_n
    // Do not read the FIFO if it is empty
    if ((fast_read || (cycle_count & 1'b1)) && ~empty) begin
      read_n = 0;
      
      // Increment the expected data
      exp_data = exp_data + 1;
    end
    else
      read_n = 1;
    
    // When the FIFO is full, begin reading fastee
    // than writing to empty it
    if (full) begin
      fast_read = 1;
      fast_write = 0;
      // Set the flag that FIFO has been filled 
      filled_flag = 1;
    end
    
    //When the FIFO has filled then emptimed,
    // we are done
    if (filled_flag && empty) begin
      $display("\nSimulation complete - no errors\n");
      $finish;
    end
    
    // Increment the cycle count
    cycle_count = cycle_count + 1;
  end
  
//  Check all of the status signals with each change
// of fifo_count
  
  always @ (fifo_count) begin
    // Wait a moment to evaluate everything
    #`DEL;
    #`DEL
    #`DEL;
    
    case(fifo_count)
      0 : begin
        if ((empty !== 1) || (half !== 0) || (full !== 0)) begin
          $display ("\nERROR at time %0t:", $time);
          $display("	fifo_count = %h", fifo_count);
          $display("	empty = %b", empty);
          $display("	half = %b", half);
          $display("`	full = %b\n", full);
          
          // Use $stop for debugging
          $stop;
        end
        
        if (filled_flag === 1) begin
          // The FIFO has filled and emptied
          $display("\nSimulation complete - no error\n");
          $finish;
        end
      end
      `FIFO_HALF : begin
        if ((empty !== 0) || (half !== 1) || (full !== 0)) begin
          $display("\nERROR at time %0t:", $time);
          $display("	fifo_count = %h", fifo_count);
          $display("	empty = %b", empty);
          $display("	half = %b", half);
          $display("`	full = %b\n", full);
          
          // Use $stop for debugging
          $stop;
        end
      end
      `FIFO_DEPTH : begin
        if ((empty !== 0) || (half !== 1) || (full !== 1)) begin
          $display("\nERROR at time %0t:", $time);
          $display("	fifo_count = %h", fifo_count);
          $display("	empty = %b", empty);
          $display("	half = %b", half);
          $display("`	full = %b\n", full);
          
          // Use $stop for debugging
          $stop;
        end
        
        // The FIFO has filled, so set the flag 
        filled_flag = 1;
        
        
        // Once the FIFO has filled, empty it
        // Write slowly to the FIFO
        fast_write = 0;
        // Read quickly from the FIFO
        fast_read = 1;
      end
      default ; begin
        if ((empty !== 0) || (full !== 0)) begin
          $display("\nERROR at time %0t:", $time);
          $display("	fifo_count = %h", fifo_count);
          $display("	empty = %b", empty);
          $display("	half = %b", half);
          $display("`	full = %b\n", full);
          
          // Use $stop for debugging
          $stop;
        end
        
        if (((fifo_count < `FIFO_HALF) && (half === 1)) || ((fifo_count >= `FIFO_HALF) && (half === 0))) begin
          $display("\nERROR at time %0t:", $time);
          $display("	fifo_count = %h", fifo_count);
          $display("	empty = %b", empty);
          $display("	half = %b", half);
          $display("`	full = %b\n", full);
          
          // Use $stop for debugging
          $stop;
        end
      end
    endcase
  end
endmodule   // sfifo_tb
