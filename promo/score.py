# Original score + sound design for the Tape promo. Everything is synthesised here.
# usage: python score.py timeline.json out.wav
import json, sys
import numpy as np
from scipy.signal import butter, sosfilt, fftconvolve
from scipy.io import wavfile

SR = 48000
DUR = 55.0
N = int(DUR * SR)
rng = np.random.default_rng(7)
TL = json.load(open(sys.argv[1]))

def bus(): return np.zeros((2, N))
music, perc, sfx, sfx_dry = bus(), bus(), bus(), bus()
pads, subs = bus(), bus()

def mtof(m): return 440.0 * 2 ** ((m - 69) / 12)
def lp(x, f, o=2): return sosfilt(butter(o, f, 'low', fs=SR, output='sos'), x, axis=-1)
def hp(x, f, o=2): return sosfilt(butter(o, f, 'high', fs=SR, output='sos'), x, axis=-1)
def bp(x, lo, hi, o=2): return sosfilt(butter(o, [lo, hi], 'band', fs=SR, output='sos'), x, axis=-1)

def place(b, sig, t0, gain=1.0, pan=0.0):
    i0 = int(round(t0 * SR))
    if i0 >= N: return
    if sig.ndim == 1:
        l, r = np.cos((pan + 1) * np.pi / 4), np.sin((pan + 1) * np.pi / 4)
        sig = np.vstack([sig * l, sig * r]) * np.sqrt(2)
    s0 = max(0, -i0); i0 = max(0, i0)
    n = min(sig.shape[1] - s0, N - i0)
    b[:, i0:i0 + n] += sig[:, s0:s0 + n] * gain

def tt(d): return np.arange(int(d * SR)) / SR

# ---------------- instruments ----------------
def piano(m, vel=0.5, d=3.5):
    t = tt(d); f = mtof(m); y = np.zeros_like(t)
    for n in range(1, 11):
        fn = f * n * np.sqrt(1 + 0.00035 * n * n)
        if fn > 16000: break
        y += (1 / n ** 1.25) * np.exp(-t * (0.9 + 0.75 * n) * (0.7 + vel)) * np.sin(2 * np.pi * fn * t + rng.uniform(0, 6))
    att = np.minimum(1, t / 0.004)
    hammer = lp(rng.standard_normal(len(t)) * np.exp(-t / 0.006), 3000) * 0.15
    y = (y * att + hammer) * vel
    return lp(y, 2500 + 5000 * vel)

def pad_note(m, d, a=1.8, r=2.6):
    t = tt(d + r); y = np.zeros((2, len(t)))
    for ch, cents in ((0, -6), (1, 6), (0, 1), (1, -2)):
        f = mtof(m) * 2 ** (cents / 1200)
        v = np.zeros_like(t)
        for n in range(1, 9):
            v += np.sin(2 * np.pi * f * n * t + rng.uniform(0, 6)) / n ** 1.6
        y[ch] += v
    env = np.minimum(1, t / a) * np.clip((d + r - t) / r, 0, 1) ** 2
    return y * env * 0.5

def bell(f, vel=0.5, d=4.0):
    t = tt(d); y = np.zeros_like(t)
    for ratio, amp, dec in ((1, 1, 2.6), (2.0, .45, 1.6), (2.76, .35, 1.1), (5.4, .2, .5), (8.93, .1, .25)):
        y += amp * np.exp(-t / dec) * np.sin(2 * np.pi * f * ratio * t)
    return y * np.minimum(1, t / 0.002) * vel

def marimba(m, vel=0.4):
    t = tt(1.2); f = mtof(m)
    y = np.sin(2 * np.pi * f * t) * np.exp(-t / .35) + .35 * np.sin(2 * np.pi * f * 4 * t) * np.exp(-t / .06)
    return y * np.minimum(1, t / .002) * vel

def kick(vel=0.5):
    t = tt(0.6); f = 46 + 70 * np.exp(-t / 0.035)
    y = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / 0.22)
    return lp(y, 900) * vel

