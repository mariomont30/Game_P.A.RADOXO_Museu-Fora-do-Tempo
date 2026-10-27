extends "res://scripts/ui.gd"

const Museum=preload("res://scripts/museum.gd")
const Exhibit=preload("res://scripts/exhibit_view.gd")
const Bench=preload("res://scripts/restoration.gd")
const Audio=preload("res://scripts/audio.gd")
const Title=preload("res://scripts/title.gd")
const Character=preload("res://scripts/character_view.gd")
const MobileLayout=preload("res://scripts/mobile_layout.gd")
const LivesDisplay=preload("res://scripts/lives_display.gd")
const EntryBackdrop=preload("res://scripts/entry_backdrop.gd")
const GalleryTransition=preload("res://scripts/gallery_transition.gd")
const QuestionDraw=preload("res://scripts/question_draw.gd")
const SAVE="user://paradoxo_v2.json"
const ENDED_SAVE="user://paradoxo_ended_journeys.json"
const ROOMS=["Galeria de Arte","História Natural","Salão das Invenções"]
const NAMES=["A paisagem despedaçada","A guardiã de mármore","Mosaico dos caminhos","O retrato impossível","O gigante esquecido","Cristais de origem","Espiral do passado","Vitrine das descobertas","Relógio dos padrões","O pequeno universo","Máquina dos ecos","O coração do museu"]
const TOPICS=[1,2,3,0,3,4,5,1,2,6,4,6]
const FACTS=["Paisagens podem contar histórias usando apenas cor, luz e composição.","Uma escultura muda de aparência conforme a luz e o ponto de vista.","Mosaicos são imagens formadas por pequenas peças de materiais diferentes.","Retratos preservam uma interpretação de alguém, não apenas sua aparência.","Esqueletos articulados ajudam a observar a estrutura dos animais.","Minerais podem formar cristais com padrões geométricos.","Um fóssil é um registro de vida preservado em materiais do passado.","Vitrines protegem peças e permitem examiná-las de vários ângulos.","Relógios transformam movimentos regulares em medidas de tempo.","Este modelo mecânico mostra os movimentos relativos dos planetas.","Engrenagens transmitem movimento entre partes de uma máquina.","Preservar o passado também permite construir histórias novas."]
var art: Control
var audio: Node
var db: Array=[]
var legacy_db: Array=[]
var question_by_id: Dictionary={}
var profiles: Array=[]
var current: Dictionary={}
var question: Dictionary={}
var screen: String="menu"
var gender: String="female"
var mode_choice: String="normal"
var room: int=0
var mission: int=0
var selected_item: int=-1
var time_left: float=0
var answered: bool=false
var bad_answers: Array=[]
var hints: int=0
var selected_answer: String=""
var sequence_slots: Array=[]
var slot_index: int=0
var lives_label: LivesDisplay
var timer_label: Label
var status: Label
var objective: Label
var answer_box: LineEdit
var restore_button: Button
var exhibit_view: Control
var selected_label: Label
var slot_buttons: Array=[]
var step_buttons: Array=[]
var touch_movement:=Vector2.ZERO
var checkpoint: float=0
var phase: String=""
var restore_remaining: float=0
var tutorial_step: int=0
var tutorial_answer: int=0
var tutorial_seen: Array=[]
var startup_warning: String=""
var testing: bool=false
var resources_ready: bool=false
var native_loading_label: Label
var native_loading_progress: ProgressBar
var native_entry_scene: Control
var native_entry_effects: Control
var native_entry_button: Button
var native_entry_time: float=0
var native_entry_hover: int=-1
var returning_to_pause: bool=false
var ending_elapsed: float=0
var credit_roll: Label
var credit_scenes: Array[Control]=[]
var credit_elapsed: float=0
var credits_paused: bool=false
var credit_button: Button
var credit_hint: Label
var credit_viewport: Control
var credit_resume_button: Button
var consulted_book: bool=false
var save_notice: Label
var closing: bool=false
var title_label: Control
var answer_buttons: Array[Button]=[]
var pause_stage: String=""
var banked_pause: bool=false
var overlay_kind: String=""
var pause_layout: Dictionary={}
var rise_elapsed: float=0
var resume_action: Callable
var bench_state: String=""
var bench_button: Button
var menu_character_hovered: int=-1
var character_view: Control
var setup_name: LineEdit
var setup_notice: Label
var setup_hint: Label
var setup_placeholder: Label
var setup_gender: String=""
var setup_mode: String=""
var setup_attempted: bool=false
var setup_character_buttons: Array[Button]=[]
var setup_mode_buttons: Array[Button]=[]
var mobile_orientation_timer: float=0
var ended_journeys: Array=[]
var gameover_elapsed: float=0
var gameover_final: bool=false
var gameover_card: Control
var gameover_shade: ColorRect
var gameover_primary: Button
var gameover_returning: bool=false
var gameover_storage_ok: bool=true
var question_ready: bool=false
var learning_scroll: ScrollContainer
var learning_book: bool=false
var learning_scroll_position: int=0
var gallery_transition: Control
var transition_kind: String=""
var transition_focus_paused: bool=false
var transition_orientation_paused: bool=false

func _ready() -> void:
	DisplayServer.window_set_title("P.A.RADOXO | O Museu Fora do Tempo")
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	mobile_layout="--mobile" in OS.get_cmdline_user_args() or (OS.has_feature("web") and bool(JavaScriptBridge.eval("window.matchMedia('(pointer: coarse)').matches || navigator.maxTouchPoints > 0")))
	if mobile_layout: get_tree().root.content_scale_size=Vector2i(960,540)
	var fallback: Font=ThemeDB.fallback_font.duplicate()
	fallback.fallbacks=[load("res://fonts/Symbols.ttf"),load("res://fonts/Emoji.ttf")]
	var game_theme:=Theme.new()
	game_theme.default_font=fallback
	theme=game_theme
	testing="--smoke" in OS.get_cmdline_user_args()
	randomize()
	audio=Audio.new(); add_child(audio)
	ui_feedback=audio.hover
	init_ui()
	get_tree().auto_accept_quit=false
	# Exported Windows builds enter through the same welcome/load sequence as the Web.
	if not OS.has_feature("web") and not OS.has_feature("editor") and not testing and "--capture" not in OS.get_cmdline_user_args():
		load_entry_preferences(); show_native_entry(); return
	load_question_resources()
	load_save()
	create_museum_scene()
	resources_ready=true
	menu()
	audio.track(0)
	if not testing and not settings.reduced:
		ui.modulate.a=0.0
		create_tween().tween_property(ui,"modulate:a",1.0,1.2)
	if "--audio-test" in OS.get_cmdline_user_args(): call_deferred("audio_test")
	if testing: call_deferred("smoke_test")
	elif "--capture" in OS.get_cmdline_user_args(): call_deferred("capture")
	elif not startup_warning.is_empty(): info("Seu progresso",startup_warning)

func load_question_resources() -> void:
	db=JSON.parse_string(FileAccess.get_file_as_string("res://data/questions.json"))
	legacy_db=JSON.parse_string(FileAccess.get_file_as_string("res://data/questions_legacy_215.json"))
	question_by_id.clear()
	for item in legacy_db+db: question_by_id[item.id]=item

func create_museum_scene() -> void:
	if is_instance_valid(art): remove_child(art); art.queue_free()
	art=Museum.new(); art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(art)
	move_child(art,0)
	art.reached_exhibit.connect(interact); art.footstep.connect(audio.step)

func load_entry_preferences() -> void:
	var saved: Variant=read_json(SAVE)
	if not saved is Dictionary: saved=read_json(SAVE+".bak")
	if not saved is Dictionary or not saved.get("settings") is Dictionary:return
	for key in ["master","music","effects"]:
		if number_in(saved.settings.get(key),0,1,false): settings[key]=float(saved.settings[key])
	for key in ["large","reduced"]:
		if saved.settings.get(key) is bool: settings[key]=saved.settings[key]

func show_native_entry() -> void:
	resources_ready=false;screen="entry";paused=false
	if is_instance_valid(art): art.visible=false
	reset_refs()
	var background:=ColorRect.new();background.color=Color("101d2c");background.mouse_filter=Control.MOUSE_FILTER_IGNORE
	place(background,Rect2(0,0,1280,800))
	native_entry_effects=EntryBackdrop.new();place(native_entry_effects,Rect2(0,0,1280,800));native_entry_effects.reduced=settings.reduced
	native_entry_scene=Museum.new();place(native_entry_scene,Rect2(0,0,1280,800))
	native_entry_scene.background_visible=false;native_entry_scene.presentation_rect=Rect2(565,105,705,600)
	native_entry_scene.menu_mode=true;native_entry_scene.show_pair=true;native_entry_scene.restored=[0,1,2,3]
	native_entry_scene.active=-1;native_entry_scene.reduced=settings.reduced
	native_entry_time=0;native_entry_hover=-1
	var eyebrow:=label_at("UMA AVENTURA DE RESTAURAÇÃO",Rect2(70,145,560,38),16,TEAL)
	title_label=Title.new();place(title_label,Rect2(70,195,585,110));title_label.scale=Vector2.ONE*1.12;title_label.reduced=settings.reduced
	label_at("O MUSEU FORA DO TEMPO",Rect2(70,336,560,48),27)
	var description:=label_at("Restaure 12 obras, descubra padrões e devolva vida às histórias.",Rect2(70,413,520,82),23)
	description.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT
	native_entry_button=button("Entrar no museu",Rect2(70,535,410,66),start_native_loading,true)
	native_entry_button.pivot_offset=native_entry_button.size*.5;native_entry_button.grab_focus()
	var entry_style:=style(GOLD,Color("fff0c5"),16);entry_style.shadow_color=Color(.91,.78,.54,.20);entry_style.shadow_size=12
	native_entry_button.add_theme_stylebox_override("normal",entry_style)
	var hint:=label_at("Explore com as setas ou o mouse. Suas jornadas ficam salvas neste usuário do Windows.",Rect2(70,633,535,75),17,MUTED)
	hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT
	audio.volume=float(settings.music)*float(settings.master);audio.effects_volume=float(settings.effects)*float(settings.master)
	audio.track(0)

func native_loading_step(message: String,value: float) -> void:
	native_loading_label.text=message;native_loading_progress.value=value
	await get_tree().process_frame
	await get_tree().process_frame

func start_native_loading() -> void:
	if screen!="entry":return
	screen="loading";reset_refs()
	var background:=ColorRect.new();background.color=Color("101d2c");background.mouse_filter=Control.MOUSE_FILTER_IGNORE
	place(background,Rect2(0,0,1280,800))
	var title:=label_at("P.A.RADOXO",Rect2(200,250,880,62),40,GOLD)
	title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	native_loading_label=label_at("Preparando o museu…",Rect2(200,335,880,58),24,MUTED)
	native_loading_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	native_loading_progress=ProgressBar.new();place(native_loading_progress,Rect2(240,690,800,12))
	native_loading_progress.show_percentage=false
	native_loading_progress.add_theme_stylebox_override("background",style(Color("1d3849"),Color("1d3849"),6))
	native_loading_progress.add_theme_stylebox_override("fill",style(TEAL,TEAL,6))
	await native_loading_step("Abrindo os desafios…",0)
	load_question_resources()
	await native_loading_step("Recuperando suas jornadas…",40)
	load_save()
	await native_loading_step("Preparando as galerias…",75)
	create_museum_scene();art.visible=false
	await native_loading_step("O museu está pronto.",100)
	resources_ready=true;menu()
	if not startup_warning.is_empty():info("Seu progresso",startup_warning)

func _apply_mobile_layout() -> void:
	mobile_layout_pending=false; mobile_applying=true
	MobileLayout.apply(self)
	mobile_applying=false

func reset_refs() -> void:
	if is_instance_valid(audio): audio.stop_countdown()
	gameover_primary=null; gameover_card=null; gameover_shade=null
	credit_scenes.clear()
	credits_paused=false; credit_button=null; credit_hint=null; credit_viewport=null; credit_resume_button=null
	character_view=null; title_label=null; answer_buttons=[]; bench_button=null
	lives_label=null; timer_label=null; status=null; answer_box=null; selected_label=null; restore_button=null; objective=null; exhibit_view=null
	slot_buttons=[]; step_buttons=[]
	clear_ui()

func menu() -> void:
	cancel_gallery_transition()
	learning_book=false
	art.defeat_amount=0; art.defeat_active=false; art.modulate=Color.WHITE
	cancel_pause_cycle()
	close_overlay()
	# The menu owns its framing; discard the frame left by pause or defeat.
	art.presentation_rect=Rect2(); art.camera=Vector2.ZERO
	art.queue_redraw()
	audio.defeat=false; audio.final_defeat=false
	audio.track(0)
	screen="menu"; art.show_pair=true; art.menu_mode=true; art.preview=false; art.room=0; art.hero=Vector2(4.8,5); art.movement=Vector2.ZERO; art.path=[]
	art.restored=[0,1,2,3]; art.active=-1; art.seated=false; art.bench_pending=false; art.restore_time=0; art.restore_index=-1; art.collapse_time=0
	reset_refs()
	label_at("UMA AVENTURA DE RESTAURAÇÃO",Rect2(65,83,560,35),14,TEAL)
	title_label=Title.new()
	place(title_label,Rect2(65,134,585,110))
	title_label.reduced=settings.reduced
	label_at("O MUSEU FORA DO TEMPO",Rect2(65,247,550,40),23)
	label_at("Cada descoberta devolve uma história.\nEntre no museu, reconstrua suas obras\ne encontre o caminho de volta ao tempo.",Rect2(65,315,530,110),22,MUTED)
	button("Começar uma jornada  ",Rect2(65,469,370,58),new_game,true).grab_focus()
	button("Continuar",Rect2(65,542,370,51),profile_menu).disabled=profiles.is_empty()
	button("Como jogar",Rect2(65,610,178,46),func(): info("Seu guia",help_text()))
	button("Configurações",Rect2(255,610,180,46),open_settings)
	button("A história do museu",Rect2(65,679,370,46),func(): info("O museu fora do tempo","Na véspera de uma nova exposição, quadros perderam suas cores e antigas invenções começaram a se desfazer. Com medo de perder o acervo, o Curador acionou o Relógio Central. O museu ficou preso no mesmo instante. Suas histórias também pararam de avançar.\n\nTico é um pequeno robô em forma de relógio, criado para cuidar dos mecanismos e orientar os visitantes. Ele aparece flutuando ao lado de você durante a exploração. A parada do tempo espalhou suas memórias por três engrenagens, mas uma lembrança resistiu: cada padrão guarda uma pista. Seu caderno reúne essas descobertas.\n\nVocê chega como aprendiz de restauração. Nas três alas, as progressões aritméticas ajudam a reconstruir 12 obras e recuperar as engrenagens. A cada restauração, uma parte do acervo e das lembranças de Tico volta à vida.\n\nSua missão é fazer o Relógio Central funcionar novamente e mostrar ao Curador que preservar o passado também significa deixar espaço para o amanhã."))
	label_at("12 RESTAURAÇÕES     •     DOIS MODOS     •     UMA AVENTURA",Rect2(65,749,700,25),13,MUTED)
	label_at("UM LUGAR PARA REDESCOBRIR",Rect2(800,712,430,30),14,GOLD)

