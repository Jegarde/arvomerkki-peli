class_name RankManager
extends Node

@export var ranks: Dictionary[String, CompressedTexture2D]
var rank_classes: Array[Rank]

func _ready():
	for rank_name in ranks.keys():
		var rank = Rank.new(rank_name, ranks[rank_name])
		rank_classes.append(rank)
		
		
func get_ranks() -> Array[Rank]:
	return rank_classes
		
		
func get_random_unique_ranks(count: int) -> Array[Rank]:
	rank_classes.shuffle()
	var random_ranks: Array[Rank] = rank_classes.slice(0, count)
	return random_ranks
		
		
func get_random_rank() -> Rank:
	return rank_classes.pick_random()
