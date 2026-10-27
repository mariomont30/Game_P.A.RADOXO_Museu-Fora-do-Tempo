extends Control
## Hand-painted-style isometric museum. Every polygon remains 2D.
signal reached_exhibit(index: int)
signal footstep

const GOLD = Color("dcb67a")
const JADE = Color("80d6bd")
const POS = [Vector2(2,1.6),Vector2(7,1.6),Vector2(2,5.4),Vector2(7.4,4.9)]
const PLANTS = [Vector2(.8,3.4),Vector2(8.2,3.4)]
const BENCH_CENTER = Vector2(4.5,3.6)
const RUG_BOUNDS = Rect2(3,1,3,5)
const BENCH_EXIT = Vector2(4.5,4.75)
const MENU_SEATS = [Vector2(4.95,3.78),Vector2(4.05,3.78)]
const TYPES = [["painting","statue","mosaic","portrait"],["dinosaur","crystal","fossil","vitrine"],["clock","orrery","machine","time_core"]]
var show_pair: bool=false
var seated: bool=false
var rise_progress: float=0.0
var bench_pending: bool=false
var bench_hovered: bool=false
var gaze: Array[float]=[0.0,0.0]
var greetings: Array[float]=[0.0,0.0]
var pointer := Vector2(640,400)
var hovered: int=-1
var room: int = 0
var restored: Array = []
var gender: String = "female"
var hero := Vector2(4.5,5.8)
var facing: float = 1
var moving: bool = false
var frozen: bool = false
var reduced: bool = false
var menu_mode: bool = true
var preview: bool = false
var presentation_rect:=Rect2()
var active: int = 0
var time: float = 0
var walk_time: float = 0
var movement := Vector2.ZERO
var path: PackedVector2Array = []
var pending: int = -1
var nav := AStarGrid2D.new()
var camera := Vector2.ZERO
var restore_index: int = -1
var restore_time: float = 0
var collapse_time: float = 0
var defeat_active: bool=false
var defeat_amount: float=0.0
var celebration: float = 0
var step_time: float = 0
var view_scale: float = 0.94
var origin := Vector2(610,238)
var font: Font

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	font=get_theme_default_font()
	nav.region=Rect2i(0,0,37,29)
	nav.cell_size=Vector2(.25,.25)
	nav.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	nav.update()
	for x in range(37):
		for y in range(29):
			nav.set_point_solid(Vector2i(x,y),blocked(Vector2(x,y)*.25))

func blocked(p: Vector2) -> bool:
	if p.x<.5 or p.y<.5 or p.x>8.5 or p.y>6.5: return true
	for spot in POS:
		if absf(p.x-spot.x)<.74 and absf(p.y-spot.y)<.66: return true
	if Rect2(3.38,3.10,2.24,1.02).has_point(p): return true
	for plant_pos in PLANTS:
		if p.distance_to(plant_pos)<.55: return true
	return false

func iso(p: Vector2, z: float=0) -> Vector2:
	return Vector2((p.x-p.y)*63,(p.x+p.y)*31.5-z)

func screen_point(p: Vector2,z: float=0) -> Vector2:
	return origin+(Vector2.ZERO if presentation_rect.has_area() else camera)+iso(p,z)*view_scale

func ground_point(p: Vector2) -> Vector2:
	var v: Vector2=(p-origin-(Vector2.ZERO if presentation_rect.has_area() else camera))/view_scale
	return Vector2((v.x/63+v.y/31.5)/2,(v.y/31.5-v.x/63)/2)

func approach(index: int) -> void:
	stand_up(); bench_pending=false
	var goal: Vector2=POS[index]+Vector2(0,1.0)
	var start := navigation_start()
	var end := Vector2i(roundi(goal.x*4),roundi(goal.y*4))
	path=nav.get_point_path(start,end)
	pending=index
	if path.is_empty(): pending=-1

func walk_to(point: Vector2) -> void:
	stand_up(); bench_pending=false
	var target := Vector2i(roundi(point.x*4),roundi(point.y*4))
	if not nav.is_in_boundsv(target) or nav.is_point_solid(target): return
	path=nav.get_point_path(navigation_start(),target)
	pending=-1

func near(index: int) -> bool:
	return hero.distance_to(POS[index])<1.65

func navigation_start() -> Vector2i:
	var closest:=Vector2i(roundi(hero.x*4),roundi(hero.y*4))
	var distance: float=INF
	for x in range(37):
		for y in range(29):
			var cell:=Vector2i(x,y)
			if nav.is_point_solid(cell): continue
			var d: float=hero.distance_to(Vector2(cell)*.25)
			if d<distance and (blocked(hero) or clear_segment(hero,Vector2(cell)*.25)): closest=cell; distance=d
	# Older saves may place the feet inside the newly enlarged collision margin.
	if blocked(hero): hero=Vector2(closest)*.25
	return closest

func restore(index: int) -> void:
	restore_index=index
	restore_time=2.2 if not reduced else .2
	celebration=3

