extends RefCounted
## Landscape touch layout. Game rules and callbacks are shared with desktop.
const WORLD_FRAME:=Rect2(12,80,936,452)
static func rect(c: Control,r: Rect2) -> void:
	if c is ScrollContainer and c.get_child_count()>0:
		var margin: Control=c.get_child(0)
		if margin is MarginContainer:
			margin.custom_minimum_size.x=r.size.x-16
			margin.size.x=r.size.x-16
			var body: Control=margin.get_child(0)
			body.custom_minimum_size.x=0; body.size.x=r.size.x-40
	c.position=r.position; c.size=r.size

static func font(c: Control,n: int,g) -> void:
	c.add_theme_font_size_override("font_size",n+(2 if g.settings.large else 0))

static func buttons(root: Node) -> Array[Button]:
	var out: Array[Button]=[]
	for c in root.get_children():
		if c is Button and not c is CheckButton: out.append(c)
		out.append_array(buttons(c))
	return out

static func named(root: Node,text: String) -> Button:
	for b in buttons(root):
		if b.text.strip_edges()==text: return b
	return null

static func move_button(root: Node,text: String,r: Rect2) -> void:
	var b:=named(root,text)
	if b: rect(b,r)

static func apply(g) -> void:
	if not g.mobile_layout: return
	if bool(g.ui.get_meta("mobile_laid_out",false)):
		if is_instance_valid(g.overlay) and not bool(g.overlay.get_meta("mobile_laid_out",false)):
			overlay(g); g.overlay.set_meta("mobile_laid_out",true)
		return
	g.ui.set_meta("mobile_laid_out",true)
	g.art.presentation_rect=Rect2(220,164,565,288) if g.screen!="menu" and g.screen!="setup" else Rect2(420,80,530,360)
	for c in g.ui.get_children():
		if c is Label: font(c,20,g)
		if c is Button: font(c,22,g)
	match g.screen:
		"menu": menu(g)
		"setup": setup(g)
		"world": world(g)
		"challenge": challenge(g)
		"profiles": profiles(g)
		"ending": ending(g)
		"credits": credits(g)
		"collapse","gameover_final": gameover(g)
		"success","timeout": result(g)
		"restoring":
			for c in g.ui.get_children():
				if c is Panel: rect(c,Rect2(60,20,840,70))
				elif c is Label: rect(c,Rect2(80,35,800,45))
	if is_instance_valid(g.overlay): overlay(g); g.overlay.set_meta("mobile_laid_out",true)
	g.art.queue_redraw()

static func menu(g) -> void:
	for c in g.ui.get_children():
		var old: Rect2=c.get_meta("desktop_rect",Rect2())
		if c==g.title_label:
			rect(c,Rect2(24,46,410,90)); c.scale=Vector2.ONE*.74
		elif c is Label:
			if old.position.y==83: rect(c,Rect2(24,16,410,30)); font(c,16,g)
			elif old.position.y==247: rect(c,Rect2(24,133,400,35)); font(c,20,g)
			elif old.position.y==315: c.text="Restaure as obras e descubra os padrões do tempo."; rect(c,Rect2(24,179,390,80)); font(c,22,g)
			elif old.position.y==749: rect(c,Rect2(24,508,900,25)); font(c,14,g)
			else: c.visible=false
	move_button(g.ui,"Começar uma jornada",Rect2(24,276,390,64))
	move_button(g.ui,"Continuar",Rect2(24,350,390,64))
	move_button(g.ui,"Como jogar",Rect2(24,426,185,64))
	move_button(g.ui,"Configurações",Rect2(225,426,189,64))
	move_button(g.ui,"A história do museu",Rect2(530,440,360,64))

static func setup(g) -> void:
	for c in g.ui.get_children():
		var old: Rect2=c.get_meta("desktop_rect",Rect2())
		if c is Panel: rect(c,Rect2(12,12,608,516) if old.position.x<700 else Rect2(636,12,312,516))
		elif c is Label and c not in [g.setup_hint,g.setup_notice,g.setup_placeholder]:
			if old.position.y==70: rect(c,Rect2(30,22,560,28)); font(c,15,g)
			elif old.position.y==119: rect(c,Rect2(30,57,560,44)); font(c,27,g)
			elif old.position.y==449: c.visible=false
			elif old.position.y==582:
				c.text="Normal: sem tempo. Difícil: com cronômetro.\nAmbos: duas vidas e uma tentativa extra por jornada."
				rect(c,Rect2(30,388,560,60)); font(c,17,g)
			elif old.position.y==135: rect(c,Rect2(654,28,280,32)); font(c,17,g)
	rect(g.setup_name,Rect2(30,112,568,64)); font(g.setup_name,25,g)
	rect(g.setup_hint,Rect2(30,183,568,47)); font(g.setup_hint,14,g)
	if not g.setup_attempted: g.setup_hint.text="Até 20 caracteres. Acentos e emojis são aceitos."
	for i in range(2):
		rect(g.setup_character_buttons[i],Rect2(30+i*290,231,278,64))
		rect(g.setup_mode_buttons[i],Rect2(30+i*290,310,278,64))
	rect(g.character_view,Rect2(650,75,280,290))
	rect(g.setup_placeholder,Rect2(654,165,276,150)); font(g.setup_placeholder,22,g)
	rect(g.setup_notice,Rect2(654,375,276,135)); font(g.setup_notice,18,g)
	move_button(g.ui,"Voltar",Rect2(90,454,220,64)); move_button(g.ui,"Iniciar",Rect2(330,454,220,64))

