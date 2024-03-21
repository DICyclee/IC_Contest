
`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input clk;
input reset;
output reg [13:0] gray_addr;
output reg gray_req;
input gray_ready;
input [7:0] gray_data;
output reg [13:0] lbp_addr;
output reg lbp_valid;
output reg [7:0] lbp_data;
output reg finish;


//====================================================================

reg [1:0] cstate;
reg [1:0] nstate;

reg [7:0] buffer [0:8];

reg [1:0] x;
reg [1:0] y;

reg [6:0] i2;
reg [6:0] j2;

reg [7:0] result; 

reg a;
reg [1:0] b;
reg [2:0] c;
reg [3:0] d;
reg [4:0] e;
reg [5:0] f;
reg [6:0] g;
reg [7:0] h;

parameter read = 0;
parameter calculate_1 = 1;
parameter calculate_2 = 2;
parameter write = 3;

always@(posedge clk or posedge reset)begin
    if(reset)
        cstate <= read;
    else 
        cstate <= nstate;
end

always@(posedge clk or posedge reset)begin
    if(reset)begin
        gray_req <= 1;
        lbp_addr <= 0;
        lbp_valid <= 0;
        x <= 0;
        y <= 0;
        i2 <= 0;
        j2 <= 0;
        finish <= 0;
    end
    else begin
        case(cstate)
            read:begin
                buffer[3*y + x] <= gray_data;
                if(x == 2)begin
                    x <= 0;
                    if(y == 2)begin
                        y <= 0;
                        gray_req <= 0;
                    end
                    else
                        y <= y + 1;
                end       
                else
                    x <= x + 1;                                             
            end   
            calculate_1:begin
                if(buffer[0] >= buffer[4]) 
                    a <= 1;
                else 
                    a <= 0;

                if(buffer[1] >= buffer[4]) 
                    b <= 2;
                else 
                    b <= 0; 

                if(buffer[2] >= buffer[4]) 
                    c <= 4;
                else 
                    c <= 0;

                if(buffer[3] >= buffer[4])
                    d <= 8;
                else 
                    d <= 0;

                if(buffer[5] >= buffer[4]) 
                    e <= 16;
                else 
                    e <= 0;

                if(buffer[6] >= buffer[4])
                    f <= 32;
                else 
                    f <= 0;

                if(buffer[7] >= buffer[4])  
                    g <= 64;
                else 
                    g <= 0;

                if(buffer[8] >= buffer[4])  
                    h <= 128;
                else 
                    h <= 0;
            end
            calculate_2:begin
                lbp_valid <= 1;
                if(i2 == 127)begin
                    i2 <= 0;
                    j2 <= j2 + 1;
                end
                else
                    i2 <= i2 + 1;                
                if((i2 != 0) && (i2 != 127) && (j2 != 0) && (j2 != 127))
                    lbp_data <= a + b + c + d + e + f + g + h;  
                else 
                    lbp_data <= 0;
            end  
            write:begin                                 
                lbp_valid <= 0;
                gray_req <= 1;
                if(lbp_addr == 16383)
                    finish <= 1;
                else
                    lbp_addr <= lbp_addr + 1;
            end
        endcase 
    end
end

always@(*)begin
    case(cstate)
        read:begin
            if(x == 2 && y == 2)
                nstate = calculate_1;
            else 
                nstate = read;
        end
        calculate_1:begin
            nstate = calculate_2;           
        end
        calculate_2:begin
            nstate = write;
        end           
        write:begin
            nstate = read;           
        end   
        default:begin
            nstate = read;
        end                     
    endcase 
end

always@(*)begin
    gray_addr = 128*(y+j2-1) + (x+i2-1);                         
end
//====================================================================
endmodule