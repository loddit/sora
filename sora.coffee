Messages = new Meteor.Collection('messages')
Channels = new Meteor.Collection('channels')

if Meteor.isClient
  Template.messages.helpers {
    channelMessages: (channelId) -> Messages.find(channelId: channelId)
    messagesCount: () -> Messages.find().count()
  }

  Template.channels.helpers {
    channels: () -> Channels.find()
  }

if Meteor.isServer
  Meteor.startup ->
