# 🍽️ OrderEase - Smart Restaurant Order Management System
OrderEase is a comprehensive restaurant order management system built with Flutter and Firebase that streamlines operations across four key roles: Admin, Manager, Cook, and Cashier. It features smart menu management with customizable categories, real-time order tracking from placement to preparation, digital bill generation with QR code sharing for paperless transactions, and powerful business analytics with visual insights on sales trends, payment modes, and top-selling items. The application offers a responsive design optimized for both mobile and tablet views, includes customer-facing features like live order status tracking via QR codes and a 10-point rating system, and maintains comprehensive activity logs for complete operational transparency.
<h2>Table of Contents</h2>
<ul>
  <li> <a href = "#About"> About </a></li>
  <ul>
   <li><a href="#wa"> What is OrderEase? </a></li> 
   <li><a href="#features"> Features </a></li> 
   <li><a href="#why"> Why OrderEase? </a></li>
  </ul>
  <li> <a href = "#getting_started"> Getting Started </a></li>
  <ul>
   <li><a href="#prerequisites"> Prerequisites </a></li> 
   <li><a href="#installation"> Installation </a></li> 
   <li><a href="#frontend_setup"> Building the App </a></li>
  </ul>
  <li> <a href = "#tech_used"> TechStack Used </a></li>
  <li> <a href = "#architecture"> System Architecture </a></li>
  <li> <a href = "#screenshots"> Screenshots and App Demonstration </a></li>
  <li> <a href = "#conclusion"> Conclusion </a></li>
  <li> <a href = "#team"> Developed By </a></li>
</ul>
<section id = "About">
  <h2> About </h2>
  <h3 id = "wa"> What is OrderEase? </h3>
    OrderEase is a comprehensive restaurant order management system designed to streamline and digitalize restaurant operations from order placement to settlement. Built with Flutter and Firebase, it provides a complete ecosystem for managing menus, processing orders, tracking food preparation, and generating insightful business analytics.
The application serves four distinct user roles - Admin, Manager, Cook, and Cashier - each with tailored dashboards and functionalities. OrderEase eliminates manual processes through features like digital bill generation with QR code sharing, real-time order status tracking for customers, and automated activity logging. With its responsive design optimized for both mobile and tablet devices, OrderEase transforms traditional restaurant management into a smart, paperless, and efficient operation while providing powerful analytics to drive business decisions.
  <h3 id="features">Features</h3>
<ul>
    <li><strong>Multi-Role Access Control</strong>
        <ul>
            <li>Four distinct user roles: Admin, Manager, Cook, and Cashier</li>
            <li>Role-based dashboards with tailored functionalities</li>
            <li>Secure authentication with unique hotel ID assignment</li>
        </ul>
    </li>
    <br>
    <li><strong>Smart Menu Management</strong>
        <ul>
            <li>Create and organize menu categories with custom background images</li>
            <li>Add multiple menu items at once with easy search functionality</li>
            <li>Edit, delete, and customize menu items in real-time</li>
            <li>Toggle food availability status based on time criteria</li>
        </ul>
    </li>
    <br>
    <li><strong>Real-Time Order Tracking</strong>
        <ul>
            <li>Live order status updates from placement to preparation</li>
            <li>Customer-facing QR code scanning for order status tracking</li>
            <li>Time-sorted order queue for kitchen efficiency</li>
            <li>Custom notifications and food preparation instructions</li>
        </ul>
    </li>
    <br>
    <li><strong>Digital Bill Generation & Settlement</strong>
        <ul>
            <li>Paperless billing with QR code sharing system</li>
            <li>Download and print bills in PDF format</li>
            <li>Multiple payment mode support (Cash, UPI, Card)</li>
            <li>Complete settlement history and tracking</li>
        </ul>
    </li>
    <br>
    <li><strong>Comprehensive Business Analytics</strong>
        <ul>
            <li>Visual insights with daily, weekly, monthly, and yearly reports</li>
            <li>Payment mode analysis and revenue tracking</li>
            <li>Top-selling items visualization by count, price, and total</li>
            <li>Customer rating system with 10-point scale feedback</li>
            <li>Export analytics reports as PDF for sharing</li>
        </ul>
    </li>
    <br>
    <li><strong>Table & Session Management</strong>
        <ul>
            <li>Dynamic table blocking and availability tracking</li>
            <li>Live view of in-service and available tables</li>
            <li>Configure number of tables based on hotel requirements</li>
            <li>Session-based order management per table</li>
        </ul>
    </li>
    <br>
    <li><strong>Kitchen Operations Dashboard</strong>
        <ul>
            <li>Sorted order display based on preparation priority</li>
            <li>Ongoing and completed orders view</li>
            <li>Food progress tracking (ordered, preparing, prepared, cancelled)</li>
            <li>Custom preparation notes and dietary requirements display</li>
        </ul>
    </li>
    <br>
    <li><strong>Activity Logging & Monitoring</strong>
        <ul>
            <li>Firebase-based comprehensive activity logs</li>
            <li>Track all operations across the application</li>
            <li>Admin monitoring for security and audit purposes</li>
            <li>Real-time synchronization across all devices</li>
        </ul>
    </li>
    <br>
    <li><strong>Responsive Design</strong>
        <ul>
            <li>Optimized for both mobile and tablet devices</li>
            <li>Horizontal tablet view for enhanced order-taking experience</li>
            <li>Consistent UI/UX across all screen sizes</li>
            <li>Flutter-based smooth animations and transitions</li>
        </ul>
    </li>
    <br>
    <li><strong>Staff Management</strong>
        <ul>
            <li>Add and assign roles (Manager, Cook, Cashier)</li>
            <li>Toggle duty status (on-duty/off-duty) instantly</li>
            <li>Remove or reassign users as needed</li>
            <li>Secure credential management for all staff</li>
        </ul>
    </li>
    <br>
    <li><strong>Customizable Settings</strong>
        <ul>
            <li>Configurable GST rates per hotel requirements</li>
            <li>Hotel branding with custom logo uploads</li>
            <li>Category-wise menu customization with images</li>
            <li>Firebase Storage integration for media management</li>
        </ul>
    </li>
