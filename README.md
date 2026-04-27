# 📊 Stratify

**A Data-Driven Lifestyle Optimization and Time-Based Recommendation System** 

## Overview

A significant challenge faced by students is making daily decisions based purely on habit rather than on the actual value each activity delivers. We often spend time and money without evaluating whether those activities genuinely contribute to our satisfaction, energy, or overall well-being[.

**Stratify** solves this by turning daily habits into measurable data. It is a comprehensive mobile application that allows users to log their daily activities, track their associated time and financial costs, and evaluate their psychological impact. The system computes a custom **Return on Investment (ROI) score** for each activity and uses historical data to recommend the best possible activity for any given time of day.

---

## Core Modules & Features

### 1. Activity Data Entry 
A streamlined form that captures both objective metrics and subjective experiences. 
* **Inputs:** Date, Start Time, Time Segment (Morning, Afternoon, Evening, Night), Category, and Activity Name.
* **Resource Tracking:** Time Spent (hours/minutes) and Money Spent (₹).
* **Psychological Metrics:** Interactive sliders to rate Satisfaction (1-5), Energy Impact (-2 to +2), and Stress Impact (-2 to +2).
* **Cloud Sync:** Validated data is securely pushed to Supabase.

### 2. Analytical Dashboard 
The brain of the application. It fetches historical data and runs it through the ROI calculation engine.
* **Custom ROI Score:** Ranks activities by weighing subjective benefits against objective costs.
* **Insights:** Visualizes highest-ROI activities, category-wise satisfaction comparisons, energy-versus-stress charts, weekly trends, and time-of-day performance.

### 3. Time-Based Recommendation Engine 
Context-aware intelligence that makes your data actionable.
* Reads the device's current time and maps it to a specific time segment.
* Filters historical data to compute the average ROI of activities performed during that specific window.
* Actively recommends the activity that has historically performed the best at that exact time of day.

---

## Technology Stack

Stratify is built with a modern, scalable, cross-platform architecture:
* **Frontend:** Flutter (Dart) 
* **Backend & Database:** Supabase (Cloud-based PostgreSQL)
* **State Management:** Provider (Ensuring a clean separation of UI and business logic)
* **Data Visualization:** `fl_chart` package 

---

## The ROI Engine (How It Works)

Stratify uses a custom engineering heuristic (Benefit-Cost Ratio) to normalize subjective feelings against objective resources:

`ROI = (Satisfaction + EnergyImpact - StressImpact) / (TimeSpent + (MoneySpent * 0.01) + 1)`

* **The Benefit (Numerator):** Uses Simple Additive Weighting. It rewards high satisfaction and high energy, while penalizing high stress. 
* **The Cost (Denominator):** Converts Time to hours and scales Money by `0.01` to normalize the differing units into a single "resource cost."
* **Additive Smoothing:** The `+ 1` ensures mathematical stability, preventing division-by-zero errors for activities that are instantaneous and free.

---

## 📥 Installation & Setup

**1. Clone the repository**
```
git clone [https://github.com/your-username/stratify.git](https://github.com/your-username/stratify.git)
cd stratify

```
**2. Install dependencies**


```
flutter pub get

```
**3. Configure Environment Variables**
Create a .env file in the root directory of the project to securely store your database credentials.
(Ensure this file is added to your .gitignore!)

```
SUPABASE_URL=[https://your-project-url.supabase.co](https://your-project-url.supabase.co)
SUPABASE_ANON_KEY=your-anon-key

```
**4. Run the application**


```
flutter run

```
## Future Scope

AI-Based Recommendations: Replacing static ROI weights with a machine learning model that personalizes weightings based on individual user behavior.


Sensor Integration: Utilizing smartphone sensors or wearables for automatic activity detection and passive energy tracking.


Gamification: Implementing streak systems to improve user retention.


Social Features: Multi-user data sharing so friends can compare lifestyle performance and accountability.


Developed as part of the Advanced Technologies Lab, 6th Semester.
