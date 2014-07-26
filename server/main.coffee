  Messages.allow
    insert: (userId, doc) ->
      doc.created = new Date()
      doc.userId = userId
      !!userId and doc.body
    update: (userId, doc) ->
      !!userId

  Channels.allow
    insert: (userId, doc) ->
      doc.created = new Date()
      doc.userId = userId
      !!userId and doc.name and !Channels.find({name:doc.name}).count()
    remove: (userId, doc) ->
      !!userId and doc.userId == userId

  Memberships.allow
    insert: (userId, doc) ->
      !!userId and doc.channelId and doc.userId == userId
    remove: (userId, doc) ->
      !!userId and doc.userId == userId

  Meteor.publish "channelMessages", () ->
    channelIds = Channels.find().map (c) -> c._id
    Messages.find
      channelId:
        $in: channelIds
    , $orderby: {created: 1}

  Meteor.publish "metionMessages", () ->
    Messages.find
      $or: [{userId: @userId, metionId: {$exists: true}}, {metionId: @userId}]
    , $orderby: {created: 1}

  Meteor.publish "memberships", () ->
    Memberships.find
      userId: @userId

  Meteor.publish "channels", () ->
    Channels.find()

  Meteor.publish "users", () ->
    Meteor.users.find()

  Meteor.startup ->
    unless Channels.find().count()
      Channels.insert({name: "default"})
    Channels.find().observe
      added: (doc) ->
        Memberships.insert
          userId: doc.userId
          channelId: doc._id