</ul>
<h3 id="why">Why OrderEase?</h3>
<ul>
    <li><strong>Complete Digital Transformation</strong>: Eliminates paper-based processes with QR code billing, digital menus, and paperless settlements for modern restaurant operations.</li>
    <li><strong>Enhanced Operational Efficiency</strong>: Streamlines order flow from placement to preparation with real-time tracking, reducing delays and improving kitchen coordination.</li>
    <li><strong>Data-Driven Insights</strong>: Empowers restaurant owners with comprehensive analytics on sales trends, payment modes, and customer preferences to make informed business decisions.</li>
    <li><strong>Improved Customer Experience</strong>: Live order status tracking via QR codes and digital bill sharing provide transparency and convenience for diners.</li>
    <li><strong>Role-Based Specialization</strong>: Each user role gets a customized dashboard designed for their specific tasks, improving productivity and reducing training time.</li>
    <li><strong>Scalable & Flexible</strong>: Easily configurable for any restaurant size with adjustable tables, GST rates, menu categories, and staff management.</li>
    <li><strong>Cost-Effective Solution</strong>: Reduces operational costs through automation, paperless billing, and efficient resource management without requiring expensive hardware.</li>
    <li><strong>Responsive & Device-Agnostic</strong>: Works seamlessly on both mobile and tablet devices, allowing staff to use their preferred device for optimal workflow.</li>
</ul>
</section>

<section id="getting_started">
  <h2>Getting Started</h2>
  <h3 id="prerequisites">Prerequisites</h3>
  <p>Before you begin, ensure that you have the following prerequisites installed on your development environment:</p>

  <h4>For Frontend (Flutter):</h4>
  <ul>
    <li>
      <strong>Flutter SDK (3.0+)</strong>: To build and run the OrderEase mobile application
      <ul>
        <li><a href="https://flutter.dev/docs/get-started/install">Flutter Installation Guide</a></li>
      </ul>
    </li>
    <li>
      <strong>Dart SDK</strong>: Comes bundled with Flutter SDK
      <ul>
        <li>Verify Dart installation: <code>dart --version</code></li>
      </ul>
    </li>
    <li>
      <strong>Android Studio or VS Code</strong>: IDE for Flutter development
      <ul>
        <li><a href="https://developer.android.com/studio">Android Studio</a></li>
        <li><a href="https://code.visualstudio.com/">VS Code</a> with Flutter and Dart extensions</li>
      </ul>
    </li>
    <li>
      <strong>Android SDK</strong>: Required for building Android applications
      <ul>
        <li>Ensure Android SDK paths are added to PATH environment variables</li>
      </ul>
    </li>
  </ul>

  

  <p>After installing Flutter, run the following command to verify your setup:</p>
  <pre><code>flutter doctor</code></pre>

  <h3 id="installation">Installation</h3>

  <h4>1. Clone the Repository:</h4>
  <pre><code>git clone https://github.com/pannaga-18/OrderEase_prb.git
