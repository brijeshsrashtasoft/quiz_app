# Flutter Quiz App Theme Guide

## 🎨 Color Palette

### Primary Brand Colors
| Color Name | Hex Code | Usage | Emotion/Purpose |
|------------|----------|--------|-----------------|
| **Vibrant Purple** | `#6C5CE7` | Primary brand, main buttons, headers | Knowledge, creativity, modern |
| **Turquoise** | `#00D2D3` | Correct answers, success states | Positive, refreshing, achievement |
| **Coral Red** | `#FF6B6B` | Incorrect answers, time warnings | Urgency, attention, mistakes |
| **Mint Green** | `#4ECDC4` | Secondary actions, highlights | Fresh, supportive, progress |
| **Warm Yellow** | `#FFE66D` | Rewards, stars, achievements | Joy, celebration, energy |

### Neutral Colors
| Color Name | Hex Code | Usage |
|------------|----------|--------|
| **Charcoal** | `#2D3436` | Primary text, headings |
| **Cool Gray** | `#636E72` | Secondary text, hints |
| **Off-White** | `#F5F3F4` | Main background |
| **Pure White** | `#FFFFFF` | Cards, elevated surfaces |
| **Light Gray** | `#DFE6E9` | Borders, dividers |

### Dark Mode Colors
| Element | Light Mode | Dark Mode | Notes |
|---------|------------|-----------|-------|
| **Background** | `#F5F3F4` | `#1E1E1E` | Pure black avoided for eye comfort |
| **Surface/Cards** | `#FFFFFF` | `#2D2D2D` | Slight elevation from background |
| **Primary Text** | `#2D3436` | `#F5F3F4` | High contrast maintained |
| **Secondary Text** | `#636E72` | `#B2BEC3` | Softer for reduced emphasis |
| **Dividers** | `#DFE6E9` | `#3D3D3D` | Subtle separation |

## 🎯 Answer Button Colors

| Shape | Color Name | Hex Code | Psychology |
|-------|------------|----------|------------|
| **Triangle** | Coral Red | `#FF6B6B` | Sharp, decisive, bold |
| **Diamond** | Mint Green | `#4ECDC4` | Balanced, valuable, unique |
| **Circle** | Warm Yellow | `#FFE66D` | Complete, unified, friendly |
| **Square** | Turquoise | `#00D2D3` | Stable, trustworthy, solid |

## 📐 Typography

### Font Selection
- **Primary Font**: Inter or system font
- **Fallback**: Roboto (Android), SF Pro (iOS)
- **Characteristics**: Clean, highly readable, modern, supports multiple weights

### Text Hierarchy
| Element | Size | Weight | Line Height | Usage |
|---------|------|--------|-------------|--------|
| **Game Title** | 32sp | Bold (700) | 1.2 | Main screen headers |
| **Section Headers** | 24sp | Semi-bold (600) | 1.3 | Category titles |
| **Question Text** | 20-24sp | Medium (500) | 1.4 | Quiz questions |
| **Answer Options** | 18-20sp | Medium (500) | 1.4 | Multiple choice text |
| **Body Text** | 16sp | Regular (400) | 1.5 | Instructions, descriptions |
| **Caption/Hints** | 14sp | Regular (400) | 1.5 | Secondary information |
| **Timer Display** | 48sp | Bold (700) | 1.0 | Countdown numbers |
| **Score Display** | 36sp | Bold (700) | 1.0 | Points, rankings |

## 🎮 UI Components

### Question Cards
- **Background**: White/Dark surface
- **Border Radius**: 16dp
- **Padding**: 24dp all sides
- **Shadow**: Subtle purple tint (10% opacity)
- **Active State**: 2dp purple border
- **Elevation**: 4-8dp

### Answer Buttons
- **Height**: 80dp minimum
- **Border Radius**: 12dp
- **Shadow**: 15% black opacity
- **Press State**: Scale to 95%
- **Correct Animation**: Pulse + color change to turquoise
- **Incorrect Animation**: Shake + color change to coral red
- **Disabled State**: 50% opacity

### Timer Component
- **Size**: 80x80dp
- **Style**: Circular progress
- **Normal Color**: Purple gradient
- **Warning State**: Red gradient (last 5 seconds)
- **Animation**: Smooth countdown, pulse when critical

### Progress Bar
- **Height**: 4-6dp
- **Background**: Light gray
- **Fill**: Purple gradient
- **Border Radius**: Full rounded
- **Animation**: Smooth fill transition

### Leaderboard Items
- **Card Style**: Rounded rectangles
- **Spacing**: 8dp between items
- **Top 3 Special**: Gradient backgrounds
    - 1st: Gold gradient
    - 2nd: Silver gradient
    - 3rd: Bronze gradient
- **Animation**: Slide in from right

## ✨ Animations & Interactions

