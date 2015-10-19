# Description:
#   カードの締切の当日9時に通知
#
# Configuration:
#   HUBOT_TRELLO_API_KEY
#   HUBOT_TRELLO_API_TOKEN
#   HUBOT_TRELLO_ORGANIZATION

cronJob = require('cron').CronJob
moment = require('moment')
table = require('easy-table')
trelloAPI = require('node-trello')

UTCtoJST = (utc) ->
  if utc is null
    return ''
  return moment(utc).locale('ja').format('YYYY/MM/DD hh:mm')

module.exports = (robot) ->
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

  getOrganizationsBoards = ->
    url = "/1/organizations/#{ORG}/boards"
    trello.get url, (err, data) =>
      if err
        return
      for board in data
        getBoardsCards(board)

  getOrganizationsMembers = ->
    url = "/1/organizations/#{ORG}/members"
    trello.get url, (err, data) =>
      if err
        return
      MEMBERS = data

  getBoardsCards = (board) ->
    url = "/1/boards/#{board.id}/cards"
    t = new table
    trello.get url, (err, data) =>
      if err
        return
      today = moment().locale('ja').format('YYYY/MM/DD')
      member = new String
      t = new table
      for card in data
        due = UTCtoJST(card.due)
        if due.indexOf(today) isnt -1
          card.idMembers = for member in card.idMembers
            getMemberNameByID(member)
          t.cell('Link', card.shortLink)
          t.cell('Due', UTCtoJST(card.due).split(' ')[1])
          t.cell('Members', card.idMembers.join(','))
          t.cell('Name', card.name)
          t.newRow()
      if t.rows.length > 0
        robot.send({ room: board.name.toLowerCase() }, "本日締切のカードです。\n```\n#{t.print().trim()}\n```")

  getOrganizationsMembers()

  trelloCron = new cronJob({
    cronTime: '0 0 9 * * *'
    onTick: getOrganizationsBoards()
    start: true
    timeZone: 'Asia/Tokyo'
  })
