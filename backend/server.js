const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Database connection
const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

// Add connection error handling
db.connect((err) => {
  if (err) {
    console.error('Error connecting to database:', err);
    return;
  }
  console.log('Connected to MySQL database');
});

// Equipment endpoints
app.get('/api/equipment', (req, res) => {
  const query = `
    SELECT e.*, c.name as category_name 
    FROM equipment e 
    LEFT JOIN equipment_categories c ON e.category_id = c.id
  `;
  db.query(query, (err, results) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json(results);
  });
});

app.post('/api/equipment', (req, res) => {
  const { 
    name, 
    category_id, 
    serial_number, 
    status, 
    location, 
    purchase_date, 
    last_maintenance, 
    next_maintenance, 
    notes 
  } = req.body;

  db.query(
    `INSERT INTO equipment (
      name, category_id, serial_number, status, location, 
      purchase_date, last_maintenance, next_maintenance, notes
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [name, category_id, serial_number, status, location, 
     purchase_date, last_maintenance, next_maintenance, notes],
    (err, result) => {
      if (err) {
        res.status(500).json({ error: err.message });
        return;
      }
      res.status(201).json({ 
        id: result.insertId, 
        message: 'Equipment added successfully' 
      });
    }
  );
});

app.put('/api/equipment/:id', (req, res) => {
  const { 
    name, 
    category_id, 
    serial_number, 
    status, 
    location, 
    purchase_date, 
    last_maintenance, 
    next_maintenance, 
    notes 
  } = req.body;

  // If only status is being updated
  if (req.body.status && Object.keys(req.body).length === 1) {
    db.query('UPDATE equipment SET status = ? WHERE id = ?',
      [req.body.status, req.params.id],
      (err) => {
        if (err) {
          console.error('Status update error:', err);
          res.status(500).json({ error: err.message });
          return;
        }
        res.json({ message: 'Equipment status updated successfully' });
      });
    return;
  }

  // Full equipment update with better error handling
  db.query(
    `UPDATE equipment SET 
      name = COALESCE(?, name),
      category_id = COALESCE(?, category_id),
      serial_number = COALESCE(?, serial_number),
      status = COALESCE(?, status),
      location = COALESCE(?, location),
      purchase_date = COALESCE(?, purchase_date),
      last_maintenance = COALESCE(?, last_maintenance),
      next_maintenance = COALESCE(?, next_maintenance),
      notes = COALESCE(?, notes)
    WHERE id = ?`,
    [name, category_id, serial_number, status, location, 
     purchase_date, last_maintenance, next_maintenance, notes, req.params.id],
    (err) => {
      if (err) {
        console.error('Full update error:', err);
        res.status(500).json({ error: err.message });
        return;
      }
      res.json({ message: 'Equipment updated successfully' });
    }
  );
});

app.delete('/api/equipment/:id', (req, res) => {
  const equipmentId = req.params.id;
  
  db.beginTransaction(async (err) => {
    if (err) {
      console.error('Transaction error:', err);
      return res.status(500).json({ error: err.message });
    }

    try {
      console.log('Starting deletion process for equipment:', equipmentId);

      // 1. First delete from maintenance_schedule (has FK to equipment)
      console.log('Deleting from maintenance_schedule');
      await db.promise().query(
        'DELETE FROM maintenance_schedule WHERE equipment_id = ?',
        [equipmentId]
      );

      // 2. Then delete from maintenance_history (has FK to equipment)
      console.log('Deleting from maintenance_history');
      await db.promise().query(
        'DELETE FROM maintenance_history WHERE equipment_id = ?',
        [equipmentId]
      );

      // 3. Finally delete the equipment (referenced by the above tables)
      console.log('Deleting equipment record');
      await db.promise().query(
        'DELETE FROM equipment WHERE id = ?',
        [equipmentId]
      );

      // Commit the transaction
      db.commit((err) => {
        if (err) {
          console.error('Commit error:', err);
          return db.rollback(() => {
            res.status(500).json({ error: err.message });
          });
        }
        console.log('Successfully deleted equipment and all related records');
        res.json({ message: 'Equipment and related records deleted successfully' });
      });

    } catch (error) {
      console.error('Delete error:', error);
      return db.rollback(() => {
        res.status(500).json({ error: error.message });
      });
    }
  });
});

// Categories endpoints
app.get('/api/categories', (req, res) => {
  db.query('SELECT * FROM equipment_categories', (err, results) => {
    if (err) {
      console.error('Error fetching categories:', err);  // Add this line for debugging
      res.status(500).json({ error: err.message });
      return;
    }
    res.json(results);
  });
});

// Get maintenance history for specific equipment
app.get('/api/maintenance-history/:equipmentId', (req, res) => {
  db.query(
    `SELECT * FROM maintenance_history 
     WHERE equipment_id = ? 
     ORDER BY date DESC`,
    [req.params.equipmentId],
    (err, results) => {
      if (err) {
        res.status(500).json({ error: err.message });
        return;
      }
      res.json(results);
    }
  );
});

// Get all scheduled maintenance
app.get('/api/maintenance-schedule', (req, res) => {
  db.query(
    `SELECT ms.*, e.name as equipment_name, e.category_id, e.last_maintenance, e.status as equipment_status
     FROM maintenance_schedule ms
     JOIN equipment e ON ms.equipment_id = e.id
     ORDER BY ms.scheduled_date`,
    (err, results) => {
      if (err) {
        console.error('Error fetching maintenance schedule:', err);
        res.status(500).json({ error: err.message });
        return;
      }
      console.log('Sending maintenance schedule:', results);
      res.json(results);
    }
  );
});

// Schedule new maintenance
app.post('/api/maintenance-schedule', (req, res) => {
  const { equipment_id, scheduled_date, type, notes } = req.body;
  db.query(
    `INSERT INTO maintenance_schedule 
     (equipment_id, scheduled_date, type, notes, status) 
     VALUES (?, ?, ?, ?, 'Scheduled')`,
    [equipment_id, scheduled_date, type || 'Regular Maintenance', notes],
    (err, result) => {
      if (err) {
        console.error('Error scheduling maintenance:', err);
        res.status(500).json({ error: err.message });
        return;
      }
      res.status(201).json({ 
        message: 'Maintenance scheduled successfully',
        id: result.insertId 
      });
    }
  );
});

// Update maintenance schedule status
app.put('/api/maintenance-schedule/:id/status', (req, res) => {
  const { status } = req.body;
  const scheduleId = req.params.id;
  
  console.log('Received status update request:', { scheduleId, status });

  // First update the maintenance schedule
  db.query(
    'UPDATE maintenance_schedule SET status = ? WHERE id = ?',
    [status, scheduleId],
    (err, result) => {
      if (err) {
        console.error('Database error:', err);
        res.status(500).json({ error: err.message });
        return;
      }
      
      if (result.affectedRows === 0) {
        res.status(404).json({ error: 'Maintenance schedule not found' });
        return;
      }

      // If updating to 'In Progress', also update equipment status
      if (status === 'In Progress') {
        db.query(
          'UPDATE equipment e JOIN maintenance_schedule ms ON e.id = ms.equipment_id SET e.status = ? WHERE ms.id = ?',
          ['Maintenance', scheduleId],
          (err) => {
            if (err) {
              console.error('Error updating equipment status:', err);
              res.status(500).json({ error: err.message });
              return;
            }
            res.json({ message: 'Status updated successfully' });
          }
        );
      } else {
        res.json({ message: 'Status updated successfully' });
      }
    }
  );
});

// Complete maintenance
app.post('/api/maintenance-complete/:scheduleId', (req, res) => {
  const { performed_by, notes, equipment_id, type } = req.body;
  
  console.log('Received maintenance completion request:', req.body);

  db.beginTransaction((err) => {
    if (err) {
      console.error('Transaction error:', err);
      res.status(500).json({ error: err.message });
      return;
    }

    // Step 1: Add to maintenance history
    db.query(
      `INSERT INTO maintenance_history 
       (equipment_id, date, type, performed_by, notes)
       VALUES (?, CURDATE(), ?, ?, ?)`,
      [equipment_id, type, performed_by, notes],
      (err) => {
        if (err) {
          console.error('History insert error:', err);
          db.rollback(() => {
            res.status(500).json({ error: err.message });
          });
          return;
        }

        // Step 2: Update current maintenance schedule entry
        db.query(
          `UPDATE maintenance_schedule 
           SET status = 'Completed',
               completion_date = CURDATE()
           WHERE id = ?`,
          [req.params.scheduleId],
          (err) => {
            if (err) {
              console.error('Schedule update error:', err);
              db.rollback(() => {
                res.status(500).json({ error: err.message });
              });
              return;
            }

            // Step 3: Create new maintenance schedule entry for next maintenance
            db.query(
              `INSERT INTO maintenance_schedule 
               (equipment_id, scheduled_date, status, type, notes)
               VALUES (?, DATE_ADD(CURDATE(), INTERVAL 90 DAY), 'Scheduled', 'Regular Maintenance', 'Scheduled maintenance')`,
              [equipment_id],
              (err) => {
                if (err) {
                  console.error('New schedule creation error:', err);
                  db.rollback(() => {
                    res.status(500).json({ error: err.message });
                  });
                  return;
                }

                // Step 4: Update equipment
                db.query(
                  `UPDATE equipment 
                   SET status = 'Available',
                       last_maintenance = CURDATE(),
                       next_maintenance = DATE_ADD(CURDATE(), INTERVAL 90 DAY)
                   WHERE id = ?`,
                  [equipment_id],
                  (err) => {
                    if (err) {
                      console.error('Equipment update error:', err);
                      db.rollback(() => {
                        res.status(500).json({ error: err.message });
                      });
                      return;
                    }

                    // Commit the transaction
                    db.commit((err) => {
                      if (err) {
                        console.error('Commit error:', err);
                        db.rollback(() => {
                          res.status(500).json({ error: err.message });
                        });
                        return;
                      }
                      res.json({ message: 'Maintenance completed successfully' });
                    });
                  }
                );
              }
            );
          }
        );
      }
    );
  });
});

// Update the schedule-all endpoint
app.post('/api/maintenance-schedule/schedule-all', (req, res) => {
  console.log('Starting schedule-all process');
  
  // First, get all active equipment that doesn't have scheduled maintenance
  const query = `
    SELECT e.id, e.name 
    FROM equipment e
    LEFT JOIN maintenance_schedule ms ON e.id = ms.equipment_id 
      AND ms.status IN ('Scheduled', 'In Progress')
    WHERE e.status != 'Retired'
      AND ms.id IS NULL`;

  db.query(query, (err, equipment) => {
    if (err) {
      console.error('Error fetching equipment:', err);
      res.status(500).json({ error: err.message });
      return;
    }

    if (equipment.length === 0) {
      res.json({ 
        message: 'No equipment needs scheduling',
        scheduledCount: 0 
      });
      return;
    }

    // Create values for bulk insert
    const values = equipment.map(item => [
      item.id,                                    // equipment_id
      new Date().toISOString().split('T')[0],    // scheduled_date (today)
      'Scheduled',                               // status
      'Regular Maintenance',                     // type
      'Scheduled maintenance'                    // notes
    ]);

    // Bulk insert maintenance schedules
    const insertQuery = `
      INSERT INTO maintenance_schedule 
      (equipment_id, scheduled_date, status, type, notes)
      VALUES ?`;

    db.query(insertQuery, [values], (err, result) => {
      if (err) {
        console.error('Error scheduling maintenance:', err);
        res.status(500).json({ error: err.message });
        return;
      }

      res.json({ 
        message: `Scheduled maintenance for ${result.affectedRows} equipment items`,
        scheduledCount: result.affectedRows
      });
    });
  });
});

// Maintenance endpoints
const maintenanceController = {
  async deleteMaintenanceSchedule(req, res) {
    const scheduleId = req.params.id;
    console.log('Attempting to delete maintenance schedule:', scheduleId);
    
    try {
      const result = await db.promise().query(
        'DELETE FROM maintenance_schedule WHERE id = ?',
        [scheduleId]
      );
      
      if (result[0].affectedRows === 0) {
        console.log('No schedule found with id:', scheduleId);
        return res.status(404).json({ error: 'Maintenance schedule not found' });
      }
      
      console.log('Successfully deleted schedule:', scheduleId);
      res.json({ message: 'Maintenance schedule deleted successfully' });
    } catch (error) {
      console.error('Error deleting maintenance schedule:', error);
      res.status(500).json({ error: error.message });
    }
  },

  async deleteEquipment(req, res) {
    const equipmentId = req.params.id;
    
    db.beginTransaction(async (err) => {
      if (err) {
        console.error('Transaction error:', err);
        return res.status(500).json({ error: err.message });
      }

      try {
        // Delete related records in correct order
        await Promise.all([
          db.promise().query('DELETE FROM maintenance_schedule WHERE equipment_id = ?', [equipmentId]),
          db.promise().query('DELETE FROM maintenance_history WHERE equipment_id = ?', [equipmentId])
        ]);

        await db.promise().query('DELETE FROM equipment WHERE id = ?', [equipmentId]);

        db.commit((err) => {
          if (err) {
            return db.rollback(() => {
              res.status(500).json({ error: err.message });
            });
          }
          res.json({ message: 'Equipment and related records deleted successfully' });
        });
      } catch (error) {
        return db.rollback(() => {
          res.status(500).json({ error: error.message });
        });
      }
    });
  }
};

// Apply the controllers
app.delete('/api/maintenance-schedule/:id', maintenanceController.deleteMaintenanceSchedule);
app.delete('/api/equipment/:id', maintenanceController.deleteEquipment);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});