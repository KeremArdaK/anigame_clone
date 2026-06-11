extends MarginContainer

var panels: Array[PanelContainer] = []

@onready var fight_button := %FightButton 
@onready var shop_button := %ShopButton 
@onready var inv_button := %InvButton

func _ready() -> void:
    panels = [
        %FightPanel, %ShopPanel, %InvPanel
    ]

    fight_button.pressed.connect(show_panel.bind(panels[0]))
    shop_button.pressed.connect(show_panel.bind(panels[1]))
    inv_button.pressed.connect(show_panel.bind(panels[2]))

    show_panel(panels[0])
func show_panel(panel_to_show: PanelContainer) -> void:
    for panel in panels:
        panel.hide()
    
    panel_to_show.show()