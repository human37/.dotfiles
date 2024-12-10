vim.env.JDTLS_JVM_ARGS = "-javaagent:" .. vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls/lombok.jar")

local function get_project_java_version()
  local tool_versions_path = vim.fn.getcwd() .. "/.tool-versions"
  local file = io.open(tool_versions_path, "r")

  if file then
    for line in file:lines() do
      local java_ver = line:match("^java%s+(.+)$")
      if java_ver then
        file:close()
        local major_version = java_ver:match("^corretto%-(%d+)") or java_ver:match("^temurin%-(%d+)") or "21"
        local java_path = vim.fn.expand("~/.asdf/installs/java/" .. java_ver)
        vim.notify(
          "found java version: " .. java_ver .. " (major version: " .. major_version .. ")",
          vim.log.levels.INFO
        )
        return {
          name = "JavaSE-" .. major_version,
          path = java_path,
        }
      end
    end
    file:close()
  end

  return {
    name = "JavaSE-17",
    path = vim.fn.expand("~/.asdf/installs/java/temurin-17.0.9+9"),
  }
end

local function ensure_lombok()
  local lombok_path = vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls/lombok.jar")
  if vim.fn.filereadable(lombok_path) == 0 then
    vim.fn.mkdir(vim.fn.fnamemodify(lombok_path, ":h"), "p")
    local lombok_url = "https://projectlombok.org/downloads/lombok.jar"
    vim.notify("downloading lombok...", vim.log.levels.INFO)
    vim.fn.system({ "curl", "-L", lombok_url, "-o", lombok_path })
    if vim.fn.filereadable(lombok_path) == 1 then
      vim.notify("lombok downloaded successfully", vim.log.levels.INFO)
    else
      vim.notify("failed to download lombok", vim.log.levels.ERROR)
    end
  end
  return lombok_path
end

local function get_jdtls_config_dir()
  if vim.fn.has("mac") == 1 then
    if vim.fn.system("uname -m"):find("arm64") then
      return "config_mac_arm"
    else
      return "config_mac"
    end
  elseif vim.fn.has("unix") == 1 then
    if vim.fn.system("uname -m"):find("aarch64") then
      return "config_linux_arm"
    else
      return "config_linux"
    end
  else
    return "config_win"
  end
end

return {
  {
    "nvim-java/nvim-java",
    ft = { "java" },
    lazy = true,
    dependencies = {
      "nvim-java/lua-async-await",
      "nvim-java/nvim-java-core",
      "nvim-java/nvim-java-test",
      "nvim-java/nvim-java-dap",
      "nvim-java/nvim-java-refactor",
      "MunifTanjim/nui.nvim",
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
      {
        "williamboman/mason.nvim",
        opts = {
          ensure_installed = {
            "java-debug-adapter",
            "java-test",
          },
          max_concurrent_installers = 10,
        },
      },
    },
    opts = {
      jdk = {
        auto_discover = true,
      },
      jdtls = {
        handlers = {
          ["$/progress"] = function(_, result, ctx)
            if result then
              local value = result.value or {}
              if not value.kind then
                return
              end

              local message = value.message or ""
              local percentage = value.percentage or 0
              local title = value.title or ""

              if message ~= "" or title ~= "" then
                vim.notify(string.format("%s: %s (%d%%)", title, message, percentage), vim.log.levels.INFO)
              end
            end
          end,
        },
        cmd = function()
          return {
            "jdtls",
            "--jvm-arg=-javaagent:" .. ensure_lombok(),
            "-configuration",
            vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls/" .. get_jdtls_config_dir()),
            "-data",
            vim.fn.expand("~/.cache/jdtls-workspace/") .. vim.fn.getcwd():gsub("/", "_"),
            "--jvm-arg=-XX:+UseParallelGC",
            "--jvm-arg=-XX:GCTimeRatio=4",
            "--jvm-arg=-XX:AdaptiveSizePolicyWeight=90",
            "--jvm-arg=-Dsun.zip.disableMemoryMapping=true",
            "--jvm-arg=-Xmx1G",
            "--jvm-arg=-Xms100m",
            "--jvm-arg=-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "--jvm-arg=-Dosgi.bundles.defaultStartLevel=4",
            "--jvm-arg=-Declipse.product=org.eclipse.jdt.ls.core.product",
            "--jvm-arg=-Dlog.protocol=true",
            "--jvm-arg=-Dlog.level=ALL",
            "--jvm-arg=--add-modules=ALL-SYSTEM",
            "--jvm-arg=--add-opens",
            "--jvm-arg=java.base/java.util=ALL-UNNAMED",
            "--jvm-arg=--add-opens",
            "--jvm-arg=java.base/java.lang=ALL-UNNAMED",
          }
        end,
        root_dir = function()
          return vim.fs.dirname(vim.fs.find({ "pom.xml", "gradle.build", ".git" }, { upward = true })[1])
        end,
        settings = {
          java = {
            configuration = {
              runtimes = {
                get_project_java_version(),
              },
            },
            compiler = {
              annotationProcessing = {
                enabled = true,
              },
            },
            project = {
              referencedLibraries = {
                ensure_lombok(),
              },
            },
            jdt = {
              ls = {
                lombokSupport = {
                  enabled = true,
                },
              },
            },
          },
        },
        init_options = {
          bundles = {},
          extendedClientCapabilities = {
            progressReportProvider = false,
          },
        },
      },
      dap = {
        config_overrides = {},
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      dap.configurations.java = {
        {
          type = "java",
          request = "attach",
          name = "Debug (Attach) - Remote",
          hostName = "127.0.0.1",
          port = 5005,
        },
      }
    end,
  },
}
