"""Original short gallery stingers. Deterministic synthesis, no external recordings."""
from pathlib import Path
import array,hashlib,json,math,random,wave
ROOT=Path(__file__).resolve().parents[1]
RATE=44100
TAU=math.tau

def build(name,notes,duration,seed,bright):
    rng=random.Random(seed)
    frames=int(RATE*duration)
    left=[0.0]*frames;right=[0.0]*frames
    def voice(at,length,midi,level,pan=0.0,bell=False):
        start=int(at*RATE);end=min(frames,start+int(length*RATE));hz=440*2**((midi-69)/12)
        for i in range(start,end):
            t=(i-start)/RATE;attack=min(1,t/.012);release=min(1,(end-i)/(RATE*.13))
            env=attack*release*math.exp(-t*(3.5 if bell else 2.0))
            fundamental=math.sin(TAU*hz*t)
            tone=fundamental+.20*math.sin(TAU*hz*2*t)+.09*math.sin(TAU*hz*(3.01 if bell else 3)*t)
            v=level*env*tone
            left[i]+=v*(.75-.25*pan);right[i]+=v*(.75+.25*pan)
            echo=i+int(.14*RATE)
            if echo<frames:left[echo]+=v*.12*(.75+.25*pan);right[echo]+=v*.12*(.75-.25*pan)
    if name!='gallery_travel':
        # A soft winding sound leads into a rising four-note discovery motif.
        for n,midi in enumerate(notes):voice(.24+n*.18,1.15,midi,.14,(-.5 if n%2==0 else .5),True)
        root=notes[0]-24
        for midi in [root,root+7,root+16]:voice(1.05,2.55,midi,.10,0)
        for n,midi in enumerate([notes[-1],notes[-1]+4,notes[-1]+7]):voice(1.12+n*.035,2.45,midi,.105,(-.55+n*.55),bright)
        for at in [.03,.10,.18]:voice(at,.09,91,.023,-.35,True)
    for i in range(frames):
        t=i/RATE
        wind=math.sin(math.pi*min(1,t/(.68 if name!='gallery_travel' else .5)))**2 if t<(.68 if name!='gallery_travel' else .5) else 0
        noise=rng.uniform(-1,1)*.022*wind
        # Low-level stereo air, no harsh transient or sub-bass spike.
        left[i]+=noise*.7;right[i]+=noise*.9
    peak=max(max(abs(x) for x in left),max(abs(x) for x in right),1e-9)
    gain=(.13 if name=='gallery_travel' else .65)/peak
    samples=array.array('h')
    for i,(l,rr) in enumerate(zip(left,right)):
        fade=min(1,(frames-i)/(RATE*.16));fade=max(0,fade)
        samples.extend([round(l*gain*fade*32767),round(rr*gain*fade*32767)])
    path=ROOT/'audio'/(name+'.wav')
    with wave.open(str(path),'wb') as out:
        out.setnchannels(2);out.setsampwidth(2);out.setframerate(RATE);out.writeframes(samples.tobytes())
    final_peak=max(abs(v) for v in samples)/32768
    rms=math.sqrt(sum((v/32768)**2 for v in samples)/len(samples))
    assert final_peak<.80 and rms>.001
    return {'name':path.name,'duration':duration,'channels':2,'rate':RATE,'peak':round(final_peak,5),'rms':round(rms,5),'clipped_samples':sum(abs(v)>=32767 for v in samples),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}

def main():
    recipes=[('arrival_art',[72,76,79,84],3.8,21701,True),('arrival_nature',[62,69,74,78],3.8,21702,False),('arrival_inventions',[67,74,79,83],3.8,21703,True),('arrival_finale',[60,67,72,76,79,84],3.8,21704,True),('gallery_travel',[],.55,21705,False)]
    result=[build(*args) for args in recipes]
    print(json.dumps(result,ensure_ascii=False,indent=2))
if __name__=='__main__':main()
