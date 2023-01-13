local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
-- local themes = require("telescope.themes")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local clashrsctl = require("clashrsctl")

local list_proxies = function (opts)
    opts = opts or {}
    return pickers.new(opts, {
        prompt_title = "Proxies",
        finder = finders.new_table {
            results = clashrsctl.get_proxy_list(),
            entry_maker = function (entry)
                return {
                    value = entry,
                    display = string.format("[%s]: %s", entry.type, entry.name),
                    ordinal = entry.type .. entry.name,
                }
            end
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function (prompt_bufnr, map)
            actions.select_default:replace(function ()
                actions.close(prompt_bufnr)
                local selected = action_state.get_selected_entry()
                local selected_name = selected.value.name
                local list = {}
                local n = 0
                local operations = clashrsctl_telescope_config.operation_map[selected.value.type]
                if operations ~= nil then
                    for k, v in pairs(operations) do
                        n = n + 1
                        list[n] = { k, v }
                    end
                end
                for k, v in pairs(clashrsctl_telescope_config.general_operations) do
                    n = n + 1
                    list[n] = { k, v }
                end

                if n == 0 then
                    vim.notify("No available operations")
                    return
                end
                local operation_picker = pickers.new(opts, {
                    prompt_title = "Selecte Operation",
                    finder = finders.new_table {
                        results = list,
                        entry_maker = function (entry)
                            return {
                                value = entry,
                                display = entry[1],
                                ordinal = entry[1],
                            }
                        end
                    },
                    sorter = conf.generic_sorter(opts),
                    attach_mappings = function (prompt_bufnr, map)
                        actions.select_default:replace(function ()
                            actions.close(prompt_bufnr)
                            local selected = action_state.get_selected_entry()
                            local operation = selected.value[2]
                            operation(selected_name, opts)
                        end)
                        return true
                    end
                }):find()
            end)
            return true
        end
    })
end

local select_new_proxy = function (selector, opts)
    opts = opts or {}
    return pickers.new(opts, {
        prompt_title = "Select_new_proxy",
        finder = finders.new_table {
            results = clashrsctl.get_proxy_list(),
            entry_maker = function (entry)
                return {
                    value = entry,
                    display = string.format("[%s]: %s", entry.type, entry.name),
                    ordinal = entry.type .. entry.name,
                }
            end
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function ()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                clashrsctl.change_selected_proxy(selector, selection.value.name)
                vim.notify(string.format("%s Change: %s", selector, selection.value.name))
            end)
            return true
        end
    })
end

clashrsctl_telescope_config = {
    operation_map = {
        Selector = {
            Change = function(selected, opts) select_new_proxy(selected, opts):find() end,
        }
    },
    general_operations = {
        Delay = function(selected, _)
            local res = clashrsctl.delay_test(selected)
            vim.notify(string.format("%s: %s", selected, res))
        end,
    }
}

return require("telescope").register_extension {
    setup = function(ext_config, config)
        -- pass
    end,
    exports = {
        clashrsctl = function (opts)
            list_proxies(opts):find()
        end,
    }
}
