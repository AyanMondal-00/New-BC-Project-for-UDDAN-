(function () {
  "use strict";
  var host = document.getElementById("controlAddIn") || document.body;
  if (typeof window.AIRIQPLBMount === "function") window.AIRIQPLBMount(host);
  if (window.Microsoft && Microsoft.Dynamics && Microsoft.Dynamics.NAV)
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("AddInReady", []);
}());
