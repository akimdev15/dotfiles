-- ============================================================================
-- Centralized config flags
-- Toggle Rust-backed / daemon-backed tools without touching plugin specs.
-- Set any flag to false to fall back to the canonical default.
-- ============================================================================
return {
  -- Master flag. When false all use_* flags below are forced false.
  prefer_rust   = true,

  -- Identical-output speedups (safe defaults)
  use_prettierd = true,   -- daemon prettier (Node) — same output, ~10x faster
  use_taplo     = true,   -- Rust TOML formatter — no current TOML coverage

  -- Output-differing swaps (opt-in)
  use_biome     = false,  -- Rust JS/TS/JSON formatter (replaces prettier)
  use_dprint    = false,  -- Rust JSON/MD/YAML/TOML formatter
}
