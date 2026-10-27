/** Check the complete welcome screen without scrolling. Same setup as web_recovery.mjs. */
import {createRequire} from 'node:module';import http from 'node:http';import fs from 'node:fs/promises';import path from 'node:path';import assert from 'node:assert/strict';
const {chromium}=createRequire(import.meta.url)('playwright-core');
const root=path.resolve(process.argv[2]||'.'),output=path.resolve(process.argv[3]||'test-results/web-welcome');await fs.mkdir(output,{recursive:true});
const types={'.html':'text/html','.css':'text/css','.js':'application/javascript','.png':'image/png'};
const server=http.createServer(async(req,res)=>{try{let rel=new URL(req.url,'http://localhost').pathname;if(rel==='/')rel='/index.html';const p=path.resolve(root,'.'+decodeURIComponent(rel));if(path.relative(root,p).startsWith('..'))throw Error();const data=await fs.readFile(p);res.writeHead(200,{'Content-Type':types[path.extname(p)]||'application/octet-stream'});res.end(data);}catch{res.writeHead(404);res.end();}});await new Promise(r=>server.listen(0,'127.0.0.1',r));
const browser=await chromium.launch({executablePath:process.env.BROWSER_EXECUTABLE||undefined,headless:true,args:['--no-sandbox','--no-proxy-server','--use-angle=swiftshader','--enable-unsafe-swiftshader']});const report={cases:[],errors:[]};
try{
 for(const [width,height] of [[1280,800],[1024,600],[915,412],[844,390],[740,360],[667,320],[640,280],[568,240],[480,216]]){
  const mobile=width<1000,context=await browser.newContext({viewport:{width,height},isMobile:mobile,hasTouch:mobile});const page=await context.newPage();page.on('pageerror',e=>report.errors.push(e.message));
  await page.goto('http://127.0.0.1:'+server.address().port+'/',{waitUntil:'domcontentloaded'});await page.evaluate(()=>document.fonts.ready);await page.waitForTimeout(200);
  const measure=()=>page.evaluate(()=>{const view={width:innerWidth,height:innerHeight},welcome=document.getElementById('welcome');const rects=Array.from(welcome.querySelectorAll('h1,h2,p,button')).map(e=>{const b=e.getBoundingClientRect();return {tag:e.tagName,text:e.textContent,x:b.x,y:b.y,width:b.width,height:b.height};});return {view,overflow:getComputedStyle(welcome).overflowY,scrollY,rects};});
  for(const enlarged of [false,true]){
   if(enlarged){await page.evaluate(()=>{for(const e of document.querySelectorAll('#welcome h1,#welcome h2,#welcome p,#welcome button'))e.style.fontSize=(parseFloat(getComputedStyle(e).fontSize)*1.4)+'px';});await page.waitForTimeout(200);}
   const result=await measure();assert.equal(result.overflow,'hidden');assert.equal(result.scrollY,0);
   for(const r of result.rects){assert.ok(r.x>=-.5&&r.y>=-.5&&r.x+r.width<=width+.5&&r.y+r.height<=height+.5,JSON.stringify({width,height,enlarged,rect:r}));}
   assert.ok(result.rects.find(r=>r.tag==='BUTTON').height>=30,'Entry remains usable even on short screens with enlarged text');
   report.cases.push({width,height,enlarged,completeWithoutScroll:true});
   if(!enlarged&&[800,390,240,216].includes(height))await page.screenshot({path:path.join(output,width+'x'+height+'.png')});
  }
  await context.close();
 }
 // Loading position and motion preferences apply before the engine is ready.
 for(const mobile of [true,false]){
  const context=await browser.newContext({viewport:mobile?{width:844,height:390}:{width:1280,height:800},isMobile:mobile,hasTouch:mobile});const page=await context.newPage();
  await page.goto('http://127.0.0.1:'+server.address().port+'/',{waitUntil:'domcontentloaded'});
  await page.evaluate(()=>{document.getElementById('welcome').style.display='none';const s=document.getElementById('status');s.style.visibility='visible';const p=document.getElementById('status-progress');p.style.display='block';p.value=.4;});
  const position=await page.locator('#status-progress').evaluate(e=>({top:e.getBoundingClientRect().top,position:getComputedStyle(e).position}));
  if(mobile){assert.equal(position.position,'fixed');assert.ok(position.top>=0&&position.top<=32);await page.screenshot({path:path.join(output,'mobile-loading-top.png')});}else assert.notEqual(position.position,'fixed');
  await page.evaluate(()=>window.paradoxo.setReduced(true));await page.reload();
  assert.equal(await page.locator('#welcome-scene img').evaluate(e=>getComputedStyle(e).animationName),'none');
  await page.evaluate(()=>window.paradoxo.setReduced(false));await page.emulateMedia({reducedMotion:'reduce'});
  assert.equal(await page.locator('#welcome-scene img').evaluate(e=>getComputedStyle(e).animationName),'none');
  report.cases.push({mobile,loadingPosition:mobile?'top':'unchanged',savedReducedMotion:true,systemReducedMotion:true});await context.close();
 }
 // The address-bar/orientation resize must recompute the fit without retaining a smaller scale.
 const context=await browser.newContext({viewport:{width:844,height:390},isMobile:true,hasTouch:true});const page=await context.newPage();await page.goto('http://127.0.0.1:'+server.address().port+'/',{waitUntil:'domcontentloaded'});
 for(const viewport of [{width:640,height:260},{width:915,height:412},{width:844,height:390}]){await page.setViewportSize(viewport);await page.waitForTimeout(200);const box=await page.locator('#welcome .small').boundingBox();assert.ok(box.y+box.height<=viewport.height+.5);}
 report.cases.push({resize:true,completeWithoutScroll:true});await context.close();assert.deepEqual(report.errors,[]);report.validated=true;
}catch(error){report.errors.push(String(error));process.exitCode=1;}finally{await fs.writeFile(path.join(output,'results.json'),JSON.stringify(report,null,2));console.log(JSON.stringify(report));await browser.close();await new Promise(r=>server.close(r));}