static func header(g) -> void:
	for c in g.ui.get_children():
		var old: Rect2=c.get_meta("desktop_rect",Rect2())
		if c is Panel and old.position.y==22: rect(c,Rect2(12,8,936,68))
		elif c is Label and old.position.y<80:
			if old.position.x==48: rect(c,Rect2(26,26,190,38)); font(c,22,g)
			elif old.position.x==275: rect(c,Rect2(220,27,170,36)); font(c,18,g)
			elif old.position.x==550: rect(c,Rect2(394,26,300,38)); font(c,20,g)
			elif old.position.x==910: rect(c,Rect2(700,27,75,36)); font(c,18,g)
	move_button(g.ui,"II  Pausar",Rect2(782,10,160,64))

static func world(g) -> void:
	header(g)
	# The diamond-shaped room leaves its corners free for touch controls.
	# Use the full height rather than reserving a rectangular strip for the room.
	g.art.presentation_rect=WORLD_FRAME
	for c in g.ui.get_children():
		var old: Rect2=c.get_meta("desktop_rect",Rect2())
		if c is Panel and old.position.y==108: rect(c,Rect2(14,88,280,75))
		elif c is Panel and old.position.y==110: rect(c,Rect2(688,88,254,85))
		elif c is Panel and old.position.y==713: rect(c,Rect2(12,470,290,62))
		elif c is Label and old.position.y==116: rect(c,Rect2(30,94,248,24)); font(c,14,g)
		elif c is Label and old.position.y==143: rect(c,Rect2(30,119,248,38)); font(c,21,g)
		elif c==g.objective: rect(c,Rect2(702,94,226,73)); font(c,18,g)
	rect(g.status,Rect2(26,476,262,48)); g.status.text="Toque em Levantar." if g.art.seated else "Toque para caminhar."; font(g.status,16,g)
	g.status.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT
	g.status.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	move_button(g.ui,"Mapa",Rect2(792,181,150,64)); move_button(g.ui,"Caderno",Rect2(792,259,150,64))
	rect(g.bench_button,Rect2(792,337,150,64))
	move_button(g.ui,"Examinar",Rect2(650,465,290,64))
	var dirs: Array=["<",">","^","v"]
	var positions: Array=[Vector2(12,380),Vector2(176,380),Vector2(94,298),Vector2(94,380)]
	for i in range(4): move_button(g.ui,dirs[i],Rect2(positions[i],Vector2(80,80)))

static func challenge(g) -> void:
	header(g)
	for c in g.ui.get_children():
		var old: Rect2=c.get_meta("desktop_rect",Rect2())
		if c is Panel and old.position.y==108: rect(c,Rect2(12,86,936,446))
		elif c is Label and old.position.y==128: rect(c,Rect2(30,95,730,36)); font(c,17,g)
		elif c==g.timer_label: rect(c,Rect2(784,95,150,38)); font(c,21,g)
		elif c is ScrollContainer: rect(c,Rect2(308,141,620,128))
		elif c==g.exhibit_view: rect(c,Rect2(30,142,250,180)); c.display_scale=1.4
		elif c.get_script()==g.Bench: rect(c,Rect2(30,142,250,180))
		elif c is Label and c.has_meta("art_caption"): rect(c,Rect2(32,382,245,64)); font(c,16,g)
		elif c is Label and old.position.y==355: c.text="Escolha e confirme."; rect(c,Rect2(310,265,616,30)); font(c,17,g)
	if g.ui.get_children().any(func(c): return c is ScrollContainer):
		for sc in g.ui.get_children():
			if sc is ScrollContainer:
				font(sc.get_child(0).get_child(0),24,g)
	for i in range(g.answer_buttons.size()): rect(g.answer_buttons[i],Rect2(310+(i%2)*316,301+int(i/2)*73,300,64))
	font(g.status,18,g)
	# Feedback is scrollable so long hints remain readable without covering answers.
	var feedback:=ScrollContainer.new(); g.place(feedback,Rect2(30,394,250,64)); g.padded_scroll_content(feedback,g.status)
	for c in g.ui.get_children():
		if c is Label and c.has_meta("art_caption"):
			var caption_scroll:=ScrollContainer.new(); g.place(caption_scroll,Rect2(30,328,250,60)); g.padded_scroll_content(caption_scroll,c)
	move_button(g.ui,"Dica",Rect2(24,466,130,64)); move_button(g.ui,"Caderno",Rect2(168,466,150,64))
	move_button(g.ui,"Próxima pergunta",Rect2(332,466,260,64)); move_button(g.ui,"Confirmar restauração",Rect2(606,466,328,64))

