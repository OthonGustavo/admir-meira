/* v2 — interações e animações (GSAP + ScrollTrigger)
   Sem JS (ou com prefers-reduced-motion), o conteúdo fica 100% visível. */

/* Carrega o widget do Instagram (Elfsight) só quando a seção entra em vista.
   Assim o platform.js (pesado) sai do caminho crítico de carregamento. */
(function () {
  var holder = document.querySelector('[class^="elfsight-app-"]');
  if (!holder) return;
  var loaded = false;
  function loadElfsight() {
    if (loaded) return;
    loaded = true;
    var s = document.createElement('script');
    s.src = 'https://static.elfsight.com/platform/platform.js';
    s.async = true;
    document.body.appendChild(s);
  }
  if ('IntersectionObserver' in window) {
    var io = new IntersectionObserver(function (entries) {
      if (entries.some(function (e) { return e.isIntersecting; })) {
        loadElfsight();
        io.disconnect();
      }
    }, { rootMargin: '400px' });
    io.observe(holder);
  } else {
    loadElfsight();
  }
})();

(function () {
  var nav = document.querySelector('.navbar');
  var toggle = document.querySelector('.nav-toggle');
  var links = document.querySelector('.nav-links');

  /* Navbar ganha sombra ao rolar */
  function onScroll() {
    if (nav) nav.classList.toggle('scrolled', window.scrollY > 10);
  }
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  /* Menu mobile */
  if (toggle && links) {
    toggle.addEventListener('click', function () {
      links.classList.toggle('open');
    });
  }

  if (typeof gsap === 'undefined') return;
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

  gsap.registerPlugin(ScrollTrigger);
  var EASE = 'power3.out';

  /* ---- Entrada do hero (home) ---- */
  var hero = document.querySelector('.hero');
  if (hero) {
    var tl = gsap.timeline({ defaults: { ease: EASE } });
    tl.from('.hero .eyebrow', { y: 24, opacity: 0, duration: .8 })
      .from('.hero h1', { y: 44, opacity: 0, duration: 1 }, '-=.5')
      .from('.hero .lead', { y: 30, opacity: 0, duration: .9 }, '-=.65')
      .from('.hero-actions .btn', { y: 24, opacity: 0, duration: .7, stagger: .12 }, '-=.6')
      .from('.hero-scroll', { opacity: 0, duration: .8 }, '-=.3');

    /* Parallax sutil do fundo */
    gsap.to('.hero-bg', {
      yPercent: 12,
      ease: 'none',
      scrollTrigger: { trigger: hero, start: 'top top', end: 'bottom top', scrub: true }
    });
  }

  /* ---- Entrada do page-hero (páginas internas) ---- */
  var pageHero = document.querySelector('.page-hero');
  if (pageHero) {
    gsap.timeline({ defaults: { ease: EASE } })
      .from('.page-hero .breadcrumb', { y: 18, opacity: 0, duration: .7 })
      .from('.page-hero h1', { y: 34, opacity: 0, duration: .9 }, '-=.4');
  }

  /* ---- Reveals genéricos: [data-reveal] ---- */
  gsap.utils.toArray('[data-reveal]').forEach(function (el) {
    var dir = el.getAttribute('data-reveal');
    var vars = { opacity: 0, y: 34, duration: 1, ease: EASE,
                 scrollTrigger: { trigger: el, start: 'top 87%', once: true } };
    if (dir === 'left')  { vars.x = -44; vars.y = 0; }
    if (dir === 'right') { vars.x = 44;  vars.y = 0; }
    gsap.from(el, vars);
  });

  /* ---- Grupos com stagger: [data-reveal-group] anima os filhos ---- */
  gsap.utils.toArray('[data-reveal-group]').forEach(function (grid) {
    gsap.from(grid.children, {
      opacity: 0,
      y: 42,
      duration: .9,
      ease: EASE,
      stagger: .12,
      scrollTrigger: { trigger: grid, start: 'top 85%', once: true }
    });
  });

  /* ---- Contadores: [data-count="30"] ---- */
  gsap.utils.toArray('[data-count]').forEach(function (el) {
    var target = parseInt(el.getAttribute('data-count'), 10) || 0;
    var suffix = el.getAttribute('data-suffix') || '';
    var obj = { v: 0 };
    gsap.to(obj, {
      v: target,
      duration: 2,
      ease: 'power2.out',
      scrollTrigger: { trigger: el, start: 'top 88%', once: true },
      onUpdate: function () { el.textContent = Math.round(obj.v) + suffix; }
    });
  });
})();
