// Fonction pour activer le mode débogage
function enableDebug() {
    document.body.classList.add('debug'); // Ajoute la classe 'debug' au <body>
    console.log('Mode débogage activé');
  }
  
  // Fonction pour désactiver le mode débogage
  function disableDebug() {
    document.body.classList.remove('debug'); // Retire la classe 'debug' du <body>
    console.log('Mode débogage désactivé');
  }
  
  // Fonction pour basculer entre activé/désactivé
  function toggleDebug() {
    document.body.classList.toggle('debug'); // Ajoute ou retire la classe 'debug'
    console.log('Mode débogage basculé');
  }
  
  // Exemple d'utilisation
   enableDebug(); // Active le mode débogage
  // disableDebug(); // Désactive le mode débogage
  // toggleDebug(); // Bascule le mode débogage

  // ----------- //
  document.addEventListener('DOMContentLoaded', function() {
    const artsAscii_click =document.getElementById('arts_ascii')
    const projetsAscii_click = document.getElementById('projets_ascii');
    const archivesAscii_click = document.getElementById('archives_ascii');
    const haribonLogo_click = document.getElementById('haribon_logo_home');
  
    function handleClickAndRedirect(element, path) {
      if (element) {
        element.addEventListener('click', function() {
          this.classList.add('invert');
          setTimeout(function() {
            window.location.href = path;
          }, 300);
        });
      }
    }

    handleClickAndRedirect(artsAscii_click, '/arts.html');
    handleClickAndRedirect(projetsAscii_click, '/projects.html');
    handleClickAndRedirect(archivesAscii_click, '/archives.html');
    handleClickAndRedirect(haribonLogo_click, '/index.html');
  });