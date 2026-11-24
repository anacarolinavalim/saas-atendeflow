function togglePassword(button){const input=button.parentElement.querySelector('input');input.type=input.type==='password'?'text':'password';button.textContent=input.type==='password'?'ver':'ocultar'}
document.querySelectorAll('dialog[open]').forEach(d=>{if(typeof d.showModal==='function'&&!d.open)d.showModal()});
document.querySelectorAll('[data-close]').forEach(x=>x.addEventListener('click',()=>x.closest('dialog')?.close()));
