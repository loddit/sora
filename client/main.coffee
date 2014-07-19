Accounts.ui.config({passwordSignupFields: 'USERNAME_AND_EMAIL'})

Template.dashboardPage.getCurrentChannelId = -> null
Template.dashboardPage.getCurrentMetionId = -> null

Template.messages.helpers
  messages: ->
    currentChannelId = Template.dashboardPage.getCurrentChannelId()
    currentMetionId = Template.dashboardPage.getCurrentMetionId()
    if currentChannelId
      return Messages.find({channelId: currentChannelId})
    if currentMetionId
      return Messages.find({$or: [{userId: currentMetionId}, {metionId: currentMetionId}]})


Template.message.helpers
  userName: -> Meteor.users.findOne(@userId).username
  createdAt: -> @created and @created.toTimeString()

Template.channels.helpers
  joinedChannels: ->
    if Meteor.user()
      Channels.find
        _id:
          $in: Memberships.find().map (membership) ->
            membership.channelId
    else
      []
  unjoiedChannels: ->
    if Meteor.user()
      Channels.find
        _id:
          $nin: Memberships.find().map (membership) ->
            membership.channelId
    else
      Channels.find()

Template.channels.events
  "click #toggle-manager": (e) ->
    $toggler = $(e.target)
    if $toggler.text() == 'done'
      $toggler.text 'manage'
    else
      $toggler.text 'done'

    $('#channel-list').toggle()
    $('#channel-manager').toggle()

Template.channel.helpers
  isCurrentChannel: ->
    this._id == Template.dashboardPage.getCurrentChannelId()
  isMyOwn: ->
    this.userId == Meteor.userId()
  isJoined: ->
    Memberships.findOne
      channelId: this._id

Template.channel.events
  "click .delete": ->
    if confirm("delete this channel with all messages ?")
      Channels.remove(@_id)
  "click .join": ->
      Memberships.insert
        userId: Meteor.user()._id
        channelId: this._id
  "click .leave": ->
      membership =  Memberships.findOne
          userId: Meteor.user()._id
          channelId: this._id
      Memberships.remove membership._id

Template.channelManager.helpers
  allChannels: ->
    Channels.find()

Template.channelManager.events
  "submit form": (e) ->
    e.preventDefault()
    $form = $(e.target)
    $form.hide().parent().find("a").show()
    $input = $form.find('input')
    Channels.insert({name: $input.val()})
    $input.val('')

Template.user.helpers
  isCurrentMetion: ->
    this._id == Template.dashboardPage.getCurrentMetionId()

Template.users.helpers
  users: ->
    Meteor.users.find({_id: {$ne: Meteor.userId()}})

Template.messageForm.events
  'submit form': (e) ->
    e.preventDefault()
    $input = $(e.target).find('#message-input')
    currentChannelId = Template.dashboardPage.getCurrentChannelId()
    currentMetionId = Template.dashboardPage.getCurrentMetionId()
    if currentChannelId
      Messages.insert({body: $input.val(), userId: Meteor.user()._id, channelId: currentChannelId})
    if currentMetionId
      Messages.insert({body: $input.val(), userId: Meteor.user()._id, metionId: currentMetionId})
    $input.val('')

Deps.autorun ->
  Template.dashboardPage.getCurrentChannelId()
  Template.dashboardPage.getCurrentMetionId()
