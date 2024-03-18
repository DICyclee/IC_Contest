module JAM (CLK, RST, W, J, Cost, MatchCount, MinCost, Valid);

input CLK;
input RST;
output reg [2:0] W;
output reg [2:0] J;
input [6:0] Cost;
output reg [3:0] MatchCount;
output reg [9:0] MinCost;
output reg Valid;

reg [2:0] cstate; 
reg [2:0] nstate;

reg [6:0] array [0:7];
reg [3:0] i;
reg [1:0] j;
reg [2:0] f;
reg [9:0] cost_reg;

parameter load_cal = 0;
parameter find = 1;
parameter sub = 2;
parameter reverse = 3;

always@(posedge CLK or posedge RST)begin
	if(RST)
		cstate <= load_cal;
	else
		cstate <= nstate; 
end

always@(posedge CLK or posedge RST)begin
	if(RST)begin
        array[0] <= 0;
        array[1] <= 1;
        array[2] <= 2;
        array[3] <= 3;      
        array[4] <= 4;
        array[5] <= 5;
        array[6] <= 6;
        array[7] <= 7;      
        W <= 0;
        J <= 0;            
        cost_reg <= 0;   
        i <= 1;
        j <= 0;   
        MinCost <= 1017;
	end			
	else begin
		case(cstate) 
            load_cal:begin
                W <= i;
                J <= array[i];
                if(i > 1)
                    cost_reg <= cost_reg + Cost;
                else
                    cost_reg <= 0;
                if(i == 7)begin
                    i <= i;
                    if(j == 2)begin
                        i <= 0;
                        j <= 0;
                    end
                    else
                        j <= j + 1;
                end
                else
                    i <= i + 1;                     
			end
            find:begin
                i <= f;
            end
            sub:begin
                case(i)
                    6:begin
                        array[7] <= array[6];
                        array[6] <= array[7];            
                    end
                    5:begin
                        if(array[7] > array[5])begin
                            array[7] <= array[5];
                            array[5] <= array[7];  
                        end
                        else begin
                            array[6] <= array[5];
                            array[5] <= array[6];                  
                        end
                    end
                    4:begin
                        if(array[7] > array[4])begin
                            array[7] <= array[4];
                            array[4] <= array[7];  
                        end
                        else if(array[6] > array[4])begin
                            array[6] <= array[4];
                            array[4] <= array[6];                  
                        end            
                        else begin
                            array[5] <= array[4];
                            array[4] <= array[5];                       
                        end
                    end
                    3:begin
                        if(array[7] > array[3])begin
                            array[7] <= array[3];
                            array[3] <= array[7];  
                        end
                        else if(array[6] > array[3])begin
                            array[6] <= array[3];
                            array[3] <= array[6];                  
                        end            
                        else if(array[5] > array[3])begin
                            array[5] <= array[3];
                            array[3] <= array[5];                       
                        end            
                        else begin
                            array[4] <= array[3];
                            array[3] <= array[4];                       
                        end            
                    end
                    2:begin
                        if(array[7] > array[2])begin
                            array[7] <= array[2];
                            array[2] <= array[7];  
                        end
                        else if(array[6] > array[2])begin
                            array[6] <= array[2];
                            array[2] <= array[6];                  
                        end            
                        else if(array[5] > array[2])begin
                            array[5] <= array[2];
                            array[2] <= array[5];                       
                        end            
                        else if(array[4] > array[2])begin
                            array[4] <= array[2];
                            array[2] <= array[4];                       
                        end             
                        else begin
                            array[3] <= array[2];
                            array[2] <= array[3];                       
                        end                 
                    end
                    1:begin
                        if(array[7] > array[1])begin
                            array[7] <= array[1];
                            array[1] <= array[7];  
                        end
                        else if(array[6] > array[1])begin
                            array[6] <= array[1];
                            array[1] <= array[6];                  
                        end            
                        else if(array[5] > array[1])begin
                            array[5] <= array[1];
                            array[1] <= array[5];                       
                        end            
                        else if(array[4] > array[1])begin
                            array[4] <= array[1];
                            array[1] <= array[4];                       
                        end             
                        else if(array[3] > array[1])begin
                            array[3] <= array[1];
                            array[1] <= array[3];                       
                        end              
                        else begin
                            array[2] <= array[1];
                            array[1] <= array[2];                       
                        end                  
                    end
                    0:begin
                        if(array[7] > array[0])begin
                            array[7] <= array[0];
                            array[0] <= array[7];  
                        end
                        else if(array[6] > array[0])begin
                            array[6] <= array[0];
                            array[0] <= array[6];                  
                        end            
                        else if(array[5] > array[0])begin
                            array[5] <= array[0];
                            array[0] <= array[5];                       
                        end            
                        else if(array[4] > array[0])begin
                            array[4] <= array[0];
                            array[0] <= array[4];                       
                        end             
                        else if(array[3] > array[0])begin
                            array[3] <= array[0];
                            array[0] <= array[3];                       
                        end              
                        else if(array[2] > array[0])begin
                            array[2] <= array[0];
                            array[0] <= array[2];                       
                        end       
                        else begin
                            array[1] <= array[0];
                            array[0] <= array[1];                       
                        end                        
                    end                                                
                endcase                         
            end
			reverse:begin
                W <= 0;
                J <= array[0];
                i <= 1;
                j <= 0;                    
                if(cost_reg < MinCost)begin
                    MinCost <= cost_reg;
                    MatchCount <= 1;
                end
                else if(cost_reg == MinCost)begin
                    MinCost <= MinCost;
                    MatchCount <= MatchCount + 1;
                end
                else begin
                    MinCost <= MinCost;
                    MatchCount <= MatchCount;
                end                   
                case(i)
                    6:begin
                        array[0] <= array[0]; 
                        array[1] <= array[1]; 
                        array[2] <= array[2];  
                        array[3] <= array[3]; 
                        array[4] <= array[4]; 
                        array[5] <= array[5];  
                        array[6] <= array[6]; 
                        array[7] <= array[7];               
                    end
                    5:begin
                        array[0] <= array[0]; 
                        array[1] <= array[1]; 
                        array[2] <= array[2];  
                        array[3] <= array[3]; 
                        array[4] <= array[4]; 
                        array[5] <= array[5];  
                        array[6] <= array[7]; 
                        array[7] <= array[6];                                                     
                    end
                    4:begin
                        array[0] <= array[0]; 
                        array[1] <= array[1]; 
                        array[2] <= array[2];  
                        array[3] <= array[3]; 
                        array[4] <= array[4]; 
                        array[5] <= array[7];  
                        array[6] <= array[6]; 
                        array[7] <= array[5];                                                                                  
                    end
                    3:begin
                        array[0] <= array[0]; 
                        array[1] <= array[1]; 
                        array[2] <= array[2];  
                        array[3] <= array[3]; 
                        array[4] <= array[7]; 
                        array[5] <= array[6];  
                        array[6] <= array[5]; 
                        array[7] <= array[4];                                                                                      
                    end
                    2:begin
                        array[0] <= array[0]; 
                        array[1] <= array[1]; 
                        array[2] <= array[2];  
                        array[3] <= array[7]; 
                        array[4] <= array[6]; 
                        array[5] <= array[5];  
                        array[6] <= array[4]; 
                        array[7] <= array[3];                                                                                   
                    end
                    1:begin
                        array[0] <= array[0]; 
                        array[1] <= array[1]; 
                        array[2] <= array[7];  
                        array[3] <= array[6]; 
                        array[4] <= array[5]; 
                        array[5] <= array[4];  
                        array[6] <= array[3]; 
                        array[7] <= array[2];                                                                    
                    end
                    0:begin
                        array[0] <= array[0]; 
                        array[1] <= array[7]; 
                        array[2] <= array[6];  
                        array[3] <= array[5]; 
                        array[4] <= array[4]; 
                        array[5] <= array[3];  
                        array[6] <= array[2]; 
                        array[7] <= array[1];                                                                       
                    end                                                                                                                                           
                endcase    	                                                                                             
			end   
		endcase
	end
end

always@(*)begin
    case(cstate)
        load_cal:begin
            if(j == 2)
                nstate = find;
            else
                nstate = load_cal;                            	       
        end
        find:begin
            nstate = sub;
        end
        sub:begin
            nstate = reverse;
        end
        reverse:begin          
            nstate = load_cal;                                    
        end   
        default:begin
            nstate = load_cal; 
        end
    endcase    
end

always@(*)begin
    f = 0;
    Valid = 0;
    if(array[7] > array[6])
        f = 6;
    else if(array[6] > array[5])
        f = 5;
    else if(array[5] > array[4])
        f = 4;
    else if(array[4] > array[3])
        f = 3;
    else if(array[3] > array[2])
        f = 2;
    else if(array[2] > array[1])
        f = 1;  
    else if(array[1] > array[0])
        f = 0;       
    else
        Valid = 1;          
end

endmodule