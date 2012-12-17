Base = require './base'
mcnet = require 'minecraft-net'

class Connector extends Base
    constructor: (@server, options) ->
        @connections = []
        @connections.usernames = {}

        # when we receieve data from the server, send it to the corresponding client
        @server.on 'data', (connection, id, data) =>
            if typeof connection == 'string' then connection = @connections.usernames[connection]
            connection.client.write id, data if connection.client?

        # listen for client connections
        @mcserver = mcnet.createServer options, @connection
        @mcserver.listen options.port or 25565, =>
            @info "listening for Minecraft connections on port #{@mcserver.port}"
            @emit 'listening'

    connection: (socket, handshake) =>
        connection = handshake
        connection.client = socket
        connection.server = @server

        @connections.push connection
        @connections.usernames[connection.username.toLowerCase()] = connection

        # when we recieve data from the client, send it to the corresponding server
        connection.client.on 'data', (id, packet) =>
            connection.server.emit 'data', connection.username, id, packet

        @emit 'connection', connection
        connection.server.emit 'connection', connection

module.exports = Connector