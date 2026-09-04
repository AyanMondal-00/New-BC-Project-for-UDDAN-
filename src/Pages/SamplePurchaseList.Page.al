page 50310 "Sample Purchase List"
{
    Caption = 'Sample Purchase Format';
    PageType = List;
    SourceTable = "Sample Purchase";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {

        area(content)
        {
            repeater(General)
            {
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Purchase Date"; Rec."Purchase Date")
                {
                    ApplicationArea = All;
                }

                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = All;
                }

                field(Airline; Rec.Airline)
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Selection: Integer;
                    begin
                        Selection := StrMenu('Air India,IndiGo,SpiceJet', 1, 'Select Airline:');
                        if Selection <> 0 then begin
                            case Selection of
                                1:
                                    Text := 'Air India';
                                2:
                                    Text := 'IndiGo';
                                3:
                                    Text := 'SpiceJet';
                            end;
                            exit(true);
                        end;
                    end;
                }

                field("Agency ID"; Rec."Agency ID")
                {
                    ApplicationArea = All;
                }

                field(PNR; Rec.PNR)
                {
                    ApplicationArea = All;
                }

                field("Total Pax"; Rec."Total Pax")
                {
                    ApplicationArea = All;
                }

                field("Travel Date"; Rec."Travel Date")
                {
                    ApplicationArea = All;
                }

                field(Sector; Rec.Sector)
                {
                    ApplicationArea = All;
                }

                field(Rate; Rec.Rate)
                {
                    ApplicationArea = All;
                }

                field("Base Fare"; Rec."Base Fare")
                {
                    ApplicationArea = All;
                }

                field("Other Charges"; Rec."Other Charges")
                {
                    ApplicationArea = All;
                }

                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                }

                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Import from API")
            {
                ApplicationArea = All;
                Caption = 'Import from API';
                Image = Import;

                trigger OnAction()
                var
                    APIManagement: Codeunit "Sample Purchase API Management";
                begin
                    APIManagement.ImportFromAPI();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        SamplePurchase: Record "Sample Purchase";
    begin
        SamplePurchase.Reset();
        if SamplePurchase.FindLast() then
            if SamplePurchase."Serial No." >= 1 then
                Rec."Serial No." := SamplePurchase."Serial No." + 1
            else
                Rec."Serial No." := 1
        else
            Rec."Serial No." := 1;
    end;
}
