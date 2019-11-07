# NES Color Palette
# Code by First

# If you want to create graphics for the NES, you're stuck using this
# color palette. Below you will find the palette in several formats
# to use in your favorite editor.


### Hexadecimal ###

#000000
#080808
#797979
#dbdbdb

#004159
#008a8a
#00ebdb
#00ffff

#005900
#00aa45
#59fb9a
#bafbdb

#006900
#00aa00
#59db55
#bafbba

#007900
#00ba00
#bafb18
#dbfb19

#513000
#ae7d00
#fbba00
#fbdb79

#8a1400
#e75d10
#ffa245
#ffe3aa

#aa1000
#fb3800
#fb7959
#f3d3b2

#aa0020
#e70059
#fb599a
#fba6c3

#960086
#db00cf
#fb79fb
#fbbafb

#4528be
#6945ff
#9a79fb
#dbbafb

#0000be
#0059fb
#698aff
#babafb

#0000ff
#0079fb
#3cbeff
#a6e7ff

#525252
#bebebe
#fbfbfb
#ffffff


### Decimal ###

# 0, 0, 0
# 8, 8, 8
# 121, 121, 121
# 219, 219, 219

# 0, 65, 89
# 0, 138, 138
# 0, 235, 219
# 0, 255, 255

# 0, 89, 0
# 0, 170, 69
# 89, 251, 154
# 186, 251, 219

# 0, 105, 0
# 0, 170, 0
# 89, 219, 85
# 186, 251, 186

# 0, 121, 0
# 0, 186, 0
# 186, 251, 24
# 219, 251, 251

# 81, 48, 0
# 174, 125, 0
# 251, 186, 0
# 251, 219, 121

# 138, 20, 0
# 231, 93, 16
# 255, 162, 69
# 255, 227, 170

# 170, 16, 0
# 251, 56, 0
# 251, 121, 89
# 243, 211, 178

# 170, 0, 32
# 231, 0, 89
# 251, 89, 154
# 251, 166, 195

# 150, 0, 134
# 219, 0, 207
# 251, 121, 251
# 251, 186, 251

# 69, 40, 190
# 105, 69, 255
# 154, 121, 251
# 219, 186, 251

# 0, 0, 190
# 0, 89, 251
# 105, 138, 255
# 186, 186, 251

# 0, 0, 255
# 0, 121, 251
# 60, 190, 255
# 166, 231, 255

# 82, 82, 82
# 190, 190, 190
# 251, 251, 251
# 255, 255, 255

extends Node

class_name NESColorPalette

