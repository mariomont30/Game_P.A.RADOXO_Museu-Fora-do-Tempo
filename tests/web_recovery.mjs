/** Test the exported Web directory. npm install --no-save playwright-core
 * BROWSER_EXECUTABLE=/path/to/chrome node tests/web_recovery.mjs /path/to/site /path/to/report
 * Uses isolated browser profiles and a local HTTP server. Never reads personal saves.
 */
import {createRequire} from 'node:module';
import http from 'node:http';
import fs from 'node:fs/promises';
import path from 'node:path';
import assert from 'node:assert/strict';
const {chromium}=createRequire(import.meta.url)('playwright-core');
const root=path.resolve(process.argv[2]||'.');
const output=path.resolve(process.argv[3]||'test-results/web-recovery');
await fs.mkdir(output,{recursive:true});
const types={'.html':'text/html','.js':'application/javascript','.css':'text/css','.png':'image/png','.wasm':'application/wasm'};
const server=http.createServer(async(req,res)=>{
  try {
    let name=decodeURIComponent(new URL(req.url,'http://localhost').pathname);
    if(name==='/') name='/index.html';
    const file=path.resolve(root,'.'+name);
    if(path.relative(root,file).startsWith('..')) throw Error('outside root');
    const bytes=await fs.readFile(file);
    res.writeHead(200,{'Content-Type':types[path.extname(file)]||'application/octet-stream'});res.end(bytes);
  }catch{res.writeHead(404);res.end();}
});
await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
const url='http://127.0.0.1:'+server.address().port+'/';
const browser=await chromium.launch({executablePath:process.env.BROWSER_EXECUTABLE||undefined,headless:true,args:['--no-sandbox','--no-proxy-server','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
const report={cases:[],errors:[]};
const sentinel=async(page,write)=>page.evaluate(async(write)=>{
  const db=await new Promise((resolve,reject)=>{const r=indexedDB.open('recovery-test',1);r.onupgradeneeded=()=>r.result.createObjectStore('saved');r.onsuccess=()=>resolve(r.result);r.onerror=()=>reject(r.error);});
  const value=await new Promise((resolve,reject)=>{const tx=db.transaction('saved',write?'readwrite':'readonly');const store=tx.objectStore('saved');const r=write?store.put({id:'jornada-teste',question:42,lives:1},'journey'):store.get('journey');let result;r.onsuccess=()=>{result=r.result;};tx.oncomplete=()=>resolve(result);tx.onerror=()=>reject(tx.error);});
  db.close();return value;
},write);
try {
  for(const test of [
    {name:'desktop-pck',pattern:'**/index.pck*',mobile:false},
    {name:'mobile-pck',pattern:'**/index.pck*',mobile:true},
    {name:'mobile-wasm',pattern:'**/index.wasm*',mobile:true},
    {name:'desktop-engine-script',pattern:'**/index.js',mobile:false},
    {name:'mobile-helper-script',pattern:'**/mobile.js*',mobile:true}
  ]){
    const context=await browser.newContext({viewport:test.mobile?{width:844,height:390}:{width:1280,height:800},isMobile:test.mobile,hasTouch:test.mobile});
    const page=await context.newPage();let intercepted=0;
    const errors=[];page.on('pageerror',e=>errors.push(e.message));
    await page.goto(url,{waitUntil:'domcontentloaded'});await sentinel(page,true);
    await page.route(test.pattern,route=>{intercepted++;return route.abort('failed');});
    await page.reload({waitUntil:'domcontentloaded'});
    if(!test.name.includes('script')) await page.getByRole('button',{name:'Entrar no museu',exact:true}).click();
    const retry=page.getByRole('button',{name:'Tentar novamente',exact:true});
    await retry.waitFor({state:'visible',timeout:90000});
    assert.ok(intercepted>0);assert.equal(await retry.isEnabled(),true);
    const text=await page.locator('#status-notice').innerText();
    assert.match(text,/Não foi possível carregar o museu/);assert.doesNotMatch(text,/Failed to fetch|Error:/);
    const bounds=await retry.boundingBox();const viewport=page.viewportSize();
    assert.ok(bounds.x>=0&&bounds.y>=0&&bounds.x+bounds.width<=viewport.width+1&&bounds.y+bounds.height<=viewport.height+1);
    await page.screenshot({path:path.join(output,test.name+'.png')});
    await page.unroute(test.pattern);
    await Promise.all([page.waitForNavigation({waitUntil:'domcontentloaded'}),retry.click()]);
    assert.deepEqual(await sentinel(page,false),{id:'jornada-teste',question:42,lives:1});
    await page.getByRole('button',{name:'Entrar no museu',exact:true}).click();
    await page.waitForFunction(()=>window.paradoxo?.ready===true,null,{timeout:90000});
    assert.equal(await page.locator('#retryLoad').count(),0);
    assert.deepEqual(errors,[]);
    report.cases.push({...test,intercepted,recovered:true,indexedDBPreserved:true,retryWithinViewport:true});
    await context.close();console.log('PASS '+test.name);
  }
  // Rapid activation must start exactly one engine, including a rejected start.
  const page=await browser.newPage();await page.goto(url,{waitUntil:'domcontentloaded'});
  const starts=await page.evaluate(async()=>{let calls=0;window.paradoxo.start=()=>{calls++;return Promise.reject(new Error('simulated failure'));};for(let i=0;i<10;i++)window.paradoxo.launch();await Promise.resolve();window.paradoxo.launch();return calls;});
  assert.equal(starts,1);await page.getByRole('button',{name:'Tentar novamente',exact:true}).waitFor();
  report.cases.push({name:'repeated-activation',engineStarts:starts,retryVisible:true});
  report.validated=true;
}catch(error){report.errors.push(String(error));process.exitCode=1;}
finally{await fs.writeFile(path.join(output,'results.json'),JSON.stringify(report,null,2));await browser.close();await new Promise(resolve=>server.close(resolve));console.log(JSON.stringify(report));}
