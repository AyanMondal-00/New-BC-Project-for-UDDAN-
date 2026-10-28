table 50428 "Target Incentive"
{
    Caption = 'Target Incentive';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Serial No."; Integer)
        {
            Caption = 'Serial No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(2; "AirLine"; Option)
        {
            Caption = 'AirLine';
            OptionMembers = " ","IndiGo","SpiceJet","Air India";
            OptionCaption = ' ,IndiGo,SpiceJet,Air India';
            DataClassification = CustomerContent;
        }

        field(3; "AirLine ID"; Code[20])
        {
            Caption = 'AirLine ID';
            DataClassification = CustomerContent;
        }

        field(4; "Commission Basis"; Option)
        {
            Caption = 'Commission Basis';
            OptionMembers = "Booking Date","Travel Date";
            OptionCaption = 'Booking Date,Travel Date';
            DataClassification = CustomerContent;
        }

        field(5; "Calculation Base"; Option)
        {
            Caption = 'Calculation Base';
            OptionMembers = "Base Fare","Other Charges","Base Fare + Other Charges";
            OptionCaption = 'Base Fare,Other Charges,Base Fare + Other Charges';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                RecalculateAmounts();
            end;
        }

        field(6; "Commission %"; Decimal)
        {
            Caption = 'Commission %';
            DecimalPlaces = 0 : 4;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                RecalculateAmounts();
            end;
        }

        field(7; "TDS % on Commission"; Decimal)
        {
            Caption = 'TDS % on Commission';
            DecimalPlaces = 0 : 4;
            InitValue = 2.0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                RecalculateAmounts();
            end;
        }

        field(8; "GST %"; Decimal)
        {
            Caption = 'GST %';
            DecimalPlaces = 0 : 2;
            InitValue = 18.0;
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(9; "Our State"; Option)
        {
            Caption = 'Our State';
            OptionMembers = "Andhra Pradesh","Arunachal Pradesh","Assam","Bihar","Chhattisgarh","Goa","Gujarat","Haryana","Himachal Pradesh","Jharkhand","Karnataka","Kerala","Madhya Pradesh","Maharashtra","Manipur","Meghalaya","Mizoram","Nagaland","Odisha","Punjab","Rajasthan","Sikkim","Tamil Nadu","Telangana","Tripura","Uttar Pradesh","Uttarakhand","West Bengal";
            OptionCaption = 'Andhra Pradesh,Arunachal Pradesh,Assam,Bihar,Chhattisgarh,Goa,Gujarat,Haryana,Himachal Pradesh,Jharkhand,Karnataka,Kerala,Madhya Pradesh,Maharashtra,Manipur,Meghalaya,Mizoram,Nagaland,Odisha,Punjab,Rajasthan,Sikkim,Tamil Nadu,Telangana,Tripura,Uttar Pradesh,Uttarakhand,West Bengal';
            DataClassification = CustomerContent;
        }

        field(10; "AirLine State"; Option)
        {
            Caption = 'AirLine State';
            OptionMembers = "Andhra Pradesh","Arunachal Pradesh","Assam","Bihar","Chhattisgarh","Goa","Gujarat","Haryana","Himachal Pradesh","Jharkhand","Karnataka","Kerala","Madhya Pradesh","Maharashtra","Manipur","Meghalaya","Mizoram","Nagaland","Odisha","Punjab","Rajasthan","Sikkim","Tamil Nadu","Telangana","Tripura","Uttar Pradesh","Uttarakhand","West Bengal";
            OptionCaption = 'Andhra Pradesh,Arunachal Pradesh,Assam,Bihar,Chhattisgarh,Goa,Gujarat,Haryana,Himachal Pradesh,Jharkhand,Karnataka,Kerala,Madhya Pradesh,Maharashtra,Manipur,Meghalaya,Mizoram,Nagaland,Odisha,Punjab,Rajasthan,Sikkim,Tamil Nadu,Telangana,Tripura,Uttar Pradesh,Uttarakhand,West Bengal';
            DataClassification = CustomerContent;
        }

        field(11; "GST Type"; Option)
        {
            Caption = 'GST Type';
            OptionMembers = "Auto by State","IGST","CGST+SGST";
            OptionCaption = 'Auto by State,IGST,CGST+SGST';
            DataClassification = CustomerContent;
        }
           field(32; "Rule Period Booking date From"; DateTime)
        {
            Caption = 'Rule Period Booking date From';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                SelectedDate: Date;
                CurrentTime: Time;
            begin
                SelectedDate := DT2Date(Rec."Rule Period Booking date From");
                CurrentTime := DT2Time(CurrentDateTime());
            
                Rec."Rule Period Booking date From" := CreateDateTime(SelectedDate, CurrentTime);
            end;
    }
           field(31; "Rule Period Booking date To"; DateTime)
        {
            Caption = 'Rule Period Booking date To';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                SelectedDate: Date;
                CurrentTime: Time;
            begin
                SelectedDate := DT2Date(Rec."Rule Period Booking date To");
                CurrentTime := DT2Time(CurrentDateTime());
            
                Rec."Rule Period Booking date To" := CreateDateTime(SelectedDate, CurrentTime);
            end;
    }

        field(12; "Target Slabs at or Above (Cr)"; Decimal)
        {
            Caption = 'Target Slabs at or Above (Cr)';
            DecimalPlaces = 2 : 4;
            DataClassification = CustomerContent;
        }

        field(13; "Target Slabs Commission %"; Decimal)
        {
            Caption = 'Target Slabs Commission %';
            DecimalPlaces = 0 : 4;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Commission %" = 0 then
                    "Commission %" := "Target Slabs Commission %";
                RecalculateAmounts();
            end;
        }

        field(14; "Amount From"; Option)
        {
            Caption = 'Amount From';
            OptionMembers = "Manual Total","Ticket Data";
            OptionCaption = 'Manual Total,Ticket Data';
            DataClassification = CustomerContent;
        }

        field(15; "Transaction"; Option)
        {
            Caption = 'Transaction';
            OptionMembers = "Purchase","Purchase Return","Both";
            OptionCaption = 'Purchase,Purchase Return,Both';
            DataClassification = CustomerContent;
        }

        field(16; "PNR / Ticket"; Text[100])
        {
            Caption = 'PNR / Ticket';
            DataClassification = CustomerContent;
        }

        field(17; "Purchase Base Fare"; Decimal)
        {
            Caption = 'Purchase Base Fare';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                RecalculateAmounts();
            end;
        }

        field(18; "Purchase Other Charges"; Decimal)
        {
            Caption = 'Purchase Other Charges';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                RecalculateAmounts();
            end;
        }

        field(19; "Purchase Total"; Decimal)
        {
            Caption = 'Purchase Total';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(20; "Achievement"; Decimal)
        {
            Caption = 'Achievement';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(21; "Target Slabs"; Text[100])
        {
            Caption = 'Target Slabs';
            DataClassification = CustomerContent;
        }

        field(22; "Commission Base"; Decimal)
        {
            Caption = 'Commission Base';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                RecalculateAmounts();
            end;
        }

        field(23; "Commission Percentage"; Decimal)
        {
            Caption = 'Commission Percentage';
            DecimalPlaces = 0 : 4;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Commission %" := "Commission Percentage";
                RecalculateAmounts();
            end;
        }

        field(24; "Total Commission"; Decimal)
        {
            Caption = 'Total Commission';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                RecalculateTaxes();
            end;
        }

        field(25; "GST Percentage"; Decimal)
        {
            Caption = 'GST Percentage';
            DecimalPlaces = 0 : 2;
            InitValue = 18.0;
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(26; "Invoice Incl. GST"; Decimal)
        {
            Caption = 'Invoice Incl. GST';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(27; "TDS (2.00%) on Commission"; Decimal)
        {
            Caption = 'TDS (2.00%) on Commission';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(28; "Net Receivable"; Decimal)
        {
            Caption = 'Net Receivable';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(29; "Received On"; DateTime)
        {
            Caption = 'Received On';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                SelectedDate: Date;
                CurrentTime: Time;
            begin
                SelectedDate := DT2Date(Rec."Received On");
                CurrentTime := DT2Time(CurrentDateTime());
            
                Rec."Received On" := CreateDateTime(SelectedDate, CurrentTime);
            end;
    }

        field(30; "Received In (Bank/ID)"; Text[100])
        {
            Caption = 'Received In (Bank/ID)';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Serial No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "GST %" = 0 then
            "GST %" := 18;
        if "GST Percentage" = 0 then
            "GST Percentage" := 18;
        if "TDS % on Commission" = 0 then
            "TDS % on Commission" := 2;
    end;

    local procedure RecalculateAmounts()
    var
        CommissionableAmount: Decimal;
        EffectiveCommPerc: Decimal;
    begin
        "Purchase Total" := "Purchase Base Fare" + "Purchase Other Charges";

        case "Calculation Base" of
            "Calculation Base"::"Base Fare":
                CommissionableAmount := "Purchase Base Fare";
            "Calculation Base"::"Other Charges":
                CommissionableAmount := "Purchase Other Charges";
            "Calculation Base"::"Base Fare + Other Charges":
                CommissionableAmount := "Purchase Total";
        end;

        if "Commission Base" <> 0 then
            CommissionableAmount := "Commission Base"
        else
            "Commission Base" := CommissionableAmount;

        if "Commission Percentage" <> 0 then
            EffectiveCommPerc := "Commission Percentage"
        else if "Commission %" <> 0 then
            EffectiveCommPerc := "Commission %"
        else if "Target Slabs Commission %" <> 0 then
            EffectiveCommPerc := "Target Slabs Commission %"
        else
            EffectiveCommPerc := 0;

        if EffectiveCommPerc <> 0 then
            "Total Commission" := Round((CommissionableAmount * EffectiveCommPerc) / 100, 0.01)
        else
            "Total Commission" := 0;

        RecalculateTaxes();
    end;

    local procedure RecalculateTaxes()
    var
        GSTVal: Decimal;
        TDSVal: Decimal;
        GSTPerc: Decimal;
        TDSPerc: Decimal;
    begin
        if "GST %" <> 0 then
            GSTPerc := "GST %"
        else if "GST Percentage" <> 0 then
            GSTPerc := "GST Percentage"
        else
            GSTPerc := 18;

        if "TDS % on Commission" <> 0 then
            TDSPerc := "TDS % on Commission"
        else
            TDSPerc := 2;

        GSTVal := Round(("Total Commission" * GSTPerc) / 100, 0.01);
        "Invoice Incl. GST" := "Total Commission" + GSTVal;

        TDSVal := Round(("Total Commission" * TDSPerc) / 100, 0.01);
        "TDS (2.00%) on Commission" := TDSVal;

        "Net Receivable" := "Invoice Incl. GST" - TDSVal;
    end;
}
