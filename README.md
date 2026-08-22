# Tension Session (currently under construction! 🚧🪛🏗️🦺)

### Follow progress at [@tensionsession](https://www.instagram.com/tensionsession) on Instagram!

## V2 is under active development!

- [ ] Complete the foundation for the phone and watch apps
  - [ ] Structs
    - [ ] Weight unit for pounds and kilograms
    - [ ] Set details
    - [ ] Exercises
    - [ ] Workout
    - [ ] UserInfo
  - [ ] Services
    - [ ] App context: This object contains a list of templates, a list of historical workouts, and the user info. It supports creating a copy of a given template and adding a new historical workout.
    - [ ] Template buffer: This holds the template workout before and during a workout. When a workout is ended, it is remembered as a historical workout. It can hold methods for starting, pausing, resuming, and ending a workout, as well as adding it to the app context. But I still need to decide if the bulk of the code / work should be done in a `TemplateBuffer` method or a `Workout` method. (Perhaps this is an implementation detail that doesn't really matter?) Likely change `Workout`-internal things from a method of `Workout`, and do other work in `TemplateBuffer`. 
    - [ ] Companion (THe big boi): Handle transfers and syncing between watch and phone. I might want to first create a protocol, so that I can use a `MockCompanion` in testing.
  - [ ] Tests for all user facing things
    - [ ] Workout creations / deletions
    - [ ] Workout starts / pauses / resumes / ends
    - [ ] Changing the current template selection
    - [ ] Transferring things between a mock phone and mock watch? Using `MockCompanion`
- [ ] Complete the watch app
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
