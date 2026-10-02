# DeepSeek pour macOS

Projet SwiftUI natif qui ouvre https://chat.deepseek.com dans une fenêtre WKWebView sans barre d’adresse.

## Ouvrir

1. Décompressez l’archive si nécessaire.
2. Ouvrez `DeepSeek.xcodeproj` avec Xcode.
3. Sélectionnez la cible **DeepSeek**, puis lancez avec **⌘R**.

La cible minimale est macOS 14.0. La session est conservée dans le stockage WebKit persistant (`WKWebsiteDataStore.default()`). La commande **DeepSeek > Déconnexion** (raccourci ⇧⌘L) efface les données WebKit associées à `deepseek.com`.

Les liens HTTP(S) et fenêtres demandées par le site s’ouvrent dans la même fenêtre. Les téléchargements passent par la boîte de dialogue d’enregistrement macOS. Les raccourcis standards macOS **⌘W** et **⌘Q** ferment la fenêtre et quittent l’app.

Le bundle identifier d’exemple est `com.example.DeepSeek`; vous pouvez le modifier dans les réglages de la cible avant signature ou distribution.


Icône : favicon SVG officiel du site DeepSeek (`https://fe-static.deepseek.com/chat/favicon.svg`), rasterisé aux tailles requises par macOS.
