// 声音数据
const sounds = [
  // 自然类
  { id: 'rain', name: '雨声', category: '自然', icon: '🌧️', locked: false },
  { id: 'waves', name: '海浪', category: '自然', icon: '🌊', locked: false },
  { id: 'forest', name: '森林', category: '自然', icon: '🌲', locked: false },
  { id: 'wind', name: '风声', category: '自然', icon: '🍃', locked: false },
  { id: 'thunder', name: '雷暴', category: '自然', icon: '⚡', locked: false },
  // 环境类
  { id: 'fire', name: '篝火', category: '环境', icon: '🔥', locked: false },
  { id: 'fan', name: '风扇', category: '环境', icon: '💨', locked: false },
  { id: 'cafe', name: '咖啡馆', category: '环境', icon: '☕', locked: false },
  { id: 'train', name: '火车', category: '环境', icon: '🚂', locked: false },
  { id: 'plane', name: '飞机', category: '环境', icon: '✈️', locked: false },
  // 冥想类
  { id: 'singing', name: '颂钵', category: '冥想', icon: '🔔', locked: false },
  { id: 'binaural', name: '双脑同步', category: '冥想', icon: '🎵', locked: true },
  { id: 'delta', name: 'Delta波', category: '冥想', icon: '🧘', locked: true },
];

// 应用状态
let currentScreen = 'home';
let currentCategory = '自然';
let playingSounds = [];
let masterVolume = 0.7;
let audioContext = null;
let oscillators = {};

// 睡眠追踪状态
let isTracking = false;
let bedtime = null;
let timerInterval = null;
let sleepRecords = JSON.parse(localStorage.getItem('sleepRecords') || '[]');

// 初始化
document.addEventListener('DOMContentLoaded', () => {
  initAudio();
  renderSounds();
  bindEvents();
  updateStats();
});

// 初始化音频（使用白噪音生成）
function initAudio() {
  audioContext = new (window.AudioContext || window.webkitAudioContext)();
}

// 生成白噪音
function createNoise() {
  const bufferSize = audioContext.sampleRate * 2;
  const buffer = audioContext.createBuffer(1, bufferSize, audioContext.sampleRate);
  const output = buffer.getChannelData(0);
  
  for (let i = 0; i < bufferSize; i++) {
    output[i] = Math.random() * 2 - 1;
  }

  const noise = audioContext.createBufferSource();
  noise.buffer = buffer;
  noise.loop = true;

  const gainNode = audioContext.createGain();
  gainNode.gain.value = 0.1 * masterVolume;

  noise.connect(gainNode);
  gainNode.connect(audioContext.destination);
  noise.start();

  return { source: noise, gain: gainNode };
}

// 渲染声音网格
function renderSounds() {
  const grid = document.getElementById('sound-grid');
  const filteredSounds = sounds.filter(s => s.category === currentCategory);
  
  grid.innerHTML = filteredSounds.map(sound => `
    <div class="sound-card ${playingSounds.includes(sound.id) ? 'playing' : ''} ${sound.locked ? 'locked' : ''}" 
         data-id="${sound.id}">
      <span class="sound-icon">${sound.icon}</span>
      <div class="sound-name">${sound.name}</div>
      ${sound.locked ? '<div style="margin-top: 4px;"><span>🔒</span></div>' : ''}
      ${playingSounds.includes(sound.id) ? '<div class="playing-badge">▶</div>' : ''}
    </div>
  `).join('');

  // 绑定点击事件
  grid.querySelectorAll('.sound-card:not(.locked)').forEach(card => {
    card.addEventListener('click', () => {
      const id = card.dataset.id;
      toggleSound(id);
    });
  });

  // 更新主音量显示
  const masterVolumeEl = document.getElementById('master-volume');
  if (playingSounds.length > 0) {
    masterVolumeEl.style.display = 'block';
  } else {
    masterVolumeEl.style.display = 'none';
  }
}

// 切换声音播放
function toggleSound(id) {
  if (playingSounds.includes(id)) {
    // 停止
    if (oscillators[id]) {
      oscillators[id].gain.gain.value = 0;
      oscillators[id].source.stop();
      delete oscillators[id];
    }
    playingSounds = playingSounds.filter(s => s !== id);
  } else {
    // 播放
    if (audioContext.state === 'suspended') {
      audioContext.resume();
    }
    oscillators[id] = createNoise();
    playingSounds.push(id);
  }
  updateVolume();
  renderSounds();
}

// 更新所有音量
function updateVolume() {
  Object.values(oscillators).forEach(({ gain }) => {
    gain.gain.value = 0.1 * masterVolume;
  });
  
  document.getElementById('volume-value').textContent = `${Math.round(masterVolume * 100)}%`;
}

// 停止所有声音
function stopAll() {
  Object.values(oscillators).forEach(({ source, gain }) => {
    gain.gain.value = 0;
    source.stop();
  });
  oscillators = {};
  playingSounds = [];
  renderSounds();
}

