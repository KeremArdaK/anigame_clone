extends Node

# UI elementlerini oyunun en üstüne çizecek katman
var canvas_layer: CanvasLayer
var container: VBoxContainer

func _ready():
	# 1. CanvasLayer yaratıp layer 100'e koyuyoruz (Her şeyin üstünde)
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100 
	add_child(canvas_layer)
	
	# 2. Yazıları alt alta dizecek taşıyıcı kutu
	container = VBoxContainer.new()
	# Bildirimler ekranı tamamen kaplamasın, ortada süzülsün!
	# preset TOP_WIDE yerine CENTER_TOP yapıyoruz ama hiyerarşide genişliği VBox ayarlar.
	container.set_anchors_preset(Control.PRESET_CENTER_TOP)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# İsteğe bağlı: Bildirimlerin arasına ufak boşluklar koymak için (Gap/Theme Constant)
	container.add_theme_constant_override("separation", 10)
	
	# 3. Ekranın en tepesinden boşluk (Margin) ayarlıyoruz
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_top", 30) # Biraz daha aşağı indirdik
	
	# Parçaları iç içe yerleştirip CanvasLayer'a ekliyoruz
	margin.add_child(container)
	canvas_layer.add_child(margin)

# Bu fonksiyonu oyunun HER YERİNDEN çağırabilirsin
func show_message(text: String, accent_color: Color = Color.WHITE):
	# 🌟 ARKA PLAN VE OUTLINE STİLİNİ YARATIYORUZ (Sihirli Kısım)
	var sb = StyleBoxFlat.new()
	# Arkaplan: Hafif Saydam Siyah (RGBA: A=0.7)
	sb.bg_color = Color(0, 0, 0, 0.7) 
	
	# Kalın Outline (Border) Genişliği
	sb.border_width_bottom = 3
	sb.border_width_top = 3
	sb.border_width_left = 3
	sb.border_width_right = 3
	# Outline Rengi: Metin rengiyle (accent) uyumlu yapalım!
	sb.border_color = accent_color 
	
	# Modern bir dokunuş: Köşeleri yuvarlayalım (Pixel Art yapmıyorsan güzel durur)
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	
	# PanelContainer'ın içindeki yazının panele yapışmaması için boşluk (Padding)
	sb.set_content_margin_all(15) 
	
	# ----------------------------------------------------
	
	# UI Elementlerini Yaratıyoruz
	
	# Dış Taşıyıcı (Horizontal Box): Panelin ekranın en tepesinde yayılmasını engeller, 
	# içeriği ortada tutar.
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	# Başlangıçta tamamen saydam
	hbox.modulate.a = 0 
	
	# Panel (Arkaplan ve Outline'ı buraya basıyoruz)
	var panel = PanelContainer.new()
	# Yaratttığımız stili override ederek panele yüklüyoruz!
	panel.add_theme_stylebox_override("panel", sb)
	
	# Label (Metin)
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Metin Rengi: accent_color yapalım, siyah arkaplanda parlasın!
	label.add_theme_color_override("font_color", accent_color)
	# İsteğe bağlı: Font büyüklüğü artırmak istersen:
	# label.add_theme_font_size_override("font_size", 18)
	
	# Hiyerarşiyi kuruyoruz
	panel.add_child(label)
	hbox.add_child(panel)
	container.add_child(hbox)
	
	# Sihirli Animasyon (Tween) Kısmı (Tüm HBox'ı anime ediyoruz)
	var tween = create_tween()
	# EaseOut kullanarak belirme anını daha yumuşak yapıyoruz
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(hbox, "modulate:a", 1.0, 0.3) # 1. Belir
	tween.tween_interval(2.5)                           # 2. Bekle (Oku)
	tween.tween_property(hbox, "modulate:a", 0.0, 0.8) # 3. Kaybol
	tween.tween_callback(hbox.queue_free)              # 4. Sil
