local skynet = require 'skynet'
local cluster = require 'skynet.cluster'
require 'skynet.manager'

skynet.start(function ()
    cluster.reload({
        node1 = '127.0.0.1:7002',
        node2 = '127.0.0.1:7004'
    })

    local my_node = skynet.getenv('node')
    if my_node == 'node1' then
        cluster.open('node1')
        local ping1 = skynet.newservice('ping')
        local ping2 = skynet.newservice('ping')
        local pong = cluster.proxy('node2', 'pong')

        skynet.send(pong, 'lua', 'ping', 'node1', ping1, 1)
        skynet.send(pong, 'lua', 'ping', 'node1', ping2, 1)

        -- skynet.send(ping1, 'lua', 'start', 'node2', 'pong')
        -- skynet.send(ping2, 'lua', 'start', 'node2', 'pong')
    elseif my_node == 'node2' then
        cluster.open('node2')
        local ping3 = skynet.newservice('ping')
        skynet.name('pong', ping3)
    end
end)