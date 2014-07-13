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

  Meteor.publish "channelMessages", () ->
    channelIds = Channels.find().map (c) -> c._id
    Messages.find({channelId: {$in: channelIds}})

  Meteor.publish "metionMessages", () ->
    Messages.find({$or: [{userId: @userId}, {metionId: @userId}]})

  Meteor.publish "channels", () ->
    Channels.find()

  Meteor.publish "users", () ->
    Meteor.users.find()

  Meteor.startup ->
