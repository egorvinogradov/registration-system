@LU = @LU or {}

class LU.App
  
  CLASS_INPUT_ID: "#class-input"
  
  MAX_AUTOCOMPLETE_RESULTS: 10

  getClasses: ->
    try classes = Meteor.user().profile.classes
    if classes
      classes.reverse()
    else
      []

  getClassByAbbr: (abbr) ->
    _.find LU.classes, (item) =>
      item.abbr is abbr

  dropClass: (classItem) ->

    if confirm("Are you sure you want to drop #{classItem.abbr} #{classItem.title}")
      updatedClasses = Meteor.user().profile.classes.filter (item) ->
        item.abbr != classItem.abbr

      Meteor.users.update { _id: Meteor.user()._id }, $set: "profile.classes": updatedClasses

  addClass: (data) ->

    classes = Meteor.user().profile.classes or []

    duplicate = _.find classes, (item) =>
      item.abbr is data.abbr

    if duplicate
      $(".class-alert").removeClass("hidden")
    else
      classes.push data

    Meteor.users.update { _id: Meteor.user()._id }, $set: "profile.classes": classes

  initializeAutocomplete: ->

    variants = LU.classes.map (item) =>
      [
        item.abbr
        item.title
        item.professor

      ].join("|")

    autocomplete = $(@CLASS_INPUT_ID).autocomplete

      source: (request, response) =>
        results = $.ui.autocomplete.filter variants, request.term
        response results.slice(0, @MAX_AUTOCOMPLETE_RESULTS)

      select: (e, ui) =>
        abbr = ui.item.label.split("|")[0]
        @addClass @getClassByAbbr abbr

      close: (e) ->
        $(e.target).val ""


    autocomplete.data("ui-autocomplete")._renderItem = (ul, item) ->

      values = item.label.split "|"
      abbr = values[0]
      title = values[1]

      template = """
        <li>
          <div class="autocomplete-abbr">#{abbr}</div>
          <div class="autocomplete-title">#{title}</div>
        </li>
      """

      item.value = abbr + " " + title

      $(template).appendTo(ul)
        



if Meteor.isClient

  LU.app = new (LU.App)

  Template.list.helpers
    classes: LU.app.getClasses

  Template.list.events
    "click .drop-class": ->
      LU.app.dropClass @

  Template.form.rendered = ->
    LU.app.initializeAutocomplete()




if Meteor.isServer

  Meteor.startup ->

    Accounts.validateLoginAttempt (login) ->
      email = login.user.services.google.email
      if email.split("@")[1] == "lincolnucasf.edu"
        console.log("Successfull login:", email)
        true
      else
        console.log("Failed login:", email)
        false
