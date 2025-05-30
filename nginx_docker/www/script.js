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
    const artAsciiPre = document.querySelector('.art_ascii');
    const projetsAsciiPre = document.querySelector('.projets_ascii');
    const archivesAsciiPre = document.querySelector('.archives_ascii');
  
    function handleClickAndRedirect(element, path) {
      if (element) {
        element.addEventListener('click', function() {
          this.classList.add('invert');
          setTimeout(function() {
            window.location.href = path; // Utilisation du chemin relatif
          }, 300);
        });
      }
    }
  
    handleClickAndRedirect(artAsciiPre, './art.html');      // Chemin relatif pour la page "art"
    handleClickAndRedirect(projetsAsciiPre, './projets.html'); // Chemin relatif pour la page "projets"
    handleClickAndRedirect(archivesAsciiPre, './archives.html'); // Chemin relatif pour la page "archives"
  });