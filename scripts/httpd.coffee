# Description:
#   簡単なビルトインHTTPデーモン
#
# URLs:
#   GET /kaonashi/info - Kaonashiの紹介ページを表示

module.exports = (robot) ->
  INFO_PAGE =
    """
<!DOCTYPE html>
<html>
  <head>
    <title>Info | Kaonashi</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta content="width=device-width, initial-scale=1" name="viewport" />
    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" rel="stylesheet" />
    <link href="//maxcdn.bootstrapcdn.com/bootswatch/3.3.5/lumen/bootstrap.min.css" rel="stylesheet" />
    <link href="//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css" rel="stylesheet" />
    <link href="//fonts.googleapis.com/css?family=Exo:400,600" rel="stylesheet" />
    <style type="text/css"><!--
      body, h1, h2, h3, h4, text {
        font-family: 'Exo', sans-serif;
        font-weight: 400;
      }
      .bold { font-weight: 600; }
      .main {
        text-align: center;
        margin: 50px 0;
      }
      a.black { color: #333333; }
      a.black:hover {
        color: #999999;
        text-decoration: none;
      }
      @media screen and (max-width: 970px) {
        .main { margin: 15px 0; }
      }
    --></style>
  </head>
  <body>
    <div class="container">
      <div class="row">
        <div class="col-md-4"></div>
        <div class="col-md-4 main">
          <div class="well">
            <img src="https://raw.githubusercontent.com/hico-horiuchi/kaonashi/master/data/icon.png" />
            <h1 class="bold">Kaonashi</h1>
            <p>工学部祭実行委員会をサポートするHubot</p>
            <p><a class="btn btn-default btn-lg" href="https://github.com/hico-horiuchi/kaonashi"><i class="fa fa-github"></i>&nbsp;GitHubを見る</a></p>
            <p>&copy; <a class="black" href="http://hico-horiuchi.github.io/" target="_blank">Akihiko Horiuchi</a></p>
          </div>
        </div>
        <div class="col-md-4"></div>
      </div>
    </div>
  </body>
</html>
    """

  robot.router.get '/kaonashi/info', (req, call) ->
    call.end(INFO_PAGE)
