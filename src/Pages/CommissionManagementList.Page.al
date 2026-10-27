page 50345 "Commission Management"                                                                                                        
    {                                                                                                                                         
        PageType = List;                                                                                                                      
        ApplicationArea = All;                                                                                                                
        UsageCategory = Lists;                                                                                                                
        SourceTable = "Commission Management";                                                                                                
        Caption = 'Commission Management';                                                                                                    
        Editable = true;                                                                                                                      
                                                                                                                                              
        layout                                                                                                                                
        {                                                                                                                                     
            area(content)                                                                                                                     
            {                                                                                                                                 
                repeater(General)                                                                                                             
                {                                                                                                                             
                    field("Code"; Rec."Code")                                                                                                 
                    {                                                                                                                         
                        ApplicationArea = All;                                                                                                
                        ToolTip = 'Specifies the commission code.';                                                                           
                    }                                                                                                                         
                    field(Description; Rec.Description)                                                                                       
                    {                                                                                                                         
                        ApplicationArea = All;                                                                                                
                        ToolTip = 'Specifies the description of the commission.';                                                             
                    }                                                                                                                         
                    field("Commission %"; Rec."Commission %")                                                                                 
                    {                                                                                                                         
                        ApplicationArea = All;                                                                                                
                        ToolTip = 'Specifies the commission percentage.';                                                                     
                    }                                                                                                                         
                }                                                                                                                             
            }                                                                                                                                 
        }                                                                                                                                     
    }    