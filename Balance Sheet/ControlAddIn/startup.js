(function () {
    "use strict";
    var host = document.getElementById("controlAddIn");
    if (typeof window.AIRIQBalanceTreeMount === "function") {
        window.AIRIQBalanceTreeMount(host);
    }
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("AddInReady", []);
}());
