
page 50541 "AIRIQ Cost Revision Statement"
{
    Caption = 'AIR IQ Reconcilation Statement';
    PageType = List;
    SourceTable = "AIRIQ Cost Revision History";
    SourceTableView = sorting(PNR, "Revision No.") order(ascending);
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
   

    layout
    {
        area(content)
        {
            repeater(Statement)
            {
                field("Cost Revision No."; Rec."Cost Revision No.")
                {
                    ApplicationArea = All;
                }
                field("Revision Date & Time"; Rec."Revision Date & Time")
                {
                    ApplicationArea = All;
                }
                field(PNR; Rec.PNR)
                {
                    ApplicationArea = All;
                }
                field(AirLineDisplay; AirLineDisplay)
                {
                    ApplicationArea = All;
                    Caption = 'AirLine';
                    Editable = false;
                    ToolTip = 'Shows the airline stored in the revision, or the current purchase airline for older history entries.';
                }
                field("Revision No."; Rec."Revision No.")
                {
                    ApplicationArea = All;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = All;
                }
                field("Previous Base Fare"; Rec."Previous Base Fare")
                {
                    ApplicationArea = All;
                }
                field("Revised Base Fare"; Rec."Revised Base Fare")
                {
                    ApplicationArea = All;
                }
                field("Fare Difference"; Rec."Fare Difference")
                {
                    ApplicationArea = All;
                    StyleExpr = FareStyle;
                }
                field("Total Pax"; Rec."Total Pax")
                {
                    ApplicationArea = All;
                }
                field("Previous Other Charges"; Rec."Previous Other Charges")
                {
                    ApplicationArea = All;
                }
                field("Revised Other Charges"; Rec."Revised Other Charges")
                {
                    ApplicationArea = All;
                }
                field("Previous Rate"; Rec."Previous Rate")
                {
                    ApplicationArea = All;
                }
                field("Revised Rate"; Rec."Revised Rate")
                {
                    ApplicationArea = All;
                }
                field("Previous Total Amount"; Rec."Previous Total Amount")
                {
                    ApplicationArea = All;
                }
                field("Revised Total Amount"; Rec."Revised Total Amount")
                {
                    ApplicationArea = All;
                }
                field("Revision Source"; Rec."Revision Source")
                {
                    ApplicationArea = All;
                }
                field("Changed By"; Rec."Changed By")
                {
                    ApplicationArea = All;
                }
                field("Purchase Serial No."; Rec."Purchase Serial No.")
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
            action(DeleteSelectedRevision)
            {
                Caption = 'Delete Selected Revision';
                ApplicationArea = All;
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Delete selected revision history rows after confirmation.';

                trigger OnAction()
                var
                    SelectedHistory: Record "AIRIQ Cost Revision History";
                    CheckHistory: Record "AIRIQ Cost Revision History";
                    DeletedCount: Integer;
                begin
                    CurrPage.SetSelectionFilter(SelectedHistory);

                    if SelectedHistory.IsEmpty() then
                        Error('Please select at least one revision row.');

                    if not Confirm(
                        'Are you sure you want to permanently delete the selected revision history rows?',
                        false)
                    then
                        exit;

                    // Protect opening entries when later revisions exist.
                    if SelectedHistory.FindSet() then
                        repeat
                            if SelectedHistory."Revision No." = 0 then begin
                                CheckHistory.Reset();
                                CheckHistory.SetRange(
                                    "Purchase Serial No.",
                                    SelectedHistory."Purchase Serial No.");
                                CheckHistory.SetFilter(
                                    "Revision No.", '>0');

                                if not CheckHistory.IsEmpty() then
                                    Error(
                                        'Opening revision for PNR %1 cannot be deleted while later revisions exist.',
                                        SelectedHistory.PNR);
                            end;
                        until SelectedHistory.Next() = 0;

                    // Delete selected rows only.
                    if SelectedHistory.FindSet(true) then
                        repeat
                            SelectedHistory.Delete(true);
                            DeletedCount += 1;
                        until SelectedHistory.Next() = 0;

                    CurrPage.Update(false);

                    Message(
                        '%1 selected cost revision history row(s) deleted successfully.',
                        DeletedCount);
                end;
            }

            action(ExportCostRevisionStatement)
            {
                Caption = 'Export Cost Revision Statement';
                ApplicationArea = All;
                Image = ExportToExcel;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Export the filtered PNR-wise statement in grouped revision order.';

                trigger OnAction()
                var
                    History: Record "AIRIQ Cost Revision History";
                    Exporter: Codeunit "AIRIQ Cost Revision Export";
                begin
                    History.Copy(Rec);
                    Exporter.ExportStatement(History);
                end;
            }
        }
    }

    var
        FareStyle: Text;
        AirLineDisplay: Text[100];

    trigger OnAfterGetRecord()
    var
        Purchase: Record "Sample Purchase";
    begin
        if Rec."Fare Difference" > 0 then
            FareStyle := 'Unfavorable'
        else
            if Rec."Fare Difference" < 0 then
                FareStyle := 'Favorable'
            else
                FareStyle := 'Standard';

        AirLineDisplay := Rec.AirLine;

        if AirLineDisplay = '' then
            if Purchase.Get(Rec."Purchase Serial No.") then
                AirLineDisplay := Purchase.Airline;
    end;
}
