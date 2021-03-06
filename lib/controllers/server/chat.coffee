text =
  black:          '§0',
  darkBlue:       '§1',
  darkGreen:      '§2',
  darkAqua:       '§3',
  darkRed:        '§4',
  purple:         '§5',
  gold:           '§6',
  grey:           '§7',
  darkGrey:       '§8',
  indigo:         '§9',
  green:          '§a',
  aqua:           '§b',
  red:            '§c',
  pink:           '§d',
  yellow:         '§e',
  white:          '§f',
  random:         '§k',
  bold:           '§l',
  strike:         '§m',
  underline:      '§n',
  italic:         '§o',
  reset:          '§r'

jsonify = (message) -> JSON.stringify({text: message})

module.exports = ->
  @prefixes =
    chat: ''
    system: text.yellow

  @broadcast = (message) =>
    @master.emit 'message', message

  @on 'region:before', (e, region) =>
    region.broadcast = (message) =>
      region.send 0x3, {message: jsonify message }

    @master.on 'message', (message) ->
      region.broadcast message
      
  @on 'join:before', (e, player) ->
    player.message = (message) => player.send 0x3, message: jsonify message

  @on 'join:after', (e, player, options) =>
    if not options.handoff?
      player.region.broadcast @prefixes.system + "#{player.username} joined the game"

    player.on 0x3, (e, data) =>
      player.emit 'message', data.message
      @emit 'message', player, data.message

  @on 'quit:after', (e, player) =>
    player.region.broadcast @prefixes.system + "#{player.username} left the game"

  @on 'message', (e, player, message) =>
    formatted = "<#{player.username}> #{message}"
    player.region.send 0x3, {message: jsonify formatted}
    @broadcast formatted
    @log 'chat', "[#{player.region.id}] #{formatted}"