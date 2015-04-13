if (Meteor.isClient) {

  Students = new Mongo.Collection('students');

  Accounts.onLogin(function(){
    if (Meteor.user().services.google.email.split('@')[1] == 'lincolnucasf.edu') {
        console.log(Meteor.user().services.google.email)
    }
  });

  Template.list.helpers({
    classes: function () {
      var classes;
      try {
        classes = Meteor.user().profile.classes;
      }
      catch (e) {}
      return classes;
    }
  });

  Template.list.events({
    'click .drop-class': function(){
      if ( confirm('Are you sure you want to drop ' + this.abbr + ' ' + this.title) ) {
        var updatedClasses = Meteor.user().profile.classes.filter(function(item){
          return item.abbr !== this.abbr;
        }, this);

        Meteor.users.update({
          _id: Meteor.user()._id
        }, {
          $set: { 'profile.classes': updatedClasses }
        });
      }
    }
  });

  Template.form.events({
    'submit form': function(e){

      var abbrInput = $('#class-abbr');
      var titleInput = $('#class-title');

      var abbr = abbrInput.val().trim();
      var title = titleInput.val().trim();

      if ( abbr && title ) {

        var classes = Meteor.user().profile.classes || [];
        var classIndex;

        for ( var i = 0; i < classes.length; i++ ) {
          if ( classes[i].abbr === abbr ) {
            classIndex = i;
            break;
          }
        }

        var newValue = {
            abbr: abbr,
            title: title
        };

        if (classIndex > -1) {
          if (confirm('This class is already added. Do you wand to update it?')) {
            classes[classIndex] = newValue;
          }
        }
        else {
          classes.push(newValue);
        }

        Meteor.users.update({
          _id: Meteor.user()._id
        }, {
          $set: { 'profile.classes': classes }
        });

      }

      abbrInput.val('');
      titleInput.val('');

      e.preventDefault();

    }
  });





  // counter starts at 0
  Session.setDefault('counter', 0);

  Template.hello.helpers({
    counter: function () {
      return Session.get('counter');
    }
  });

  Template.hello.events({
    'click button': function () {
      // increment the counter when button is clicked
      Session.set('counter', Session.get('counter') + 1);
    }
  });
}

if (Meteor.isServer) {
  Meteor.startup(function () {
    // code to run on server at startup


  Meteor.users.allow({
    'insert': function (userId,doc) {
      /* user and doc checks ,
      return true to allow insert */
      return true;
    }
  });

  });
}
