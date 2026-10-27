from pathlib import Path
import sys,shutil
root=Path(sys.argv[1]).resolve()
p=root/"index.html"
s=p.read_text(encoding="utf-8").replace('lang="en"','lang="pt-BR"').replace('width=device-width, user-scalable=no, initial-scale=1.0','width=device-width, initial-scale=1.0, viewport-fit=cover')
s=s.replace('Your browser does not support the canvas tag.','Seu navegador não suporta o jogo.').replace('Your browser does not support JavaScript.','Ative JavaScript para jogar.')
s=s.replace('<script src="index.js"></script>', '<script src="mobile.js"></script>\n<script src="index.js"></script>')
s=s.replace('<script src="mobile.js"></script>', '''<script>
const paradoxoFetch=window.fetch.bind(window);
window.fetch=function(input,options){
 const resource=new URL(typeof input==='string'?input:input.url,document.baseURI);
 if(resource.origin===location.origin&&resource.pathname.endsWith('/index.pck')){
  resource.searchParams.set('v','2.19.0');
  return paradoxoFetch(resource.href,options);
 }
 return paradoxoFetch(input,options);
};
</script>
<script src="mobile.js"></script>''')
s=s.replace('P.A.RADOXO — O Museu Fora do Tempo','P.A.RADOXO | O Museu Fora do Tempo')
s=s.replace('</head>','<meta name="application-version" content="2.19.0">\n</head>')
s=s.replace('</head>','<link rel="stylesheet" href="mobile.css">\n</head>')
s=s.replace('<canvas id="canvas">', '<section id="welcome" aria-labelledby="welcomeTitle"><div id="welcome-scene" aria-hidden="true"><img src="welcome-museum.png?v=2.19.0" alt=""></div><div class="welcome-content"><p class="eyebrow">UMA AVENTURA DE RESTAURAÇÃO</p><h1 id="welcomeTitle">P.A.RADOXO</h1><h2>O Museu Fora do Tempo</h2><p>Restaure 12 obras, descubra padrões e devolva vida às histórias.</p><button id="enterMuseum">Entrar no museu</button><p class="small">No celular, jogue na horizontal. Toque para caminhar e use os botões da tela. Suas jornadas ficam salvas neste navegador.</p></div></section><section id="rotate" role="status"><div><div class="phoneIcon" aria-hidden="true">↻</div><h2>Gire o celular</h2><p>O museu foi preparado para jogar na horizontal.</p><p class="small">Se necessário, habilite a rotação automática do aparelho.</p></div></section><dialog id="nameDialog"><form id="nameForm"><h2>Como podemos chamar você?</h2><label for="mobileName">Seu nome ou apelido</label><input id="mobileName" type="text" autocomplete="off" autocapitalize="words" enterkeyhint="done"><p class="small">Até 20 caracteres. Acentos e emojis são aceitos.</p><div class="actions"><button id="cancelName" type="button">Voltar</button><button type="submit">Usar este nome</button></div></form></dialog><canvas id="canvas">')
s=s.replace("engine.startGame({", "window.paradoxo.start = () => engine.startGame({")
s=s.replace("setStatusMode('progress');", "setStatusMode('progress');\n        statusOverlay.style.visibility='hidden';")
s=s.replace("setStatusMode('hidden');", "setStatusMode('hidden');\n            window.paradoxo.ready=true;")
s=s.replace("}, displayFailureNotice);", "}, displayFailureNotice);\n        document.getElementById('enterMuseum').addEventListener('click', () => window.paradoxo.launch());")
# Recovery is inlined before external scripts, so it also handles a helper download failure.
recovery=(Path(__file__).resolve().parents[1]/'web/loader_recovery.js').read_text(encoding='utf-8')
s=s.replace('<script src="mobile.js"></script>','<script>'+recovery+'</script>\n<script src="mobile.js?v=2.19.0"></script>')
s=s.replace('href="mobile.css"','href="mobile.css?v=2.19.0"')
assert '<div id="status-notice"></div>' in s
s=s.replace('<div id="status-notice"></div>','<div id="status-notice" role="alert" aria-live="assertive"></div><div id="status-recovery" hidden><button id="retryLoad" type="button">Tentar novamente</button><p class="small">Tentar novamente recarrega a página sem apagar as jornadas salvas.</p></div>')
s=s.replace('const engine = new Engine(GODOT_CONFIG);','const engine = typeof Engine === "function" ? new Engine(GODOT_CONFIG) : null;')
a=s.index('\tfunction displayFailureNotice(err) {')
b=s.index('\n\tconst missing =',a)
s=s[:a]+"\tfunction displayFailureNotice(err) {\n\t\tinitializing = false;\n\t\twindow.paradoxoLoadFailure(err);\n\t}\n\n\tif (!engine || !window.paradoxo) {\n\t\tdisplayFailureNotice(new Error('Startup script unavailable'));\n\t\treturn;\n\t}\n"+s[b:]
p.write_text(s,encoding="utf-8")
(root/'mobile.css').write_text("""html,body{width:100%;height:100%;height:100dvh;background:#101d2c;color:#f5efe0;font-family:system-ui,sans-serif}body{overscroll-behavior:none}#canvas{width:100%;height:100%;touch-action:none}#welcome,#rotate{position:fixed;inset:0;z-index:10;display:grid;place-items:center;padding:max(16px,env(safe-area-inset-top)) max(24px,env(safe-area-inset-right));box-sizing:border-box;background:radial-gradient(ellipse at 70% 25%,#26434e,#101d2c 65%)}#welcome .welcome-content{max-width:700px;text-align:center}h1{font-size:clamp(38px,7vw,74px);color:#e9c78b;letter-spacing:.04em;margin:8px 0}h2{font-size:clamp(22px,3vw,32px);margin:12px 0}p{line-height:1.55;font-size:clamp(17px,2.2vw,22px)}.eyebrow{color:#8adbc1;font-size:14px;letter-spacing:.08em}.small{font-size:15px;color:#b4c6ce;max-width:600px}button{font:600 19px system-ui;min-height:48px;border-radius:14px;border:1px solid #e9c78b;background:#e9c78b;color:#132b39;padding:12px 26px;cursor:pointer}button:focus-visible,input:focus-visible{outline:3px solid #8adbc1;outline-offset:3px}button:disabled{opacity:.6;cursor:wait}#rotate{display:none;z-index:30;text-align:center}.phoneIcon{font-size:70px;color:#e9c78b}#status{background:#101d2c!important;z-index:9;padding:20px;box-sizing:border-box}#status-notice{font:18px system-ui;color:#f5efe0;max-width:600px;text-align:center}#status-progress{width:min(70vw,480px);accent-color:#8adbc1}dialog{z-index:40;width:min(620px,90vw);box-sizing:border-box;border:1px solid #426071;border-radius:18px;padding:24px;background:#0c1b27;color:#f5efe0;max-height:95dvh;overflow-y:auto}dialog::backdrop{background:#02070de6}dialog form{display:grid;gap:12px}dialog h2{font-size:24px}dialog label{font-size:18px}dialog input{font:24px system-ui;background:#1d3849;color:#fff;border:1px solid #78909c;border-radius:10px;min-height:54px;padding:4px 12px;box-sizing:border-box;width:100%}.actions{display:flex;gap:14px;justify-content:space-between}.actions button{flex:1}.actions button:first-child{background:#1d3849;color:#f5efe0;border-color:#426071}@media(pointer:coarse) and (orientation:portrait){#rotate{display:grid}}@media(max-height:430px){#welcome h1{font-size:40px}#welcome h2{font-size:22px}#welcome p{margin:8px 0;font-size:16px}#welcome .small{font-size:13px}dialog{padding:14px 22px}dialog h2{margin:0}dialog form{gap:8px}dialog .small{margin:0}}""",encoding="utf-8")
(root/'mobile.js').write_text((Path(__file__).resolve().parents[1]/'web/mobile.js').read_text(encoding='utf-8'),encoding='utf-8')
print('Mobile shell ready: landscape guidance, native name input and gesture startup.')

