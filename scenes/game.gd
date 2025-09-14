extends Control

@export var rank_manager: RankManager
@export var option_buttons: Array[TextureButton]
@export var next_round_timer: Timer

@export_group("SFX")
@export var correct_sfx: AudioStreamPlayer
@export var incorrect_sfx: AudioStreamPlayer

@export_group("Labels")
@export var rank_label: Label
@export var score_label: Label
@export var high_score_label: Label

var correct_answer_index: int

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
		i += 1


func on_answer(answer_index: int):
	var answer_color: Color
	if answer_index == correct_answer_index:
		correct_sfx.play()
		score += 1
		if score > high_score:
			high_score = score
		answer_color = Color.GREEN
	else:
		incorrect_sfx.play()
		score = 0
		answer_color = Color.RED
		
	rank_label.label_settings.font_color = answer_color
	next_round_timer.start()
	
	
func _on_next_round_timer_timeout() -> void:
	rank_label.label_settings.font_color = Color.WHITE
	new_round()


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
