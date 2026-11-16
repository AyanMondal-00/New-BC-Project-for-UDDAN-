(function () {
  "use strict";

  var host = null;
  var payload = null;
  var expanded = new Set();
  var busy = false;

  // Default = OFF
  var showZeroValueTransactions = false;

  // NEW: Current screen-visible nodes in actual display order.
  var visibleNodeIDs = {
    liabilities: [],
    assets: [],
  };

  var money = new Intl.NumberFormat("en-IN", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });

  function el(tag, cls, text) {
    var element = document.createElement(tag);

    if (cls) {
      element.className = cls;
    }

    if (text !== undefined) {
      element.textContent = String(text);
    }

    return element;
  }

  function value(amount) {
    return money.format(Number(amount || 0));
  }

  function isZeroAmount(amount) {
    return Number(amount || 0) === 0;
  }

  // Same visibility rule used by the existing UI.
  function shouldShowNode(node) {
    if (node.isGroup) {
      return true;
    }

    if (node.isProfit) {
      return true;
    }

    if (showZeroValueTransactions) {
      return true;
    }

    return !isZeroAmount(node.amount);
  }

  function captureScrollPositions() {
    var positions = [];

    if (!host) {
      return positions;
    }

    var bodies = host.querySelectorAll(".airiq-body");

    for (var i = 0; i < bodies.length; i++) {
      positions.push({
        top: bodies[i].scrollTop,
        left: bodies[i].scrollLeft,
      });
    }

    return positions;
  }

  function restoreScrollPositions(positions) {
    if (!host) {
      return;
    }

    var bodies = host.querySelectorAll(".airiq-body");

    for (var i = 0; i < bodies.length; i++) {
      if (positions[i]) {
        bodies[i].scrollTop = positions[i].top;
        bodies[i].scrollLeft = positions[i].left;
      }
    }
  }

  // Existing Ledger Drill-down.
  function activateLedger(id) {
    if (busy || !Number.isInteger(id)) {
      return;
    }

    busy = true;

    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
      "NodeActivated",
      [id],
      false,
      function () {
        busy = false;
      },
      function () {
        busy = false;
      },
    );
  }

  function buildTree(side, nodes) {
    var panel = el("section", "airiq-panel");

    panel.setAttribute(
      "aria-label",
      side === 1 ? "Liabilities and equity" : "Assets",
    );

    var heading = el("div", "airiq-head");

    heading.appendChild(
      el("span", "", side === 1 ? "LIABILITIES & EQUITY" : "ASSETS"),
    );

    heading.appendChild(el("span", "", "Amount"));

    panel.appendChild(heading);

    var body = el("div", "airiq-body");
    var children = new Map();

    // Preserve original parent-child hierarchy.
    nodes
      .filter(function (n) {
        return n.side === side;
      })
      .forEach(function (n) {
        var parent = n.parentId || 0;

        if (!children.has(parent)) {
          children.set(parent, []);
        }

        children.get(parent).push(n);
      });

    function renderNode(node, depth) {
      // Hidden zero-value ledger is not rendered
      // and therefore cannot enter the export list.
      if (!shouldShowNode(node)) {
        return;
      }

      var isGroup = !!node.isGroup;
      var isProfit = !!node.isProfit;
      var isExpanded = expanded.has(node.id);

      var row = el(
        "div",
        "airiq-row" +
          (isGroup ? " airiq-group" : " airiq-ledger") +
          (isProfit ? " airiq-profit" : ""),
      );

      var labelCell = el("div", "airiq-label");

      labelCell.style.paddingLeft = 10 + Math.min(depth, 12) * 19 + "px";

      if (isGroup) {
        var btn = el("button", "airiq-toggle", isExpanded ? "−" : "+");

        btn.type = "button";

        btn.setAttribute("aria-expanded", String(isExpanded));

        btn.setAttribute(
          "aria-label",
          (isExpanded ? "Collapse " : "Expand ") + node.name,
        );

        btn.addEventListener("click", function (e) {
          e.stopPropagation();

          if (expanded.has(node.id)) {
            expanded.delete(node.id);
          } else {
            expanded.add(node.id);
          }

          render();
        });

        labelCell.appendChild(btn);

        var titleButton = el("button", "airiq-name-button", node.name);

        titleButton.type = "button";

        titleButton.addEventListener("click", function () {
          if (expanded.has(node.id)) {
            expanded.delete(node.id);
          } else {
            expanded.add(node.id);
          }

          render();
        });

        labelCell.appendChild(titleButton);
      } else {
        labelCell.appendChild(el("span", "airiq-leaf-spacer"));

        var ledgerBtn = el(
          "button",
          "airiq-ledger-button",
          (node.accountNo ? node.accountNo + " - " : "") + node.name,
        );

        ledgerBtn.type = "button";

        ledgerBtn.title = isProfit
          ? "Open Income Statement accounts"
          : "Open G/L entries";

        ledgerBtn.addEventListener("click", function () {
          activateLedger(node.id);
        });

        labelCell.appendChild(ledgerBtn);
      }

      row.appendChild(labelCell);

      row.appendChild(el("div", "airiq-amount", value(node.amount)));

      body.appendChild(row);

      // =========================================
      // NEW: Record ONLY the rows actually shown.
      // Order exactly matches the screen hierarchy.
      // =========================================
      if (side === 1) {
        visibleNodeIDs.liabilities.push(node.id);
      } else {
        visibleNodeIDs.assets.push(node.id);
      }

      // Collapsed group's children are never added.
      if (isGroup && isExpanded) {
        (children.get(node.id) || []).forEach(function (child) {
          renderNode(child, depth + 1);
        });
      }
    }

    // Render top-level nodes.
    (children.get(0) || []).forEach(function (node) {
      renderNode(node, 0);
    });

    panel.appendChild(body);

    // Existing Grand Total.
    var total = el("div", "airiq-total");

    total.appendChild(
      el(
        "span",
        "",
        side === 1 ? "TOTAL LIABILITIES & EQUITY" : "TOTAL ASSETS",
      ),
    );

    total.appendChild(
      el("span", "", value(side === 1 ? payload.liabilities : payload.assets)),
    );

    panel.appendChild(total);

    return panel;
  }

  function createZeroValueToggle() {
    var toggle = el(
      "button",
      "airiq-zero-toggle" +
        (showZeroValueTransactions ? " airiq-zero-on" : " airiq-zero-off"),
    );

    toggle.type = "button";

    toggle.setAttribute("aria-pressed", String(showZeroValueTransactions));

    toggle.title = showZeroValueTransactions
      ? "Click to hide zero balance posting accounts"
      : "Click to show zero balance posting accounts";

    var label = el("span", "airiq-zero-label", "Zero Value Transaction");

    toggle.appendChild(label);

    var status = el(
      "span",
      "airiq-zero-status",
      showZeroValueTransactions ? "ON" : "OFF",
    );

    toggle.appendChild(status);

    toggle.addEventListener("click", function () {
      showZeroValueTransactions = !showZeroValueTransactions;

      // Re-render recalculates the visible export IDs.
      // Expanded groups and scroll are preserved.
      render();
    });

    return toggle;
  }

  function render() {
    if (!host) {
      return;
    }

    var savedScrollPositions = captureScrollPositions();

    // =========================================
    // NEW: Reset visible IDs on every render.
    // =========================================
    visibleNodeIDs = {
      liabilities: [],
      assets: [],
    };

    host.replaceChildren();

    var wrapper = el("div", "airiq-container");

    if (!payload) {
      wrapper.appendChild(
        el("div", "airiq-placeholder", "Balance Sheet loading…"),
      );

      host.appendChild(wrapper);
      return;
    }

    var tools = el("div", "airiq-tools");

    tools.appendChild(
      el(
        "span",
        "airiq-description",
        "Click + / − to expand groups. Click a ledger to open its entries.",
      ),
    );

    tools.appendChild(createZeroValueToggle());

    // Expand All.
    var expand = el("button", "airiq-text-action", "Expand all");

    expand.type = "button";

    expand.onclick = function () {
      payload.nodes.forEach(function (node) {
        if (node.isGroup) {
          expanded.add(node.id);
        }
      });

      render();
    };

    tools.appendChild(expand);

    // Collapse All.
    var collapse = el("button", "airiq-text-action", "Collapse all");

    collapse.type = "button";

    collapse.onclick = function () {
      expanded.clear();
      render();
    };

    tools.appendChild(collapse);

    wrapper.appendChild(tools);

    // Two-sided Balance Sheet.
    var columns = el("div", "airiq-columns");

    columns.appendChild(buildTree(1, payload.nodes));

    columns.appendChild(buildTree(2, payload.nodes));

    wrapper.appendChild(columns);

    // Existing bottom summary.
    var bottom = el("div", "airiq-footnote");

    var diff = el(
      "span",
      "airiq-difference" +
        (Math.abs(Number(payload.difference)) > 0.005 ? " airiq-warning" : ""),
      "Difference: " + value(payload.difference),
    );

    bottom.appendChild(diff);

    bottom.appendChild(
      el(
        "span",
        "",
        "Account validation issues: " + (payload.validationIssues || 0),
      ),
    );

    wrapper.appendChild(bottom);
    host.appendChild(wrapper);

    restoreScrollPositions(savedScrollPositions);
  }

  // ==============================================
  // NEW: AL Export Button calls this procedure.
  //
  // Send current rendered node IDs.
  // Never reset or modify the UI before exporting.
  // ==============================================
  window.RequestExcelExportState = function () {
    if (!payload || !host) {
      return;
    }

    var stateJson = JSON.stringify({
      liabilities: visibleNodeIDs.liabilities.slice(),
      assets: visibleNodeIDs.assets.slice(),
      showZeroValueTransactions: showZeroValueTransactions,
    });

    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
      "ExcelExportStateReady",
      [stateJson],
      false,
      function () {},
      function (error) {
        console.error("Balance Sheet Excel export request failed.", error);
      },
    );
  };

  // Existing Control Add-in Mount.
  window.AIRIQBalanceTreeMount = function (element) {
    host = element || document.getElementById("controlAddIn");

    if (host) {
      render();
    }
  };

  // Existing AL-to-JS data update.
  window.SetBalanceSheetData = function (json) {
    try {
      var next = JSON.parse(json);

      if (!next || !Array.isArray(next.nodes)) {
        throw new Error("Invalid payload");
      }

      payload = next;

      // Preserve existing behavior:
      // Recalculated data begins collapsed.
      expanded.clear();

      // Zero Value ON/OFF state stays unchanged.
      render();
    } catch (e) {
      if (host) {
        host.replaceChildren(
          el("div", "airiq-error", "Could not display Balance Sheet data."),
        );
      }

      console.error(e);
    }
  };
})();
