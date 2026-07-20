{
  programs.nixvim.extraConfigLua = ''
    vim.diagnostic.config({
      virtual_text = { prefix = "●", spacing = 2 },
      update_in_insert = true,
      severity_sort = true,
      underline = true,
      signs = true,
    })

    local autosave_group = vim.api.nvim_create_augroup("nixvim_autosave", { clear = true })
    vim.api.nvim_create_autocmd("FocusLost", {
      group = autosave_group,
      pattern = "*",
      command = "silent! wa",
    })

    local function lsp_on_attach(_, bufnr)
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end
          map("n", "K", vim.lsp.buf.hover, "Hover docs")
          map("n", "gd", vim.lsp.buf.definition, "Goto definition")
          map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
          map("n", "gi", vim.lsp.buf.implementation, "Goto implementation")
          map("n", "gr", vim.lsp.buf.references, "References")
          map("n", "U", function()
            local ok_telescope, builtin = pcall(require, "telescope.builtin")
            if ok_telescope then
              builtin.lsp_references()
            else
              vim.lsp.buf.references()
            end
          end, "Show usages")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        end

        if vim.g.__nixvim_lsp_attached ~= true then
          vim.g.__nixvim_lsp_attached = true
          local function lsp_clients_supporting(bufnr, method)
            local clients = {}

            for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
              if client.supports_method and client:supports_method(method, { bufnr = bufnr }) then
                table.insert(clients, client)
              end
            end

            return clients
          end

          local function find_lsp_symbols(scope)
            local bufnr = vim.api.nvim_get_current_buf()
            local method = scope == "workspace" and "workspace/symbol" or "textDocument/documentSymbol"
            local telescope_builtin = require("telescope.builtin")
            local picker = scope == "workspace"
              and telescope_builtin.lsp_dynamic_workspace_symbols
              or telescope_builtin.lsp_document_symbols

            if #lsp_clients_supporting(bufnr, method) == 0 then
              vim.wait(2000, function()
                return #lsp_clients_supporting(bufnr, method) > 0
              end, 100)
            end

            local symbol_clients = lsp_clients_supporting(bufnr, method)
            if #symbol_clients == 0 then
              local attached_clients = vim.iter(vim.lsp.get_clients({ bufnr = bufnr }))
                :map(function(client)
                  return client.name
                end)
                :totable()

              local message
              if #attached_clients == 0 then
                message = "No LSP client attached to the current buffer"
              else
                message = string.format(
                  "Attached LSP clients do not support %s: %s",
                  method,
                  table.concat(attached_clients, ", ")
                )
              end

              vim.notify(string.format("[lsp-symbols] %s", message), vim.log.levels.WARN)
              return
            end

            picker()
          end

          _G.find_document_symbols = function()
            find_lsp_symbols("document")
          end

          _G.find_workspace_symbols = function()
            find_lsp_symbols("workspace")
          end

          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              lsp_on_attach(nil, args.buf)
            end,
          })
        end

        local ok_notify, notify = pcall(require, "notify")
        if ok_notify then
          notify.setup({ background_colour = "#1e1e2e" })
          vim.notify = notify
        end

        local ok_snacks, snacks = pcall(require, "snacks")
        if ok_snacks then
          snacks.setup({
            input = {
              enabled = true,
            },
            picker = {
              enabled = true,
            },
            terminal = {
              enabled = true,
            },
          })
        end

        local ok_wk, wk = pcall(require, "which-key")
        if ok_wk then
          wk.add({
            { "<leader>a", group = "Actions" },
            { "<leader>d", group = "Diagnostics" },
            { "<leader>f", group = "Files" },
            { "<leader>g", group = "Git" },
            { "<leader>gh", group = "Git Hunks" },
            { "<leader>gt", group = "Git Toggles" },
            { "<leader>w", group = "Windows" },
          })
        end

        local ok_alpha, alpha = pcall(require, "alpha")
        if ok_alpha then
          local dashboard = require("alpha.themes.dashboard")

          local header_lines = nil
          local function gen_banner(cmd)
            local h = io.popen(cmd)
            if not h then return nil end
            local out = h:read("*a") or ""
            h:close()
            if #out == 0 then return nil end
            local lines = {}
            for line in out:gmatch("([^\n]*)\n?") do
              if line ~= "" then table.insert(lines, line) end
            end
            return #lines > 0 and lines or nil
          end

          header_lines = gen_banner("toilet -f ansi-shadow NIXVIM 2>/dev/null")
            or gen_banner("figlet -f \"ANSI Shadow\" NIXVIM 2>/dev/null")
            or gen_banner("figlet NIXVIM 2>/dev/null")
            or { "NIXVIM" }

          dashboard.section.header.val = header_lines
          dashboard.section.buttons.val = {
            dashboard.button("f", "Find file", ":Telescope find_files<CR>"),
            dashboard.button("r", "Recent files", ":Telescope oldfiles<CR>"),
            dashboard.button("g", "Live grep", ":Telescope live_grep<CR>"),
            dashboard.button("n", "New file", ":enew<CR>"),
            dashboard.button("e", "File browser", ":Neotree toggle<CR>"),
            dashboard.button("q", "Quit", ":qa<CR>"),
          }

          local v = vim.version()
          dashboard.section.footer.val = string.format("NixVim | Neovim %d.%d.%d", v.major, v.minor, v.patch)
          dashboard.opts.opts.noautocmd = true
          alpha.setup(dashboard.config)

          vim.api.nvim_create_autocmd("FileType", {
            pattern = "alpha",
            callback = function()
              vim.opt_local.foldenable = false
            end,
          })
        end
  '';
}
