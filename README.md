# SenseEar - Final Year Project

Welcome to SenseEar! This iOS application was created with the idea of helping visually impaired students to obtain their course content in an easier fashion, by converting it to audio format. 
This is done by giving the user the ability to upload their course content or notes to the application. (txt, pdf, docx, xlsx, pptx file types are supported). 
The file selection is done through the "Files" native application on the device. The user can then apply different audio specifications, which gives them the ability to customise the 
sound of their notes or course content, with multiple different accents and genders. The user has the ability to choose this audio specifications by using the Segmented Controls on the User Interface
or by using the speech recognition option and speaking their choice into the recorder. The user will then click on the "Generate Audio" button which will convert their chosen file to audio. There is a built in audio player which will give the user the ability to play, pause and replay their course content. Background play is also supported, giving them the abilty to leave the 
application with the audio still playing. The audio has also been connected to the devices control centre and can be paused or played from there. Finally, there is a history section which will display 
the users history of generated files. This is connected to a Firebase Database. 

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for testing purposes.

### Prerequisites

Software that needs to be installed to access this project.

```
Xcode
```

### Installing

Steps for installing SenseEar are as follows:

* Clone the repo
* Open in Xcode
* Run pod install to get all the dependencies
* Add a Keys.plist to add your Google's Text-to-Speech API Key and then update the below method with you key

This method is found in the TextToSpeechService class
```
valueForAPIKey(named:"")
```

## Running the tests

For running the Unit Tests

* Add a new Scheme with the below target
* Run the tests
```
SenseEar-ProjectTests
```

For running the UI Tests

* Add a new Scheme with the below target
* Run the tests
```
SenseEar-ProjectUITests
```

## Built With

* [Swift](https://developer.apple.com/swift/) - iOS Development language
* [Cocoapods](https://cocoapods.org/) - Dependency Management
* [Google's Text-to-Speech API](https://cloud.google.com/text-to-speech) - For Text-to-Speech Conversion
* [Apple's Speech Recognition API](https://developer.apple.com/documentation/speech) - For Speech Recognition Implementation
* [Firebase](https://firebase.google.com/) - For Storage