func _process(delta: float) -> void:
	if frozen:
		queue_redraw()
		return
	if not reduced: time+=delta*(-3 if collapse_time>0 else 1)
	collapse_time=maxf(0,collapse_time-delta)
	celebration=maxf(0,celebration-delta)
	if restore_time>0:
		restore_time=maxf(0,restore_time-delta)
		if restore_time==0:
			var id: int=room*4+restore_index
			if id not in restored: restored.append(id)
	moving=false
	if not menu_mode and restore_time<=0 and collapse_time<=0:
		if seated and movement.length()>.1: stand_up()
		if movement.length()>.1:
			path=[]; pending=-1; bench_pending=false
			var v := Vector2(movement.x/2+movement.y,movement.y-movement.x/2).normalized()*delta*2.5
			var next: Vector2=hero+Vector2(v.x,0)
			move_safely(next)
			next=hero+Vector2(0,v.y)
			move_safely(next)
			moving=true
			if absf(movement.x)>.1: facing=signf(movement.x)
		elif not path.is_empty():
			var d: Vector2=path[0]-hero
			if d.length()<delta*2.4:
				move_safely(path[0]); path.remove_at(0)
			else:
				move_safely(hero+d.normalized()*delta*2.4)
				facing=1 if d.x-d.y>=0 else -1
			moving=true
			if path.is_empty() and pending>=0:
				var id: int=pending
				pending=-1
				reached_exhibit.emit(id)
	if bench_pending and path.is_empty() and not menu_mode:
		bench_pending=false; seated=true; hero=BENCH_EXIT; moving=false
	if show_pair:
		for i in range(2):
			var head:=screen_point(MENU_SEATS[i],61)
			var target: float=clampf((pointer.x-head.x)/55.0,-1,1)
			gaze[i]=lerpf(gaze[i],target,minf(1,delta*7)) if not reduced else 0.0
			greetings[i]=maxf(0,greetings[i]-delta)
	if moving:
		walk_time+=delta*9
		step_time+=delta
		if step_time>.32:
			step_time=0; footstep.emit()
	else: walk_time=0
	var target_cam: Vector2=-iso(hero-Vector2(4.5,3.8))*.025
	if menu_mode:
		var mouse: Vector2=(pointer-Vector2(640,400))/Vector2(640,400)
		target_cam=Vector2(sin(time*.32)*9,cos(time*.41)*5)+mouse.clamp(Vector2(-1,-1),Vector2.ONE)*6
	camera=camera.lerp(target_cam,1-exp(-delta*3)) if not reduced else Vector2.ZERO
	queue_redraw()

func poly(points: Array, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points),color)

func line(a: Vector2,b: Vector2,color: Color,width: float=1) -> void:
	draw_line(a,b,color,width,true)

func ellipse(p: Vector2,rx: float,ry: float,c: Color) -> void:
	var pts: Array=[]
	for i in range(40): pts.append(p+Vector2(cos(TAU*i/40)*rx,sin(TAU*i/40)*ry))
	poly(pts,c)

func block(p: Vector2,sz: Vector2,h: float,top: Color,z: float=0) -> void:
	var a:=iso(p,z+h); var b:=iso(p+Vector2(sz.x,0),z+h)
	var c:=iso(p+sz,z+h); var d:=iso(p+Vector2(0,sz.y),z+h)
	poly([d,c,c+Vector2(0,h),d+Vector2(0,h)],top.darkened(.28))
	poly([b,c,c+Vector2(0,h),b+Vector2(0,h)],top.darkened(.46))
	poly([a,b,c,d],top)
	line(a,b,top.lightened(.12)); line(a,d,top.lightened(.16))

func text(p: Vector2,s: String,n: int,c: Color) -> void:
	draw_string(font,p,s,HORIZONTAL_ALIGNMENT_LEFT,-1,n,c)

