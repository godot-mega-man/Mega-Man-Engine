# Number Simplifier
#
# NumberSimplifier allows turning a long number into a simplified
# text number. Ex: floating value of 2500 will become 2K, 3200021
# will be 3M, 555555 will be 555K, etc.

extends Node

class AbbreviatedLetters:
	const K = "K"
	const M = "M"


static func get_simplified_number(number : float) -> String:
	var million : float = 1000000
	var thousand : float = 1000
	
	if number >= million:
		var num_text = str(number)
		return num_text.left(num_text.length() - 6) + AbbreviatedLetters.M
	if number >= thousand:
		var num_text = str(number)
		return num_text.left(num_text.length() - 3) + AbbreviatedLetters.K
	
	return number as String
