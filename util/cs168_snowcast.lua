-- CS168 Snowcast Protocol Dissector

snowcast_protocol = Proto("CS168Snowcast", "CS168 Snowcast Protocol")

message = ProtoField.uint8("cs168snowcast.messsage_type", "messageType", base.DEC)

-- HELLO fields
udp_port = ProtoField.uint16("cs168snowcast.udp_port", "udpPort", base.DEC)
-- SET_STATION fields
station_number = ProtoField.uint16("cs168snowcast.station_number", "stationNumber", base.DEC)
-- WELCOME fields
num_stations = ProtoField.uint16("cs168snowcast.num_stations", "numStations", base.DEC)
-- ANNOUNCE fields
song_name_size = ProtoField.uint8("cs168snowcast.song_name_size", "songnameSize", base.DEC)
song_name = ProtoField.string("cs168snowcast.song_name", "songname")
-- INVALID_COMMAND fields
reply_string_size = ProtoField.uint8("cs168snowcast.reply_string_size", "replyStringSize", base.DEC)
reply_string = ProtoField.string("cs168snowcast.reply_string", "replyString")

snowcast_protocol.fields = {
  message,
  udp_port,
  station_number,
  num_stations,
  song_name_size,
  song_name,
  reply_string_size,
  reply_string
}

function snowcast_protocol.dissector(buffer, pinfo, tree)
  length = buffer:len()
  if length == 0 then return end

  pinfo.cols.protocol = snowcast_protocol.name

  local subtree = tree:add(snowcast_protocol, buffer(), "Snowcast Protocol Data")

  local packet_len = buffer:reported_length_remaining()

  local message_num = buffer(0, 1):uint()
  local message_name = get_message_name(message_num)

  -- Add command ID and name
  subtree:add(message, buffer(0, 1)):append_text(" (" .. message_name .. ") ")
  pinfo.cols.info:append("Snowcast " .. message_name)

  if message_num == 0 then
    -- Handling HELLO command
    local udpPort = buffer(1, 2):uint()
    subtree:add(udp_port, buffer(1, 2))
    pinfo.cols.info:append(" (UDP Port: " .. udpPort .. ") ")
  elseif message_num == 1 then
    -- Handling SET_STATION command
    local stationNumber = buffer(1, 2):uint()
    subtree:add(station_number, buffer(1, 2))
    pinfo.cols.info:append(" (Station Number: " .. stationNumber .. ") ")
  elseif message_num == 2 then
    -- Handling WELCOME reply
    local numStations = buffer(1, 2):uint()
    subtree:add(num_stations, buffer(1, 2))
    pinfo.cols.info:append(" (Station Number: " .. numStations .. ") ")
  elseif message_num == 3 then
    -- Handling ANNOUNCE reply
    local songnameSize = buffer(1, 1):uint()
    subtree:add(reply_string_size, buffer(1, 1))

    local songname = buffer(2, songnameSize):string()
    subtree:add(reply_string, buffer(2, songnameSize))

    pinfo.cols.info:append(" (Song Name [" .. songnameSize .. " bytes]: " .. songname .. ") ")
  elseif message_num == 4 then
    -- Handling INVALID_COMMAND reply
    local replyStringSize = buffer(1, 1):uint()
    subtree:add(reply_string_size, buffer(1, 1))

    local replyString = buffer(2, replyStringSize):string()
    subtree:add(reply_string, buffer(2, replyStringSize))

    pinfo.cols.info:append(" (Reply String [" .. replyStringSize .. " bytes]: " .. replyString .. ") ")
  end
end

function get_message_name(message_num)
  local message_name = "UNNOWN"

  if message_num == 0 then
    message_name = "HELLO COMMAND"
  elseif message_num == 1 then
    message_name = "SET_STATION COMMAND"
  elseif message_num == 2 then
    message_name = "WELCOME REPLY"
  elseif message_num == 3 then
    message_name = "ANNOUNCE REPLY"
  elseif message_num == 4 then
    message_name = "INVALID_COMMAND REPLY"
  end

  return message_name
end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(1680, snowcast_protocol)
