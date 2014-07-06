Messages = new Meteor.Collection('messages')
Channels = new Meteor.Collection('channels')

if Meteor.isClient
  Accounts.ui.config({passwordSignupFields: 'USERNAME_AND_EMAIL'})
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


  Template.dashboardPage.getCurrentChannelId = -> null
  Template.dashboardPage.getCurrentMetionId = -> null

  Template.messages.helpers {
    messages: -> Messages.find()
    messagesCount: -> Messages.find().count()
  }

  Template.message.helpers {
    userName: -> Meteor.users.findOne(@userId).username
    createdAt: -> @created and @created.toTimeString()
  }

  Template.channels.helpers {
    channels: -> Channels.find()
  }

  Template.channel.isCurrentChannel = ->
    this._id == Template.dashboardPage.getCurrentChannelId()

  Template.user.isCurrentMetion = ->
    this._id == Template.dashboardPage.getCurrentMetionId()

  Template.users.helpers {
    users: -> Meteor.users.find()
  }

  Template.messageForm.events {
    'submit form': (e) ->
      e.preventDefault()
      input = $(e.target).find('#messageInput')
      currentChannelId = Template.dashboardPage.getCurrentChannelId()
      currentMetionId = Template.dashboardPage.getCurrentMetionId()
      if currentChannelId
        Messages.insert({body: input.val(), userId: Meteor.user()._id, channelId: currentChannelId})
      if currentMetionId
        Messages.insert({body: input.val(), userId: Meteor.user()._id, metionId: currentMetionId})
      input.val('')
  }

  Deps.autorun ->
    Template.dashboardPage.getCurrentChannelId()
    Template.dashboardPage.getCurrentMetionId()

if Meteor.isServer
  Messages.allow({
    insert: (userId, doc) ->
      doc.created = new Date()
      !!userId
  })

  Meteor.publish "channelMessages", (channelId) ->
    Messages.find({channelId: channelId})

  Meteor.publish "metionMessages", (metionId) ->
    Messages.find({$or: [{metionId: metionId, userId: @userId}, {metionId: @userId, userId: metionId}]})

  Meteor.publish "channels", () ->
    Channels.find()

  Meteor.publish "users", () ->
    Meteor.users.find()

  Meteor.startup ->
