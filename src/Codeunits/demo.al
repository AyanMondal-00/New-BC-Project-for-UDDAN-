codeunit 50421 "BC Public IP Test"
{
    procedure GetBCPublicIP()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        ResponseText: Text;
        IPCheckURL: Text;
    begin
        IPCheckURL := 'https://api.ipify.org?format=json';

        if not Client.Get(IPCheckURL, Response) then
            Error('Could not connect to IP check service.');

        if not Response.IsSuccessStatusCode() then
            Error(
                'IP check failed. Status Code: %1',
                Response.HttpStatusCode()
            );

        Response.Content().ReadAs(ResponseText);

        Message(
            'BC Sandbox Public IP:\%1',
            ResponseText
        );
    end;
}