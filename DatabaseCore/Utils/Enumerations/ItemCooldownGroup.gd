#ItemCooldownGroup
#Code by: First

#Item Cooldown group is a collection of item type
#used in consumable items.

#You can add types here for use with consumable
#items so that you can specify when an item
#is used, which the cooldown applies to the item.

extends Node
class_name FJ_Enum_ItemCooldownGroup

#ADD GROUP HERE...
enum ITEM_COOLDOWN_GROUP {
	healing_potion,
	mana_potion
}