cd OrderEase</code></pre>

 
  <h3 id="frontend_setup">Building the App</h3>
  <ol>
    <li>
      <p><strong>Navigate to App Directory</strong>: Ensure you are in the root directory of the OrderEase project.</p>
    </li>
    <li>
      <p><strong>Get Dependencies</strong>: Run the below command to fetch and install the necessary Flutter dependencies for the app. This step ensures that your app has access to required packages including Firebase dependencies.</p>
      <pre><code>flutter pub get</code></pre>
    </li>
    <li>
      <p><strong>Connect Android Device or Emulator</strong>: Ensure your Android device is connected to your computer via USB with USB debugging enabled, or use an Android emulator to test the app.</p>
      <p>Check connected devices:</p>
      <pre><code>flutter devices</code></pre>
    </li>
    <li>
      <p><strong>Launch the App</strong>: Run the below command after selecting the target device or emulator. This command will install and launch the app on the specified device.</p>
      <pre><code>flutter run</code></pre>
    </li>
  </ol>

  <h4>Additional Commands:</h4>
  <ul>
    <li><strong>Build APK</strong>: <code>flutter build apk --release</code></li>
    <li><strong>Build for specific device</strong>: <code>flutter run -d &lt;device-id&gt;</code></li>
    <li><strong>Clean build</strong>: <code>flutter clean && flutter pub get</code></li>
  </ul>

  <h3 id="troubleshooting">Troubleshooting</h3>
  <ul>
    <li><strong>Build Errors</strong>: Run <code>flutter clean</code> and rebuild the project</li>
    <li><strong>Dependency Conflicts</strong>: Update Flutter SDK to the latest version: <code>flutter upgrade</code></li>
  </ul>
</section>


<section id="tech_used">
  <h2>TechStack - Built with
    <img src="https://cdn.icon-icons.com/icons2/2530/PNG/512/flutter_button_icon_151957.png" alt="Flutter" height="20" style="vertical-align: middle; filter: none;"/>
    <img src="https://cdn.icon-icons.com/icons2/2530/PNG/512/dart_colour_button_icon_151934.png" alt="Dart" height="20" style="vertical-align: middle; filter: none;"/>
    <img src="https://github.com/user-attachments/assets/b4b3e453-bee1-402c-afd2-c02b137704a6" alt="Firebase" height="20" style="vertical-align: middle; filter: none;"/>
  </h2>
 
  <h3>Frontend Framework</h3>
  <ul>
    <li><strong>Flutter</strong>: Google's UI toolkit for building natively compiled, cross-platform applications with a single codebase. Enables responsive design for both mobile and tablet devices.</li>
    <li><strong>Dart</strong>: A fast, modern, object-oriented programming language optimized for Flutter development, providing strong typing and excellent performance.</li>
  </ul>

  <h3>Backend & Database</h3>
  <ul>
    <li><strong>Firebase Firestore</strong>: NoSQL cloud database for real-time data synchronization, storing orders, menu items, user roles, settlements, and activity logs.</li>
    <li><strong>Firebase Storage</strong>: Cloud storage solution for storing and serving user-uploaded content including category background images and hotel logos.</li>
    <li><strong>Firebase Authentication</strong>: Secure authentication system for managing user credentials and role-based access control across Admin, Manager, Cook, and Cashier roles.</li>
  </ul>

  <h3>Key Flutter Packages & Dependencies</h3>
  <ul>
    <li><strong>cloud_firestore</strong>: Firebase Firestore integration for real-time database operations</li>
    <li><strong>firebase_storage</strong>: Firebase Storage integration for image uploads and retrieval</li>
    <li><strong>firebase_auth</strong>: Firebase Authentication for secure user management</li>
    <li><strong>qr_flutter</strong>: QR code generation for digital bill sharing and order tracking</li>
    <li><strong>pdf</strong>: PDF generation for downloadable and printable bills</li>
    <li><strong>provider</strong>: State management solution for efficient app-wide state handling</li>
    <li><strong>intl</strong>: Internationalization and formatting for dates, currencies, and numbers</li>
  </ul>

  <h3>Development Tools</h3>
  <ul>
    <li><strong>Android Studio / VS Code</strong>: Primary IDEs for Flutter development with debugging and hot reload capabilities</li>
    <li><strong>Firebase Console</strong>: Web-based interface for managing Firebase services, database rules, and analytics</li>
    <li><strong>Git & GitHub</strong>: Version control and collaborative development platform</li>
  </ul>
