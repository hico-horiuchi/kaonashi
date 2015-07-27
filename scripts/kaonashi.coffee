# Description:
#   Kaonashiの情報などを提供
#
# Commands:
#   hubot hello   - 時刻に応じて簡単な挨拶
#   hubot version - Hubotのバージョンを表示
#   hubot date    - 今日の日付を表示
#   hubot time    - 現在の時刻を表示

moment = require('moment')

module.exports = (robot) ->
  robot.respond /hello$/i, (msg) ->
    hour = new Date().getHours()
    if 5 <= hour < 11
      return msg.reply(':sleepy: ｵﾊﾖｳｺﾞｻﾞｲﾏｽ')
    if 11 <= hour < 17
      return msg.reply(':smile: ｺﾝﾆﾁﾜ')
    if 17 <= hour < 23
      return msg.reply(':smiley: ｺﾝﾊﾞﾝﾜ')
    msg.reply(':sleeping:')

  robot.respond /kill/i, (msg) ->
    msg.reply(':sob: ﾔﾒﾃｰ')

  robot.respond /version$/i, (msg) ->
    msg.reply("私はたぶん#{robot.version}人目だと思うから")

  robot.respond /date$/i, (msg) ->
    msg.reply("#{moment().locale('ja').format('YYYY/MM/DD(ddd)')} です")

  robot.respond /time$/i, (msg) ->
    msg.reply("#{moment().format('HH:mm:ss')} です")
