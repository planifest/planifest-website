// Theme Management
const setTheme = (theme: 'light' | 'dark') => {
  document.documentElement.setAttribute('data-theme', theme);
  localStorage.setItem('planifest-theme', theme);
};

const getPreferredTheme = () => {
  const saved = localStorage.getItem('planifest-theme');
  if (saved) return saved as 'light' | 'dark';
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
};

import mermaid from 'mermaid';

// Initialize Theme
setTheme(getPreferredTheme());

// Initialize Mermaid
mermaid.initialize({
  startOnLoad: true,
  theme: getPreferredTheme() === 'dark' ? 'dark' : 'default',
  securityLevel: 'loose',
});

document.addEventListener('DOMContentLoaded', () => {
  // Re-run theme check for mermaid if needed
  const theme = getPreferredTheme();
  mermaid.initialize({ theme: theme === 'dark' ? 'dark' : 'default' });
  mermaid.run();
  // Theme Toggle Button Logic
  const toggleBtn = document.getElementById('theme-toggle');
  
  if (toggleBtn) {
    toggleBtn.addEventListener('click', () => {
      const current = document.documentElement.getAttribute('data-theme');
      const newTheme = current === 'light' ? 'dark' : 'light';
      setTheme(newTheme);
      
      // Update mermaid theme
      mermaid.initialize({ theme: newTheme === 'dark' ? 'dark' : 'default' });
      // We often need a page reload or a manual re-render of SVGs for Mermaid
      // but simple site usually just force re-render
      location.reload(); // Simplest way to ensure all SVGs re-render with the correct theme
    });
  }

  // Smooth Scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (this: HTMLAnchorElement, e) {
      const targetId = this.getAttribute('href');
      if (!targetId || targetId === '#') return;
      
      const targetElement = document.querySelector(targetId);
      if (targetElement) {
        e.preventDefault();
        targetElement.scrollIntoView({
          behavior: 'smooth'
        });
      }
    });
  });

  // Reveal animations on scroll
  const revealElements = document.querySelectorAll('.reveal');
  
  const revealOnScroll = () => {
    const windowHeight = window.innerHeight;
    const elementVisible = 100;

    revealElements.forEach(el => {
      const elementTop = el.getBoundingClientRect().top;
      if (elementTop < windowHeight - elementVisible) {
        el.classList.add('fade-in-up');
        el.classList.remove('reveal'); // only animate once
      }
    });
  };

  window.addEventListener('scroll', revealOnScroll);
  // Trigger once on load
  revealOnScroll();

  // Highlight active nav based on scroll position - Optional generic logic
  // --- MOBILE NAV TOGGLE LOGIC ---
  const hamburgerBtns = document.querySelectorAll('.hamburger-btn');
  const navLinks = document.querySelector('.nav-links');

  const toggleMenu = async () => {
    if (navLinks) {
      if (!navLinks.hasAttribute('data-loaded')) {
        await loadDocsIntoNav();
        navLinks.setAttribute('data-loaded', 'true');
      }
      navLinks.classList.toggle('show');
    }
  };

  async function loadDocsIntoNav() {
    try {
      const isInDocsDir = window.location.pathname.includes('/docs/');
      const fetchPath = isInDocsDir ? '../src/sitemap-data.json' : './src/sitemap-data.json';
      const res = await fetch(fetchPath);
      const data = await res.json();

      let extraLinksHTML = '<hr style="border:0; height:1px; background:var(--glass-border); width:100%; margin: 0.5rem 0;">';
      data.forEach((item: any) => {
        // Skip Master Plan if it's already hardcoded
        if (item.file.includes('p001')) return; 
        const href = isInDocsDir ? `./${item.file}` : `./docs/${item.file}`;
        extraLinksHTML += `<a href="${href}" class="nav-link">${item.title}</a>`;
      });
      if (navLinks) navLinks.innerHTML += extraLinksHTML;
    } catch(e) {
      console.error("Failed to load nav docs:", e);
    }
  }

  hamburgerBtns.forEach(btn => btn.addEventListener('click', toggleMenu));

});
