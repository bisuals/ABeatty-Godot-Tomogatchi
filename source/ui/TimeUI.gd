extends Control

@onready var daysLabel = get_node("%DaysLabel")
@onready var hoursLabel = get_node("%HoursLabel")
@onready var minutesLabel = get_node("%MinutesLabel")
@onready var sprite = $Sprite2D
@onready var pet = get_tree().get_first_node_in_group("Pet")

const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY

signal time_tick(day:int, hour:int, minute:int)

var day: int
var hour: int
var minute: int

# Speeding up gameplay
@export var INGAME_SPEED = 2.0
@export var SLEEP_SPEED_MULTIPLIER = 4.0   # 2.0 x 4.0 = 8, same as your sleep speed
@export var INITIAL_HOUR = 0:
	set(h):
		INITIAL_HOUR = h
		time = INGAME_TO_REAL_MINUTE_DURATION * INITIAL_HOUR * MINUTES_PER_HOUR

var time = 0.0
var sleeping = false
# The last absolute in-game minute we emitted a tick for.
var last_emitted_minute = 0

func _ready():
	time = INGAME_TO_REAL_MINUTE_DURATION * INITIAL_HOUR * MINUTES_PER_HOUR
	sync_to_time()
	pet.pet_actions.sleepingToggled.connect(sleep_toggled)

func _process(delta):
	var speed = INGAME_SPEED * (SLEEP_SPEED_MULTIPLIER if sleeping else 1.0)
	time += delta * INGAME_TO_REAL_MINUTE_DURATION * speed

	# Emit one tick for EVERY minute that passed, so no minute is ever skipped
	# (at high speed a single frame can cover several minutes).
	var target_minute = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	while last_emitted_minute < target_minute:
		last_emitted_minute += 1
		_update_clock(last_emitted_minute)
		time_tick.emit(day, hour, minute)
	set_time()
	rotate_daytime_sprite(target_minute % MINUTES_PER_DAY)

func on_save_game(saved_data:Array[SavedData]):
	var my_data = SavedTime.new()
	my_data.time = time
	saved_data.append(my_data)

func on_load_game(saved_data:SavedData):
	time = saved_data.time
	# Jump straight to the loaded time WITHOUT replaying every minute in between.
	sync_to_time()

func sync_to_time():
	last_emitted_minute = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	_update_clock(last_emitted_minute)
	set_time()

func _update_clock(total_minutes:int):
	day = total_minutes / MINUTES_PER_DAY
	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	hour = current_day_minutes / MINUTES_PER_HOUR
	minute = current_day_minutes % MINUTES_PER_HOUR

func rotate_daytime_sprite(current_day_minutes):
	if current_day_minutes != 0:
		sprite.rotation_degrees = ((current_day_minutes / 360.0) * 90) + 160 # Temp

func set_time():
	daysLabel.text = 'Day' + str(day + 1)
	hoursLabel.text = "%d:%02d" % [hour, minute] # %02d so 5:03 doesn't show as 5:3

# Speed up time while sleeping; derived from state, so it can't drift.
func sleep_toggled(pet_state):
	sleeping = (pet_state == pet.PetState.SLEEPING)
