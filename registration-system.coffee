LU = if typeof LU == "undefined" then {} else LU

class LU.App

  getClasses: ->
    try classes = Meteor.user().profile.classes
    classes

  dropClass: (classItem) ->

    if confirm("Are you sure you want to drop #{classItem.abbr} #{classItem.title}")
      updatedClasses = Meteor.user().profile.classes.filter (item) ->
        item.abbr != classItem.abbr

      Meteor.users.update { _id: Meteor.user()._id }, $set: "profile.classes": updatedClasses

  addClass: (abbr, title) ->

    if abbr and title

      classes = Meteor.user().profile.classes or []

      for item, index in classes
        if item is abbr
          classIndex = index
          break

      newValue = 
        abbr: abbr
        title: title

      if classIndex > -1
        if confirm("This class is already added. Do you wand to update it?")
          classes[classIndex] = newValue
      else
        classes.push newValue

      Meteor.users.update { _id: Meteor.user()._id }, $set: "profile.classes": classes


  onSubmitButtonClick: () ->

    abbrInput = $("#class-abbr")
    titleInput = $("#class-title")

    abbr = abbrInput.val().trim()
    title = titleInput.val().trim()

    @addClass abbr, title

    abbrInput.val ""
    titleInput.val ""


if Meteor.isClient

  LU.app = new (LU.App)

#  Accounts.onLogin ->
#    if Meteor.user().services.google.email.split("@")[1] == "lincolnucasf.edu"
#      console.log Meteor.user().services.google.email


  Template.list.helpers
    classes: LU.app.getClasses

  Template.list.events
    "click .drop-class": ->
      LU.app.dropClass @

  Template.form.events
    "submit form": (e) ->
      LU.app.onSubmitButtonClick e
      e.preventDefault()

#if Meteor.isServer
#  Meteor.startup ->
