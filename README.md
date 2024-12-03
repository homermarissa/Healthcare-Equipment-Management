# Healthcare Equipment Management System

This project is a full-stack application built with Vue.js and Node.js designed to manage and track healthcare equipment. It features automated maintenance scheduling, equipment status monitoring, and a maintenance history system.

## Features

- **Automated Maintenance Scheduling**: Automatically schedule regular maintenance for all equipment to ensure optimal performance.
- **Equipment Status Monitoring**: Track the status and lifecycle of each piece of equipment.
- **Maintenance History**: Maintain a detailed history of all maintenance activities for compliance and analysis.

## Technologies Used

- **Frontend**: Vue.js
- **Backend**: Node.js, Express
- **Database**: MySQL

## Setup

1. Clone the repository.
2. Install dependencies:
   ```bash
   # Frontend
   cd healthcare-app
   npm install

   # Backend
   cd backend
   npm install
   ```
3. Configure the database connection in `backend/.env`.
4. Run the application:
   ```bash
   # Frontend
   npm run serve

   # Backend
   node server.js
   ```
   
## Database Setup

1. Create a new MySQL database:
   ```sql
   CREATE DATABASE healthcare_app;
   ```

2. Import the database structure:
   ```bash
   mysql -u root -p healthcare_app < database/healthcare_app_backup.sql
   ```
