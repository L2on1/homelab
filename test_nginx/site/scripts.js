function saluer() {
    alert("Salut depuis JavaScript !");
}

console.log("Script chargé");

document.getElementById("contactForm").addEventListener("submit", function (e) {
  e.preventDefault();
  console.log("Form submitted");
  document.getElementById("formMessage").textContent = "Merci pour votre message !";
});

