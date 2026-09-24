<table>
  <tr>
    <td><img src="Images/Workout%20List.png" width="100%"></td>
    <td><img src="Images/Exercise%20Adder.png" width="100%"></td>
    <td><img src="Images/Custom%20Exercise%20Adder.png" width="100%"></td>
  </tr>
</table>

<p align="center">iPhone Screenshots</p>

<table width="100%">
  <tr>
    <td><img src="Images/Sync%20Demo.png" width="100%"></td>
  </tr>
</table>

<p align="center">Always Synced</p>

<table>
  <tr>
    <td><img src="Images/Set%20Completer.png" width="100%"></td>
    <td><img src="Images/Time%20Keeper%20Teacher.png" width="100%"></td>
    <td><img src="Images/Welcome%20Screen.png" width="100%"></td>
  </tr>
</table>

<p align="center">Apple Watch Screenshots</p>

# Tension Session (currently under construction! 🚧🪛🏗️🦺)

### Follow progress at [@tensionsession](https://www.instagram.com/tensionsession) on Instagram!

## V2 is under active development!

### Current Task: Companion

- [ ] Complete the foundation for the phone and watch apps
  - [x] Structs
    - [x] Weight unit for pounds and kilograms
    - [x] Set details
    - [x] Exercises
    - [x] Workout
    - [x] UserInfo
  - [x] Services
    - [x] App context: This object contains a list of templates, a list of historical workouts, and the user info. It supports creating a copy of a given template and adding a new historical workout.
    - [x] Template buffer: This holds the template workout before and during a workout. When a workout is ended, it is remembered as a historical workout. It can hold methods for starting, pausing, resuming, and ending a workout, as well as adding it to the app context. But I still need to decide if the bulk of the code / work should be done in a `TemplateBuffer` method or a `Workout` method. (Perhaps this is an implementation detail that doesn't really matter?) Likely change `Workout`-internal things from a method of `Workout`, and do other work in `TemplateBuffer`.
    - [ ] HealthKit manager
    - [ ] Companion (THe big boi): Handle transfers and syncing between watch and phone. I might want to first create a protocol, so that I can use a `MockCompanion` in testing.
  - [ ] Tests for all user facing things
    - [x] Workout creations / deletions
    - [x] Workout starts / pauses / resumes / ends
    - [x] Changing the current template selection
    - [ ] Transferring things between a mock phone and mock watch? Using `MockCompanion`
- [x] Complete the watch app
- [ ] Complete the phone app
 
**Tension Session** is a gym companion app designed to make your workouts more effective and easier to track. 

## Key Features
- **Simple, approachable design** – Many apps out there are unapproachable to weight-lifting beginners like myself, but Tension Session is simple.  
- **Rest timer** – Tracks the duration between sets so you rest the right amount.
- **Progress tracking** – See your weight trends for each exercise and monitor strength gains over time.  
- **Apple Watch integration** – Seamlessly syncs data so you can track workouts on your phone or watch.  

## Why I Built Tension Session

When I started going to the gym more regularly in college, I used a spreadsheet to log reps and weights. But spreadsheets designed for big screens were cumbersome on my phone. On top of that, I often lost track of time between sets while reading articles on my phone when resting between sets.   

I wanted a simple app that could: 
1. Track weight progressions over time.  
2. Time my rest periods and remind me when to get back to lifting.  
