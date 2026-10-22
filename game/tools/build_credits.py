"""Original victory parade for rolling credits. Rebuilds only credits.wav, using stdlib."""
from pathlib import Path
from array import array
import math, random

helper = Path(__file__).with_name('music22.py')
if not helper.exists():
    helper = Path(__file__).with_name('build_assets.py')
exec(compile(helper.read_text(encoding='utf-8').split('# Sixteen bars')[0], str(helper), 'exec'))

beat = 60 / 132
duration = 96 * beat
buf = array('f', [0]) * int(duration * RATE)
chords = [[50, 57, 62, 66], [55, 59, 62, 67], [47, 54, 59, 62], [45, 52, 57, 61]]
melody = [[74, 74, 78, 81, 86, 81, 78, 81],
          [83, 81, 79, 78, 79, 83, 86, 83],
          [78, 74, 71, 74, 78, 81, 78, 74],
          [76, 73, 69, 73, 76, 81, 85, 81]]
rng = random.Random(290132)

def drum(start, kind, amp):
    count = int((.18 if kind != 'hat' else .055) * RATE)
    begin = int(start * RATE)
    for j in range(count):
        t = j / RATE
        if kind == 'kick':
            value = math.sin(2 * math.pi * (48*t + 3*(1-math.exp(-35*t)))) * math.exp(-24*t)
        elif kind == 'snare':
            value = (.7*rng.uniform(-1, 1) + .3*math.sin(2*math.pi*185*t))*math.exp(-32*t)
        else:
            value = rng.uniform(-1, 1)*math.exp(-100*t)
        buf[(begin+j) % len(buf)] += value * amp * min(1, t*900)

for bar in range(24):
    chord = chords[bar % 4]
    start = bar * 4 * beat
    for pitch in chord:
        note(buf, start, 3.8*beat, pitch, .018, 'pad')
    for k in range(8):
        at = start + k*.5*beat
        note(buf, at, .38*beat, chord[[0, 1, 2, 3, 2, 1, 3, 1][k]]+12, .063, 'piano')
        note(buf, at, .36*beat, chord[0]-12+(12 if k%2 else 0), .075, 'piano')
        pitch = melody[bar%4][k]
        note(buf, at, .43*beat, pitch, .12, 'flute')
        if bar >= 8:
            note(buf, at, .42*beat, pitch-12, .05, 'piano')
        drum(at, 'hat', .028 if k%2 else .018)
    for k in range(4):
        drum(start+k*beat, 'kick' if k%2==0 else 'snare', .16 if k%2==0 else .065)

save('credits.wav', buf)
print(f'credits.wav: original victory parade, 132 BPM, {duration:.2f}s, stereo loop')
