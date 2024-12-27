return {
  -- Make sure JDTLS is enabled in LazyVim's LSP servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jdtls = {
          -- The Mason-installed JDTLS automatically found by lspconfig
          -- We just override the `cmd` to add Lombok:
          cmd = {
            -- 1) Java on your system (check `java --version`)
            "java",

            -- 2) Lombok javaagent
            "-javaagent:" .. vim.fn.expand("~/.local/share/java/lombok.jar"),

            -- 3) Standard JDTLS/Eclipse arguments
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "--add-modules=ALL-SYSTEM",
            "--add-opens=java.base/java.lang=ALL-UNNAMED",

            -- 4) The Equinox launcher from Mason’s JDTLS:
            "-jar",
            vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),

            -- 5) The OS-specific config directory (mac, linux, or win)
            "-configuration",
            vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls/config_mac"),

            -- 6) The workspace folder (change as desired)
            "-data",
            vim.fn.expand("~/.cache/jdtls-workspace"),
          },
        },
      },
    },
  },
}