const NesColor = {
	BLACK1 = Color("000000ff"),
	BLACK2 = Color("080808ff"),
	BLACK3 = Color("797979ff"),
	BLACK4 = Color("dbdbdbff"),
	CYAN1 = Color("004159ff"),
	CYAN2 = Color("008a8aff"),
	CYAN3 = Color("00ebdbff"),
	CYAN4 = Color("00ffffff"),
	LIGHTGREEN1 = Color("005900ff"),
	LIGHTGREEN2 = Color("00aa45ff"),
	LIGHTGREEN3 = Color("59fb9aff"),
	LIGHTGREEN4 = Color("bafbdbff"),
	GREEN1 = Color("006900ff"),
	GREEN2 = Color("00aa00ff"),
	GREEN3 = Color("59db55ff"),
	GREEN4 = Color("bafbbaff"),
	GREENYELLOW1 = Color("007900ff"),
	GREENYELLOW2 = Color("00ba00ff"),
	GREENYELLOW3 = Color("bafb18ff"),
	GREENYELLOW4 = Color("dbfb19ff"),
	CHOCOLATE1 = Color("513000ff"),
	CHOCOLATE2 = Color("ae7d00ff"),
	CHOCOLATE3 = Color("fbba00ff"),
	CHOCOLATE4 = Color("fbdb79ff"),
	LIGHTSALMON1 = Color("8a1400ff"),
	LIGHTSALMON2 = Color("e75d10ff"),
	LIGHTSALMON3 = Color("ffa245ff"),
	LIGHTSALMON4 = Color("ffe3aaff"),
	TOMATO1 = Color("aa1000ff"),
	TOMATO2 = Color("fb3800ff"),
	TOMATO3 = Color("fb7959ff"),
	TOMATO4 = Color("f3d3b2ff"),
	PINK1 = Color("aa0020ff"),
	PINK2 = Color("e70059ff"),
	PINK3 = Color("fb599aff"),
	PINK4 = Color("fba6c3ff"),
	PURPLE1 = Color("960086ff"),
	PURPLE2 = Color("db00cfff"),
	PURPLE3 = Color("fb79fbff"),
	PURPLE4 = Color("fbbafbff"),
	MEDIUMPURPLE1 = Color("4528beff"),
	MEDIUMPURPLE2 = Color("6945ffff"),
	MEDIUMPURPLE3 = Color("9a79fbff"),
	MEDIUMPURPLE4 = Color("dbbafbff"),
	LIGHTSTEELBLUE1 = Color("0000beff"),
	LIGHTSTEELBLUE2 = Color("0059fbff"),
	LIGHTSTEELBLUE3 = Color("698affff"),
	LIGHTSTEELBLUE4 = Color("babafbff"),
	TORQUOISE1 = Color("0000ffff"),
	TORQUOISE2 = Color("0079fbff"),
	TORQUOISE3 = Color("3cbeffff"),
	TORQUOISE4 = Color("a6e7ffff"),
	WHITE1 = Color("525252ff"),
	WHITE2 = Color("bebebeff"),
	WHITE3 = Color("fbfbfbff"),
	WHITE4 = Color("ffffffff"),
}

const BLACK1 : = Color("000000")
const BLACK2 : = Color("080808")
const BLACK3 : = Color("797979")
const BLACK4 : = Color("dbdbdb")
const CYAN1 : = Color("004159")
const CYAN2 : = Color("008a8a")
const CYAN3 : = Color("00ebdb")
const CYAN4 : = Color("00ffff")
const LIGHTGREEN1 : = Color("005900")
const LIGHTGREEN2 : = Color("00aa45")
const LIGHTGREEN3 : = Color("59fb9a")
const LIGHTGREEN4 : = Color("bafbdb")
const GREEN1 : = Color("006900")
const GREEN2 : = Color("00aa00")
const GREEN3 : = Color("59db55")
const GREEN4 : = Color("bafbba")
const GREENYELLOW1 : = Color("007900")
const GREENYELLOW2 : = Color("00ba00")
const GREENYELLOW3 : = Color("bafb18")
const GREENYELLOW4 : = Color("dbfb19")
const CHOCOLATE1 : = Color("513000")
const CHOCOLATE2 : = Color("ae7d00")
const CHOCOLATE3 : = Color("fbba00")
const CHOCOLATE4 : = Color("fbdb79")
const LIGHTSALMON1 : = Color("8a1400")
const LIGHTSALMON2 : = Color("e75d10")
const LIGHTSALMON3 : = Color("ffa245")
const LIGHTSALMON4 : = Color("ffe3aa")
const TOMATO1 : = Color("aa1000")
const TOMATO2 : = Color("fb3800")
const TOMATO3 : = Color("fb7959")
const TOMATO4 : = Color("f3d3b2")
const PINK1 : = Color("aa0020")
const PINK2 : = Color("e70059")
const PINK3 : = Color("fb599a")
const PINK4 : = Color("fba6c3")
const PURPLE1 : = Color("960086")
const PURPLE2 : = Color("db00cf")
const PURPLE3 : = Color("fb79fb")
const PURPLE4 : = Color("fbbafb")
const MEDIUMPURPLE1 : = Color("4528be")
const MEDIUMPURPLE2 : = Color("6945ff")
const MEDIUMPURPLE3 : = Color("9a79fb")
const MEDIUMPURPLE4 : = Color("dbbafb")
const LIGHTSTEELBLUE1 : = Color("0000be")
const LIGHTSTEELBLUE2 : = Color("0059fb")
const LIGHTSTEELBLUE3 : = Color("698aff")
const LIGHTSTEELBLUE4 : = Color("babafb")
const TORQUOISE1 : = Color("0000ff")
const TORQUOISE2 : = Color("0079fb")
const TORQUOISE3 : = Color("3cbeff")
const TORQUOISE4 : = Color("a6e7ff")
const WHITE1 : = Color("525252")
const WHITE2 : = Color("bebebe")
const WHITE3 : = Color("fbfbfb")
const WHITE4 : = Color("ffffff")

