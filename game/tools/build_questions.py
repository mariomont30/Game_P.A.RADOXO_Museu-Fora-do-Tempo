"""Reproducible AP bank 2.16. Integer arithmetic, five representations per skill/mode."""
from pathlib import Path
from fractions import Fraction
from collections import Counter
import itertools,json,random
ROOT=Path(__file__).resolve().parents[1]
RNG=random.Random(216042)
LABELS=['Crescente','Decrescente','Constante','Não é P.A.']
FAMILIES=['sequencia','registros','tabela','mecanismo','restauracao']
CONTEXT={
 'sequencia':'Observe o padrão registrado no museu.',
 'registros':'Tico encontrou estes registros no painel.',
 'tabela':'Use os dados da ficha de restauração.',
 'mecanismo':'O mecanismo segue uma progressão aritmética.',
 'restauracao':'Complete a informação que falta para restaurar a obra.'}
SUB=str.maketrans('0123456789','₀₁₂₃₄₅₆₇₈₉')
def label(n):return 'a'+str(n).translate(SUB)
def term(a,r,n):return a+(n-1)*r
def sign(v):return 'positive' if v>0 else 'negative' if v<0 else 'zero'
def answer_of(t,a,r,n):return term(a,r,n) if t in (1,3) else r if t==2 else a if t==4 else n if t==5 else n*(2*a+(n-1)*r)//2

def params(mode,t,wanted,fi):
 hard=mode=='hard'
 for _ in range(10000):
  r=RNG.choice([x for x in range(-12 if hard else -5,13 if hard else 6) if x])
  n=RNG.randint(14,32) if hard else RNG.randint(4,12)
  if t==1:n=RNG.randint(7,12) if hard else [5,3,6,4,7][fi]
  a=RNG.randint(-65,65) if hard else RNG.randint(-25,25)
  if wanted=='zero':
   if t in (1,3):a=-(n-1)*r
   elif t==2:r=0
   elif t==4:a=0
   elif t==6:
    if (n-1)*r%2:continue
    a=-(n-1)*r//2
  value=answer_of(t,a,r,n)
  if t==5:
   if r==0:continue
  elif sign(value)!=wanted:continue
  if not hard and (abs(a)>65 or abs(term(a,r,n))>95):continue
  return a,r,n
 raise RuntimeError('Cannot generate parameters')

def make_givens(mode,t,a,r,n,fi):
 hard=mode=='hard'
 if t==0:
  positions=[1,3,6,10] if hard else [1,2,3,4,5]
  values=[term(a,r,i) for i in positions]
  return {'kind':'classification','positions':positions,'values':values}
 if not hard:
  if t==1:
   positions=[i for i in range(1,max(n,5)+1) if i!=n]
   return {'kind':'terms','positions':positions,'values':[term(a,r,i) for i in positions],'target_index':n}
  if t==2:
   positions=[1,2,3,4] if fi in (0,2) else [fi+1,fi+2]
   return {'kind':'terms','positions':positions,'values':[term(a,r,i) for i in positions]}
  if t in (3,5) and fi in (0,2):
   return {'kind':'terms','positions':[1,2,3],'values':[term(a,r,i) for i in [1,2,3]],**({'target_index':n} if t==3 else {'target_value':term(a,r,n)})}
  if t==4 and fi in (1,2):
   return {'kind':'terms','positions':[n-1,n],'values':[term(a,r,n-1),term(a,r,n)]}
  if t in (3,4,5):
   g={'kind':'origin_step','first':a,'step':r}
   if t==3:g['target_index']=n
   if t==4:g={'kind':'known_step','position':n,'value':term(a,r,n),'step':r}
   if t==5:g['target_value']=term(a,r,n)
   return g
  if fi==4:return {'kind':'terms','positions':[1,2,3],'values':[term(a,r,i) for i in [1,2,3]],'count':n}
  if fi%2==0:return {'kind':'endpoints','first':a,'last':term(a,r,n),'count':n}
  return {'kind':'origin_step','first':a,'step':r,'count':n}
 i=RNG.randint(2,4)
 j=RNG.randint(i+2,min(n-1,i+7)) if t in (1,3) else RNG.randint(i+2,i+7)
 g={'kind':'terms','positions':[i,j],'values':[term(a,r,i),term(a,r,j)]}
 if t in (1,3):g['target_index']=n
 if t==5:g['target_value']=term(a,r,n)
 if t==6:g['count']=n
 return g

