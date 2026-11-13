(function () {
    "use strict";
    var host = document.getElementById("controlAddIn");
    if (typeof window.AIRIQPLTreeMount === "function") {
        window.AIRIQPLTreeMount(host);
    }
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("AddInReady", []);
}());