</section>

<section id = "architecture">
  <h2> System Architecture </h2>
  
<h3>🏗️ High-Level Architecture:</h3>

<pre>
┌─────────────────────────────────────────────────────────────────────────────┐
│                            ORDEREASE APPLICATION                            │
│                                                                             │
│   ┌─────────────────┐    ┌──────────────────┐    ┌────────────────────┐   │
│   │ Landing Screen  │ →  │  Authentication  │ →  │  Role-Based Entry  │   │
│   │ • Registration  │    │  • Login System  │    │  • Admin/Manager   │   │
│   │ • Hotel Setup   │    │  • Hotel ID Auth │    │  • Cook/Cashier    │   │
│   └─────────────────┘    └──────────────────┘    └────────────────────┘   │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                        ROLE-BASED MODULES                           │  │
│   │                                                                     │  │
│   │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  ┌────────────┐ │  │
│   │  │    ADMIN     │  │   MANAGER    │  │   COOK   │  │  CASHIER   │ │  │
│   │  ├──────────────┤  ├──────────────┤  ├──────────┤  ├────────────┤ │  │
│   │  │• Dashboard   │  │• Table Mgmt  │  │• Orders  │  │• Settle    │ │  │
│   │  │• Menu Setup  │  │• Order Entry │  │• Kitchen │  │• Bills     │ │  │
│   │  │• Staff Roles │  │• Item Search │  │• Progress│  │• Payment   │ │  │
│   │  │• Tables/GST  │  │• Order Place │  │• Prepare │  │• QR Bills  │ │  │
│   │  │• Analytics   │  │• Notify Cook │  │• Complete│  │• PDF Gen   │ │  │
│   │  │• Settlements │  │              │  │          │  │            │ │  │
│   │  │• Activity Log│  │              │  │          │  │            │ │  │
│   │  └──────────────┘  └──────────────┘  └──────────┘  └────────────┘ │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                    CUSTOMER-FACING FEATURES                         │  │
│   │  ┌───────────────────────┐          ┌──────────────────────────┐   │  │
│   │  │  QR Order Tracking    │          │   Review & Rating        │   │  │
│   │  │  • Scan Table QR      │          │   • 10-Point Scale       │   │  │
│   │  │  • Live Order Status  │          │   • Post-Settlement      │   │  │
│   │  │  • Real-time Updates  │          │   • Analytics Input      │   │  │
│   │  └───────────────────────┘          └──────────────────────────┘   │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                      STATE MANAGEMENT LAYER                         │  │
│   │                        (Provider Pattern)                           │  │
│   │   • Real-time Data Sync  • Role-Based Access  • Order Flow Control │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │
                         ═════════╪═══════════
                          FLUTTER │ DART
                         ═════════╪═══════════
                                  │
┌─────────────────────────────────▼───────────────────────────────────────────┐
│                          FIREBASE BACKEND SERVICES                          │
│                                                                             │
│  ┌──────────────────────┐  ┌──────────────────────┐  ┌─────────────────┐  │
│  │  AUTHENTICATION      │  │  CLOUD FIRESTORE     │  │ FIREBASE STORAGE│  │
│  ├──────────────────────┤  ├──────────────────────┤  ├─────────────────┤  │
│  │ • Email/Password     │  │ • Hotels Collection  │  │ • Category Imgs │  │
│  │ • Role Management    │  │ • Menu Items         │  │ • Hotel Logos   │  │
│  │ • Session Control    │  │ • Orders (Active)    │  │ • Bill PDFs     │  │
│  │ • Hotel ID Binding   │  │ • Orders (Complete)  │  │ • Media Assets  │  │
│  │                      │  │ • Settlements        │  │                 │  │
│  │                      │  │ • User Roles         │  │                 │  │
│  │                      │  │ • Reviews (Rating)   │  │                 │  │
│  │                      │  │ • Analytics Data     │  │                 │  │
│  │                      │  │ • Activity Logs      │  │                 │  │
│  └──────────────────────┘  └──────────────────────┘  └─────────────────┘  │
│                                                                             │
│                    ┌────────────────────────────────┐                       │
│                    │   REAL-TIME SYNCHRONIZATION    │                       │
│                    │   • Multi-device Support       │                       │
│                    │   • Instant Order Updates      │                       │
│                    │   • Live Kitchen Feed          │                       │
│                    │   • Cross-role Communication   │                       │
│                    └────────────────────────────────┘                       │
└─────────────────────────────────────────────────────────────────────────────┘
                                  │
                         ═════════╪═══════════
                           DATA FLOW
                         ═════════╪═══════════
                                  │
