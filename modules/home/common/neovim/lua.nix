{
  programs.nixvim.extraConfigLua = ''
    local function git_output(directory, args)
      local command = { "git", "-C", directory }
      vim.list_extend(command, args)
      local output = vim.fn.systemlist(command)
      return vim.v.shell_error == 0 and output[1] or nil
    end

    local function current_file_context()
      local file = vim.api.nvim_buf_get_name(0)
      if file == "" then
        vim.notify("Current buffer does not have a file", vim.log.levels.WARN)
        return nil
      end

      local root = git_output(vim.fs.dirname(file), { "rev-parse", "--show-toplevel" })
      if not root then
        vim.notify("Current file is not in a Git repository", vim.log.levels.WARN)
        return nil
      end

      return file, root, file:sub(#root + 2)
    end

local function copy_to_clipboard(value, label)
  vim.fn.setreg("+", value)
  vim.notify(label .. ": " .. value)
end

local function github_url_path(value)
  return (value:gsub("([^%w%-%._~/])", function(character)
    return string.format("%%%02X", string.byte(character))
  end))
end

_G.copy_repo_relative_file_path = function()
      local _, _, relative_path = current_file_context()
      if relative_path then
        copy_to_clipboard(relative_path, "Copied relative path")
      end
    end

    _G.copy_github_file_url = function()
      local _, root, relative_path = current_file_context()
      if not relative_path then
        return
      end

  local upstream = git_output(root, { "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}" })
  local remote_name
  local revision

  if upstream then
    remote_name, revision = upstream:match("^([^/]+)/(.+)$")
  end

  local remote = git_output(root, { "remote", "get-url", remote_name or "origin" })
  revision = revision or git_output(root, { "rev-parse", "HEAD" })
      if not remote or not revision then
        vim.notify("Could not determine the GitHub repository", vim.log.levels.WARN)
        return
      end

      local repository = remote:gsub("^git@github%.com:", "https://github.com/")
      repository = repository:gsub("^ssh://git@github%.com/", "https://github.com/")
      repository = repository:gsub("%.git$", "")
      if not vim.startswith(repository, "https://github.com/") then
        vim.notify("Origin remote is not hosted on GitHub", vim.log.levels.WARN)
        return
      end

  local line = vim.api.nvim_win_get_cursor(0)[1]
  copy_to_clipboard(
    string.format("%s/blob/%s/%s#L%d", repository, github_url_path(revision), github_url_path(relative_path), line),
    upstream and "Copied GitHub URL" or "Copied GitHub URL for current commit (push it if needed)"
  )
end

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
            image = {
              enabled = true,
              doc = {
                enabled = true,
                inline = true,
                float = true,
              },
            },
            terminal = {
              enabled = true,
            },
          })
        end

        local ok_wk, wk = pcall(require, "which-key")
        if ok_wk then
          vim.keymap.set("n", "<leader>?", function()
            wk.show({ global = false })
          end, { desc = "Buffer local keymaps" })

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
