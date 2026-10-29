tableextension 50430 "AIRIQ Posted Sales Line Ext" extends "Sales Invoice Line"
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
            
                Rec."Travel Date" := CreateDateTime(SelectedDate, CurrentTime);
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

        field(50428; CGST; Decimal)
        {
            Caption = 'CGST';
            DataClassification = CustomerContent;
        }

        field(50429; SGST; Decimal)
        {
            Caption = 'SGST';
            DataClassification = CustomerContent;
        }

        field(50430; IGST; Decimal)
        {
            Caption = 'IGST';
            DataClassification = CustomerContent;
        }

        field(50431; "Passenger Name"; Text[2048])
        {
            Caption = 'Passenger Name';
            DataClassification = CustomerContent;
        }
    }
}