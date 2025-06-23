module control(
		input			clk,
		input			rst,
		input			sof_tx,
		input			sof_rx,
  		input 	[2:0]	index_M,
		input 	[3:0]	index_SS,

		output 	[2:0]	oindex_M_rx,
		output 	[3:0]	oindex_SS_rx,
  		output 	[2:0]	oindex_M_tx,
		output 	[3:0]	oindex_SS_tx,

		output logic	del_rst
);


reg [3:0] local_ss_rx, local_ss_tx;

 reg [2:0] local_m_rx, local_m_tx;


assign oindex_M_rx = local_m_rx;
assign oindex_SS_rx = local_ss_rx;

assign oindex_M_tx = local_m_tx;
assign oindex_SS_tx = local_ss_tx;

initial begin
	local_ss_rx <= 4'd1;
	local_ss_tx <= 4'd1;
	local_m_rx  <= 3'd1;
	local_m_tx  <= 3'd1;
end


always @(posedge clk) begin
	if(sof_tx) begin
		local_m_tx  <= index_M;
		local_ss_tx <= index_SS;
	end
end

always @(posedge clk) begin
	if(sof_rx) begin
		local_m_rx  <= index_M;
		local_ss_rx <= index_SS;
	end
end

reg [6:0] 	count_rst;


always @(posedge clk) begin
	if(rst)
		count_rst <= '0;
	else if(count_rst < 7'd100)
		count_rst <= count_rst + 1'd1;
end

always @(posedge clk) begin
	if(rst)
		del_rst <= '0;
	else if(count_rst == 7'd100)
		del_rst <= '1;

end


endmodule