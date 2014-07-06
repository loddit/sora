Messages = new Meteor.Collection('messages')
Channels = new Meteor.Collection('channels')

if Meteor.isClient
  Accounts.ui.config({passwordSignupFields: 'USERNAME_AND_EMAIL'})
  Router.configure
    waitOn: ->
      Meteor.subscribe('users') && Meteor.subscribe('channels')
  Router.map ->
    @route 'welcome', {path: '/'}
    @route 'channelPage',
      path: '/channels/:name',
      data: ->
        currentChannel = Channels.findOne({name: @params.name})
        Template.channelPage.getCurrentChannelId = -> currentChannel._id
        messages = Messages.find(channelId: currentChannel._id)
        Meteor.subscribe('messages', currentChannel._id)
        {
          currentChannel: currentChannel
          messages: messages
        }


  Template.channelPage.getCurrentChannelId = -> null

  Template.messages.helpers {
    messages: (channelId) -> Messages.find()
    messagesCount: -> Messages.find().count()
  }

  Template.message.helpers {
    userName: -> Meteor.users.findOne(@userId).username
  }

  Template.channels.helpers {
    channels: -> Channels.find()
  }

  Template.channel.helpers {
    isCurrentChannel: ->
      this._id == Template.channelPage.getCurrentChannelId()
  }

  Template.users.helpers {
    users: -> Meteor.users.find()
  }

  Template.messageForm.events {
    'submit form': (e) ->
      e.preventDefault()
      body = $(e.target).find('input').val()
      Messages.insert({body: body, userId: Meteor.user()._id, channelId: Template.channelPage.getCurrentChannelId()})
  }

  Deps.autorun ->
    Template.channelPage.getCurrentChannelId()

if Meteor.isServer
  Messages.allow({
    insert: (userId, doc) -> !!userId
  })
  Meteor.publish "messages", (channelId) ->
    Messages.find({channelId: channelId})
  Meteor.publish "channels", () ->
    Channels.find()
  Meteor.publish "users", () ->
    Meteor.users.find()
  Meteor.startup ->
