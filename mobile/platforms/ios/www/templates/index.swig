<!DOCTYPE html>
<!--
    Main push.co file
  -->
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <!-- WARNING: for iOS 7, remove the width=device-width and height=device-height attributes. See https://issues.apache.org/jira/browse/CB-4323 -->
    <meta name="viewport" content="user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1, width=device-width, height=device-height, target-densitydpi=device-dpi" />
    <link rel="stylesheet" type="text/css" href="css/index.css" />
    <title>трекер push.co</title>

    <link rel="stylesheet" href="css/ui.css">
    <link rel="stylesheet" href="css/fonts.css">

    <link rel="stylesheet" href="css/colors.css">
    <link rel="stylesheet" href="css/apps.css">


  </head>
  <body>

      {# include "sidebar.swig" #}
      

      {% include "tasks.swig" %}

      <div class="notifications">  </div>

      <div class="center flex flex-center" style="height:100vh">

<div style="height:50vmin; width:100vh">
 <canvas class='jaw-o fancy-graph inline'
 data-json-opts='{"type":"VertBars","data":{"values":[4,5,8,5,3,7,3,4,3,7,4,3,3,2,10,6,2,6,7,8,7,4,5,8,7]},"paddings":{"left":10,"top":10,"right":10,"bottom":10},"redrawTime":1200,"colors":["#410095","#9d00ee","#D144FF","#ff6a6a","#FC4541","#AC1400","#DF5525","#FE7002","#FFCC33","#FFD700","#fffa00","#9ACD32","#64FF33","#5ed900","#00aa35","#56C493","#0DB7B6","#88E9E9","#17d1ff","#44DDFF","#0061FF","#004ee7","#6495ED"],"redraw":5000,"showMax":false,"parentSize":true,"legends":[],"axisColor":"#333","graphType":"equalizer","showNet":false,"showAxis":false,"showAxisValues":false,"lineWidth":3}'

></canvas>
</div>

      </div>
      




    <script type="text/javascript" src="cordova.js"></script>
    <script type="text/javascript" src="js/index.js"></script>
    <script type="text/javascript">
      app.initialize();
    </script>

    <script src="js/swig.js"></script>
    <script src="js/todo.js"></script>
    <script src="js/fg.js"></script>
    <script src="js/notify.js"></script>
    <script src="js/fg-injector.js"></script>

    <script src="js/touchable.js"></script>

  </body>
</html>

