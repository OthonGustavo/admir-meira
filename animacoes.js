/* Animações do site (GSAP + ScrollTrigger)
   Entradas suaves no carregamento e reveals no scroll.
   Sem JS (ou com prefers-reduced-motion), o site fica 100% visível. */
(function () {
  if (typeof gsap === 'undefined') return;
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

  gsap.registerPlugin(ScrollTrigger);

  var EASE = 'power3.out';

  /* ---- Entrada do cabeçalho ---- */
  gsap.from('.logo img', { y: -18, opacity: 0, duration: .9, ease: EASE });
  gsap.from('.main-nav a', {
    y: -10, opacity: 0, duration: .6, ease: EASE,
    stagger: .06, delay: .25
  });

  /* ---- Reveal genérico no scroll ---- */
  function reveal(selector, vars) {
    gsap.utils.toArray(selector).forEach(function (el) {
      gsap.from(el, Object.assign({
        opacity: 0,
        y: 28,
        duration: .9,
        ease: EASE,
        scrollTrigger: { trigger: el, start: 'top 88%', once: true }
      }, vars || {}));
    });
  }

  reveal('.section-title');
  reveal('.bloco-titulo');
  reveal('.informativo-banner');
  reveal('.banner-breve');
  reveal('.form-wrap');
  reveal('.contato-info', { x: -30, y: 0 });
  reveal('.contato-mapa', { x: 30, y: 0 });
  reveal('.ti-texto', { x: -30, y: 0 });
  reveal('.ti-imagem', { x: 30, y: 0, scale: .97 });
  reveal('.redes-icons');
  reveal('.whats-btn-wrap');
  reveal('.agendamento-grid');

  /* ---- Grades com stagger (cards, tribunais, whatsapps) ---- */
  function revealGrid(containerSel, itemSel) {
    gsap.utils.toArray(containerSel).forEach(function (grid) {
      var items = grid.querySelectorAll(itemSel);
      if (!items.length) return;
      gsap.from(items, {
        opacity: 0,
        y: 36,
        duration: .8,
        ease: EASE,
        stagger: .12,
        scrollTrigger: { trigger: grid, start: 'top 85%', once: true }
      });
    });
  }

  revealGrid('.cards', '.card');
  revealGrid('.tribunais', '.tribunal');
  revealGrid('.whats-container', '.whats-wrap');
})();
