Router.configure
  waitOn: ->
    Meteor.subscribe('users') && Meteor.subscribe('channels')
Router.map ->
  @route 'welcome', {path: '/'}
  @route 'metionPage',
    path: '/metion/:username'
    template: 'dashboardPage'
    data: ->
      currentMetion = Meteor.users.findOne({username: @params.username})
      Template.dashboardPage.getCurrentMetionId = -> currentMetion._id
      Template.dashboardPage.getCurrentChannelId = -> null
      messages = Messages.find({metionId: currentMetion._id, userId: Meteor.user()._id})
      Meteor.subscribe('metionMessages', currentMetion._id)
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
      Meteor.subscribe('channelMessages', currentChannel._id)
      {
        currentChannel: currentChannel
        messages: messages
      }