func new_game() -> void:
	screen="setup"; reset_refs()
	setup_gender=""; setup_mode=""; setup_attempted=false
	setup_character_buttons.clear(); setup_mode_buttons.clear()
	art.show_pair=true; art.menu_mode=true
	panel(Rect2(45,45,650,710))
	label_at("O MUSEU ESPERA POR VOCÊ",Rect2(79,70,575,32),14,TEAL)
	label_at("Escolha quem vai explorar",Rect2(79,119,575,90),37,GOLD)
	setup_name=field(Rect2(79,230,575,57),"Seu nome ou apelido ✦")
	setup_name.text_changed.connect(func(_value): validate_setup())
	setup_hint=label_at("Até 20 caracteres visíveis. Acentos, símbolos e emojis são aceitos.",Rect2(79,300,575,48),16,MUTED)
	setup_character_buttons.append(button("Feminino",Rect2(79,380,280,58),func(): select_setup_character("female")))
	setup_character_buttons.append(button("Masculino",Rect2(374,380,280,58),func(): select_setup_character("male")))
	label_at("Mesmas habilidades. Duas aparências originais.",Rect2(79,449,575,30),17,MUTED)
	setup_mode_buttons.append(button("Normal",Rect2(79,515,280,58),func(): select_setup_mode("normal")))
	setup_mode_buttons.append(button("Difícil",Rect2(374,515,280,58),func(): select_setup_mode("hard")))
	label_at("Normal: 3 corações, sem cronômetro.\nDifícil: 2 corações, tempo por questão.\nA tentativa extra é renovada ao acertar.",Rect2(79,582,575,96),16,MUTED)
	button("Voltar",Rect2(191,695,170,40),menu)
	button("Iniciar",Rect2(379,695,170,40),start_new_journey)
	panel(Rect2(760,100,450,610))
	label_at("SEU PERSONAGEM",Rect2(795,135,380,35),15,TEAL)
	character_view=Character.new(); character_view.gender=gender
	place(character_view,Rect2(780,205,410,355))
	character_view.visible=false
	setup_placeholder=label_at("Escolha um personagem\npara ver sua aparência.",Rect2(795,330,380,120),24,MUTED)
	setup_notice=label_at("Informe seu nome e escolha\num personagem e uma dificuldade.",Rect2(795,575,380,115),16,MUTED)
	if mobile_layout and OS.has_feature("web"):
		setup_name.virtual_keyboard_enabled=false
		setup_name.focus_entered.connect(_open_mobile_name)
		setup_name.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed: _open_mobile_name())
	setup_name.grab_focus()

func _open_mobile_name() -> void:
	if OS.has_feature("web") and is_instance_valid(setup_name):
		JavaScriptBridge.eval("window.paradoxo && window.paradoxo.openName("+JSON.stringify(setup_name.text)+")")

func select_setup_character(value: String) -> void:
	setup_gender=value; gender=value; art.gender=value
	character_view.gender=value; character_view.visible=true; setup_placeholder.visible=false
	setup_character_buttons[0].text="✓ Feminino" if value=="female" else "Feminino"
	setup_character_buttons[1].text="✓ Masculino" if value=="male" else "Masculino"
	validate_setup()

func select_setup_mode(value: String) -> void:
	setup_mode=value; mode_choice=value
	setup_mode_buttons[0].text="✓ Normal" if value=="normal" else "Normal"
	setup_mode_buttons[1].text="✓ Difícil" if value=="hard" else "Difícil"
	validate_setup()

func validate_setup() -> bool:
	if screen!="setup" or not is_instance_valid(setup_notice): return false
	var missing: Array[String]=[]
	if clean_name(setup_name.text,false).is_empty(): missing.append("nome")
	if setup_gender not in ["female","male"]: missing.append("personagem")
	if setup_mode not in ["normal","hard"]: missing.append("dificuldade")
	var error:=Color("efb3a4")
	var name_missing: bool=setup_attempted and "nome" in missing
	setup_name.add_theme_stylebox_override("normal",style(Color("1d3849"),error if name_missing else Color("355264")))
	setup_name.add_theme_stylebox_override("focus",style(Color("1d3849"),error if name_missing else Color("78909c")))
	setup_hint.text="Informe um nome ou apelido válido. Apenas espaços não são aceitos." if name_missing else "Até 20 caracteres visíveis. Acentos, símbolos e emojis são aceitos."
	if mobile_layout: setup_hint.text="Digite um nome. Apenas espaços não valem." if name_missing else "Até 20 caracteres. Acentos e emojis são aceitos."
	setup_hint.add_theme_color_override("font_color",error if name_missing else MUTED)
	for group in [setup_character_buttons,setup_mode_buttons]:
		var pending: bool=setup_attempted and ((group==setup_character_buttons and "personagem" in missing) or (group==setup_mode_buttons and "dificuldade" in missing))
		for b in group: b.add_theme_stylebox_override("normal",style(Color("1d3849"),error if pending else Color("426071")))
	if missing.is_empty(): setup_notice.text="Tudo pronto!\nClique em Iniciar para explorar."; setup_notice.add_theme_color_override("font_color",TEAL)
	elif setup_attempted:
		setup_notice.text="Para iniciar, falta escolher ou preencher: %s." % ", ".join(missing)
		setup_notice.add_theme_color_override("font_color",error)
	else:
		setup_notice.text="Informe seu nome e escolha\num personagem e uma dificuldade."
		setup_notice.add_theme_color_override("font_color",MUTED)
	return missing.is_empty()

func start_new_journey() -> void:
	setup_attempted=true
	if not validate_setup():
		if clean_name(setup_name.text,false).is_empty(): setup_name.grab_focus()
		elif setup_gender.is_empty(): setup_character_buttons[0].grab_focus()
		else: setup_mode_buttons[0].grab_focus()
		audio.cue("wrong")
		return
	create_profile(setup_name.text,setup_mode,true)

func clean_name(value: String,fallback: bool=true) -> String:
	var out: String=""
	for i in range(value.length()):
		var cp: int=value.unicode_at(i)
		if cp in [0x00a0,0x1680,0x2028,0x2029,0x202f,0x205f,0x3000] or (cp>=0x2000 and cp<=0x200a):
			out+=" "; continue
		if cp>=32 and cp!=127 and cp not in [0x200b,0x200e,0x200f,0x202a,0x202b,0x202c,0x202d,0x202e,0x2066,0x2067,0x2068,0x2069,0xfeff]: out+=value[i]
	out=out.strip_edges()
	if out.replace(String.chr(0x200d),"").replace(String.chr(0xfe0f),"").is_empty(): out=""
	var ends:=TextServerManager.get_primary_interface().string_get_character_breaks(out)
	if ends.size()>20: out=out.substr(0,ends[19])
	return "Explorador" if out.is_empty() and fallback else out

func create_profile(player_name: String,mode: String,present: bool=false) -> void:
	learning_scroll_position=0
	current={"id":str(Time.get_unix_time_from_system())+str(randi()%1000),"name":clean_name(player_name),"gender":gender,"mode":mode,"done":[],"seen":[],"active":{},"lives":max_lives(mode),"rules_version":5,"room":0,"hero":[4.5,5.8],"tutorial":true,"phase":"world","balance":[0,0,0,0],"attempts":0,"correct":0,"hints_used":0,"learning":{},"defeats":0,"last_defeat_timeout":false,"draw_state":{},"last_answer_position":-1,"introduced_galleries":[]}
	profiles.append(current)
	art.gender=gender
	mission=0; room=0
	question={}; phase="world"
	audio.track(0)
	save_game()
	if present: begin_gallery_transition(0,"opening")
	else:
		current.introduced_galleries=[0]
		world()

func intro() -> void:
	screen="intro"; reset_refs()
	panel(Rect2(70,65,700,665))
	label_at("PRÓLOGO / O DIA SEM AMANHÃ",Rect2(105,132,630,33),15,TEAL)
	label_at("O Curador parou o tempo.",Rect2(105,187,620,100),38,GOLD)
	prose("%s, as obras deste museu começaram a desaparecer. Para protegê-las, o Curador congelou todas as horas.\n\nEu sou Tico. Esqueci quase tudo… menos que cada padrão guarda uma pista. Precisamos restaurar as exposições e recuperar três engrenagens.\n\nTalvez preservar uma história também signifique deixá-la continuar." % current.name,Rect2(105,300,620,320),22)
	button("Entrar no museu",Rect2(105,650,380,52),func(): begin_gallery_transition(0,"opening"),true)

func tutorial() -> void:
	screen="tutorial"; tutorial_step=0
	var a: int=randi_range(1,7)
	var r: int=randi_range(1,3)
	tutorial_answer=a+3*r
	reset_refs(); panel(Rect2(110,80,1060,640))
	label_at("OFICINA DE TICO / SEM PERDER VIDAS",Rect2(150,108,950,35),15,TEAL)
	label_at("Os números deixam pistas.",Rect2(150,164,950,65),38,GOLD)
	label_at("Uma P.A. tem a mesma diferença entre termos consecutivos.\nAqui a razão é %d. Escolha a próxima peça:" % r,Rect2(150,250,940,90),23)
	panel(Rect2(150,355,960,65))
	label_at("%d, %d, %d, ?" % [a,a+r,a+2*r],Rect2(180,365,890,45),30,GOLD)
	var next_button:=button("Próximo  ",Rect2(810,635,300,49),tutorial_controls,true)
	next_button.disabled=true
	var choices: Array=[tutorial_answer,tutorial_answer+1,tutorial_answer+r+1]
	choices.shuffle()
	for i in range(3):
		var value: int=choices[i]
		button(str(value),Rect2(230+i*280,435,230,65),func():
			if value==tutorial_answer:
				audio.cue("correct"); status.text="Isso! Somamos a razão ao último termo. Vamos aprender os controles."
				next_button.disabled=false
			else: status.text="Observe a diferença entre os termos. Tente somar %d ao último." % r; audio.cue("wrong"),true)
	status=label_at("Selecione uma peça. Neste tutorial você pode experimentar livremente.",Rect2(150,536,950,65),21,MUTED)

func tutorial_controls() -> void:
	reset_refs(); panel(Rect2(150,85,980,630))
	label_at("UM PEQUENO GUIA DE EXPLORAÇÃO",Rect2(190,120,900,40),16,TEAL)
	label_at("Caminhe. Observe. Restaure.",Rect2(190,180,890,70),37,GOLD)
	prose("CAMINHAR · Setas ou clique no chão.\nEXAMINAR · Clique numa obra ou pressione E perto dela.\nO marcador ! mostra a próxima missão. O símbolo ✓ marca uma obra restaurada.\n\nCada coração é uma vida. Normal: três corações. Difícil: dois. Ao esgotá-los, você tem uma tentativa extra. Acertar recupera os corações e renova essa chance. Uma segunda derrota antes de acertar apaga a jornada.\nDicas e trocas não gastam vidas. Trocar não recupera corações nem renova a tentativa extra. No Difícil, mantém o tempo restante.\n\nEsc ou Enter leva ao banco e pausa depois de sentar. Ao retomar, o personagem se levanta antes de liberar os controles. Os botões do menu continuam com som. No Difícil, abrir o caderno mantém o tempo ativo.\n\nSiga o marcador dourado para começar.",Rect2(190,270,880,335),21)
	button("Explorar a galeria",Rect2(190,631,350,52),func(): current.tutorial=true; current.phase="world"; phase="world"; save_game(); begin_gallery_transition(0,"opening"),true)

func profile_menu() -> void:
	screen="profiles"; reset_refs()
	panel(Rect2(140,70,1000,660))
	label_at("Suas jornadas",Rect2(180,105,900,65),38,GOLD)
	if profiles.is_empty(): label_at("Nenhuma jornada salva. Comece uma nova aventura pelo menu.",Rect2(180,215,860,90),24,MUTED)
	var scroll:=ScrollContainer.new(); scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED; place(scroll,Rect2(180,200,915,410))
	var list:=VBoxContainer.new(); list.add_theme_constant_override("separation",14); padded_scroll_content(scroll,list)
	var first_journey: Button=null
	for profile in profiles:
		var p: Dictionary=profile
		var row:=HBoxContainer.new(); row.add_theme_constant_override("separation",16); list.add_child(row)
		var b:=button("%s · %s · %d/12 obras" % [p.name,"Normal" if p.mode=="normal" else "Difícil",p.done.size()],Rect2(0,0,680,58),func(): current=p; resume_profile(),false,row)
		b.custom_minimum_size=Vector2(0,58)
		b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		b.clip_text=true; b.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
		b.set_meta("journey_name",str(p.name))
		b.set_meta("journey_details"," · %s · %d/12 obras" % ["Normal" if p.mode=="normal" else "Difícil",p.done.size()])
		b.tooltip_text=str(p.name)+str(b.get_meta("journey_details"))
		b.resized.connect(func(): fit_profile_caption(b))
		b.theme_changed.connect(func(): fit_profile_caption.call_deferred(b))
		fit_profile_caption(b)
		if first_journey==null: first_journey=b
		var remove_button:=button("Excluir",Rect2(0,0,170,58),func(): confirm_delete(str(p.id)),false,row)
		remove_button.custom_minimum_size=Vector2(170,58)
	var back:=button("Voltar",Rect2(180,650,180,48),menu)
	if first_journey: first_journey.grab_focus()
	else: back.grab_focus()

func fit_profile_caption(b: Button) -> void:
	if not is_instance_valid(b) or not b.has_meta("journey_name"): return
	var font: Font=b.get_theme_font("font")
	var n: int=b.get_theme_font_size("font_size")
	var skin: StyleBox=b.get_theme_stylebox("normal")
	var available: float=maxf(0,b.size.x-skin.get_content_margin(SIDE_LEFT)-skin.get_content_margin(SIDE_RIGHT)-8)
	var full_name: String=str(b.get_meta("journey_name"))
	var details: String=str(b.get_meta("journey_details"))
	var prefix: String=full_name
	if font.get_string_size(prefix+details,HORIZONTAL_ALIGNMENT_LEFT,-1,n).x>available:
		var ends: PackedInt32Array=TextServerManager.get_primary_interface().string_get_character_breaks(full_name)
		var count: int=ends.size()
		while count>0:
			count-=1
			prefix=(full_name.substr(0,ends[count-1]) if count>0 else "")+"…"
			if font.get_string_size(prefix+details,HORIZONTAL_ALIGNMENT_LEFT,-1,n).x<=available: break
	b.text=prefix+details

