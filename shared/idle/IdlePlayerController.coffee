
if Meteor.isClient
  ngMeteor.controller 'IdlePlayer', [
    '$scope', '$stateParams', '$sce', '$collection', 'IdleCollections',
    ($scope, $stateParams, $sce, $collection, IdleCollections) =>
      $scope.$sce = $sce
      $scope._ = window._

      $collection IdleCollections.IdlePlayers, name: $stateParams.playerName
      .bind $scope, 'player'

      $scope.playerEvents = []

      $collection IdleCollections.IdlePlayerEvents, {player: $stateParams.playerName}, limit: 7, sort: {createdAt: -1}
      .bind $scope, 'playerEvents'

      $scope.$watch 'playerEvents', (newVal, oldVal) ->
        console.log 'test',newVal

      $scope.getJSONFor = (player) ->
        str = JSON.stringify player, null, 4
        blob = new Blob [str], type: 'application/json'
        url = URL.createObjectURL blob
        a = document.createElement 'a'
        a.download = "#{player.name}-#{Date.now()}.json"
        a.href = url
        a.click()

      $scope.getPlayerTagline = (player) ->
        player.messages?.web

      $scope.setPlayerInSession = (player) ->
        Session.set 'player', player

      $scope.getEquipmentAndTotals = (player) ->
        items = $scope.getEquipment player

        test = _.reduce items, (prev, cur) ->
          for key, val of cur
            prev[key] = 0 if not (key of prev) and _.isNumber val
            prev[key] += val if _.isNumber val
          prev
        , {name: 'Stat Totals', type: 'STAT TOTALS', bgColor: 'bg-maroon'}

        items.unshift test

        items

      $scope.getEquipment = (player) ->
        base = _.sortBy player.equipment, (item) -> item.type

        _.each base, (item) ->
          item.bgColor = 'bg-aqua'
          item.bgClassColor = $scope.classToColor item.itemClass

        base

      $scope.classToColor = (itemClass) ->
        switch itemClass
          when 'newbie', 'Newbie' then return 'bg-maroon'
          when 'Normal', 'basic'  then return 'bg-gray'
          when 'pro'              then return 'bg-purple'
          when 'idle'             then return 'bg-rainbow'
          when 'godly'            then return 'bg-black'

      $scope.equipmentStatArray = [
        {name: 'str', fa: 'fa-legal fa-rotate-90'}
        {name: 'dex', fa: 'fa-crosshairs'}
        {name: 'agi', fa: 'fa-bicycle'}
        {name: 'con', fa: 'fa-heart'}
        {name: 'int', fa: 'fa-mortar-board'}
        {name: 'wis', fa: 'fa-book'}
        {name: 'fire', fa: 'fa-fire'}
        {name: 'water', fa: 'fa-cloud'}
        {name: 'thunder', fa: 'fa-bolt'}
        {name: 'earth', fa: 'fa-leaf'}
        {name: 'ice', fa: 'icon-snow'}
        {name: 'luck', fa: 'fa-moon-o'}
      ]

      $scope.extendedEquipmentStatArray = $scope.equipmentStatArray.concat {name: 'sentimentality'},
        {name: 'piety'},
        {name: 'enchantLevel'},
        {name: '_calcScore'},
        {name: '_baseScore'}

      $scope.getPopoverFor = (player, stat) ->
        string = "<table class='table table-striped table-condensed'>"
        items = 0
        _.each player.equipment, (item) ->
          return if item[stat] is 0
          items++
          itemClass = if item[stat] < 0 then 'text-danger' else 'text-success'
          string += "<tr><td>#{item.name}</td><td class='#{itemClass}'>#{item[stat]}</td>"

        string += "<tr><td>No items are adding to this stat!</td></tr>" if items is 0

        string + "</table>"

      $scope.getExtraStats = (item) ->
        keys = _.filter (_.keys item), (key) -> _.isNumber item[key]

        _.each $scope.extendedEquipmentStatArray, (stat) ->
          keys = _.without keys, stat.name
          keys = _.without keys, "#{stat.name}Percent"

        keys = _.reject keys, (key) -> item[key] is 0

        _.map keys, (key) -> "#{key} (#{item[key]})"
        .join ', '

      $scope.getPersonalityString = (player) ->
        if player.personalityStrings?.length > 0 then (_.sortBy player.personalityStrings, (string) -> string).join ', ' else "No personalities selected"

      sprite = null
      game = null

      $scope.drawMap = (player) ->

        if sprite
          sprite.x = (player.x*16)
          sprite.y = (player.y*16)
          game.camera.x = sprite.x
          game.camera.y = sprite.y

          game.load.tilemap "../map/#{player.map}.json", null, Phaser.Tilemap.TILED_JSON

        phaserOpts =
          preload: ->
            @game.load.image "tiles", "../../img/tiles.png", 16, 16
            @game.load.spritesheet "interactables", "../../img/tiles.png", 16, 16
            @game.load.tilemap player.map, "../../map/#{player.map}.json", null, Phaser.Tilemap.TILED_JSON

          create: ->
            map = @game.add.tilemap player.map
            map.addTilesetImage "tiles", "tiles"
            terrain = map.createLayer "Terrain"
            terrain.resizeWorld()
            map.createLayer "Blocking"

            map.createFromObjects "Interactables", 1, "interactables"
            map.createFromObjects "Interactables", 2, "interactables"

            map.createFromObjects "Interactables", 12, "interactables", 11
            map.createFromObjects "Interactables", 13, "interactables", 12
            map.createFromObjects "Interactables", 14, "interactables", 13
            map.createFromObjects "Interactables", 18, "interactables", 17

            sprite = @game.add.sprite player.x*16, player.y*16, 'interactables', 12
            @game.camera.follow sprite

        return if (not player) or game
        game = new Phaser.Game '100%',300, Phaser.AUTO, 'map', phaserOpts
        null

      $scope.isHtmlStat = (stat) ->
        stat in ['calculated kills', 'calculated kills by class', 'calculated class changes']

      $scope.statsObj = (player, key) ->
        val = player.statistics[key] or 0

        buildHtmlFromObject = (obj, playerLink = no) ->
          _(_.keys obj).sortBy (key) ->
            -obj[key]
          .filter (key) ->
            not _.str.isBlank key
          .map (key) ->
            embedKey =  if playerLink then "<a href='#{key}'>#{key}</a>" else key
            "<li>#{embedKey} (#{obj[key]})</li>"
          .join ""

        return "<ul class='kills no-margin'>#{buildHtmlFromObject val, true}</ul>" if (_.isObject val) and key is 'calculated kills'
        return "<ul class='kills no-margin'>#{buildHtmlFromObject val, false}</ul>" if (_.isObject val) and $scope.isHtmlStat key
        parseInt val

      $scope.getStats = (player) ->
        _.sortBy (_.keys player.statistics or []), (v) -> v

      $scope.itemItemScore = (item) ->
        return 0 if not item._baseScore or not item._calcScore
        parseInt (item._calcScore / item._baseScore) * 100

      $scope.playerItemScore = (player, item) ->
        return 0 if not item._calcScore or not player._baseStats.itemFindRange
        parseInt (item._calcScore / player._baseStats.itemFindRange) * 100

      gauge = null
      $scope.updateXp = (player) ->
        if not gauge
          xpEl = document.getElementById 'xpGauge'
          opts =
            lines: 12
            angle: 0
            lineWidth: 0.07
            pointer:
              length: 0.9
              strokeWidth: 0.035
              color: '#000000'
            limitMax: 'false'
            colorStart: '#66CD00'
            colorStop: '#3B5323'
            strokeColor: '#EEEEEE'
            generateGradient: true

          gauge = new Donut(xpEl).setOptions opts

        gauge.maxValue = player.xp.maximum
        gauge.set player.xp.__current
        null
  ]