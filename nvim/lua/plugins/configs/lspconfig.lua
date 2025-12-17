-- Configure lua_ls
vim.lsp.config.lua_ls = {
    cmd = { "lua-language-server" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
    filetypes = { "lua" },
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
                disable = { "different-requires" },
            },
        },
    },
}

-- Configure rust_analyzer
vim.lsp.config.rust_analyzer = {
    cmd = { "rust-analyzer" },
    root_markers = { "Cargo.toml", "rust-project.json" },
    filetypes = { "rust" },
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                features = "all",
            },
        },
    },
}

-- Configure gopls
vim.lsp.config.gopls = {
    cmd = { "gopls" },
    root_markers = { "go.work", "go.mod", ".git" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
}

-- Enable the LSP servers
vim.lsp.enable({ "lua_ls", "rust_analyzer", "gopls" })
