"""Prepare the static entry, web/ assets and licenses from a fresh Web export."""
from pathlib import Path
import gzip
import shutil
import sys

ROOT=Path(__file__).resolve().parents[1]

def prepare(source: Path, destination: Path) -> None:
    source=source.resolve();destination=destination.resolve()
    if source==destination:
        raise ValueError('Use a separate output directory')
    assets=destination/'web';assets.mkdir(parents=True,exist_ok=True)
    for p in source.iterdir():
        if p.is_file() and p.name not in ('index.html','index.wasm','.nojekyll','_headers'):
            shutil.copy2(p,assets/p.name)
    licenses=destination/'licenses';licenses.mkdir(exist_ok=True)
    for name in ('GODOT-LICENSE.txt','THIRD-PARTY-LICENSES.json','OFL-Symbols.txt','OFL-Emoji.txt'):
        shutil.copy2(ROOT/'licenses'/name,licenses/name)
    (destination/'.nojekyll').write_text('',encoding='utf-8')
    (assets/'index.wasm.gz').write_bytes(gzip.compress((source/'index.wasm').read_bytes(),compresslevel=9,mtime=0))
    html=(source/'index.html').read_text(encoding='utf-8')
    html=html.replace('lang="en"','lang="pt-BR"').replace('Your browser does not support the canvas tag.','Seu navegador não suporta o jogo.').replace('Your browser does not support JavaScript.','Ative JavaScript para jogar.')
    html=html.replace('background-color: #242424;','background-color: #10202d;')
    # Set the base before styles/icons load. The browser address and storage origin stay unchanged.
    html=html.replace('<head>','<head>\n<base href="./web/">',1)
    html=html.replace('location.href','document.baseURI')
    html=html.replace('<div id="status">','<div id="status"><div style="font:24px Georgia,serif;color:#e9c78b;letter-spacing:3px">P.A.RADOXO</div><p id="status-subtitle" style="font:16px Arial;color:#b4c6ce">Preparando o museu…</p>')
    shim='''<script>
const originalFetch=window.fetch.bind(window);
window.fetch=async function(input,options){
 const url=new URL(typeof input==='string'?input:input.url,document.baseURI);
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
    (destination/'index.html').write_text(html,encoding='utf-8')
    (destination/'_headers').write_text('/*\n  X-Content-Type-Options: nosniff\n/web/index.wasm.gz\n  Content-Type: application/octet-stream\n',encoding='utf-8')
    print('Static site ready: index.html, web/ and licenses/.')

if __name__=='__main__':
    prepare(Path(sys.argv[1]),Path(sys.argv[2]))
