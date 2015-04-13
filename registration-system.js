if (Meteor.isClient) {

  Students = new Mongo.Collection('students');

  Accounts.onLogin(function(){
    if (Meteor.user().services.google.email.split('@')[1] == 'lincolnucasf.edu') {
        console.log(Meteor.user().services.google.email)
    }
  });

  Template.list.helpers({
    classes: function () {
      return [
        {
          name: 'BA 360',
          title: 'Management Information Systems'
        },
        {
          name: 'MATH 15',
          title: 'Finite Mathematics'
        },
        {
          name: 'BA 300B',
          title: 'Financial Accounting Foundations'
        },
        {
          name: 'BA 301 I',
          title: 'Managerial Economics'
        }
      ]
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
  });
}
