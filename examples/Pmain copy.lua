local skynet = require 'skynet'
local socket = require 'skynet.socket'
local mysql = require 'skynet.db.mysql'

local db = nil

local function connect(fd, addr)
    socket.start(fd)
    while true do
        local read_data = socket.read(fd)
        if read_data == 'get\r\n' then
            local res = db:query('select * from msgs')
            for key, value in pairs(res) do
                socket.write(fd, value.id..' '..value.text..'\r\n')
            end
        else
            local data = string.match(read_data, 'set (.-)\r\n')
            if data then
                db:query("insert into msgs (text) values ('"..data.."')")
            end
        end
    end
    
end

skynet.start(function ()
    db = mysql.connect({
        host = '127.0.0.1',
        port = 3306,
        database = 'message_board',
        user = 'root',
        password = '123456',
        max_packet_size = 1024 * 1024,
        on_connect = nil
    })

    local ip = '0.0.0.0'
    local port = 8888
    local listen_fd = socket.listen(ip, port)
    socket.start(listen_fd, connect)
end)