func next_mission() -> int:
	for i in range(12):
		if i not in current.done: return i
	return 12

func resume_profile() -> void:
	if str(current.get("id","")) in ended_journeys:
		current={}; profile_menu(); return
	if int(current.get("defeats",0))>=2:
		collapse(); return
	gender=current.gender; art.gender=gender; room=int(current.room)
	art.hero=Vector2(float(current.hero[0]),float(current.hero[1]))
	mission=next_mission()
	phase=str(current.get("phase","world"))
	if not current.tutorial: current.tutorial=true; current.phase="world"; phase="world"
	if phase=="success":
		mission=int(current.get("restoring_id",maxi(0,mission-1)))
		finish_restore(true); return
	if phase=="restoring":
		var restored_id: int=int(current.get("restoring_id",mission))
		if restored_id not in current.done: current.done.append(restored_id)
		current.active={}; current.phase="world"; phase="world"; mission=next_mission()
		if mission<12:
			room=int(mission/4); current.room=room; art.hero=art.BENCH_EXIT; current.hero=[art.hero.x,art.hero.y]; current.seated=true
		save_game()
	if not current.active.is_empty() and int(current.active.question.topic)==7:
		current.active={}; current.phase="world"; phase="world"; save_game()
	if not current.active.is_empty():
		question=current.active.question.duplicate(true)
		mission=int(current.active.mission)
		time_left=float(current.active.remaining)
		bad_answers=current.active.bad.duplicate()
		hints=int(current.active.hints)
		consulted_book=bool(current.active.get("consulted_book",false))
		sequence_slots=current.active.get("slots",[]).duplicate()
		selected_answer=str(current.active.get("selected",""))
		if int(question.topic)==1 and selected_answer.is_empty() and not sequence_slots.is_empty(): selected_answer=str(sequence_slots[0])
		slot_index=int(current.active.get("slot_index",0))
		answered=false
		if int(current.lives)<=0: collapse()
		elif phase=="timeout": timeout_screen()
		else: challenge()
		return
	if mission==12 and not current.get("tour",false): ending()
	else:
		world(true)
		if room not in current.get("introduced_galleries",[0,1,2]): begin_gallery_transition(room,"opening" if room==0 else "advance")

func world(keep_position: bool=false) -> void:
	art.defeat_amount=0; art.defeat_active=false; art.modulate=Color.WHITE
	cancel_pause_cycle()
	close_overlay(); screen="world"; phase="world"; answered=false; question={}
	mission=next_mission()
	if mission>=12 and current.get("tour",false)==false: ending(); return
	current.phase="world"; current.active={}
	if not keep_position and mission<12: room=int(mission/4)
	current.room=room
	art.show_pair=false; art.menu_mode=false; art.preview=false; art.room=room; art.restored=current.done.duplicate(); art.active=mission%4 if mission<12 and int(mission/4)==room else -1; art.gender=current.gender
	art.movement=Vector2.ZERO; art.path=[]; art.pending=-1; art.collapse_time=0; art.bench_pending=false
	art.seated=bool(current.get("seated",false)) if keep_position else true
	if not keep_position: art.hero=art.BENCH_EXIT
	if art.blocked(art.hero): art.navigation_start()
	current.seated=art.seated
	current.hero=[art.hero.x,art.hero.y]
	reset_refs(); header()
	panel(Rect2(28,108,455,75))
	label_at("ALA %02d" % (room+1),Rect2(47,116,400,24),13,TEAL)
	label_at(ROOMS[room],Rect2(47,143,400,35),25,GOLD)
	panel(Rect2(780,110,470,74))
	objective=label_at("",Rect2(800,120,430,54),17)
	objective.text="Restaure: "+NAMES[mission] if mission<12 else "Museu restaurado. Explore as exposições!"
	if mission<12 and int(mission/4)!=room: objective.text="Ala restaurada! Abra o mapa para continuar."
	button("Mapa",Rect2(1120,196,128,52),map_menu)
	button("Caderno",Rect2(1120,266,128,52),notebook)
	bench_button=button("Levantar" if art.seated else "Sentar",Rect2(1120,336,128,52),use_bench)
	bench_button.tooltip_text=""
	panel(Rect2(28,713,1220,65))
	status=label_at("Clique numa obra para caminhar até ela. Setas: mover. Clique em Examinar.",Rect2(48,727,840,36),18,MUTED)
	restore_button=button("Examinar",Rect2(960,724,265,43),interact_nearest,true)
	for i in range(4):
		var dirs: Array=[Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]
		var r: Rect2=[Rect2(30,641,52,52),Rect2(140,641,52,52),Rect2(85,585,52,52),Rect2(85,641,52,52)][i]
		var direction: Vector2=dirs[i]
		var b:=button(["<",">","^","v"][i],r,func(): pass)
		b.button_down.connect(func(): touch_movement=direction)
		b.button_up.connect(func(): touch_movement=Vector2.ZERO)
	sync_bench_status(true)
	audio.track(room+1)
	save_game()

func header() -> void:
	panel(Rect2(28,22,1220,68))
	label_at("P.A.RADOXO",Rect2(48,39,215,36),24,GOLD)
	var name_label:=label_at(str(current.name),Rect2(275,41,265,32),20)
	name_label.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	lives_label=LivesDisplay.new(); place(lives_label,Rect2(550,42,300,32)); update_lives()
	label_at("%02d/12" % current.done.size(),Rect2(910,43,90,30),18,MUTED)
	button("II  Pausar",Rect2(1060,33,168,45),pause_game)

func update_lives() -> void:
	if is_instance_valid(lives_label): lives_label.configure(int(current.lives),max_lives(),"NORMAL" if current.mode=="normal" else "DIFÍCIL",settings.large)

func interact_nearest() -> void:
	if screen!="world" or paused or not pause_stage.is_empty(): return
	var closest: int=-1
	var distance: float=1.65
	for i in range(4):
		var d: float=art.hero.distance_to(art.POS[i])
		if d<distance: closest=i; distance=d
	if closest>=0: interact(closest)
	elif mission<12 and int(mission/4)==room:
		art.approach(mission%4)
		if is_instance_valid(status): status.text="Caminhando até a exposição…"

func interact(index: int) -> void:
	if screen!="world" or paused or not pause_stage.is_empty(): return
	var id: int=room*4+index
	if not art.near(index): art.approach(index); return
	art.movement=Vector2.ZERO
	if id in current.done:
		view_restored(id)
	elif id!=next_mission():
		info(NAMES[id],"Tico: este mecanismo depende da restauração anterior. Siga o marcador dourado ! para recuperar o fluxo do tempo.\n\n"+FACTS[id])
	else:
		mission=id; selected_item=index; start_question()

func map_menu() -> void:
	make_overlay()
	panel(Rect2(220,100,840,600),overlay)
	label_at("As alas do museu",Rect2(260,133,760,60),34,GOLD,overlay)
	for i in range(3):
		var index: int=i
		var unlocked: bool=i==0 or (i*4-1 in current.done)
		var count: int=0
		for id in current.done:
			if int(int(id)/4)==i: count+=1
		button(("" if unlocked else "🔒 ")+ROOMS[i]+"   %d/4"%count,Rect2(260,240+i*100,760,70),func(): enter_gallery(index),unlocked,overlay).disabled=not unlocked
	button("Voltar",Rect2(260,620,190,46),close_overlay,false,overlay)

func enter_gallery(index: int) -> void:
	if index<0 or index>2 or current.is_empty():return
	if index>0 and index*4-1 not in current.done:return
	var kind: String="travel" if index in current.get("introduced_galleries",[0,1,2]) else "opening" if index==0 else "advance"
	begin_gallery_transition(index,kind)

func begin_gallery_transition(destination: int,kind: String) -> void:
	if is_instance_valid(gallery_transition) or current.is_empty():return
	if destination<0 or destination>3:return
	if destination==3 and next_mission()!=12:return
	if destination in [1,2] and destination*4-1 not in current.done:return
	cancel_pause_cycle();super.close_overlay()
	transition_kind=kind;transition_focus_paused=false;transition_orientation_paused=false
	audio.transitioning=true
	if destination<3:
		room=destination;current.room=room;current.seated=true
		art.hero=art.BENCH_EXIT;current.hero=[art.hero.x,art.hero.y]
		world(true)
	else:
		current.phase="world";current.active={};save_game()
	gallery_transition=GalleryTransition.new()
	gallery_transition.destination=destination;gallery_transition.kind=kind
	gallery_transition.reduced=settings.reduced;gallery_transition.large_text=settings.large
	gallery_transition.mobile=mobile_layout;gallery_transition.character_gender=current.gender
	gallery_transition.restored=current.done.duplicate()
	gallery_transition.finished.connect(finish_gallery_transition)
	ui.visible=false;art.visible=false;art.frozen=true;art.movement=Vector2.ZERO;art.path=[];touch_movement=Vector2.ZERO
	screen="transition";paused=false;question_ready=false
	add_child(gallery_transition)
	audio.paused=false;audio.defeat=false;audio.final_defeat=false;audio.subdued=false
	audio.volume=float(settings.music)*float(settings.master);audio.effects_volume=float(settings.effects)*float(settings.master)
	audio.begin_arrival(destination,kind);audio.track(4 if destination==3 else destination+1)

func finish_gallery_transition() -> void:
	if not is_instance_valid(gallery_transition):return
	var destination: int=gallery_transition.destination
	if destination<3:
		var visited: Array=current.get("introduced_galleries",[0,1,2]).duplicate()
		if destination not in visited:visited.append(destination)
		current.introduced_galleries=visited
	cancel_gallery_transition()
	if destination==3:ending()
	else:world(true)

func cancel_gallery_transition() -> void:
	if is_instance_valid(gallery_transition):
		gallery_transition.set_process(false);remove_child(gallery_transition);gallery_transition.queue_free();gallery_transition=null
	if is_instance_valid(art):art.visible=true;art.frozen=false
	if is_instance_valid(ui):ui.visible=true
	if is_instance_valid(audio):audio.end_arrival();audio.paused=false
	transition_kind="";transition_focus_paused=false;transition_orientation_paused=false

func continue_after_restore() -> void:
	var next: int=next_mission()
	if next==12:begin_gallery_transition(3,"finale")
	elif int(next/4)!=room:
		var target: int=int(next/4)
		begin_gallery_transition(target,"travel" if target in current.get("introduced_galleries",[0,1,2]) else "advance")
	else:world(true)

func question_math_key(q: Dictionary) -> String:
	var t: int=int(q.topic)
	var n: int=0 if t in [0,2] else 5 if t==1 and not q.has("revision") else int(q.n)
	return "%s:%d:%d:%d:%d" % [q.mode,t,int(q.a),int(q.r),n]

func question_time_limit(item: Dictionary) -> float:
	# Keep the saved question intact while applying the current clock policy.
	if item.mode=="hard": return [60.0,60.0,60.0,75.0,75.0,90.0,90.0][clampi(int(item.topic),0,6)]
	return float(item.time)

func start_question() -> void:
	if mission>=12: return
	var seen_math: Dictionary={}
	for id in current.seen:
		if question_by_id.has(id): seen_math[question_math_key(question_by_id[id])]=true
	var pool: Array=[]
	for q in db:
		if q.mode==current.mode and int(q.topic)==TOPICS[mission] and q.id not in current.seen and not seen_math.has(question_math_key(q)): pool.append(q)
	var draw_key: String=str(current.mode)+":"+str(TOPICS[mission])
	if pool.is_empty():
		var retained_time: float=time_left if screen=="challenge" and not answered and current.mode=="hard" else -1.0
		info("Este conteúdo foi todo explorado","Você já viu as questões deste conteúdo. Quer revisar? O histórico dos outros assuntos será preservado.",func():
			var ids: Array=[]
			for q in question_by_id.values():
				if q.mode==current.mode and int(q.topic)==TOPICS[mission]: ids.append(q.id)
			current.seen=current.seen.filter(func(id): return id not in ids)
			var state: Dictionary=current.get("draw_state",{}); state.erase(draw_key); current.draw_state=state
			close_overlay(); start_question()
			if retained_time>=0 and screen=="challenge":
				time_left=minf(time_left,retained_time); update_timer(); update_snapshot(); save_game(),"Revisar este conteúdo")
		return
	var draw_state: Dictionary=current.get("draw_state",{})
	var state: Dictionary=draw_state.get(draw_key,{})
	question=QuestionDraw.choose(pool,state).duplicate(true)
	draw_state[draw_key]=QuestionDraw.record(state,question); current.draw_state=draw_state
	# Soft balance avoids a predictable four-question rotation.
	var balance: Array=current.get("balance",[0,0,0,0])
	var target: int=QuestionDraw.answer_position(balance,int(current.get("last_answer_position",-1)))
	current.last_answer_position=target
	var options: Array=question.options.filter(func(v): return v!=question.answer)
	options.shuffle(); options.insert(target,question.answer); question.options=options
	balance[target]=int(balance[target])+1; current.balance=balance
	current.seen.append(question.id)
	bad_answers=[]; hints=0; consulted_book=false; selected_answer=""; sequence_slots=["",""]; slot_index=0
	time_left=question_time_limit(question)
	answered=false; phase="question"
	current.phase=phase
	current.active={"question":question.duplicate(true),"mission":mission,"remaining":time_left,"bad":[],"hints":0,"slots":sequence_slots.duplicate(),"selected":"","slot_index":0}
	save_game(); challenge()

