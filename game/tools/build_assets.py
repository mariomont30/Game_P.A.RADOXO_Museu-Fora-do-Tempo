"""Original musical arrangements and contextualized, audited question bank."""
from pathlib import Path
from array import array
import wave, math, random, json, struct

ROOT=Path(__file__).resolve().parents[1]
RATE=22050
random.seed(8291)
def freq(midi): return 440*2**((midi-69)/12)

def note(buf, start, duration, midi, amp, instrument='piano'):
    f=freq(midi); begin=int(start*RATE); count=min(int(duration*RATE),len(buf)-begin)
    for j in range(max(0,count)):
        t=j/RATE
        attack=min(1,t*70)
        tail=min(1,(duration-t)*12)
        phase=2*math.pi*f*t
        if instrument=='piano':
            value=(math.sin(phase)+.32*math.sin(phase*2.002)+.13*math.sin(phase*3.01))*math.exp(-3*t/duration)
        elif instrument=='bell':
            value=(math.sin(phase)+.25*math.sin(phase*2.76)+.08*math.sin(phase*5.4))*math.exp(-5*t/duration)
        elif instrument=='flute':
            value=(math.sin(phase+.015*math.sin(2*math.pi*4*t))+.12*math.sin(phase*2))*min(1,t*14)*min(1,(duration-t)*8)
        else:
            value=(math.sin(phase)+.2*math.sin(phase*2)+.08*math.sin(phase*3))*min(1,t*2)*min(1,(duration-t)*2)
        buf[begin+j]+=value*amp*attack*tail

def save(name,buf,stereo=True,loop=True):
    peak=max(abs(x) for x in buf) or 1
    gain=.76/max(.76,peak)
    out=array('h')
    n=len(buf)
    for i in range(n):
        # Short stereo room, with loop-safe circular delay.
        dry=buf[i]
        if stereo:
            left=dry+.19*buf[(i-int(.173*RATE))%n]+.10*buf[(i-int(.379*RATE))%n]
            right=dry+.17*buf[(i-int(.229*RATE))%n]+.11*buf[(i-int(.431*RATE))%n]
            out.append(int(max(-1,min(1,left*gain)) * 30000))
            out.append(int(max(-1,min(1,right*gain)) * 30000))
        else: out.append(int(max(-1,min(1,dry*gain))*30000))
    with wave.open(str(ROOT/'audio'/name),'wb') as w:
        w.setnchannels(2 if stereo else 1); w.setsampwidth(2); w.setframerate(RATE); w.writeframes(out.tobytes())

# Sixteen bars, evolving harmony and original melodic phrases, roughly 46 seconds.
chords=[[50,57,62,66],[47,54,59,62],[43,50,55,59],[45,52,57,61],
        [50,57,62,66],[54,57,61,66],[55,59,62,67],[45,52,57,64],
        [47,54,59,66],[43,50,55,62],[50,57,62,69],[45,52,57,64],
        [55,59,62,67],[52,55,59,64],[45,52,57,61],[50,57,62,66]]
melodies=[[74,78,76,69],[71,74,73,66],[67,71,74,78],[76,73,69,73],
          [78,81,78,76],[73,78,76,73],[74,79,78,74],[76,73,69,64],
          [71,74,78,76],[74,71,67,69],[74,78,81,78],[76,73,69,73],
          [79,78,74,71],[76,74,71,67],[69,73,76,73],[74,69,66,74]]
for idx,name in enumerate(['menu','gallery','nature','inventions']):
    bpm=[78,84,88,92][idx]; beat=60/bpm; duration=64*beat
    buf=array('f',[0]) * int(duration*RATE)
    lead=['bell','piano','flute','bell'][idx]
    for bar,base_chord in enumerate(chords):
        shift=[0,0,5,-3][idx]
        chord=[pitch+shift for pitch in chords[(bar+[0,0,5,9][idx])%16]]
        start=bar*4*beat
        for pitch in chord[:3]: note(buf,start,3.95*beat,pitch,.018,'pad')
        note(buf,start,1.8*beat,chord[0]-12,.07,'piano')
        for step in range(8):
            pitch=chord[[0,1,2,3,2,1,3,1][step]]+12
            note(buf,start+step*.5*beat,1.2*beat,pitch,.047 if idx==0 else .060,'piano' if idx!=3 else 'bell')
        motif=melodies[bar] if idx<2 else ([79,74,76,71] if bar%2==0 else [72,76,79,83]) if idx==2 else ([69,76,72,79] if bar%2==0 else [67,74,71,76])
        for k,pitch in enumerate(motif):
            if idx==0 and k%2==1: continue
            note(buf,start+k*beat+.05,1.15*beat,pitch,.085,lead)
        if bar>=8:
            note(buf,start+2*beat,1.6*beat,chord[2]+12,.035,'flute')
    save(name+'.wav',buf)
    print(name,round(duration,1),'seconds')

