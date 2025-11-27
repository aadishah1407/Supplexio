
# Software Requirements Specification (SRS) for Supplexio Web Application

## 1. Introduction

### 1.1 Purpose

This document provides a detailed description of the Software Requirements Specification (SRS) for the Supplexio Web Application. The Supplexio Web Application is a web-based procurement and reverse auction platform designed to streamline the purchasing process for Axalta Coating Systems. It facilitates the management of products, suppliers, and reverse auctions, and includes an integrated inventory management system.

### 1.2 Document Conventions

This document follows a standard SRS template. The document is written in Markdown.

### 1.3 Intended Audience and Reading Suggestions

This document is intended for a wide audience, including:

*   **Project Managers:** To understand the scope and requirements of the project.
*   **Developers:** To understand the technical requirements and features to be implemented.
*   **QA and Testers:** To develop test cases and verify the functionality of the application.
*   **Business Analysts:** To understand the business logic and workflows of the system.
*   **Stakeholders:** To get a comprehensive overview of the project.

It is recommended to read the document sequentially to get a complete understanding of the system.

### 1.4 Project Scope

The scope of this project is to develop a web-based application with the following key features:

*   **Product Management:** Manage a catalog of products for procurement.
*   **Supplier Management:** Maintain a database of suppliers and their information.
*   **Reverse Auction Management:** Create, manage, and monitor reverse auctions.
*   **Bidding System:** Allow suppliers to participate in reverse auctions by placing bids.
*   **Inventory Management:** A Kanban-based system to manage inventory levels and trigger auctions automatically.
*   **Payment Management:** Track payments to suppliers.
*   **User Management:** Manage user accounts and roles.

### 1.5 References

*   **README.md:** Provides an overview of the project, prerequisites, and setup instructions.
*   **inventory_management_guide.md:** Explains the Kanban-based inventory management system.
*   **Database Schema:** The schema is defined in various `.sql` files in the project root and subdirectories.

## 2. Overall Description

### 2.1 Product Perspective

The Supplexio Web Application is a self-contained system that will be used by Axalta's procurement team and its suppliers. It is a new system that replaces a manual or semi-automated procurement process. The application will be accessible through a web browser.

### 2.2 Product Features

The major features of the Supplexio Web Application are:

*   **Dashboard:** A central dashboard providing an overview of the system, including active auctions, low stock alerts, and quick links to major features.
*   **Product Management:**
    *   Add, edit, and delete products.
    *   Categorize products.
    *   Define product specifications, including base price and unit.
*   **Supplier Management:**
    *   Add, edit, and delete suppliers.
    *   Store supplier details, including contact information and status.
    *   Track supplier performance (future feature).
*   **Reverse Auction Management:**
    *   Create reverse auctions for products.
    *   Set auction start and end times, and starting price.
    *   Monitor real-time bidding activity.
    *   Award auctions to the winning supplier.
    *   Invite specific suppliers to auctions.
*   **Bidding Portal:**
    *   A dedicated portal for suppliers to view and participate in active auctions.
    *   Suppliers can place bids on auctions.
*   **Inventory Management:**
    *   Kanban-based system to track inventory levels (Low, Medium, High).
    *   Set minimum and maximum thresholds for each inventory item.
    *   Automatic triggering of auctions for items with low stock.
    *   Visual representation of stock levels.
*   **Payment Management:**
    *   Track payments to suppliers for completed auctions.
    *   Generate invoices (future feature).
*   **User Management:**
    *   User authentication and authorization.
    *   Different user roles (e.g., Admin, Procurement Manager, Supplier).

### 2.3 User Classes and Characteristics

The system will have the following user classes:

*   **Administrator:**
    *   Has full access to all system features.
    *   Manages user accounts and system settings.
    *   Can override or cancel auctions.
*   **Procurement Manager:**
    *   Manages products, suppliers, and auctions.
    *   Monitors inventory levels.
    *   Initiates auctions.
    *   Awards auctions to suppliers.
*   **Supplier:**
    *   Can view and participate in reverse auctions.
    *   Can place bids.
    *   Can view their bidding history and awarded auctions.
    *   Can manage their own profile information.

### 2.4 Operating Environment

*   **Server-side:**
    *   **Operating System:** Any OS that supports Java and MySQL.
    *   **Application Server:** GlassFish Server 4.1.
    *   **Database:** MySQL Server 8.0 or later.
    *   **Programming Language:** Java (JDK 8).
*   **Client-side:**
    *   **Web Browser:** A modern web browser such as Google Chrome, Mozilla Firefox, or Microsoft Edge.
    *   **JavaScript:** Enabled in the browser.

### 2.5 Design and Implementation Constraints

*   The application must be developed using Java, JSP, and Servlets.
*   The application must use a MySQL database.
*   The application must be deployed on a GlassFish server.
*   The UI should be responsive and user-friendly, using Bootstrap for the front-end framework.

### 2.6 User Documentation

The following user documentation will be provided:

*   **README.md:** For developers and system administrators, with setup and deployment instructions.
*   **inventory_management_guide.md:** For procurement managers, explaining the inventory management system.
*   **Online Help:** The UI will include tooltips and help text to guide users.

### 2.7 Assumptions and Dependencies

*   The `users` table exists in the database, although its creation script is not found in the provided files. It is assumed to have at least `id`, `email`, and `password` columns.
*   The system assumes that the users have a basic understanding of procurement and auction processes.
*   The system depends on the availability of a MySQL database and a GlassFish server.
*   The system relies on an internet connection for suppliers to access the bidding portal.

## 3. System Features

### 3.1 User Management