func challenge() -> void:
	question_ready=false
	art.defeat_active=false; art.defeat_amount=0
	screen="challenge"; phase="question"; room=int(mission/4)
	audio.track(room+1)
	art.show_pair=false; art.menu_mode=false; art.preview=false; art.room=room; art.movement=Vector2.ZERO; art.path=[]
	reset_refs(); header()
	panel(Rect2(28,108,1220,670))
	label_at("RESTAURAÇÃO %02d / %s" % [mission+1,NAMES[mission].to_upper()],Rect2(55,128,1005,42),15,TEAL)
	timer_label=label_at("",Rect2(1080,130,140,38),23,GOLD)
	var bench:=Bench.new(); place(bench,Rect2(52,195,385,375))
	exhibit_view=Exhibit.new(); exhibit_view.kind=art.TYPES[room][mission%4]; exhibit_view.display_scale=2.6; exhibit_view.reduced=settings.reduced
	place(exhibit_view,Rect2(52,195,385,375))
	var caption:=label_at(FACTS[mission],Rect2(64,578,360,106),16,MUTED)
	caption.set_meta("art_caption",true)
	prose(str(question.prompt),Rect2(470,199,715,145),25)
	label_at("Escolha uma resposta e confirme.",Rect2(470,355,710,35),18,MUTED)
	for i in range(4):
		var value: String=question.options[i]
		var choice:=button(value,Rect2(470+(i%2)*360,410+int(i/2)*76,345,62),func(): select_answer(value))
		choice.set_meta("answer",value); answer_buttons.append(choice)
	refresh_answer_selection()
	status=label_at("",Rect2(470,573,710,87),18,MUTED)
	button("Dica",Rect2(52,695,160,56),show_hint)
	button("Caderno",Rect2(230,695,183,56),notebook)
	button("Confirmar restauração",Rect2(790,695,390,56),submit,true)
	button("Próxima pergunta",Rect2(470,695,295,56),skip_question).tooltip_text="Troca sem gastar vidas. Não recupera corações nem renova a tentativa extra. No Difícil, mantém o tempo restante."
	update_timer(); save_game()
	call_deferred("mark_question_ready")

func mark_question_ready() -> void:
	if screen=="challenge" and not answered: question_ready=true

func skip_question() -> void:
	if screen!="challenge" or paused or answered: return
	var remaining: float=time_left
	current["skipped"]=int(current.get("skipped",0))+1
	record_learning("puladas")
	start_question()
	if current.mode=="hard":
		time_left=minf(remaining,time_left)
		update_timer(); update_snapshot(); save_game()

func choices(rect: Rect2) -> void:
	for i in range(4):
		var value: String=question.options[i]
		button(value,Rect2(rect.position+Vector2(i*177,0),Vector2(162,rect.size.y)),func(): selected_answer=value; answer_box.text=value; update_snapshot())

func refresh_slots() -> void:
	for i in range(slot_buttons.size()):
		slot_buttons[i].text=("› " if i==slot_index else "")+("?" if str(sequence_slots[i]).is_empty() else str(sequence_slots[i]))
	if is_instance_valid(exhibit_view):
		exhibit_view.progress=.15 if sequence_slots[0]!="" or sequence_slots[1]!="" else 0

func adjust_dial(delta: int) -> void:
	var value: int=int(selected_answer) if selected_answer.is_valid_int() else 0
	selected_answer=str(value+delta)
	if is_instance_valid(answer_box): answer_box.text=selected_answer
	update_snapshot()

func normalized(value: String) -> String:
	var s: String=value.strip_edges().replace(",",".")
	if s.is_valid_float():
		var f: float=float(s)
		if is_finite(f): return str(f)
	return s.to_lower()

func submit() -> void:
	if screen!="challenge" or answered or paused: return
	var response: String=""
	var correct: bool=false
	var value: String=selected_answer.strip_edges()
	if value.is_empty(): status.text="Selecione uma resposta. Nenhuma vida foi perdida."; return
	response=normalized(value)
	correct=response==normalized(question.answer)
	if response in bad_answers:
		status.text="Você já testou essa resposta. Altere a resposta. Nenhuma outra vida foi perdida."; return
	current.attempts=int(current.attempts)+1
	if correct:
		answered=true; current.correct=int(current.correct)+1
		record_learning("com_ajuda" if hints>0 or consulted_book else "sem_ajuda")
		start_restore()
	else:
		record_learning("erros")
		bad_answers.append(response); lose_charge(false)

func lose_charge(timeout: bool) -> void:
	if answered: return
	current.lives=maxi(0,int(current.lives)-1)
	audio.cue("wrong"); update_lives()
	if timeout: answered=true; phase="timeout"; record_learning("tempo_esgotado")
	if int(current.lives)<=0:
		answered=true; phase="collapse"
		current.defeats=mini(2,int(current.get("defeats",0))+1)
		current.last_defeat_timeout=timeout
		update_snapshot(); save_game(); collapse()
	elif timeout:
		update_snapshot(); save_game(); timeout_screen()
	else:
		if is_instance_valid(status): status.text="−1 vida. "+(str(question.hint) if current.mode=="normal" else "Revise o mecanismo. O tempo continua.")
		update_snapshot(); save_game()

func timeout_screen() -> void:
	screen="timeout"; phase="timeout"; answered=true
	reset_refs(); panel(Rect2(130,100,1020,600))
	label_at("A janela de tempo se fechou.",Rect2(170,145,930,85),36,GOLD)
	label_at("Uma vida foi perdida. Você ainda tem %d.\n\n%s" % [int(current.lives),solution_text()],Rect2(170,273,900,230),25)
	button("Outra questão",Rect2(170,600,340,55),func(): current.active={}; answered=false; start_question(),true)
	button("Menu",Rect2(540,600,190,55),func(): save_game(); menu())

func collapse() -> void:
	if current.is_empty(): return
	cancel_pause_cycle(); super.close_overlay()
	gameover_final=int(current.get("defeats",0))>=2
	if not gameover_final: current.defeats=1
	var player_name: String=str(current.name)
	var reason: String="O tempo acabou e o último coração se apagou." if current.get("last_defeat_timeout",false) else "Seus corações se apagaram."
	room=int(mission/4)
	art.room=room; art.gender=current.gender; art.restored=current.done.duplicate()
	art.show_pair=false; art.menu_mode=false; art.preview=false; art.active=-1
	art.path=[]; art.pending=-1; art.bench_pending=false; art.movement=Vector2.ZERO; art.moving=false
	art.restore_time=0; art.collapse_time=0; art.defeat_active=true; art.defeat_amount=0
	art.presentation_rect=Rect2(15,70,735,650)
	screen="gameover_final" if gameover_final else "collapse"
	phase="collapse"; answered=true; question_ready=false; touch_movement=Vector2.ZERO
	gameover_elapsed=0; gameover_returning=false; gameover_storage_ok=true
	audio.paused=false; audio.subdued=true; audio.defeat=true; audio.final_defeat=gameover_final
	audio.cue("gameover_final" if gameover_final else "gameover_first")
	if gameover_final: gameover_storage_ok=retire_current_journey()
	else: update_snapshot(); save_game()
	reset_refs()
	gameover_shade=ColorRect.new(); gameover_shade.color=Color(.035,.045,.075,.25)
	place(gameover_shade,Rect2(0,0,1280,800))
	label_at("ALA %02d  /  %s" % [room+1,ROOMS[room]],Rect2(42,38,680,40),18,GOLD)
	gameover_card=Control.new(); place(gameover_card,Rect2(735,80,510,650))
	panel(Rect2(0,0,510,650),gameover_card)
	var eyebrow:=label_at("FIM DA JORNADA" if gameover_final else "UMA NOVA CHANCE",Rect2(32,26,446,30),15,TEAL,gameover_card)
	eyebrow.set_meta("gameover_role","eyebrow")
	var heading:=label_at("GAME OVER",Rect2(32,74,446,70),48,Color("edb8ad"),gameover_card)
	heading.set_meta("gameover_role","heading")
	var detail:=label_at(reason,Rect2(32,153,446,65),22,GOLD,gameover_card)
	detail.set_meta("gameover_role","reason")
	var message: String="Tico: até a próxima jornada, %s." % player_name if gameover_final else "Tico: estou com você, %s. Vamos tentar?" % player_name
	var body:=label_at(message,Rect2(32,233,446,110),21,WHITE,gameover_card)
	body.horizontal_alignment=HORIZONTAL_ALIGNMENT_FILL
	body.justification_flags=TextServer.JUSTIFICATION_WORD_BOUND | TextServer.JUSTIFICATION_SKIP_LAST_LINE
	body.set_meta("gameover_role","body")
	var body_scroll:=ScrollContainer.new(); body_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	place(body_scroll,Rect2(32,233,446,110),gameover_card); body_scroll.set_meta("gameover_role","body")
	padded_scroll_content(body_scroll,body)
	var warning: String="Todo o progresso desta jornada foi apagado." if gameover_final else "Última chance neste desafio. Uma nova derrota antes de acertar apaga esta jornada."
	if gameover_final and not gameover_storage_ok: warning="Não conseguimos concluir o salvamento. Tente voltar ao início pelo botão abaixo."
	var note:=label_at(warning,Rect2(32,354,446,94),18,Color("e8b5a8"),gameover_card)
	note.horizontal_alignment=HORIZONTAL_ALIGNMENT_FILL
	note.justification_flags=TextServer.JUSTIFICATION_WORD_BOUND | TextServer.JUSTIFICATION_SKIP_LAST_LINE
	note.set_meta("gameover_role","warning")
	var note_scroll:=ScrollContainer.new(); note_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	place(note_scroll,Rect2(32,354,446,94),gameover_card); note_scroll.set_meta("gameover_role","warning")
	padded_scroll_content(note_scroll,note)
	if gameover_final:
		var returning:=label_at("Voltando à tela inicial…" if gameover_storage_ok else "Seu jogo continua aberto para tentar salvar.",Rect2(32,510,446,65),20,MUTED,gameover_card)
		returning.set_meta("gameover_role","returning")
		if not gameover_storage_ok: gameover_primary=button("Tentar voltar ao início",Rect2(32,574,446,52),retry_final_save,true,gameover_card)
	else:
		gameover_primary=button("Tentar novamente",Rect2(32,458,446,52),retry_gameover,true,gameover_card)
		button("Consultar o Caderno de Tico",Rect2(32,520,446,52),notebook,false,gameover_card)
		button("Voltar ao menu",Rect2(32,582,446,44),leave_gameover,false,gameover_card)
	if not settings.reduced and not testing: gameover_card.modulate.a=0

func retry_gameover() -> void:
	if screen!="collapse" or gameover_final or current.is_empty(): return
	if not testing and gameover_elapsed<1: return
	close_overlay()
	current.lives=max_lives(); current.active={}; current.phase="question"
	audio.defeat=false; audio.final_defeat=false
	art.modulate=Color.WHITE; art.defeat_active=false; art.defeat_amount=0; art.presentation_rect=Rect2()
	answered=false; save_game(); start_question()

func leave_gameover() -> void:
	if screen!="collapse": return
	update_snapshot(); save_game(); menu()

func retire_current_journey() -> bool:
	if current.is_empty(): return true
	var id: String=str(current.id)
	var retired: Array=ended_journeys.duplicate()
	if id not in retired: retired.append(id)
	var temp: String=ENDED_SAVE+".tmp"
	var file:=FileAccess.open(temp,FileAccess.WRITE)
	if file==null: storage_failure(); return false
	file.store_string(JSON.stringify(retired)); file.flush()
	var result: Error=file.get_error(); file.close()
	if result!=OK or DirAccess.rename_absolute(ProjectSettings.globalize_path(temp),ProjectSettings.globalize_path(ENDED_SAVE))!=OK:
		storage_failure(); return false
	ended_journeys=retired
	profiles=profiles.filter(func(p): return str(p.id)!=id)
	current={}; question={}; phase=""; save_game(); save_game()
	return true

func retry_final_save() -> void:
	if not gameover_final: return
	if retire_current_journey(): menu()

func process_gameover(delta: float) -> void:
	if screen not in ["collapse","gameover_final"]: return
	gameover_elapsed+=delta
	var amount: float=1.0 if settings.reduced else clampf(gameover_elapsed/1.0,0,1)
	art.defeat_amount=amount
	art.modulate=Color.WHITE.lerp(Color(.72,.78,.88,1),amount)
	if is_instance_valid(gameover_card): gameover_card.modulate.a=amount
	if gameover_elapsed>=1 and is_instance_valid(gameover_primary) and not gameover_returning:
		gameover_primary.grab_focus(); gameover_returning=true
	if screen=="gameover_final" and gameover_storage_ok and gameover_elapsed>=4.6: menu()

func max_lives(mode: String="") -> int:
	var selected_mode: String=mode if not mode.is_empty() else str(current.get("mode","normal"))
	return 2 if selected_mode=="hard" else 3

func reset_question_chances(profile: Dictionary) -> void:
	profile.lives=max_lives(str(profile.mode))
	profile.defeats=0
	profile.last_defeat_timeout=false
	profile.rules_version=5

func solution_text() -> String:
	if question.is_empty(): return "Observe os padrões e consulte as fórmulas de Tico."
	return str(question.solution)

func start_restore() -> void:
	screen="restoring"; phase="restoring"; current.phase=phase; current.restoring_id=mission
	reset_question_chances(current)
	update_snapshot(); save_game()
	reset_refs(); art.restored=current.done.duplicate(); art.room=int(mission/4); art.menu_mode=false
	art.restore(mission%4); restore_remaining=2.7 if not settings.reduced else .3
	audio.cue("restore")
	panel(Rect2(310,35,660,65))
	label_at("✓ O padrão se encaixou. A história está voltando…",Rect2(335,51,610,34),20,GOLD)

func finish_restore(resuming: bool=false) -> void:
	reset_question_chances(current)
	if mission not in current.done: current.done.append(mission)
	if not resuming: current.last_solution=solution_text()
	current.active={}; current.phase="success"; phase="success"; current.restoring_id=mission
	room=int(mission/4); current.room=room
	art.room=room; art.restored=current.done.duplicate(); art.menu_mode=false; art.show_pair=false
	audio.track(room+1)
	current.hero=[art.hero.x,art.hero.y]
	save_game()
	screen="success"; reset_refs()
	panel(Rect2(185,135,910,540))
	label_at("OBRA RESTAURADA / %02d DE 12" % current.done.size(),Rect2(225,172,830,40),16,TEAL)
	label_at(NAMES[mission],Rect2(225,230,820,70),35,GOLD)
	label_at(str(current.get("last_solution",solution_text())),Rect2(225,330,800,140),24)
	var msg: String="O objeto permanece restaurado no museu. Estabilidade recuperada."
	if (mission+1)%4==0:
		msg=["Primeira engrenagem! Tico lembra: o Curador queria proteger as obras.","Segunda engrenagem! Congelar o tempo também impedia novas descobertas.","Terceira engrenagem! O museu pode voltar a receber o amanhã."][int(mission/4)]
	label_at(msg,Rect2(225,493,800,70),21,TEAL)
	button("Continuar explorando",Rect2(225,591,350,52),continue_after_restore,true)
	button("Ver a obra",Rect2(600,591,260,52),func(): view_restored(mission))