func _draw() -> void:
	draw_rect(Rect2(0,0,1280,800),Color("101d2c"))
	for i in range(12):
		draw_circle(Vector2(830,400),640-i*40,Color(.14,.27,.30,.015))
	for i in range(36):
		draw_circle(Vector2(fmod(i*137.4+sin(time*.3+i)*9,1280),fmod(i*67.2+time*2,800)),1+(i%2),Color(.65,.8,.73,.14))
	view_scale=.65 if menu_mode else .72
	origin=Vector2(860,278) if menu_mode else Vector2(620,306)
	var offset: Vector2=camera
	if presentation_rect.has_area():
		var bounds:=Rect2(-480,-180,1100,800)
		view_scale=minf(presentation_rect.size.x/bounds.size.x,presentation_rect.size.y/bounds.size.y)
		origin=presentation_rect.get_center()-bounds.get_center()*view_scale
		offset=Vector2.ZERO
	if defeat_active and not reduced:
		view_scale*=1.0+.035*defeat_amount
	draw_set_transform(origin+offset,0,Vector2.ONE*view_scale)
	# Floating architectural plinth, shadows, tile seams and real-looking thickness.
	ellipse(iso(Vector2(4.5,3.5))+Vector2(0,48),520,240,Color(0,0,0,.15))
	block(Vector2(-.2,-.2),Vector2(9.4,7.4),32,Color("243b48"),-32)
	var palettes := [[Color("d4c9af"),Color("c8bea8"),Color("507c7a")],[Color("bbc8b1"),Color("a8bba5"),Color("435f54")],[Color("b9c2d1"),Color("abb6c8"),Color("5a6482")]]
	var palette: Array=palettes[room]
	for x in range(9):
		for y in range(7):
			var p:=Vector2(x,y)
			var col: Color=palette[(x+y)%2]
			if x==0 or y==0 or x==8 or y==6: col=palette[2]
			poly([iso(p),iso(p+Vector2(.98,0)),iso(p+Vector2(.98,.98)),iso(p+Vector2(0,.98))],col)
	# Carpet runner and stitched border.
	var rug: Color=[Color("a65750"),Color("53796c"),Color("635880")][room]
	var carpet: Rect2=RUG_BOUNDS.grow(-.02)
	poly([iso(carpet.position),iso(Vector2(carpet.end.x,carpet.position.y)),iso(carpet.end),iso(Vector2(carpet.position.x,carpet.end.y))],rug)
	var stitch: Rect2=RUG_BOUNDS.grow(-.10)
	var corners: Array=[stitch.position,Vector2(stitch.end.x,stitch.position.y),stitch.end,Vector2(stitch.position.x,stitch.end.y)]
	for i in range(4): line(iso(corners[i]),iso(corners[(i+1)%4]),GOLD,2)
	# Two tall back walls create the 3D impression without a 3D engine.
	poly([iso(Vector2.ZERO),iso(Vector2(9,0)),iso(Vector2(9,0),155),iso(Vector2.ZERO,155)],Color("35535b") if room!=2 else Color("444660"))
	poly([iso(Vector2.ZERO),iso(Vector2(0,7)),iso(Vector2(0,7),155),iso(Vector2.ZERO,155)],Color("28444f") if room!=2 else Color("333b53"))
	line(iso(Vector2.ZERO,155),iso(Vector2(9,0),155),GOLD,5)
	line(iso(Vector2.ZERO,155),iso(Vector2(0,7),155),GOLD,5)
	for axis in range(2):
		for i in range(1,9 if axis==0 else 7,2):
			var p:=Vector2(i,0) if axis==0 else Vector2(0,i)
			wall_window(p,axis)
	for p in [Vector2(0,0),Vector2(9,0),Vector2(0,7)]:
		block(p-Vector2(.14,.14),Vector2(.28,.28),157,Color("a9ac9b"))
		block(p-Vector2(.21,.21),Vector2(.42,.42),8,GOLD,150)
	# Every floor object participates in the same depth sort as the player.
	var order: Array=[]
	for i in range(4): order.append({"depth":POS[i].x+POS[i].y,"index":i})
	order.append({"depth":8.65 if show_pair or seated else hero.x+hero.y,"index":4})
	if show_pair: order.append({"depth":8.55,"index":5})
	for i in range(PLANTS.size()): order.append({"depth":PLANTS[i].x+PLANTS[i].y,"index":6+i})
	order.append({"depth":8.1,"index":8})
	order.sort_custom(func(a,b): return a.depth<b.depth)
	for e in order:
		if e.index==4:
			if show_pair: draw_person("female",MENU_SEATS[0],true,gaze[0],greetings[0])
			else: draw_person(gender,Vector2(4.5,3.78).lerp(BENCH_EXIT,rise_progress) if seated else hero,seated and rise_progress<.6)
		elif e.index==5: draw_person("male",MENU_SEATS[1],true,gaze[1],greetings[1])
		elif e.index in [6,7]: plant(PLANTS[int(e.index)-6])
		elif e.index==8: bench()
		else: exhibit(int(e.index))
	# Little floating clock companion.
	if not menu_mode:
		var tico:=iso(Vector2(4.5,3.78).lerp(BENCH_EXIT,rise_progress) if seated else hero)+Vector2(35,-62+sin(time*2.2)*4)
		clock(tico+Vector2(0,8*defeat_amount),13,Color("f2cc83").lerp(Color("8a909b"),defeat_amount),not defeat_active)
	if menu_mode and hovered>=0:
		var base: Vector2=iso(POS[hovered],4)
		draw_arc(base,57,0,TAU,48,Color(.54,.86,.76,.75),2,true)
	if not menu_mode and not preview:
		for i in range(4):
			var done: bool=room*4+i in restored
			if i==hovered:
				var edge: Array=[Vector2(-.75,-.65),Vector2(.75,-.65),Vector2(.75,.65),Vector2(-.75,.65)]
				for side in range(4): line(iso(POS[i]+edge[side],2),iso(POS[i]+edge[(side+1)%4],2),JADE,3)
			var p:=iso(POS[i],125)
			if i==active and not done:
				ellipse(p,17,17,Color("f5df9a"))
				text(p+Vector2(-4,6),"!",20,Color("263b45"))
			elif done:
				ellipse(p,12,12,Color("6ccbb0"))
				text(p+Vector2(-7,5),"✓",17,Color("183d36"))
	if not path.is_empty() and not menu_mode:
		var goal: Vector2=iso(path[-1])
		draw_arc(goal,9,0,TAU,30,Color(.95,.85,.6,.65),2,true)
	draw_set_transform(Vector2.ZERO)
	if menu_mode:
		for i in range(50): draw_rect(Rect2(i*13,0,14,800),Color(.035,.07,.105,clampf(1-float(i)/50,0,1)))

