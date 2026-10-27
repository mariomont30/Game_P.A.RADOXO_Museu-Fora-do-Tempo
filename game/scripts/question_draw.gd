extends RefCounted
## Variety only changes which unseen item is chosen. It never changes its answer.
static func choose(pool: Array,state: Dictionary) -> Dictionary:
 var candidates: Array=pool.duplicate()
 if int(state.get("sign_streak",0))>=2 and state.get("last_sign","")!="label":
  var varied: Array=candidates.filter(func(q): return q.answer_sign!=state.get("last_sign",""))
  if not varied.is_empty(): candidates=varied
 if int(state.get("trend_streak",0))>=2:
  var varied: Array=candidates.filter(func(q): return q.trend!=state.get("last_trend",""))
  if not varied.is_empty(): candidates=varied
 var other_family: Array=candidates.filter(func(q): return q.family!=state.get("last_family",""))
 if not other_family.is_empty(): candidates=other_family
 var counts: Dictionary=state.get("families",{})
 var least: int=1000000000
 for q in candidates: least=mini(least,int(counts.get(q.family,0)))
 var balanced: Array=candidates.filter(func(q): return int(counts.get(q.family,0))==least)
 return balanced.pick_random()

static func record(state: Dictionary,q: Dictionary) -> Dictionary:
 var next: Dictionary=state.duplicate(true)
 var counts: Dictionary=next.get("families",{})
 counts[q.family]=int(counts.get(q.family,0))+1
 next.families=counts
 next.sign_streak=int(next.get("sign_streak",0))+1 if next.get("last_sign","")==q.answer_sign else 1
 next.trend_streak=int(next.get("trend_streak",0))+1 if next.get("last_trend","")==q.trend else 1
 next.last_family=q.family;next.last_sign=q.answer_sign;next.last_trend=q.trend
 return next

static func answer_position(balance: Array,last_position: int) -> int:
 var least: int=int(balance.min())
 var candidates: Array=[]
 for i in range(4):
  if int(balance[i])<=least+2: candidates.append(i)
 if candidates.size()>1: candidates.erase(last_position)
 var total: float=0
 for i in candidates: total+=1.0/(1.0+int(balance[i])-least)
 var ticket: float=randf_range(0,total)
 for i in candidates:
  ticket-=1.0/(1.0+int(balance[i])-least)
  if ticket<=0: return int(i)
 return int(candidates.back())
