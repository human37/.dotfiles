vim.env.JDTLS_JVM_ARGS = "-javaagent:" .. vim.fn.expand("~/.local/share/nvim/mason/packages/lombok-nightly/lombok.jar")

local function get_project_java_version()
    local tool_versions_path = vim.fn.getcwd() .. "/.tool-versions"
    local file = io.open(tool_versions_path, "r")

    if file then
        for line in file:lines() do
            local java_ver = line:match("^java%s+(.+)$")
            if java_ver then
                file:close()
                local major_version = java_ver:match("^corretto%-(%d+)") or java_ver:match("^temurin%-(%d+)") or
                                          java_ver:match("^openjdk%-(%d+)") or java_ver:match("^java%s+openjdk%-(%d+)") or
                                          "21"
                local java_path = vim.fn.expand("~/.asdf/installs/java/" .. java_ver)
                vim.notify("found java version: " .. java_ver .. " (major version: " .. major_version .. ")",
                    vim.log.levels.INFO)
                return {
                    name = "JavaSE-" .. major_version,
                    path = java_path
                }
            end
        end
        file:close()
    end

    return {
        name = "JavaSE-17",
        path = vim.fn.expand("~/.asdf/installs/java/temurin-17.0.9+9")
    }
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

local function setup_workspace()
    local workspace_path = vim.fn.expand("~/.cache/jdtls/workspace")
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local project_path = workspace_path .. "/" .. project_name

    -- Create workspace directory structure
    local dirs = {workspace_path, project_path, project_path .. "/.metadata", project_path .. "/.metadata/.plugins",
                  project_path .. "/.metadata/.plugins/org.eclipse.core.resources",
                  project_path .. "/.metadata/.plugins/org.eclipse.jdt.core"}

    for _, dir in ipairs(dirs) do
        vim.fn.mkdir(dir, "p")
        os.execute(string.format("chmod 755 %s", vim.fn.shellescape(dir)))
    end

    return project_path
end

-- Store the Java version info once
local java_version = get_project_java_version()

return {{
    "nvim-java/nvim-java",
    ft = {"java"},
    lazy = true,
    dependencies = {"nvim-java/lua-async-await", "nvim-java/nvim-java-core", "nvim-java/nvim-java-test",
                    "nvim-java/nvim-java-dap", "MunifTanjim/nui.nvim", "neovim/nvim-lspconfig",
                    "williamboman/mason.nvim"},
    opts = {
        jdk = {
            auto_discover = true
        },
        jdtls = {
            setup = {
                cmd = function()
                    local mason_registry = require("mason-registry")
                    local jdtls = mason_registry.get_package("jdtls")
                    local jdtls_path = jdtls:get_install_path()

                    local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
                    if launcher == "" then
                        -- Trigger reinstall if launcher is missing
                        vim.notify("JDTLS launcher not found. Reinstalling...", vim.log.levels.INFO)
                        jdtls:uninstall()
                        jdtls:install()
                        launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
                    end

                    return {"java", "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                            "-Dosgi.bundles.defaultStartLevel=4", "-Declipse.product=org.eclipse.jdt.ls.core.product",
                            "-Dlog.protocol=true", "-Dlog.level=ALL", "-Xmx1g", "--add-modules=ALL-SYSTEM",
                            "--add-opens", "java.base/java.util=ALL-UNNAMED", "--add-opens",
                            "java.base/java.lang=ALL-UNNAMED", "-jar", launcher, "-configuration",
                            jdtls_path .. "/config_mac", "-data", vim.fn.expand("~/.cache/jdtls/workspace")}
                end
            },
            handlers = {
                ["$/progress"] = function(_, result)
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
                end
            },
            root_dir = function()
                return require("jdtls.setup").find_root({"pom.xml", "gradle.build", ".git"})
            end,
            settings = {
                java = {
                    configuration = {
                        runtimes = {{
                            name = java_version.name,
                            path = java_version.path
                        }}
                    },
                    project = {
                        referencedLibraries = {"lib/**/*.jar"}
                    },
                    eclipse = {
                        downloadSources = true
                    },
                    maven = {
                        downloadSources = true
                    },
                    implementationsCodeLens = {
                        enabled = true
                    },
                    referencesCodeLens = {
                        enabled = true
                    },
                    format = {
                        enabled = true
                    }
                }
            }
        }
    }
}}
