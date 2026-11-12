# T-20 Real model integration

## Scope
- Replace placeholders with real models and animations through the T-02 factory (no gameplay code changes).
- Define model format, folder layout, and naming (open question in the [pipeline doc](../plan/technical/asset_pipeline.md)).
- Hook model animations to the Hand states, king states, and cutscenes.

## Acceptance criteria
- Dropping a model into its folder replaces its placeholder.
- A missing model falls back to the named placeholder instead of crashing.