┌─────────────────────────────────▼───────────────────────────────────────────┐
│                            DEVICE DEPLOYMENT                                │
│                                                                             │
│     ┌─────────────────────────┐              ┌─────────────────────────┐   │
│     │   MOBILE DEVICES        │              │   TABLET DEVICES        │   │
│     │   • Portrait View       │              │   • Landscape View      │   │
│     │   • On-the-go Access    │              │   • Enhanced Order UI   │   │
│     │   • All Features        │              │   • Bigger Display      │   │
│     │   • Responsive Design   │              │   • Same Features       │   │
│     └─────────────────────────┘              └─────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              KEY DATA FLOWS                                 │
│                                                                             │
│  Order Flow:  Manager → Order Placement → Cook Dashboard → Preparation     │
│               → Completion → Cashier → Settlement → Bill Generation         │
│                                                                             │
│  Analytics:   All Transactions → Firestore → Analytics Engine →            │
│               Visualizations (Daily/Weekly/Monthly/Yearly Reports)          │
│                                                                             │
│  Customer:    Table QR Scan → Live Order Status → Rating System →          │
│               Feedback Storage → Analytics Integration                      │
└─────────────────────────────────────────────────────────────────────────────┘
</pre>
<h3>🗂️ Project Structure:</h3>

<pre>
OrderEase/
│
├── OrderEase/                # Flutter Frontend
│   ├── lib/
│   │   ├── main.dart          # App entry point
│   │   ├── pages              # Features Screens
│   ├── pubspec.yaml           # Flutter dependencies
│   ├── android/               # Android-specific config
│   ├── ios/                   # iOS-specific config
│   └── README.md
│   ├── server/                 # FastAPI Backend
│       ├── server.py           # Main application file
│       ├── requirements.txt    # Python dependencies
│
├── README.md                  # Main project documentation
└── LICENSE
</pre>

<h3>🔐 OrderEase Security Architecture</h3>

<ul>
  <li><strong>API Key Management</strong>:
    <ul>
      <li>Secure storage of API keys in .env (never committed to Git)</li>
      <li>Server-side key rotation for uninterrupted AI processing</li>
      <li>Keys never exposed to frontend or client devices</li>
    </ul>
  </li>
  
  <li><strong>Data Privacy</strong>:
    <ul>
      <li>Audio is processed completely in-memory</li>
      <li>No audio or generated content stored on the server</li>
      <li>Temporary files auto-deleted after processing</li>
      <li>Zero user tracking — OrderEase does not collect or retain personal data</li>
    </ul>
  </li>
  
  <li><strong>API Security</strong>:
    <ul>
      <li>Strict CORS policies for trusted domains</li>
      <li>Request validation, sanitization, and safe error handling</li>
      <li>Protected backend routes to prevent unauthorized usage</li>
    </ul>
  </li>
</ul>

<h3>⚡ OrderEase Performance Optimizations</h3>

<ul>
  <li><strong>Backend</strong>:
    <ul>
      <li>FastAPI backend with highly optimized async processing</li>
      <li>Groq LLM inference speeds up to 330 tokens/sec</li>
      <li>Memory-efficient pipeline for handling long audio files</li>
      <li>Automatic key rotation prevents API rate-limit slowdowns</li>
    </ul>
  </li>
  
  <li><strong>Frontend</strong>:
    <ul>
      <li>Lazy-loaded UI components for faster initial load</li>
      <li>Optimized PDF generation with cached fonts</li>
      <li>Compressed and optimized images</li>
      <li>Smooth and efficient state management for a responsive UI</li>
    </ul>
  </li>
</ul>
</section>

