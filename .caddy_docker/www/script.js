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
  // enableDebug(); // Active le mode débogage
  // disableDebug(); // Désactive le mode débogage
  // toggleDebug(); // Bascule le mode débogage