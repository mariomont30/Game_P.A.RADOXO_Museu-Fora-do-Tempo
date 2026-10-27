"""Two original, distinct defeat cues. Does not rebuild any existing soundtrack."""
from pathlib import Path
from array import array
import math,wave
ROOT=Path(__file__).resolve().parents[1]
RATE=22050

def build(name,duration,notes,sad):
 samples=array('f',[0])*int(duration*RATE)
 for start,length,midi,amp in notes:
  hz=440*2**((midi-69)/12)
  for i in range(min(int(length*RATE),len(samples)-int(start*RATE))):
   t=i/RATE
   envelope=min(1,t/.025)*max(0,1-t/length)**1.6
   value=math.sin(math.tau*hz*t)+.23*math.sin(math.tau*hz*2.003*t)+.07*math.sin(math.tau*hz*3*t)
   samples[int(start*RATE)+i]+=value*amp*envelope
 output=array('h')
 for i,sample in enumerate(samples):
  if sad:sample+=.12*samples[max(0,i-int(.17*RATE))]
  value=max(-.9,min(.9,sample))
  output.extend([int(value*27000),int(value*26000)])
 with wave.open(str(ROOT/'audio'/name),'wb') as target:
  target.setnchannels(2);target.setsampwidth(2);target.setframerate(RATE);target.writeframes(output.tobytes())

build('gameover_first.wav',2.1,[(0,.5,76,.22),(.15,.6,72,.23),(.32,1,67,.24),(.5,1.3,60,.19),(.5,1.3,64,.10)],False)
build('gameover_final.wav',4.3,[(0,1.2,69,.18),(.3,1.6,65,.18),(.65,1.8,64,.17),(1.1,2.6,57,.18),(1.1,2.6,60,.13),(1.1,2.6,64,.10),(1.6,2.5,45,.13)],True)
print('Original game-over cues generated; existing music unchanged.')
