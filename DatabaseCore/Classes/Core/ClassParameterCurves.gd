#Class Parameter Curves
#Code by: First

extends Node
class_name FJ_Game_ClassParameterCurves

export (float) var experience_start = 100
export (float) var experience_end = 9999999
export (Curve) var experience_curve

export (float) var hp_start = 30
export (float) var hp_end = 10240
export (Curve) var hp_curve

export (float) var mp_start = 10
export (float) var mp_end = 768
export (Curve) var mp_curve

export (float) var attack_start = 1
export (float) var attack_end = 127
export (Curve) var attack_curve

export (float) var defense_start = 0
export (float) var defense_end = 90
export (Curve) var defense_curve

export (float) var cri_rate_start = 0.01
export (float) var cri_rate_end = 0.08
export (Curve) var cri_rate_curve
