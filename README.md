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
  <li> <a href = "#app_demonstration"> App Demonstration & Testing </a></li>
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
    <img src="https://github.com/user-attachments/assets/deea2cf0-377f-4e47-b9fb-5290d8d108c0" alt="Firebase" height="20" style="vertical-align: middle; filter: none;"/>
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
    <li><strong>Firebase Hosting</strong>: Hosted the web application on Firebase Hosting for secure, fast, and scalable access.</li>
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
┌────────────────────────────────────────────────────────────────────────────┐
│                            ORDEREASE APPLICATION                           │
│                                                                            │
│   ┌─────────────────┐    ┌──────────────────┐    ┌────────────────────┐    │
│   │ Landing Screen  │ →  │  Authentication  │ →  │  Role-Based Entry  │    │
│   │ • Registration  │    │  • Login System  │    │  • Admin/Manager   │    │
│   │ • Hotel Setup   │    │  • Hotel ID Auth │    │  • Cook/Cashier    │    │
│   └─────────────────┘    └──────────────────┘    └────────────────────┘    │
│                                                                            │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                        ROLE-BASED MODULES                           │  │
│   │                                                                     │  │
│   │  ┌──────────────┐  ┌───────────────┐  ┌──────────┐  ┌────────────┐  │  │
│   │  │    ADMIN     │  │   MANAGER     │  │   COOK   │  │  CASHIER   │  │  │
│   │  ├──────────────┤  ├───────────────┤  ├──────────┤  ├────────────┤  │  │
│   │  │• Dashboard   │  │• Table Mgmt   │  │• Orders  │  │• Settle    │  │  │
│   │  │• Menu Setup  │  │• Order Entry  │  │• Kitchen │  │• Bills     │  │  │
│   │  │• Staff Roles │  │• Item Search  │  │• Progress│  │• Payment   │  │  │
│   │  │• Tables/GST  │  │• Order Place  │  │• Prepare │  │• QR Bills  │  │  │
│   │  │• Analytics   │  │• Notify Cook  │  │• Complete│  │• PDF Gen   │  │  │
│   │  │• Settlements │  │• Food Progress│  │          │  │            │  │  │
│   │  │• Activity Log│  │               │  │          │  │            │  │  │
│   │  ├──────────────┤  ├───────────────┤  ├──────────┤  ├────────────┤  │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                                                                            │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                    CUSTOMER-FACING FEATURES                         │  │
│   │  ┌───────────────────────┐          ┌──────────────────────────┐    │  │
│   │  │  QR Order Tracking    │          │   Review & Rating        │    │  │
│   │  │  • Scan Table QR      │          │   • 10-Point Scale       │    │  │
│   │  │  • Live Order Status  │          │   • Post-Settlement      │    │  │
│   │  │  • Real-time Updates  │          └──────────────────────────┘    │  │
│   │  └───────────────────────┘                                          │  │  
│   └─────────────────────────────────────────────────────────────────────┘  │
│                                                                            │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                      STATE MANAGEMENT LAYER                         │  │
│   │                        (Provider Pattern)                           │  │
│   │   • Real-time Data Sync  • Role-Based Access  • Order Flow Control  │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────┬──────────────────────────────────────────┘
                                  │
                         ═════════╪═══════════
                          FLUTTER │   DART
                         ═════════╪═══════════
                                  │
