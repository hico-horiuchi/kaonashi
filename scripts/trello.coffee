# Description:
#   Trello APIの機能を提供
#
# Configuration:
#   HUBOT_TRELLO_API_KEY
#   HUBOT_TRELLO_API_TOKEN
#   HUBOT_TRELLO_ORGANIZATION
#
# Commands:
#   hubot trello list    <list>          - カードの一覧を表示
#   hubot trello add     <list> <name>   - カードをリストに追加
#   hubot trello move    <list> <card>   - カードをリストに移動
#   hubot trello show    <card>          - カードの詳細を表示
#   hubot trello archive <card>          - カードをアーカイブ
#   hubot trello comment <card> <text>   - カードにコメントを追加
#   hubot trello assign  <card> <member> - カードに担当者を追加
#   hubot trello due     <card> <date>   - カードに締切を設定

moment = require('moment')
table = require('easy-table')
trelloAPI = require('node-trello')

UTCtoJST = (utc) ->
  if utc is null
    return ''
  return moment(utc).locale('ja').format('YYYY/MM/DD(ddd) hh:mm')

JSTtoUTC = (jst) ->
  if jst is null
    return ''
  return moment(jst).locale('ja').format('YYYY-MM-DDThh:mm:ss.SSSZ')

module.exports = (robot) ->
  ERR_MSG = ':confounded: Trello APIの呼出に失敗'
  NIL_MSG = ':expressionless: 結果なし'
  ORG = process.env.HUBOT_TRELLO_ORGANIZATION
  MEMBERS = []

  trello = new trelloAPI(
    process.env.HUBOT_TRELLO_API_KEY
    process.env.HUBOT_TRELLO_API_TOKEN
  )

  getOrganizationsMembers = (name) ->
    url = "/1/organizations/#{ORG}/members"
    trello.get url, (err, data) =>
      unless err
        MEMBERS = data

  getMemberNameByID = (id) ->
    for member in MEMBERS
      if member.id is id
        return member.username
    return ''

  getMemberIDByName = (name) ->
    for member in MEMBERS
      if member.username is name
        return member.id
    return ''

  getOrganizationsBoards = (msg, args) ->
    url = "/1/organizations/#{ORG}/boards"
    trello.get url, (err, data) =>
      if err
        return msg.reply(ERR_MSG)
      for board in data
        if board.name.toLowerCase() is msg.envelope.room
          args['boardID'] = board.id
          return getBoardsLists(msg, args)
      msg.reply(NIL_MSG)

  getBoardsLists = (msg, args) ->
    url = "/1/boards/#{args['boardID']}/lists"
    trello.get url, (err, data) =>
      if err
        return msg.reply(ERR_MSG)
      for list in data
        if list.name.toLowerCase() is args['listName']
          args['listID'] = list.id
          return args['callback'](msg, args)
      msg.reply(NIL_MSG)

  getListsCards = (msg, args) ->
    url = "/1/lists/#{args['listID']}/cards"
    trello.get url, (err, data) =>
      if err
        return msg.reply(ERR_MSG)
      t = new table
      data.forEach (card) ->
        t.cell('URL', card.shortUrl)
        t.cell('Name', card.name)
        t.newRow()
      msg.reply("```\n#{t.print().trim()}\n```")

  postListsCards = (msg, args) ->
    url = "/1/lists/#{args['listID']}/cards"
    trello.post url, { name: args['cardName'] }, (err, data) =>
      if err
        return msg.reply(ERR_MSG)
      msg.reply("「#{data.name}」を #{args['listName']} に追加しました\n#{data.shortUrl}")

  putCardsIdList = (msg, args) ->
    url = "/1/cards/#{args['cardShort']}/idList"
    trello.put url, { value: args['listID'] }, (err, data) =>
      if err
        return msg.reply(ERR_MSG)
      msg.reply("「#{data.name}」を #{args['listName']} に移動しました\n#{data.shortUrl}")

  getCards = (msg, args) ->
    url = "/1/cards/#{args['cardShort']}"
    trello.get url, (err, data) =>
      if err
        return msg.reply(ERR_MSG)
      data.idMembers = data.idMembers.map (member) ->
        member = getMemberNameByID(member)
      msg.reply("```\n名前: #{data.name}\n締切: #{UTCtoJST(data.due)}\n担当: #{data.idMembers.join(', ')}\n```")

  putCardsClosed = (msg, args) ->
    url = "/1/cards/#{args['cardShort']}/closed"
    trello.put url, { value: args['cardClosed'] }, (err, data) =>
      if err
        return msg.reply(ERR_MSG)
      if args['cardClosed'] is 'true'
        msg.reply("「#{data.name}」をアーカイブしました\n#{data.shortUrl}")
      else if args['cardClosed'] is 'false'
        msg.reply("「#{data.name}」をボードに戻しました\n#{data.shortUrl}")

  postCardsActionsComments = (msg, args) ->
    url = "/1/cards/#{args['cardShort']}/actions/comments"
    trello.post url, { text: args['cardComment'] }, (err, data) =>
      if err
        return msg.reply(ERR_MSG)
      msg.reply("カードにコメントしました\n> #{args['cardComment']}\nhttps://trello.com/c/#{args['cardShort']}")

  postCardsIDMembers = (msg, args) ->
    url = "/1/cards/#{args['cardShort']}/idMembers"
    trello.post url, { value: args['memberID'] }, (err, data) =>
      if err
        return msg.reply(ERR_MSG)
      msg.reply("#{args['memberName']} を担当者に追加しました\nhttps://trello.com/c/#{args['cardShort']}")

  putCardsDue = (msg, args) ->
    url = "/1/cards/#{args['cardShort']}/due"
    trello.put url, { value: args['cardDue'] }, (err, data) =>
      if err
        return msg.reply(ERR_MSG)
      msg.reply("「#{data.name}」の締切を設定しました\n#{data.shortUrl}")

  getOrganizationsMembers()

  robot.respond /trello\s+list\s+(\S+)$/i, (msg) ->
    getOrganizationsBoards(msg, {
      callback: getListsCards
      listName: msg.match[1]
    })

  robot.respond /trello\s+add\s+(\S+)\s+(.+)$/i, (msg) ->
    getOrganizationsBoards(msg, {
      callback: postListsCards
      listName: msg.match[1]
      cardName: msg.match[2]
    })

  robot.respond /trello\s+move\s+(\S+)\s+(\S+)$/i, (msg) ->
    getOrganizationsBoards(msg, {
      callback: putCardsIdList
      listName: msg.match[1]
      cardShort: msg.match[2]
    })

  robot.respond /trello\s+show\s+(\S+)$/i, (msg) ->
    getCards(msg, {
      cardShort: msg.match[1]
    })

  robot.respond /trello\s+archive\s+(\S+)$/i, (msg) ->
    putCardsClosed(msg, {
      cardShort: msg.match[1]
      cardClosed: 'true'
    })

  robot.respond /trello\s+comment\s+(\S+)\s+(.+)$/i, (msg) ->
    postCardsActionsComments(msg, {
      cardShort: msg.match[1]
      cardComment: msg.match[2]
    })

  robot.respond /trello\s+assign\s+(\S+)\s+(\S+)$/i, (msg) ->
    postCardsIDMembers(msg, {
      cardShort: msg.match[1]
      memberName: msg.match[2]
      memberID: getMemberIDByName(msg.match[2])
    })

  robot.respond /trello\s+due\s+(\S+)\s+(.+)$/i, (msg) ->
    putCardsDue(msg, {
      cardShort: msg.match[1]
      cardDue: JSTtoUTC(msg.match[2])
    })
