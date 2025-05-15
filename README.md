# ULearna

**ULearna** is a sleek, modern reels-style video feed app built with Flutter, designed to deliver short-form video content with smooth interactions and advanced features for a rich user experience.

---

## Features

- **Vertical Video Feed**  
  Scroll vertically through videos fetched dynamically from a backend service, with smooth pagination and lazy loading.

- **Video Playback**  
  High-quality video playback with looping and mute/unmute functionality.

- **Gesture Controls**  
  - Double-tap to Like/Unlike videos with heart animation.  
  - Tap to mute/unmute with a subtle volume icon overlay.  
  - Long press to pause video playback, releasing resumes play.    
  - Drag to scrub through the video timeline.

- **Progress Indicators**  
  - Subtle linear progress bar at the bottom of each video showing playback progress.  
  - Circular progress indicators around mute/play/pause icons.

- **Resource Optimization**  
  Videos automatically pause when scrolled offscreen to save bandwidth and battery life.

- **Comments Modal**  
  Tap the comment icon to open a modal bottom sheet showing user comments for the video (with sample static comments for now).

- **Sharing Integration**  
  Share videos directly using the platform’s native share sheet.

- **Video Caching**  
  Videos are cached locally to provide smoother and faster playback on repeated views.

- **UI Polish & Animations**  
  - Animated like button scaling and color changes.  
  - Smooth fade and slide animations on UI components like bottom info bars, mute and pause icons.  
  - Shadows and overlays improve readability on videos.

- **Clean Architecture & State Management**  
  Built using the BLoC pattern with dependency injection for scalable and maintainable code.

---

