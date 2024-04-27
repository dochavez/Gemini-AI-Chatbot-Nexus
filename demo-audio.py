# This file was developed for testing purposes with the Text-to-Speech API generated in GCP.

from google.cloud import texttospeech

# Set up authentication
# Replace 'path/to/your/credentials.json' with the path to the service key JSON file.
credentials_path = 'PUT-THE-CREDENTIAL-HERE-FOR-TEXT-TO-SPEECH.json'
client = texttospeech.TextToSpeechClient.from_service_account_json(credentials_path)

# Configure the speech synthesis request
input_text = texttospeech.SynthesisInput(text="Hi, how are you today? I hope you are doing well. I am a computer program that can generate audio from text. I am happy to help you with your projects.")
#voice_params = texttospeech.VoiceSelectionParams(language_code="en-US", name="en-US-Wavenet-D")
voice_params = texttospeech.VoiceSelectionParams(language_code="es-US", name="es-US-Neural2-B")
audio_config = texttospeech.AudioConfig(audio_encoding=texttospeech.AudioEncoding.LINEAR16)

# Make the request to the Text-to-Speech API
response = client.synthesize_speech(input=input_text, voice=voice_params, audio_config=audio_config)

# Save audio to a file
with open("output_audio.wav", "wb") as out:
    out.write(response.audio_content)
    print("Audio content written to file 'output_audio.wav'")
