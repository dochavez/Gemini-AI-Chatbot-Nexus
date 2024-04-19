from google.cloud import texttospeech

# Configurar la autenticación
# Reemplaza 'path/to/your/credentials.json' con la ruta al archivo JSON de clave de servicio.
credentials_path = 'PUT-THE-CREDENTIAL-HERE-FOR-TEXT-TO-SPEECH.json'
client = texttospeech.TextToSpeechClient.from_service_account_json(credentials_path)

# Configurar la solicitud de síntesis de voz
input_text = texttospeech.SynthesisInput(text="Hi, how are you today? I hope you are doing well. I am a computer program that can generate audio from text. I am happy to help you with your projects.")
#voice_params = texttospeech.VoiceSelectionParams(language_code="en-US", name="en-US-Wavenet-D")
voice_params = texttospeech.VoiceSelectionParams(language_code="es-US", name="es-US-Neural2-B")
audio_config = texttospeech.AudioConfig(audio_encoding=texttospeech.AudioEncoding.LINEAR16)

# Realizar la solicitud a la API de Text-to-Speech
response = client.synthesize_speech(input=input_text, voice=voice_params, audio_config=audio_config)

# Guardar el audio en un archivo
with open("output_audio.wav", "wb") as out:
    out.write(response.audio_content)
    print("Audio content written to file 'output_audio.wav'")
