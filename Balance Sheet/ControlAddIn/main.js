(function () {
  "use strict";

  var host = null;
  var payload = null;
  var expanded = new Set();
  var busy = false;

  // ==============================================
  // ZERO VALUE TRANSACTION TOGGLE
  // Default = OFF
  // ==============================================

  var showZeroValueTransactions = false;

  var money = new Intl.NumberFormat("en-IN", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });

  // ==============================================
  // HTML ELEMENT HELPER
  // ==============================================

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

  // ==============================================
  // AMOUNT FORMAT
  // ==============================================

  function value(amount) {
    return money.format(Number(amount || 0));
  }

  // ==============================================
  // ZERO BALANCE IDENTIFICATION
  // ==============================================

  function isZeroAmount(amount) {
    return Number(amount || 0) === 0;
  }

  // ==============================================
  // NODE VISIBILITY
  // ==============================================

  function shouldShowNode(node) {
    // Always show groups.
    if (node.isGroup) {
      return true;
    }

    // Always show Current Year Profit/Loss.
    if (node.isProfit) {
      return true;
    }

    // Toggle ON: Show all Posting G/L Accounts.
    if (showZeroValueTransactions) {
      return true;
    }

    // Toggle OFF: Hide zero-balance ledgers.
    if (isZeroAmount(node.amount)) {
      return false;
    }

    return true;
  }

  // ==============================================
  // NEW: CAPTURE SCROLL POSITIONS
  //
  // Save both panels separately:
  // Index 0 = Liabilities & Equity
  // Index 1 = Assets
  // ==============================================

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

  // ==============================================
  // NEW: RESTORE SCROLL POSITIONS
  //
  // Called after rebuilding the UI.
  // Browser automatically clamps positions
  // if content becomes shorter.
  // ==============================================

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

  // ==============================================
  // OPEN G/L ENTRIES
  // ==============================================

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

  // ==============================================
  // BUILD ASSET / LIABILITY TREE
  // ==============================================

  function buildTree(side, nodes) {
    var panel = el("section", "airiq-panel");

    panel.setAttribute(
      "aria-label",
      side === 1 ? "Liabilities and equity" : "Assets",
    );

    // ============================================
    // PANEL HEADER
    // ============================================

    var heading = el("div", "airiq-head");

    heading.appendChild(
      el("span", "", side === 1 ? "LIABILITIES & EQUITY" : "ASSETS"),
    );

    heading.appendChild(el("span", "", "Amount"));

    panel.appendChild(heading);

    var body = el("div", "airiq-body");

    var children = new Map();

    // ============================================
    // BUILD PARENT / CHILD MAPPING
    // ============================================

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

    // ============================================
    // RENDER INDIVIDUAL NODE
    // ============================================

    function renderNode(node, depth) {
      // Hide zero-balance Posting G/L Accounts
      // when Zero Value Transaction is OFF.
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

      // ==========================================
      // GROUP NODE
      // ==========================================

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

          // NEW:
          // render() preserves both scroll positions.
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

          // Scroll position will be preserved.
          render();
        });

        labelCell.appendChild(titleButton);
      } else {
        // ========================================
        // POSTING G/L ACCOUNT
        // ========================================

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

      // ==========================================
      // EXPAND CHILDREN
      // ==========================================

      if (isGroup && isExpanded) {
        (children.get(node.id) || []).forEach(function (ch) {
          renderNode(ch, depth + 1);
        });
      }
    }

    // ============================================
    // RENDER ROOT NODES
    // ============================================

    (children.get(0) || []).forEach(function (n) {
      renderNode(n, 0);
    });

    panel.appendChild(body);

    // ============================================
    // GRAND TOTAL
    // ============================================

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

  // ==============================================
  // ZERO VALUE TRANSACTION BUTTON
  // ==============================================

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

    // ============================================
    // BUTTON LABEL
    // ============================================

    var label = el("span", "airiq-zero-label", "Zero Value Transaction");

    toggle.appendChild(label);

    // ============================================
    // ON / OFF STATUS
    // ============================================

    var status = el(
      "span",
      "airiq-zero-status",
      showZeroValueTransactions ? "ON" : "OFF",
    );

    toggle.appendChild(status);

    // ============================================
    // TOGGLE CLICK
    // ============================================

    toggle.addEventListener("click", function () {
      showZeroValueTransactions = !showZeroValueTransactions;

      // Only redraw UI.
      // No AL server call.
      // No recalculation.
      // Expanded groups remain unchanged.
      // Scroll positions remain preserved.
      render();
    });

    return toggle;
  }

  // ==============================================
  // MAIN RENDER FUNCTION
  // ==============================================

  function render() {
    if (!host) {
      return;
    }

    // ============================================
    // NEW: SAVE CURRENT SCROLL POSITIONS
    //
    // This must run BEFORE replaceChildren().
    // ============================================

    var savedScrollPositions = captureScrollPositions();

    // ============================================
    // REBUILD EXISTING UI
    // ============================================

    host.replaceChildren();

    var wrapper = el("div", "airiq-container");

    if (!payload) {
      wrapper.appendChild(
        el("div", "airiq-placeholder", "Balance Sheet loading…"),
      );

      host.appendChild(wrapper);

      return;
    }

    // ============================================
    // TOOLBAR
    // ============================================

    var tools = el("div", "airiq-tools");

    tools.appendChild(
      el(
        "span",
        "airiq-description",
        "Click + / − to expand groups. Click a ledger to open its entries.",
      ),
    );

    // ============================================
    // ZERO VALUE TRANSACTION
    // ============================================

    tools.appendChild(createZeroValueToggle());

    // ============================================
    // EXPAND ALL
    // ============================================

    var expand = el("button", "airiq-text-action", "Expand all");

    expand.type = "button";

    expand.onclick = function () {
      payload.nodes.forEach(function (n) {
        if (n.isGroup) {
          expanded.add(n.id);
        }
      });

      // Scroll positions remain preserved.
      render();
    };

    tools.appendChild(expand);

    // ============================================
    // COLLAPSE ALL
    // ============================================

    var collapse = el("button", "airiq-text-action", "Collapse all");

    collapse.type = "button";

    collapse.onclick = function () {
      expanded.clear();

      // Scroll positions remain preserved
      // where the new content height permits.
      render();
    };

    tools.appendChild(collapse);

    wrapper.appendChild(tools);

    // ============================================
    // TWO-SIDED BALANCE SHEET
    // ============================================

    var columns = el("div", "airiq-columns");

    // Left: Liabilities & Equity
    columns.appendChild(buildTree(1, payload.nodes));

    // Right: Assets
    columns.appendChild(buildTree(2, payload.nodes));

    wrapper.appendChild(columns);

    // ============================================
    // FOOTNOTE
    // ============================================

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

    // ============================================
    // INSERT NEW UI
    // ============================================

    host.appendChild(wrapper);

    // ============================================
    // NEW: RESTORE SCROLL POSITIONS
    //
    // Must run AFTER host.appendChild(wrapper).
    // ============================================

    restoreScrollPositions(savedScrollPositions);
  }

  // ==============================================
  // CONTROL ADD-IN MOUNT
  // ==============================================

  window.AIRIQBalanceTreeMount = function (element) {
    host = element || document.getElementById("controlAddIn");

    if (host) {
      render();
    }
  };

  // ==============================================
  // RECEIVE DATA FROM BUSINESS CENTRAL
  // ==============================================

  window.SetBalanceSheetData = function (json) {
    try {
      var next = JSON.parse(json);

      if (!next || !Array.isArray(next.nodes)) {
        throw new Error("Invalid payload");
      }

      payload = next;

      // Existing behavior:
      // New data starts with collapsed groups.
      expanded.clear();

      // Zero Value Transaction state
      // remains unchanged on recalculation.

      // Scroll positions are preserved
      // where possible.
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
