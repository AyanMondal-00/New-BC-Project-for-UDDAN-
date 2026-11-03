# AIRIQ GST execution tree nodes — preparation and validation

## Output and source

Created `AIRIQ-GST-Custom/AIRIQ-UseCaseTree-Nodes.json`, an import-shaped JSON array containing only 12 AIRIQ Use Case Tree nodes. Source was `C:\Users\P.C\Downloads\UseCaseTree (3).json` (11 nodes: TE-112400 through TE-112410). The export has the Sales Line / Item Begin node followed by six ordinary or Kerala Food Cess sales leaves and four export/SEZ leaves.

Paired the existing Domestic and International AIRIQ tax cases to all six Item sales leaves: registered/unregistered intra-state, registered/unregistered inter-state, and the two Kerala Food Cess intra-state leaves. Export/SEZ nodes were preserved and not cloned. Each node uses the corresponding existing AIRIQ custom CaseID, TableID 37, NodeType `Use Case`, and the same TaxType/IsTaxTypeRoot values as its standard sibling. JSON properties match the exported node schema: Code, Name, NodeType, TableID, CaseID, TaxType, IsTaxTypeRoot, Condition.

## Ordering and preservation

Codes place a Domestic/International pair immediately before its matching standard leaf in the supplied tree's Code-sorted order:

| Standard leaf | AIRIQ node codes (Domestic, International) |
|---|---|
| TE-112401 — unregistered inter-state | TE-112400A01, TE-112400A02 |
| TE-112402 — unregistered intra-state Kerala | TE-112401A01, TE-112401A02 |
| TE-112403 — registered intra-state Kerala | TE-112402A01, TE-112402A02 |
| TE-112404 — unregistered intra-state | TE-112403A01, TE-112403A02 |
| TE-112405 — registered inter-state | TE-112404A01, TE-112404A02 |
| TE-112406 — registered intra-state | TE-112405A01, TE-112405A02 |

A reconstructed merged sequence has 23 nodes. All 11 Microsoft nodes remain byte-for-field equivalent in their original relative order. Each AIRIQ node is a Sales Line sibling in the TE-112400 Type-Item branch and its code sorts after the previous node and before the exact overlapping Microsoft leaf. Existing Microsoft nodes were not edited; the source export was not modified.

## Formula and mapping validation

Ran the existing offline AIRIQ case validator against temporary copies, leaving the existing validation artifacts unchanged. Result: PASS, 1,300 checks across 12 cases and 720 numeric scenarios. Checks confirm formulas continue to look up the original `Sales Line.Amount`, use Domestic 1/20 or International 1/10 as base factors, use each configured component percent, and preserve the source case's non-formula component/posting fields. This is offline source/formula validation, not Business Central runtime calculation.

Structural checks passed: 12 nodes, unique node codes and CaseIDs; all CaseIDs match the existing manifest and custom tax-case JSON; no name/code length overflow; JSON parses as an array and each entry has the exact exported fields. Standard-node preservation, branch/sibling properties, and ordering checks passed.

## Import sequence and blockers

The new JSON contains tree nodes only. The referenced custom Use Cases must already be imported from `AIRIQ-GST-Custom/AIRIQ-GST-Domestic.json` and `AIRIQ-GST-Custom/AIRIQ-GST-International.json` before importing the node array. No tenant import or modification was performed.

The export provided is the TE-112400 Item branch (11 nodes); it does not include surrounding branches or broader GST tree nodes. Placement is validated within this exported branch. Runtime priority, actual condition overlap, enabled state, import acceptance, execution CaseID, and posting results remain Sandbox checks. The JSON/order-based priority is not represented as runtime proof. Kerala precedence and special-case behavior require those same runtime checks.

No runtime success is claimed. No Microsoft GST setup, posting mapping, tenant record, source export, or standard node was modified.
