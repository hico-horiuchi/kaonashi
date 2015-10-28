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
#   hubot trello member                  - ボードのメンバーの一覧を表示
#   hubot trello member  <name>          - メンバーが担当するカードの一覧を表示

moment = require('moment')
table = require('easy-table')
trelloAPI = require('node-trello')

UTCtoJST = (utc) ->
  if utc is null
    return ''
  return moment(utc).locale('ja').format('YYYY/MM/DD hh:mm')

JSTtoUTC = (jst) ->
  if jst is null
    return ''
  return moment(jst).locale('ja').format('YYYY-MM-DDThh:mm:ss.SSSZ')

module.exports = (robot) ->
  ERR_MSG = 'Trello APIの呼出に失敗しました。'
  NIL_MSG = '結果はありません。'
  ORG = process.env.HUBOT_TRELLO_ORGANIZATION
  MEMBERS = []

  trello = new trelloAPI(
    process.env.HUBOT_TRELLO_API_KEY
    process.env.HUBOT_TRELLO_API_TOKEN
  )

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
        return msg.reply("#{ERR_MSG}\n```\n#{err}\n```")
      for board in data
        if board.name.toLowerCase() is msg.envelope.room
          args['boardID'] = board.id
          return args['callbacks'].shift()(msg, args)
      msg.reply(NIL_MSG)

  getOrganizationsMembers = ->
    url = "/1/organizations/#{ORG}/members"
    trello.get url, (err, data) =>
      if err
        return
      MEMBERS = data

  getBoardsLists = (msg, args) ->
    url = "/1/boards/#{args['boardID']}/lists"
    trello.get url, (err, data) =>
      if err
        return msg.reply("#{ERR_MSG}\n```\n#{err}\n```")
      for list in data
        if list.name.toLowerCase() is args['listName']
          args['listID'] = list.id
          return args['callbacks'].shift()(msg, args)
      msg.reply(NIL_MSG)

  getBoardsMembers = (msg, args) ->
    url = "/1/boards/#{args['boardID']}/members"
    trello.get url, (err, data) =>
      if err
        return msg.reply("#{ERR_MSG}\n```\n#{err}\n```")
      t = new table
      for member in data
        t.cell('Name', member.username)
        t.cell('Full', member.fullName)
        t.newRow()
      if t.rows.length > 0
        return msg.reply("```\n#{t.print().trim()}\n```")
      msg.reply(NIL_MSG)

  getListsCards = (msg, args) ->
    url = "/1/lists/#{args['listID']}/cards"
    trello.get url, (err, data) =>
      if err
        return msg.reply("#{ERR_MSG}\n```\n#{err}\n```")
      t = new table
      for card in data
        card.idMembers = for member in card.idMembers
          getMemberNameByID(member)
        t.cell('Link', card.shortLink)
        t.cell('Due', UTCtoJST(card.due).split(' ')[0])
        t.cell('Members', card.idMembers.join(','))
        t.cell('Name', card.name)
        t.newRow()
      if t.rows.length > 0
        return msg.reply("```\n#{t.print().trim()}\n```")
      msg.reply(NIL_MSG)

  postListsCards = (msg, args) ->
    url = "/1/lists/#{args['listID']}/cards"
    trello.post url, { name: args['cardName'] }, (err, data) =>
      if err
        return msg.reply("#{ERR_MSG}\n```\n#{err}\n```")
      # msg.reply("「#{data.name}」を #{args['listName']} に追加しました。\n#{data.shortUrl}")

  getCards = (msg, args) ->
    url = "/1/cards/#{args['cardShort']}"
    trello.get url, (err, data) =>
      if err
        return msg.reply("#{ERR_MSG}\n```\n#{err}\n```")
      data.idMembers = for member in data.idMembers
        getMemberNameByID(member)
      args['card'] = data
      args['callbacks'].shift()(msg, args)

  getCardsActions = (msg, args) ->
    url = "/1/cards/#{args['cardShort']}/actions"
    trello.get url, { filter: 'commentCard' }, (err, data) =>
      if err
        return msg.reply("#{ERR_MSG}\n```\n#{err}\n```")
      comments = []
      console.log(args['card'])
      body = "名前: #{args['card'].name}\n締切: #{UTCtoJST(args['card'].due)}\n担当: #{args['card'].idMembers.join(',')}"
      for comment in data
        comments.push("#{comment.memberCreator.username}「#{comment.data.text}」")
      if comments.length > 0
        return msg.reply("```\n#{body}\n#{comments.join('\n')}\n```")
      msg.reply("```\n#{body}\n```")

  putCardsIdList = (msg, args) ->
    url = "/1/cards/#{args['cardShort']}/idList"
    trello.put url, { value: args['listID'] }, (err, data) =>
      if err
        return msg.reply("#{ERR_MSG}\n```\n#{err}\n```")
      # msg.reply("「#{data.name}」を #{args['listName']} に移動しました。\n#{data.shortUrl}")

  putCardsClosed = (msg, args) ->
    url = "/1/cards/#{args['cardShort']}/closed"
    trello.put url, { value: args['cardClosed'] }, (err, data) =>
      if err
        return msg.reply("#{ERR_MSG}\n```\n#{err}\n```")
      # if args['cardClosed'] is 'true'
      #   msg.reply("「#{data.name}」をアーカイブしました。\n#{data.shortUrl}")
      # else if args['cardClosed'] is 'false'
      #   msg.reply("「#{data.name}」をボードに戻しました。\n#{data.shortUrl}")

  putCardsDue = (msg, args) ->
    url = "/1/cards/#{args['cardShort']}/due"
    trello.put url, { value: args['cardDue'] }, (err, data) =>
      if err
        return msg.reply("#{ERR_MSG}\n```\n#{err}\n```")
      # msg.reply("「#{data.name}」の締切を設定しました。\n#{data.shortUrl}")

  postCardsActionsComments = (msg, args) ->
    url = "/1/cards/#{args['cardShort']}/actions/comments"
    trello.post url, { text: args['cardComment'] }, (err, data) =>
      if err
        return msg.reply("#{ERR_MSG}\n```\n#{err}\n```")
      # msg.reply("カードにコメントしました。\n> #{args['cardComment']}\nhttps://trello.com/c/#{args['cardShort']}")

  postCardsIDMembers = (msg, args) ->
    url = "/1/cards/#{args['cardShort']}/idMembers"
    trello.post url, { value: args['memberID'] }, (err, data) =>
      if err
        return msg.reply("#{ERR_MSG}\n```\n#{err}\n```")
      # msg.reply("#{args['memberName']} を担当者に追加しました。\nhttps://trello.com/c/#{args['cardShort']}")

  getMembersCards = (msg, args) ->
    url = "/1/members/#{args['memberName']}/cards"
    trello.get url, (err, data) =>
      if err
        return msg.reply("#{ERR_MSG}\n```\n#{err}\n```")
      t = new table
      for card in data
        card.idMembers = for member in card.idMembers
          getMemberNameByID(member)
        t.cell('Link', card.shortLink)
        t.cell('Due', UTCtoJST(card.due).split(' ')[0])
        t.cell('Members', card.idMembers.join(','))
        t.cell('Name', card.name)
        t.newRow()
      if t.rows.length > 0
        return msg.reply("```\n#{t.print().trim()}\n```")
      msg.reply(NIL_MSG)

  getOrganizationsMembers()

  robot.respond /trello\s+list\s+(\S+)$/i, (msg) ->
    getOrganizationsBoards(msg, {
      callbacks: [getBoardsLists, getListsCards]
      listName: msg.match[1]
    })

  robot.respond /trello\s+add\s+(\S+)\s+(.+)$/i, (msg) ->
    getOrganizationsBoards(msg, {
      callbacks: [getBoardsLists, postListsCards]
      listName: msg.match[1]
      cardName: msg.match[2]
    })

  robot.respond /trello\s+move\s+(\S+)\s+(\S+)$/i, (msg) ->
    getOrganizationsBoards(msg, {
      callbacks: [getBoardsLists, putCardsIdList]
      listName: msg.match[1]
      cardShort: msg.match[2]
    })

  robot.respond /trello\s+show\s+(\S+)$/i, (msg) ->
    getCards(msg, {
      callbacks: [getCardsActions]
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

  robot.respond /trello\s+member$/i, (msg) ->
    getOrganizationsBoards(msg, {
      callbacks: [getBoardsMembers]
    })

  robot.respond /trello\s+member\s+(\S+)$/i, (msg) ->
    getMembersCards(msg, {
      memberName: msg.match[1]
    })