┌─────────────────────────────────▼─────────────────────────────────────────┐
│                          FIREBASE BACKEND SERVICES                        │
│                                                                           │
│  ┌──────────────────────┐  ┌──────────────────────┐  ┌─────────────────┐  │
│  │  AUTHENTICATION      │  │  CLOUD FIRESTORE     │  │ FIREBASE STORAGE│  │
│  ├──────────────────────┤  ├──────────────────────┤  ├─────────────────┤  │
│  │ • Email/Password     │  │ • Hotels/{HotelId}/  │  │ • Menu Images   │  │  
│  │ • Role Management    │  │   ├─ Category Imgs   │  │ • Hotel Logos   │  │
│  │ • Session Control    │  │   ├─ Menu            │  └─────────────────┘  │
│  │ • Hotel ID Binding   │  │   ├─ Bill            │                       │      
│  │                      │  │   ├─ Cook            │                       │ 
│  │                      │  │   ├─ Food Review     │                       │
│  │                      │  │   ├─ Settlements     │                       │
│  │                      │  │   ├─ Transactions    │                       │
│  │                      │  │   ├─ Users           │                       │
│  │                      │  │   ├─ Activity Logs   │                       │
│  │                      │  └──────────────────────┘                       │ 
│  └──────────────────────┘                                                 │ 
│                                                                           │
│                    ┌────────────────────────────────┐                     │
│                    │   REAL-TIME SYNCHRONIZATION    │                     │
│                    │   • Multi-device Support       │                     │
│                    │   • Instant Order Updates      │                     │
│                    │   • Live Kitchen Feed          │                     │
│                    │   • Cross-role Communication   │                     │
│                    └────────────────────────────────┘                     │
└───────────────────────────────────────────────────────────────────────────┘
                                  │
                         ═════════╪═══════════
                              DATA FLOW
                         ═════════╪═══════════
                                  │
┌─────────────────────────────────▼───────────────────────────────────────────┐
│                            DEVICE DEPLOYMENT                                │
│                                                                             │
│     ┌─────────────────────────┐              ┌─────────────────────────┐    │
│     │   MOBILE DEVICES        │              │   TABLET DEVICES        │    │
│     │   • Portrait View       │              │   • Landscape View      │    │
│     │   • On-the-go Access    │              │   • Enhanced Order UI   │    │
│     │   • All Features        │              │   • Bigger Display      │    │
│     │   • Responsive Design   │              │   • Same Features       │    │
│     └─────────────────────────┘              └─────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              KEY DATA FLOWS                                 │
│                                                                             │
│  Order Flow:  Manager → Order Placement → Cook Dashboard → Preparation      │
│               → Completion → Cashier → Settlement → Bill Generation         │
│                                                                             │
│  Analytics:   All Transactions → Firestore → Analytics Engine →             │
│               Visualizations (Daily/Weekly/Monthly/Yearly Reports)          │
│                                                                             │
│  Customer:    Table QR Scan → Live Order Status → Rating System →           │
│               Feedback Storage → Analytics Integration                      │
└─────────────────────────────────────────────────────────────────────────────┘
</pre>

