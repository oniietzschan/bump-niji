max_line_length = false
allow_defined = false -- Do NOT allow implicitly defined globals.
allow_defined_top = false -- Do NOT allow implicitly defined globals.

files = {
  ['bump-niji.lua'] = {
    std = 'luajit',
  },
  ['main.lua'] = {
    std = 'luajit+love',
  },
  ['spec/*'] = {
    std = 'luajit+busted',
  },
}

exclude_files = {
  'lua_install/*', -- CI: hererocks
  'demolibs/*',
  'bump-original.lua',
}
