-- ============================================================================
-- Shared color palette (Dracula)
-- Single source of truth for hex values hardcoded into highlight overrides
-- scattered across the config (autocmds.lua, plugins/ui.lua). Swapping the
-- colorscheme means updating this file instead of hunting through comments
-- for stray hex codes.
-- ============================================================================
return {
  bg         = '#282a36',
  selection  = '#44475a', -- Dracula's own Visual bg — subtle on a near-black background
  foreground = '#f8f8f2',
  comment    = '#6272a4',
  cyan       = '#8be9fd',
  green      = '#50fa7b',
  orange     = '#ffb86c',
  pink       = '#ff79c6',
  purple     = '#bd93f9',
  red        = '#ff5555',
  yellow     = '#f1fa8c',

  -- Brighter purple-blue used for high-contrast Visual-mode selection.
  -- Not a stock Dracula color — chosen to pop more than `selection` above.
  visual_selection = '#4d5277',
}