<h3>🗂️ Project Structure:</h3>
<pre>
OrderEase/
│
├── lib/                                # Flutter Application Source Code
│   ├── main.dart                       # App entry point & initialization
│   ├── firebase_options.dart           # Firebase configuration
│   │
│   ├── Admin/                          # Admin Module
│   │   ├── logs/                       # Logs Module
│   │   ├── menu/                       # Menu & category management
│   │   ├── roles/                      # Staff role assignment
│   │   ├── admin_dashboard.dart        # Admin Panel
│   │
│   ├── Manager/                        # Manager Module
│   │
│   ├── Cook/                           # Cook Module
│   │
│   ├── Settlements/                    # Settlement & Billing Module
│   │   ├── Bill_Print/                 # Bill generation components
│   │   ├── analytics_dashboard.dart    # Analytics visualization
│   │   ├── cleared_settlements.dart    # Settlement history
│   │   ├── get_analytics_report.dart   # Report generation
│   │   ├── pending_settlements.dart    # Pending bills view
│   │   ├── settlements_table_dashboard.dart  # Settlement management
│   │   └── settlements_view.dart       # Detailed settlement view
│   │
│   ├── Website_Feature/                # Customer-Facing Features
│   │   ├── Customer/                   # Customer interface components
│   │   ├── web_home_page.dart          # Landing Webpage
│   │   └── main_web.dart               # Web interface entry
│   │
│   ├── Authentication/                 # Authentication Module
│   │   ├── auth.dart                   # Hotel registration
│   │
│   ├── LandingScreen/                  # Landing Page
│   │   └── landing_page.dart           # Initial entry screen
│   │
│   ├── Review_System/                  # Customer Feedback Module
│   │   ├── review_system.dart          # 10-point rating interface
│   │
│   └── util_components/                # Reusable UI Components
│       ├── util.dart                   # Custom Util widgets
│       ├── QR_Code/                    # QR Generation components
│
├── android/                            # Android Configuration
│ 
├── assets/                             # Static Assets
│   ├── images/                         # App images & icons
│   ├── fonts/                          # Custom fonts
│   └── logos/                          # Brand assets
│
├── pubspec.yaml                        # Flutter dependencies & config
├── pubspec.lock                        # Dependency lock file
├── analysis_options.yaml               # Dart analyzer settings
├── README.md                           # Project documentation
└── LICENSE                             # Project license
</pre>
<h3>🔐 OrderEase Security Architecture</h3>
<ul>
  <li><strong>Firebase Authentication</strong>:
    <ul>
      <li>Secure email/password authentication for all users</li>
      <li>Unique Hotel ID assignment for multi-tenant isolation</li>
      <li>Role-based access control (RBAC) for Admin, Manager, Cook, and Cashier</li>
      <li>Session management with automatic token refresh</li>
      <li>Password encryption and secure credential storage</li>
    </ul>
  </li>
  
  <li><strong>Data Security</strong>:
    <ul>
      <li>End-to-end encryption for data transmission between app and Firebase</li>
      <li>Firestore Security Rules to restrict data access based on user roles</li>
      <li>Hotel data isolation - users can only access their own hotel's data</li>
      <li>Secure Firebase Storage rules for image and PDF uploads</li>
      <li>Activity logging for audit trails and monitoring</li>
    </ul>
  </li>
  
  <li><strong>Role-Based Access Control (RBAC)</strong>:
    <ul>
      <li><strong>Admin</strong>: Full access to all features, staff management, and analytics</li>
      <li><strong>Manager</strong>: Table management, order placement, and customer notifications</li>
      <li><strong>Cook</strong>: Kitchen dashboard, order preparation, and status updates</li>
      <li><strong>Cashier</strong>: Billing, settlements, and payment processing only</li>
      <li>Each role has restricted access to prevent unauthorized operations</li>
    </ul>
  </li>
  
  <li><strong>Firebase Security Rules</strong>:
    <ul>
      <li>Read/Write permissions enforced at database level</li>
      <li>User authentication required for all database operations</li>
      <li>Hotel ID validation to prevent cross-hotel data access</li>
      <li>Rate limiting to prevent abuse and DDoS attacks</li>
    </ul>
  </li>
  
  <li><strong>Payment & Billing Security</strong>:
    <ul>
      <li>Secure PDF generation for bills with encrypted QR codes</li>
      <li>Payment mode tracking (Cash, UPI, Card) without storing sensitive card details</li>
      <li>Settlement logs maintained for financial auditing</li>
      <li>No storage of customer payment credentials in the application</li>
    </ul>
  </li>
  
  <li><strong>Data Privacy</strong>:
    <ul>
      <li>Customer data (orders, reviews) anonymized for analytics</li>
      <li>Optional customer feedback - no mandatory personal information collection</li>
      <li>QR code order tracking without requiring customer login</li>
      <li>Compliance with data protection best practices</li>
    </ul>
  </li>
  
  <li><strong>Application Security</strong>:
    <ul>
      <li>Input validation and sanitization to prevent injection attacks</li>
      <li>Secure API calls with proper error handling</li>
      <li>Protected routes to prevent unauthorized access to sensitive screens</li>
      <li>Regular security updates through Firebase SDK</li>
    </ul>
  </li>
  
  <li><strong>Device Security</strong>:
    <ul>
      <li>Secure local storage for session tokens</li>
      <li>Automatic logout after inactivity timeout</li>
      <li>Support for biometric authentication (future enhancement)</li>
      <li>Encrypted communication between app and Firebase services</li>
    </ul>
  </li>
</ul>