def render(mode,t,f,g):
 intro='Precisamos conferir os registros do mecanismo.' if t==0 and f=='mecanismo' else CONTEXT[f]
 if t!=0 and 'progressão aritmética' not in intro:intro+=' A sequência é uma P.A.'
 kind=g['kind']
 if kind in ('terms','classification'):
  positions=g['positions'];values=g['values']
  if f=='tabela':data='\n'.join(f'Posição {p} → {v}' for p,v in zip(positions,values))
  elif mode=='normal' and positions==list(range(1,len(positions)+1)):
   data='Valores nas posições 1 a '+str(len(positions))+': '+', '.join(map(str,values))+'.'
  elif f=='registros':data=' '.join(f'Na posição {p}, o valor é {v}.' for p,v in zip(positions,values))
  elif f=='restauracao':data='Etiquetas da P.A. (posição → valor): '+', '.join(f'{p} → {v}' for p,v in zip(positions,values))+'.' if t!=0 else 'Registros (posição → valor): '+', '.join(f'{p} → {v}' for p,v in zip(positions,values))+'.'
  else:data='Dados: '+', '.join(f'{label(p)} = {v}' for p,v in zip(positions,values))+'.'
 elif kind=='origin_step':
  data=f'O valor inicial é {g["first"]}. A cada posição, somamos {g["step"]}.' if f=='mecanismo' else f'a₁ = {g["first"]} e r = {g["step"]}.'
 elif kind=='known_step':data=f'{label(g["position"])} = {g["value"]} e r = {g["step"]}.'
 else:data=f'a₁ = {g["first"]}, {label(g["count"])} = {g["last"]} e n = {g["count"]}.'
 asks=[
  'Esses registros são compatíveis com uma P.A.? Se forem, como ela se classifica?' if mode=='hard' else 'Como se classifica a sequência?',
  f'Qual valor completa a posição {g.get("target_index",0)}?',
  'Qual é a razão dessa P.A.?',
  f'Qual é o valor de {label(g.get("target_index",0))}?',
  'Qual era o primeiro termo, a₁?',
  f'Em qual posição aparece o valor {g.get("target_value",0)}?',
  f'Qual é a soma dos {g.get("count",0)} primeiros termos?']
 return intro+'\n'+data+'\n'+asks[t]

def explanations(t,a,r,n,g,classification=None):
 b=term(a,r,n)
 if t==0:
  pairs=list(zip(g['positions'],g['values']))
  ratios=[Fraction(v2-v1,p2-p1) for (p1,v1),(p2,v2) in zip(pairs,pairs[1:])]
  if classification=='Não é P.A.':solution='As diferenças por posição não são constantes. Esses registros não são compatíveis com uma P.A.'
  else:solution=f'A variação por posição é sempre {r}. A classificação é {classification.lower()}.'
  return solution,'Compare a variação dos valores com a distância entre as posições.','Calcule (valor final − valor inicial)/(posição final − posição inicial) em cada intervalo.','Compare as razões dos intervalos'
 derive=''
 if g['kind']=='terms':
  i,j=g['positions'][:2];vi,vj=g['values'][:2]
  derive=f'r = ({vj} − ({vi}))/({j} − {i}) = {r}. a₁ = {vi} − ({i} − 1) × ({r}) = {a}. '
 elif g['kind']=='endpoints':derive=f'r = ({g["last"]} − ({a}))/({n} − 1) = {r}. '
 if t in (1,3):
  return derive+f'{label(n)} = {a} + ({n} − 1) × ({r}) = {b}.','Localize o primeiro termo e a variação por posição.','Use aₙ = a₁ + (n − 1)r. Conte os intervalos, não os termos.','aₙ = a₁ + (n − 1)r'
 if t==2:
  i,j=g['positions'][:2];vi,vj=g['values'][:2]
  return f'r = ({vj} − ({vi}))/({j} − {i}) = {r}.','Compare valores e posições de dois registros.','Divida a diferença dos valores pela quantidade de intervalos entre eles.','r = (aⱼ − aᵢ)/(j − i)'
 if t==4:return derive+f'a₁ = {b} − ({n} − 1) × ({r}) = {a}.','Conte quantos intervalos separam o termo conhecido da primeira posição.','Use a₁ = aₙ − (n − 1)r. Se a razão for negativa, cuide da subtração.','a₁ = aₙ − (n − 1)r'
 if t==5:return derive+f'n = ({b} − ({a}))/({r}) + 1 = {n}.','Encontre a razão antes de contar as posições.','Use n = (valor procurado − a₁)/r + 1. A primeira posição também conta.','n = (aₙ − a₁)/r + 1'
 total=n*(a+b)//2
 return derive+f'{label(n)} = {a} + ({n} − 1) × ({r}) = {b}. S{str(n).translate(SUB)} = {n} × ({a} + ({b}))/2 = {total}.','Descubra o primeiro e o último termo do trecho que será somado.','Use Sₙ = n(a₁ + aₙ)/2. No Difícil, calcule a razão a partir dos registros.','Sₙ = n(a₁ + aₙ)/2'

