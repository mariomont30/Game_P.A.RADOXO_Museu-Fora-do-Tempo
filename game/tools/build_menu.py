"""Original, upbeat adventure theme. Rebuilds only menu.wav, using stdlib."""
from pathlib import Path
from array import array
import math, random

helper = Path(__file__).with_name('music22.py')
if not helper.exists():
    helper = Path(__file__).with_name('build_assets.py')
exec(compile(helper.read_text(encoding='utf-8').split('# Sixteen bars')[0], str(helper), 'exec'))

beat = 60 / 122
duration = 64 * beat
buf = array('f', [0]) * int(duration * RATE)
chords = [[48, 55, 60, 64], [43, 50, 55, 59], [45, 52, 57, 60], [41, 48, 53, 57]]
melody = [[72, 76, 79, 76, 81, 79, 76, 74],
          [71, 74, 79, 74, 83, 81, 79, 74],
          [72, 76, 81, 79, 76, 79, 81, 84],
          [77, 76, 72, 69, 72, 74, 76, 79]]
rng = random.Random(280122)

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

for bar in range(16):
    chord = chords[bar % 4]
    start = bar * 4 * beat
    for pitch in chord:
        note(buf, start, 3.8*beat, pitch, .018, 'pad')
    for k in range(8):
        at = start + k*.5*beat
        note(buf, at, .38*beat, chord[[0, 1, 2, 3, 2, 1, 3, 1][k]]+12, .063, 'piano')
        note(buf, at, .36*beat, chord[0]-12+(12 if k%2 else 0), .075, 'piano')
        pitch = melody[bar%4][k]
        note(buf, at, .43*beat, pitch, .095, 'bell')
        if bar >= 8:
            note(buf, at, .42*beat, pitch-12, .036, 'flute')
        drum(at, 'hat', .028 if k%2 else .018)
    for k in range(4):
        drum(start+k*beat, 'kick' if k%2==0 else 'snare', .16 if k%2==0 else .065)

save('menu.wav', buf)
print(f'menu.wav: original adventure theme, 122 BPM, {duration:.2f}s, stereo loop')
