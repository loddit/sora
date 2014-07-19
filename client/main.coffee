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
      Channels.find({_id: {$in: Meteor.user().channelIds or []}})
  otherChannels: ->
    if Meteor.user()
      Channels.find({_id: {$nin:Meteor.user().channelIds or []}})

Template.channel.helpers
  isCurrentChannel: ->
    this._id == Template.dashboardPage.getCurrentChannelId()
  isMyOwn: ->
    this.userId == Meteor.userId()
  isJoined: ->
    this._id in (Meteor.user().channelIds or [])

Template.channel.events
  "click .delete": ->
    if confirm("delete this channel with all messages ?")
      Channels.remove(@_id)
  "click .join": ->

Template.channelPannel.events
  "click a": (e) ->
    e.preventDefault()
    $(e.target).hide().parent().find("form").show()
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
