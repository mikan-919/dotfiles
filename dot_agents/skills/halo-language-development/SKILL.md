---
name: halo-language-development
description: Develop and evolve the Halo programming language through small, coherent vertical slices. Use when working in the Halo repository on language boundaries, syntax, HIR, name resolution, type or ownership checking, diagnostics, Cranelift code generation, the C runtime, allocation and deterministic cleanup, tests, documentation, roadmap decisions, selecting the next implementation task, or reviewing a proposed change for overengineering.
---

# Halo Language Development

Evolve Halo from user-visible semantics through native execution without losing its simple, safe language boundary. Treat repository documentation and tests as the current source of truth.

## Establish the current state

1. Locate the repository root and inspect `git status` before editing. Preserve unrelated or user-authored changes.
2. Read `README.md`, `docs/vision.md`, `docs/scope.md`, `docs/implementation.md`, and `docs/roadmap.md`. Read the relevant focused documents and tests for the requested feature.
3. Inspect recent commits and trace the existing implementation with `rg`. Do not infer missing behavior from filenames or plans alone.
4. Separate three categories explicitly:
   - permanent language commitments;
   - provisional implementation choices;
   - deferred features.

If repository documentation has changed, follow it instead of the historical defaults summarized below.

## Preserve Halo's design boundary

Use these current defaults unless the user deliberately revises them:

- Favor concise application-language ergonomics with Rust-like safety, not every Rust mechanism.
- Infer lifetimes completely; never introduce user-written lifetime syntax.
- Interpret plain parameters as shared borrows, `mut` as exclusive borrows, and `take` as ownership transfer.
- Permit numeric casts only when every source value is represented exactly; give lossy behavior named checked, rounding, saturating, or wrapping operations.
- Keep ordinary integer arithmetic checked in every build mode.
- Abort through the Halo panic runtime without unwinding or catching.
- Use the initial x86-64 Linux Cranelift backend, system `cc`/`ar`, and the small C runtime until another target is intentionally selected.
- Allow the target runtime to use libc behind a narrow Halo ABI; do not expose libc as the language model.
- Keep Halo diagnostics renderer-independent, with miette fancy human output at the CLI boundary.
- Use ownership and deterministic cleanup rather than a tracing garbage collector.

Do not silently turn a deferred feature into a permanent non-goal, or a provisional ABI into a language guarantee.

## Select a vertical slice

Choose the smallest change that produces observable, exercised behavior. Define before editing:

- the source-level behavior;
- accepted and rejected programs;
- ownership and failure semantics;
- affected compiler passes;
- runtime or target ABI changes;
- tests that prove the behavior;
- documentation that must stop claiming the old behavior.

Prefer a real first consumer over an isolated subsystem. For example, introduce allocation together with an owned operation and generated cleanup, not as unused allocator functions.

State what the slice deliberately does not include. Defer adjacent generality unless correctness requires it now.

## Implement from semantics to execution

Apply only the layers needed by the slice, in this order:

1. Update syntax and typed AST only when source syntax changes.
2. Lower into HIR and resolve names without leaking parser trivia into semantic passes.
3. Type-check accepted operations and produce one useful diagnostic rather than cascades.
4. Enforce moves, borrows, `mut`, `take`, branch merging, and return ownership before code generation.
5. Extend code generation and the runtime ABI together. Respect the target calling convention; use a caller-provided return slot when a multiword value cannot be returned directly.
6. Emit cleanup on every normal control-flow path affected by the feature.
7. Update tests and documentation in the same slice.

Avoid letting code generation become the first place an invalid Halo program is rejected. Codegen checks may defend invariants but must not substitute for semantic diagnostics.

## Maintain ownership and allocation invariants

For every non-copy value, distinguish semantic responsibility from physical allocation:

- Static data may be owned as a value while requiring no deallocation.
- A heap-producing operation must identify one drop responsibility.
- A move, `take` call, or owned return transfers that responsibility; it must neither duplicate nor release it early.
- Shared and `mut` calls borrow their arguments for the call and do not consume local ownership.
- Owned temporaries borrowed by an operation must be dropped after their last use.
- Live branch locals must be dropped at branch exit.
- If an outer value moves on only one continuing branch, release it on the other branch before merging and treat it as unavailable afterward.
- A terminating branch must clean its live values without poisoning ownership state on continuing branches.
- Normal function exits drop remaining owned locals in reverse declaration order.
- Abort-style panics do not run drops; document that process teardown reclaims memory.

Keep allocation policy below language semantics. Reuse the exercised `halo_alloc(size, align)` / `halo_dealloc(pointer, size, align)` boundary rather than adding another allocator path.

## Resist overengineering

Before finalizing, remove machinery that serves no current invariant or executable behavior. In particular, do not add these merely because they may be useful later:

- a second code-generation backend;
- a general lifetime-annotation or borrowed-return system;
- allocator selection or a public allocation API;
- a generic destructor framework with only one concrete resource type;
- user-type layout support unrelated to the slice;
- abstractions that only rename one call site.

Keep narrow target-specific code explicit when that makes the active ABI auditable. Generalize after a second real consumer reveals the shared shape.

## Verify proportionally

Run focused checks while iterating, then finish with the repository's full validation. In the current workspace use the reproducible environment when direct Cargo tools are unavailable:

```console
nix-shell --run 'cargo fmt --all'
nix-shell --run 'cargo clippy --workspace --all-targets -- -D warnings'
nix-shell --run 'cargo test --workspace --all-targets'
```

For native/runtime changes, include integration coverage for:

- successful stdout, stderr, and exit status;
- rejected source programs and stable diagnostic codes;
- moves through locals, calls, branches, and returns;
- owned and non-allocating static values;
- nested and borrowed temporaries;
- panic or invalid-runtime requests;
- allocator alignment and zero-size behavior where applicable.

Compile C runtime harnesses with warnings enabled. Run `git diff --check`, review the complete diff, and confirm documentation no longer describes the previous implementation.

## Commit and hand off

For requested Halo changes, treat the implementation request as authorization to commit the completed, validated slice; do not wait for separate commit permission. Read-only reviews and status reports do not require a commit. Stage only files that belong to the active slice, preserve unrelated or user-authored changes, and keep each commit coherent. Describe the user-visible slice, not an internal substep. If a commit cannot be created, report the blocker explicitly instead of silently leaving the work uncommitted.

Report:

- the implemented behavior;
- the key safety and ABI decisions;
- validation commands and outcomes;
- the commit hash when committed;
- remaining deliberate limitations and the smallest sensible next slice.