func view_restored(id: int) -> void:
	if id not in current.done: return
	# A modal preserves the success screen, room, next objective and saved journey.
	make_overlay()
	panel(Rect2(150,65,980,665),overlay)
	label_at("ACERVO RESTAURADO / OBRA %02d" % (id+1),Rect2(190,94,880,30),15,TEAL,overlay)
	label_at(NAMES[id],Rect2(190,141,880,60),32,GOLD,overlay)
	var display:=Exhibit.new()
	display.kind=art.TYPES[int(id/4)][id%4]; display.progress=1.0
	display.display_scale=3.1; display.reduced=settings.reduced
	place(display,Rect2(210,218,550,370),overlay)
	label_at(FACTS[id],Rect2(790,280,285,180),21,MUTED,overlay)
	label_at("RESTAURAÇÃO COMPLETA",Rect2(790,490,285,65),15,TEAL,overlay)
	button("Voltar",Rect2(190,643,230,54),close_overlay,true,overlay)
	if screen=="world":
		button("Praticar novamente",Rect2(700,643,370,54),func(): close_overlay(); mission=id; current.tour=true; current.lives=max_lives(); start_question(),false,overlay)
	else:
		button("Voltar ao museu",Rect2(700,643,370,54),func(): close_overlay(); current.tour=next_mission()==12; world(true),false,overlay)

func show_hint() -> void:
	if screen!="challenge" or answered: return
	if current.mode=="hard" and hints>=1:
		status.text="Sua dica já foi utilizada. O caderno continua disponível."; return
	hints+=1; current.hints_used=int(current.hints_used)+1
	record_learning("dicas")
	status.text=str(question.hint)
	if hints==2: status.text=str(question.hint_steps[1]) if question.has("hint_steps") else "Identifique: a₁ = %s, r = %s, n = %s. Consulte a fórmula correspondente."%[question.a,question.r,question.n]
	if hints>=3: status.text=solution_text()
	update_snapshot(); save_game()

func notebook() -> void:
	if screen=="challenge": consulted_book=true; update_snapshot(); save_game()
	var running: bool=screen=="challenge" and current.get("mode","")=="hard" and not answered
	info("Caderno de Tico"+(" · TEMPO CONTINUA" if running else ""),"P.A. é uma sequência com diferença constante entre termos consecutivos.\n\nSÍMBOLOS\na₁: primeiro termo · a₂: segundo termo\naₙ: termo na posição n · r: razão (diferença constante)\nn: posição do termo ou quantidade de termos somados\nSₙ: soma dos n primeiros termos\ni e j: posições distintas. Os termos nessas posições são a[i] e a[j]\n\nRAZÃO: diferença entre termos consecutivos\nr = a₂ − a₁\nEx.: 2, 5, 8 r = 5 − 2 = 3\n\nRAZÃO ENTRE DUAS POSIÇÕES: quando os termos não são vizinhos\nr = (a[j] − a[i])/(j − i), com j ≠ i\nEx.: a₂ = 5 e a₄ = 11 r = (11 − 5)/(4 − 2) = 3\n\nTERMO GERAL: encontrar o valor na posição n\naₙ = a₁ + (n − 1)r\nEx.: a₁ = 2, r = 3 a₄ = 2 + 3 × 3 = 11\n\nPRIMEIRO TERMO: voltar ao início\na₁ = aₙ − (n − 1)r\nEx.: a₄ = 11, r = 3 a₁ = 11 − 3 × 3 = 2\n\nPOSIÇÃO OU QUANTIDADE: localizar o último termo\nn = (aₙ − a₁)/r + 1, se r ≠ 0\nEx.: (11 − 2)/3 + 1 = 4 termos\n\nSOMA: juntar os n primeiros termos\nSₙ = n(a₁ + aₙ)/2\nEx.: S₄ = 4 × (2 + 11)/2 = 26\n\nr > 0: crescente. r < 0: decrescente. r = 0: constante.\n\nExemplo: 2, 5, 8, 11. r = 3, a₄ = 11 e S₄ = 26.\nA primeira posição é 1. A quantidade de termos é inteira e positiva.\n\nNo modo Difícil, o cronômetro continua enquanto você consulta este caderno.",Callable(),"",not running)

func pause_game() -> void:
	if screen=="credits": toggle_credits_pause(); return
	if screen not in ["world","challenge","restoring","credits","ending","success","timeout"]: return
	if not pause_stage.is_empty(): return
	audio.stop_countdown()
	if banked_pause: show_pause_menu(); return
	super.close_overlay()
	pause_layout={"menu":art.menu_mode,"pair":art.show_pair,"frame":art.presentation_rect}
	ui.visible=false; art.menu_mode=false; art.show_pair=false; art.room=room
	art.movement=Vector2.ZERO; touch_movement=Vector2.ZERO
	art.frozen=false; pause_stage="walking"
	if art.seated: show_pause_menu()
	else:
		art.use_bench()
		if not art.bench_pending:
			# The grid should always offer a route; keep control if a route cannot be found.
			pause_stage=""; ui.visible=true; restore_pause_layout()

func show_pause_menu() -> void:
	pause_stage=""; banked_pause=true; overlay_kind="pause"
	ui.visible=false; art.seated=true; art.rise_progress=0
	make_overlay(); overlay.get_child(0).color=Color(.025,.045,.075,.40)
	art.presentation_rect=Rect2(10,100,665,570)
	audio.paused=true; art.frozen=true
	art.movement=Vector2.ZERO; touch_movement=Vector2.ZERO
	update_snapshot(); save_game()
	panel(Rect2(695,72,550,657),overlay)
	label_at("O tempo pode esperar.",Rect2(727,111,486,65),30,GOLD,overlay)
	button("Retomar",Rect2(727,211,486,54),resume_from_bench,true,overlay).grab_focus()
	button("Configurações",Rect2(727,279,486,51),func(): returning_to_pause=true; open_settings(),false,overlay)
	button("Controles",Rect2(727,344,486,51),func(): info("Como jogar",help_text()),false,overlay)
	button("Trocar pergunta",Rect2(727,409,486,51),restart_confirm,false,overlay).disabled=screen!="challenge"
	button("Voltar ao menu",Rect2(727,474,486,51),func():
		info("Voltar ao menu?","Sua questão, alternativas, vidas e tempo restante serão preservados.",func(): update_snapshot(); save_game(); menu(),"Salvar e voltar"),false,overlay)
	label_at("Jogo e cronômetro pausados.\nProgresso salvo neste dispositivo.",Rect2(727,586,486,100),18,MUTED,overlay).horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT


func resume_from_bench() -> void:
	if not banked_pause: super.close_overlay(); return
	super.close_overlay(); banked_pause=false; returning_to_pause=false
	pause_stage="rising"; rise_elapsed=0; paused=true
	ui.visible=false; art.menu_mode=false; art.show_pair=false
	art.frozen=false; art.path=[]; art.pending=-1; art.bench_pending=false
	art.seated=true; art.rise_progress=0; art.movement=Vector2.ZERO

func restore_pause_layout() -> void:
	art.menu_mode=bool(pause_layout.get("menu",false))
	art.show_pair=bool(pause_layout.get("pair",false))
	art.presentation_rect=pause_layout.get("frame",Rect2())
	pause_layout={}

func cancel_pause_cycle() -> void:
	pause_stage=""; banked_pause=false; resume_action=Callable(); returning_to_pause=false
	pause_layout={}; bench_state=""
	if is_instance_valid(ui): ui.visible=true
	if is_instance_valid(art): art.rise_progress=0

func close_overlay() -> void:
	if learning_book:
		learning_book=false; learning_summary(); return
	if banked_pause:
		if overlay_kind=="pause": resume_from_bench()
		else: super.close_overlay(); show_pause_menu()
	else: super.close_overlay()

func info(title: String,body: String,action: Callable=Callable(),caption: String="",stop_time: bool=true) -> void:
	overlay_kind="info"
	super.info(title,body,action,caption,stop_time)

func swap_after_pause() -> void:
	if banked_pause: resume_action=skip_question; resume_from_bench()
	else: close_overlay(); skip_question()

func restart_confirm() -> void:
	info("Trocar a pergunta?","A troca não gasta vidas. No Difícil, mantém o tempo restante. As obras concluídas continuam restauradas.",swap_after_pause,"Trocar pergunta")

func open_settings() -> void:
	overlay_kind="settings"
	make_overlay(); panel(Rect2(235,72,810,657),overlay)
	label_at("Sua experiência",Rect2(275,110,730,65),35,GOLD,overlay)
	if not mobile_layout: button("Tela cheia / Janela · F11",Rect2(620,630,370,50),toggle_fullscreen,false,overlay)
	for i in range(3):
		var key: String=["master","music","effects"][i]
		label_at(["Volume geral","Música","Efeitos sonoros"][i],Rect2(275,214+i*80,300,35),23,WHITE,overlay)
		var slider:=HSlider.new(); slider.min_value=0; slider.max_value=1; slider.step=.05; slider.value=float(settings[key])
		place(slider,Rect2(610,215+i*80,340,35),overlay)
		if i==0: slider.grab_focus()
		slider.value_changed.connect(func(v): settings[key]=v; save_game())
	var reduce:=CheckButton.new(); reduce.text="Movimento reduzido"; reduce.button_pressed=settings.reduced; reduce.add_theme_font_size_override("font_size",22)
	place(reduce,Rect2(275,470,650,50),overlay)
	reduce.toggled.connect(func(v): settings.reduced=v; save_game())
	var large:=CheckButton.new(); large.text="Texto ampliado (próxima tela)"; large.button_pressed=settings.large; large.add_theme_font_size_override("font_size",22)
	place(large,Rect2(275,537,650,50),overlay)
	large.toggled.connect(func(v): settings.large=v; save_game())
	button("Salvar e voltar",Rect2(275,635,320,50),settings_back,true,overlay)

func help_text() -> String:
	return "OBJETIVO\nRestaure 12 exposições em três alas. Cada engrenagem recuperada abre a próxima ala.\n\nCONTROLES\nEXPLORAÇÃO: use as setas, os botões direcionais ou clique no chão para caminhar. Clique numa obra para aproximar-se. Use Examinar ou E para abrir.\n\nBANCO: você começa sentado em cada galeria, inclusive na primeira. Levantar ou uma seta permite explorar. Clicar no banco ou em Sentar faz o personagem caminhar e sentar, sem pausar.\n\nPAUSA: Pausar, Esc ou Enter levam o personagem até o banco. O jogo e o som do cenário pausam somente depois que ele se senta. Ao retomar, ele se levanta. Em seguida os controles são liberados. No Difícil, o tempo continua durante a caminhada até o banco.\n\nMENUS: use as setas para navegar, Espaço para ativar a opção destacada e Tab para alternar o foco. Em textos longos, cima/baixo rolam o conteúdo. Page Up/Page Down, Home e End também funcionam. Esc ou Enter retomam o jogo quando ele está pausado.\n\nCELULAR\nJogue na horizontal. Toque nas opções e nas obras, use os botões direcionais para caminhar e arraste os textos para rolar. O nome é digitado pelo teclado do navegador. Nos créditos pausados, Retornar aos créditos permite continuar pelo toque.\n\nCRÉDITOS FINAIS\nPausar interrompe somente as letras. A música e as galerias continuam, respeitando Movimento reduzido. Esc ou Enter pausam e retomam os letreiros. Enquanto as letras estão pausadas, o botão Sair para o menu principal encerra os créditos. Não há caminhada ao banco nem menu de pausa nos créditos.\n\nDESAFIOS\nIdentifique padrões e calcule termos, razões e somas. Escolha uma alternativa e confirme. O sorteio respeita o conteúdo da obra. Próxima pergunta não gasta vidas. No Difícil, mantém o tempo restante.\n\nVIDAS E GAME OVER\nNormal: três corações. Difícil: dois corações. Cada coração é uma vida. Ao esgotá-los, aparece GAME OVER. Normal: sem tempo. Difícil: 60 a 120 segundos. Quando o tempo acaba, você também perde uma vida. Cada erro novo e confirmado custa uma vida. Campos vazios e respostas repetidas não descontam novamente. Se as vidas acabarem, aparece GAME OVER. Você tem uma tentativa extra por desafio, renovada ao acertar. Ela reinicia só a restauração atual, com os corações do modo e uma nova questão do mesmo desafio. No Difícil, o tempo também é renovado. Se esgotar os corações novamente antes de acertar, esta jornada e todas as suas restaurações serão apagadas. As outras jornadas e as configurações são preservadas. Voltar ao menu ou fechar o jogo não renova a tentativa extra. Acertar recupera todos os corações e zera a contagem de derrotas para a próxima pergunta. Próxima pergunta mantém os corações e a tentativa extra que restam.\n\nDICAS\nDicas não custam vidas. O caderno mantém o tempo ativo no Difícil. A pausa encobre a questão durante a ida ao banco. O tempo só para depois de sentar."

func credits() -> void:
	audio.track(5)
	close_overlay(); reset_refs(); screen="credits"
	credit_elapsed=0
	for index in range(2):
		var scene: Control=presentation_gallery(index,Rect2(55,95,1170,590))
		scene.modulate.a=1.0 if index==0 else 0.0
		credit_scenes.append(scene)
	var background:=ColorRect.new()
	background.color=Color(.02,.035,.06,.62)
	background.mouse_filter=Control.MOUSE_FILTER_IGNORE
	place(background,Rect2(0,0,1280,800))
	var reading:=Panel.new()
	reading.mouse_filter=Control.MOUSE_FILTER_IGNORE
	reading.add_theme_stylebox_override("panel",style(Color(.025,.045,.07,.35),Color(0,0,0,0),22))
	place(reading,Rect2(165,40,950,660))
	var viewport: Control=ScrollContainer.new() if settings.reduced else Control.new()
	viewport.clip_contents=true
	if viewport is ScrollContainer: viewport.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	place(viewport,Rect2(120,55,1040,635))
	credit_viewport=viewport
	credit_roll=label_at("P.A.RADOXO\nO Museu Fora do Tempo\n\nUMA JORNADA CONCLUÍDA\nObrigado por restaurar nossas histórias,\n%s!\n\nPROJETO APLICADO\nProgressão Aritmética\nUniversidade de Fortaleza\nCentro de Ciências Tecnológicas\nDisciplina: Res problemas nat discreta\nProfessor: Rubens Rodrigues\n\nEQUIPE\nMário Monteiro\nBruno Gonçalves\nAna Gabriella\nJosé Cleidson\n\nARTE E SOM\nIlustrações isométricas e personagens originais\nComposições musicais originais do projeto\n\nTECNOLOGIA\nGodot Engine 4.7.2 · licença MIT\nFontes Symbols e Emoji · SIL OFL\nLicenças completas nos arquivos do jogo\n\nO museu continua vivo\nenquanto alguém tem curiosidade.\n\nFIM" % current.name,Rect2(0,0 if settings.reduced else 635,1000,0),27,GOLD,viewport)
	credit_roll.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	credit_roll.add_theme_color_override("font_shadow_color",Color(0,0,0,.95))
	credit_roll.add_theme_constant_override("shadow_offset_y",2)
	if settings.reduced: padded_scroll_content(viewport,credit_roll)
	credit_hint=label_at("Esc ou Enter: pausar e retomar as letras.",Rect2(340,694,600,24),14,MUTED)
	credit_hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	credit_button=button("Pausar",Rect2(440,724,400,52),func():
		if credits_paused: menu()
		else: toggle_credits_pause())
	if mobile_layout:
		credit_resume_button=button("Retornar aos créditos",Rect2(60,470,400,60),toggle_credits_pause,true)
		credit_resume_button.visible=false
	if settings.reduced: viewport.grab_focus()

