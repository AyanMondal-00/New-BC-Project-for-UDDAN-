
table 50468 "TP Sales Return Passenger"
{
    Caption = 'Third Party Sales Return Passenger';
    DataClassification = CustomerContent;
    DrillDownPageId = "TP Sales Return Passenger List";
    LookupPageId = "TP Sales Return Passenger List";

    fields
    {
        field(1; "Return No."; Code[50])
        {
            Caption = 'Return No.';
            Editable = false;
        }
        field(2; PNR; Text[50])
        {
            Caption = 'PNR';
            Editable = false;
        }
        field(3; "SL No."; Integer)
        {
            Caption = 'SL No.';
            Editable = false;
        }
        field(4; "Passenger Name"; Text[100])
        {
            Caption = 'Passenger Name';
        }
        field(5; ID; BigInteger)
        {
            Caption = 'Passenger ID';
        }
        field(6; Type; Text[50])
        {
            Caption = 'Passenger Type';
        }
    }

    keys
    {
        key(PK; "Return No.", PNR, "SL No.")
        {
            Clustered = true;
        }
        key(SLNoLookup; "SL No.")
        {
        }
    }

    trigger OnInsert()
    var
        LastPassenger: Record "TP Sales Return Passenger";
        NextSLNo: Integer;
    begin
        if "Return No." = '' then
            Error('Return No. is required.');

        if PNR = '' then
            Error('PNR is required.');

        LastPassenger.LockTable();
        LastPassenger.Reset();
        LastPassenger.SetCurrentKey("SL No.");

        if LastPassenger.FindLast() then
            NextSLNo := LastPassenger."SL No." + 1
        else
            NextSLNo := 1;

        "SL No." := NextSLNo;
    end;
}
