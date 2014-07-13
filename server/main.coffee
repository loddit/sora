  Messages.allow
    insert: (userId, doc) ->
      doc.created = new Date()
      doc.userId = userId
      !!userId and doc.body

  Channels.allow
    insert: (userId, doc) ->
      doc.created = new Date()
      doc.userId = userId
      !!userId and doc.name
    remove: (userId, doc) ->
      !!userId and doc.userId == userId

  Meteor.publish "channelMessages", (channelId) ->
    Messages.find({channelId: channelId})

  Meteor.publish "metionMessages", (metionId) ->
    Messages.find({$or: [{metionId: metionId, userId: @userId}, {metionId: @userId, userId: metionId}]})

  Meteor.publish "channels", () ->
    Channels.find()

  Meteor.publish "users", () ->
    Meteor.users.find()

  Meteor.startup ->
