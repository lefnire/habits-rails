# Basically a singleton global variable, not being synced with the server
# Reason is habit.update() will calculate user stats on server
class HabitTracker.Models.User extends Backbone.Model
  
  updateStats: (habit, delta) ->
    #  If adding points, add to experience
    if delta > 0
      @set({exp: @get('exp')+delta})
    # Deduct from health unless buying legitimately
    else if !habit.isReward() or ( habit.isReward() and (@get('money')+delta < 0) )
      @set({hp: @get('hp')+delta})

    # can't go below 0 exp
    if @get('exp') < 0 then @set({exp: 0})
    
    # level up & carry-over exp 
    if @get('exp') > @tnl()
      @set({ exp: @get('exp') - @tnl() })
      @set({ lvl: @get('lvl') + 1 })
    
    # @deprecated also add money. Only take away money if it was a mistake (aka, a checkbox) 
    # if delta>0 or (habit.isDaily() or habit.isTodo()) 
      # @set({money: @get('money')+delta})
      
    # apply same logic to money
    @set({money: @get('money')+delta})
    if @get('money') < 0 then @set({money: 0})
      
    # if buying an item, deduct cost
    if habit.isReward()
      @set({money: @get('money')-habit.get('score')})
      
    @trigger('updatedStats')
      
  tnl: () ->
    # http://tibia.wikia.com/wiki/Formula
    50 * Math.pow(@get('lvl'), 2) - 150 * @get('lvl') + 200
