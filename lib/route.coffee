Router.configure
  waitOn: ->
    Meteor.subscribe('users') &&
    Meteor.subscribe('channels') &&
    Meteor.subscribe('metionMessages') &&
    Meteor.subscribe('channelMessages')
Router.map ->
  @route 'welcome', {path: '/'}
  @route 'metionPage',
    path: '/metion/:username'
    template: 'dashboardPage'
    data: ->
      currentMetion = Meteor.users.findOne({username: @params.username})
      Template.dashboardPage.getCurrentMetionId = -> currentMetion._id
      Template.dashboardPage.getCurrentChannelId = -> null
      {
        currentMetion: currentMetion
        messages: messages
      }
  @route 'channelPage',
    path: '/channel/:name'
    template: 'dashboardPage'
    data: ->
      currentChannel = Channels.findOne({name: @params.name})
      Template.dashboardPage.getCurrentChannelId = -> currentChannel._id
      Template.dashboardPage.getCurrentMetionId = -> null
      messages = Messages.find(channelId: currentChannel._id)
      {
        currentChannel: currentChannel
      }