<section id="screenshots">
  <h2 id="screenshots">App Demonstration</h2>
  <button> <a href="https://drive.google.com/file/d/1n1-7fQX8kG-AyN3iRzpJ3jv9V25sCGOn/view?usp=sharing" target="_blank">Clear here to watch</button></a>  
  <h2> Screenshots </h2>   
  <img src="https://github.com/user-attachments/assets/d6bd2d65-d428-42fb-85ec-74c09cb683cf" style="width: 200px;" />
  <img src="https://github.com/user-attachments/assets/8e57886b-b97d-4e0f-a5b2-5b706a504648" style="width: 200px;" />
  <img src="https://github.com/user-attachments/assets/4cc12fba-0970-4075-8817-d9f5fc1175b7" style="width: 200px;" />
  <img src="https://github.com/user-attachments/assets/12ef30fb-c8ef-4002-8895-a6eb8a92c82f" style="width: 200px;" />
  <img src="https://github.com/user-attachments/assets/a5a7a83d-a530-4dac-9f4e-15809d40e187" style="width: 200px;" />
  <img src="https://github.com/user-attachments/assets/69b02efd-b210-4333-83a1-d4d3573adf2c" style="width: 200px;" />
  <img src="https://github.com/user-attachments/assets/c779e588-933b-418c-b02c-43b988e50107" style="width: 200px;" />
  <img src="https://github.com/user-attachments/assets/92a35f92-bd16-4df0-871a-c51502b645d7" style="width: 200px;" />
  <img src="https://github.com/user-attachments/assets/140f5198-8a1d-4201-9961-c4885a6aa90d" style="width: 200px;" />
  <img src="https://github.com/user-attachments/assets/8b9f325c-ff8b-4510-ae0b-c485cac584eb" style="width: 200px;" />
  <img src="https://github.com/user-attachments/assets/af308e05-06b2-4ca0-8291-d7338f82a54f" style="width: 200px;" />
  <img src="https://github.com/user-attachments/assets/cfe636ad-b298-44c7-bf60-4c681b1a532b" style="width: 200px;" />
  <img src="https://github.com/user-attachments/assets/f9c92b41-cf4b-4343-a97b-80551fbb6997" style="width: 200px;" />
</section>


<section id="conclusion">
  <h2>Conclusion</h2>
  <p>
   OrderEase Lens represents a practical, human-centered assistive technology designed to empower visually impaired individuals with enhanced perception, awareness, and independence. By integrating ESP32-CAM based edge processing with an intelligent mobile application, the system provides essential features such as scene description, object recognition, text reading, and situational navigation without heavy dependence on cloud services. Its modular design, low-cost hardware, and real-time audio feedback make it both accessible and scalable for everyday use. Ultimately, OrderEase Lens demonstrates how affordable innovation, thoughtful engineering, and user-centric design can work together to significantly improve the quality of life for people with vision impairments.
  </p>
</section>



<section id = "team">
  <h2> The Team </h2>
  <h3> Pannaga R Bhat </h3>
<p align="left">
  <a href="https://github.com/pannaga-rj" style="text-decoration: none;" target="_blank" rel="nofollow">
    <img src="https://img.shields.io/badge/GitHub-black?style=flat&logo=github" alt="GitHub" style="max-width: 100%;">
  </a>
  <a href="https://www.linkedin.com/in/pannaga-r-bhat-ba8bb6289/" style="text-decoration: none;" target="_blank">
    <img src="https://img.shields.io/badge/LinkedIn-blue?style=flat&logo=linkedin" alt="LinkedIn" />
  </a>
</p>

<h3> Pradeep P T </h3>
<p align="left">
  <a href="" style="text-decoration: none;" target="_blank">
    <img src="https://img.shields.io/badge/GitHub-black?style=flat&logo=github" alt="GitHub" />
  </a>
  <a href="" style="text-decoration: none;" target="_blank">
    <img src="https://img.shields.io/badge/LinkedIn-blue?style=flat&logo=linkedin" alt="LinkedIn" />
  </a>
</p>

<h3> Prajwal P </h3>
<p align="left">
  <a href="" style="text-decoration: none;" target="_blank">
    <img src="https://img.shields.io/badge/GitHub-black?style=flat&logo=github" alt="GitHub" />
  </a>
  <a href="" style="text-decoration: none;" target="_blank">
    <img src="https://img.shields.io/badge/LinkedIn-blue?style=flat&logo=linkedin" alt="LinkedIn" />
  </a>
</p>

<h3> Pranav Anantha Rao </h3>
<p align="left">
  <a href="" style="text-decoration: none;" target="_blank">
    <img src="https://img.shields.io/badge/GitHub-black?style=flat&logo=github" alt="GitHub" />
  </a>
  <a href="" style="text-decoration: none;" target="_blank">
    <img src="https://img.shields.io/badge/LinkedIn-blue?style=flat&logo=linkedin" alt="LinkedIn" />
  </a>
</p>
</section>
