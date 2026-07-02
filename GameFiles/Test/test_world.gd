extends Node2D

const WAVES = [
{
	"time_limit": 30.0,
	"delay": 3.0,
	"enemies":
	[
		{"scene": preload("res://characters/bat/bat.tscn"), "count": 5},
	]
},
{
	"time_limit": 40.0,
	"delay": 3.0,
	"enemies":
	[
		{"scene": preload("res://characters/bat/bat.tscn"), "count": 8},
		{"scene": preload("res://characters/bat/bat.tscn"), "count": 2},
	]
},
{
	"time_limit": 50.0,
	"delay": 3.0,
	"enemies":
	[
		{"scene": preload("res://characters/bat/bat.tscn"), "count": 10},
		 {"scene": preload("res://characters/bat/bat.tscn"), "count": 8},
		{"scene": preload("res://characters/bat/bat.tscn"), "count": 2},
	]
},

]