with (root/'mobile.css').open('a',encoding='utf-8') as css:
 css.write("\nbody.load-failed{touch-action:auto}#status.is-failed{overflow-y:auto;touch-action:pan-y;gap:14px;padding:24px 20px}#status.is-failed #status-notice{margin:0;max-width:600px;padding:14px;line-height:1.5}#status-recovery{display:flex;flex-direction:column;align-items:center;gap:12px;width:min(600px,100%)}#status-recovery[hidden]{display:none}#status-recovery p{margin:0;line-height:1.4;font-size:14px;text-align:center}#retryLoad{min-width:224px;max-width:100%}@media(max-height:430px){#status.is-failed{padding:16px 20px;gap:10px}#status.is-failed #status-notice{font-size:17px}}\n")

# Keep the complete welcome screen visible with browser bars and short landscape viewports.
with (root/'mobile.css').open('a',encoding='utf-8') as css:
 css.write("""
#welcome{grid-template-columns:minmax(0,1fr);grid-template-rows:minmax(0,1fr);overflow:hidden}
#welcome .welcome-content{width:min(700px,100%);min-width:0;transform:scale(var(--welcome-scale,1));transform-origin:center}
#welcome .small{margin-left:auto;margin-right:auto}
@media(max-height:600px){
 #welcome{padding:max(8px,env(safe-area-inset-top)) max(16px,env(safe-area-inset-right)) max(8px,env(safe-area-inset-bottom)) max(16px,env(safe-area-inset-left))}
 #welcome h1{font-size:clamp(30px,11dvh,60px);line-height:1.08;margin:4px 0}
 #welcome h2{font-size:clamp(18px,6.2dvh,27px);line-height:1.15;margin:5px 0}
 #welcome p{font-size:clamp(13px,4.7dvh,19px);line-height:1.3;margin:6px 0}
 #welcome .eyebrow{font-size:clamp(11px,3.3dvh,14px);line-height:1.2;margin:0 0 4px}
 #welcome .small{font-size:clamp(11px,3.5dvh,14px);line-height:1.3;margin:8px auto 0}
 #welcome button{font-size:clamp(16px,5.2dvh,19px);line-height:1.2;min-height:44px;padding:8px 22px}
}
""")

