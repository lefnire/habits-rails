# Basically a singleton global variable, not being synced with the server
# Reason is habit.update() will calculate user stats on server
class HabitTracker.Models.User extends Backbone.Model

  updateStats: (habit, delta) ->

    if habit.isReward()
      # purchase item
      @set {money: @get('money') - habit.get('score') }
      # if too expensive, reduce health & zero money
      if @get('money') < 0
        difference = @get('money')
        @set {money: 0, hp: @get('hp') + difference}

    # If positive delta, add points to exp & money
    # Only take away mony if it was a mistake (aka, a checkbox)
    if delta > 0 or (habit.isDaily() or habit.isTodo())
      @set {exp: @get('exp')+delta, money: @get('money')+delta}
    # Deduct from health (rewards case handled above)
    else if !habit.isReward()
      @set {hp: @get('hp')+delta}

    # level up & carry-over exp
    if @get('exp') > @tnl()
      @set { exp: @get('exp') - @tnl() , lvl: @get('lvl') + 1}
      refresh = true

    # game over
    if @get('hp') < 0
      @set {hp: 50, lvl: 1, exp: 0}
      refresh = true

    # why did I have this?
    #@trigger 'updatedStats'

    if refresh
      window.location.reload()


  tnl: () ->
    # http://tibia.wikia.com/wiki/Formula
    50 * Math.pow(@get('lvl'), 2) - 150 * @get('lvl') + 200
