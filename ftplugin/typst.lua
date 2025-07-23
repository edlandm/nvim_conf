require 'config.mappings'.map { mode = 'n', buffer = true,
  { 'Compile and open', '<F5>', ':!typst compile % %:p:s?typ?pdf?;click %:p:s?typ?pdf?<cr>' }
}
