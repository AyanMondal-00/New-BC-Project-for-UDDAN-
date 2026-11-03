tableextension 50715 "AIRIQ SR Header" extends "Sales Header" { fields { field(50715; "AIRIQ Return No."; Code[50]) { DataClassification = CustomerContent;  }
field(50716; "AIRIQ Return Serial"; Integer) { DataClassification = CustomerContent;  }
field(50717; "AIRIQ Bill No."; Code[50]) { DataClassification = CustomerContent;  }
field(50718; "AIRIQ Original Invoice"; Code[50]) { DataClassification = CustomerContent;  }
field(50719; "AIRIQ Entry Date"; DateTime) { DataClassification = CustomerContent;  }
field(50720; "AIRIQ Reference"; Text[100]) { DataClassification = CustomerContent;  }
field(50721; "AIRIQ Narration"; Text[250]) { DataClassification = CustomerContent;  }
field(50722; "AIRIQ Supplier"; Code[30]) { DataClassification = CustomerContent;  }
field(50723; "AIRIQ Sale Type"; Option) { DataClassification = CustomerContent; OptionMembers = Own,ThirdParty; } } }
tableextension 50716 "AIRIQ SR Line" extends "Sales Line" { fields { field(50715; "AIRIQ Taxable Value"; Decimal) { DataClassification = CustomerContent;  }
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
tableextension 50717 "AIRIQ SR Tracking" extends "Sales Return" { fields {
field(50715; "AIRIQ Memo Created"; Boolean) { DataClassification = CustomerContent; Editable = false; }
field(50716; "AIRIQ Memo No."; Code[20]) { DataClassification = CustomerContent; Editable = false; }
field(50717; "AIRIQ Credit Unit Price"; Decimal) { DataClassification = CustomerContent; Caption = 'Reviewed Credit Unit Price'; MinValue = 0; ObsoleteState = Pending; ObsoleteReason = 'Base Fare now supplies Unit Price Excl. VAT directly.'; ObsoleteTag = '1.0'; }
field(50718; "AIRIQ Price Reviewed"; Boolean) { DataClassification = CustomerContent; Caption = 'Credit Price Reviewed'; ObsoleteState = Pending; ObsoleteReason = 'Base Fare now supplies Unit Price Excl. VAT directly.'; ObsoleteTag = '1.0'; }
} }