with (root/'mobile.css').open('a',encoding='utf-8') as css:
 css.write("\n.mobile-web #status-progress{position:fixed;top:max(16px,env(safe-area-inset-top));bottom:auto;left:50%;transform:translateX(-50%);width:min(calc(100% - 40px),720px);height:8px}\n")

shutil.copy2(Path(__file__).resolve().parents[2]/'media/abertura/museu.png',root/'welcome-museum.png')
with (root/'mobile.css').open('a',encoding='utf-8') as css:
 css.write("""
#welcome{grid-template-columns:minmax(0,1fr) minmax(0,1fr);gap:24px;padding-left:max(32px,env(safe-area-inset-left));padding-right:max(24px,env(safe-area-inset-right));background:radial-gradient(ellipse at 80% 35%,#234b50 0,transparent 55%),radial-gradient(ellipse at 90% 15%,#493823 0,transparent 48%),#0b1926}
#welcome::after{content:'';position:absolute;inset:0;pointer-events:none;z-index:1;background:linear-gradient(90deg,#091722d9,transparent 72%)}
#welcome .welcome-content{position:relative;grid-column:1;grid-row:1;z-index:3;max-width:680px;text-align:left}
#welcome-scene{position:absolute;inset:0;z-index:0;pointer-events:none;transform:translate3d(var(--scene-dx,0px),var(--scene-dy,0px),0);transition:transform .5s ease-out}
#welcome-scene img{position:absolute;top:50%;right:-4vw;width:65vw;max-width:1150px;height:auto;filter:drop-shadow(0 30px 28px #0007);animation:museum-float 8s ease-in-out infinite}
#welcome-scene::after{content:'';position:absolute;inset:-15%;opacity:.22;background:repeating-radial-gradient(circle at 75% 30%,#e9c78b 0 1px,transparent 2px 105px);animation:scene-drift 22s linear infinite}
#welcome h1{font-weight:800;background:linear-gradient(110deg,#e9c78b 15%,#fff3d3 42%,#ddb36f 58%,#fff5d8 76%,#e9c78b 92%);background-size:250% 100%;background-clip:text;-webkit-background-clip:text;color:transparent;filter:drop-shadow(0 4px 0 #16333b);animation:title-shine 7s ease-in-out infinite}
#welcome h2{font-weight:600;letter-spacing:.02em}
#welcome .eyebrow{letter-spacing:.12em}
#welcome .small{margin-left:0;margin-right:0}
#enterMuseum{position:relative;isolation:isolate;overflow:hidden;background:linear-gradient(135deg,#f6db9f,#e4ba73);border-color:#ffe7b8;box-shadow:0 10px 28px #0005,0 0 28px #e9c78b24;transition:transform .18s,box-shadow .18s;animation:entry-glow 3.5s ease-in-out infinite}
#enterMuseum::after{content:'';position:absolute;inset:-100% -50%;z-index:-1;background:linear-gradient(105deg,transparent 42%,#fff7 50%,transparent 58%);transform:translateX(-55%);animation:button-shine 5s ease-in-out infinite}
#enterMuseum:hover{transform:translateY(-2px);box-shadow:0 12px 32px #0006,0 0 35px #e9c78b44}
#enterMuseum:active{transform:translateY(0)}
@keyframes museum-float{0%,100%{transform:translateY(calc(-50% - 7px)) rotate(-.3deg)}50%{transform:translateY(calc(-50% + 7px)) rotate(.3deg)}}
@keyframes title-shine{0%,100%{background-position:0 50%}50%{background-position:100% 50%}}
@keyframes button-shine{0%,55%,100%{transform:translateX(-60%)}75%{transform:translateX(60%)}}
@keyframes entry-glow{0%,100%{box-shadow:0 10px 28px #0005,0 0 22px #e9c78b20}50%{box-shadow:0 10px 28px #0005,0 0 34px #e9c78b38}}
@keyframes scene-drift{from{transform:translateY(0)}to{transform:translateY(-55px)}}
@media(max-width:700px),(max-height:320px){#welcome{grid-template-columns:minmax(0,1fr);gap:0;padding-left:max(16px,env(safe-area-inset-left));padding-right:max(16px,env(safe-area-inset-right))}#welcome .welcome-content{grid-column:1;max-width:700px;text-align:center}#welcome .small{margin-left:auto;margin-right:auto}#welcome-scene img{width:95vw;right:-24vw;opacity:.24}#welcome::after{background:#09172288}}
@media(prefers-reduced-motion:reduce){#welcome h1,#enterMuseum,#enterMuseum::after,#welcome-scene img,#welcome-scene::after{animation:none!important}#welcome-scene img{transform:translateY(-50%)}#welcome-scene{transition:none!important}}
.reduced-motion #welcome h1,.reduced-motion #enterMuseum,.reduced-motion #enterMuseum::after,.reduced-motion #welcome-scene img,.reduced-motion #welcome-scene::after{animation:none!important}
.reduced-motion #welcome-scene img{transform:translateY(-50%)}.reduced-motion #welcome-scene{transition:none!important}
""")
