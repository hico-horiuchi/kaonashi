# Description:
#   Hubotのhelpコマンドを生成
#
# Commands:
#   hubot help           - コマンドの一覧を表示
#   hubot help <command> - コマンドの検索結果を表示

table = require('easy-table')

module.exports = (robot) ->
  NIL_MSG = ':expressionless: 結果なし'

  robot.respond /help\s*(.+)?$/i, (msg) ->
    cmds = robot.helpCommands()
    filter = msg.match[1]
    if filter
      cmds = cmds.filter (cmd) ->
        cmd.match(new RegExp(filter, 'i'))
      if cmds.length == 0
        msg.reply(NIL_MSG)
        return
    t = new table
    cmds.forEach (cmd) ->
      cmd = cmd.replace(/^hubot/i, robot.name.toLowerCase())
      arr = cmd.split(' - ')
      t.cell('Command', arr[0])
      t.cell('Description', arr[1])
      t.newRow()
    msg.reply('\n```\n' + t.print().trim() + '\n```')
