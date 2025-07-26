window.addEventListener('message', function (event) {
  const data = event.data;

  // 🟢 Mise à jour des jauges faim/soif/alcool
  if (data.action === 'updateStatus') {
    const hunger = Math.max(0, Math.min(100, data.hunger));
    const thirst = Math.max(0, Math.min(100, data.thirst));
    const alcohol = Math.max(0, Math.min(100, data.alcohol || 0));

    document.getElementById('hunger-bar').style.width = hunger + '%';
    document.getElementById('thirst-bar').style.width = thirst + '%';
    document.getElementById('alcohol-bar').style.width = alcohol + '%';

    document.querySelector('.hunger').style.border = hunger <= 25 ? '1px solid red' : '1px solid rgba(255,255,255,0.08)';
    document.querySelector('.thirst').style.border = thirst <= 25 ? '1px solid #2196f3' : '1px solid rgba(255,255,255,0.08)';
    document.querySelector('.alcohol').style.display = alcohol > 0 ? 'flex' : 'none';
  }

  if (data.action === 'warnHunger') {
    document.querySelector('.hunger .bar').classList.add('blink');
  }

  if (data.action === 'clearHunger') {
    document.querySelector('.hunger .bar').classList.remove('blink');
  }

  if (data.action === 'warnThirst') {
    document.querySelector('.thirst .bar').classList.add('blink');
  }

  if (data.action === 'clearThirst') {
    document.querySelector('.thirst .bar').classList.remove('blink');
  }

  // Commandes d'affichage/masquage global
  if (data.action === 'hideAll') {
    document.getElementById('hud').style.display = 'none';
  }

  if (data.action === 'showAll') {
    document.getElementById('hud').style.display = 'flex';
  }
});