static func profiles(g) -> void:
	for c in g.ui.get_children():
		if c is Panel: rect(c,Rect2(20,12,920,516))
		elif c is Label: rect(c,Rect2(42,25 if c.text=="Suas jornadas" else 140,875,60)); font(c,30 if c.text=="Suas jornadas" else 22,g)
		elif c is ScrollContainer:
			rect(c,Rect2(42,105,875,330))
			for b in buttons(c): b.custom_minimum_size=Vector2(640 if b.text!="Excluir" else 160,64); font(b,21,g)
	move_button(g.ui,"Voltar",Rect2(42,454,230,64))

static func ending(g) -> void:
	for c in g.ui.get_children():
		var old: Rect2=c.get_meta("desktop_rect",Rect2())
		if c.get_script()==g.Museum: c.presentation_rect=Rect2(500,105,440,330)
		elif c is Panel: rect(c,Rect2(16,12,466,516))
		elif c is Label:
			if old.position.y==87: rect(c,Rect2(36,25,426,32)); font(c,16,g)
			elif old.position.y==151: rect(c,Rect2(36,66,426,110)); font(c,29,g)
			else: rect(c,Rect2(36,346,426,85)); font(c,16,g)
		elif c is ScrollContainer: rect(c,Rect2(36,188,426,145))
	for action in [named(g.ui,"Ver créditos"),named(g.ui,"Meu aprendizado")]:
		if action: font(action,18,g)
	move_button(g.ui,"Ver créditos",Rect2(36,454,204,64)); move_button(g.ui,"Meu aprendizado",Rect2(254,454,208,64))

static func credit_controls(g) -> void:
	if not is_instance_valid(g.credit_button): return
	g.credit_hint.text="Letras pausadas. Toque em Retornar aos créditos." if g.credits_paused else "Toque em Pausar para parar somente as letras."
	rect(g.credit_hint,Rect2(80,434,800,28)); font(g.credit_hint,16,g)
	rect(g.credit_button,Rect2(500 if g.credits_paused else 280,466,400,64))
	if is_instance_valid(g.credit_resume_button):
		g.credit_resume_button.visible=g.credits_paused
		rect(g.credit_resume_button,Rect2(60,466,400,64))

static func credits(g) -> void:
	for scene in g.credit_scenes: scene.presentation_rect=Rect2(50,20,860,420)
	for c in g.ui.get_children():
		if c is Panel: rect(c,Rect2(70,12,820,422))
	rect(g.credit_viewport,Rect2(80,20,800,410))
	g.credit_roll.size.x=760; font(g.credit_roll,25,g)
	if not g.settings.reduced: g.credit_roll.position.y=410
	credit_controls(g)

static func result(g) -> void:
	var labels: Array=[]
	for c in g.ui.get_children():
		if c is Panel: rect(c,Rect2(24,20,912,500))
		elif c is Label: labels.append(c)
	var ys: Array=[35,100,170,326] if g.screen=="success" else [35,100,170] if g.screen=="collapse" else [35,110]
	var hs: Array=[50,64,146,90] if g.screen=="success" else [50,64,246] if g.screen=="collapse" else [65,300]
	for i in range(labels.size()):
		rect(labels[i],Rect2(46,ys[i],860,hs[i])); font(labels[i],26 if i==0 else 21,g)
		if i>=2 or (g.screen=="timeout" and i==1):
			var scroll:=ScrollContainer.new(); g.place(scroll,Rect2(46,ys[i],860,hs[i])); g.padded_scroll_content(scroll,labels[i])
	var actions:=buttons(g.ui)
	var width: float=(860-(actions.size()-1)*16)/maxi(1,actions.size())
	for i in range(actions.size()): rect(actions[i],Rect2(46+i*(width+16),438,width,64))

