# Microsoft reference source archive

All seven extracted Microsoft AL files are preserved byte-for-byte in
`Microsoft-reference-source.zip` in this directory. Their original filenames
are retained inside the archive. Contents were hash-verified before removing
the loose AL copies.

The project compiler recursively includes loose `.al` files, including files
under `.alpackages`. Keeping the reference sources inside this ZIP prevents
duplicate Microsoft objects from being compiled into AIRIQ. Open archive
entries for analysis; do not extract `.al` files anywhere below the AIRIQ
project root. Extract outside the project if editable files are needed.

The complete build includes both AIRIQGSTTreeCheck.al and
AIRIQGSTTreeDiagnostic.al. Their ambiguous SourceTable errors and cascading
Rec/repeater errors were resolved by removing the duplicate reference table;
neither page required a source edit.
