extends Control
## Each lit heart is one remaining life. Empty hearts show the mode limit.
var filled: int=3
var total: int=3
var mode_text: String="NORMAL"
var large_text: bool=false
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 clip_contents=true
 resized.connect(queue_redraw)
func configure(value: int,limit: int,mode_name: String,large: bool=false) -> void:
 total=clampi(limit,1,3);filled=clampi(value,0,total)
 mode_text=mode_name;large_text=large
 tooltip_text="%d de %d vidas · %s" % [filled,total,mode_text]
 queue_redraw()
func _draw() -> void:
 var width: float=28.0 if large_text else 26.0
 var height: float=26.0 if large_text else 24.0
 var gap: float=8.0
 var top: float=(size.y-height)*.5
 for i in range(total):
  var left: float=i*(width+gap)
  var points:=PackedVector2Array()
  for step in range(64):
   var angle: float=TAU*step/64.0
   var x: float=16.0*pow(sin(angle),3)
   var y: float=13*cos(angle)-5*cos(2*angle)-2*cos(3*angle)-cos(4*angle)
   points.append(Vector2(left+(x/32.0+.5)*width,top+(12.0-y)/29.0*height))
  var lit: bool=i<filled
  draw_colored_polygon(points,Color("ef5350") if lit else Color("172b38"))
  var outline:=points.duplicate();outline.append(points[0])
  draw_polyline(outline,Color("ff8a80") if lit else Color("526773"),1.2,true)
  if lit:draw_circle(Vector2(left+width*.28,top+height*.22),1.8,Color(1,.75,.70,.7))
 var label_font: Font=get_theme_default_font()
 var font_size: int=22 if large_text else 20
 var baseline: float=(size.y-label_font.get_height(font_size))*.5+label_font.get_ascent(font_size)
 var text_x: float=total*(width+gap)+8
 draw_string(label_font,Vector2(text_x,baseline),mode_text,HORIZONTAL_ALIGNMENT_LEFT,maxf(0,size.x-text_x),font_size,Color("8adbc1"))