*   **3.1.1 Description and Priority:** This feature allows for the management of user accounts and their roles. Priority: High.
*   **3.1.2 Stimulus/Response Sequences:**
    *   **Login:** A user enters their credentials. The system validates the credentials and grants access to the appropriate dashboard based on the user's role.
    *   **Logout:** A user clicks the logout button. The system terminates the user's session and redirects them to the login page.
*   **3.1.3 Functional Requirements:**
    *   The system shall provide a secure user login with email and password.
    *   The system shall support different user roles (Administrator, Procurement Manager, Supplier).
    *   The system shall restrict access to features based on user roles.

### 3.2 Product Management

*   **3.2.1 Description and Priority:** This feature allows procurement managers to manage the product catalog. Priority: High.
*   **3.2.2 Stimulus/Response Sequences:**
    *   A procurement manager adds a new product by filling out a form with product details. The system saves the new product to the database.
    *   A procurement manager edits an existing product. The system updates the product details in the database.
*   **3.2.3 Functional Requirements:**
    *   The system shall allow users to add, edit, and delete products.
    *   Each product shall have a name, description, category, base price, and unit.

### 3.3 Supplier Management

*   **3.3.1 Description and Priority:** This feature allows procurement managers to manage the supplier database. Priority: High.
*   **3.3.2 Stimulus/Response Sequences:**
    *   A procurement manager adds a new supplier by filling out a form with supplier details. The system saves the new supplier to the database.
*   **3.3.3 Functional Requirements:**
    *   The system shall allow users to add, edit, and delete suppliers.
    *   Each supplier shall have a name, email, phone number, address, and status.

### 3.4 Reverse Auction Management

*   **3.4.1 Description and Priority:** This feature allows procurement managers to create and manage reverse auctions. Priority: High.
*   **3.4.2 Stimulus/Response Sequences:**
    *   A procurement manager creates a new auction for a product, specifying the start and end times and the starting price. The system creates the auction and sets its status to "SCHEDULED" or "ACTIVE".
    *   The auction ends. The system determines the winning supplier based on the lowest bid and sets the auction status to "COMPLETED".
*   **3.4.3 Functional Requirements:**
    *   The system shall allow users to create reverse auctions for products.
    *   Auctions shall have a start time, end time, and starting price.
    *   The system shall have different auction statuses (e.g., PENDING, ACTIVE, COMPLETED, CANCELLED, SCHEDULED).
    *   The system shall allow inviting specific suppliers to an auction.

### 3.5 Bidding System

*   **3.5.1 Description and Priority:** This feature allows suppliers to participate in reverse auctions. Priority: High.
*   **3.5.2 Stimulus/Response Sequences:**
    *   A supplier views an active auction and places a bid. The system records the bid and updates the current auction price.
*   **3.5.3 Functional Requirements:**
    *   The system shall provide a bidding portal for suppliers.
    *   Suppliers shall be able to view active auctions they are invited to.
    *   Suppliers shall be able to place bids on auctions.
    *   Bids must be lower than the current auction price.

### 3.6 Inventory Management

*   **3.6.1 Description and Priority:** This feature provides a Kanban-based system to manage inventory levels. Priority: High.
*   **3.6.2 Stimulus/Response Sequences:**
    *   The system periodically checks the inventory levels. If an item's quantity falls below the minimum threshold, the system sets its Kanban status to "Low" and flags it as "needs_auction".
    *   A procurement manager initiates an auction for a low-stock item.
*   **3.6.3 Functional Requirements:**
    *   The system shall categorize inventory items into "Low", "Medium", and "High" status based on quantity and thresholds.
    *   The system shall provide a visual representation of inventory levels.
    *   The system shall automatically identify items that need replenishment.
    *   The system shall allow procurement managers to initiate auctions for low-stock items.

## 4. External Interface Requirements

### 4.1 User Interfaces

The application will have a web-based user interface with the following key screens:

*   **Login Page:** For user authentication.
*   **Dashboard:** The main landing page after login, providing an overview of the system.
*   **Product Management Page:** For managing products.
*   **Supplier Management Page:** For managing suppliers.
*   **Auction Management Page:** For managing reverse auctions.
*   **Bidding Page:** For suppliers to place bids.
*   **Inventory Management Page:** For monitoring and managing inventory.
*   **Payment Management Page:** For tracking payments.

### 4.2 Hardware Interfaces

No special hardware interfaces are required. The application will be accessible through standard computer hardware.

### 4.3 Software Interfaces

*   **MySQL Database:** The application will interface with a MySQL database for data storage.
*   **GlassFish Server:** The application will be deployed on a GlassFish application server.
*   **Web Browser:** Users will interact with the application through a standard web browser.

### 4.4 Communications Interfaces

The application will use the HTTP/S protocol for communication between the client (web browser) and the server.

## 5. Other Nonfunctional Requirements

### 5.1 Performance Requirements

*   The application should be responsive, with page load times of under 3 seconds for most pages.
*   The system should be able to handle at least 100 concurrent users.

### 5.2 Safety Requirements

There are no specific safety requirements for this application.

### 5.3 Security Requirements

*   All user passwords must be securely hashed and stored in the database.
*   The application should be protected against common web vulnerabilities, such as SQL injection and Cross-Site Scripting (XSS).
*   Access to different parts of the application should be restricted based on user roles.

### 5.4 Software Quality Attributes

*   **Reliability:** The system should be reliable and available 24/7, with minimal downtime.
*   **Usability:** The user interface should be intuitive and easy to use.
*   **Maintainability:** The code should be well-documented and easy to maintain and modify.
*   **Scalability:** The application should be scalable to accommodate future growth in the number of users and data.

## 6. Other Requirements

There are no other requirements at this time.