static func overlay(g) -> void:
	var root: Control=g.overlay
	if bool(root.get_meta("learning_dashboard",false)): return
	var bs:=buttons(root)
	var scrolls: Array=[]
	var labels: Array=[]
	var sliders: Array=[]
	var toggles: Array=[]
	for c in root.get_children():
		if c is Panel: rect(c,Rect2(24,16,912,508))
		elif c is Label: labels.append(c)
		elif c is ScrollContainer: scrolls.append(c)
		elif c is Slider: sliders.append(c)
		elif c is CheckButton: toggles.append(c)
	for b in bs: font(b,22,g)
	if named(root,"Retomar"):
		g.art.presentation_rect=Rect2(0,70,490,440)
		for c in root.get_children():
			if c is Panel: rect(c,Rect2(484,12,464,516))
		for i in range(labels.size()):
			rect(labels[i],Rect2(508,32 if i==0 else 440,416,68))
			font(labels[i],26 if i==0 else 17,g)
		move_button(root,"Retomar",Rect2(508,116,416,64))
		move_button(root,"Configurações",Rect2(508,198,200,64))
		move_button(root,"Controles",Rect2(724,198,200,64))
		move_button(root,"Trocar pergunta",Rect2(508,278,416,64))
		move_button(root,"Voltar ao menu",Rect2(508,358,416,64))
	elif not sliders.is_empty():
		for i in range(labels.size()): rect(labels[i],Rect2(50,30 if i==0 else 102+(i-1)*72,350 if i>0 else 850,50)); font(labels[i],28 if i==0 else 22,g)
		for i in range(sliders.size()): rect(sliders[i],Rect2(400,98+i*72,500,64))
		for i in range(toggles.size()):
			if i==1: toggles[i].text="Texto ampliado"
			rect(toggles[i],Rect2(50+i*450,331,410,65)); font(toggles[i],20,g)
		for i in range(bs.size()): rect(bs[i],Rect2(275 if bs.size()==1 else 50+i*450,442,410,64))
	elif named(root,"Voltar") and bs.size()==4 and scrolls.is_empty():
		for l in labels: rect(l,Rect2(60,34,840,60)); font(l,28,g)
		for i in range(3): rect(bs[i],Rect2(60,116+i*95,840,74))
		rect(bs[3],Rect2(60,439,240,64))
	elif root.get_children().any(func(c): return c.get_script()==g.Exhibit):
		for i in range(labels.size()): rect(labels[i],Rect2(48 if i<2 else 520,30+i*44 if i<2 else 155+(i-2)*140,860 if i<2 else 380,65 if i<2 else 125)); font(labels[i],25 if i==1 else 20,g)
		for c in root.get_children():
			if c.get_script()==g.Exhibit: rect(c,Rect2(50,145,430,270)); c.display_scale=2
		for i in range(bs.size()): rect(bs[i],Rect2(50+i*455,442,405,64))
	else:
		for l in labels: rect(l,Rect2(48,32,864,60)); font(l,27 if l.text.length()<45 else 23,g)
		for sc in scrolls: rect(sc,Rect2(48,108,864,306))
		for i in range(bs.size()): rect(bs[i],Rect2(48+i*455,440,409,64))

static func gameover(g) -> void:
	g.art.presentation_rect=Rect2(0,60,492,462)
	rect(g.gameover_shade,Rect2(0,0,960,540))
	for c in g.ui.get_children():
		if c is Label: rect(c,Rect2(22,20,438,55)); font(c,18,g)
	rect(g.gameover_card,Rect2(484,12,464,516))
	for c in g.gameover_card.get_children():
		if c is Panel: rect(c,Rect2(0,0,464,516))
		elif c is Label:
			var role: String=str(c.get_meta("gameover_role",""))
			match role:
				"eyebrow": rect(c,Rect2(24,16,416,28)); font(c,14,g)
				"heading": rect(c,Rect2(24,47,416,60)); font(c,38,g)
				"reason": rect(c,Rect2(24,116,416,54)); font(c,19,g)
				"body": rect(c,Rect2(24,175,416,84)); font(c,18,g)
				"warning": rect(c,Rect2(24,264,416,65)); font(c,17,g)
				"returning": rect(c,Rect2(24,380,416,78)); font(c,21,g)
	for c in g.gameover_card.get_children():
		if c is ScrollContainer:
			var role: String=str(c.get_meta("gameover_role",""))
			rect(c,Rect2(24,170 if role=="body" else 252,416,78 if role=="body" else 80))
			font(c.get_child(0).get_child(0),18 if role=="body" else 17,g)
	var actions:=buttons(g.gameover_card)
	for i in range(actions.size()):
		rect(actions[i],Rect2(24,336+i*58,416,52)); font(actions[i],19,g)
