# Effets provisoires

Fichiers WAV mono PCM 16 bits, 22 050 Hz, générés pour ce projet :

- `card_slide.wav` : glissement de carte (0,10 s).
- `tap.wav` : action légère (0,065 s).
- `timeout.wav` : expiration du délai local (0,28 s).

Ces fichiers sont remplaçables par les sons définitifs en conservant leur chemin.
Les sons de distribution, mise, Hordago et victoire restent dans `assets/audio/`.
Tous les appels passent par `AudioHapticService.playSound`; ne pas créer de
lecteur audio ni appeler les haptiques depuis les boutons. Le réglage « Effets
sonores » désactive également les vibrations et arrête immédiatement le lecteur.
Le service reste silencieux tant que la préférence est inconnue ou indisponible.
