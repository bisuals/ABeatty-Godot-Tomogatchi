extends Node

@onready var pet = get_parent()
@onready var timeUI = get_tree().get_first_node_in_group("TimeUI")

# Stats interval before change, set in in-game minutes
const HUNGER_INTERVAL = 10
const HAPPINESS_INTERVAL = 15
const HYGINE_INTERVAL = 30
const FUN_INTERVAL = 15
const SOCIAL_INTERVAL = 30
const TIRED_INTERVAL = 45
const POOP_INTERVAL = 30
const XP_GAIN_INTERVAL = 10

func _ready():
	timeUI.time_tick.connect(process_time_events)

func process_time_events(day, hour, minute):
	# Use absolute minutes, NOT minute-of-the-hour. "minute % 45" restarts every hour,
	# so the gaps were 45, 15, 45, 15... and everything fired together at :00.
	var total = day * 1440 + hour * 60 + minute

	if pet.state == pet.PetState.SLEEPING:
		pet.pet_stats.tiredness -= 1
		pet.pet_actions.reaction_popup('sick')
		if pet.pet_stats.tiredness == 0:
			pet.pet_actions.toggle_sleep()
	if total % HUNGER_INTERVAL == 0:
		pet.pet_stats.hunger += 5
		pet.pet_actions.feed_counter -= 1
	if total % HAPPINESS_INTERVAL == 0:
		pet.pet_stats.happiness -= 5
		pet.pet_actions.pet_counter -= 1
	var hygiene_interval = int(max(HYGINE_INTERVAL - (HYGINE_INTERVAL * pet.pet_actions.poop_counter * 0.2), 5))
	if total % hygiene_interval == 0:
		pet.pet_stats.hygiene -= 5
	if total % FUN_INTERVAL == 0:
		pet.pet_stats.fun -= 5
	if total % SOCIAL_INTERVAL == 0:
		pet.pet_stats.social -= 5
	if total % TIRED_INTERVAL == 0 and pet.state != pet.PetState.SLEEPING:
		pet.pet_stats.tiredness += 5
	if total % POOP_INTERVAL == 0:
		pet.pet_actions.random_poop_chance()
	if total % XP_GAIN_INTERVAL == 0:
		pet.gain_xp_based_on_stats(pet.pet_stats.average_stats)