def hat(vel=0.1):
    t = tt(0.12)
    return hp(rng.standard_normal(len(t)), 7000, 4) * np.exp(-t / 0.025) * vel

def tick(vel=0.3, f=4200):
    t = tt(0.05)
    y = bp(rng.standard_normal(len(t)), f * .7, f * 1.3) * np.exp(-t / .004)
    y += 0.5 * np.sin(2 * np.pi * f * 1.5 * t) * np.exp(-t / .006)
    return y * vel

def whoosh(d=1.2, f0=300, f1=3000, vel=0.25, rise=0.6):
    t = tt(d); x = rng.standard_normal(len(t)); y = np.zeros_like(x)
    blk = 512
    for i in range(0, len(t), blk):
        k = i / len(t); fc = f0 * (f1 / f0) ** k
        seg = x[max(0, i - 2048):i + blk]
        y[i:i + blk] = bp(seg, fc * .6, min(fc * 1.6, 20000))[-len(y[i:i + blk]):]
    env = np.where(t < d * rise, (t / (d * rise)) ** 2, ((d - t) / (d * (1 - rise))) ** 1.5)
    return y * env * vel

def thock(vel=0.4, f=190):
    t = tt(0.3)
    return np.sin(2 * np.pi * f * t * (1 - .15 * t)) * np.exp(-t / .05) * vel

def voice(pcs, lo, hi):
    return sorted(m for m in range(lo, hi + 1) if m % 12 in pcs)

# ---------------- harmony ----------------
CH = [  # start, bass root pc, chord pcs
    (0, 5, [5, 9, 0, 4, 7]),     # Fmaj9
    (6, 2, [2, 5, 9, 0, 4]),     # Dm9
    (12, 10, [10, 2, 5, 9, 0]),  # Bbmaj9
    (16, 0, [0, 4, 7, 2]),       # Cadd9
    (20, 5, [5, 9, 0, 4, 7]),    # Fmaj9 (breathe)
    (26, 9, [9, 0, 4, 7]),       # Am7
    (30, 10, [10, 2, 5, 9, 0]),  # Bbmaj9
    (32, 2, [2, 5, 9, 0, 4]),    # Dm9
    (36, 10, [10, 2, 5, 9, 0]),  # Bbmaj9
    (40, 7, [7, 10, 2, 5, 9]),   # Gm9
    (44, 0, [0, 5, 7, 10]),      # C7sus4
    (47, 5, [5, 9, 0, 4, 7]),    # Fmaj9 (home)
]
def chord_at(t):
    c = CH[0]
    for x in CH:
        if t >= x[0]: c = x
    return c

# pads + sub bass
for i, (t0, root, pcs) in enumerate(CH):
    t1 = CH[i + 1][0] if i + 1 < len(CH) else DUR - 2.4
    d = t1 - t0
    for m in voice(pcs, 52, 69)[:5]:
        place(pads, pad_note(m, d, a=2.2 if i == 0 else 1.2, r=2.4), t0, 0.05)
    if t0 >= 6:
        bm = 36 + (root - 36) % 12  # C2..B2
        tb = tt(d + 1.2); sub = np.sin(2 * np.pi * mtof(bm) * tb) * np.minimum(1, tb / .4) * np.clip((d + 1.2 - tb) / 1.2, 0, 1)
        place(subs, sub, t0, 0.13 if t0 < 47 else 0.1)

# piano arpeggio (8ths at 120 bpm, with rests)
PAT = [0, None, 2, 1, None, 3, 2, None, 0, None, 3, 1, None, 4, 2, None]
def arp(a, b, step=0.25, vel=0.26, every=1):
    k = 0; t = a
    while t < b - 1e-6:
        idx = PAT[k % len(PAT)]
        if idx is not None and k % every == 0:
            notes = voice(chord_at(t)[2], 65, 86)
            m = notes[idx % len(notes)]
            v = vel * (1.15 if k % 8 == 0 else 0.85 + 0.2 * rng.random())
            place(music, piano(m, v), t + rng.normal(0, 0.004), 1.0, pan=0.35 * np.sin(k * 1.7))
        k += 1; t += step
