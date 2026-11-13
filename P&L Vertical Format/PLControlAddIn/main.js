
(function () {
  "use strict";

  var host = null;
  var payload = null;
  var expanded = new Set();
  var busy = false;

  // ==============================================
  // ZERO VALUE TRANSACTION
  // Default: OFF
  // ==============================================

  var showZeroValueTransactions = false;

  var money = new Intl.NumberFormat("en-IN", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
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
  // ZERO VALUE IDENTIFICATION
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

    // Always show Net Profit / Net Loss.
    if (node.isProfit) {
      return true;
    }

    // Toggle ON: Show all Posting G/L Accounts.
    if (showZeroValueTransactions) {
      return true;
    }

    // Toggle OFF: Hide zero-value posting accounts.
    if (isZeroAmount(node.amount)) {
      return false;
    }

    return true;
  }

  // ==============================================
  // LEDGER DRILL-DOWN
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
      }
    );
  }

  // ==============================================
  // BUILD P&L TREE
  // Side 1 = Expenses
  // Side 2 = Income
  // ==============================================

  function buildTree(side, nodes) {

    var panel = el("section", "airiq-panel");

    panel.setAttribute(
      "aria-label",
      side === 1 ? "Expenses" : "Income"
    );

    // ============================================
    // HEADER
    // ============================================

    var heading = el("div", "airiq-head");

    heading.appendChild(
      el(
        "span",
        "",
        side === 1 ? "EXPENSES" : "INCOME"
      )
    );

    heading.appendChild(
      el("span", "", "Amount")
    );

    panel.appendChild(heading);

    var body = el("div", "airiq-body");

    // ============================================
    // PARENT / CHILD HIERARCHY
    // ============================================

    var children = new Map();

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
    // EXISTING DIRECT TRADING GROUP LOGIC
    // UNCHANGED
    // ============================================

    function isDirectGroup(node) {

      return (
        side === 1 &&
        (
          node.accountNo === "40010" ||
          node.accountNo === "40301"
        )
      ) || (
        side === 2 &&
        (
          node.accountNo === "30010" ||
          node.accountNo === "30101"
        )
      );
    }

    // ============================================
    // EXISTING GROSS PROFIT / LOSS
    // UNCHANGED
    // ============================================

    function renderGrossRow() {

      var gross = Number(payload.grossProfit || 0);

      if (
        (gross >= 0 && side !== 1) ||
        (gross < 0 && side !== 2)
      ) {
        return;
      }

      var row = el(
        "div",
        "airiq-row airiq-profit airiq-gross"
      );

      var label = el("div", "airiq-label");

      label.style.paddingLeft = "10px";

      label.appendChild(
        el("span", "airiq-leaf-spacer")
      );

      label.appendChild(
        el(
          "span",
          "",
          gross >= 0 ? "GROSS PROFIT" : "GROSS LOSS"
        )
      );

      row.appendChild(label);

      row.appendChild(
        el(
          "div",
          "airiq-amount",
          value(Math.abs(gross))
        )
      );

      body.appendChild(row);
    }

    // ============================================
    // RENDER P&L NODE
    // ============================================

    function renderNode(node, depth) {

      // ==========================================
      // NEW ZERO VALUE FILTER
      // ==========================================

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
          (isProfit ? " airiq-profit" : "")
      );

      var labelCell = el("div", "airiq-label");

      labelCell.style.paddingLeft =
        (10 + Math.min(depth, 12) * 19) + "px";

      // ==========================================
      // GROUP ROW
      // ==========================================

      if (isGroup) {

        var btn = el(
          "button",
          "airiq-toggle",
          isExpanded ? "−" : "+"
        );

        btn.type = "button";

        btn.setAttribute(
          "aria-expanded",
          String(isExpanded)
        );

        btn.setAttribute(
          "aria-label",
          (isExpanded ? "Collapse " : "Expand ") +
            node.name
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

        var titleButton = el(
          "button",
          "airiq-name-button",
          node.name
        );

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

        // ========================================
        // POSTING G/L ACCOUNT
        // ========================================

        labelCell.appendChild(
          el("span", "airiq-leaf-spacer")
        );

        var ledgerBtn = el(
          "button",
          "airiq-ledger-button",
          (
            node.accountNo
              ? node.accountNo + " - "
              : ""
          ) + node.name
        );

        ledgerBtn.type = "button";

        ledgerBtn.title = isProfit
          ? "Open income/expense ledger entries"
          : "Open G/L entries";

        ledgerBtn.addEventListener(
          "click",
          function () {
            activateLedger(node.id);
          }
        );

        labelCell.appendChild(ledgerBtn);
      }

      row.appendChild(labelCell);

      row.appendChild(
        el(
          "div",
          "airiq-amount",
          value(node.amount)
        )
      );

      body.appendChild(row);

      // ==========================================
      // EXPAND CHILDREN
      // KEEP GROSS PROFIT POSITION UNCHANGED
      // ==========================================

      if (isGroup && isExpanded) {

        var descendants = children.get(node.id) || [];

        // Main Expenses / Income root groups.
        if (
          (side === 1 && node.accountNo === "40000") ||
          (side === 2 && node.accountNo === "30000")
        ) {

          // Direct trading groups first.
          descendants
            .filter(isDirectGroup)
            .forEach(function (ch) {
              renderNode(ch, depth + 1);
            });

          // Gross Profit / Loss between
          // Direct and Indirect groups.
          renderGrossRow();

          // Indirect groups afterwards.
          descendants
            .filter(function (ch) {
              return !isDirectGroup(ch);
            })
            .forEach(function (ch) {
              renderNode(ch, depth + 1);
            });

        } else {

          descendants.forEach(function (ch) {
            renderNode(ch, depth + 1);
          });
        }
      }
    }

    // ============================================
    // ROOT NODES
    // ============================================

    (children.get(0) || []).forEach(function (n) {

      renderNode(n, 0);

      // Keep Gross Profit/Loss visible even
      // when the main account tree is collapsed.
      if (
        (
          (side === 1 && n.accountNo === "40000") ||
          (side === 2 && n.accountNo === "30000")
        ) &&
        !expanded.has(n.id)
      ) {
        renderGrossRow();
      }
    });

    panel.appendChild(body);

    // ============================================
    // P&L GRAND TOTAL
    // ============================================

    var total = el("div", "airiq-total");

    total.appendChild(
      el(
        "span",
        "",
        side === 1
          ? "TOTAL EXPENSES"
          : "TOTAL INCOME"
      )
    );

    total.appendChild(
      el(
        "span",
        "",
        value(
          side === 1
            ? payload.totalExpenses
            : payload.totalIncome
        )
      )
    );

    panel.appendChild(total);

    return panel;
  }

  // ==============================================
  // NEW: ZERO VALUE TRANSACTION TOGGLE BUTTON
  // ==============================================

  function createZeroValueToggle() {

    var toggle = el(
      "button",
      "airiq-zero-toggle" +
        (
          showZeroValueTransactions
            ? " airiq-zero-on"
            : " airiq-zero-off"
        )
    );

    toggle.type = "button";

    toggle.setAttribute(
      "aria-pressed",
      String(showZeroValueTransactions)
    );

    toggle.title = showZeroValueTransactions
      ? "Hide zero-value posting G/L accounts"
      : "Show zero-value posting G/L accounts";

    // Button label
    var label = el(
      "span",
      "airiq-zero-label",
      "Zero Value Transaction"
    );

    toggle.appendChild(label);

    // ON / OFF status
    var status = el(
      "span",
      "airiq-zero-status",
      showZeroValueTransactions ? "ON" : "OFF"
    );

    toggle.appendChild(status);

    // ============================================
    // TOGGLE CLICK
    // ============================================

    toggle.addEventListener("click", function () {

      showZeroValueTransactions =
        !showZeroValueTransactions;

      // Only redraw the P&L UI.
      // No server call.
      // No recalculation.
      // Gross Profit and Net Profit stay unchanged.
      // Existing expanded groups stay expanded.
      render();
    });

    return toggle;
  }

  // ==============================================
  // MAIN RENDER
  // ==============================================

  function render() {

    if (!host) {
      return;
    }

    host.replaceChildren();

    var wrapper = el(
      "div",
      "airiq-container"
    );

    if (!payload) {

      wrapper.appendChild(
        el(
          "div",
          "airiq-placeholder",
          "P&L loading…"
        )
      );

      host.appendChild(wrapper);

      return;
    }

    // ============================================
    // TOOLBAR
    // ============================================

    var tools = el(
      "div",
      "airiq-tools"
    );

    tools.appendChild(
      el(
        "span",
        "airiq-description",
        "Click + / − to expand groups. Click a ledger to open its entries."
      )
    );

    // ============================================
    // NEW ZERO VALUE TRANSACTION BUTTON
    // Immediately before Expand all
    // ============================================

    tools.appendChild(
      createZeroValueToggle()
    );

    // ============================================
    // EXPAND ALL
    // ============================================

    var expand = el(
      "button",
      "airiq-text-action",
      "Expand all"
    );

    expand.type = "button";

    expand.onclick = function () {

      payload.nodes.forEach(function (n) {

        if (n.isGroup) {
          expanded.add(n.id);
        }
      });

      render();
    };

    tools.appendChild(expand);

    // ============================================
    // COLLAPSE ALL
    // ============================================

    var collapse = el(
      "button",
      "airiq-text-action",
      "Collapse all"
    );

    collapse.type = "button";

    collapse.onclick = function () {

      expanded.clear();

      render();
    };

    tools.appendChild(collapse);

    wrapper.appendChild(tools);

    // ============================================
    // TWO COLUMN P&L
    // ============================================

    var columns = el(
      "div",
      "airiq-columns"
    );

    columns.appendChild(
      buildTree(1, payload.nodes)
    );

    columns.appendChild(
      buildTree(2, payload.nodes)
    );

    wrapper.appendChild(columns);

    // ============================================
    // FOOTNOTE
    // ============================================

    var bottom = el(
      "div",
      "airiq-footnote"
    );

    var diff = el(
      "span",
      "airiq-difference" +
        (
          Math.abs(Number(payload.difference)) > 0.005
            ? " airiq-warning"
            : ""
        ),
      "Difference: " + value(payload.difference)
    );

    bottom.appendChild(diff);

    bottom.appendChild(
      el(
        "span",
        "",
        "Account validation issues: " +
          (payload.validationIssues || 0)
      )
    );

    wrapper.appendChild(bottom);

    host.appendChild(wrapper);
  }

  // ==============================================
  // CONTROL ADD-IN MOUNT
  // ==============================================

  window.AIRIQPLTreeMount = function (element) {

    host =
      element ||
      document.getElementById("controlAddIn");

    if (host) {
      render();
    }
  };

  // ==============================================
  // RECEIVE P&L DATA FROM BUSINESS CENTRAL
  // ==============================================

  window.SetPLData = function (json) {

    try {

      var next = JSON.parse(json);

      if (!next || !Array.isArray(next.nodes)) {
        throw new Error("Invalid P&L payload");
      }

      payload = next;

      // Preserve existing behavior:
      // fresh data starts with collapsed groups.
      expanded.clear();

      // Zero Value Transaction toggle state
      // remains unchanged on recalculation.
      render();

    } catch (e) {

      if (host) {
        host.replaceChildren(
          el(
            "div",
            "airiq-error",
            "Could not display P&L data."
          )
        );
      }

      console.error(e);
    }
  };

}());
