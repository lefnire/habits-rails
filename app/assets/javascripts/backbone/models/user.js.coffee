# Basically a singleton global variable, not being synced with the server
# Reason is habit.update() will calculate user stats on server
class HabitTracker.Models.User extends Backbone.Model

  updateStats: (habit, delta) ->
    [money, hp, exp, lvl] = [@get('money'), @get('hp'), @get('exp'), @get('lvl')]

    if habit.isReward()
      # purchase item
      money -= habit.get('score')
      # if too expensive, reduce health & zero money
      if money < 0
        hp += money # hp - money difference
        money = 0

    # If positive delta, add points to exp & money
    # Only take away mony if it was a mistake (aka, a checkbox)
    if delta > 0 or (habit.isDaily() or habit.isTodo())
      exp += delta
      money += delta
    # Deduct from health (rewards case handled above)
    else if !habit.isReward()
      hp += delta

    # level up & carry-over exp
    if exp > @tnl()
      exp -= @tnl()
      lvl += 1
      hp = 50
      refresh = true

    # game over
    if hp < 0
      [hp, lvl, exp] = [50, 1, 0]
      refresh = true

    @set {money: money, hp: hp, exp: exp, lvl: lvl}

    # why do I have this?
    @trigger 'updatedStats'

    if refresh
      window.location.reload()


  tnl: () ->
    # http://tibia.wikia.com/wiki/Formula
    50 * Math.pow(@get('lvl'), 2) - 150 * @get('lvl') + 200
