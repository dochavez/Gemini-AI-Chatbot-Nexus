from flask import Flask, request, jsonify, render_template
from google.cloud import texttospeech
from gemini_api_consume import get_gemini_response
import os
import io

app = Flask(__name__)

# Configurar la autenticación para Text-to-Speech
credentials_path = 'geminiai-text-to-speech.json'


client = texttospeech.TextToSpeechClient.from_service_account_json(credentials_path)

def generate_audio(text):
    # Configurar la solicitud de síntesis de voz
    input_text = texttospeech.SynthesisInput(text=text)
    voice_params = texttospeech.VoiceSelectionParams(language_code="es-ES", name="es-ES-Wavenet-D")
    audio_config = texttospeech.AudioConfig(audio_encoding=texttospeech.AudioEncoding.MP3)

    # Realizar la solicitud a la API de Text-to-Speech
    response = client.synthesize_speech(input=input_text, voice=voice_params, audio_config=audio_config)

    # Devolver el contenido de audio
    return response.audio_content


@app.route('/generate-world', methods=['POST'])
def generate_world():
    # Obtiene la instrucción del usuario del cuerpo de la solicitud JSON
    prompt = request.form['txt-promp']
    answer = get_gemini_response(prompt)

    # Generar audio para la respuesta de la IA
    audio_content = generate_audio(answer)

    # Devolver la respuesta y el audio en formato MP3
    return render_template('index.html', geminianswer=answer, audio_content=audio_content)

@app.route('/', methods=['GET'])
def index():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
