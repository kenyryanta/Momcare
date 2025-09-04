# MomCare: AI-Powered Pregnancy Health Monitoring App
Link Video Youtube : https://youtu.be/RG8u9nKf56E

MomCare is a mobile application designed to provide comprehensive support and monitoring for expectant mothers. Leveraging AI, the platform aims to reduce maternal mortality rates (MMR) and prevent stunting from an early stage by offering personalized guidance, early risk detection, and a supportive community.



---

## 📖 Table of Contents

-   [The Problem](#-the-problem)
-   [Our Solution](#-our-solution)
-   [🚀 Key Features](#-key-features)
-   [🛠️ Technology Stack](#️-technology-stack)
-   [🏁 Getting Started](#-getting-started)
    -   [Prerequisites](#prerequisites)
    -   [Installation & Setup](#installation--setup)
-   [Project Goals](#-project-goals)
-   [Project Benefits](#-project-benefits)

---

## 📉 The Problem

Pregnancy is a critical period filled with physical and emotional changes. In Indonesia, this journey is often fraught with significant risks, reflected in a high **Maternal Mortality Rate (MMR)**. According to the 2020 Population Census, the MMR in Indonesia stands at **189 per 100,000 live births**, a figure starkly distant from the Sustainable Development Goals (SDG) target of under 70 per 100,000 by 2030.

Key contributing factors include:
1.  **Delays in Medical Care**: Delays in recognizing danger signs, seeking help, and receiving adequate medical services.
2.  **Socio-Economic Barriers**: Poverty and remote locations limit access to essential health information and services.
3.  **Lack of Health Education**: Insufficient knowledge about pregnancy danger signs and the importance of routine check-ups.
4.  **Mental Health Risks**: Hormonal fluctuations can lead to anxiety, stress, and perinatal depression, which are often overlooked but contribute to maternal health risks.

Without effective intervention, these challenges not only threaten the mother's life but also impact the long-term health of the child, contributing to issues like stunting.

---

## ✨ Our Solution

MomCare addresses these challenges by placing a powerful health companion directly into the hands of expectant mothers. Our application is designed to bridge the information and healthcare gap, ensuring every mother feels supported, informed, and secure throughout her pregnancy.

We provide a holistic platform that combines **AI-driven analytics**, **personalized education**, and **community support**. By flagging potential risks early and offering actionable guidance, MomCare empowers women to take proactive control of their health and their baby's future, directly aligning with the SDG goal of **"Good Health and Well-being."**

---

## 🚀 Key Features

-   **🧠 Smart Alert System**: An AI-powered weekly assessment analyzes user-input data to proactively detect early symptoms of high-risk conditions like pre-eclampsia, anemia, or severe stress, sending timely alerts.
-   **📸 AI Nutrition Analysis**: Simply snap a photo of your meal, and our AI analyzes its nutritional content. Receive personalized dietary recommendations tailored to your gestational age to prevent stunting from the womb.
-   **📊 Unified Health Dashboard**: Track everything in one place. Your nutrition intake, sleep patterns, assessment results, and daily symptoms are visualized in easy-to-read graphs, making you an informed manager of your health.
-   **💬 24/7 AI Chatbot & Community Forum**: Get instant, verified answers to your questions anytime from our Gemini-powered AI chatbot. Connect with a supportive community of fellow expectant mothers in a safe and moderated forum.

---

## 🛠️ Technology Stack

-   **Frontend**: Flutter
-   **Backend**: Flask (Python)
-   **Database**: MySQL
-   **AI & Machine Learning**: NLTK, Scikit-learn, TensorFlow (or similar)
-   **Chatbot**: Google Gemini API

---

## 🏁 Getting Started

Follow these instructions to set up and run the MomCare prototype on your local machine.

### Prerequisites

Ensure you have the following software installed on your system:
-   **Git**: For cloning the repository.
-   **Python 3.8+** and **pip**: For the backend server.
-   **MySQL Server**: As the primary database.
-   **Flutter SDK**: For running the mobile application.
-   **An IDE/Code Editor**: Such as VS Code, Android Studio.

### Installation & Setup

#### **1. Clone the Repository**

Open your terminal and run the following command:
```bash
git clone [https://github.com/yonurhan/MomCare.git](https://github.com/yonurhan/MomCare.git)
cd MomCare
```

#### **2. Backend Setup** ⚙️

The backend is a Flask server that powers the application's logic and AI features.

-   **Navigate to the backend directory:**
    ```bash
    cd backend
    ```

-   **(Recommended) Create and activate a virtual environment:**
    ```bash
    # For macOS/Linux
    python3 -m venv venv
    source venv/bin/activate

    # For Windows
    python -m venv venv
    .\venv\Scripts\activate
    ```

-   **Install Python dependencies:**
    This command installs all required libraries from `requirements.txt` and downloads necessary NLTK data.
    ```bash
    pip install -r requirements.txt
    python nltk_setup.py
    ```

-   **Configure Environment Variables:**
    Create a `.env` file in the `backend` directory. Copy the contents of `.env.example` (if available) and fill in your details.
    ```
    # .env file for the backend
    DATABASE_URL="mysql+pymysql://<user>:<password>@<host>/<dbname>"
    SECRET_KEY="your_strong_secret_key_here"
    GEMINI_API_KEY="your_google_gemini_api_key"
    ```

-   **Set up the MySQL Database:**
    Ensure your MySQL server is running. Then, apply the database migrations.
    ```bash
    flask db upgrade
    ```

-   **Run the Flask Server:**
    ```bash
    flask run
    ```
    The backend server should now be running, typically on `http://127.0.0.1:5000`.

#### **3. Frontend Setup** 📱

The frontend is a Flutter application for iOS and Android.

-   **Navigate to the frontend directory:**
    ```bash
    # From the root MomCare directory
    cd frontend
    ```

-   **Configure the API Base URL:**
    1.  Create a file named `.env` in the `frontend` directory.
    2.  Find your computer's local IPv4 address.
        -   On **Windows**, run `ipconfig`.
        -   On **macOS/Linux**, run `ifconfig` or `ip addr`.
    3.  Add the following line to the `.env` file, replacing the IP address with your own. The port should match your running Flask server (default is 5000).
        ```
        # .env file for the frontend
        BaseURL=[http://192.168.1.10:5000](http://192.168.1.10:5000)
        ```
        *Note: Do not use `localhost` or `127.0.0.1` if you plan to run the app on a physical mobile device.*

-   **Install Flutter dependencies:**
    ```bash
    flutter pub get
    ```

-   **Run the Flutter Application:**
    Make sure an emulator is running or a physical device is connected.
    ```bash
    flutter run
    ```

---

## 🎯 Project Goals

1.  **Proactively Detect Risks**: Utilize AI to analyze weekly health data and identify early warning signs of serious conditions before they escalate.
2.  **Provide Personalized Nutrition Guidance**: Simplify nutrition tracking with AI-powered meal photo analysis and deliver dynamic recommendations to prevent stunting.
3.  **Create a Centralized Health Hub**: Integrate all key health data (nutrition, sleep, symptoms, assessments) into an intuitive dashboard to empower users.
4.  **Offer On-Demand Emotional and Informational Support**: Provide reliable answers 24/7 through an AI chatbot and foster a safe community space for peer support.
5.  **Bridge the Healthcare Access Gap**: Overcome barriers of limited access to information by delivering a risk detection and knowledge system directly to users.

---

## ✅ Project Benefits

1.  **Total Peace of Mind with Smart Early Detection**: Our AI proactively monitors for risks like pre-eclampsia & anemia, providing crucial early warnings while working silently in the background.
2.  **Optimal Fetal Nutrition, as Easy as Taking a Photo**: Eliminate tedious manual logging. Our AI instantly analyzes meal photos and provides personalized recommendations to actively combat stunting risks.
3.  **Full Control in Your Hands**: Transform from a passive patient to an empowered health manager. Visual reports on nutrition, sleep, and symptoms make you an informed partner for your doctor.
4.  **Trusted Answers & Emotional Support, Anytime**: Get verified responses from our 24/7 AI chatbot for urgent questions. Connect with a supportive community forum when you need to feel understood.