func toggle_credits_pause() -> void:
	if screen!="credits" or not is_instance_valid(credit_button): return
	credits_paused=not credits_paused
	credit_button.text="Sair para o menu principal" if credits_paused else "Pausar"
	credit_hint.text="Letras pausadas. Esc ou Enter para retomar." if credits_paused else "Esc ou Enter: pausar e retomar as letras."
	if credit_viewport is ScrollContainer:
		credit_viewport.focus_mode=Control.FOCUS_NONE if credits_paused else Control.FOCUS_ALL
	if credits_paused or not settings.reduced: credit_button.grab_focus()
	else: credit_viewport.grab_focus()
	if mobile_layout: MobileLayout.credit_controls(self)

func presentation_gallery(index: int,rect: Rect2) -> Control:
	var scene:=Museum.new()
	place(scene,Rect2(0,0,1280,800))
	scene.menu_mode=false; scene.room=index; scene.restored=range(12)
	scene.active=-1; scene.show_pair=false; scene.gender=current.gender
	scene.hero=scene.BENCH_EXIT; scene.seated=true; scene.reduced=settings.reduced
	scene.presentation_rect=rect
	return scene

func update_credit_scenery(delta: float) -> void:
	if credit_scenes.size()!=2: return
	for scene in credit_scenes:
		scene.frozen=paused or not pause_stage.is_empty()
		scene.reduced=settings.reduced
	if paused or not pause_stage.is_empty() or settings.reduced: return
	credit_elapsed+=delta
	var cycle: int=int(credit_elapsed/12)
	var next: Control=credit_scenes[1]
	credit_scenes[0].room=cycle%3
	next.room=(cycle+1)%3
	var blend: float=smoothstep(9.0,12.0,fmod(credit_elapsed,12.0))
	next.modulate.a=blend

func ending() -> void:
	ending_elapsed=0
	close_overlay(); screen="ending"; phase="world"; current.phase=phase; current.active={}; save_game()
	art.menu_mode=true; art.room=2; art.restored=current.done.duplicate(); art.active=-1
	audio.track(4); audio.cue("restore")
	reset_refs()
	presentation_gallery(2,Rect2(690,175,555,465))
	panel(Rect2(35,50,630,700))
	label_at("O MUSEU TEM UM AMANHÃ",Rect2(70,87,560,40),16,TEAL)
	label_at("Você devolveu vida\nàs histórias.",Rect2(70,151,560,150),37,GOLD)
	prose("%s, as três engrenagens voltaram ao relógio. Tico recuperou suas memórias. O Curador reabriu as portas: agora, o museu pode construir novas histórias." % current.name,Rect2(70,328,560,175),20)
	label_at("12 OBRAS RESTAURADAS • 3 ENGRENAGENS\n%d respostas corretas • %d dicas consultadas\nModo %s" % [int(current.correct),int(current.hints_used),"Normal" if current.mode=="normal" else "Difícil"],Rect2(70,535,560,107),17,TEAL)
	button("Ver créditos",Rect2(70,673,265,50),credits,true)
	button("Meu aprendizado",Rect2(355,673,275,50),learning_summary)

func update_timer() -> void:
	if not is_instance_valid(timer_label): return
	timer_label.text="SEM LIMITE" if current.mode=="normal" else "%02d:%02d"%[int(ceil(time_left))/60,int(ceil(time_left))%60]
	timer_label.add_theme_color_override("font_color",Color("efb3a4") if time_left<15 and current.mode=="hard" else GOLD)

func _process(delta: float) -> void:
	if screen in ["entry","loading"]:
		audio.volume=float(settings.music)*float(settings.master);audio.effects_volume=float(settings.effects)*float(settings.master)
		if is_instance_valid(title_label):title_label.reduced=settings.reduced
		if screen=="entry":
			native_entry_time+=delta
			if is_instance_valid(native_entry_button):
				var pulse: float=0 if settings.reduced else sin(native_entry_time*2.2)*.008
				native_entry_button.scale=Vector2.ONE*(1.0+pulse+(.02 if native_entry_button.is_hovered() else 0.0))
			if is_instance_valid(native_entry_scene):
				native_entry_scene.reduced=settings.reduced;native_entry_scene.pointer=get_global_mouse_position()
				var hovered: int=native_entry_scene.menu_character_at(native_entry_scene.pointer)
				if hovered>=0 and hovered!=native_entry_hover:native_entry_scene.greetings[hovered]=1.2;audio.hover()
				native_entry_hover=hovered
		return
	if is_instance_valid(gallery_transition):
		if mobile_layout and OS.has_feature("web"):
			mobile_orientation_timer+=delta
			if mobile_orientation_timer>=.3:
				mobile_orientation_timer=0
				transition_orientation_paused=bool(JavaScriptBridge.eval("window.paradoxo && window.paradoxo.portrait"))
		gallery_transition.suspended=transition_focus_paused or transition_orientation_paused
		audio.paused=gallery_transition.suspended
		audio.volume=float(settings.music)*float(settings.master);audio.effects_volume=float(settings.effects)*float(settings.master)
		return
	process_gameover(delta)
	if mobile_layout and OS.has_feature("web"):
		mobile_orientation_timer+=delta
		if mobile_orientation_timer>=.3:
			mobile_orientation_timer=0
			if bool(JavaScriptBridge.eval("window.paradoxo && window.paradoxo.portrait")):
				if screen in ["world","challenge","restoring"] and not paused and pause_stage.is_empty(): pause_game()
				elif screen=="credits" and not credits_paused: toggle_credits_pause()
	if mobile_layout and OS.has_feature("web") and screen=="setup" and is_instance_valid(setup_name):
		var entered: Variant=JavaScriptBridge.eval("window.paradoxo ? window.paradoxo.takeName() : null")
		if entered!=null: setup_name.text=str(entered)
	if screen=="credits": update_credit_scenery(delta)
	if pause_stage=="walking" and art.seated: show_pause_menu()
	elif pause_stage=="rising":
		rise_elapsed+=delta
		art.rise_progress=clampf(rise_elapsed/(.08 if settings.reduced else .4),0,1)
		if art.rise_progress>=1:
			art.stand_up(); pause_stage=""; paused=false; ui.visible=true
			restore_pause_layout()
			current.hero=[art.hero.x,art.hero.y]; current.seated=false
			sync_bench_status(true); update_snapshot(); save_game()
			var action: Callable=resume_action; resume_action=Callable()
			if action.is_valid(): action.call()
	if screen=="credits" and not paused and not credits_paused and not settings.reduced and is_instance_valid(credit_roll):
		credit_roll.position.y-=delta*48
		if credit_roll.position.y+credits_text_height()<0: menu(); return
	if not is_instance_valid(art): return
	if is_instance_valid(title_label): title_label.reduced=settings.reduced; title_label.frozen=paused
	art.frozen=(paused or screen in ["challenge","timeout","success"] or (screen in ["collapse","gameover_final"] and gameover_elapsed>=1)) and pause_stage.is_empty()
	art.reduced=settings.reduced
	if is_instance_valid(character_view): character_view.gender=gender; character_view.reduced=settings.reduced
	audio.volume=float(settings.music)*float(settings.master)
	audio.effects_volume=float(settings.effects)*float(settings.master)
	if "--audio-test" not in OS.get_cmdline_user_args(): audio.paused=paused
	audio.subdued=screen=="challenge"
	if is_instance_valid(exhibit_view): exhibit_view.frozen=paused; exhibit_view.reduced=settings.reduced
	if screen=="world" and not paused and pause_stage.is_empty():
		var hovered: int=art.hit_exhibit(art.pointer)
		if hovered!=art.hovered and hovered>=0: audio.hover()
		art.hovered=hovered
		var bench_hover: bool=art.hit_bench(art.pointer)
		if bench_hover and not art.bench_hovered: audio.hover()
		art.bench_hovered=bench_hover
		sync_bench_status()
		var v:=touch_movement
		if Input.is_physical_key_pressed(KEY_LEFT): v.x-=1
		if Input.is_physical_key_pressed(KEY_RIGHT): v.x+=1
		if Input.is_physical_key_pressed(KEY_UP): v.y-=1
		if Input.is_physical_key_pressed(KEY_DOWN): v.y+=1
		art.movement=v.normalized() if v.length()>1 else v
	else:
		art.movement=Vector2.ZERO
		art.bench_hovered=screen=="menu" and not paused and art.hit_bench(art.pointer)
		art.hovered=art.hit_exhibit(art.pointer) if screen=="menu" and not paused and art.pointer.x>650 else -1
	if screen=="menu" and not paused:
		var person: int=art.menu_character_at(art.pointer)
		if person>=0 and person!=menu_character_hovered: art.greetings[person]=1.2; audio.hover()
		menu_character_hovered=person
	if screen=="challenge" and not paused and not answered and question_ready and current.mode=="hard":
		var previous_time: float=time_left
		time_left=maxf(0,time_left-delta); update_timer()
		audio.countdown(previous_time,time_left)
		if time_left<=0:
			close_overlay(); lose_charge(true)
	if screen=="restoring" and not paused:
		restore_remaining=maxf(0,restore_remaining-delta)
		if restore_remaining<=0: finish_restore()
	checkpoint+=delta
	if checkpoint>=1.0:
		checkpoint=0
		if not current.is_empty(): update_snapshot(); save_game()

func sync_bench_status(force: bool=false) -> void:
	if screen!="world" or not pause_stage.is_empty() or banked_pause: return
	var state: String="seated" if art.seated else "walking" if art.bench_pending else "standing"
	if is_instance_valid(bench_button): bench_button.text="Levantar" if art.seated else "A caminho…" if art.bench_pending else "Sentar"
	if state!=bench_state or force:
		bench_state=state
		if is_instance_valid(status):
			status.text="Você está sentado. Levante pelo botão ou use uma seta para explorar." if state=="seated" else "Caminhando até o banco. Use as setas para cancelar." if state=="walking" else "Clique numa obra para caminhar até ela. Setas: mover. Clique em Examinar."
			if mobile_layout: status.text="Toque em Levantar." if state=="seated" else "Indo ao banco…" if state=="walking" else "Toque para caminhar."

func use_bench() -> void:
	if screen!="world" or paused or not pause_stage.is_empty(): return
	art.use_bench(); sync_bench_status(true)
	update_snapshot(); save_game()

func toggle_pause_key() -> void:
	if screen=="credits": toggle_credits_pause(); return
	if not pause_stage.is_empty(): return
	if banked_pause: resume_from_bench()
	elif is_instance_valid(overlay): close_overlay()
	else: pause_game()

func _input(event: InputEvent) -> void:
	if screen=="loading":
		get_viewport().set_input_as_handled();return
	if screen=="entry" and event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ENTER,KEY_KP_ENTER,KEY_SPACE]:
		start_native_loading();get_viewport().set_input_as_handled();return
	if is_instance_valid(gallery_transition):
		get_viewport().set_input_as_handled();return
	if is_instance_valid(art) and (event is InputEventMouseMotion or event is InputEventMouseButton): art.pointer=event.position
	if screen=="credits" and credits_paused:
		if event is InputEventMouse and is_instance_valid(credit_viewport) and credit_viewport.get_global_rect().has_point(event.position):
			get_viewport().set_input_as_handled(); return
		if event is InputEventKey and event.keycode in [KEY_PAGEUP,KEY_PAGEDOWN,KEY_HOME,KEY_END]:
			get_viewport().set_input_as_handled(); return
	if not pause_stage.is_empty():
		if event is InputEventKey or event is InputEventMouseButton: get_viewport().set_input_as_handled()
		return
	if screen=="gameover_final" and gameover_storage_ok:
		if event is InputEventKey or event is InputEventMouseButton: get_viewport().set_input_as_handled()
		return
	if not event is InputEventKey: return
	if screen=="collapse" and event.pressed and not event.echo and event.keycode in [KEY_ENTER,KEY_KP_ENTER,KEY_SPACE,KEY_ESCAPE]:
		if gameover_elapsed<1:
			gameover_elapsed=1; get_viewport().set_input_as_handled(); return
		if event.keycode==KEY_ESCAPE:
			if is_instance_valid(overlay): close_overlay()
			else: leave_gameover()
			get_viewport().set_input_as_handled(); return
	if event.keycode in [KEY_ENTER,KEY_KP_ENTER,KEY_ESCAPE] and screen in ["world","challenge","restoring","credits","ending","success","timeout"]:
		get_viewport().set_input_as_handled()
		if event.pressed and not event.echo: toggle_pause_key()
		return
	if not event.pressed: return
	if event.keycode in [KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN] and screen=="world" and not paused and not is_instance_valid(overlay):
		get_viewport().set_input_as_handled(); return
	var active_root: Control=overlay if is_instance_valid(overlay) else ui
	if keyboard_navigate(event,active_root): get_viewport().set_input_as_handled()

func credits_text_height() -> float:
	if not is_instance_valid(credit_roll): return 0
	var count: int=credit_roll.get_line_count()
	return count*credit_roll.get_line_height()+maxi(0,count-1)*credit_roll.get_theme_constant("line_spacing")

func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(gallery_transition):return
	if not pause_stage.is_empty(): return
	if screen=="menu" and not paused and event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT and event.position.x>650:
		var index: int=art.hit_exhibit(event.position)
		if index>=0: art.restore(index); audio.hover()
		else:
			var person: int=art.menu_character_at(event.position)
			if person>=0: art.greetings[person]=1.8; audio.hover()
			elif art.hit_bench(event.position): art.greetings[0]=1.3; art.greetings[1]=1.3; audio.hover()
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_F11: toggle_fullscreen()
		elif event.keycode==KEY_ESCAPE and screen!="gameover_final":
			if is_instance_valid(overlay): close_overlay()
			else: pause_game()
		elif event.keycode==KEY_E and screen=="world" and not paused: interact_nearest()
	if screen=="world" and not paused and event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		var p: Vector2=event.position
		if art.hit_bench(p): use_bench(); return
		var hit: int=art.hit_exhibit(p)
		if hit>=0: art.approach(hit); return
		art.walk_to(art.ground_point(p))