func wall_window(p: Vector2,axis: int) -> void:
	var v:=Vector2(.8,0) if axis==0 else Vector2(0,.8)
	var a:=iso(p-v*.5,35); var b:=iso(p+v*.5,35)
	poly([a,b,b-Vector2(0,91),a-Vector2(0,91)],Color("16313f"))
	line(a,b,GOLD,2); line(a,a-Vector2(0,91),GOLD,2); line(b,b-Vector2(0,91),GOLD,2)
	line(a-Vector2(0,91),b-Vector2(0,91),GOLD,2)
	for h in [32,61]: line(a-Vector2(0,h),b-Vector2(0,h),Color("799692"),1)
	var mid: Vector2=(a+b)/2
	line(mid,mid-Vector2(0,91),Color("799692"),2)
	poly([a-Vector2(0,35),b-Vector2(0,35),b+Vector2(55,70),a+Vector2(55,70)],Color(.95,.85,.56,.035))

func plant(p: Vector2) -> void:
	var at:=iso(p)
	ellipse(at+Vector2(3,4),25,9,Color(0,0,0,.19))
	var top:=at-Vector2(0,27)
	poly([top+Vector2(-18,0),top+Vector2(18,0),at+Vector2(13,-1),at+Vector2(-13,-1)],Color("c99872"))
	poly([top,top+Vector2(18,0),at+Vector2(13,-1),at+Vector2(0,4)],Color("987051"))
	ellipse(at-Vector2(0,1),13,5,Color("af805d"))
	ellipse(top,19,7,Color("e1bb8b"))
	ellipse(top,14,4.6,Color("4c4437"))
	line(at+Vector2(-13,-10),at+Vector2(12,-10),Color("e7c88e"),1.5)
	var sway: float=0 if reduced else sin(time*.85+p.x)*1.5
	for i in range(7):
		var base:=top+Vector2(0,-2)
		var tip:=base+Vector2(cos(i*2.4)*19+sway,-10-absf(sin(i*1.6))*22)
		line(base,tip,Color("829c6c"),2)
		ellipse(tip,7,10,Color("9ab77e") if i%2 else Color("527e68"))
		line(tip+Vector2(0,5),tip-Vector2(0,6),Color("bbcb95"),.8)

func bench() -> void:
	var p:=BENCH_CENTER-Vector2(.9,.25)
	ellipse(iso(BENCH_CENTER)+Vector2(4,9),76,22,Color(0,0,0,.18))
	# Rounded-looking walnut slats, cushioned seat and brass-framed backrest.
	for x in [p.x+.12,p.x+1.55]:
		block(Vector2(x,p.y+.05),Vector2(.13,.40),18,Color("334f59"))
		block(Vector2(x-.02,p.y+.04),Vector2(.18,.44),3,GOLD)
	block(p,Vector2(1.8,.5),4,Color("9f6c4f"),16)
	for i in range(4): block(p+Vector2(.02,.025+i*.115),Vector2(1.76,.095),2,Color("bb8861"),20)
	block(p+Vector2(.13,.12),Vector2(1.54,.28),3,[Color("4f807b"),Color("688367"),Color("776c97")][room],22)
	for x in [p.x+.08,p.x+1.6]: block(Vector2(x,p.y),Vector2(.10,.10),46,Color("405763"))
	for h in [31,40]: block(p+Vector2(.04,.015),Vector2(1.72,.09),6,Color("a87654"),h)
	for x in [p.x+.04,p.x+1.68]:
		line(iso(Vector2(x,p.y+.02),31),iso(Vector2(x,p.y+.48),31),GOLD,3)
	if bench_hovered:
		var corners: Array=[Vector2(-1.05,-.4),Vector2(1.05,-.4),Vector2(1.05,.65),Vector2(-1.05,.65)]
		for i in range(4): line(iso(BENCH_CENTER+corners[i],2),iso(BENCH_CENTER+corners[(i+1)%4],2),JADE,2)

func draw_person(character_gender: String,point: Vector2,sit: bool,look: float=0.0,greeting: float=0.0) -> void:
	var previous_gender: String=gender
	var previous_facing: float=facing
	gender=character_gender
	if show_pair: facing=look
	avatar(iso(point),1.0,sit,look,greeting)
	gender=previous_gender; facing=previous_facing

func stand_up() -> void:
	if seated: hero=BENCH_EXIT
	seated=false; bench_pending=false; rise_progress=0

func use_bench() -> void:
	if seated: stand_up(); return
	if bench_pending: return
	path=nav.get_point_path(navigation_start(),Vector2i(18,19))
	pending=-1; bench_pending=not path.is_empty()

