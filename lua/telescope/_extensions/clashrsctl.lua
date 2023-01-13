local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local themes = require("telescope.themes")
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
                local gen_map = clashrsctl_telescope_config.picker_gen_map[selected.type]
                if gen_map == nil then
                    vim.notify("No available operations")
                    return
                end
                for k, v in pairs(gen_map) do
                    n = n + 1
                    list[n] = { k, v }
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
                            local picker_gen = selected.value[2]
                            picker_gen(selected_name, opts):find()
                        end)
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
            end)
        end
    })
end

clashrsctl_telescope_config = {
    picker_gen_map = {
        Selector = {
            Change = select_new_proxy,
        }
    }
}

return require("telescope").register_extension {
    setup = function(ext_config, config)
        -- pass
    end,
    exports = {
        clashrsctl = list_proxies,
    }
}
