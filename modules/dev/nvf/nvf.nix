{
  inputs,
  pkgs,
  lib,
  spec,
  ...
}: {
  environment.systemPackages = with pkgs; [
    alejandra
    basedpyright
    clang-tools
    cargo-nextest
    delve
    fd
    gleam
    go
    gofumpt
    gopls
    gotestsum
    lldb
    python313Packages.debugpy
    ruff
    uv
    cargo
    rustc
    rust-analyzer
    stylua
  ];

  home-manager.users.${spec.user} = {...}: {
    imports = [inputs.nvf.homeManagerModules.nvf];

    programs.nvf = {
      enable = true;

      settings.vim = {
        viAlias = true;
        vimAlias = true;
        syntaxHighlighting = true;

        options = {
          number = true;
          relativenumber = true;
          signcolumn = "yes";
          expandtab = true;
          shiftwidth = 2;
          tabstop = 2;
          softtabstop = 2;
          wrap = false;
          termguicolors = true;
          clipboard = "unnamedplus";
          mouse = "a";
          mousemoveevent = true;
          updatetime = 250;
          timeoutlen = 400;
          splitbelow = true;
          splitright = true;
          cursorline = true;
        };

        theme.enable = false;
        telescope.enable = false;
        filetree.neo-tree.enable = false;
        binds.whichKey.enable = true;
        statusline.lualine.enable = false;

        extraPlugins = {
          catppuccin = {
            package = pkgs.vimPlugins.catppuccin-nvim;
          };
          plenary = {
            package = pkgs.vimPlugins.plenary-nvim;
          };
          nui = {
            package = pkgs.vimPlugins.nui-nvim;
          };
          mini-icons = {
            package = pkgs.vimPlugins.mini-icons;
          };
          smear-cursor = {
            package = pkgs.vimPlugins.smear-cursor-nvim;
          };
          mini-pairs = {
            package = pkgs.vimPlugins.mini-pairs;
          };
          mini-ai = {
            package = pkgs.vimPlugins.mini-ai;
          };
          mini-surround = {
            package = pkgs.vimPlugins.mini-surround;
          };
          mini-move = {
            package = pkgs.vimPlugins.mini-move;
          };
          mini-operators = {
            package = pkgs.vimPlugins.mini-operators;
          };
          mini-splitjoin = {
            package = pkgs.vimPlugins.mini-splitjoin;
          };
          mini-bracketed = {
            package = pkgs.vimPlugins.mini-bracketed;
          };
          mini-animate = {
            package = pkgs.vimPlugins.mini-animate;
          };
          mini-align = {
            package = pkgs.vimPlugins.mini-align;
          };
          mini-hipatterns = {
            package = pkgs.vimPlugins.mini-hipatterns;
          };
          mini-trailspace = {
            package = pkgs.vimPlugins.mini-trailspace;
          };
          mini-visits = {
            package = pkgs.vimPlugins.mini-visits;
          };
          harpoon2 = {
            package = pkgs.vimPlugins.harpoon2;
          };
          hardtime = {
            package = pkgs.vimPlugins.hardtime-nvim;
          };
          diffview = {
            package = pkgs.vimPlugins.diffview-nvim;
          };
          lualine = {
            package = pkgs.vimPlugins.lualine-nvim;
          };
          mini-files = {
            package = pkgs.vimPlugins.mini-files;
          };
          flash = {
            package = pkgs.vimPlugins.flash-nvim;
          };
          trouble = {
            package = pkgs.vimPlugins.trouble-nvim;
          };
          todo-comments = {
            package = pkgs.vimPlugins.todo-comments-nvim;
          };
          conform = {
            package = pkgs.vimPlugins.conform-nvim;
          };
          nvim-lint = {
            package = pkgs.vimPlugins.nvim-lint;
          };
          grug-far = {
            package = pkgs.vimPlugins.grug-far-nvim;
          };
          project = {
            package = pkgs.vimPlugins.project-nvim;
          };
          mini-comment = {
            package = pkgs.vimPlugins.mini-comment;
          };
          mini-sessions = {
            package = pkgs.vimPlugins.mini-sessions;
          };
          lazydev = {
            package = pkgs.vimPlugins.lazydev-nvim;
          };
          luasnip = {
            package = pkgs.vimPlugins.luasnip;
          };
          friendly-snippets = {
            package = pkgs.vimPlugins.friendly-snippets;
          };
          neotest = {
            package = pkgs.vimPlugins.neotest;
          };
          neotest-python = {
            package = pkgs.vimPlugins.neotest-python;
          };
          neotest-go = {
            package = pkgs.vimPlugins.neotest-go;
          };
          neotest-rust = {
            package = pkgs.vimPlugins.neotest-rust;
          };
          outline = {
            package = pkgs.vimPlugins.outline-nvim;
          };
          nvim-ufo = {
            package = pkgs.vimPlugins.nvim-ufo;
          };
          promise-async = {
            package = pkgs.vimPlugins.promise-async;
          };
          refactoring = {
            package = pkgs.vimPlugins.refactoring-nvim;
          };
          bqf = {
            package = pkgs.vimPlugins.nvim-bqf;
          };
          overseer = {
            package = pkgs.vimPlugins.overseer-nvim;
          };
          neogen = {
            package = pkgs.vimPlugins.neogen;
          };
          undotree = {
            package = pkgs.vimPlugins.undotree;
          };
          treesitter-context = {
            package = pkgs.vimPlugins.nvim-treesitter-context;
          };
          dap-virtual-text = {
            package = pkgs.vimPlugins.nvim-dap-virtual-text;
          };
          treesitter-textobjects = {
            package = pkgs.vimPlugins.nvim-treesitter-textobjects;
          };
          render-markdown = {
            package = pkgs.vimPlugins.render-markdown-nvim;
          };
          noice = {
            package = pkgs.vimPlugins.noice-nvim;
          };
          rustaceanvim = {
            package = pkgs.vimPlugins.rustaceanvim;
          };
        };

        tabline.nvimBufferline = {
          enable = true;
          setupOpts = {
            options = {
              diagnostics = "nvim_lsp";
              always_show_bufferline = false;
              show_buffer_close_icons = false;
              show_close_icon = false;
              separator_style = "thin";
            };
          };
        };

        git = {
          enable = true;
          gitsigns = {
            enable = true;
            codeActions.enable = true;
            setupOpts = {
              current_line_blame = true;
              current_line_blame_opts = {
                virt_text = true;
                virt_text_pos = "eol";
                delay = 300;
              };
              signs = {
                add = {text = "▎";};
                change = {text = "▎";};
                delete = {text = "";};
                topdelete = {text = "";};
                changedelete = {text = "▎";};
                untracked = {text = "▎";};
              };
            };
          };
        };

        lsp = {
          enable = true;
          formatOnSave = false;
          lightbulb.enable = true;
          lspkind.enable = false;
          lspSignature.enable = false;
        };

        autocomplete.blink-cmp = {
          enable = true;
          setupOpts = {
            keymap = {
              "<C-Space>" = ["show" "show_documentation" "hide_documentation"];
              "<C-n>" = ["select_next"];
              "<C-p>" = ["select_prev"];
              "<C-f>" = ["scroll_documentation_down"];
              "<C-b>" = ["scroll_documentation_up"];
              "<C-y>" = ["select_and_accept"];
              "<Tab>" = ["select_next" "fallback"];
              "<S-Tab>" = ["select_prev" "fallback"];
              "<CR>" = ["accept" "fallback"];
              "<C-e>" = ["hide" "cancel"];
            };

            completion = {
              trigger = {
                show_on_keyword = true;
                show_on_trigger_character = true;
                show_on_insert = false;
              };

              list = {
                selection = {
                  preselect = true;
                  auto_insert = false;
                };
              };

              menu = {
                enabled = true;
                auto_show = true;
                auto_show_delay_ms = 0;
                min_width = 28;
                max_height = 10;
                border = "rounded";
                scrollbar = true;
                direction_priority = ["s" "n"];
                draw = {
                  padding = 1;
                  gap = 1;
                  columns = [
                    ["kind_icon"]
                    ["label" "label_description"]
                    ["kind"]
                  ];
                };
              };

              documentation = {
                auto_show = true;
                auto_show_delay_ms = 80;
                update_delay_ms = 50;
                window = {
                  min_width = 24;
                  max_width = 64;
                  max_height = 18;
                  border = "rounded";
                  scrollbar = true;
                };
              };

              ghost_text = {
                enabled = false;
              };
            };

            signature = {
              enabled = true;
              trigger = {
                show_on_keyword = false;
                show_on_trigger_character = true;
                show_on_insert = false;
                show_on_insert_on_trigger_character = true;
                show_on_accept = true;
                show_on_accept_on_trigger_character = true;
              };
              window = {
                border = "rounded";
                min_width = 24;
                max_width = 64;
                max_height = 14;
              };
            };

            appearance = {
              use_nvim_cmp_as_default = false;
              nerd_font_variant = "mono";
            };

            sources = {
              default = ["lazydev" "lsp" "path" "snippets" "buffer"];
              providers = {
                lazydev = {
                  name = "LazyDev";
                  module = "lazydev.integrations.blink";
                  score_offset = 100;
                };
              };
            };

            snippets = {
              preset = "luasnip";
            };
          };
        };

        utility = {
          snacks-nvim = {
            enable = true;
            setupOpts = {
              bigfile.enabled = true;
              notifier.enabled = true;
              quickfile.enabled = true;
              dashboard.enabled = false;
              explorer.enabled = true;
              picker.enabled = true;
              indent.enabled = true;
              input.enabled = true;
              scope.enabled = true;
              scroll.enabled = true;
              words.enabled = true;
              terminal = {
                enabled = true;
                win.bo.buflisted = false;
              };
              toggle.enabled = true;
              zen.enabled = true;
              statuscolumn.enabled = true;
              lazygit.enabled = true;
              dim.enabled = true;
              rename.enabled = true;
            };
          };

          smart-splits.enable = true;
        };

        dashboard.alpha.enable = true;

        visuals = {
          nvim-web-devicons.enable = true;
          highlight-undo.enable = true;
          fidget-nvim.enable = true;
          indent-blankline.enable = false;
        };

        debugger.nvim-dap = {
          enable = true;
          ui.enable = true;
        };

        ui.borders = {
          enable = true;
          globalStyle = "rounded";
        };

        languages = {
          enableTreesitter = true;
          enableFormat = true;

          nix = {
            enable = true;
            lsp = {
              enable = true;
              servers = ["nixd"];
            };
            treesitter.enable = true;
            format = {
              enable = true;
              type = ["alejandra"];
            };
          };

          rust = {
            enable = true;
            lsp.enable = false;
            treesitter.enable = true;
            format = {
              enable = true;
              type = ["rustfmt"];
            };
          };

          python = {
            enable = true;
            lsp = {
              enable = true;
              servers = ["basedpyright"];
            };
            treesitter.enable = true;
            format = {
              enable = true;
              type = ["ruff"];
            };
          };

          clang = {
            enable = true;
            lsp = {
              enable = true;
              servers = ["clangd"];
            };
            treesitter.enable = true;
          };

          gleam = {
            enable = true;
            lsp.enable = true;
            treesitter.enable = true;
          };

          go = {
            enable = true;
            lsp = {
              enable = true;
              servers = ["gopls"];
            };
            treesitter.enable = true;
            format = {
              enable = true;
              type = ["gofumpt"];
            };
          };
        };

        luaConfigRC.dashboard = ''
          local alpha = require("alpha")
          local dashboard = require("alpha.themes.dashboard")

          local logo = [[

          ███████╗██╗   ██╗ █████╗ ███████╗ ██████╗
          ██╔════╝██║   ██║██╔══██╗╚══███╔╝██╔═══██╗
          ███████╗██║   ██║███████║  ███╔╝ ██║   ██║
          ╚════██║██║   ██║██╔══██║ ███╔╝  ██║   ██║
          ███████║╚██████╔╝██║  ██║███████╗╚██████╔╝
          ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝

          ]]

          dashboard.section.header.val = vim.split(logo, "\n")
          dashboard.section.header.opts.hl = "AlphaHeader"

          dashboard.section.buttons.val = {
            dashboard.button("f", "  Find File", "<cmd>lua require('snacks').picker.files()<cr>"),
            dashboard.button("g", "  Find Text", "<cmd>lua require('snacks').picker.grep()<cr>"),
            dashboard.button("r", "  Recent Files", "<cmd>lua require('snacks').picker.recent()<cr>"),
            dashboard.button("e", "  Explorer", "<cmd>lua require('mini.files').open()<cr>"),
            dashboard.button("c", "  Config", "<cmd>lua require('snacks').picker.files({ cwd = vim.fn.stdpath('config') })<cr>"),
            dashboard.button("s", "  Restore Session", "<cmd>lua require('mini.sessions').read()<cr>"),
            dashboard.button("q", "  Quit", "<cmd>qa<cr>"),
          }

          for _, button in ipairs(dashboard.section.buttons.val) do
            button.opts.hl = "AlphaButtons"
            button.opts.hl_shortcut = "AlphaShortcut"
          end

          dashboard.opts.layout[1].val = 8
          alpha.setup(dashboard.opts)
        '';

        luaConfigRC.theme = ''
          require("catppuccin").setup({
            flavour = "mocha",
            color_overrides = {
              mocha = {
                base = "#000000",
                mantle = "#000000",
                crust = "#000000",
              },
            },
            integrations = {
              blink_cmp = true,
              lualine = true,
              gitsigns = true,
              treesitter = true,
              native_lsp = {
                enabled = true,
                underlines = {
                  errors = { "undercurl" },
                  hints = { "undercurl" },
                  warnings = { "undercurl" },
                  information = { "undercurl" },
                },
              },
              which_key = true,
              dap = { enabled = true, enable_ui = true },
              fidget = true,
              mini = { enabled = true },
              snacks = true,
            },
          })
          vim.cmd.colorscheme("catppuccin")

          local ui = {
            bg = "#000000",
            panel = "#0a0a0a",
            panel_alt = "#111111",
            border = "#2a2a2a",
            border_bright = "#ffffff",
            fg = "#d6d6d6",
            text = "#b8b8b8",
            muted = "#7a7a7a",
            subtle = "#4e4e4e",
            bright = "#ffffff",
          }

          local set_hl = vim.api.nvim_set_hl
          local groups = {
            Normal = { fg = ui.fg, bg = ui.bg },
            NormalNC = { fg = ui.fg, bg = ui.bg },
            NormalFloat = { fg = ui.fg, bg = ui.panel },
            FloatBorder = { fg = ui.border_bright, bg = ui.panel },
            FloatTitle = { fg = ui.bright, bg = ui.panel },
            CmdLine = { fg = ui.bright, bg = ui.panel_alt },
            MsgArea = { fg = ui.bright, bg = ui.bg },
            SignColumn = { bg = ui.bg },
            LineNr = { fg = ui.subtle, bg = ui.bg },
            CursorLineNr = { fg = ui.bright, bg = ui.bg, bold = true },
            CursorLine = { bg = ui.panel },
            CursorColumn = { bg = ui.panel },
            EndOfBuffer = { fg = ui.bg, bg = ui.bg },
            VertSplit = { fg = ui.border, bg = ui.bg },
            WinSeparator = { fg = ui.border, bg = ui.bg },
            StatusLine = { fg = ui.fg, bg = ui.panel_alt },
            StatusLineNC = { fg = ui.muted, bg = ui.panel },
            TabLine = { fg = ui.muted, bg = ui.panel },
            TabLineFill = { bg = ui.bg },
            TabLineSel = { fg = ui.bright, bg = ui.panel_alt, bold = true },
            Pmenu = { fg = ui.text, bg = ui.panel },
            PmenuSel = { fg = ui.bright, bg = ui.panel_alt, bold = true },
            PmenuSbar = { bg = ui.panel_alt },
            PmenuThumb = { bg = ui.border },
            Folded = { fg = ui.muted, bg = ui.panel },
            FoldColumn = { fg = ui.subtle, bg = ui.bg },
            Visual = { fg = ui.bg, bg = ui.fg },
            VisualNOS = { fg = ui.bg, bg = ui.fg },
            Search = { fg = ui.bg, bg = "#cfcfcf" },
            IncSearch = { fg = ui.bg, bg = ui.bright },
            DiagnosticVirtualTextError = { fg = "#b0b0b0", bg = ui.panel },
            DiagnosticVirtualTextWarn = { fg = "#a0a0a0", bg = ui.panel },
            DiagnosticVirtualTextInfo = { fg = "#9a9a9a", bg = ui.panel },
            DiagnosticVirtualTextHint = { fg = "#8c8c8c", bg = ui.panel },
            WhichKey = { fg = ui.bright },
            WhichKeyGroup = { fg = ui.text },
            WhichKeyDesc = { fg = ui.fg },
            WhichKeySeparator = { fg = ui.subtle },
            WhichKeyFloat = { bg = ui.panel },
            SnacksNormal = { fg = ui.fg, bg = ui.panel },
            SnacksPicker = { fg = ui.fg, bg = ui.panel },
            SnacksPickerBorder = { fg = ui.border_bright, bg = ui.panel },
            SnacksPickerInput = { fg = ui.bright, bg = ui.panel_alt },
            SnacksPickerInputBorder = { fg = ui.border_bright, bg = ui.panel_alt },
            SnacksPickerTitle = { fg = ui.bright, bg = ui.panel },
            SnacksNotifierBorderDebug = { fg = ui.border_bright, bg = ui.panel },
            SnacksNotifierBorderError = { fg = ui.border_bright, bg = ui.panel },
            SnacksNotifierBorderInfo = { fg = ui.border_bright, bg = ui.panel },
            SnacksNotifierBorderTrace = { fg = ui.border_bright, bg = ui.panel },
            SnacksNotifierBorderWarn = { fg = ui.border_bright, bg = ui.panel },
            NoiceCmdline = { fg = ui.bright, bg = ui.panel_alt },
            NoiceCmdlinePopup = { fg = ui.bright, bg = ui.panel_alt },
            NoiceCmdlinePopupBorder = { fg = ui.border_bright, bg = ui.panel_alt },
            NoiceCmdlineIcon = { fg = ui.bright, bg = ui.panel_alt },
            NoicePopupmenu = { fg = ui.bright, bg = ui.panel },
            NoicePopupmenuBorder = { fg = ui.border_bright, bg = ui.panel },
            TroubleNormal = { fg = ui.fg, bg = ui.panel },
            TroubleNormalNC = { fg = ui.fg, bg = ui.panel },
            TroublePreview = { fg = ui.fg, bg = ui.panel },
            OilDir = { fg = ui.bright, bg = ui.bg, bold = true },
            OilDirHidden = { fg = ui.text, bg = ui.bg },
            OilDirIcon = { fg = ui.bright, bg = ui.bg },
            AlphaHeader = { fg = ui.bright, bg = ui.bg, bold = true },
            AlphaButtons = { fg = ui.text, bg = ui.bg },
            AlphaShortcut = { fg = ui.bright, bg = ui.bg, bold = true },
            AlphaFooter = { fg = ui.muted, bg = ui.bg },
          }

          for group, opts in pairs(groups) do
            set_hl(0, group, opts)
          end

          vim.api.nvim_create_autocmd("FileType", {
            pattern = "minifiles",
            callback = function(args)
              local win = vim.fn.bufwinid(args.buf)
              if win ~= -1 then
                vim.api.nvim_set_hl(0, "FloatBorder", { fg = ui.border_bright, bg = ui.panel })
                vim.wo[win].winhighlight = "FloatBorder:FloatBorder,NormalFloat:NormalFloat"
              end
            end,
          })
        '';

        luaConfigRC.rustaceanvim = ''
          local blink_ok, blink = pcall(require, "blink.cmp")
          local ra_caps = blink_ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

          vim.g.rustaceanvim = {
            server = {
              capabilities = ra_caps,
              settings = {
                ["rust-analyzer"] = {
                  cargo = {
                    allFeatures = true,
                    buildScripts = { enable = true },
                  },
                  check = {
                    enable = true,
                    command = "clippy",
                    extraArgs = { "--no-deps" },
                  },
                  procMacro = { enable = true },
                  inlayHints = {
                    bindingModeHints = { enable = false },
                    closureReturnTypeHints = { enable = "never" },
                    lifetimeElisionHints = { enable = "never" },
                    parameterHints = { enable = true },
                    typeHints = { enable = true },
                    maxLength = 25,
                  },
                },
              },
              on_attach = function(_, bufnr)
                local map = function(lhs, rhs, desc)
                  vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
                end
                map("K", function() vim.cmd("RustLsp hover actions") end, "Rust Hover Actions")
                map("<leader>cR", function() vim.cmd("RustLsp runnables") end, "Rust Runnables")
                map("<leader>cD", function() vim.cmd("RustLsp debuggables") end, "Rust Debuggables")
                map("<leader>cE", function() vim.cmd("RustLsp expandMacro") end, "Expand Macro")
                map("<leader>cO", function() vim.cmd("RustLsp openDocs") end, "Open Docs.rs")
                map("<leader>ce", function() vim.cmd("RustLsp explainError") end, "Explain Error")
                map("<leader>cg", function() vim.cmd("RustLsp crateGraph") end, "Crate Graph")
              end,
            },
            tools = {
              hover_actions = { auto_focus = true },
              float_win_config = { border = "rounded" },
            },
            dap = {
              adapter = {
                type = "executable",
                command = "${pkgs.lldb}/bin/lldb-dap",
                name = "lldb",
              },
            },
          }
        '';

        luaConfigRC.treesitter-textobjects = ''
          vim.api.nvim_create_autocmd("VimEnter", {
            once = true,
            callback = function()
              local ok, configs = pcall(require, "nvim-treesitter.configs")
              if not ok then return end
              configs.setup({
                textobjects = {
                  select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                      ["ac"] = { query = "@class.outer", desc = "around class" },
                      ["ic"] = { query = "@class.inner", desc = "inside class" },
                      ["af"] = { query = "@function.outer", desc = "around function" },
                      ["if"] = { query = "@function.inner", desc = "inside function" },
                    },
                  },
                  move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                      ["]f"] = { query = "@function.outer", desc = "Next function" },
                      ["]c"] = { query = "@class.outer", desc = "Next class" },
                    },
                    goto_next_end = {
                      ["]F"] = { query = "@function.outer", desc = "Next function end" },
                      ["]C"] = { query = "@class.outer", desc = "Next class end" },
                    },
                    goto_previous_start = {
                      ["[f"] = { query = "@function.outer", desc = "Prev function" },
                      ["[c"] = { query = "@class.outer", desc = "Prev class" },
                    },
                    goto_previous_end = {
                      ["[F"] = { query = "@function.outer", desc = "Prev function end" },
                      ["[C"] = { query = "@class.outer", desc = "Prev class end" },
                    },
                  },
                  swap = {
                    enable = true,
                    swap_next = {
                      ["<leader>cp"] = { query = "@parameter.inner", desc = "Swap next parameter" },
                    },
                    swap_previous = {
                      ["<leader>cP"] = { query = "@parameter.inner", desc = "Swap prev parameter" },
                    },
                  },
                },
              })
            end,
          })
        '';

        luaConfigRC.lualine-custom = ''
          require("lualine").setup({
            options = {
              theme = "auto",
              component_separators = { left = "|", right = "|" },
              section_separators = { left = "", right = "" },
              globalstatus = true,
              disabled_filetypes = {
                statusline = { "dashboard", "alpha", "snacks_dashboard", "minifiles" },
              },
            },
            sections = {
              lualine_a = { "mode" },
              lualine_b = { "branch", "diff" },
              lualine_c = {
                { "diagnostics", symbols = { error = " ", warn = " ", info = " ", hint = " " } },
                { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
                { "filename", path = 1 },
              },
              lualine_x = { "encoding", "fileformat" },
              lualine_y = { "progress" },
              lualine_z = { "location" },
            },
          })
        '';

        luaConfigRC.extra-plugins = ''
          package.preload["lazy.stats"] = function()
            return {
              stats = function()
                return {
                  count = 0,
                  loaded = 0,
                  startuptime = 0,
                }
              end,
            }
          end

          package.preload["lazy.status"] = function()
            return {
              has_updates = function()
                return false
              end,
              updates = function()
                return ""
              end,
            }
          end

          vim.g.mapleader = " "
          vim.g.maplocalleader = "\\"
          vim.o.laststatus = 3

          local function map(mode, lhs, rhs, desc, opts)
            opts = opts or {}
            opts.desc = desc
            vim.keymap.set(mode, lhs, rhs, opts)
          end

          local function command(cmd)
            return function()
              vim.cmd(cmd)
            end
          end

          local function has(module)
            local ok = pcall(require, module)
            return ok
          end

          local Snacks = require("snacks")
          local uv = vim.uv or vim.loop
          Snacks.config.terminal = vim.tbl_deep_extend("force", Snacks.config.terminal or {}, {
            win = { bo = { buflisted = false } },
          })

          local function picker(method, opts)
            return function()
              local fn = Snacks.picker and Snacks.picker[method]
              if fn then
                fn(opts or {})
              else
                vim.notify("Snacks picker '" .. method .. "' is unavailable", vim.log.levels.WARN)
              end
            end
          end

          local function trouble(mode)
            return function()
              vim.cmd("Trouble " .. mode .. " toggle")
            end
          end

          local function trouble_cmd(cmd)
            return function()
              vim.cmd(cmd)
            end
          end

          local function open_root_terminal(cmd)
            local root = Snacks.git.get_root() or uv.cwd()
            if cmd then
              Snacks.terminal(cmd, { cwd = root })
            else
              Snacks.terminal(nil, { cwd = root })
            end
          end

          local autoformat_global = true
          local autoformat_buffer = {}

          local function format(buf, injected)
            buf = buf or vim.api.nvim_get_current_buf()
            local ok, conform = pcall(require, "conform")
            if ok then
              if injected then
                conform.format({ bufnr = buf, formatters = { "injected" }, timeout_ms = 3000 })
              else
                conform.format({ bufnr = buf, timeout_ms = 3000, lsp_format = "fallback" })
              end
              return
            end
            vim.lsp.buf.format({ bufnr = buf })
          end

          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("lazyvim-like-format", { clear = true }),
            callback = function(args)
              if autoformat_global and autoformat_buffer[args.buf] ~= false then
                format(args.buf)
              end
            end,
          })

          local function toggle_bool(opt, on, off)
            local value = vim.opt_local[opt]:get()
            if value == on then
              vim.opt_local[opt] = off
            else
              vim.opt_local[opt] = on
            end
          end

          local function buffer_delete(force)
            if Snacks.bufdelete then
              Snacks.bufdelete(0, { force = force or false })
            else
              vim.cmd(force and "bdelete!" or "bdelete")
            end
          end

          local function toggle_zoom()
            local win = vim.api.nvim_get_current_win()
            if vim.t.lazyvim_zoom_win and vim.api.nvim_win_is_valid(vim.t.lazyvim_zoom_win) then
              vim.cmd(vim.t.lazyvim_zoom_restore)
              vim.t.lazyvim_zoom_win = nil
              vim.t.lazyvim_zoom_restore = nil
            else
              vim.t.lazyvim_zoom_win = win
              vim.t.lazyvim_zoom_restore = vim.fn.winrestcmd()
              vim.cmd("wincmd |")
              vim.cmd("wincmd _")
            end
          end

          require("mini.icons").setup({})

          require("smear_cursor").setup({
            stiffness = 0.8,
            trailing_stiffness = 0.5,
            distance_stop_animating = 0.5,
          })

          require("mini.pairs").setup({
            modes = { insert = true, command = true, terminal = false },
            skip_next = [=[[%w%%%'%[%%"%.%`%$]]=],
            skip_ts = { "string" },
            skip_unbalanced = true,
            markdown = true,
          })
          local luasnip = require("luasnip")
          require("luasnip.loaders.from_vscode").lazy_load()
          luasnip.config.setup({
            history = true,
            delete_check_events = "TextChanged",
          })
          require("mini.ai").setup({ n_lines = 500 })
          require("mini.surround").setup()
          require("flash").setup({})
          require("trouble").setup({
            modes = {
              lsp = {
                win = { position = "right" },
              },
            },
          })
          require("todo-comments").setup({})
          require("mini.comment").setup({})
          require("mini.move").setup({})
          require("mini.operators").setup({})
          require("mini.splitjoin").setup({})
          require("mini.bracketed").setup({})
          require("mini.animate").setup({
            open = { enable = false },
            close = { enable = false },
          })
          require("mini.align").setup({})
          require("mini.trailspace").setup({})
          require("mini.visits").setup({})
          require("mini.hipatterns").setup({
            highlighters = {
              hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
            },
          })
          require("harpoon"):setup({})
          require("hardtime").setup({ enabled = true })
          require("mini.sessions").setup({
            autoread = false,
            autowrite = true,
            directory = vim.fn.stdpath("data") .. "/sessions",
          })
          require("grug-far").setup({ headerMaxWidth = 80 })
          require("project").setup({
            manual_mode = false,
            detection_methods = { "lsp", "pattern" },
            patterns = { ".git", "flake.nix", "package.json", "pyproject.toml", "go.mod", "Cargo.toml" },
            silent_chdir = true,
            scope_chdir = "global",
          })
          require("bqf").setup({})
          require("overseer").setup({})
          require("outline").setup({
            outline_window = {
              position = "right",
              width = 28,
              auto_jump = false,
              show_numbers = false,
              show_relative_numbers = false,
            },
            preview_window = {
              auto_preview = false,
            },
            symbols = {
              follow_cursor = true,
            },
          })
          require("ufo").setup({
            provider_selector = function(_, _, _)
              return { "treesitter", "indent" }
            end,
          })
          require("treesitter-context").setup({
            enable = true,
            max_lines = 3,
            multiline_threshold = 2,
            trim_scope = "outer",
          })
          require("refactoring").setup({})
          require("neogen").setup({ snippet_engine = "luasnip" })
          require("neotest").setup({
            adapters = {
              require("neotest-python")({
                dap = { justMyCode = false },
                runner = "pytest",
              }),
              require("neotest-go")({
                experimental = { test_table = true },
                args = { "-count=1" },
              }),
              require("neotest-rust")({
                args = { "--no-capture" },
                dap_adapter = "lldb",
              }),
            },
            summary = { open = "botright vsplit | vertical resize 45" },
            output = { open_on_run = false },
            output_panel = { open = "botright split | resize 12" },
            quickfix = { open = false },
          })
          require("noice").setup({
            notify = { enabled = false },
            lsp = {
              override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
              },
            },
            routes = {
              {
                filter = {
                  event = "msg_show",
                  any = {
                    { find = "%d+L, %d+B" },
                    { find = "; after #%d+" },
                    { find = "; before #%d+" },
                  },
                },
                view = "mini",
              },
            },
            presets = {
              bottom_search = true,
              command_palette = true,
              long_message_to_split = true,
            },
          })

          require("conform").setup({
            default_format_opts = {
              timeout_ms = 3000,
              async = false,
              quiet = false,
              lsp_format = "fallback",
            },
            formatters_by_ft = {
              lua = { "stylua" },
              nix = { "alejandra" },
              python = { "ruff_format" },
              rust = { "rustfmt" },
              go = { "gofumpt" },
              sh = { "shfmt" },
              bash = { "shfmt" },
              zsh = { "shfmt" },
            },
            formatters = {
              injected = { options = { ignore_errors = true } },
            },
          })
          require("lint").linters_by_ft = {
            python = { "ruff" },
            sh = { "shellcheck" },
            bash = { "shellcheck" },
            zsh = { "shellcheck" },
          }
          vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            callback = function()
              require("lint").try_lint()
            end,
          })
          require("nvim-dap-virtual-text").setup({})
          require("lazydev").setup({
            library = {
              { path = "''${3rd}/luv/library", words = { "vim%.uv" } },
              { path = "snacks.nvim", words = { "Snacks" } },
              { path = "nvim-lspconfig", words = { "lspconfig.settings" } },
            },
          })
          vim.o.autoread = true
          vim.o.foldcolumn = "1"
          vim.o.foldlevel = 99
          vim.o.foldlevelstart = 99
          vim.o.foldenable = true

          require("snacks").statuscolumn.setup()

          require("render-markdown").setup({
            enabled = true,
            render_modes = { "n", "c", "t" },
            heading = {
              sign = false,
              icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
            },
            code = {
              sign = false,
              width = "block",
              right_pad = 1,
            },
            dash = { width = 80 },
            bullet = { right_pad = 1 },
          })

          require("diffview").setup({
            enhanced_diff_hl = true,
          })

          local dap = require("dap")
          local dapui_ok, dapui = pcall(require, "dapui")
          if dapui_ok then
            dap.listeners.after.event_initialized["dapui_config"] = function()
              dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
              dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
              dapui.close()
            end
          end

          dap.adapters.python = {
            type = "executable",
            command = "${pkgs.python313Packages.debugpy}/bin/debugpy-adapter",
          }
          dap.configurations.python = {
            {
              type = "python",
              request = "launch",
              name = "Launch file",
              program = "''${file}",
              pythonPath = function()
                return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python"
              end,
            },
            {
              type = "python",
              request = "launch",
              name = "Pytest current file",
              module = "pytest",
              args = { vim.fn.expand("%") },
              justMyCode = false,
            },
          }

          dap.adapters.go = {
            type = "server",
            port = "''${port}",
            executable = {
              command = "${pkgs.delve}/bin/dlv",
              args = { "dap", "-l", "127.0.0.1:''${port}" },
            },
          }
          dap.configurations.go = {
            {
              type = "go",
              name = "Debug file",
              request = "launch",
              program = "''${file}",
            },
            {
              type = "go",
              name = "Debug package",
              request = "launch",
              program = "''${fileDirname}",
            },
            {
              type = "go",
              name = "Debug test",
              request = "launch",
              mode = "test",
              program = "''${file}",
            },
          }

          dap.adapters.lldb = {
            type = "executable",
            command = "${pkgs.lldb}/bin/lldb-dap",
            name = "lldb",
          }
          local lldb_config = {
            {
              name = "Launch executable",
              type = "lldb",
              request = "launch",
              program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
              end,
              cwd = "''${workspaceFolder}",
              stopOnEntry = false,
              args = {},
            },
          }
          dap.configurations.c = lldb_config
          dap.configurations.cpp = lldb_config

          require("mini.files").setup({
            windows = {
              preview = true,
              width_focus = 30,
              width_preview = 50,
            },
            options = {
              use_as_default_explorer = false,
              permanent_delete = false,
            },
          })

          vim.opt.winborder = "rounded"

          vim.diagnostic.config({
            virtual_text = false,
            float = { border = "rounded", source = "if_many" },
            underline = true,
            signs = true,
            severity_sort = true,
            update_in_insert = false,
          })

          vim.api.nvim_create_autocmd("CursorHold", {
            callback = function()
              vim.diagnostic.open_float(nil, { focus = false })
            end,
          })

          local hover_opts = {
            border = "rounded",
            max_width = 72,
            max_height = 20,
            silent = true,
            focusable = false,
            close_events = { "CursorMoved", "InsertEnter", "BufHidden" },
          }

          local signature_opts = {
            border = "rounded",
            max_width = 72,
            max_height = 16,
            silent = true,
            focusable = false,
            close_events = { "CursorMoved", "BufHidden", "InsertLeave" },
          }

          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if not client then return end
              if client.supports_method("textDocument/inlayHint") then
                vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
              end
            end,
          })

          vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, hover_opts)
          vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, signature_opts)

          local wk = require("which-key")
          wk.add({
            { "<leader><tab>", group = "tabs" },
            { "<leader>b", group = "buffer" },
            { "<leader>h", group = "harpoon" },
            { "<leader>c", group = "code" },
            { "<leader>cp", group = "swap" },
            { "<leader>cR", group = "rust" },
            { "<leader>d", group = "debug" },
            { "<leader>dp", group = "profiler" },
            { "<leader>f", group = "file/find" },
            { "<leader>g", group = "git" },
            { "<leader>gh", group = "hunks" },
            { "<leader>o", group = "open/outline/tasks" },
            { "<leader>q", group = "quit/session" },
            { "<leader>r", group = "refactor" },
            { "<leader>s", group = "search" },
            { "<leader>sn", group = "noice" },
            { "<leader>t", group = "test" },
            { "<leader>u", group = "ui" },
            { "<leader>w", group = "window" },
            { "<leader>x", group = "diagnostics/quickfix" },
            { "[", group = "prev" },
            { "]", group = "next" },
            { "g", group = "goto" },
            { "gs", group = "surround" },
          })

          map({ "i", "n", "s" }, "<esc>", function()
            vim.cmd("noh")
            return "<esc>"
          end, "Escape and Clear hlsearch", { expr = true })

          map({ "i", "x", "n", "s" }, "<C-s>", function()
            vim.cmd("silent! write")
          end, "Save File")
          map({ "i", "s" }, "<C-l>", function()
            if luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            end
          end, "Snippet Jump Forward")
          map({ "i", "s" }, "<C-h>", function()
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            end
          end, "Snippet Jump Backward")

          map("n", "<C-h>", "<C-w>h", "Go to Left Window")
          map("n", "<C-j>", "<C-w>j", "Go to Lower Window")
          map("n", "<C-k>", "<C-w>k", "Go to Upper Window")
          map("n", "<C-l>", "<C-w>l", "Go to Right Window")
          map("n", "<C-Up>", command("resize +2"), "Increase Window Height")
          map("n", "<C-Down>", command("resize -2"), "Decrease Window Height")
          map("n", "<C-Left>", command("vertical resize -2"), "Decrease Window Width")
          map("n", "<C-Right>", command("vertical resize +2"), "Increase Window Width")
          map("n", "<leader><tab>f", "<cmd>BufferLineGoToBuffer 1<cr>", "First Buffer")
          map("n", "<leader><tab>l", "<cmd>lua require('bufferline').go_to(-1, true)<cr>", "Last Buffer")
          map("n", "<leader><tab><tab>", "<cmd>enew<cr>", "New Buffer")
          map("n", "<leader><tab>]", "<cmd>BufferLineCycleNext<cr>", "Next Buffer")
          map("n", "<leader><tab>[", "<cmd>BufferLineCyclePrev<cr>", "Prev Buffer")
          map("n", "<leader><tab>d", "<cmd>bd<cr>", "Close Buffer")

          map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", "Prev Buffer")
          map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", "Next Buffer")
          map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", "Prev Buffer")
          map("n", "]b", "<cmd>BufferLineCycleNext<cr>", "Next Buffer")
          map("n", "[B", "<cmd>BufferLineMovePrev<cr>", "Move buffer prev")
          map("n", "]B", "<cmd>BufferLineMoveNext<cr>", "Move buffer next")

          map("n", "K", function()
            vim.lsp.buf.hover(hover_opts)
          end, "Hover")
          map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
          map("n", "gr", vim.lsp.buf.references, "References")
          map("n", "gI", vim.lsp.buf.implementation, "Goto Implementation")
          map("n", "gy", vim.lsp.buf.type_definition, "Goto Type Definition")
          map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
          map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
          map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
          map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
          map("n", "<leader>cl", command("LspInfo"), "Lsp Info")
          map("n", "<leader>cd", function()
            vim.diagnostic.open_float(nil, { border = "rounded", scope = "line" })
          end, "Line Diagnostics")
          map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
          map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
          map("n", "]e", function()
            vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
          end, "Next Error")
          map("n", "[e", function()
            vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
          end, "Prev Error")
          map("n", "]w", function()
            vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
          end, "Next Warning")
          map("n", "[w", function()
            vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
          end, "Prev Warning")

          map({ "n", "x" }, "s", function() require("flash").jump() end, "Flash")
          map({ "n", "o", "x" }, "S", function() require("flash").treesitter() end, "Flash Treesitter")
          map("o", "r", function() require("flash").remote() end, "Remote Flash")
          map({ "o", "x" }, "R", function() require("flash").treesitter_search() end, "Treesitter Search")
          map("c", "<C-s>", function() require("flash").toggle() end, "Toggle Flash Search")
          map({ "n", "o", "x" }, "<C-Space>", function()
            require("flash").treesitter({
              actions = {
                ["<C-Space>"] = "next",
                ["<BS>"] = "prev",
              },
            })
          end, "Treesitter Incremental Selection")

          map("n", "<leader><space>", picker("files"), "Find Files (Root Dir)")
          map("n", "<leader>,", picker("buffers"), "Buffers")
          map("n", "<leader>/", picker("grep"), "Grep (Root Dir)")
          map("n", "<leader>:", picker("command_history"), "Command History")
          map("n", "<leader>.", function() Snacks.scratch() end, "Toggle Scratch Buffer")
          map("n", "<leader>S", function() Snacks.scratch.select() end, "Select Scratch Buffer")
          local function mini_files_open(path)
            local mf = require("mini.files")
            if not mf.close() then mf.open(path) end
          end
          map("n", "<leader>e", function()
            local path = vim.api.nvim_buf_get_name(0)
            mini_files_open(vim.fn.filereadable(path) == 1 and path or vim.fn.getcwd())
          end, "Explorer")
          map("n", "<leader>E", function() mini_files_open(vim.fn.getcwd()) end, "Explorer (cwd)")
          map("n", "<leader>ff", picker("files"), "Find Files (Root Dir)")
          map("n", "<leader>fF", picker("files", { cwd = false }), "Find Files (cwd)")
          map("n", "<leader>fg", picker("git_files"), "Find Files (git-files)")
          map("n", "<leader>fr", picker("recent"), "Recent")
          map("n", "<leader>fR", picker("recent", { filter = { cwd = true } }), "Recent (cwd)")
          map("n", "<leader>fb", picker("buffers"), "Buffers")
          map("n", "<leader>fB", picker("buffers", { all = true }), "Buffers (all)")
          map("n", "<leader>fc", picker("files", { cwd = vim.fn.stdpath("config") }), "Find Config File")
          map("n", "<leader>fe", function()
            local path = vim.api.nvim_buf_get_name(0)
            mini_files_open(vim.fn.filereadable(path) == 1 and path or vim.fn.getcwd())
          end, "Explorer")
          map("n", "<leader>fE", function() mini_files_open(vim.fn.getcwd()) end, "Explorer (cwd)")
          map("n", "<leader>fp", picker("projects"), "Projects")
          map("n", "<leader>fT", function() Snacks.terminal(nil, { cwd = vim.loop.cwd() }) end, "Terminal (cwd)")
          map("n", "<leader>ft", function() Snacks.terminal() end, "Terminal (Root Dir)")
          map("n", "-", function()
            local path = vim.api.nvim_buf_get_name(0)
            mini_files_open(vim.fn.filereadable(path) == 1 and path or vim.fn.getcwd())
          end, "Explorer")
          map({ "n", "t" }, "<C-/>", function() Snacks.terminal() end, "Terminal (Root Dir)")
          map({ "n", "t" }, "<C-_>", function() Snacks.terminal() end, "which_key_ignore")

          map("n", "<leader>sg", picker("grep"), "Grep (Root Dir)")
          map("n", "<leader>sG", picker("grep", { cwd = false }), "Grep (cwd)")
          map({ "n", "x" }, "<leader>sw", picker("grep_word"), "Visual selection or word (Root Dir)")
          map({ "n", "x" }, "<leader>sW", picker("grep_word", { cwd = false }), "Visual selection or word (cwd)")
          map("n", "<leader>sb", picker("lines"), "Buffer Lines")
          map("n", "<leader>sB", picker("grep_buffers"), "Grep Open Buffers")
          map("n", "<leader>sc", picker("command_history"), "Command History")
          map("n", "<leader>sC", picker("commands"), "Commands")
          map("n", "<leader>sd", picker("diagnostics"), "Diagnostics")
          map("n", "<leader>sD", picker("diagnostics_buffer"), "Buffer Diagnostics")
          map("n", "<leader>sh", picker("help"), "Help Pages")
          map("n", "<leader>sH", picker("highlights"), "Highlights")
          map("n", "<leader>sj", picker("jumps"), "Jumps")
          map("n", "<leader>sk", picker("keymaps"), "Keymaps")
          map("n", "<leader>sl", picker("loclist"), "Location List")
          map("n", "<leader>sm", picker("marks"), "Marks")
          map("n", "<leader>sq", picker("qflist"), "Quickfix List")
          map("n", "<leader>sR", picker("resume"), "Resume")
          map("n", "<leader>sr", function()
            require("grug-far").open({
              transient = true,
              prefills = {
                filesFilter = (vim.bo.buftype == "" and vim.fn.expand("%:e") ~= "") and ("*." .. vim.fn.expand("%:e")) or nil,
              },
            })
          end, "Search and Replace")
          map("n", "<leader>s\"", picker("registers"), "Registers")
          map("n", "<leader>s/", picker("search_history"), "Search History")
          map("n", "<leader>ss", picker("lsp_symbols"), "LSP Symbols")
          map("n", "<leader>sS", picker("lsp_workspace_symbols"), "LSP Workspace Symbols")

          map("n", "<leader>gd", picker("git_diff"), "Git Diff (hunks)")
          map("n", "<leader>gD", "<cmd>DiffviewOpen<cr>", "Git Diff (origin)")
          map("n", "<leader>gs", picker("git_status"), "Git Status")
          map("n", "<leader>gL", picker("git_log"), "Git Log (cwd)")
          map("n", "<leader>gl", picker("git_log_file"), "Git Log")
          map("n", "<leader>gb", function() require("gitsigns").blame_line({ full = true }) end, "Git Blame Line")
          map("n", "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", "Git Current File History")
          map("n", "<leader>gg", function() Snacks.lazygit() end, "LazyGit")
          map({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, "Git Browse")
          map({ "n", "x" }, "<leader>gY", function()
            vim.fn.setreg("+", vim.fn.expand("<cfile>"))
          end, "Git Browse (copy)")

          map("n", "[h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "[c", bang = true })
            else
              require("gitsigns").nav_hunk("prev")
            end
          end, "Prev Hunk")
          map("n", "]h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "]c", bang = true })
            else
              require("gitsigns").nav_hunk("next")
            end
          end, "Next Hunk")
          map("n", "[H", function() require("gitsigns").nav_hunk("first") end, "First Hunk")
          map("n", "]H", function() require("gitsigns").nav_hunk("last") end, "Last Hunk")
          map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
          map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
          map("n", "<leader>ghS", function() require("gitsigns").stage_buffer() end, "Stage Buffer")
          map("n", "<leader>ghu", function() require("gitsigns").undo_stage_hunk() end, "Undo Stage Hunk")
          map("n", "<leader>ghR", function() require("gitsigns").reset_buffer() end, "Reset Buffer")
          map("n", "<leader>ghp", function() require("gitsigns").preview_hunk_inline() end, "Preview Hunk Inline")
          map("n", "<leader>ghb", function() require("gitsigns").blame_line({ full = true }) end, "Blame Line")
          map("n", "<leader>ghB", function() require("gitsigns").blame() end, "Blame Buffer")
          map("n", "<leader>ghd", function() require("gitsigns").diffthis() end, "Diff This")
          map("n", "<leader>ghD", function() require("gitsigns").diffthis("~") end, "Diff This ~")
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")

          map("n", "<leader>xx", trouble("diagnostics"), "Diagnostics (Trouble)")
          map("n", "<leader>xX", trouble_cmd("Trouble diagnostics toggle filter.buf=0"), "Buffer Diagnostics (Trouble)")
          map("n", "<leader>cs", trouble("symbols"), "Symbols (Trouble)")
          map("n", "<leader>cS", trouble("lsp"), "LSP references/definitions/... (Trouble)")
          map("n", "<leader>xL", trouble("loclist"), "Location List (Trouble)")
          map("n", "<leader>xQ", trouble("qflist"), "Quickfix List (Trouble)")
          map("n", "[q", function()
            if require("trouble").is_open() then
              require("trouble").prev({ skip_groups = true, jump = true })
            else
              vim.cmd.cprev()
            end
          end, "Previous Trouble/Quickfix Item")
          map("n", "]q", function()
            if require("trouble").is_open() then
              require("trouble").next({ skip_groups = true, jump = true })
            else
              vim.cmd.cnext()
            end
          end, "Next Trouble/Quickfix Item")

          map("n", "]t", function() require("todo-comments").jump_next() end, "Next Todo Comment")
          map("n", "[t", function() require("todo-comments").jump_prev() end, "Previous Todo Comment")
          map("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", "Todo (Trouble)")
          map("n", "<leader>xT", "<cmd>Trouble todo toggle filter={tag={TODO,FIX,FIXME}}<cr>", "Todo/Fix/Fixme (Trouble)")
          map("n", "<leader>st", picker("todo_comments"), "Todo")
          map("n", "<leader>sT", picker("todo_comments", { keywords = { "TODO", "FIX", "FIXME" } }), "Todo/Fix/Fixme")

          local harpoon = require("harpoon")
          map("n", "<leader>ha", function() harpoon:list():add() end, "Harpoon Add")
          map("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, "Harpoon Menu")
          map("n", "<leader>1", function() harpoon:list():select(1) end, "Harpoon 1")
          map("n", "<leader>2", function() harpoon:list():select(2) end, "Harpoon 2")
          map("n", "<leader>3", function() harpoon:list():select(3) end, "Harpoon 3")
          map("n", "<leader>4", function() harpoon:list():select(4) end, "Harpoon 4")

          map("n", "<leader>bd", function() buffer_delete(false) end, "Delete Buffer")
          map("n", "<leader>bD", function() buffer_delete(true) end, "Delete Buffer and Window")
          map("n", "<leader>bo", function()
            local current = vim.api.nvim_get_current_buf()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(buf) and buf ~= current and vim.bo[buf].buflisted then
                if Snacks.bufdelete then
                  Snacks.bufdelete(buf)
                else
                  vim.cmd("bdelete " .. buf)
                end
              end
            end
          end, "Delete Other Buffers")
          map("n", "<leader>bb", "<C-^>", "Switch to Other Buffer")
          map("n", "<leader>`", "<C-^>", "Switch to Other Buffer")
          map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", "Toggle Pin")
          map("n", "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", "Delete Non-Pinned Buffers")
          map("n", "<leader>br", "<cmd>BufferLineCloseRight<cr>", "Delete Buffers to the Right")
          map("n", "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", "Delete Buffers to the Left")
          map("n", "<leader>bj", "<cmd>BufferLinePick<cr>", "Pick Buffer")

          map("n", "<leader>qs", function() require("mini.sessions").read() end, "Restore Session")
          map("n", "<leader>qS", function() require("mini.sessions").select() end, "Select Session")
          map("n", "<leader>ql", function() require("mini.sessions").read() end, "Restore Last Session")
          map("n", "<leader>qd", function() require("mini.sessions").stop_autosave() end, "Don't Save Current Session")
          map("n", "<leader>qq", command("qa"), "Quit All")
          map("n", "<leader>oO", command("Outline"), "Outline")
          map("n", "<leader>oo", function() require("overseer").toggle() end, "Task List")
          map("n", "<leader>or", function() require("overseer").run_template() end, "Run Task")
          map("n", "<leader>oq", function() require("overseer").quick_action() end, "Task Action")
          map("n", "<leader>ou", command("UndotreeToggle"), "Undo Tree")

          map("n", "<leader>cf", function() format() end, "Format")
          map({ "n", "x" }, "<leader>cF", function() format(0, true) end, "Format Injected Langs")
          map("n", "<leader>cc", function() if vim.lsp.codelens then vim.lsp.codelens.run() end end, "Run Codelens")
          map("n", "<leader>cC", function() if vim.lsp.codelens then vim.lsp.codelens.refresh() end end, "Refresh & Display Codelens")

          map("n", "<leader>fn", function() vim.cmd("enew") end, "New File")
          map("n", "<leader>tt", function() require("neotest").run.run() end, "Run Nearest Test")
          map("n", "<leader>tT", function() require("neotest").run.run(vim.fn.expand("%")) end, "Run File Tests")
          map("n", "<leader>ta", function() require("neotest").run.attach() end, "Attach To Test")
          map("n", "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, "Debug Nearest Test")
          map("n", "<leader>tD", function() require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" }) end, "Debug File Tests")
          map("n", "<leader>tl", function() require("neotest").run.run_last() end, "Run Last Test")
          map("n", "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, "Test Output")
          map("n", "<leader>tO", function() require("neotest").output_panel.toggle() end, "Test Output Panel")
          map("n", "<leader>ts", function() require("neotest").summary.toggle() end, "Test Summary")
          map("n", "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, "Test Watch File")
          map("n", "<leader>tv", function() require("neotest").jump.prev({ status = "failed" }) end, "Prev Failed Test")
          map("n", "<leader>tn", function() require("neotest").jump.next({ status = "failed" }) end, "Next Failed Test")
          map("n", "<leader>re", function() require("refactoring").refactor("Extract Function") end, "Extract Function")
          map("x", "<leader>re", function() require("refactoring").refactor("Extract Function") end, "Extract Function")
          map("x", "<leader>rf", function() require("refactoring").refactor("Extract Function To File") end, "Extract Function To File")
          map("x", "<leader>rv", function() require("refactoring").refactor("Extract Variable") end, "Extract Variable")
          map({ "n", "x" }, "<leader>ri", function() require("refactoring").refactor("Inline Variable") end, "Inline Variable")
          map("n", "<leader>rI", function() require("refactoring").refactor("Inline Function") end, "Inline Function")
          map("n", "<leader>rb", function() require("refactoring").refactor("Extract Block") end, "Extract Block")
          map("n", "<leader>rB", function() require("refactoring").refactor("Extract Block To File") end, "Extract Block To File")
          map("n", "<leader>cn", function() require("neogen").generate() end, "Generate Annotations")
          map("n", "<leader>db", function() require("dap").toggle_breakpoint() end, "Toggle Breakpoint")
          map("n", "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, "Breakpoint Condition")
          map("n", "<leader>dc", function() require("dap").continue() end, "Continue")
          map("n", "<leader>dC", function() require("dap").run_to_cursor() end, "Run to Cursor")
          map("n", "<leader>di", function() require("dap").step_into() end, "Step Into")
          map("n", "<leader>do", function() require("dap").step_over() end, "Step Over")
          map("n", "<leader>dO", function() require("dap").step_out() end, "Step Out")
          map("n", "<leader>dr", function() require("dap").repl.toggle() end, "Toggle REPL")
          map("n", "<leader>dl", function() require("dap").run_last() end, "Run Last")
          map("n", "<leader>du", function() if package.loaded.dapui then require("dapui").toggle() end end, "Toggle DAP UI")
          map("n", "<leader>dt", function() require("dap").terminate() end, "Terminate")
          map("n", "<leader>xl", command("lopen"), "Location List")
          map("n", "<leader>xq", command("copen"), "Quickfix List")
          map("n", "<leader>?", function() require("which-key").show({ global = false }) end, "Buffer Keymaps (which-key)")
          map("n", "<C-w><space>", function() require("which-key").show({ keys = "<C-w>", loop = true }) end, "Window Hydra Mode (which-key)")
          map("n", "<leader>-", "<C-W>s", "Split Window Below")
          map("n", "<leader>|", "<C-W>v", "Split Window Right")
          map("n", "<leader>ww", "<C-W>p", "Other Window")
          map("n", "<leader>wx", "<C-W>x", "Swap Window")
          map("n", "<leader>w-", "<C-W>s", "Split Window Below")
          map("n", "<leader>w|", "<C-W>v", "Split Window Right")
          map("n", "<leader>wh", "<C-W>h", "Go to Left Window")
          map("n", "<leader>wj", "<C-W>j", "Go to Lower Window")
          map("n", "<leader>wk", "<C-W>k", "Go to Upper Window")
          map("n", "<leader>wl", "<C-W>l", "Go to Right Window")
          map("n", "<leader>wd", "<C-W>c", "Delete Window")
          map("n", "<leader>wm", toggle_zoom, "Toggle Zoom Mode")
          map("n", "<leader>uZ", toggle_zoom, "Toggle Zoom Mode")
          map("n", "zR", function() require("ufo").openAllFolds() end, "Open All Folds")
          map("n", "zM", function() require("ufo").closeAllFolds() end, "Close All Folds")
          map("n", "zr", function() require("ufo").openFoldsExceptKinds() end, "Open Folds Except Kinds")
          map("n", "zm", function() require("ufo").closeFoldsWith() end, "Close Folds With")
          map("n", "zp", function()
            local winid = require("ufo").peekFoldedLinesUnderCursor()
            if not winid then
              vim.lsp.buf.hover()
            end
          end, "Peek Fold")

          map("n", "<leader>ur", function()
            vim.cmd("nohlsearch")
            vim.cmd("diffupdate")
            vim.cmd("normal! <C-L>")
          end, "Redraw / Clear hlsearch / Diff Update")
          map("n", "<leader>us", function() toggle_bool("spell", true, false) end, "Toggle Spelling")
          map("n", "<leader>uw", function() toggle_bool("wrap", true, false) end, "Toggle Wrap")
          map("n", "<leader>uL", function() toggle_bool("relativenumber", true, false) end, "Toggle Relative Number")
          map("n", "<leader>ud", function()
            if vim.diagnostic.is_enabled() then
              vim.diagnostic.enable(false)
            else
              vim.diagnostic.enable(true)
            end
          end, "Toggle Diagnostics")
          map("n", "<leader>ul", function() toggle_bool("number", true, false) end, "Toggle Line Numbers")
          map("n", "<leader>uc", function()
            if vim.wo.conceallevel > 0 then
              vim.wo.conceallevel = 0
            else
              vim.wo.conceallevel = 3
            end
          end, "Toggle Conceal Level")
          map("n", "<leader>uA", function()
            vim.o.showtabline = (vim.o.showtabline == 0) and 2 or 0
          end, "Toggle Tabline")
          map("n", "<leader>uT", function()
            local ok, ts = pcall(vim.treesitter.start)
            if ok then
              if vim.b.lazyvim_ts_disabled then
                vim.treesitter.start()
                vim.b.lazyvim_ts_disabled = false
              else
                vim.treesitter.stop()
                vim.b.lazyvim_ts_disabled = true
              end
            end
          end, "Toggle Treesitter Highlight")
          map("n", "<leader>ub", function()
            vim.o.background = (vim.o.background == "dark") and "light" or "dark"
          end, "Toggle Dark Background")
          map("n", "<leader>uf", function()
            autoformat_global = not autoformat_global
            vim.notify("Auto Format (Global): " .. (autoformat_global and "on" or "off"))
          end, "Toggle Auto Format (Global)")
          map("n", "<leader>uF", function()
            local buf = vim.api.nvim_get_current_buf()
            autoformat_buffer[buf] = not (autoformat_buffer[buf] ~= false)
            vim.notify("Auto Format (Buffer): " .. ((autoformat_buffer[buf] ~= false) and "on" or "off"))
          end, "Toggle Auto Format (Buffer)")
          map("n", "<leader>ug", function()
            vim.g.snacks_animate = not vim.g.snacks_animate
            if has("ibl") then
              local ibl = require("ibl")
              if vim.g.lazyvim_indent_disabled then
                ibl.setup_buffer(0, { enabled = true })
                vim.g.lazyvim_indent_disabled = false
              else
                ibl.setup_buffer(0, { enabled = false })
                vim.g.lazyvim_indent_disabled = true
              end
            end
          end, "Toggle Indent Guides")
          map("n", "<leader>uh", function()
            if vim.lsp.inlay_hint then
              local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
              vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
            end
          end, "Toggle Inlay Hints")
          map("n", "<leader>uG", function() require("gitsigns").toggle_signs() end, "Toggle Git Signs")
          map("n", "<leader>un", function() Snacks.notifier.hide() end, "Dismiss All Notifications")
          map("n", "<leader>uz", function() Snacks.zen() end, "Toggle Zen Mode")
          map("n", "<leader>uD", function() Snacks.dim() end, "Toggle Dim")
          map("n", "<leader>ut", function() require("mini.trailspace").trim() end, "Trim Trailing Whitespace")
          map("n", "<leader>fr", function() Snacks.rename.rename_file() end, "Rename File")
          map("c", "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, "Redirect Cmdline")
          map("n", "<leader>snl", function() require("noice").cmd("last") end, "Noice Last Message")
          map("n", "<leader>snh", function() require("noice").cmd("history") end, "Noice History")
          map("n", "<leader>sna", function() require("noice").cmd("all") end, "Noice All")
          map("n", "<leader>snd", function() require("noice").cmd("dismiss") end, "Dismiss All")
          map("n", "<C-f>", function()
            if not require("noice.lsp").scroll(4) then return "<C-f>" end
          end, "Scroll Forward", { expr = true, silent = true })
          map("n", "<C-b>", function()
            if not require("noice.lsp").scroll(-4) then return "<C-b>" end
          end, "Scroll Backward", { expr = true, silent = true })

          map("n", "<leader>n", function()
            if Snacks.config.picker and Snacks.config.picker.enabled and Snacks.picker.notifications then
              Snacks.picker.notifications()
            else
              Snacks.notifier.show_history()
            end
          end, "Notification History")

          map("n", "gco", function()
            local row = vim.api.nvim_win_get_cursor(0)[1]
            vim.api.nvim_buf_set_lines(0, row, row, false, { "" })
            vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
            require("mini.comment").toggle_lines(row + 1, row + 1)
            vim.schedule(function() vim.cmd("startinsert!") end)
          end, "Add Comment Below")
          map("n", "gcO", function()
            local row = vim.api.nvim_win_get_cursor(0)[1] - 1
            vim.api.nvim_buf_set_lines(0, row, row, false, { "" })
            vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
            require("mini.comment").toggle_lines(row + 1, row + 1)
            vim.schedule(function() vim.cmd("startinsert!") end)
          end, "Add Comment Above")
        '';
      };
    };
  };
}
