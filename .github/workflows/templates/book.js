(function() {
  let config = null;
  let currentChapter = 0;
  
  async function init() {
    try {
      const response = await fetch('chapters.json');
      config = await response.json();
      renderTOC();
      loadLanguageSelector();
      
      const hash = window.location.hash.slice(1);
      const initialFile = hash || (config.chapters[0] && config.chapters[0].file);
      if (initialFile) loadChapter(initialFile);
    } catch (err) {
      document.getElementById('chapter-content').innerHTML = '<p>Error loading book.</p>';
    }
  }
  
  function renderTOC() {
    const toc = document.getElementById('toc');
    if (!toc || !config) return;
    
    const ul = document.createElement('ul');
    config.chapters.forEach((chapter, index) => {
      const li = document.createElement('li');
      const a = document.createElement('a');
      a.href = '#' + chapter.file;
      a.textContent = chapter.title;
      a.dataset.index = index;
      a.addEventListener('click', (e) => {
        e.preventDefault();
        loadChapter(chapter.file);
      });
      li.appendChild(a);
      ul.appendChild(li);
    });
    toc.appendChild(ul);
  }
  
  function loadLanguageSelector() {
    const select = document.getElementById('lang-select');
    if (!select) return;
    
    fetch('../languages.json')
      .then(r => r.json())
      .then(langs => {
        select.innerHTML = langs.map(l => 
          '<option value="' + l.code + '"' + (l.code === config.lang ? ' selected' : '') + '>' + l.name + '</option>'
        ).join('');
        select.addEventListener('change', (e) => {
          const currentFile = config.chapters[currentChapter]?.file;
          window.location.href = '../' + e.target.value + '/#' + currentFile;
        });
      })
      .catch(() => {
        select.innerHTML = '<option>' + config.lang + '</option>';
      });
  }
  
  async function loadChapter(filename) {
    const contentDiv = document.getElementById('chapter-content');
    if (!contentDiv || !config) return;
    
    contentDiv.innerHTML = '<div class="loading">Loading...</div>';
    
    const chapterIndex = config.chapters.findIndex(c => c.file === filename);
    if (chapterIndex === -1) {
      contentDiv.innerHTML = '<p>Chapter not found.</p>';
      return;
    }
    
    currentChapter = chapterIndex;
    
    try {
      const response = await fetch(filename);
      if (!response.ok) throw new Error('Failed to load');
      const html = await response.text();
      
      const parser = new DOMParser();
      const doc = parser.parseFromString(html, 'text/html');
      
      contentDiv.innerHTML = '';
      while (doc.body.firstChild) {
        contentDiv.appendChild(doc.body.firstChild);
      }
      
      window.history.replaceState(null, null, '#' + filename);
      updateNavigation();
      updateTOCActive();
      window.scrollTo(0, 0);
      
      const chapter = config.chapters[chapterIndex];
      document.title = chapter.title + ' | ' + config.title;
    } catch (err) {
      contentDiv.innerHTML = '<p>Error loading chapter: ' + err.message + '</p>';
    }
  }
  
  function updateNavigation() {
    const prevBtn = document.getElementById('prev-btn');
    const nextBtn = document.getElementById('next-btn');
    if (prevBtn) prevBtn.disabled = currentChapter === 0;
    if (nextBtn) nextBtn.disabled = currentChapter >= config.chapters.length - 1;
  }
  
  function updateTOCActive() {
    document.querySelectorAll('.toc a').forEach((a, index) => {
      a.classList.toggle('active', index === currentChapter);
    });
  }
  
  function goToPrev() {
    if (currentChapter > 0) {
      loadChapter(config.chapters[currentChapter - 1].file);
    }
  }
  
  function goToNext() {
    if (currentChapter < config.chapters.length - 1) {
      loadChapter(config.chapters[currentChapter + 1].file);
    }
  }
  
  document.addEventListener('DOMContentLoaded', init);
  document.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowLeft') goToPrev();
    if (e.key === 'ArrowRight') goToNext();
  });
})();