func hit_bench(point: Vector2) -> bool:
	return Rect2(screen_point(BENCH_CENTER,62)-Vector2(80,0)*view_scale,Vector2(160,100)*view_scale).has_point(point)

func menu_character_at(point: Vector2) -> int:
	if not show_pair: return -1
	for i in range(2):
		if point.distance_to(screen_point(MENU_SEATS[i],48))<27*view_scale: return i
	return -1

func exhibit(index: int) -> void:
	var p: Vector2=POS[index]
	var done: bool=room*4+index in restored
	var progress: float=1 if done else clampf(1-restore_time/2.2,0,1) if index==restore_index and restore_time>0 else 0
	var base:=iso(p)
	ellipse(base+Vector2(15,11),62,26,Color(0,0,0,.13))
	block(p-Vector2(.48,.4),Vector2(.96,.8),26,Color("acb8b0"))
	block(p-Vector2(.52,.44),Vector2(1.04,.88),5,Color("e0d8bc"),26)
	var at: Vector2=base-Vector2(0,32)
	var kind: String=TYPES[room][index]
	match kind:
		"painting": painting(at,progress,index)
		"portrait": portrait(at,progress)
		"time_core": time_core(at,progress)
		"statue": statue(at,progress)
		"mosaic": mosaic(at,progress)
		"dinosaur": dinosaur(at,progress)
		"crystal": crystal(at,progress)
		"fossil": fossil(at,progress)
		"vitrine": vitrine(at,progress)
		"clock": clock(at-Vector2(0,36),36,GOLD,progress>.5)
		"orrery": orrery(at,progress)
		"machine": machine(at,progress)
	if progress==0:
		line(at+Vector2(-16,-15),at+Vector2(3,-42),Color("b1e3d3"),1)
		line(at+Vector2(3,-42),at+Vector2(-1,-64),Color("b1e3d3"),1)
		for j in range(3):
			var f:=at+Vector2(cos(time+j*2)*30,-20-sin(time*.7+j)*20)
			poly([f,f+Vector2(5,-8),f+Vector2(10,1)],Color(.6,.85,.8,.45))
	if index==restore_index and restore_time>0 and not reduced:
		for j in range(30):
			var angle: float=j*2.4+time
			var q:=at+Vector2(cos(angle)*80,sin(angle)*60)*restore_time/2.2-Vector2(0,25)
			draw_circle(q,2.5,Color("ffe5a6"))
	# Plaque mounted on the front face.
	var plate: Vector2=base+Vector2(4,4)
	draw_rect(Rect2(plate-Vector2(14,4),Vector2(28,9)),GOLD)
	text(plate+Vector2(-8,3),"%02d" % (room*4+index+1),8,Color("34464a"))

func painting(p: Vector2,progress: float,index: int) -> void:
	# Freestanding gilt frame, perspective edges and a mountain composition.
	poly([p+Vector2(-46,-89),p+Vector2(42,-77),p+Vector2(42,0),p+Vector2(-46,-12)],Color("87603c"))
	poly([p+Vector2(-42,-93),p+Vector2(46,-81),p+Vector2(46,-4),p+Vector2(-42,-16)],GOLD)
	poly([p+Vector2(-35,-85),p+Vector2(39,-75),p+Vector2(39,-12),p+Vector2(-35,-22)],Color("7fa99e") if progress>.8 else Color("4b6b70"))
	var sun:=p+Vector2(17,-61)
	draw_circle(sun,10,Color("f6d48c"))
	poly([p+Vector2(-33,-23),p+Vector2(-9,-63),p+Vector2(10,-21)],Color("356b69"))
	poly([p+Vector2(-5,-19),p+Vector2(15,-49),p+Vector2(37,-13)],Color("548c78"))
	if progress<1:
		for j in range(3):
			var off:=Vector2(j*24,-j*3)
			poly([p+Vector2(-34,-81)+off,p+Vector2(-17,-77)+off,p+Vector2(-18,-27)+off],Color(.12,.21,.25,(1-progress)*.95))
	else:
		var bird:=p+Vector2(sin(time*.3+index)*14,-67)
		line(bird+Vector2(-4,0),bird+Vector2(0,2),Color("f8ecd3")); line(bird+Vector2(0,2),bird+Vector2(4,0),Color("f8ecd3"))

func statue(p: Vector2,progress: float) -> void:
	var marble:=Color("dce1ce")
	var offset: float=(1-progress)*14
	poly([p+Vector2(-24,-1),p+Vector2(-16,-47),p+Vector2(10,-50),p+Vector2(22,-1)],marble.darkened(.18))
	poly([p+Vector2(-16,-47),p+Vector2(-2,-51),p+Vector2(4,-3),p+Vector2(-24,-1)],marble)
	draw_circle(p+Vector2(-3+offset,-66-offset),15,marble)
	draw_arc(p+Vector2(-3+offset,-69-offset),15,PI,TAU,20,Color("b7c1ac"),6,true)
	line(p+Vector2(10,-41),p+Vector2(27+offset,-21-offset),marble,9)
	line(p+Vector2(-14,-41),p+Vector2(-29-offset,-21-offset),marble.darkened(.1),9)
	for j in range(3): line(p+Vector2(-12+j*9,-30),p+Vector2(-17+j*12,-5),Color("b1bda8"),1)

