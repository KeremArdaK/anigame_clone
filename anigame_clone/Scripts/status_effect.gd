extends Resource
class_name StatusEffect

enum Type {
    BLIND, #saldırı ıskalar
    BURN, #her tur sonunda hasar verir
    POISON, #her tur sonunda hasar verir
    LEECH, #saldırı yaparken rakibin canını çalar
    DAMAGE_BUFF, #saldırı gücünü artırır
    DEFENSE_BUFF, #savunma gücünü artırır
    RESURRECTION, #ölünce tekrar canlanır
    EXPLODE_ON_DEATH #ölünce patlar ve rakibe hasar verir
}

@export var name: String
@export var description: String
@export var effect_type: Type
@export var power: int = 0 #etkinin gücü, örneğin burn için her tur verilecek hasar, leech için çalınacak can miktarı, bufflar için artırılacak güç miktarı vb.
@export var duration: int = 0 #etkinin kaç tur süreceği, 9999 gibi bir değer sonsuzdur