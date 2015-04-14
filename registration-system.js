LU = typeof LU === 'undefined' ? {} : LU;

LU.App = function(){};

LU.App.prototype = {

  getClasses: function(){
    var classes;
    try {
      classes = Meteor.user().profile.classes;
    }
    catch (e) {}
    return classes;
  },
  dropClass: function(classItem){

    if ( confirm('Are you sure you want to drop ' + classItem.abbr + ' ' + classItem.title) ) {
      var updatedClasses = Meteor.user().profile.classes.filter(function(item){
        return item.abbr !== classItem.abbr;
      });

      Meteor.users.update({
        _id: Meteor.user()._id
      }, {
        $set: { 'profile.classes': updatedClasses }
      });
    }
  },
  addClass: function(abbr, title){

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

      if ( classIndex > -1 ) {
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
  },
  onSubmitButtonClick: function(e){

    var abbrInput = $('#class-abbr');
    var titleInput = $('#class-title');

    var abbr = abbrInput.val().trim();
    var title = titleInput.val().trim();

    this.addClass(abbr, title);

    abbrInput.val('');
    titleInput.val('');

  }
};


if (Meteor.isClient) {

  LU.app = new LU.App();

  Accounts.onLogin(function(){
    if (Meteor.user().services.google.email.split('@')[1] == 'lincolnucasf.edu') {
        console.log(Meteor.user().services.google.email)
    }
  });

  Template.list.helpers({
    classes: LU.app.getClasses
  });

  Template.list.events({
    'click .drop-class': function(){
      LU.app.dropClass(this);
    }
  });

  Template.form.events({
    'submit form': function(e){
      LU.app.onSubmitButtonClick(e);
      e.preventDefault();
    }
  });
}

if (Meteor.isServer) {
  Meteor.startup(function () {
  });
}