def distractors(t,a,r,n,correct,desired_rank,include_zero):
 b=term(a,r,n)
 mistakes={1:[a+n*r,a+(n-2)*r,b-r,b+r,a],2:[-r,2*r,3*r,r-1,r+1,a],3:[a+n*r,a+(n-2)*r,n*r,b-r,b+r,a],4:[b-n*r,b+(n-1)*r,b-r,a-r,a+r,b],5:[n-1,n+1,n-2,n+2,n+3,n-3],6:[n*(a+b),n*b,n*a,n*(a+b-r)//2,n*(a+b+r)//2,correct-n,correct+n]}[t]
 candidates=list(dict.fromkeys(mistakes+[correct+d for d in range(-8,9) if d]+[-correct,0]))
 candidates=[v for v in candidates if v!=correct and (t!=5 or v>0)]
 # Every nonzero correct answer shares its sign with another option.
 possible=[]
 for combination in itertools.combinations(candidates,3):
  if correct and not any(sign(x)==sign(correct) for x in combination):continue
  if sum(x<correct for x in combination)!=desired_rank:continue
  if include_zero and t!=5 and correct!=0 and 0 not in combination:continue
  if not include_zero and correct!=0 and 0 in combination:continue
  # Prefer common misconceptions and nearby off-by-one errors, without a fixed rank cue.
  score=sum(candidates.index(x) for x in combination)
  possible.append((score+RNG.random()*6,combination))
 if not possible:return None
 possible.sort(key=lambda p:p[0]);values=list(possible[RNG.randrange(min(5,len(possible)))][1])+[correct]
 RNG.shuffle(values)
 return [str(x) for x in values]

def build():
 bank=[];signatures=set()
 for mode in ['normal','hard']:
  for topic in range(7):
   desired=[]
   for fi in range(5):
    for j in range(60):
     desired.append((fi, 'positive' if topic==5 else ('positive' if j<28 else 'negative' if j<56 else 'zero')))
   RNG.shuffle(desired)
   ranks=[i%4 for i in range(300)];RNG.shuffle(ranks)
   classes=[LABELS[i%4] for i in range(300)];RNG.shuffle(classes)
   for index,(fi,wanted) in enumerate(desired):
    for attempt in range(10000):
     if topic==0:
      classification=classes[index]
      r=0 if classification=='Constante' else RNG.randint(1,12 if mode=='hard' else 5)*(1 if classification=='Crescente' else -1 if classification=='Decrescente' else RNG.choice([-1,1]))
      a=RNG.randint(-100,100) if mode=='hard' else RNG.randint(-45,45);n=10 if mode=='hard' else 5
     else:a,r,n=params(mode,topic,wanted,fi)
     givens=make_givens(mode,topic,a,r,n,fi)
     if topic==4 and mode=='hard':n=givens['positions'][-1]
     fingerprint=(topic,a,r,n if topic not in (0,2) else 0)
     if fingerprint in signatures:continue
     if topic==0:
      if classification=='Não é P.A.':givens['values'][2]+=RNG.choice([1,2,3])
      answer=classification;options=LABELS.copy();RNG.shuffle(options)
     else:
      value=answer_of(topic,a,r,n);answer=str(value)
      include_zero=index%3==0 and not (value<0 and ranks[index]==3 or value>0 and ranks[index]==0)
      options=distractors(topic,a,r,n,value,ranks[index],include_zero)
      if options is None:continue
     solution,hint,step,formula=explanations(topic,a,r,n,givens,classification if topic==0 else None)
     q={'id':f'216-{mode}-{topic}-{index:03}','mode':mode,'topic':topic,'revision':216,'family':FAMILIES[fi],
        'prompt':render(mode,topic,FAMILIES[fi],givens),'answer':answer,'options':options,'solution':solution,
        'hint':hint,'hint_steps':[hint,step],'formula':formula,'a':a,'r':r,'n':n,
        'sequence':givens['values'] if topic==0 else [term(a,r,i) for i in range(1,6)],'givens':givens,
        'answer_sign':'label' if topic==0 else sign(int(answer)),
        'trend':'irregular' if topic==0 and classification=='Não é P.A.' else 'increasing' if r>0 else 'decreasing' if r<0 else 'constant',
        'time':([60,60,60,90,90,90,120] if mode=='normal' else [75,75,90,105,105,120,120])[topic]}
     bank.append(q);signatures.add(fingerprint);break
    else:raise RuntimeError((mode,topic,index,wanted,ranks[index]))
 output=ROOT/'data/questions.json'
 output.write_text(json.dumps(bank,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 print('Generated',len(bank),'questions; deterministic seed 216042.')
 print({m:dict(Counter(q['answer_sign'] for q in bank if q['mode']==m)) for m in ['normal','hard']})
if __name__=='__main__':build()
