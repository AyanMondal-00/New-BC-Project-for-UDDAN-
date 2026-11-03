tableextension 50718 "AIRIQ SR Posted Header" extends "Sales Cr.Memo Header" { fields { field(50715; "AIRIQ Return No."; Code[50]) { DataClassification = CustomerContent;  }
field(50716; "AIRIQ Return Serial"; Integer) { DataClassification = CustomerContent;  }
field(50717; "AIRIQ Bill No."; Code[50]) { DataClassification = CustomerContent;  }
field(50718; "AIRIQ Original Invoice"; Code[50]) { DataClassification = CustomerContent;  }
field(50719; "AIRIQ Entry Date"; DateTime) { DataClassification = CustomerContent;  }
field(50720; "AIRIQ Reference"; Text[100]) { DataClassification = CustomerContent;  }
field(50721; "AIRIQ Narration"; Text[250]) { DataClassification = CustomerContent;  }
field(50722; "AIRIQ Supplier"; Code[30]) { DataClassification = CustomerContent;  }
field(50723; "AIRIQ Sale Type"; Option) { DataClassification = CustomerContent; OptionMembers = Own,ThirdParty; } } }

tableextension 50719 "AIRIQ SR Posted Line" extends "Sales Cr.Memo Line" { fields { field(50424; "Travel Date"; DateTime) { DataClassification = CustomerContent; }
field(50425; "Sector"; Text[200]) { DataClassification = CustomerContent; }
field(50426; "FlightType"; Text[50]) { DataClassification = CustomerContent; }
field(50432; "BaseFare"; Text[50]) { DataClassification = CustomerContent; }
field(50431; "Passenger Name"; Text[2048]) { DataClassification = CustomerContent; } field(50715; "AIRIQ Taxable Value"; Decimal) { DataClassification = CustomerContent;  }
field(50716; "AIRIQ Source CGST"; Decimal) { DataClassification = CustomerContent;  }
field(50717; "AIRIQ Source SGST"; Decimal) { DataClassification = CustomerContent;  }
field(50718; "AIRIQ Source IGST"; Decimal) { DataClassification = CustomerContent;  }
field(50719; "AIRIQ Sold Value"; Decimal) { DataClassification = CustomerContent;  }
field(50720; "AIRIQ XXLN Charges"; Decimal) { DataClassification = CustomerContent;  }
field(50721; "AIRIQ Refund Amount"; Decimal) { DataClassification = CustomerContent;  }
field(50722; "AIRIQ Country"; Text[50]) { DataClassification = CustomerContent;  }
field(50723; "AIRIQ State"; Text[50]) { DataClassification = CustomerContent;  }
field(50724; "AIRIQ City"; Text[50]) { DataClassification = CustomerContent;  }
field(50725; "AIRIQ Travel Time"; Time) { DataClassification = CustomerContent;  }
field(50726; "AIRIQ Airline"; Text[100]) { DataClassification = CustomerContent;  }
field(50727; "AIRIQ Airline Code"; Code[20]) { DataClassification = CustomerContent;  }
field(50728; "AIRIQ Reference"; Text[100]) { DataClassification = CustomerContent;  }
field(50729; "AIRIQ Passenger Type"; Text[50]) { DataClassification = CustomerContent;  }
field(50730; "AIRIQ Passenger SL"; Integer) { DataClassification = CustomerContent;  } } }

codeunit 50719 "AIRIQ SR Posting" {
[EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesCrMemoHeaderInsert', '', false, false)]
local procedure HeaderCopy(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; var SalesInvHeader: Record "Sales Invoice Header")
begin if SalesHeader."AIRIQ Return No." = '' then exit;
SalesCrMemoHeader."AIRIQ Return No." := SalesHeader."AIRIQ Return No.";
SalesCrMemoHeader."AIRIQ Return Serial" := SalesHeader."AIRIQ Return Serial";
SalesCrMemoHeader."AIRIQ Bill No." := SalesHeader."AIRIQ Bill No.";
SalesCrMemoHeader."AIRIQ Original Invoice" := SalesHeader."AIRIQ Original Invoice";
SalesCrMemoHeader."AIRIQ Entry Date" := SalesHeader."AIRIQ Entry Date";
SalesCrMemoHeader."AIRIQ Reference" := SalesHeader."AIRIQ Reference";
SalesCrMemoHeader."AIRIQ Narration" := SalesHeader."AIRIQ Narration";
SalesCrMemoHeader."AIRIQ Supplier" := SalesHeader."AIRIQ Supplier";
SalesCrMemoHeader."AIRIQ Sale Type" := SalesHeader."AIRIQ Sale Type";
end;
[EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesCrMemoLineInsert', '', false, false)]
local procedure LineCopy(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; var SalesHeader: Record "Sales Header"; var SalesShptHeader: Record "Sales Shipment Header"; var ReturnRcptHeader: Record "Return Receipt Header"; var PostingSalesLine: Record "Sales Line")
begin if SalesHeader."AIRIQ Return No." = '' then exit;
SalesCrMemoLine."AIRIQ Taxable Value" := SalesLine."AIRIQ Taxable Value";
SalesCrMemoLine."AIRIQ Source CGST" := SalesLine."AIRIQ Source CGST";
SalesCrMemoLine."AIRIQ Source SGST" := SalesLine."AIRIQ Source SGST";
SalesCrMemoLine."AIRIQ Source IGST" := SalesLine."AIRIQ Source IGST";
SalesCrMemoLine."AIRIQ Sold Value" := SalesLine."AIRIQ Sold Value";
SalesCrMemoLine."AIRIQ XXLN Charges" := SalesLine."AIRIQ XXLN Charges";
SalesCrMemoLine."AIRIQ Refund Amount" := SalesLine."AIRIQ Refund Amount";
SalesCrMemoLine."AIRIQ Country" := SalesLine."AIRIQ Country";
SalesCrMemoLine."AIRIQ State" := SalesLine."AIRIQ State";
SalesCrMemoLine."AIRIQ City" := SalesLine."AIRIQ City";
SalesCrMemoLine."AIRIQ Travel Time" := SalesLine."AIRIQ Travel Time";
SalesCrMemoLine."AIRIQ Airline" := SalesLine."AIRIQ Airline";
SalesCrMemoLine."AIRIQ Airline Code" := SalesLine."AIRIQ Airline Code";
SalesCrMemoLine."AIRIQ Reference" := SalesLine."AIRIQ Reference";
SalesCrMemoLine."AIRIQ Passenger Type" := SalesLine."AIRIQ Passenger Type";
SalesCrMemoLine."AIRIQ Passenger SL" := SalesLine."AIRIQ Passenger SL";
SalesCrMemoLine."Travel Date" := SalesLine."Travel Date";
SalesCrMemoLine."Sector" := SalesLine."Sector";
SalesCrMemoLine."FlightType" := SalesLine."FlightType";
SalesCrMemoLine."BaseFare" := SalesLine."BaseFare";
SalesCrMemoLine."Passenger Name" := SalesLine."Passenger Name";
end;
}