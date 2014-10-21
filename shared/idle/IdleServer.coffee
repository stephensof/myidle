
if Meteor.isServer
  driver = new MongoInternals.RemoteCollectionDriver "mongodb://localhost:27017/idlelands"

  IdlePlayers = new Mongo.Collection "players", _driver: driver
  IdlePlayerEvents = new Mongo.Collection "playerEvents", _driver: driver
  IdleAnalytics = new Mongo.Collection "analytics", _driver: driver
  IdleMonsters = new Mongo.Collection "monsters", _driver: driver
  IdleItems = new Mongo.Collection "items", _driver: driver

  analyticsFields = {name: 1, statistics: 1, _statCache: 1, level: 1, hp: 1, mp: 1, gold: 1}

  Meteor.publish 'allPlayers', ->

    yesterday = new Date
    yesterday.setDate yesterday.getDate() - 1

    IdlePlayers.find {$or: [ {lastLogin: {$gt: yesterday}}, {isOnline: yes} ]}, {sort: {'name': 1, 'level.__current': -1}}
      ,{fields: {_statCache: 1, name: 1, map: 1, mapRegion: 1, achievements: 1, hp: 1, mp: 1, gold: 1, professionName: 1, isOnline: 1}}

  Meteor.publish 'playerEvents', (playerName) ->
    IdlePlayerEvents.find {player: playerName}, limit: 7, sort: {createdAt: -1}

  Meteor.publish 'singlePlayer', (playerName) ->
    IdlePlayers.find {name: playerName}

  Meteor.publish 'analytics', ->
    IdleAnalytics.find {}, {fields: analyticsFields}

  Meteor.publish 'singlePlayerAnalytics', (playerName) ->
    IdleAnalytics.find {name: playerName}, {fields: analyticsFields}

  Meteor.methods
    monsterCount: -> IdleMonsters.find().count()

    itemCount: ->
      ret = {}
      items = _.groupBy _.pluck IdleItems.find().fetch(), 'type'
      _.each (_.keys items), (itemType) ->
        ret[itemType] = items[itemType].length
      ret
