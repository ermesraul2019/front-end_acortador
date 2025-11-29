const form = document.getElementById("shorten-form");
const result = document.getElementById("result");
const shortUrlInput = document.getElementById("short-url");
const copyBtn = document.getElementById("copy-btn");

const BACKEND_URL = "https://TU_API/shorten";

form.addEventListener("submit", async (e) => {
  e.preventDefault();
  const longUrl = document.getElementById("url-input").value.trim();

  if (!longUrl) {
    alert("❌ Por favor, escribe una URL válida.");
    return;
  }

  try {
    const res = await fetch(BACKEND_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ url: longUrl }),
    });

    if (!res.ok) {
      console.log("Error:", await res.text());
      alert("❌ El backend no respondió correctamente.");
      return;
    }

    const data = await res.json();
    console.log("Respuesta backend:", data);

    if (!data.code) {
      alert("❌ El backend no está enviando un código.");
      return;
    }

    const shortLink = `${window.location.origin}/short/${data.code}`;

    shortUrlInput.value = shortLink;
    result.classList.remove("hidden");

  } catch (err) {
    console.error("ERROR:", err);
    alert("❌ No se pudo conectar con el backend.");
  }
});

copyBtn.addEventListener("click", () => {
  navigator.clipboard.writeText(shortUrlInput.value);
  copyBtn.textContent = "Copiado ✓";
  setTimeout(() => (copyBtn.textContent = "Copiar"), 1500);
});