arp(6.0, 20.9, vel=0.22)
arp(23.0, 25.9, step=0.5, vel=0.18)
arp(26.0, 31.4, vel=0.24)
arp(32.0, 39.6, vel=0.25)
arp(44.0, 46.9, step=0.5, vel=0.2)
# melody notes on the downbeats of the main sections
for t0, m in [(6, 77), (8, 76), (10, 72), (12, 74), (14, 77), (16, 79), (18, 76),
              (26, 76), (28, 79), (30, 77), (32, 81), (34, 77), (36, 74), (38, 77)]:
    place(music, piano(m, 0.34, 4.5), t0, 1.0, pan=-0.1)
# outro motif on the home chord
for t0, m in [(47.5, 84), (48.25, 81), (49.0, 79), (49.75, 77), (51.0, 72)]:
    place(music, piano(m, 0.3, 5), t0, 1.0, pan=0.1)
place(music, piano(53, 0.45, 6), 47.0, 1.0); place(music, piano(41, 0.45, 6), 47.0, 1.0)

# soft pulse
for a, b, hats in [(12.0, 20.6, True), (26.0, 31.4, True), (32.0, 39.6, True)]:
    t = a
    while t < b - 1e-6:
        beat = round((t - a) / 0.5)
        if beat % 4 == 0: place(perc, kick(0.55), t)
        elif beat % 4 == 2: place(perc, kick(0.3), t)
        if hats: place(perc, hat(0.05 if beat % 2 else 0.03), t + 0.25, pan=0.3)
        t += 0.5

# ---------------- sound design ----------------
# needle drop + ticks revealing outwards from it
place(sfx, thock(0.35, 140), 0.62); place(sfx, tick(0.35, 3200), 0.66)
for j in range(1, 29):
    d = j * 7 / 400
    tj = 1.0 + d * 1.6 + 0.08
    v = 0.16 * (1 - j / 34)
    place(sfx, tick(v, 5200), tj, pan=-0.5); place(sfx, tick(v * .9, 5400), tj + 0.004, pan=0.5)
# every minute that passes the needle
for t0 in TL['ticks']:
    if abs(t0 - TL['cross']) > 0.05:
        place(sfx, tick(0.22, 3600), t0)
# panel morph + appear
place(sfx, whoosh(1.4, 250, 2400, 0.10), 11.8)
place(sfx, marimba(81, 0.12), 13.0, pan=0.3)
# focus -> break: glass chime
place(sfx, bell(mtof(81), 0.22, 5), TL['cross']); place(sfx, bell(mtof(88), 0.12, 4), TL['cross'] + 0.11)
# menu bar
place(sfx, whoosh(0.9, 2500, 500, 0.09, 0.3), 25.8)
place(sfx, tick(0.25, 2600), 26.85)
place(sfx, whoosh(2.0, 200, 4000, 0.09, 0.8), 27.3)
place(sfx, whoosh(0.8, 3000, 400, 0.07, 0.3), 31.3)
# settings: one note per block as the strip wipes in
def eio(x): return 4 * x ** 3 if x < .5 else 1 - (-2 * x + 2) ** 3 / 2
W = 1200; GAP = 8; widths = [25, 5, 25, 5, 25, 5, 25]; tot = sum(widths); avail = W - GAP * 6
x0s = []; x = 0
for w in widths: x0s.append(x); x += avail * w / tot + GAP
ts = np.linspace(32.7, 34.2, 3000); wip = np.array([eio(min(1, max(0, (t - 32.7) / 1.5))) for t in ts]) * (W + 40) - 20
notes = [62, 65, 69, 72, 74, 77, 81]
for i, xb in enumerate(x0s):
    t0 = 32.7 + i * 0.18 + 0.03
    place(sfx, marimba(notes[i] + 12, 0.13), t0, pan=-0.6 + 1.2 * i / 6)
# value changes
for t0, ns in [(35.0, [86, 89]), (37.0, [81, 84])]:
    place(sfx, tick(0.25, 2400), t0)
    place(sfx, marimba(ns[0], 0.1), t0 + 0.35); place(sfx, marimba(ns[1], 0.1), t0 + 0.6)
