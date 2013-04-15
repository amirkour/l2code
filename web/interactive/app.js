(function($,_,bb){

	var iIngredientGUID = 0;
	var $divTemplates = $('div#templates');
	
	var pIngredientCollection = bb.Collection.extend({
		model: pIngredientModel
	});
	var pIngredients = new pIngredientCollection();
	
	/*
	 * Ingredient Model
	 */
	var pIngredientModel = bb.Model.extend({
		defaults: {
			name: null,
			composites: new pIngredientCollection()
		}
	});

	
	/*
	 * Ingredient View
	 */
	var pIngredientView = bb.View.extend({
		tagName: "li",
		
		initialize: function(){
			this.$el.html($divTemplates.find("script#t_ingredient").html());
			this.removeButton = this.$el.find("button.btn-danger")[0];
			this.removeButton.disabled = true;
		},
		
		events: {
			"keyup input.ingredient-input": "onIngredientKeyup",
			"click button.btn-danger": "onRemoveClick"
		},
		
		onIngredientKeyup: function(e){
			if(e.keyCode === 13 && e.target.value !== ""){
				this.model = new pIngredientModel({
					"name": e.target.value,
					"cid": iIngredientGUID++
				});
				pIngredients.add(this.model);
				
				e.target.disabled=true;
				this.removeButton.disabled = false;
			}
		},
		
		onRemoveClick: function(e){
			if(!this.model) return;
			
			pIngredients.remove(this.model);
			this.remove();
		},
		
		render: function(){
			return this;
		}
	});

	
	var pAppView = bb.View.extend({
		el: $("ol#ingredientList"),
		initialize: function(){
			var pNewIngredientView = new pIngredientView();
			
			this.$el.append(pNewIngredientView.render().el);
			
			this.listenTo(pIngredients, "add", this.onIngredientAdded);
		},
		
		onIngredientAdded: function(e){
			var pNewIngredientView = new pIngredientView();
			this.$el.append(pNewIngredientView.render().el);
			pNewIngredientView.$el.find('input.ingredient-input').focus();
		}
	});
	
	var pApp = new pAppView();
})(jQuery,_,Backbone);