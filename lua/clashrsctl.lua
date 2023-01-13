local M = {}

M.ip = nil
M.port = nil
M.delay = nil
M.url = nil


M.get_executable = function ()
    local ip, port
    if M.ip == nil then
        ip = ""
    end
    if M.port == nil then
        port = ""
    end

    return "clashrs-ctl " .. ip .. " " .. port .. " "
end

M.parse_proxy = function (line)
    local sep = string.find(line, ": \"")
    local proxy = string.sub(line, 1, sep - 1)
    local type_orig = string.sub(line, sep + 2)
    local type = string.gsub(type_orig, "\"", "")
    return {
        name = proxy,
        type = type,
    }
end

M.get_proxy_list = function ()
    local executable = M.get_executable()
    local command = "proxy list"
    local fd = io.popen(executable .. command, "r")
    local ret = {}
    for line in fd:lines() do
        table.insert(ret, M.parse_proxy(line))
    end

    return ret
end

M.change_selected_proxy = function (selector, new_proxy)
    local executable = M.get_executable()
    local command = "proxy change " .. selector .. " " .. new_proxy

    local suc, _, _ = os.execute(executable .. command)
    return suc
end

M.setup = function (opts)
    M.ip = opts.ip
    M.port = opts.port
    M.delay = opts.delay or 500
    M.url = opts.url or "http://google.com"
end

return M

