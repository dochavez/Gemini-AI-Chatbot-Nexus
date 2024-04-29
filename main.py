from flask import Flask, request, jsonify, render_template
from google.cloud import texttospeech
from gemini_api_consume import get_gemini_response
import os
import io

app = Flask(__name__)

# Set up authentication for Text-to-Speech
credentials_path = 'geminiai-text-to-speech.json'


client = texttospeech.TextToSpeechClient.from_service_account_json(credentials_path)

def generate_audio(text):
    # Configure the speech synthesis request
    input_text = texttospeech.SynthesisInput(text=text)
    voice_params = texttospeech.VoiceSelectionParams(language_code="en-US", name="en-US-Neural2-I")
    audio_config = texttospeech.AudioConfig(audio_encoding=texttospeech.AudioEncoding.MP3)

    # Make the request to the API Text-to-Speech
    response = client.synthesize_speech(input=input_text, voice=voice_params, audio_config=audio_config)

    # Return audio content
    return response.audio_content


@app.route('/generate-world', methods=['POST'])
def generate_world():
    # Gets the user statement from the JSON request body

    prompt = request.form['txt-promp']
    answer = get_gemini_response(prompt)

    # Generate audio for AI response
    audio_content = generate_audio(answer)

    # Return the response and audio in MP3 format
    return render_template('index.html', geminianswer=answer, audio_content=audio_content)

@app.route('/', methods=['GET'])
def index():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