### Micro-interactions
| Action | Animation | Duration | Easing |
|--------|-----------|----------|--------|
| **Button Tap** | Scale down 5% | 200ms | Ease-out |
| **Correct Answer** | Pulse + Confetti | 500ms | Elastic |
| **Wrong Answer** | Horizontal shake | 500ms | Spring |
| **New Question** | Slide up + Fade | 300ms | Ease-in-out |
| **Score Update** | Count up | 800ms | Ease-out |
| **Achievement** | Bounce + Glow | 600ms | Bounce |
| **Timer Warning** | Pulse | 1000ms | Linear |

### Screen Transitions
- **Default**: Slide + Fade (300ms)
- **Game Start**: Zoom in (400ms)
- **Game Over**: Iris out effect (500ms)
- **Leaderboard**: Slide up from bottom (350ms)

## 📱 Platform Adaptations

### Material Design (Android)
- **Elevation**: Use Material elevation system (2-8dp)
- **Ripple Effects**: On all touchable elements
- **Navigation**: Bottom navigation or drawer
- **Shadows**: Softer, more diffused
- **Icons**: Outlined style preferred

### Cupertino (iOS)
- **Shadows**: Subtle, closer to surface
- **Blur Effects**: Background blurs for modals
- **Navigation**: Tab bar or navigation bar
- **Haptic Feedback**: Light, medium, heavy impacts
- **Icons**: Filled style preferred

## 🎯 Game States & Feedback

### Visual Feedback Colors
| State | Primary Color | Secondary | Icon/Symbol |
|-------|--------------|-----------|-------------|
| **Correct** | Turquoise | White | Checkmark |
| **Incorrect** | Coral Red | White | X mark |
| **Time Warning** | Orange | Red pulse | Clock |
| **Achievement** | Gold | Yellow sparkles | Star |
| **New High Score** | Purple | Gold accents | Trophy |
| **Power-up Active** | Color varies | White glow | Lightning |

### Power-up Colors
| Power-up | Color | Hex | Visual Effect |
|----------|-------|-----|---------------|
| **Double Points** | Gold | `#FFD700` | Golden glow |
| **Time Freeze** | Ice Blue | `#74B9FF` | Frost particles |
| **50/50 Chance** | Purple | `#A29BFE` | Split effect |
| **Skip Question** | Orange | `#FFA502` | Arrow forward |

## 📊 Data Visualization

### Score Display
- **Font**: Monospace for numbers
- **Animation**: Rolling numbers
- **Color**: Purple for regular, gold for high scores

### Progress Indicators
- **Quiz Progress**: Linear bar at top
- **Level Progress**: Circular with percentage
- **Streaks**: Fire animation with orange/red
- **Achievements**: Star-based system

## ♿ Accessibility

### Color Contrast Requirements
- **Normal Text**: 4.5:1 minimum
- **Large Text**: 3:1 minimum
- **Interactive Elements**: 3:1 minimum
- **Disabled States**: 2.5:1 minimum

### Additional Considerations
- **Color Blind Friendly**: Never rely on color alone
- **Icons**: Always pair with colors
- **Patterns**: Use for additional differentiation
- **Text Size**: Support dynamic type sizing
- **Touch Targets**: 48x48dp minimum

## 🌍 Localization Considerations

### RTL Support
- **Animations**: Mirror horizontal movements
- **Icons**: Flip directional icons
- **Layouts**: Full mirroring support
- **Progress**: Right-to-left progress bars

### Cultural Colors
- **Adaptable Elements**: Success/error colors
- **Regional Preferences**: Adjustable themes
- **Number Formats**: Locale-specific scoring

## 💡 Best Practices

### Performance
1. **Gradients**: Use sparingly on low-end devices
2. **Shadows**: Reduce complexity on older phones
3. **Animations**: Provide reduced motion option
4. **Images**: Use vector graphics where possible

### Consistency
1. **Spacing**: Use 8dp grid system
2. **Border Radius**: Consistent across similar elements
3. **Animation Timing**: Standardize durations
4. **Color Usage**: Maintain meaning across app

### User Experience
1. **Feedback**: Immediate visual response
2. **Loading States**: Skeleton screens or spinners
3. **Empty States**: Friendly illustrations
4. **Error States**: Clear, actionable messages

## 🎨 Theme Variations

### Seasonal Themes (Optional)
| Season | Primary Accent | Secondary | Background |
|--------|---------------|-----------|------------|
| **Spring** | Pink | Green | Light Mint |
| **Summer** | Ocean Blue | Yellow | Light Blue |
| **Autumn** | Orange | Brown | Warm Beige |
| **Winter** | Ice Blue | Silver | Cool Gray |

### Difficulty Themes
| Level | Primary Color | Intensity |
|-------|--------------|-----------|
| **Easy** | Soft Green | Low contrast |
| **Medium** | Balanced Purple | Medium contrast |
| **Hard** | Intense Red | High contrast |
| **Expert** | Deep Black | Maximum contrast |