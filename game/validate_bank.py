"""Independent validation: solve displayed givens with exact fractions, not the stored answer."""
import ast,json,re
from pathlib import Path
from fractions import Fraction
from collections import Counter
ROOT=Path(__file__).parent
LABELS={'Crescente','Decrescente','Constante','Não é P.A.'}

def solve(q):
 g=q['givens'];t=q['topic'];k=g['kind']
 if k in ('terms','classification'):
  ps=g['positions'];vs=g['values']
  assert len(ps)==len(vs)>=2 and len(set(ps))==len(ps) and ps==sorted(ps)
  rs=[Fraction(vs[j]-vs[j-1],ps[j]-ps[j-1]) for j in range(1,len(ps))]
  if t==0:return 'Não é P.A.' if len(set(rs))!=1 else 'Crescente' if rs[0]>0 else 'Decrescente' if rs[0]<0 else 'Constante'
  assert len(set(rs))==1
  r=rs[0];a=vs[0]-(ps[0]-1)*r
 elif k=='origin_step':a=Fraction(g['first']);r=Fraction(g['step'])
 elif k=='known_step':r=Fraction(g['step']);a=g['value']-(g['position']-1)*r
 elif k=='endpoints':a=Fraction(g['first']);r=Fraction(g['last']-g['first'],g['count']-1)
 else:raise AssertionError(k)
 assert a==q['a'] and r==q['r']
 if t in (1,3):value=a+(g['target_index']-1)*r;assert g['target_index']==q['n']
 elif t==2:value=r
 elif t==4:value=a
 elif t==5:
  assert r!=0
  value=(g['target_value']-a)/r+1
  assert value>0 and value.denominator==1 and value==q['n']
 else:
  n=g['count'];value=sum(a+i*r for i in range(n));assert n==q['n']
 assert value.denominator==1
 return str(int(value))

def displayed(q):
 g=q['givens'];lines=q['prompt'].splitlines();data='\n'.join(lines[1:-1]);ask=lines[-1]
 to_ascii=str.maketrans('₀₁₂₃₄₅₆₇₈₉','0123456789')
 pairs=[]
 if g['kind'] in ('terms','classification'):
  if data.startswith('Valores nas posições'):
   m=re.fullmatch(r'Valores nas posições 1 a (\d+): (.+)[.]',data)
   values=list(map(int,m[2].split(', ')));pairs=list(zip(range(1,int(m[1])+1),values))
  elif data.startswith('Na posição'):
   pairs=[tuple(map(int,p)) for p in re.findall(r'Na posição (\d+), o valor é (-?\d+)[.]',data)]
  elif data.startswith('Dados:'):
   pairs=[(int(p.translate(to_ascii)),int(v)) for p,v in re.findall(r'a([₀-₉]+) = (-?\d+)',data)]
  else:pairs=[tuple(map(int,p)) for p in re.findall(r'(?:Posição )?(\d+) → (-?\d+)',data)]
  assert pairs==list(zip(g['positions'],g['values'])),(q['id'],data,pairs,g)
 elif g['kind']=='origin_step':
  if data.startswith('O valor inicial'):
   m=re.fullmatch(r'O valor inicial é (-?\d+)[.] A cada posição, somamos (-?\d+)[.]',data)
  else:m=re.fullmatch(r'a₁ = (-?\d+) e r = (-?\d+)[.]',data)
  assert m and (int(m[1]),int(m[2]))==(g['first'],g['step'])
 elif g['kind']=='known_step':
  m=re.fullmatch(r'a([₀-₉]+) = (-?\d+) e r = (-?\d+)[.]',data)
  assert m and (int(m[1].translate(to_ascii)),int(m[2]),int(m[3]))==(g['position'],g['value'],g['step'])
 else:
  m=re.fullmatch(r'a₁ = (-?\d+), a([₀-₉]+) = (-?\d+) e n = (\d+)[.]',data)
  assert m and (int(m[1]),int(m[2].translate(to_ascii)),int(m[3]),int(m[4]))==(g['first'],g['count'],g['last'],g['count'])
 if q['topic']==0:
  assert 'segue uma progressão aritmética' not in q['prompt']
 else:
  assert 'progressão aritmética' in lines[0] or 'P.A.' in lines[0]
  if q['topic'] in (1,3):
   m=re.search(r'posição (\d+)|a([₀-₉]+)',ask);target=int((m[1] or m[2]).translate(to_ascii));assert target==g['target_index']
   if g['kind']=='terms':assert target not in g['positions']
  elif q['topic']==5:assert int(re.search(r'valor (-?\d+)',ask)[1])==g['target_value']
  elif q['topic']==6:assert int(re.search(r'dos (\d+) primeiros',ask)[1])==g['count']

