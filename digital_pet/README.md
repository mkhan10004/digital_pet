```md
# Digital Pet State Lab

## Activity 07 Project README

**Course:** Mobile Application Development  
**Pathway:** Undergraduate  
**Team Name:** [Enter Team Name]  
**Repository:** [Paste GitHub repository URL]  

## Team Members and Roles

| Member | Team | Role | Contribution |
|---|---|---|---|
| [Mohammed Afeefuddin] | Team 1 | Care Systems | Feed, play, reset, meter boundaries, hunger timer, win/loss rules |
| [Muhammad samad khan ] | Team 2 | Pet Personality | Mood feedback, animations, accessibility, pet asset, UI polish |

## Project Overview

Digital Pet is a Flutter pet-care app where user actions and time change the pet’s state. The app uses a `StatefulWidget` and `setState()` to manage the pet name, happiness, hunger, energy, feedback reactions, timers, and game outcomes.

Users can rename, feed, play with, rest, and reset their pet. The app keeps every meter between 0 and 100 and gives visible feedback through mood labels, color tint, animations, messages, and reactions.

## Setup and Run

```bash
flutter pub get
flutter run
```

## Analyze, Test, and Build

```bash
flutter analyze
flutter test
flutter build apk --release
```

The release APK should be named:

```text
DigitalPet_TeamName.apk
```

## Core Features

- Editable pet name using `TextEditingController`
- Happiness meter from 0–100
- Hunger meter from 0–100
- Energy meter from 0–100
- Feed, Play, Rest, and Reset actions
- Mood label that does not rely only on color
- Mood tint using `ColorFiltered`
- Hunger increases by 5 every 30 seconds
- Win condition: happiness stays strictly above 80 for three continuous minutes
- Loss condition: hunger reaches 100 while happiness is 10 or lower
- Care actions disable after a win or loss until Reset
- Timers and controller are canceled/disposed safely in `dispose()`

## Pet Rules

| Action | Effect |
|---|---|
| Feed | Hunger −10, energy +5, happiness changes based on resulting hunger |
| Play | Happiness +15, hunger +5, energy −10 |
| Rest | Energy +25, happiness −5, hunger +5 |
| Hunger timer | Every 30 seconds, hunger +5 |
| Hunger overflow | If hunger is already 100 and another tick occurs, happiness −20 |
| Reset | Returns to 50 happiness, 50 hunger, 70 energy, and starts one hunger timer |

## Mood Rules

| Happiness | Mood | Tint | Scale |
|---:|---|---|---:|
| 0–29 | Unhappy | Red | 0.94 |
| 30–70 | Neutral | Yellow | 1.00 |
| 71–100 | Happy | Green | 1.06 |

## Advanced Features Selected

### 1. Energy System

The app includes an energy meter. Playing costs 10 energy, feeding restores 5 energy, and resting restores 25 energy. If energy is below 10, the pet cannot play and gives sleep feedback.

### 2. Visual Polish and Accessible Motion

The app includes:

- Animated meter transitions with `TweenAnimationBuilder`
- Mood and message transitions with `AnimatedSwitcher`
- Pet scaling based on mood
- Bounce feedback after Feed and Play
- Short action reactions such as 🍖, 🎾, and 💤
- Reduced-motion support using `MediaQuery.of(context).disableAnimations`

## Accessibility

The pet’s mood is shown with text such as Happy, Neutral, or Unhappy, so color is not the only way users receive feedback. Reduced-motion mode makes nonessential animations use `Duration.zero`.

## Asset Attribution

**Pet asset:** `assets/pet.png`  


> Before submission, replace the emoji pet with a transparent or grayscale PNG at `assets/pet.png`, register it in `pubspec.yaml`, and display it with `Image.asset()` inside `ColorFiltered`.

## Manual Test Evidence

| Scenario | Expected Result | Evidence |
|---|---|---|
| Feed at hunger 5 and 95 | Hunger stays between 0–100 | [Add results] |
| Play at happiness 95 | Happiness stays at or below 100 | [Add results] |
| Play at energy 5 | Play is blocked and sleep feedback appears | [Add results] |
| Happiness at 29, 30, 70, and 71 | Correct mood label, tint, and scale appear | [Add screenshots] |
| Happiness above 80 for 2:59, then drops to 80 | No win; win timer is canceled | [Add results] |
| Happiness above 80 for 3 minutes | Win screen appears; hunger timer stops | [Add results] |
| Hunger 95 → 100 → next timer tick | First tick has no penalty; overflow reduces happiness by 20 | [Add results] |
| Hunger 100 and happiness 10 | Game Over appears and actions disable | [Add screenshot] |
| Leave screen with active timer | No `setState() called after dispose()` error | [Add console result] |
| Reduced motion enabled | Values and messages remain usable without movement |  |


