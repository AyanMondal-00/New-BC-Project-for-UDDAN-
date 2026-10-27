 pageextension 50325 "Commission Mgmt Navigation" extends "Business Manager Role Center"                                                   
    {                                                                                                                                         
        actions                                                                                                                               
        {                                                                                                                                     
            addlast(sections)                                                                                                                 
            {                                                                                                                                 
                group("Commission Management Group")                                                                                          
                {                                                                                                                             
                    Caption = 'Commission Management';                                                                                        
                                                                                                                                              
                    action("Commission Management")                                                                                           
                    {                                                                                                                         
                        ApplicationArea = All;                                                                                                
                        Caption = 'Commission Management';                                                                                    
                        RunObject = page "Commission Management";                                                                             
                        ToolTip = 'Open Commission Management list.';                                                                         
                    }                                                                                                                         
                }                                                                                                                             
            }                                                                                                                                 
        }                                                                                                                                     
    }              