func _notification(what: int) -> void:
	if is_instance_valid(gallery_transition):
		if what==NOTIFICATION_APPLICATION_FOCUS_OUT:transition_focus_paused=true
		elif what==NOTIFICATION_APPLICATION_FOCUS_IN:transition_focus_paused=false
	if not is_instance_valid(ui): return
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT and screen in ["world","challenge","restoring"] and not testing and "--capture" not in OS.get_cmdline_user_args():
		pause_game()
	if what==NOTIFICATION_WM_CLOSE_REQUEST:
		save_before_close()
		shutdown()

func save_before_close() -> void:
	if resources_ready: update_snapshot(); save_game()

func update_snapshot() -> void:
	if current.is_empty(): return
	if banked_pause or not pause_stage.is_empty(): current.hero=[art.hero.x,art.hero.y]; current.seated=art.seated
	if screen=="world": current.hero=[art.hero.x,art.hero.y]; current.room=room; current.seated=art.seated
	if not current.active.is_empty() and not question.is_empty() and screen in ["challenge","timeout","collapse","restoring"]:
		current.active={"question":question.duplicate(true),"mission":mission,"remaining":time_left,"bad":bad_answers.duplicate(),"hints":hints,"slots":sequence_slots.duplicate(),"selected":selected_answer,"slot_index":slot_index,"consulted_book":consulted_book}
		current.phase=phase

func number_in(value: Variant,low: float,high: float,whole: bool=true) -> bool:
	if not (value is int or value is float): return false
	return is_finite(float(value)) and float(value)>=low and float(value)<=high and (not whole or float(value)==floorf(float(value)))

func read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path): return null
	var parser:=JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path))!=OK: return null
	return parser.data

func valid_profile(p: Variant) -> bool:
	if not p is Dictionary: return false
	for key in ["id","name","gender","mode"]:
		if not p.get(key) is String: return false
	if p.id.is_empty() or p.mode not in ["normal","hard"] or p.gender not in ["male","female"]: return false
	if not p.get("tutorial") is bool or not p.get("active") is Dictionary: return false
	if not p.get("done") is Array or not p.get("seen") is Array: return false
	for id in p.done:
		if not number_in(id,0,11): return false
	for id in p.seen:
		if not id is String: return false
	var allowed_lives: int=max_lives(p.mode) if int(p.get("rules_version",0))>=5 else 5 if p.mode=="normal" else 3
	if not number_in(p.get("room"),0,2) or not number_in(p.get("lives"),0,allowed_lives): return false
	if not p.get("hero") is Array or p.hero.size()!=2: return false
	if not number_in(p.hero[0],.0,9,false) or not number_in(p.hero[1],.0,7,false): return false
	for key in ["attempts","correct","hints_used","skipped","restoring_id"]:
		if not number_in(p.get(key,0),0,11 if key=="restoring_id" else 100000000): return false
	if p.get("phase","world") not in ["intro","world","question","restoring","timeout","collapse","success"]: return false
	if not p.get("last_solution","") is String: return false
	if not p.get("tour",false) is bool: return false
	if not p.get("seated",false) is bool: return false
	var introduced: Variant=p.get("introduced_galleries",[0,1,2])
	if not introduced is Array or introduced.size()>3:return false
	var unique_galleries: Array=[]
	for gallery in introduced:
		if not number_in(gallery,0,2) or gallery in unique_galleries:return false
		unique_galleries.append(gallery)
	if not number_in(p.get("rules_version",0),0,5): return false
	if not number_in(p.get("defeats",0),0,2): return false
	if not p.get("last_defeat_timeout",false) is bool: return false
	if not number_in(p.get("last_answer_position",-1),-1,3): return false
	var balance: Variant=p.get("balance",[0,0,0,0])
	if not balance is Array or balance.size()!=4: return false
	for count in balance:
		if not number_in(count,0,100000000): return false
	var learning: Variant=p.get("learning",{})
	if not learning is Dictionary: return false
	for key in learning:
		if key not in ["0","1","2","3","4","5","6"] or not learning[key] is Dictionary: return false
		for metric in learning[key]:
			if metric not in ["sem_ajuda","com_ajuda","erros","puladas","tempo_esgotado","dicas"]: return false
			if not number_in(learning[key][metric],0,100000000): return false
	var draws: Variant=p.get("draw_state",{})
	if not draws is Dictionary or draws.size()>14: return false
	for draw_key in draws:
		if draw_key not in ["normal:0","normal:1","normal:2","normal:3","normal:4","normal:5","normal:6","hard:0","hard:1","hard:2","hard:3","hard:4","hard:5","hard:6"]: return false
		var state: Variant=draws[draw_key]
		if not state is Dictionary or not state.get("families",{}) is Dictionary or state.get("families",{}).size()>5: return false
		for family in state.get("families",{}):
			if family not in ["sequencia","registros","tabela","mecanismo","restauracao"]: return false
			if not number_in(state.families[family],0,100000000): return false
		for key in ["sign_streak","trend_streak"]:
			if not number_in(state.get(key,0),0,100000000): return false
		if state.get("last_family","") not in ["","sequencia","registros","tabela","mecanismo","restauracao"]: return false
		if state.get("last_sign","") not in ["","label","positive","negative","zero"]: return false
		if state.get("last_trend","") not in ["","increasing","decreasing","constant","irregular"]: return false
	if p.active.is_empty(): return true
	var active: Dictionary=p.active
	if not number_in(active.get("mission"),0,11) or not number_in(active.get("remaining"),0,120,false): return false
	if not number_in(active.get("hints"),0,100000000) or not number_in(active.get("slot_index",0),0,1): return false
	if not active.get("consulted_book",false) is bool or not active.get("selected","") is String: return false
	if not active.get("bad") is Array or not active.get("slots",["",""]) is Array: return false
	for answer in active.bad:
		if not answer is String: return false
	var slots: Array=active.get("slots",["",""])
	if slots.size()!=2: return false
	for slot in slots:
		if not slot is String: return false
	var q: Variant=active.get("question")
	if not q is Dictionary: return false
	for key in ["id","mode","answer","prompt","hint","solution"]:
		if not q.get(key) is String: return false
	if q.mode!=p.mode or not number_in(q.get("topic"),0,7): return false
	for key in ["a","r","n"]:
		if not number_in(q.get(key),-100000,100000): return false
	if not number_in(q.get("time"),0,120): return false
	if not q.get("options") is Array or q.options.size()!=4: return false
	var unique: Array=[]
	for option in q.options:
		if not option is String or option in unique: return false
		unique.append(option)
	if q.answer not in unique: return false
	if int(q.topic)==1 and q.has("targets"):
		for key in ["targets","tiles"]:
			if not q.get(key) is Array or q[key].size()!=(2 if key=="targets" else 4): return false
			for value in q[key]:
				if not value is String: return false
	# Reject a modified/malformed question instead of trusting a saved answer key.
	if int(q.topic)!=7:
		if not question_by_id.has(q.id): return false
		var source: Dictionary=question_by_id[q.id]
		for key in ["mode","answer","prompt","hint","solution","topic","a","r","n","time"]:
			if source[key]!=q[key]: return false
		for key in ["revision","family","answer_sign","trend","givens","hint_steps"]:
			if source.has(key) and source[key]!=q.get(key): return false
		for option in unique:
			if option not in source.options: return false
	return true

func valid_save(value: Variant) -> bool:
	if not value is Dictionary or not value.get("profiles") is Array: return false
	var configuration: Variant=value.get("settings",{})
	if not configuration is Dictionary: return false
	for key in ["master","music","effects"]:
		if not number_in(configuration.get(key,.65),0,1,false): return false
	for key in ["large","reduced"]:
		if not configuration.get(key,false) is bool: return false
	for profile in value.profiles:
		if not valid_profile(profile): return false
	return true

func normalize_profile(p: Dictionary) -> Dictionary:
	var clean: Dictionary=p.duplicate(true)
	clean.done=[]
	for id in p.done:
		if int(id) not in clean.done: clean.done.append(int(id))
	clean.room=int(p.room)
	var saved_rules: int=int(p.get("rules_version",0))
	var limit: int=max_lives(p.mode)
	var old_max: int=limit if saved_rules>=5 else 2 if saved_rules>=4 else 5 if p.mode=="normal" else 3
	# Preserve damage without reviving an exhausted attempt or ending a live legacy save.
	clean.lives=clampi(limit-(old_max-int(p.lives)),1,limit) if int(p.lives)>0 else 0
	clean.rules_version=5
	if clean.mode=="hard" and not clean.active.is_empty():
		clean.active.remaining=minf(float(clean.active.remaining),question_time_limit(clean.active.question))
	clean.balance=p.get("balance",[0,0,0,0]).map(func(n): return int(n))
	clean.introduced_galleries=p.get("introduced_galleries",[0,1,2]).map(func(n): return int(n))
	clean.last_answer_position=int(p.get("last_answer_position",-1))
	if not p.has("last_answer_position") and not p.active.is_empty():
		clean.last_answer_position=p.active.question.options.find(p.active.question.answer)
	for key in ["attempts","correct","hints_used","skipped"]: clean[key]=int(p.get(key,0))
	clean.learning=p.get("learning",{}).duplicate(true)
	clean.draw_state=p.get("draw_state",{}).duplicate(true)
	for draw_key in clean.draw_state:
		var state: Dictionary=clean.draw_state[draw_key]
		for metric in ["sign_streak","trend_streak"]: state[metric]=int(state.get(metric,0))
		var counts: Dictionary=state.get("families",{})
		for family in counts: counts[family]=int(counts[family])
		state.families=counts
	clean.defeats=maxi(int(p.get("defeats",0)),1 if clean.lives<=0 else 0)
	clean.last_defeat_timeout=bool(p.get("last_defeat_timeout",false))
	# An already solved question must not carry the old journey-wide defeat into the next one.
	var completed: bool=str(p.get("phase","world")) in ["success","restoring"]
	var legacy_full_world: bool=saved_rules<5 and str(p.get("phase","world"))=="world" and p.active.is_empty() and not clean.done.is_empty() and int(p.lives)==old_max
	if clean.defeats<2 and (completed or legacy_full_world):
		reset_question_chances(clean)
	return clean

func storage_failure() -> void:
	startup_warning="Não foi possível salvar. Mantenha o jogo aberto e verifique o espaço e o acesso à pasta de progresso."
	if is_instance_valid(save_notice): return
	save_notice=label_at(startup_warning,Rect2(24,2,1230,30),14,Color("ffb3a7"),self)

func save_game() -> void:
	var temporary: String=SAVE+"."+str(OS.get_process_id())+".tmp"
	var file:=FileAccess.open(temporary,FileAccess.WRITE)
	if not file: storage_failure(); return
	file.store_string(JSON.stringify({"version":3,"profiles":profiles,"settings":settings}))
	file.flush()
	var write_error: Error=file.get_error()
	file.close()
	if write_error!=OK: storage_failure(); return
	var path: String=ProjectSettings.globalize_path(SAVE)
	if FileAccess.file_exists(SAVE):
		var old: Variant=read_json(SAVE)
		if valid_save(old) and DirAccess.copy_absolute(path,path+".bak")!=OK: storage_failure(); return
	# Keep the original and backup in place until the replacement is fully written.
	if DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary),path)!=OK: storage_failure(); return
	if OS.has_feature("web"):
		JavaScriptBridge.eval("if(window.paradoxo&&typeof window.paradoxo.setReduced==='function'){window.paradoxo.setReduced("+("true" if settings.reduced else "false")+")}")
	if is_instance_valid(save_notice): save_notice.queue_free(); save_notice=null

func load_save() -> void:
	var ended: Variant=read_json(ENDED_SAVE)
	ended_journeys=[]
	if ended is Array:
		for id in ended:
			if id is String and id not in ended_journeys: ended_journeys.append(id)
	var primary: Variant=read_json(SAVE)
	var backup: Variant=read_json(SAVE+".bak")
	var parsed: Variant=primary
	if not valid_save(parsed):
		parsed=backup
		if valid_save(parsed): startup_warning="O progresso foi recuperado da cópia de segurança."
		else:
			var recovered: Array=[]
			var ids: Array=[]
			for candidate in [primary,backup]:
				if not candidate is Dictionary or not candidate.get("profiles") is Array: continue
				for profile in candidate.profiles:
					if valid_profile(profile) and profile.id not in ids:
						recovered.append(profile); ids.append(profile.id)
			if recovered.is_empty():
				if primary!=null or backup!=null or FileAccess.file_exists(SAVE): startup_warning="O progresso está danificado. Não foi possível recuperar um perfil válido."
				return
			parsed={"profiles":recovered,"settings":{}}
			startup_warning="Os perfis válidos foram recuperados. Dados danificados foram descartados."
	profiles=[]
	for profile in parsed.profiles:
		if str(profile.id) not in ended_journeys: profiles.append(normalize_profile(profile))
	for key in settings:
		if parsed.get("settings",{}).has(key): settings[key]=parsed.settings[key]

