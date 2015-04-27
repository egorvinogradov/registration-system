@LU = @LU or {}

if Meteor.isClient

  @LU.settings =
    MOBILE_DEVICE_WIDTH: 400

  @LU.window = $(@)



class LU.App
  
  classes:
    searchInput: ".b-heading__search-input"

  MAX_AUTOCOMPLETE_RESULTS: 10

  initializeMeteorTemplates: ->

    console.log('fff', Template.heading.helpers())


  attachMeteorEvents: ->


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

    Session.set "last-added-class", data.abbr + " " + data.title

    if duplicate
      Session.set "alert-visible", true
      setTimeout =>
        Session.set "alert-visible", false
      , 5000
    else
      Session.set "alert-visible", false
      classes.push data

    Meteor.users.update { _id: Meteor.user()._id }, $set: "profile.classes": classes

  getClassByAbbr: (abbr) ->
    _.find LU.classes, (item) =>
      item.abbr is abbr

  initializeAutocomplete: ->

    variants = LU.classes.map (item) =>
      [
        item.abbr
        item.title
        item.professor
      ].join("|")

    autocomplete = $(@classes.searchInput).autocomplete

      source: (request, response) =>
        results = $.ui.autocomplete.filter variants, request.term
        response results.slice(0, @MAX_AUTOCOMPLETE_RESULTS)

      select: (e, ui) =>
        abbr = ui.item.label.split("|")[0]
        @addClass @getClassByAbbr abbr

      close: (e) ->
        $(e.target).val ""

    autocomplete.data("ui-autocomplete")._renderItem = $.proxy @renderAutocompleteItem, @
    $(".ui-autocomplete").addClass("container-fluid");

  renderAutocompleteItem: (autocomplete, item) ->

    abbr = item.label.split("|")[0]
    data = @getClassByAbbr abbr

    template = """
        <div class="row">
          <div class="col-sm-2 b-autocomplete__abbr">#{abbr}</div>
          <div class="col-sm-5 b-autocomplete__title">#{data.title}</div>
          <div class="col-sm-2 b-autocomplete__professor">#{data.professor}</div>
          <small class="col-sm-3 text-muted b-autocomplete__time">
            <span class="b-autocomplete__days">#{data.days.join(', ')}</span>
            #{data.time}
          </small>
        </div>
    """

    item.value = abbr + " " + data.title
    $(template).appendTo(autocomplete)

  setMobileSession: ->

    @zz = alert: (txt) ->
      unless $('#zzz').length
        $('<div id="zzz" style="z-index: 10; display: none; background: red; position: fixed; top: 50px"></div>').prependTo('body');
      $('#zzz').html(txt.toString())
      console.log('setMobileSession', txt.toString())

    @zz.alert(LU.window.width() < LU.settings.MOBILE_DEVICE_WIDTH)
    Session.set "mobile", LU.window.width() < LU.settings.MOBILE_DEVICE_WIDTH



if Meteor.isClient

  LU.app = new (LU.App)

  #$ ->

  LU.window.on "resize", _.debounce =>
    LU.app.setMobileSession()

  LU.app.initializeMeteorTemplates()
  LU.app.attachMeteorEvents()

  Template.heading.helpers
    loggedIn: ->
      #console.log('1---', Meteor.user())
      Meteor.user() #or true
    mobile: ->
      console.log('> mobile', Session.get "mobile")
      Session.get "mobile"

  Template.heading.rendered = ->
    LU.app.initializeAutocomplete()
    LU.app.setMobileSession()
    Session.set "alert-visible", false

  Template.alert.helpers
    name: ->
      Session.get "last-added-class"
    visible: ->
      Session.get "alert-visible"

  Template.list.helpers
    classes: LU.app.getClasses
    mobile: ->
      Session.get "mobile"

  Template.list.rendered = ->
    $(".b-list__item").hammer()

  Template._loginButtonsLoggedOutSingleLoginButton.rendered = ->
    $(".login-button.btn-Google").html("Sign in with @lincolnucasf.edu")

  Template.alert.events
    "click .b-alert__close": ->
      Session.set "alert-visible", false

  Template.list.events

    "click .b-drop": ->
      LU.app.dropClass @

    "swipeleft .b-list__item": (e) ->
      $(e.currentTarget)
        .addClass("b-list__item_swiped")
        .siblings()
        .removeClass("b-list__item_swiped")

    "swiperight .b-list__item": (e) ->
      $(e.currentTarget).removeClass "b-list__item_swiped"



if Meteor.isServer

  Meteor.startup ->

    Accounts.validateNewUser (user) ->
      true
      email = user.services.google.email
      if email.split("@")[1] == "lincolnucasf.edu"
        console.log("Successful login:", email)
        true
      else
        console.log("Login failed:", email)
        throw new Meteor.Error 403, "You must login using your @lincolnucasf.edu email"
