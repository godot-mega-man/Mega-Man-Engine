extends Node


const DIFF_NEWCOMER = 0 # Super Easy
const DIFF_CASUAL = 1 # Easy
const DIFF_NORMAL = 2
const DIFF_SUPERHERO = 3 # HARD!

const DIFFNAME_NEWCOMER = "Newcomer" # Super Easy
const DIFFNAME_CASUAL = "Casual" # Easy
const DIFFNAME_NORMAL = "Normal"
const DIFFNAME_SUPERHERO = "Superhero" # HARD!

const LIVES_NEWCOMER = 9
const LIVES_CASUAL = 5
const LIVES_NORMAL = 2
const LIVES_SUPERHERO = 2

var difficulty := DIFF_NORMAL


func get_lives_by_current_difficulty() -> int:
	if difficulty == DIFF_NEWCOMER:
		return LIVES_NEWCOMER
	if difficulty == DIFF_CASUAL:
		return LIVES_CASUAL
	if difficulty == DIFF_NORMAL:
		return LIVES_NORMAL
	if difficulty == DIFF_SUPERHERO:
		return LIVES_SUPERHERO
	
	return 0