func mosaic(p: Vector2,progress: float) -> void:
	for x in range(5):
		for y in range(4):
			var a:=p+Vector2((x-y)*12,(x+y)*6-52)
			var missing: bool=(x+y)%3==0 and progress<.9
			var col: Color=[Color("6a9990"),Color("ecc68d"),Color("bf7463")][(x+y)%3]
			poly([a,a+Vector2(11,5),a+Vector2(0,11),a+Vector2(-11,5)],Color("3c5661") if missing else col)

func dinosaur(p: Vector2,progress: float) -> void:
	var bone:=Color("e6d8b2")
	var points: Array=[p+Vector2(-63,-23),p+Vector2(-31,-38),p+Vector2(0,-42),p+Vector2(24,-51),p+Vector2(31,-85),p+Vector2(49,-91)]
	for i in range(points.size()-1):
		if progress<.5 and i in [1,3]: continue
		line(points[i],points[i+1],bone,5)
	for i in range(6):
		var base:=p+Vector2(-25+i*9,-40-i)
		if progress<.9 and i%3==0: continue
		draw_arc(base,16,0,PI*.85,12,bone,3,true)
	for x in [-16,18]:
		line(p+Vector2(x,-33),p+Vector2(x-6,-7),bone,5)
		line(p+Vector2(x-6,-7),p+Vector2(x+5,-4),bone,4)
	ellipse(p+Vector2(48,-91),15,9,bone)
	draw_circle(p+Vector2(51,-94),2,Color("566365"))
	if progress==1: line(p+Vector2(58,-88),p+Vector2(65,-87+sin(time)*2),bone,2)

func crystal(p: Vector2,progress: float) -> void:
	for i in range(5):
		var a:=p+Vector2((i-2)*14,abs(i-2)*-3)
		var h: float=30+(2-abs(i-2))*17
		if progress<.7 and i%2==0: h*=.4
		poly([a+Vector2(-9,-7),a+Vector2(-8,-h),a+Vector2(0,-h-12),a+Vector2(0,0)],Color("82c3c1"))
		poly([a,a+Vector2(0,-h-12),a+Vector2(9,-h+1),a+Vector2(10,-7)],Color("538ba4"))
		line(a+Vector2(0,-h-12),a,Color("c2f0d7"))

func fossil(p: Vector2,progress: float) -> void:
	ellipse(p+Vector2(0,-34),45,34,Color("b6a07d"))
	for j in range(70):
		var a: float=j*.19
		var r: float=j*.4
		if progress<.8 and j>38: continue
		draw_circle(p+Vector2(cos(a)*r,sin(a)*r*.8-34),2.2,Color("75694f"))
	if progress<.8: line(p+Vector2(-26,-55),p+Vector2(22,-9),Color("3e5357"),3)

func vitrine(p: Vector2,progress: float) -> void:
	# Amber botanical specimen: a distinct silhouette and palette from the minerals.
	poly([p+Vector2(-45,-5),p+Vector2(29,7),p+Vector2(47,-4),p+Vector2(-28,-16)],Color("8e6949"))
	var amber:=p+Vector2(0,-36)
	poly([amber+Vector2(-22,20),amber+Vector2(-26,-12),amber+Vector2(-8,-34),amber+Vector2(18,-26),amber+Vector2(26,5),amber+Vector2(14,25)],Color("b57938") if progress<1 else Color("edbb63"))
	poly([amber+Vector2(-8,-34),amber+Vector2(18,-26),amber+Vector2(26,5),amber+Vector2(0,-1)],Color("ffd897"))
	line(amber+Vector2(-9,13),amber+Vector2(7,-18),Color("655b3d"),2)
	if progress>=1:
		for i in range(4):
			var stem:=amber+Vector2(-5+i*3,7-i*6)
			ellipse(stem+Vector2(-6,-4),6,3,Color("58755a"))
			ellipse(stem+Vector2(6,0),6,3,Color("748354"))
	else: line(amber+Vector2(-22,-10),amber+Vector2(15,11),Color("5d4c38"),3)
	poly([p+Vector2(-44,-87),p+Vector2(37,-74),p+Vector2(37,3),p+Vector2(-44,-10)],Color(.65,.85,.85,.10))
	for edge in [[Vector2(-44,-87),Vector2(37,-74)],[Vector2(-44,-87),Vector2(-44,-10)],[Vector2(37,-74),Vector2(37,3)]]:
		line(p+edge[0],p+edge[1],Color("c2e5df"),1.5)
	line(p+Vector2(-31,-74),p+Vector2(-15,-45),Color(1,1,1,.25),3)