const COLORLIST = {
	"BLACK1" : BLACK1,
	"BLACK2" : BLACK2,
	"BLACK3" : BLACK3,
	"BLACK4" : BLACK4,
	"CYAN1" : CYAN1,
	"CYAN2" : CYAN2,
	"CYAN3" : CYAN3,
	"CYAN4" : CYAN4,
	"LIGHTGREEN1" : LIGHTGREEN1,
	"LIGHTGREEN2" : LIGHTGREEN2,
	"LIGHTGREEN3" : LIGHTGREEN3,
	"LIGHTGREEN4" : LIGHTGREEN4,
	"GREEN1" : GREEN1,
	"GREEN2" : GREEN2,
	"GREEN3" : GREEN3,
	"GREEN4" : GREEN4,
	"GREENYELLOW1" : GREENYELLOW1,
	"GREENYELLOW2" : GREENYELLOW2,
	"GREENYELLOW3" : GREENYELLOW3,
	"GREENYELLOW4" : GREENYELLOW4,
	"CHOCOLATE1" : CHOCOLATE1,
	"CHOCOLATE2" : CHOCOLATE2,
	"CHOCOLATE3" : CHOCOLATE3,
	"CHOCOLATE4" : CHOCOLATE4,
	"LIGHTSALMON1" : LIGHTSALMON1,
	"LIGHTSALMON2" : LIGHTSALMON2,
	"LIGHTSALMON3" : LIGHTSALMON3,
	"LIGHTSALMON4" : LIGHTSALMON4,
	"TOMATO1" : TOMATO1,
	"TOMATO2" : TOMATO2,
	"TOMATO3" : TOMATO3,
	"TOMATO4" : TOMATO4,
	"PINK1" : PINK1,
	"PINK2" : PINK2,
	"PINK3" : PINK3,
	"PINK4" : PINK4,
	"PURPLE1" : PURPLE1,
	"PURPLE2" : PURPLE2,
	"PURPLE3" : PURPLE3,
	"PURPLE4" : PURPLE4,
	"MEDIUMPURPLE1" : MEDIUMPURPLE1,
	"MEDIUMPURPLE2" : MEDIUMPURPLE2,
	"MEDIUMPURPLE3" : MEDIUMPURPLE3,
	"MEDIUMPURPLE4" : MEDIUMPURPLE4,
	"LIGHTSTEELBLUE1" : LIGHTSTEELBLUE1,
	"LIGHTSTEELBLUE2" : LIGHTSTEELBLUE2,
	"LIGHTSTEELBLUE3" : LIGHTSTEELBLUE3,
	"LIGHTSTEELBLUE4" : LIGHTSTEELBLUE4,
	"TORQUOISE1" : TORQUOISE1,
	"TORQUOISE2" : TORQUOISE2,
	"TORQUOISE3" : TORQUOISE3,
	"TORQUOISE4" : TORQUOISE4,
	"WHITE1" : WHITE1,
	"WHITE2" : WHITE2,
	"WHITE3" : WHITE3,
	"WHITE4" : WHITE4
}