<section id="app_demonstration">
  <h2>📱 App Demonstration & Testing</h2>
  
  <h3>🎥 Video Demonstrations</h3>
  <p>
    <strong>Before creating new credentials or testing the application, we highly recommend watching the demonstration videos to understand the complete workflow and features of OrderEase.</strong> These videos provide a comprehensive walkthrough of the system setup and order management process, helping you navigate the application effectively.
  </p>
  
  <h4>Demo Videos:</h4>
  <ol>
    <li>
      <strong>Admin Setup & Dashboard Features</strong>
      <ul>
        <li>Hotel registration and initial setup process</li>
        <li>Menu management, category creation, and customization</li>
        <li>Staff role assignment and table configuration</li>
        <li>GST settings and settlement management</li>
      </ul>
      <p>📹 <a href="https://drive.google.com/file/d/1UNBBgJFlUzvp_07anUJ3DBDqeeXob7zz/view?usp=sharing">Watch Admin Setup Demo</a></p>
    </li>
    <br>
    <li>
      <strong>Complete Order Management Flow</strong>
      <ul>
        <li>Manager: Table selection and order placement</li>
        <li>Cook: Kitchen dashboard and order preparation</li>
        <li>Cashier: Billing and settlement process</li>
        <li>Customer: QR code order tracking and rating</li>
        <li>End-to-end workflow from order to settlement</li>
         <li>Analytics dashboard and business insights</li>
      </ul>
      <p>📹 <a href="https://drive.google.com/file/d/1yvutbD5sgKxPu_93dsWnhT4bVcKI5pZS/view?usp=sharing">Watch Order Management Demo</a></p>
    </li>
  </ol>

  <h3>📲 Download & Install APK</h3>
  <p>
    You can download and install the OrderEase APK on your Android device (mobile or tablet) to test all features. The application is optimized for both portrait (mobile) and landscape (tablet) orientations.
  </p>
  <p>
    📥 <strong>Download APK:</strong> <a href="YOUR_APK_DOWNLOAD_LINK">OrderEase APK</a>
  </p>
  <p>
    <em>Note: Enable "Install from Unknown Sources" in your Android settings to install the APK.</em>
  </p>

  <h3>🔑 Test Credentials</h3>
  <p>
    For quick evaluation and testing, you can use the following pre-configured credentials. These accounts are set up with sample data to help you explore all features immediately:
  </p>

  <h4>Sample Hotel Details:</h4>
  <ul>
    <li><strong>Hotel Name:</strong> Shree Guru Sagar </li>
    <li><strong>Hotel ID:</strong> <code>1</code></li>
  </ul>

  <h4>User Credentials by Role:</h4>
  <table border="1" cellpadding="10" cellspacing="0" style="border-collapse: collapse; width: 100%;">
    <thead>
      <tr style="background-color: #f2f2f2;">
        <th>Role</th>
        <th>Email</th>
        <th>Password</th>
        <th>Access Level</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><strong>Admin</strong></td>
        <td><code>sgs@1gmail.com</code></td>
        <td><code>sgs1234</code></td>
        <td>Full access to all features</td>
      </tr>
      <tr>
        <td><strong>Manager</strong></td>
        <td><code>prb2@gmail.com</code></td>
        <td><code>qwe1234</code></td>
        <td>Table & order management</td>
      </tr>
      <tr>
        <td><strong>Cook</strong></td>
        <td><code>prb1@gmail.com</code></td>
        <td><code>qwe1234</code></td>
        <td>Kitchen operations</td>
      </tr>
      <tr>
        <td><strong>Cashier</strong></td>
        <td><code>prb3@gmail.com</code></td>
        <td><code>qwe1234</code></td>
        <td>Billing & settlements</td>
      </tr>
    </tbody>
  </table>

  <h3>🆕 Create Your Own Hotel</h3>
  <p>
    Alternatively, you can register your own hotel and create custom credentials to experience the complete setup process:
  </p>
  <ol>
    <li>Download and install the OrderEase APK</li>
    <li>Open the application and navigate to the Registration screen</li>
    <li>Fill in your hotel details (name, address, contact, GST number, etc.)</li>
    <li>Upload your hotel logo (optional)</li>
    <li>Complete registration to receive a unique Hotel ID</li>
    <li>Login as Admin using your registered credentials</li>
    <li>Set up your menu, add staff roles, configure tables, and start managing orders</li>
  </ol>

  <h3>📸 Screenshots</h3>
  <p>Below are screenshots showcasing OrderEase features across different roles and devices:</p>
  
  <h4>Mobile View:</h4>
  <ul>
    <li>Landing & Authentication screens</li>
    <li>Admin Dashboard & Menu Management</li>
    <li>Manager Order Placement</li>
    <li>Cook Kitchen Dashboard</li>
    <li>Cashier Settlement & QR Bill</li>
    <li>Customer Order Tracking & Rating</li>
  </ul>
  <!-- Add your mobile screenshots here -->
  <p>📹 <a href="YOUR_MSS_LINK">Watch all Mobile View Snapshots here</a></p>
  
  <h4>Tablet View:</h4>
  <ul>
    <li>Landscape Admin Dashboard</li>
    <li>Enhanced Order Management Interface</li>
    <li>Kitchen Operations Display</li>
    <li>Settlement Dashboard</li>
  </ul>
  <!-- Add your tablet screenshots here -->
  <p>📹 <a href="YOUR_TSS_LINK">Watch all Tablet View Snapshots here</a></p>

  <h3>💡 Testing Tips</h3>
  <ul>
    <li><strong>Start with Admin:</strong> Login as Admin first to understand the complete setup and configuration options</li>
    <li><strong>Follow the Order Flow:</strong> Test the complete flow by logging in as Manager → Cook → Cashier sequentially</li>
    <li><strong>Try QR Features:</strong> Scan the table QR code to experience customer-facing order tracking</li>
    <li><strong>Explore Analytics:</strong> Check the analytics dashboard to see visual insights and reports</li>
    <li><strong>Test on Tablet:</strong> Experience the enhanced landscape view on tablet devices for better usability</li>
  </ul>

  <h3>⚠️ Important Notes</h3>
  <ul>
    <li>Test credentials are shared among evaluators - data may change during testing</li>
    <li>For isolated testing, create your own hotel registration</li>
    <li>Ensure stable internet connection for real-time Firebase synchronization</li>
    <li>All features work best on Android 8.0 (API level 26) or higher</li>
  </ul>
