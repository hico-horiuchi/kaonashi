# Kaonashi

![icon.png](https://raw.githubusercontent.com/hico-horiuchi/kaonashi/master/data/icon.png)

Kaonashi(カオナシ)は、Hubot製のチャットボットです。  
Slackの工学部祭実行委員チームで、[Trello](https://trello.com/)との連携などをサポートしています。

## Install

    $ heroku create --stack cedar kaonashi
    $ heroku config:set HUBOT_HEROKU_KEEPALIVE_URL=$(heroku apps:info -s  | grep web_url | cut -d= -f2)
    $ heroku config:set HUBOT_PING_PATH="/kaonashi/ping"
    $ heroku config:set HUBOT_SLACK_TOKEN=""
    $ heroku config:set HUBOT_DOCOMO_DIALOGUE_API_KEY=""
    $ heroku config:set HUBOT_TRELLO_API_KEY=""
    $ heroku config:set HUBOT_TRELLO_API_TOKEN=""
    $ heroku config:set HUBOT_TRELLO_ORGANIZATION=""
    $ heroku config:add TZ=Asia/Tokyo
    $ git push heroku master

## Commands

<table>
  <thead></thead>
  <tbody>
    <tr>
      <td rowspan="2"><tt>help.coffee</tt></td>
      <td><tt>help</tt></td>
      <td>コマンドの一覧を表示</td>
    </tr>
    <tr>
      <td><tt>help &lt;command&gt;</tt></td>
      <td>コマンドの検索結果を表示</td>
    </tr>
    <tr>
      <td rowspan="4"><tt>kaonashi.coffee</tt></td>
      <td><tt>hello</tt></td>
      <td>時刻に応じて簡単な挨拶</td>
    </tr>
    <tr>
      <td><tt>version</tt></td>
      <td>Hubotのバージョンを表示</td>
    </tr>
    <tr>
      <td><tt>date</tt></td>
      <td>今日の日付を表示</td>
    </tr>
    <tr>
      <td><tt>time</tt></td>
      <td>現在の時刻を表示</td>
    </tr>
    <tr>
      <td><tt>z_dialogue.coffee</tt></td>
      <td></td>
      <td>どのコマンドにも一致しない場合に雑談</td>
    </tr>
  </tbody>
</table>

## URLs

<table>
  <thead></thead>
  <tbody>
    <tr>
      <td><tt>httpd.coffee</tt></td>
      <td><tt>GET /huboco/info</tt></td>
      <td>Hubocoの紹介ページを表示</td>
    </tr>
 </tbody>
</table>

## Cron

<table>
  <thead></thead>
  <tbody>
 </tbody>
</table>

## SpecialThanks

  - アイコンは「[In Spirited We Love Icon Se by Raindropmemory](http://raindropmemory.deviantart.com/art/In-Spirited-We-Love-Icon-Set-Repost-304014435)」を使っています。