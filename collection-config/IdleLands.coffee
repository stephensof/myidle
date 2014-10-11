
if Meteor.isClient
  ngMeteor.config ['$stateProvider',
    ($stateProvider) ->
      $stateProvider
      .state 'idle',
        abstract: yes
        views:
          'content':
            template: UiRouter.template 'idle'
            controller: 'Idle'
          'sidebar':
            template: UiRouter.template 'idle-sidebar'
            controller: 'IdleFilter'

      .state 'idle.urlone',
        url: '/idle'
      .state 'idle.urltwo',
        url: '/idle/'

      .state 'idleglobalstats',
        url: '/idle/stats'
        views:
          'content':
            template: UiRouter.template 'idleglobalstats'
            controller: 'IdleGlobalStats'

      .state 'idleglobalanalytics',
        url: '/idle/analytics'
        views:
          'content':
            template: UiRouter.template 'idleanalytics'
            controller: 'IdleAnalytics'
          'sidebar':
            template: UiRouter.template 'idleanalyticssidebar'
            controller: 'IdleAnalyticsFilter'

      .state 'idleglobalachievements',
        url: '/idle/achievements'
        views:
          'content':
            template: UiRouter.template 'idleachievements'
            controller: 'IdleAchievements'

      .state 'idleplayerachievements',
        url: '/idle/achievements/:playerName'
        views:
          'content':
            template: UiRouter.template 'idleachievements'
            controller: 'IdleAchievements'

      .state 'idleplayeranalytics',
        url: '/idle/analytics/:playerName'
        views:
          'content':
            template: UiRouter.template 'idleanalytics'
            controller: 'IdleAnalytics'
          'sidebar':
            template: UiRouter.template 'idleanalyticssidebar'
            controller: 'IdleAnalyticsFilter'

      .state 'idleplayer',
        url: '/idle/stats/:playerName'
        views:
          'content':
            template: UiRouter.template 'idleplayer'
            controller: 'IdlePlayer'
          'sidebar':
            template: UiRouter.template 'idleplayersidebar'
            controller: 'IdlePlayerSidebar'

      .state 'idlespecialthanks',
        url: '/idle/thanks'
        views:
          'content':
            template: UiRouter.template 'idlespecialthanks'
            controller: 'IdleSpecialThanks'
          'sidebar':
            template: UiRouter.template 'idlespecialthankssidebar'
  ]