</section>


<section id="conclusion">
  <h2>Conclusion</h2>
  <p>
    OrderEase represents a comprehensive, practical solution for modern restaurant management, designed to streamline operations and enhance efficiency across all levels of service. By integrating Flutter's cross-platform capabilities with Firebase's real-time database infrastructure, the system provides essential features such as smart menu management, live order tracking, digital billing, and powerful business analytics without the complexity of traditional restaurant management systems. Its role-based modular design, responsive UI for mobile and tablet devices, and paperless operations make it both accessible and scalable for restaurants of any size. The inclusion of customer-facing features like QR code order tracking and a 10-point rating system bridges the gap between restaurant operations and customer satisfaction. Ultimately, OrderEase demonstrates how thoughtful software architecture, user-centric design, and cloud-based technology can work together to digitally transform restaurant operations, reduce operational costs, and improve both staff productivity and customer experience in the competitive food service industry.
  </p>
</section>



<section id = "team">
  <h2> Developed By: </h2>
  <h3> Pannaga R Bhat </h3>
<p align="left">
  <a href="https://github.com/pannaga-rj" style="text-decoration: none;" target="_blank" rel="nofollow">
    <img src="https://img.shields.io/badge/GitHub-black?style=flat&logo=github" alt="GitHub" style="max-width: 100%;">
  </a>
  <a href="https://mail.google.com/mail/?view=cm&fs=1&to=pannaga.rj@gmail.com" target="_blank">
    <img src="https://img.shields.io/badge/Gmail-D14836?style=flat&logo=gmail&logoColor=white" alt="Gmail">
  </a>

  <!-- <a href="https://www.linkedin.com/in/pannaga-r-bhat-ba8bb6289/" style="text-decoration: none;" target="_blank">
    <img src="https://img.shields.io/badge/LinkedIn-blue?style=flat&logo=linkedin" alt="LinkedIn" />
  </a> -->
</p>
</section>
