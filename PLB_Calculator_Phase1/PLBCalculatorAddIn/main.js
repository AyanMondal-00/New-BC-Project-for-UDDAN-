(function () {
  "use strict";
  var root,
    rows = [],
    data = { pbase: 0, pyq: 0, rbase: 0, ryq: 0 };
  var fmt = new Intl.NumberFormat("en-IN", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
  var states = [
    "Andaman and Nicobar Islands",
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chandigarh",
    "Chhattisgarh",
    "Dadra and Nagar Haveli and Daman and Diu",
    "Delhi",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jammu and Kashmir",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Ladakh",
    "Lakshadweep",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Puducherry",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
  ];
  var round = function (v) {
    return Math.round((v + Number.EPSILON) * 100) / 100;
  };
  var val = function (n) {
    return fmt.format(round(n));
  };
  var get = function (id) {
    return root.querySelector('[data-id="' + id + '"]');
  };
  var read = function (id) {
    var n = parseFloat(get(id).value);
    return Number.isFinite(n) ? n : 0;
  };
  var set = function (id, text) {
    get(id).textContent = text;
  };
  var inp = function (label, id, type, value, other) {
    return (
      '<div class="field ' +
      (other || "") +
      '"><label for="plb-' +
      id +
      '">' +
      label +
      '</label><input data-id="' +
      id +
      '" id="plb-' +
      id +
      '" type="' +
      (type || "text") +
      '" ' +
      (value !== undefined ? 'value="' + value + '"' : "") +
      " " +
      (type === "number" ? 'min="0" step="0.01"' : "") +
      "></div>"
    );
  };
  var sel = function (label, id, opts) {
    return (
      '<div class="field"><label for="plb-' +
      id +
      '">' +
      label +
      '</label><select id="plb-' +
      id +
      '" data-id="' +
      id +
      '">' +
      opts
        .map(function (x) {
          return '<option value="' + x[0] + '">' + x[1] + "</option>";
        })
        .join("") +
      "</select></div>"
    );
  };
  var group = function (title, contents, id) {
    return (
      '<div class="group" data-group="' +
      id +
      '"><h3>' +
      title +
      '</h3><div class="group-grid">' +
      contents +
      "</div></div>"
    );
  };
  var card = function (area, number, title, body) {
    return (
      '<section class="card ' +
      area +
      '"><div class="card-head"><span class="head-icon">' +
      number +
      '</span><div><div class="eyebrow">' +
      area.toUpperCase() +
      "</div><h2>" +
      title +
      "</h2></div></div>" +
      body +
      "</section>"
    );
  };
  var line = function (name, key, css) {
    return (
      '<div class="line ' +
      (css || "") +
      '"><span>' +
      name +
      '</span><span data-id="' +
      key +
      '">0.00</span></div>'
    );
  };
  var period = function (f, t) {
    return f || t
      ? (f || "Any date") + " to " + (t || "Any date")
      : "No limit set";
  };
  var esc = function (s) {
    return String(s == null ? "" : s).replace(/[&<>"']/g, function (ch) {
      return {
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;",
      }[ch];
    });
  };

  function mount(host) {
    root = document.createElement("div");
    root.className = "airiq-plb";
    host.appendChild(root);
    var stateOpts = [["", "Select state"]].concat(
      states.map(function (s) {
        return [s, s];
      }),
    );
    var rule =
      '<div class="fields">' +
      inp("Airline", "airline", "text", "") +
      inp("Airline IDs (comma separated)", "ids", "text", "") +
      sel("Commission basis", "basis", [
        ["booking", "Booking date"],
        ["travel", "Travel (flown) date"],
        ["combined", "Combined"],
      ]) +
      sel("Calculation base", "calcbase", [
        ["base", "Base fare"],
        ["yq", "Other Charges"],
        ["both", "Base fare + Other Charges"],
      ]) +
      inp("Commission %", "pct", "number", "0") +
      inp("TDS % on commission", "tdspct", "number", "2") +
      inp("GST % on commission", "gstpct", "number", "18") +
      sel("Our state", "ourstate", stateOpts) +
      sel("Airline state", "airstate", stateOpts) +
      sel("GST type", "gsttype", [
        ["auto", "Auto (by state)"],
        ["igst", "IGST"],
        ["cgst", "CGST + SGST"],
      ]) +
      '<div class="field" data-group="reversal"><label>Return reversal %</label><input data-id="rev" type="number" value="100" min="0" step="0.01"></div></div>';
    var dates =
      '<div class="fields">' +
      '<div data-group="bookFrom">' +
      inp("Booking date from", "bfrom", "date") +
      "</div>" +
      '<div data-group="bookTo">' +
      inp("Booking date to", "bto", "date") +
      "</div>" +
      '<div data-group="flownFrom">' +
      inp("Flown date from", "ffrom", "date") +
      "</div>" +
      '<div data-group="flownTo">' +
      inp("Flown date to", "fto", "date") +
      "</div></div>";
    var amounts =
      '<div class="fields">' +
      sel("Amounts from", "src", [
        ["manual", "Manual totals"],
        ["posted", "BC posted documents (Phase 2)"],
      ]) +
      sel("Transaction", "ttype", [
        ["purchase", "Purchase"],
        ["return", "Purchase return"],
        ["both", "Both (net of purchase and return)"],
      ]) +
      inp("PNR / Ticket no.", "ref", "text", "", "wide") +
      group(
        "PURCHASE",
        inp("Base fare", "pbase", "number", "0") +
          inp("Other Charges", "pyq", "number", "0") +
          inp("Total", "ptotal", "text", "0.00"),
        "purchase",
      ) +
      group(
        "PURCHASE RETURN",
        inp("Base fare", "rbase", "number", "0") +
          inp("Other Charges", "ryq", "number", "0") +
          inp("Total", "rtotal", "text", "0.00"),
        "return",
      ) +
      group(
        "NET (PURCHASE MINUS RETURN)",
        inp("Base fare", "nbase", "text", "0.00") +
          inp("Other Charges", "nyq", "text", "0.00") +
          inp("Total", "ntotal", "text", "0.00"),
        "net",
      ) +
      "</div>";
    var breakdown =
      '<div class="breakdown"><span class="pill" data-id="pill">Purchase</span><div class="checks" data-id="periodText"></div>' +
      line("Base fare", "o-base") +
      line("Other Charges", "o-yq") +
      line("Total", "o-total", "strong") +
      line("Commission base", "o-cb") +
      line("Commission %", "o-pct") +
      line("Purchase commission", "o-pcomm") +
      line("Return reversal", "o-rcomm") +
      line("Total commission", "o-totalcomm", "strong") +
      line("IGST", "o-igst") +
      line("CGST", "o-cgst") +
      line("SGST", "o-sgst") +
      line("Invoice amount (with GST)", "o-invoice", "strong") +
      line("TDS on commission", "o-tds") +
      line("Net receivable", "o-net", "strong") +
      '<div class="fields" style="padding:12px 0 0">' +
      inp("Received on", "recdate", "date") +
      inp("Received in (bank / ID)", "recin", "text") +
      "</div>" +
      '<div class="actions"><button class="primary" data-act="add">Add to statement preview</button><button data-act="reset">Clear amounts</button></div></div>';
    var cols = [
      "Ref",
      "Airline",
      "Airline ID’s",
      "Type",
      "Basis",
      "Period",
      "Commission base",
      "%",
      "Commission",
      "GST",
      "Invoice amount",
      "TDS",
      "Net receivable",
      "Received on",
      "Received in",
      "Status",
      "Remove",
    ];
    root.innerHTML =
      '<div class="plb-title"><div class="eyebrow">AIRIQ 365 LIMITED</div><h1>PLB Calculator</h1></div>' +
      '<div class="hub"><div class="plb-left-column">' +
      card("rule", "01", "PLB rule", rule) +
      card("amounts", "03", "Ticket", amounts) +
      "</div>" +
      '<div class="center"><div class="core"><div class="eyebrow">NET RECEIVABLE</div><strong data-id="central">0.00</strong><div class="sub" data-id="centralComm">Commission 0.00</div><div class="sub" data-id="centralGST">GST 0.00</div><div class="sub" data-id="centralTDS">TDS 0.00</div></div></div>' +
      '<div class="plb-right-column">' +
      card("period", "02", "Rule period", dates) +
      card("result", "04", "Breakdown", breakdown) +
      "</div></div>" +
      '<section class="card statement"><div class="statement-head"><div><div class="eyebrow">STATEMENT · PREVIEW ONLY</div><h2>PLB statement</h2></div>' +
      '<div class="statement-buttons"><span class="status" data-id="totstatus">Received 0.00 | Pending 0.00</span><button data-act="copy">Copy for Excel</button><button data-act="clear">Clear statement</button></div></div>' +
      '<div class="table-scroll"><table><thead><tr>' +
      cols
        .map(function (c) {
          return "<th>" + c + "</th>";
        })
        .join("") +
      '</tr></thead><tbody data-id="tableBody"></tbody><tfoot><tr><td colspan="8">Totals</td><td class="number" data-id="sumcomm">0.00</td><td class="number" data-id="sumgst">0.00</td><td class="number" data-id="suminvoice">0.00</td><td class="number" data-id="sumtds">0.00</td><td class="number" data-id="sumnet">0.00</td><td colspan="4"></td></tr></tfoot></table></div><div class="empty" data-id="empty">No entries added yet.</div><div class="status" data-id="message" style="padding:0 20px 15px"></div></section>';
    ["ptotal", "rtotal", "nbase", "nyq", "ntotal"].forEach(function (k) {
      get(k).readOnly = true;
    });
    root.addEventListener("input", function (e) {
      if (e.target.matches("input,select")) calculate();
    });
    root.addEventListener("change", function (e) {
      if (e.target.matches("input,select")) calculate();
    });
    root.addEventListener("click", function (e) {
      var button = e.target.closest("button[data-act]");
      if (!button) return;
      var action = button.dataset.act;
      if (action === "add") add();
      else if (action === "reset") reset();
      else if (action === "clear") {
        rows = [];
        renderRows();
      } else if (action === "copy") copy();
      else if (action === "remove") {
        rows.splice(+button.dataset.index, 1);
        renderRows();
      }
    });
    calculate();
    renderRows();
  }
  function toggle(group, yes) {
    root.querySelectorAll('[data-group="' + group + '"]').forEach(function (x) {
      x.hidden = !yes;
    });
  }
  function calculate() {
    if (!root) return null;
    var basis = get("basis").value,
      mode = get("ttype").value,
      src = get("src").value;
    toggle("bookFrom", basis !== "travel");
    toggle("bookTo", basis !== "travel");
    toggle("flownFrom", basis !== "booking");
    toggle("flownTo", basis !== "booking");
    toggle("purchase", mode !== "return");
    toggle("return", mode !== "purchase");
    toggle("net", mode === "both");
    toggle("reversal", mode !== "purchase");
    var posted = src === "posted";
    ["pbase", "pyq", "rbase", "ryq"].forEach(function (k) {
      get(k).readOnly = posted;
    });
    if (posted) {
      set(
        "message",
        "BC posted-document retrieval is a Phase 2 placeholder. Select Manual totals to calculate.",
      );
    }
    var pb = mode !== "return" ? read("pbase") : 0,
      py = mode !== "return" ? read("pyq") : 0;
    var rb = mode !== "purchase" ? read("rbase") : 0,
      ry = mode !== "purchase" ? read("ryq") : 0;
    get("ptotal").value = val(pb + py);
    get("rtotal").value = val(rb + ry);
    get("nbase").value = val(pb - rb);
    get("nyq").value = val(py - ry);
    get("ntotal").value = val(pb + py - rb - ry);
    var cbf = function (b, y) {
      return get("calcbase").value === "base"
        ? b
        : get("calcbase").value === "yq"
          ? y
          : b + y;
    };
    var cp = cbf(pb, py),
      cr = cbf(rb, ry),
      pct = read("pct"),
      rev = get("rev").value === "" ? 100 : read("rev");
    var commP = round((cp * pct) / 100),
      commR = round((((cr * pct) / 100) * rev) / 100),
      comm = round(commP - commR);
    var gstPct = read("gstpct"),
      tdsPct = read("tdspct"),
      gst = round((comm * gstPct) / 100),
      tds = round((comm * tdsPct) / 100);
    var invoice = round(comm + gst),
      net = round(invoice - tds),
      gstChoice = get("gsttype").value;
    var our = get("ourstate").value,
      air = get("airstate").value;
    var gstType =
      gstChoice === "auto"
        ? our && air && our === air
          ? "cgst"
          : "igst"
        : gstChoice;
    var cgst = gstType === "cgst" ? round(gst / 2) : 0,
      sgst = gstType === "cgst" ? round(gst - cgst) : 0,
      igst = gstType === "igst" ? gst : 0;
    var trans =
      mode === "purchase"
        ? "Purchase"
        : mode === "return"
          ? "Purchase return"
          : "Net of purchase and return";
    var basisLabel =
      basis === "booking"
        ? "Booking date"
        : basis === "travel"
          ? "Travel date"
          : "Combined";
    var dates = [];
    if (basis !== "travel")
      dates.push("Booking " + period(get("bfrom").value, get("bto").value));
    if (basis !== "booking")
      dates.push("Flown " + period(get("ffrom").value, get("fto").value));
    set("pill", trans);
    set("periodText", dates.join(" | "));
    [
      ["o-base", pb - rb],
      ["o-yq", py - ry],
      ["o-total", pb + py - rb - ry],
      ["o-cb", cp - cr],
      ["o-pcomm", commP],
      ["o-rcomm", -commR],
      ["o-totalcomm", comm],
      ["o-igst", igst],
      ["o-cgst", cgst],
      ["o-sgst", sgst],
      ["o-invoice", invoice],
      ["o-tds", -tds],
      ["o-net", net],
      ["central", net],
    ].forEach(function (e) {
      set(e[0], val(e[1]));
    });
    set("o-pct", val(pct) + "%");
    set("centralComm", "Commission " + val(comm));
    set("centralGST", "GST " + val(gst));
    set("centralTDS", "TDS " + val(tds));
    // GST rows show the exact interstate/intrastate split, as in the source HTML.
    ["o-igst", "o-cgst", "o-sgst"].forEach(function (k) {
      get(k).parentNode.hidden =
        gstType === "igst" ? k !== "o-igst" : k === "o-igst";
    });
    return {
      ref: get("ref").value.trim(),
      airline: get("airline").value.trim(),
      ids: get("ids").value.trim(),
      type: trans,
      basis: basisLabel,
      period: dates.join(" | "),
      base: round(cp - cr),
      pct: pct,
      comm: comm,
      gst: gst,
      invoice: invoice,
      tds: tds,
      net: net,
      recdate: get("recdate").value,
      recin: get("recin").value.trim(),
      gstType: gstType,
    };
  }
  function reset() {
    ["ref", "pbase", "pyq", "rbase", "ryq", "recdate", "recin"].forEach(
      function (k) {
        get(k).value = "";
      },
    );
    get("src").value = "manual";
    set("message", "");
    calculate();
  }
  function add() {
    if (get("src").value !== "manual") {
      set(
        "message",
        "Cannot add an unimplemented posted-data calculation. Switch to Manual totals.",
      );
      return;
    }
    var r = calculate();
    rows.push(r);
    get("recdate").value = "";
    get("recin").value = "";
    set(
      "message",
      "Added to this page preview only; not saved in Business Central.",
    );
    renderRows();
  }
  function renderRows() {
    var body = get("tableBody");
    body.innerHTML = "";
    var sums = {
      comm: 0,
      gst: 0,
      invoice: 0,
      tds: 0,
      net: 0,
      received: 0,
      pending: 0,
    };
    rows.forEach(function (r, i) {
      var tr = document.createElement("tr");
      var vals = [
        r.ref,
        r.airline,
        r.ids,
        r.type,
        r.basis,
        r.period,
        val(r.base),
        val(r.pct) + "%",
        val(r.comm),
        val(r.gst),
        val(r.invoice),
        val(r.tds),
        val(r.net),
        r.recdate,
        r.recin,
        r.recdate ? "Received" : "Pending",
      ];
      vals.forEach(function (v, j) {
        var td = document.createElement("td");
        td.textContent = v;
        if (j >= 6 && j <= 12) td.className = "number";
        tr.appendChild(td);
      });
      var td = document.createElement("td"),
        b = document.createElement("button");
      b.className = "small-btn danger";
      b.textContent = "Remove";
      b.dataset.act = "remove";
      b.dataset.index = i;
      td.appendChild(b);
      tr.appendChild(td);
      body.appendChild(tr);
      ["comm", "gst", "invoice", "tds", "net"].forEach(function (k) {
        sums[k] += r[k];
      });
      sums[r.recdate ? "received" : "pending"] += r.net;
    });
    ["comm", "gst", "invoice", "tds", "net"].forEach(function (k) {
      set("sum" + k, val(sums[k]));
    });
    set(
      "totstatus",
      "Received " + val(sums.received) + " | Pending " + val(sums.pending),
    );
    get("empty").hidden = rows.length > 0;
  }
  function copy() {
    if (!rows.length) {
      set("message", "Nothing to copy.");
      return;
    }
    var lines = [
      [
        "Ref",
        "Airline",
        "Airline IDs",
        "Type",
        "Basis",
        "Period",
        "Commission base",
        "%",
        "Commission",
        "GST",
        "Invoice amount",
        "TDS",
        "Net receivable",
        "Received on",
        "Received in",
        "Status",
      ].join("\t"),
    ];
    rows.forEach(function (r) {
      lines.push(
        [
          r.ref,
          r.airline,
          r.ids,
          r.type,
          r.basis,
          r.period,
          r.base.toFixed(2),
          r.pct.toFixed(2),
          r.comm.toFixed(2),
          r.gst.toFixed(2),
          r.invoice.toFixed(2),
          r.tds.toFixed(2),
          r.net.toFixed(2),
          r.recdate,
          r.recin,
          r.recdate ? "Received" : "Pending",
        ].join("\t"),
      );
    });
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(lines.join("\n")).then(
        function () {
          set("message", "Copied for Excel.");
        },
        function () {
          set("message", "Clipboard was blocked by the browser.");
        },
      );
    } else set("message", "Clipboard is unavailable in this client.");
  }
  window.AIRIQPLBMount = mount;
  // The AL procedure SetPostedData can call this function in Phase 2.
  window.SetPostedData = function (payload) {
    try {
      var d = JSON.parse(payload);
      set("message", d.message || "BC data response received.");
    } catch (e) {
      set("message", "Invalid BC response.");
    }
  };
})();
