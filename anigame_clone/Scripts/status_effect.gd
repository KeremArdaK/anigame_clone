extends Resource
class_name StatusEffect

enum Type {
    BLIND,
    BURN,
    POISON,
    LEECH,
    DAMAGE_BUFF,
    DEFENSE_BUFF,
    RESURRECTION,
    EXPLODE_ON_DEATH
}


enum StackBehavior {
    STACK,
    REFRESH,
    INDEPENDENT
}


@export var name: String
@export var description: String
@export var effect_type: Type
@export var stack_behavior: StackBehavior = StackBehavior.REFRESH
@export var power: int = 0
@export var duration: int = 0