def arithmetic(expression):
 def visit(node):
  if isinstance(node,ast.Constant) and isinstance(node.value,int):return Fraction(node.value)
  if isinstance(node,ast.UnaryOp) and isinstance(node.op,ast.USub):return -visit(node.operand)
  if isinstance(node,ast.BinOp):
   a,b=visit(node.left),visit(node.right)
   if isinstance(node.op,ast.Add):return a+b
   if isinstance(node.op,ast.Sub):return a-b
   if isinstance(node.op,ast.Mult):return a*b
   if isinstance(node.op,ast.Div):return a/b
  raise AssertionError(ast.dump(node))
 return visit(ast.parse(expression.replace('−','-').replace('×','*').strip(),mode='eval').body)

def validate():
 bank=json.loads((ROOT/'data/questions.json').read_text(encoding='utf-8'))
 assert len(bank)==4200
 ids=set();fingerprints=set();rank=Counter();families=Counter();signs=Counter();proofs=0
 for q in bank:
  assert q['id'] not in ids;ids.add(q['id'])
  assert q['answer']==solve(q),(q['id'],q['answer'],solve(q))
  displayed(q)
  assert len(q['options'])==len(set(q['options']))==4 and q['options'].count(q['answer'])==1
  fp=(q['topic'],q['a'],q['r'],q['n'] if q['topic'] not in (0,2) else 0)
  assert fp not in fingerprints;fingerprints.add(fp)
  assert q['revision']==216 and 60<=q['time']<=120
  assert ';' not in q['prompt']+q['solution'] and '—' not in q['prompt']+q['solution']
  assert len(q['prompt'])<=320
  if q['mode']=='hard' and q['topic']:
   assert q['givens']['kind']=='terms'
   i,j=q['givens']['positions'][:2];assert i>=2 and j-i>1
  if q['topic']==0:assert set(q['options'])==LABELS
  else:
   values=list(map(int,q['options']));answer=int(q['answer'])
   assert not answer or sum((v>0)==(answer>0) and v!=0 for v in values)>=2
   if q['topic']==5:assert all(v>0 for v in values)
   rank[(q['mode'],q['topic'],sorted(values).index(answer))]+=1
  for expression,result in re.findall(r'(?:r|a[₀-₉0-9]+|S[₀-₉0-9]+) = ([^=]+?) = (-?\d+)\.',q['solution']):
   assert arithmetic(expression)==int(result),(q['id'],expression,result)
   proofs+=1
  families[(q['mode'],q['topic'],q['family'])]+=1
  signs[(q['mode'],q['topic'],q['answer_sign'])]+=1
 assert len(families)==70 and set(families.values())=={60}
 for mode in ['normal','hard']:
  for t in range(1,7):
   assert sorted(rank[(mode,t,r)] for r in range(4))==[75,75,75,75]
   if t!=5:assert [signs[(mode,t,s)] for s in ['positive','negative','zero']]==[140,140,20]
 for t in range(7):
  for s in ['positive','negative','zero','label']:assert signs[('normal',t,s)]==signs[('hard',t,s)]
 result={'questions':4200,'displayed_prompts_verified':4200,'numeric_answers_recomputed':3600,'classifications_recomputed':600,'solution_equalities_checked':proofs,'families':dict(Counter(q['family'] for q in bank)),'normal_signs':dict(Counter(q['answer_sign'] for q in bank if q['mode']=='normal')),'hard_signs':dict(Counter(q['answer_sign'] for q in bank if q['mode']=='hard')),'single_correct_sign_cues':0,'rank_counts_per_numeric_group':[75,75,75,75]}
 print('PASS BANK216: '+json.dumps(result,ensure_ascii=False))
 return result
if __name__=='__main__':validate()
