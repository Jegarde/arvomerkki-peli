extends Control

@export var rank_manager: RankManager
@export var option_buttons: Array[TextureButton]
@export var round_progress: ProgressBar

@export_group("Timers")
@export var round_progress_timer: Timer
@export var next_round_timer: Timer

@export_group("SFX")
@export var correct_sfx: AudioStreamPlayer
@export var incorrect_sfx: AudioStreamPlayer

@export_group("Labels")
@export var rank_label: Label
@export var score_label: Label
@export var high_score_label: Label

var correct_answer_index: int
var time_remaining: float = 100
var time_speed: float = 1
var can_answer: bool = true
var tween: Tween

var score: int:
	set(value):
		score = value
		score_label.text = "Pisteet: %s" % score
		
var high_score: int:
	set(value):
		high_score = value
		high_score_label.text = "Ennätys: %s" % high_score


func _ready():
	high_score = 0 
	score = 0
	
	setup_buttons()
	new_round()


func setup_buttons():
	var i := 0
	for btn in option_buttons:
		btn.pressed.connect(on_answer.bind(i))
		btn.mouse_entered.connect(_on_button_mouse_entered.bind(btn))
		btn.mouse_exited.connect(_on_button_mouse_exited.bind(btn))
		i += 1


func _on_button_mouse_entered(btn: TextureButton) -> void:
	btn.modulate = Color.from_rgba8(225, 225, 225)
	
	
func _on_button_mouse_exited(btn: TextureButton) -> void:
	btn.modulate = Color.WHITE
	

func on_answer(answer_index: int):
	if not can_answer: return
	
	can_answer = false
	if answer_index == correct_answer_index:
		round_won() 
	else:
		round_lost()
		
	next_round_timer.start()
	
	
func round_won() -> void:
	correct_sfx.play()
	score += 1
	if score > high_score:
		high_score = score
	rank_label.label_settings.font_color = Color.GREEN
	time_speed *= 1.05
	
func round_lost() -> void:
	incorrect_sfx.play()
	score = 0
	rank_label.label_settings.font_color = Color.RED
	time_speed = 1
	
	

func reset_round_timer() -> void:
	time_remaining = 100
	round_progress.value = time_remaining
	round_progress_timer.start()
	

func new_round() -> void:
	var random_ranks := rank_manager.get_random_unique_ranks(option_buttons.size())
	var correct_rank: Rank = random_ranks.pick_random()
	
	var i := 0
	for btn in option_buttons:
		var rank := random_ranks[i]
		btn.texture_normal = random_ranks[i].image
		
		if rank.rank_name == correct_rank.rank_name:
			correct_answer_index = i
		
		i += 1
		
	rank_label.text = correct_rank.rank_name
	reset_round_timer()
	can_answer = true


func _on_round_time_timer_timeout() -> void:
	if not can_answer: return
	time_remaining -= time_speed
	animate_to(time_remaining, 0.1)
	#round_progress.value = time_remaining
	
	if time_remaining <= 0:
		on_answer(-1)
		
	round_progress_timer.start()
	
	
func _on_next_round_timer_timeout() -> void:
	rank_label.label_settings.font_color = Color.WHITE
	new_round()
	

func animate_to(target_value: float, duration: float = 0.5):
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.tween_property(round_progress, "value", target_value, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
