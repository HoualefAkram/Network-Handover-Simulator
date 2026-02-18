# 📡 Handover Simulator (Flutter)

A visual cellular handover simulator built with Flutter.

This app demonstrates how Handover Margin (HOM) and Time-To-Trigger (TTT) affect handover decisions between two base stations using a simple RSS (distance-based) model.

It is useful for understanding LTE/5G mobility concepts in a visual and interactive way.

---

## 🚀 Features

- Interactive map using OpenStreetMap
- Draggable User
- Draggable Cell Tower 1
- Draggable Cell Tower 2
- Live RSS calculation (distance-based)
- Handover logic using:
  - Handover Margin (HOM)
  - Time-To-Trigger (TTT)
- Visual connection indicator:
  - Green = Connected tower
  - Red = Not connected tower

---

## 🧠 Concepts Simulated

### 1️⃣ RSS (Received Signal Strength)

Currently modeled as:

RSS = distance(user, cell)

Lower distance = better signal (simplified model).

---

### 2️⃣ Handover Margin (HOM)

Handover is only considered if:

|RSS1 - RSS2| >= HOM

Increasing HOM:
- Requires a larger difference between towers
- Reduces ping-pong
- May increase late handovers

---

### 3️⃣ Time-To-Trigger (TTT)

Even if HOM is satisfied, the condition must remain valid for:

TTT milliseconds

If the condition breaks before TTT expires → handover is cancelled.

Short TTT:
- Faster handover
- More ping-pong risk

Long TTT:
- More stable
- Risk of late handover

---

## 📂 Project Structure

lib/</br>
 ├── main.dart</br>
 ├── home.dart</br>
 ├── latlang_extension.dart</br>
 └── typedefs.dart</br>

### main.dart
Initializes the app and loads Home.

### home.dart
Contains:
- Map UI
- Drag logic
- RSS calculation
- HOM & TTT logic
- Handover state management

### latlang_extension.dart
Custom LatLng extension:
- Distance calculation (Haversine formula)
- Coordinate helpers

---

## ⚙️ How It Works

1. RSS is recalculated every time:
   - User moves
   - A tower moves

2. If:
   - Target tower has better RSS
   - AND RSS difference ≥ HOM
   → TTT starts

3. If condition remains valid for full TTT:
   → Handover occurs

---

## 🧪 How to Use

1. Drag the user between towers.
2. Adjust:
   - HOM
   - TTT (ms)
3. Observe:
   - RSS values
   - TTT status
   - Connected tower

---

## 🛠 Dependencies

- flutter_map
- flutter_map_dragmarker
- latlong2


---

## 📄 License

This project is for educational purposes.
