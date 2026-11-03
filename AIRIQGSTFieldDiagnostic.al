page 50595 "AIRIQ GST Field Diagnostic"
{
    Caption = 'AIRIQ GST Field Diagnostic';
    PageType = List;
    SourceTable = "Tax Component Expr. Token";
    ApplicationArea = All;
    UsageCategory = Lists;

    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Case ID"; Rec."Case ID")
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
            action(CheckFlightType)
            {
                Caption = 'Check FlightType Field';
                ApplicationArea = All;
                Image = Check;

                trigger OnAction()
                var
                    FieldRecord: Record Field;
                begin
                    FieldRecord.Reset();

                    FieldRecord.SetRange(
                        TableNo,
                        Database::"Sales Line");

                    FieldRecord.SetRange(
                        "No.",
                        50426);

                    if FieldRecord.FindFirst() then
                        Message(
                            'FlightType Field Found!\Table ID: %1\Field ID: %2\Field Name: %3',
                            FieldRecord.TableNo,
                            FieldRecord."No.",
                            FieldRecord.FieldName)
                    else
                        Error(
                            'FlightType field 50426 was not found in Sales Line.');
                end;
            }

            action(ShowStandardTokens)
            {
                Caption = 'Show Standard GST Tokens';
                ApplicationArea = All;
                Image = View;

                trigger OnAction()
                begin
                    FilterStandardCase();
                    CurrPage.Update(false);
                end;
            }

            action(ShowAllTokens)
            {
                Caption = 'Show All Tokens';
                ApplicationArea = All;
                Image = Refresh;

                trigger OnAction()
                begin
                    Rec.Reset();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        FilterStandardCase();
    end;

    local procedure FilterStandardCase()
    var
        CaseGuid: Guid;
    begin
        Evaluate(
            CaseGuid,
            '6B464955-261F-4EAF-A749-7807444FC37C');

        Rec.Reset();
        Rec.SetRange("Case ID", CaseGuid);
    end;
}