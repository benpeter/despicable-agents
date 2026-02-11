## Lucy Review: BLOCK

### Blocking Issue: Two files from issue #32's explicit "Delete" scope are missing from the plan

The issue explicitly lists these files under "Delete (artifact removal)":
- docs/override-format-spec.md
- docs/validate-overlays-spec.md

Both files exist in the repository. Neither is listed in Task 1's deletion instructions. The metaplan correctly identified them but the synthesis dropped them.

### Required fix
Add both files to Task 1's deletion list and Task 9's verification terms.

### Non-blocking observations (ADVISE)
1. Task 9 search term list includes `override-format-spec` but the synthesis never deletes the file
2. the-plan.md frontmatter comment about x-fine-tuned will become stale (acceptable, tracked as follow-up)
