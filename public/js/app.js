Zepto(function($){
	
	Handlebars.registerHelper('todate', function(date) {
 		 return date.getMonth() + "/" + date.getDate();
	});

	// Post Model

	var Post = Backbone.Model.extend ({
	
		defaults: {
			title: '',
			body: '',
			date: '',
			created_at: '',
			status: 0,
			privacy: false
		},

		parse: function(data) {
			data.date = new Date(Date.parse(data.date));
			data.created_at = new Date(Date.parse(data.created_at));
			data.privacy = data.private;
			return data;
		}

	});


	// Posts Collection

	var PostsList = Backbone.Collection.extend({

		model: Post,

		url: '/movement/api/posts',

		drafts: function() {
			return this.where({status: 1});
		}

	});

	var Posts = new PostsList;

	// View for each post

	var PostView = Backbone.View.extend({

		tagName: 'li',

		template: Handlebars.compile($('#post-template').html()),

		events: {
			"click": "edit"
		},

		initialize: function() {
			this.listenTo(this.model, 'change', this.render);
		},

		render: function() {

			this.$el.html(this.template(this.model.toJSON()));
			return this;
		},

		edit: function() {
			this.parent.clr();
		}
	});

	var NoteView = Backbone.View.extend({

		tagName: 'li',

		template: Handlebars.compile($('#note-template').html()),

		events: {
			"click .notetext": "edit",
			"keypress .edit": "finishEdit",
			"blur .notetext": "close"
		},

		initialize: function() {
			this.listenTo(this.model, 'change', this.render);
		},

		render: function() {
			this.$el.html(this.template(this.model.toJSON()));
			this.noteText = this.$('.notetext');
			this.editingText = this.$('.edit');
			return this;
		},

		edit: function() {
			this.$el.addClass('editing');
			this.noteText.focus();
		},

		finishEdit: function(e) {
			if (e.keyCode == 13) this.close();
		},

		close: function() {
			var modifiedNote = this.editingText.val();
			console.log(modifiedNote);
			if (modifiedNote) {
				this.model.save({body: modifiedNote});
				this.$el.removeClass('editing');
			}
		}
	});

	// Drafts

	var DraftView = Backbone.View.extend({

		el: "#draftposts",

		events: {

		},

		initialize: function() {
			
		},

		render: function() {

		},

		addOne: function(post) {
			var view = new PostView({model: post});
			this.$el.append(view.render().el);
		},

		addAll: function() {
			Posts.drafts().each(this.addOne, this);
		}
	});

	// Published

	var PublishView = Backbone.View.extend({

		el: "#publishedposts",

		events: {

		},

		initialize: function() {

		},

		render: function() {

		}
	});

	// Dashboard

	var Dashboard = Backbone.View.extend({

		el: "#dash",

		events: {

		},

		initialize: function() {
			this.listenTo(Posts, 'add', this.addOne);
			this.listenTo(Posts, 'reset', this.addAll);

			this.notes = this.$("#notelist");
			this.drafts = this.$("#draftposts");
			this.published = this.$("#publishedposts");

			Posts.fetch();
			//this.draftView = new DraftView();
		},

		render: function() {

		},

		addOne: function(post) {
			switch(post.get('status')) {
				case 0:
					var view = new NoteView({model: post});
					this.notes.append(view.render().el);
					break;
				case 1:
					var view = new PostView({model: post});
					this.drafts.append(view.render().el);
					break;
				case 2:
					var view = new PostView({model: post});
					this.published.append(view.render().el);
			}
		},

		addAll: function() {
			Posts.each(this.addOne, this);
		}
	});


	// Routing

	var AppRouter = Backbone.Router.extend({
		routes: {
			'bracket': 'dashboard',
			'*action': 'dashboard'
		},

		dashboard: function(action) {
			//if (action) action = action.trim();
			(new Dashboard()).render();
		}
	});

	var approuter = new AppRouter;
	Backbone.history.start();

	//var App = new SongsView;

});