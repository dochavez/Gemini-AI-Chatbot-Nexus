const submitButton = document.getElementById('submit-button');
const promptInput = document.getElementById('prompt');
const responseText = document.getElementById('response-text');

submitButton.addEventListener('click', async () => {
  const prompt = promptInput.value;
  run();

  // Reemplaza con la URL real del punto final de tu API backend
  const url = 'http://localhost:5000/generate-world'; // Reemplaza con tu URL real


  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ prompt })
    });

    const data = await response.json();
    responseText.textContent = data.response;
  } catch (error) {
    console.error(error);
   
    responseText.textContent = 'Error: No se pudo comunicar con la IA.';
  }
});
