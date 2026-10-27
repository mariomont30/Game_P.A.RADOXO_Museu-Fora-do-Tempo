"""Prepare a compressed static site from a freshly prepared Web export."""
from pathlib import Path
import shutil,gzip,sys
base=Path(__file__).resolve().parents[1]
source=Path(sys.argv[1]).resolve()
dest=Path(sys.argv[2]).resolve();dest.mkdir(parents=True,exist_ok=True)
if source==dest: raise ValueError('Use a separate output directory')
for p in source.iterdir():
    if p.is_file() and p.suffix!='.wasm': shutil.copy2(p,dest/p.name)
(dest/'licenses').mkdir(exist_ok=True)
for name in ['GODOT-LICENSE.txt','THIRD-PARTY-LICENSES.json','OFL-Symbols.txt','OFL-Emoji.txt']:
    shutil.copy2(base/'licenses'/name,dest/'licenses'/name)
(dest/'.nojekyll').write_text('',encoding='utf-8')
(dest/'index.wasm.gz').write_bytes(gzip.compress((source/'index.wasm').read_bytes(),compresslevel=9,mtime=0))
html=(dest/'index.html').read_text(encoding='utf-8')
html=html.replace('lang="en"','lang="pt-BR"').replace('Your browser does not support the canvas tag.','Seu navegador não suporta o jogo.').replace('Your browser does not support JavaScript.','Ative JavaScript para jogar.')
html=html.replace('background-color: #242424;','background-color: #10202d;')
html=html.replace('<div id="status">','<div id="status"><div style="font:24px Georgia,serif;color:#e9c78b;letter-spacing:3px">P.A.RADOXO</div><p id="status-subtitle" style="font:16px Arial;color:#b4c6ce">Preparando o museu…</p>')
shim='''<script>
const originalFetch=window.fetch.bind(window);
window.fetch=async function(input,options){
 const url=new URL(typeof input==='string'?input:input.url,location.href);
 if(url.pathname.endsWith('/index.wasm')){
   url.pathname+='.gz';
   const response=await originalFetch(url.href,options);
   if(!response.ok) return response;
   if(typeof DecompressionStream==='undefined') throw new Error('Use um navegador atualizado para abrir o museu.');
   const headers=new Headers(response.headers);
   headers.delete('Content-Length');headers.delete('Content-Encoding');
   headers.set('Content-Type','application/wasm');
   return new Response(response.body.pipeThrough(new DecompressionStream('gzip')),{status:response.status,headers});
 }
 return originalFetch(input,options);
};
</script>'''
html=html.replace('<script src="index.js"></script>',shim+'\n<script src="index.js"></script>')
(dest/'index.html').write_text(html,encoding='utf-8')
(dest/'_headers').write_text('/*\n  X-Content-Type-Options: nosniff\n/index.wasm.gz\n  Content-Type: application/octet-stream\n',encoding='utf-8')
print('Static site prepared. Compressed WASM:',(dest/'index.wasm.gz').stat().st_size)
