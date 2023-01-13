local M = {}

M.get_executable = function ()
    return string.format("clashrs-ctl -a %s -p %d ", Clash_ip, Clash_port)
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

M.delay_test = function(proxy)
    local executable = M.get_executable()
    local command = string.format("proxy delay %s %s %d", proxy, Clash_url, Clash_delay)

    vim.notify(executable .. command)
    local fd = io.popen(executable .. command, "r")
    local ret = fd:read()

    if ret == nil or string.len(ret) == 0 then
        ret = "TimeOut"
    end

    return ret
end

M.setup = function (opts)
    Clash_ip = opts.ip or "127.0.0.1"
    Clash_port = opts.port or 9090
    Clash_delay = opts.delay or 500
    Clash_url = opts.url or "http://google.com"
end

return M

