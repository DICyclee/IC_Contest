module LCD_CTRL(clk, reset, IROM_Q, cmd, cmd_valid, IROM_EN, IROM_A, IRB_RW, IRB_D, IRB_A, busy, done);
input clk;
input reset;
input [7:0] IROM_Q;
input [2:0] cmd;
input cmd_valid;
output reg IROM_EN;
output reg [5:0] IROM_A;
output reg IRB_RW;
output reg [7:0] IRB_D;
output reg [5:0] IRB_A;
output reg busy;
output reg done;

reg [3:0] cstate;
reg [3:0] nstate;

reg [7:0] buffer [0:63];

reg [2:0] x;
reg [2:0] y;

wire [2:0] x_1;
wire [2:0] y_1;

reg drive;

parameter read = 0;
parameter idle = 1;
parameter Write = 2;
parameter Shift_Up = 3;
parameter Shift_Down = 4;
parameter Shift_Left = 5;
parameter Shift_Right = 6;
parameter Average = 7;
parameter Mirror_X = 8;
parameter Mirror_Y = 9;

always@(posedge clk or posedge reset)begin
    if(reset)
        cstate <= read;
    else
        cstate <= nstate;
end

always@(posedge clk or posedge reset)begin
    if(reset)begin
        IROM_A <= 0;
        IROM_EN <= 0;          
        IRB_RW <= 1;
        IRB_A <= 0;
        busy <= 1;
        done <= 0;
        x <= 3;
        y <= 3;
        drive <= 0;
    end
    else begin
        case(cstate)
            read:begin  
                drive <= 1;
                if(drive)begin
                    buffer[IROM_A - 1] <= IROM_Q;
                end
                if(IROM_A == 63)begin
                    IROM_A <= 63;
                    drive <= 0;
                end
                else
                    IROM_A <= IROM_A + 1;      
                if((drive == 0) && (IROM_A == 63))begin
                    buffer[IROM_A] <= IROM_Q;
                    IROM_A <= 0;
                    IROM_EN <= 1;
                    busy <= 0;                    
                end

            end  
            idle:begin
                if(cmd_valid)
                    busy <= 1;
                else
                    busy <= 0;
            end
            Write:begin
                IRB_RW <= 0;
                if(!IRB_RW)begin
                    IRB_D <= buffer[IRB_A + 1];
                    if(IRB_A == 63)begin
                        IRB_A <= 0;
                        done <= 1;
                    end
                    else
                        IRB_A <= IRB_A + 1;
                end
                else
                    IRB_D <= buffer[IRB_A];
            end
            Shift_Up:begin
                if(y == 0)
                    y <= y;
                else 
                    y <= y - 1;
            end
            Shift_Down:begin
                if(y == 6)
                    y <= y;
                else 
                    y <= y + 1;                            
            end
            Shift_Left:begin
                if(x == 0)
                    x <= x;
                else 
                    x <= x - 1;                              
            end
            Shift_Right:begin
                if(x == 6)
                    x <= x;
                else                                
                    x <= x + 1;                           
            end
            Average:begin
                buffer[{y, x}] <= (buffer[{y, x}] + buffer[{y, x_1}] + buffer[{y_1, x}] + buffer[{y_1, x_1}]) / 4;
                buffer[{y, x_1}] <= (buffer[{y, x}] + buffer[{y, x_1}] + buffer[{y_1, x}] + buffer[{y_1, x_1}]) / 4;
                buffer[{y_1, x}] <= (buffer[{y, x}] + buffer[{y, x_1}] + buffer[{y_1, x}] + buffer[{y_1, x_1}]) / 4;
                buffer[{y_1, x_1}] <= (buffer[{y, x}] + buffer[{y, x_1}] + buffer[{y_1, x}] + buffer[{y_1, x_1}]) / 4;
            end
            Mirror_X:begin
                buffer[{y, x}] <= buffer[{y_1, x}];
                buffer[{y, x_1}] <= buffer[{y_1, x_1}];
                buffer[{y_1, x}] <= buffer[{y, x}];
                buffer[{y_1, x_1}] <= buffer[{y, x_1}];
            end  
            Mirror_Y:begin
                buffer[{y, x}] <= buffer[{y, x_1}];
                buffer[{y, x_1}] <= buffer[{y, x}];
                buffer[{y_1, x}] <= buffer[{y_1, x_1}];
                buffer[{y_1, x_1}] <= buffer[{y_1, x}];
            end                                                      
        endcase
    end
end

always@(*)begin
    case(cstate)
        read:begin
            if((drive == 0) && (IROM_A == 63))
                nstate = idle;
            else
                nstate = read;              
        end   
        idle:begin
            if(cmd_valid)begin
                case(cmd)
                    0:begin
                        nstate = Write; 
                    end
                    1:begin
                        nstate = Shift_Up;
                    end
                    2:begin
                        nstate = Shift_Down;                            
                    end
                    3:begin
                        nstate = Shift_Left;                            
                    end
                    4:begin
                        nstate = Shift_Right;                            
                    end
                    5:begin
                        nstate = Average;                            
                    end
                    6:begin
                        nstate = Mirror_X;                            
                    end  
                    7:begin
                        nstate = Mirror_Y;                            
                    end                                                  
                endcase                    
            end
            else
                nstate = idle;
        end
        Write:begin
            if(IRB_A == 63)
                nstate = idle;
            else
                nstate = Write;             
        end
        Shift_Up:begin
            nstate = idle;            
        end
        Shift_Down:begin  
            nstate = idle;                                    
        end
        Shift_Left:begin    
            nstate = idle;                                    
        end
        Shift_Right:begin          
            nstate = idle;                              
        end
        Average:begin
            nstate = idle;              
        end
        Mirror_X:begin
            nstate = idle;              
        end  
        Mirror_Y:begin
            nstate = idle;              
        end           
        default:begin
            nstate = read;
        end         
    endcase
end

assign x_1 = x + 1;
assign y_1 = y + 1;

// always@(*)begin
//     x_1 = x + 1;
//     y_1 = y + 1;
// end

endmodule