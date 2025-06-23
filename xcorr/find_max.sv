module find_max#(
	parameter wnd_size  = 16,
	parameter wdth_crr  = 24
)(
	input					clk,
	input					rst,
	input [wdth_crr-1:0] 	corr_in,
	input [wdth_crr-1:0]	thr_lvl,

	output	logic			osop
);
localparam cnt_wdt = $clog2(wnd_size);

logic	[cnt_wdt-1:0]	cnt_wr, cnt_rd, cnt_val;

logic	loc_val;

always @(posedge clk) begin
	if(rst) begin
		cnt_wr <= '0;
	end
	else begin
		cnt_wr <= cnt_wr + 1'd1;
	end
end



always @(posedge clk) begin
	if(rst) begin
		cnt_val <= '0;
		loc_val <= '0;
	end
	else if(cnt_val == wnd_size - 1 && loc_val) begin
		loc_val <= '0;
		cnt_val <= '0;
	end
	else if(loc_val) begin
		cnt_val <= cnt_val + 1'd1;
	end
	else if(corr_in > thr_lvl) begin
		loc_val <= '1;
	end
end

logic [wdth_crr-1:0]	local_max;


always @(posedge clk) begin
	if(rst) begin
		local_max <= '0;
		cnt_rd	  <= '0;
	end
	else if(loc_val) begin
		if(cnt_val == 0) begin
			local_max <= read_buff;
			cnt_rd	  <= cnt_wr;
		end
		else if(read_buff > local_max) begin
			local_max <= read_buff;
			cnt_rd 	  <= cnt_wr;
		end
	end
end

logic loc_sop;

always @(posedge clk) begin
	if(rst) begin
		loc_sop <= '0;
		osop	<= '0;
	end
	else if(loc_val) begin
		loc_sop <= '1;
		osop	<= '0;
	end
	else if (~loc_val & loc_sop & cnt_rd == cnt_wr) begin
		osop <= '1;
		loc_sop <= '0;
	end
	else if(loc_sop == 0) begin
		osop <= '0;
	end

end

reg	[wdth_crr-1:0]	read_buff;

always @(posedge clk) begin
	read_buff <= corr_in;
end



endmodule