func clock(p: Vector2,r: float,color: Color,running: bool) -> void:
	draw_circle(p+Vector2(3,3),r,Color("725a42"))
	draw_circle(p,r,color)
	draw_circle(p,r-4,Color("263f4c"))
	for i in range(12):
		var v:=Vector2(sin(i*TAU/12),-cos(i*TAU/12))
		line(p+v*(r-7),p+v*(r-11),color,1)
	var angle: float=time*.2 if running else 2.2
	line(p,p+Vector2(sin(angle),-cos(angle))*(r*.64),color,2)
	line(p,p+Vector2(sin(angle+1.8),-cos(angle+1.8))*(r*.4),JADE,2)
	draw_circle(p,2,color)

func orrery(p: Vector2,progress: float) -> void:
	line(p,p+Vector2(0,-44),GOLD,6)
	var center:=p+Vector2(0,-48)
	draw_circle(center,12,Color("f3cc7f"))
	for i in range(3):
		var rx: float=24+i*13
		var pts:=PackedVector2Array()
		for j in range(50): pts.append(center+Vector2(cos(j*TAU/49)*rx,sin(j*TAU/49)*rx*.38))
		draw_polyline(pts,Color("8eafab"),1,true)
		var angle: float=i*2+time*.25*progress
		if progress>.8 or i==0: draw_circle(center+Vector2(cos(angle)*rx,sin(angle)*rx*.38),5+i,JADE if i%2 else Color("b990b5"))

func machine(p: Vector2,progress: float) -> void:
	draw_rect(Rect2(p+Vector2(-35,-60),Vector2(70,56)),Color("687f85"))
	for i in range(3):
		clock(p+Vector2(-22+i*22,-40),11,GOLD,progress>.8)
		line(p+Vector2(-22+i*22,-17),p+Vector2(-22+i*22,-7),JADE if progress>.8 else Color("bf8a70"),5)

func avatar(p: Vector2,scale_value: float=1,seated_pose: bool=false,look: float=0.0,greeting: float=0.0) -> void:
	# Original adventurers: same equipment, distinct hair/face silhouettes.
	var female: bool=gender=="female"
	var stride: float=sin(walk_time)*5 if moving and not reduced else 0
	var bob: float=absf(sin(walk_time))*1.5 if moving else sin(time*1.8)*.6
	ellipse(p+Vector2(0,4),20,8,Color(0,0,0,.22))
	if defeat_active:
		bob=0
		p.y+=defeat_amount*4
		look=-.5*defeat_amount
	p.y-=bob
	var skin:=Color("d6a178") if female else Color("c78e68")
	var hair:=Color("533b35") if female else Color("382c30")
	if female:
		ellipse(p+Vector2(-facing*8,-53),17,23,hair)
		ellipse(p+Vector2(-facing*18,-58),8,11,hair)
	# Animated boots, trousers, cream shirt, teal vest and satchel.
	if seated_pose:
		for side in [-1,1]:
			var hip:=p+Vector2(side*6,-25)
			var knee:=p+Vector2(side*7-17,-15)
			line(hip,knee,Color("30475a") if side<0 else Color("23394c"),8)
			line(knee,knee+Vector2(0,17),Color("30475a") if side<0 else Color("23394c"),7)
			ellipse(knee+Vector2(-2,18),7,3.5,Color("564234"))
	else:
		line(p+Vector2(-6,-24),p+Vector2(-7+stride,-3),Color("30475a"),9)
		line(p+Vector2(7,-24),p+Vector2(8-stride,-3),Color("23394c"),9)
		ellipse(p+Vector2(-6+stride,-1),8,4,Color("564234"))
		ellipse(p+Vector2(9-stride,-1),8,4,Color("45352c"))
	poly([p+Vector2(-12,-47),p+Vector2(12,-47),p+Vector2(14,-22),p+Vector2(-13,-22)],Color("985177") if female else Color("d3a555"))
	poly([p+Vector2(-11,-48),p+Vector2(-2,-43),p+Vector2(-3,-23),p+Vector2(-14,-23)],Color("ad668c") if female else Color("365c78"))
	poly([p+Vector2(12,-48),p+Vector2(2,-43),p+Vector2(3,-23),p+Vector2(14,-23)],Color("793e61") if female else Color("29465e"))
	if female:
		if seated_pose:
			poly([p+Vector2(-12,-29),p+Vector2(12,-29),p+Vector2(6,-20),p+Vector2(-24,-20)],Color("397b79"))
		else:
			poly([p+Vector2(-12,-29),p+Vector2(12,-29),p+Vector2(19,-13),p+Vector2(-18,-13)],Color("397b79"))
		line(p+Vector2(-12,-29),p+Vector2(12,-29),GOLD,2)
	else:
		line(p+Vector2(-8,-45),p+Vector2(-7,-25),Color("7fa3b9"),3)
		draw_rect(Rect2(p+Vector2(-4,-37),Vector2(9,7)),Color("6b8a9d"))
	var arm: float=sin(walk_time)*5 if moving else sin(time)*1.3
	if restore_time>0 or greeting>0: arm=-16+sin(time*8)*3
	line(p+Vector2(-13,-43),p+Vector2(-17,-27-arm),Color("ad668c") if female else Color("d3a555"),7)
	line(p+Vector2(13,-43),p+Vector2(18,-26+arm),Color("985177") if female else Color("b78b43"),7)
	draw_circle(p+Vector2(18,-24+arm),4,skin)
	draw_circle(p+Vector2(-17,-25-arm),4,skin)
	line(p+Vector2(-9,-47),p+Vector2(12,-25),Color("805a3d"),3)
	draw_rect(Rect2(p+Vector2(8,-29),Vector2(13,13)),Color("a87743"))
	draw_rect(Rect2(p+Vector2(9,-30),Vector2(12,4)),GOLD)
	p+=Vector2(look*3.5,-absf(look)*.6)
	draw_circle(p+Vector2(0,-59),14,skin)
	ellipse(p+Vector2(0,-69),14,7,hair)
	poly([p+Vector2(-14,-70),p+Vector2(-5,-79),p+Vector2(13,-73),p+Vector2(14,-63),p+Vector2(5,-68),p+Vector2(-9,-65)],hair)
	if female: line(p+Vector2(-12,-65),p+Vector2(-14,-47),hair,5)
	var fx: float=facing*2
	draw_circle(p+Vector2(-5+fx,-59),1.5,Color("302c32"))
	draw_circle(p+Vector2(5+fx,-59),1.5,Color("302c32"))
	if defeat_active:
		line(p+Vector2(-3+fx,-51),p+Vector2(fx,-54),Color("9e6353"),1)
		line(p+Vector2(fx,-54),p+Vector2(3+fx,-51),Color("9e6353"),1)
	else: line(p+Vector2(-2+fx,-53),p+Vector2(3+fx,-53),Color("9e6353"),1)
	if female: draw_circle(p+Vector2(-9,-55),2,Color("bd7a68"))
	if celebration>0:
		for i in range(5):
			var q:=p+Vector2(cos(i*TAU/5+time)*28,-85+sin(i*TAU/5+time)*15)
			draw_circle(q,2,GOLD)

