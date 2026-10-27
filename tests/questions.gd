extends SceneTree
var g
var checks: int=0
var draws: int=0
func _initialize() -> void: call_deferred("run")
func check(value: bool,message: String) -> void:
 checks+=1
 if not value: push_error("FAIL BANK216: "+message);quit(1)
func find_button(node: Node,caption: String) -> Button:
 for c in node.get_children():
  if c is Button and c.text==caption: return c
  var found:=find_button(c,caption)
  if found:return found
 return null
func run() -> void:
 g=load("res://main.tscn").instantiate();root.add_child(g);g.testing=true
 await process_frame;g.set_process(false);g.art.set_process(false);g.audio.stop_all()
 check(g.db.size()==4200 and g.legacy_db.size()==1050,"New bank plus read-only legacy validation")
 seed(216042)
 var banks: Dictionary={}
 for q in g.db:
  var key: String=str(q.mode)+":"+str(int(q.topic))
  if not banks.has(key):banks[key]=[]
  banks[key].append(q)
 # Simulate 2,000 full museum journeys with the actual production draw helper.
 for mode in ["normal","hard"]:
  for journey in range(1000):
   var states: Dictionary={};var seen: Dictionary={}
   for topic in g.TOPICS:
    var pool: Array=banks[mode+":"+str(topic)].filter(func(q): return not seen.has(q.id))
    var state: Dictionary=states.get(topic,{})
    var q: Dictionary=g.QuestionDraw.choose(pool,state)
    check(not seen.has(q.id) and q.mode==mode and int(q.topic)==topic,"Journey draws unseen items of the requested skill and mode")
    states[topic]=g.QuestionDraw.record(state,q);seen[q.id]=true;draws+=1
 # Exhaust complete groups: all 300 items exactly once, not merely the first few.
 for mode in ["normal","hard"]:
  for topic in range(7):
   for trial in range(5):
    var pool: Array=banks[mode+":"+str(topic)].duplicate()
    var state: Dictionary={};var seen: Dictionary={}
    for i in range(300):
     var old_sign: String=str(state.get("last_sign",""))
     var has_other: bool=pool.any(func(q): return q.answer_sign!=old_sign)
     var q: Dictionary=g.QuestionDraw.choose(pool,state)
     if topic!=0 and int(state.get("sign_streak",0))>=2 and has_other:check(q.answer_sign!=old_sign,"No avoidable run of three equal answer signs")
     if i<20 and i>0:check(q.family!=state.last_family,"Early questions vary their representation")
     check(not seen.has(q.id),"No duplicates before bank exhaustion")
     seen[q.id]=true;state=g.QuestionDraw.record(state,q);pool.erase(q);draws+=1
    check(seen.size()==300 and pool.is_empty(),"Every question remains reachable")
 # Alternative slots vary without a forced permutation of every four questions.
 var balance: Array=[0,0,0,0];var last: int=-1;var window: Array=[];var repeated_blocks: int=0
 for i in range(100000):
  var slot: int=g.QuestionDraw.answer_position(balance,last)
  check(slot!=last,"Correct option changes position on a new question")
  balance[slot]=int(balance[slot])+1;last=slot;window.append(slot)
  check(int(balance.max())-int(balance.min())<=3,"Soft balance stays bounded")
  if window.size()==4:
   var distinct: Dictionary={}
   for p in window:distinct[p]=true
   if distinct.size()<4:repeated_blocks+=1
   window=[]
 check(repeated_blocks>0,"Positions do not follow a predictable four-item cycle")
 # Real start_question() persists variety and balances alternative positions.
 for mode in ["normal","hard"]:
  g.create_profile("Sorteio salvo",mode);g.mission=0
  var state: Dictionary={}
  for i in range(20):g.start_question()
  state=g.current.draw_state.duplicate(true)
  var id: String=g.current.id;var question_id: String=g.question.id
  var options: Array=g.question.options.duplicate()
  var saved_position: int=int(g.current.last_answer_position)
  g.time_left=31.25;g.update_snapshot();g.save_game();g.load_save()
  for p in g.profiles:
   if p.id==id:g.current=p
  g.resume_profile()
  if not (g.current.draw_state==state and g.question.id==question_id and g.question.options==options): print("DEBUG DRAW RELOAD ",JSON.stringify({"expected":state,"actual":g.current.draw_state,"id_expected":question_id,"id_actual":g.question.id,"choices_expected":options,"choices_actual":g.question.options}))
  check(g.current.draw_state==state and g.question.id==question_id and g.question.options==options,"Reload preserves draw history, active question and alternative order")
  check(g.time_left==31.25,"Reload preserves remaining time")
  check(int(g.current.last_answer_position)==saved_position,"Reload preserves the last correct position")
  var invalid_position: Dictionary=g.current.duplicate(true);invalid_position.last_answer_position=4
  check(not g.valid_profile(invalid_position),"Reject out-of-range saved correct position")
  check(int(g.current.balance.max())-int(g.current.balance.min())<=3,"Answer positions balanced")
  var bad: Dictionary=g.current.duplicate(true);bad.draw_state={"normal:1":{"families":{"unknown":2}}}
  check(not g.valid_profile(bad),"Reject malformed saved draw metadata")
 # Legacy active questions keep lives, clock, question and the already used retry.
 for mode in ["normal","hard"]:
  for gender in ["female","male"]:
   g.gender=gender;g.create_profile("Migração 2.15",mode)
   var legacy: Dictionary=g.legacy_db.filter(func(q):return q.mode==mode and int(q.topic)==g.TOPICS[0])[0].duplicate(true)
   g.current.seen=[legacy.id];g.current.erase("draw_state");g.current.erase("last_answer_position");g.current.defeats=1;g.current.lives=1;g.current.phase="question"
   g.current.active={"question":legacy,"mission":0,"remaining":29.5,"bad":[],"hints":1,"slots":["", ""],"selected":legacy.options[0],"slot_index":0}
   check(g.valid_profile(g.current),"Previous active question accepted against archived canonical data")
   g.save_game();g.load_save();g.current=g.profiles.back();g.resume_profile()
   check(g.question.id==legacy.id and g.time_left==29.5 and g.current.lives==1 and g.current.defeats==1,"Migration preserves the game-over rule and snapshot")
   check(int(g.current.last_answer_position)==legacy.options.find(legacy.answer),"Legacy save derives its last correct position")
   var old_key: String=g.question_math_key(legacy)
   g.start_question();check(g.question.revision==216 and g.question_math_key(g.question)!=old_key,"Next draw uses new bank without repeating old mathematics")
   var tampered: Dictionary=g.current.duplicate(true);tampered.active.question.answer="alterada"
   check(not g.valid_profile(tampered),"Canonical answer validation remains strict")
 # Reviewing an exhausted subject preserves other subjects, the retry and hard-mode time.
 g.create_profile("Revisão","hard");g.current.defeats=1;g.mission=0;g.start_question();await process_frame
 var other: Dictionary=g.db.filter(func(q):return q.mode=="hard" and int(q.topic)==0)[0]
 g.current.seen=[other.id]
 for q in g.question_by_id.values():
  if q.mode=="hard" and int(q.topic)==g.TOPICS[0]:g.current.seen.append(q.id)
 g.time_left=21.5;g.start_question()
 check(is_instance_valid(g.overlay),"Exhaustion asks for consent")
 var review: Button=find_button(g.overlay,"Revisar este conteúdo")
 check(review!=null,"Review action exists");review.pressed.emit()
 check(g.current.seen.has(other.id) and g.current.defeats==1,"Review preserves other history and defeat count")
 check(g.time_left==21.5,"Review while skipping cannot refill the hard-mode clock")
 print("PASS BANK216 DRAW: ",checks," checks; ",draws," draws; 2000 journeys; legacy snapshots and bank review verified")
 await create_timer(.35).timeout;quit()