// 绑定事件
function bindEvents() {
  // 切换分类
  document.querySelectorAll('.category-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelector('.category-btn.active').classList.remove('active');
      btn.classList.add('active');
      currentCategory = btn.dataset.category;
      renderSounds();
    });
  });

  // 主音量滑块
  document.getElementById('volume-slider').addEventListener('input', (e) => {
    masterVolume = parseFloat(e.target.value);
    updateVolume();
  });

  // 停止全部
  document.getElementById('stop-all').addEventListener('click', stopAll);

  // 底部导航切换屏幕
  document.querySelectorAll('.nav-item').forEach(btn => {
    btn.addEventListener('click', () => {
      const screen = btn.dataset.screen;
      switchScreen(screen);
    });
  });

  // 开始睡眠追踪
  document.getElementById('start-tracking').addEventListener('click', startTracking);

  // 取消追踪
  document.getElementById('cancel-tracking').addEventListener('click', cancelTracking);

  // 停止追踪
  document.getElementById('stop-tracking').addEventListener('click', () => {
    document.getElementById('quality-modal').style.display = 'flex';
  });

  // 质量评分
  document.querySelectorAll('.star-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const quality = parseInt(e.target.dataset.quality);
      stopTracking(quality);
      document.getElementById('quality-modal').style.display = 'none';
    });
  });

  // 点击遮罩关闭弹窗
  document.getElementById('quality-modal').addEventListener('click', (e) => {
    if (e.target.id === 'quality-modal') {
      e.target.style.display = 'none';
    }
  });
}

// 切换屏幕
function switchScreen(screenName) {
  document.querySelectorAll('.screen').forEach(screen => {
    screen.classList.remove('active');
  });
  document.querySelectorAll('.nav-item').forEach(nav => {
    nav.classList.remove('active');
  });
  
  document.getElementById(`${screenName}-screen`).classList.add('active');
  document.querySelector(`.nav-item[data-screen="${screenName}"]`).classList.add('active');
  currentScreen = screenName;

  if (screenName === 'stats') {
    updateStats();
  }
}

// 开始睡眠追踪
function startTracking() {
  isTracking = true;
  bedtime = new Date();
  
  document.getElementById('not-tracking').style.display = 'none';
  document.getElementById('tracking').style.display = 'block';
  
  document.getElementById('bedtime-text').textContent = 
    `入睡时间: ${formatTime(bedtime)}`;
  
  timerInterval = setInterval(updateTimer, 1000);
}

// 取消追踪
function cancelTracking() {
  isTracking = false;
  bedtime = null;
  clearInterval(timerInterval);
  document.getElementById('not-tracking').style.display = 'block';
  document.getElementById('tracking').style.display = 'none';
  stopAll();
}

// 停止追踪并保存
function stopTracking(quality) {
  const wakeTime = new Date();
  const duration = wakeTime - bedtime;
  
  const record = {
    date: new Date().toISOString(),
    bedtime: bedtime.toISOString(),
    wakeTime: wakeTime.toISOString(),
    durationMinutes: Math.floor(duration / (1000 * 60)),
    quality: quality
  };
  
  sleepRecords.unshift(record);
  localStorage.setItem('sleepRecords', JSON.stringify(sleepRecords));
  
  isTracking = false;
  clearInterval(timerInterval);
  stopAll();
  
  document.getElementById('not-tracking').style.display = 'block';
  document.getElementById('tracking').style.display = 'none';
  
  switchScreen('stats');
}

// 更新计时器
function updateTimer() {
  if (!bedtime) return;
  
  const duration = new Date() - bedtime;
  document.getElementById('sleep-timer').textContent = formatDuration(duration);
}

// 更新统计
function updateStats() {
  if (sleepRecords.length === 0) {
    document.getElementById('empty-state').style.display = 'block';
    document.getElementById('stats-data').style.display = 'none';
    return;
  }
  
  document.getElementById('empty-state').style.display = 'none';
  document.getElementById('stats-data').style.display = 'block';
  
  // 计算平均值
  const totalMinutes = sleepRecords.reduce((sum, r) => sum + r.durationMinutes, 0);
  const avgMinutes = Math.floor(totalMinutes / sleepRecords.length);
  const avgQuality = sleepRecords.reduce((sum, r) => sum + r.quality, 0) / sleepRecords.length;
  
  document.getElementById('avg-sleep').textContent = formatDurationShort(avgMinutes);
  document.getElementById('avg-quality').textContent = `${avgQuality.toFixed(1)} ⭐`;
  document.getElementById('total-days').textContent = `${sleepRecords.length}`;
  
  // 渲染最近记录
  const recordsList = document.getElementById('records-list');
  const recent = sleepRecords.slice(0, 10);
  
  recordsList.innerHTML = recent.map(record => {
    const date = new Date(record.date);
    const bd = new Date(record.bedtime);
    const wt = new Date(record.wakeTime);
    return `
      <div class="record-item">
        <div class="record-avatar">${record.quality}⭐</div>
        <div class="record-info">
          <div class="record-date">${formatDate(date)}</div>
          <div class="record-time">${formatTime(bd)} - ${formatTime(wt)}</div>
        </div>
        <div class="record-duration">${formatDurationShort(record.durationMinutes)}</div>
      </div>
    `;
  }).join('');
}

// 格式化工具
function formatTime(date) {
  return `${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`;
}

function formatDate(date) {
  return `${date.getMonth() + 1}月${date.getDate()}日`;
}

function formatDuration(ms) {
  const totalSeconds = Math.floor(ms / 1000);
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;
  return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
}

function formatDurationShort(totalMinutes) {
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;
  return `${hours}h${minutes}m`;
}
