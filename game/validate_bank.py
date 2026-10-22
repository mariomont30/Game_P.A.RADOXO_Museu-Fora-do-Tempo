"""Independent mathematical audit. Run with Python 3, no dependencies."""
import json
from pathlib import Path
from collections import Counter

questions=json.loads((Path(__file__).parent/'data/questions.json').read_text(encoding='utf-8'))
assert len(questions)==1050
ids=set()
signatures=set()
for q in questions:
    assert q['id'] not in ids
    ids.add(q['id'])
    assert len(q['options'])==len(set(q['options']))==4
    assert q['options'].count(q['answer'])==1
    a,r,n,t=q['a'],q['r'],q['n'],q['topic']
    series=[a]
    for _ in range(n-1): series.append(series[-1]+r)
    if t==0:
        diffs=[b-a for a,b in zip(q['sequence'],q['sequence'][1:])]
        expected='Não é P.A.' if len(set(diffs))!=1 else 'Crescente' if diffs[0]>0 else 'Decrescente' if diffs[0]<0 else 'Constante'
    elif t==1: expected=str(a+sum([r]*4))
    elif t in (2,7): expected=str(r)
    elif t==3: expected=str(series[-1])
    elif t==4: expected=str(series[0])
    elif t==5: expected=str(len(series))
    else: expected=str(sum(series))
    assert q['answer']==expected,(q['id'],expected,q['answer'])
    signature=(t,a,r,n if t not in (0,1,2) else 0)
    assert signature not in signatures
    signatures.add(signature)
counts=Counter((q['mode'],q['topic']) for q in questions)
assert all(v==75 for v in counts.values()) and len(counts)==14
print('PASS: 1050 answers independently recalculated; 14 groups x 75; unique IDs, mathematical signatures and alternatives.')
