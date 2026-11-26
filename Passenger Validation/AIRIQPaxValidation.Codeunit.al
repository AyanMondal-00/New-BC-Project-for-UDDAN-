codeunit 50749 "AIRIQ Pax Validation"
{
    procedure CheckFields(PassengerName: Text; PassengerID: BigInteger; PassengerType: Text; LineNo: Integer)
    begin
        if DelChr(PassengerName, '<>', ' ') = '' then
            Error('Passenger Name must not be blank (SL No. %1).', LineNo);
        if PassengerID <= 0 then
            Error('Passenger ID must be greater than 0 (SL No. %1).', LineNo);
        if DelChr(PassengerType, '<>', ' ') = '' then
            Error('Passenger Type must not be blank (SL No. %1).', LineNo);
    end;

    procedure CheckInsertLimit(PaxCount: Integer; PassengerCount: Integer)
    begin
        if PaxCount <= 0 then
            Error('First enter Pax count.');
        if PassengerCount >= PaxCount then
            Error('Passenger count cannot exceed PAX count (%1).', PaxCount);
    end;

    procedure CheckExactCount(PaxCount: Integer; PassengerCount: Integer)
    begin
        if PaxCount <= 0 then
            Error('First enter Pax count.');
        if PassengerCount < PaxCount then
            Error('Please complete all %1 passenger details. Add %2 more passenger(s).', PaxCount, PaxCount - PassengerCount);
        if PassengerCount > PaxCount then
            Error('Please remove %1 passenger(s) to match PAX count (%2).', PassengerCount - PaxCount, PaxCount);
    end;

    procedure NotifyPaxChange(PaxCount: Integer; PassengerCount: Integer)
    begin
        if PassengerCount = 0 then
            exit;
        if PaxCount <= 0 then
            Error('PAX must be greater than 0 when passengers exist. Remove existing passengers first.');

        // A non-blocking alert is intentional: Error would roll back the new PAX.
        if PassengerCount < PaxCount then
            Message('Please add %1 passenger(s) in View Passenger to match the new PAX count of %2.', PaxCount - PassengerCount, PaxCount);
        if PassengerCount > PaxCount then
            Message('Please remove %1 passenger(s) in View Passenger to match the new PAX count of %2.', PassengerCount - PaxCount, PaxCount);
    end;
}