func smoke_test() -> void:
	set_process(false)
	var saved_profiles: Array=profiles.duplicate(true)
	var saved_settings: Dictionary=settings.duplicate(true)
	assert(db.size()==4200)
	assert(clean_name(" João ★ 💜 ")=="João ★ 💜")
	assert(clean_name("abcdefghijklmnopqrstu").length()==20)
	assert(clean_name("\n\t ")=="Explorador")
	assert(clean_name("<b>★</b>")=="<b>★</b>")
	for g in ["male","female"]:
		gender=g
		for mode in ["normal","hard"]:
			create_profile("Teste ★",mode); current.tutorial=true
			for m in range(12):
				world(); mission=m; start_question()
				assert(int(question.topic)==TOPICS[m])
				assert(question.mode==mode)
				var before: int=int(current.lives)
				submit(); assert(int(current.lives)==before)
				selected_answer="incorreto" if int(question.topic)==0 else "999999"
				submit(); assert(int(current.lives)==before-1)
				submit(); assert(int(current.lives)==before-1)
				show_hint(); assert(int(current.lives)==before-1)
				selected_answer=question.answer
				submit(); assert(screen=="restoring")
				finish_restore(); assert(m in current.done)
				assert(int(current.lives)==max_lives())
				await get_tree().process_frame
			assert(current.done.size()==12)
			assert(current.seen.size()==12)
			assert(int(current.balance.max())-int(current.balance.min())<=3)
			ending()
	# Continuation must preserve question, order, answer selection, clock and charges.
	create_profile("Persistência ♡","hard"); current.tutorial=true
	world(); start_question()
	var qid: String=question.id
	var order: Array=question.options.duplicate()
	sequence_slots[0]="17"; selected_answer="17"; time_left=42.5; current.lives=2
	update_snapshot(); save_game(); load_save(); current=profiles.back(); resume_profile()
	assert(question.id==qid and question.options==order)
	assert(time_left==42.5 and int(current.lives)==2)
	assert(sequence_slots[0]=="17")
	await get_tree().process_frame
	art.seated=true; pause_game(); _process(5); assert(time_left==42.5)
	close_overlay(); _process(.4); notebook(); var running_time: float=time_left; _process(1); assert(absf(time_left-(running_time-1))<.001)
	close_overlay(); lose_charge(true); assert(screen=="timeout" and int(current.lives)==1)
	update_snapshot(); save_game(); load_save(); current=profiles.back(); resume_profile()
	assert(screen=="timeout" and int(current.lives)==1)
	current.active={}; start_question(); assert(question.id!=qid)
	lose_charge(true); assert(screen=="collapse" and int(current.lives)==0)
	update_snapshot(); save_game(); load_save(); current=profiles.back(); resume_profile()
	assert(screen=="collapse" and int(current.lives)==0)
	current.lives=max_lives(); current.active={}; start_question()
	# Skips retain charges, use unseen questions, and preserve the same mission.
	for mode in ["normal","hard"]:
		create_profile("Pular",mode); current.tutorial=true; world(); start_question()
		var old_id: String=question.id
		var old_lives: int=int(current.lives)
		skip_question()
		assert(question.id!=old_id and current.lives==old_lives and mission==0)
		assert(current.seen.size()==2 and int(question.topic)!=7)
		pause_game(); old_id=question.id; skip_question(); assert(question.id==old_id); close_overlay()
	# Every artwork is reachable through the navigation grid.
	for i in range(4):
		art.hero=Vector2(4.5,5.75); art.approach(i)
		assert(not art.path.is_empty())
		assert(not art.blocked(art.path[-1]))
		art.hero=art.path[-1]; assert(art.near(i))
	# Every work gets unseen random questions, never a fixed answer per work.
	for mode in ["normal","hard"]:
		create_profile("Teste",mode); current.tutorial=true
		for m in range(12):
			mission=m
			for sample in range(5):
				var seen_before: Array=current.seen.duplicate()
				start_question()
				assert(question.id not in seen_before)
				assert(question.options.size()==4)
				assert(question.options.count(question.answer)==1)
	# All twelve visuals are distinct, and each pedestal blocks traversal.
	var kinds: Array=[]
	for wing in art.TYPES:
		for kind in wing: assert(kind not in kinds); kinds.append(kind)
	for wing in range(3):
		art.room=wing
		for i in range(4):
			assert(art.blocked(art.POS[i]))
			for direction in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
				art.hero=art.POS[i]+direction*.95
				assert(not art.blocked(art.hero))
				art.move_safely(art.POS[i]-direction*.95)
				assert(not art.blocked(art.hero))
				assert((art.hero-art.POS[i]).dot(direction)>0)
			art.hero=Vector2(4.5,5.8); art.approach(i)
			assert(not art.path.is_empty())
			for point in art.path:
				art.move_safely(point)
				assert(art.hero.distance_to(point)<.01)
	credits(); var roll_y: float=credit_roll.position.y; _process(1)
	assert(credit_roll.position.y<roll_y)
	art.seated=true; pause_game(); roll_y=credit_roll.position.y; _process(1)
	assert(credit_roll.position.y==roll_y); toggle_credits_pause()
	mission=0; world(); start_question()
	# Exhausted banks require consent instead of silently resetting history.
	current.seen=[]
	for q in db:
		if q.mode==current.mode and int(q.topic)==TOPICS[mission]: current.seen.append(q.id)
	start_question(); assert(is_instance_valid(overlay)); close_overlay()
	profiles=saved_profiles; settings=saved_settings; screen="menu"; current={}; save_game()
	audio.stop_all()
	print("PASS V2: 48 missions. 2 genders. 2 modes. empty/wrong/duplicate/correct. hints. balanced shuffle. persisted order/slots/time/lives. pause. notebook. timeout. collapse. 4 navigation routes. bank exhaustion. Unicode.")
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().quit()

func capture() -> void:
	var saved_profiles: Array=profiles.duplicate(true)
	await get_tree().create_timer(1.5).timeout
	await shot("menu")
	gender="female"; new_game(); await shot("personagens")
	gender="male"; new_game(); await shot("personagem-masculino")
	gender="female"; create_profile("Luna ★","normal"); current.tutorial=true
	intro(); await shot("prologo")
	tutorial(); await shot("tutorial")
	tutorial_controls(); await shot("controles")
	settings.large=true
	intro(); await shot("prologo-ampliado")
	tutorial_controls(); await shot("controles-ampliados")
	settings.large=false
	world(); await shot("galeria")
	notebook(); await shot("formulas"); close_overlay()
	profile_menu(); await shot("jornadas"); world(true)
	art.hero=art.POS[0]+Vector2(0,1); mission=0; start_question(); await shot("restauracao")
	selected_answer=question.answer; submit()
	await get_tree().create_timer(.9).timeout
	await shot("efeito")
	finish_restore(); view_restored(mission); await shot("obra-em-destaque"); close_overlay(); world(true); await shot("obra-restaurada")
	current.done=[0,1,2,3]; gender="male"; current.gender=gender; mission=4; room=1
	world(); await shot("historia-natural")
	current.done=[0,1,2,3,4,5,6,7]; mission=8; room=2
	world(); await shot("invencoes")
	mission=8; start_question(); await shot("mecanismo")
	mission=3; start_question(); await shot("retrato")
	mission=11; start_question(); await shot("coracao")
	pause_game(); await shot("pausa"); close_overlay()
	current.done=range(12); ending(); await shot("final")
	credits(); credit_roll.position.y=-120; await shot("creditos")
	credit_roll.position.y=-600; await shot("equipe")
	settings.reduced=true; credits(); await shot("creditos-estaticos"); settings.reduced=false
	profiles=saved_profiles; screen="menu"; current={}; save_game(); audio.stop_all()
	await get_tree().create_timer(.2).timeout
	get_tree().quit()

func shot(filename: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png("res://../v2-"+filename+".png")

func audio_test() -> void:
	await get_tree().create_timer(.4).timeout
	assert(audio.players[audio.current_player].playing)
	audio.cue("restore")
	audio.paused=true
	await get_tree().create_timer(.1).timeout
	var position: float=audio.players[audio.current_player].get_playback_position()
	await get_tree().create_timer(.3).timeout
	assert(audio.effect.stream_paused)
	for player in audio.players:
		if player.stream != null: assert(player.stream_paused)
	assert(absf(audio.players[audio.current_player].get_playback_position()-position)<.02)
	audio.paused=false
	await get_tree().create_timer(.3).timeout
	assert(audio.players[audio.current_player].get_playback_position()>position)
	print("PASS: startup music, paused music/effects, frozen playback position and resumed playback.")
	set_process(false)
	audio.stop_all()
	await get_tree().create_timer(.35).timeout
	audio.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().quit()

func settings_back() -> void:
	if banked_pause: returning_to_pause=false; show_pause_menu(); return
	close_overlay()
	if screen=="credits": credits()
	if returning_to_pause: returning_to_pause=false; pause_game()

func explore_completed() -> void:
	current.tour=true; current.active={}; enter_gallery(0)

func record_learning(metric: String) -> void:
	if question.is_empty(): return
	var learning: Dictionary=current.get("learning",{})
	var key: String=str(int(question.topic))
	var entry: Dictionary=learning.get(key,{})
	entry[metric]=int(entry.get(metric,0))+1
	learning[key]=entry; current.learning=learning

func learning_summary() -> void:
	if current.is_empty(): return
	learning_book=false; overlay_kind="learning"
	make_overlay()
	overlay.set_meta("learning_dashboard",true)
	var frame: Rect2=Rect2(20,12,920,516) if mobile_layout else Rect2(130,45,1020,710)
	var inset: float=24 if mobile_layout else 40
	panel(frame,overlay)
	label_at("Meu aprendizado",Rect2(frame.position+Vector2(inset,18),Vector2(frame.size.x-inset*2,48)),30,GOLD,overlay)
	label_at("Cada tentativa ajuda a entender os padrões.",Rect2(frame.position+Vector2(inset,70),Vector2(frame.size.x-inset*2,38)),18,MUTED,overlay)
	learning_scroll=ScrollContainer.new()
	learning_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	place(learning_scroll,Rect2(frame.position+Vector2(inset,116),Vector2(frame.size.x-inset*2,frame.size.y-212)),overlay)
	var content:=VBoxContainer.new(); content.add_theme_constant_override("separation",20)
	padded_scroll_content(learning_scroll,content)
	var learning: Dictionary=current.get("learning",{})
	var correct_count: int=0
	for row in learning.values(): correct_count+=int(row.get("sem_ajuda",0))+int(row.get("com_ajuda",0))
	var summary:=GridContainer.new(); summary.columns=3; summary.add_theme_constant_override("h_separation",16); content.add_child(summary)
	for i in range(3):
		var tile:=PanelContainer.new(); tile.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		tile.add_theme_stylebox_override("panel",style(Color("17323f"))); summary.add_child(tile)
		var stack:=VBoxContainer.new(); tile.add_child(stack)
		var value:=Label.new(); value.text=str([current.done.size(),correct_count,int(current.hints_used)][i])
		value.add_theme_font_size_override("font_size",30); value.add_theme_color_override("font_color",TEAL); stack.add_child(value)
		var caption:=Label.new(); caption.text=["Obras restauradas","Respostas corretas","Dicas consultadas"][i]
		caption.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; caption.add_theme_font_size_override("font_size",16); stack.add_child(caption)
	var titles: Array=["Reconhecer e classificar","Completar sequências","Razão","Termo geral","Primeiro termo","Posição e quantidade","Soma"]
	var best: int=-1; var best_count: int=0; var review: int=-1; var review_count: int=0
	for i in range(7):
		var row: Dictionary=learning.get(str(i),{})
		var hits: int=int(row.get("sem_ajuda",0))+int(row.get("com_ajuda",0))
		var misses: int=int(row.get("erros",0))+int(row.get("tempo_esgotado",0))
		if hits>best_count: best=i; best_count=hits
		if misses>review_count: review=i; review_count=misses
	var note: String="Os resultados aparecerão aqui conforme você resolver os desafios. Usar ajuda também faz parte de aprender."
	if best>=0: note="Você teve mais acertos em %s." % str(titles[best]).to_lower()
	if review>=0: note+=" Vale revisar %s no Caderno de Tico." % str(titles[review]).to_lower()
	var insight:=Label.new(); insight.text=note; insight.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	insight.horizontal_alignment=HORIZONTAL_ALIGNMENT_FILL
	insight.justification_flags=TextServer.JUSTIFICATION_WORD_BOUND | TextServer.JUSTIFICATION_SKIP_LAST_LINE
	insight.add_theme_font_size_override("font_size",19); content.add_child(insight)
	var grid:=GridContainer.new(); grid.columns=1 if mobile_layout else 2
	grid.add_theme_constant_override("h_separation",18); grid.add_theme_constant_override("v_separation",18); content.add_child(grid)
	for i in range(7):
		var card:=PanelContainer.new(); card.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		card.custom_minimum_size=Vector2(0,252); card.add_theme_stylebox_override("panel",style(Color("142c39"))); grid.add_child(card)
		var stack:=VBoxContainer.new(); stack.add_theme_constant_override("separation",12); card.add_child(stack)
		var heading:=Label.new(); heading.text=str(titles[i]); heading.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		heading.add_theme_font_size_override("font_size",22+(2 if settings.large else 0)); heading.add_theme_color_override("font_color",GOLD); stack.add_child(heading)
		var row: Dictionary=learning.get(str(i),{})
		var metrics: Array=["sem_ajuda","com_ajuda","erros","puladas","tempo_esgotado"]
		var captions: Array=["Acertos sem ajuda","Acertos com ajuda","Erros","Questões puladas","Tempo esgotado"]
		for j in range(metrics.size()):
			var metric:=HBoxContainer.new(); stack.add_child(metric)
			var caption:=Label.new(); caption.text=captions[j]; caption.size_flags_horizontal=Control.SIZE_EXPAND_FILL
			caption.add_theme_font_size_override("font_size",18+(2 if settings.large else 0)); metric.add_child(caption)
			var value:=Label.new(); value.text=str(int(row.get(metrics[j],0))); value.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
			value.add_theme_font_size_override("font_size",18+(2 if settings.large else 0)); value.add_theme_color_override("font_color",TEAL); metric.add_child(value)
	var footer_y: float=frame.end.y-76
	button("Voltar",Rect2(frame.position.x+inset,footer_y,180 if mobile_layout else 200,56),close_overlay,false,overlay)
	button("Revisar no Caderno de Tico",Rect2(frame.position.x+inset+(200 if mobile_layout else 240),footer_y,frame.size.x-inset*2-(200 if mobile_layout else 240),56),open_learning_notebook,true,overlay)
	overlay.set_meta("mobile_laid_out",true)
	learning_scroll.grab_focus()
	learning_scroll.set_deferred("scroll_vertical",learning_scroll_position)

func open_learning_notebook() -> void:
	learning_scroll_position=learning_scroll.scroll_vertical
	notebook(); learning_book=true

func select_answer(value: String) -> void:
	if paused or answered: return
	selected_answer=value; refresh_answer_selection(); update_snapshot(); save_game()
	if is_instance_valid(status): status.text="Resposta selecionada. Confirme para verificar."

func refresh_answer_selection() -> void:
	for choice in answer_buttons:
		var chosen: bool=str(choice.get_meta("answer"))==selected_answer
		choice.text=("✓ " if chosen else "")+str(choice.get_meta("answer"))
		choice.add_theme_stylebox_override("normal",style(Color("315a60") if chosen else Color("1d3849"),TEAL if chosen else Color("426071")))

func confirm_delete(id: String) -> void:
	var name_text: String=""
	for profile in profiles:
		if profile.id==id: name_text=profile.name
	info("Excluir jornada?","Excluir a jornada de %s? Apenas esse progresso será apagado. Esta ação não pode ser desfeita." % name_text,func(): delete_profile(id),"Excluir jornada")

func delete_profile(id: String) -> void:
	profiles=profiles.filter(func(profile): return profile.id!=id)
	if current.get("id","")==id: current={}; question={}
	save_game(); save_game()
	close_overlay(); profile_menu()

func toggle_fullscreen() -> void:
	var mode: int=DisplayServer.window_get_mode()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if mode==DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)

func shutdown() -> void:
	if closing: return
	closing=true; set_process(false)
	audio.stop_all()
	await get_tree().create_timer(.35).timeout
	get_tree().quit()
