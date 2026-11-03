
tableextension 50425 "AIRIQ Sales Line Ext" extends "Sales Line"
{
    fields
    {
        field(50424; "Travel Date"; DateTime)
        {
            Caption = 'Travel Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SelectedDate: Date;
                CurrentTime: Time;
            begin
                SelectedDate := DT2Date(Rec."Travel Date");
                CurrentTime := DT2Time(CurrentDateTime());

                Rec."Travel Date" :=
                    CreateDateTime(SelectedDate, CurrentTime);
            end;
        }

        field(50425; Sector; Text[200])
        {
            Caption = 'Sector';
            DataClassification = CustomerContent;
        }

        field(50426; FlightType; Text[50])
        {
            Caption = 'Flight Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CalculateTax: Codeunit "Calculate Tax";
            begin
                if Rec.IsTemporary() then
                    exit;
                if (Rec."Document Type" <> Rec."Document Type"::Invoice) or
                   (Rec.Type <> Rec.Type::Item) or (Rec."No." = '') then
                    exit;
                if Rec.FlightType = xRec.FlightType then
                    exit;

                // Re-run standard tax selection when FlightType changes or is cleared.
                // The custom formulas read Amount; never reduce the commercial fields.
                CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
            end;
        }

        field(50432; BaseFare; Text[50])
        {
            Caption = 'Base Fare';
            DataClassification = CustomerContent;
        }

        field(50427; "Other Charges"; Decimal)
        {
            Caption = 'Other Charges';
            DataClassification = CustomerContent;
        }

        field(50431; "Passenger Name"; Text[2048])
        {
            Caption = 'Passenger Name';
            DataClassification = CustomerContent;
        }
    }
}
