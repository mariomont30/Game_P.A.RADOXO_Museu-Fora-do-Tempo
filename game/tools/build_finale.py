"""Build only the original victory theme, without rewriting existing assets."""
from pathlib import Path
from array import array
import math, random

source=Path(__file__).with_name('build_assets.py').read_text(encoding='utf-8')
exec(compile(source.split('# Sixteen bars')[0],str(Path(__file__)),'exec'))
beat=60/112
bars=24
duration=(bars*4+4)*beat
buf=array('f',[0])*int(duration*RATE)
# D major, a rising opening fanfare, a lyrical middle, then a full tonic cadence.
chords=[[50,54,57,62],[55,59,62,67],[47,54,59,62],[45,52,57,61],
        [50,54,57,62],[54,57,61,66],[55,59,62,67],[45,52,57,61]]
motifs=[[74,78,81,86],[83,81,79,78],[78,74,71,78],[76,73,69,73],
        [74,78,81,78],[78,81,85,81],[79,83,86,83],[81,79,76,73]]
for bar in range(bars):
    chord=chords[bar%8]; start=bar*4*beat
    for pitch in chord:
        note(buf,start,3.95*beat,pitch,.04 if bar>=16 else .026,'pad')
    note(buf,start,1.7*beat,chord[0]-12,.11,'piano')
    note(buf,start+2*beat,1.6*beat,chord[2]-12,.08,'piano')
    for k in range(8):
        note(buf,start+k*.5*beat,.85*beat,chord[[0,1,2,3,2,1,3,2][k]]+12,.045,'bell')
    for k,pitch in enumerate(motifs[bar%8]):
        note(buf,start+k*beat,1.3*beat,pitch,.105,'flute')
        if bar>=16: note(buf,start+k*beat,1.1*beat,pitch-12,.05,'flute')
    # A light game-like pulse with a deeper kick and soft noise snare.
    for k in range(4):
        begin=int((start+k*beat)*RATE)
        for j in range(int(.12*RATE)):
            t=j/RATE
            pulse=math.sin(2*math.pi*(72*t-130*t*t))*math.exp(-t*35)*.085
            if k%2: pulse+=random.uniform(-1,1)*math.exp(-t*38)*.035
            if begin+j<len(buf): buf[begin+j]+=pulse
for pitch in [38,50,54,57,62,74]: note(buf,bars*4*beat,3.8*beat,pitch,.07,'piano')
# Fade both boundaries so replay remains smooth, while retaining the final cadence.
for i in range(len(buf)):
    buf[i]*=min(1,i/(RATE*.035),(len(buf)-1-i)/(RATE*.7))
save('finale.wav',buf)
print('Victory theme:',round(duration,2),'seconds')
