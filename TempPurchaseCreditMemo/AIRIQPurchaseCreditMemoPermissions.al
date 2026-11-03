permissionset 50700 "AIRIQ RETURN MEMO"
{
    Assignable = true;
    Caption = 'AIRIQ Purchase Return Credit Memo';
    Permissions =
        codeunit "AIRIQ Return Credit Memo" = X,
        codeunit "AIRIQ AQPR No. Mgt" = X,
        codeunit "AIRIQ Return Posting" = X,
        table "AIRIQ AQPR Reservation" = X,
        tabledata "AIRIQ AQPR Reservation" = Ri,
        tabledata "Purchase Return" = Rm;
}