func move_safely(target: Vector2) -> void:
	var start:=hero
	var steps: int=maxi(1,ceili(start.distance_to(target)/.04))
	for i in range(1,steps+1):
		var point:=start.lerp(target,float(i)/steps)
		if blocked(point): return
		hero=point

func portrait(p: Vector2,progress: float) -> void:
	draw_rect(Rect2(p+Vector2(-35,-94),Vector2(70,94)),Color("573e61"))
	draw_rect(Rect2(p+Vector2(-31,-90),Vector2(62,86)),GOLD,false,4)
	poly([p+Vector2(-23,-8),p+Vector2(-17,-39),p+Vector2(12,-42),p+Vector2(26,-8)],Color("4f8f9c"))
	ellipse(p+Vector2(1,-60),17,23,Color("dca784"))
	poly([p+Vector2(-17,-60),p+Vector2(-19,-81),p+Vector2(12,-87),p+Vector2(22,-65),p+Vector2(0,-75)],Color("332c42"))
	draw_circle(p+Vector2(-5,-61),2,Color("332c42"))
	draw_circle(p+Vector2(8,-61),2,Color("332c42"))
	line(p+Vector2(-2,-49),p+Vector2(7,-48),Color("8c5266"),2)
	if progress<1:
		poly([p+Vector2(-28,-87),p+Vector2(-3,-80),p+Vector2(-12,-7),p+Vector2(-28,-7)],Color(.08,.13,.21,1-progress))

func time_core(p: Vector2,progress: float) -> void:
	for i in range(3):
		var angle: float=i*TAU/3+(time*.25 if progress>=1 else 0)
		var center:=p+Vector2(cos(angle)*29,-45+sin(angle)*26)
		draw_arc(center,17,0,TAU,32,GOLD,4,true)
		for tooth in range(8):
			var direction:=Vector2.from_angle(tooth*TAU/8+angle)
			line(center+direction*15,center+direction*22,GOLD,5)
	poly([p+Vector2(0,-76),p+Vector2(20,-43),p+Vector2(0,-12),p+Vector2(-20,-43)],JADE if progress>=1 else Color("466a78"))
	line(p+Vector2(0,-68),p+Vector2(0,-21),Color("d9fff1"),3)

func clear_segment(start: Vector2,target: Vector2) -> bool:
	var steps: int=maxi(1,ceili(start.distance_to(target)/.025))
	for i in range(steps+1):
		if blocked(start.lerp(target,float(i)/steps)): return false
	return true

func hit_exhibit(point: Vector2) -> int:
	var result: int=-1
	var distance: float=INF
	for i in range(4):
		var center:=screen_point(POS[i],55)
		var height: float=150 if TYPES[room][i] in ["dinosaur","portrait","painting","statue"] else 125
		var bounds:=Rect2(screen_point(POS[i],height)-Vector2(70,0)*view_scale,Vector2(140,height+20)*view_scale)
		if bounds.has_point(point) and center.distance_to(point)<distance:
			result=i; distance=center.distance_to(point)
	return result
