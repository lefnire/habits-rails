HabitTracker.Views.Habits ||= {}

class HabitTracker.Views.Habits.HabitView extends Backbone.View
  template: JST["backbone/templates/habits/habit"]
  
  events:
    "click .destroy" : "destroy"
    "click .vote-up" : "voteUp"
    "click .vote-down" : "voteDown"

  destroy: () =>
    @model.destroy()
    this.remove()
    return false
    
  voteUp: =>
    @model.vote("up")

  voteDown: =>
    if @model.isReward and (@model.get('score') > window.userStats.get('money'))
      $('#money').effect("pulsate", 100);      
    else
      @model.vote("down")

  tagName: "li"
  
  # why is @model not available in this function? having to pass it in like this
  dynamicClass: () =>
    if @model.isReward() then return "reward"
    output = "habit habit-type-#{@model.get('habit_type')}"
    if @model.get("done") then output += " done"
    score = @model.get("score")
    switch
      when score<-8 then output += ' color-worst'
      when score>=-8 and score<-5 then output += ' color-worse'
      when score>=-5 and score<-1 then output += ' color-bad' 
      when score>=-1 and score<1 then output += ' color-neutral'
      when score>=1 and score<5 then output += ' color-good' 
      when score>=5 and score<10 then output += ' color-better' 
      when score>=10 then output += ' color-best'
    return output
    
  render: ->
    $(@el).attr('id', "habit_#{@model.get('id')}")
    $(@el).attr('class', @dynamicClass())
    $(@el).html(@template(@model.toJSON() ))
    
    @$(".comment").qtip content:
      text: (api) ->
        $(this).next().html()
      
    return this