place(sfx, whoosh(0.8, 3000, 400, 0.06, 0.3), 39.3)
# sleep: a soft power-down, then a wake shimmer
tsd = tt(1.0); place(sfx, np.sin(2 * np.pi * np.cumsum(330 * np.exp(-tsd * 1.6)) / SR) * np.exp(-tsd / .35) * .07, 42.1)
for i, m in enumerate([77, 81, 84, 88, 91]):
    place(sfx, bell(mtof(m), 0.06, 2.5), 43.6 + i * 0.06, pan=-0.4 + 0.2 * i)
# end card
place(sfx, whoosh(1.0, 300, 1800, 0.07), 46.4)
place(sfx_dry, kick(0.35), 47.0)
place(sfx, bell(mtof(84), 0.12, 6), 47.15); place(sfx, bell(mtof(89), 0.07, 5), 47.27)
# light sweeping across the icon: a faint high shimmer
for i, m in enumerate([96, 100, 103]):
    place(sfx, bell(mtof(m), 0.025, 2.5), 48.55 + i * 0.09, pan=-0.3 + 0.3 * i)
# the tagline settles
place(sfx, bell(mtof(77), 0.05, 4), 48.6, pan=0.1)

# ---------------- mix ----------------
# while the Mac sleeps, the music goes muffled and quieter
t = np.arange(N) / SR
def smooth(x): return x * x * (3 - 2 * x)
sl = smooth(np.clip((t - 42.0) / 0.6, 0, 1)) * (1 - smooth(np.clip((t - 43.5) / 0.6, 0, 1)))
bed = music * 0.42 + pads * 1.1 + subs * 0.6 + perc * 0.7
muff = lp(bed, 350, 4)
bed = bed * (1 - sl) + muff * sl * 0.55

def reverb(x, rt=3.0, wet=0.3):
    n = int(rt * SR); ti = np.arange(n) / SR
    out = np.zeros_like(x)
    for ch in range(2):
        ir = rng.standard_normal(n) * np.exp(-6.9 * ti / rt)
        ir = lp(ir, 5000); ir[:int(.015 * SR)] *= np.linspace(0, 1, int(.015 * SR))
        ir /= np.sqrt(np.sum(ir ** 2))
        out[ch] = fftconvolve(x[ch], ir)[:x.shape[1]]
    return x * (1 - wet) + out * wet

def db(x): return 20*np.log10(np.sqrt(np.mean(x**2))+1e-12)
for nm,bb in [('piano',music),('pads',pads),('sub',subs)]: print(nm, 'rms', db(bb), 'peak', np.max(np.abs(bb)))
print('perc rms', db(perc), 'peak', np.max(np.abs(perc)))
print('sfx rms', db(sfx), 'peak', np.max(np.abs(sfx)))
mix = reverb(bed, 3.2, 0.32) + reverb(sfx * 1.25, 2.2, 0.22) + sfx_dry
mix = hp(mix, 30)
# fade in/out
mix *= np.clip(t / 0.3, 0, 1) * np.clip((DUR - t) / 2.5, 0, 1) ** 1.5
# gentle limiter + normalise
print('pre-limit peak', np.max(np.abs(mix)), 'rms', db(mix))
# level to about -19 dBFS RMS, then a soft knee only on the rare peaks above 0.8
mix *= 10 ** (-19 / 20) / np.sqrt(np.mean(mix ** 2))
th = 0.8; ax = np.abs(mix)
mix = np.where(ax > th, np.sign(mix) * (th + (1 - th) * np.tanh((ax - th) / (1 - th))), mix)
mix *= min(1, 10 ** (-1 / 20) / np.max(np.abs(mix)))
print('limited samples %', 100 * np.mean(ax > th))
print('rms dBFS', 20 * np.log10(np.sqrt(np.mean(mix ** 2))))
wavfile.write(sys.argv[2], SR, (mix.T * 32767).astype(np.int16))
