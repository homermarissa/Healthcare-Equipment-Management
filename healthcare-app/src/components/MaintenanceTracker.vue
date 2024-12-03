<template>
    <div class="maintenance-tracker">
      <div class="maintenance-header">
        <h2>Maintenance Tracker</h2>
        <div class="header-actions">
          <button @click="scheduleAllMaintenance" class="schedule-all-button">
            <i class="fas fa-calendar-plus"></i> Schedule All Equipment
          </button>
          <button @click="showScheduleModal = true" class="schedule-button">
            <i class="fas fa-plus"></i> Schedule Maintenance
          </button>
        </div>
      </div>
  
      <!-- Maintenance Overview Cards -->
      <div class="maintenance-overview">
        <div class="overview-card due-soon">
          <h3>Due Soon</h3>
          <div class="card-count">{{ dueSoonCount }}</div>
          <p>Equipment needs maintenance within 7 days</p>
        </div>
        <div class="overview-card overdue">
          <h3>Overdue</h3>
          <div class="card-count">{{ overdueCount }}</div>
          <p>Equipment past maintenance date</p>
        </div>
        <div class="overview-card in-maintenance">
          <h3>In Maintenance</h3>
          <div class="card-count">{{ inMaintenanceCount }}</div>
          <p>Equipment currently being serviced</p>
        </div>
      </div>
  
      <!-- Maintenance Schedule Table -->
      <div class="maintenance-table">
        <h3>Maintenance Schedule</h3>
        <table>
          <thead>
            <tr>
              <th>Equipment</th>
              <th>Category</th>
              <th>Last Maintenance</th>
              <th>Next Due</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in sortedMaintenanceItems" :key="item.id" 
                :class="{ 'overdue': isOverdue(item), 'due-soon': isDueSoon(item) }">
              <td>{{ item.name }}</td>
              <td>{{ getCategoryName(item.category_id) }}</td>
              <td>{{ formatDate(item.last_maintenance) }}</td>
              <td>{{ formatDate(item.next_maintenance) }}</td>
              <td>
                <span :class="['status-badge', statusClass(item.status)]">
                  {{ item.status }}
                </span>
              </td>
              <td class="actions">
                <button @click="completeMaintenance(item)" 
                        v-if="item.status === 'In Progress'"
                        class="complete-button">
                  <i class="fas fa-check"></i> Complete
                </button>
                <button @click="startMaintenance(item)"
                        v-else-if="item.status === 'Scheduled'"
                        class="start-button">
                  <i class="fas fa-play"></i> Start
                </button>
                <button @click="showMaintenanceHistory(item)" 
                        class="history-button">
                  <i class="fas fa-history"></i> History
                </button>
                <button @click="removeFromMaintenanceSchedule(item)"
                        class="remove-button">
                  <i class="fas fa-trash"></i> Remove
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
  
      <!-- Schedule Maintenance Modal -->
      <div v-if="showScheduleModal" class="modal" @click.self="showScheduleModal = false">
        <div class="modal-content">
          <h3>Schedule Maintenance</h3>
          <form @submit.prevent="scheduleNewMaintenance">
            <div class="form-group">
              <label>Equipment</label>
              <select v-model="newMaintenance.equipment_id" required>
                <option value="">Select Equipment</option>
                <option v-for="equip in availableEquipment" 
                        :key="equip.id" 
                        :value="equip.id">
                  {{ equip.name }}
                </option>
              </select>
            </div>
            
            <div class="form-group">
              <label>Scheduled Date</label>
              <input type="date" v-model="newMaintenance.scheduled_date" required>
            </div>
            
            <div class="form-group">
              <label>Notes</label>
              <textarea v-model="newMaintenance.notes" rows="3"></textarea>
            </div>
  
            <div class="modal-actions">
              <button type="button" @click="showScheduleModal = false" class="cancel-button">
                Cancel
              </button>
              <button type="submit" class="submit-button">
                Schedule
              </button>
            </div>
          </form>
        </div>
      </div>
  
      <!-- Maintenance History Modal -->
      <div v-if="selectedEquipment" class="modal" @click.self="selectedEquipment = null">
        <div class="modal-content">
          <h3>Maintenance History - {{ selectedEquipment.name }}</h3>
          <div class="history-list">
            <div v-for="(record, index) in maintenanceHistory" 
                 :key="index" 
                 class="history-item">
              <div class="history-date">{{ formatDate(record.date) }}</div>
              <div class="history-details">
                <strong>Type:</strong> {{ record.type }}<br>
                <strong>Performed by:</strong> {{ record.performed_by }}<br>
                <strong>Notes:</strong> {{ record.notes }}
              </div>
            </div>
          </div>
          <div class="modal-actions">
            <button @click="selectedEquipment = null" class="close-button">
              Close
            </button>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  import api from '@/services/api';
  
  export default {
    data() {
      return {
        equipment: [],
        categories: [],
        maintenanceHistory: [],
        maintenanceSchedule: [],
        selectedEquipment: null,
        showScheduleModal: false,
        newMaintenance: {
          equipment_id: '',
          scheduled_date: '',
          notes: ''
        }
      };
    },
  
    computed: {
      dueSoonCount() {
        return this.sortedMaintenanceItems.filter(item => this.isDueSoon(item)).length;
      },
      overdueCount() {
        return this.sortedMaintenanceItems.filter(item => this.isOverdue(item)).length;
      },
      inMaintenanceCount() {
        return this.sortedMaintenanceItems.filter(item => item.status === 'In Progress').length;
      },
      availableEquipment() {
        const available = this.equipment.filter(item => {
          console.log(`Equipment ${item.name} status:`, item.status);
          return item.status === 'Available';
        });
        console.log('Available equipment:', available);
        return available;
      },
      sortedMaintenanceItems() {
        return this.maintenanceSchedule
          .filter(schedule => {
            // Get the corresponding equipment
            const equipment = this.equipment.find(e => e.id === schedule.equipment_id);
            
            // Only include if:
            // 1. Equipment exists
            // 2. Equipment is not checked out (status !== 'Out')
            // 3. Schedule is not completed
            return equipment && 
                   equipment.status !== 'Out' && 
                   schedule.status !== 'Completed';
          })
          .map(schedule => {
            const equipment = this.equipment.find(e => e.id === schedule.equipment_id);
            return {
              id: schedule.id,
              equipment_id: schedule.equipment_id,
              name: equipment ? equipment.name : 'Unknown Equipment',
              category_id: equipment ? equipment.category_id : null,
              last_maintenance: equipment ? equipment.last_maintenance : null,
              next_maintenance: schedule.scheduled_date,
              scheduled_date: schedule.scheduled_date,
              status: schedule.status || 'Scheduled',
              notes: schedule.notes,
              type: schedule.type
            };
          }).sort((a, b) => {
            if (a.status === 'In Progress' && b.status !== 'In Progress') return -1;
            if (b.status === 'In Progress' && a.status !== 'In Progress') return 1;
            return new Date(a.scheduled_date) - new Date(b.scheduled_date);
          });
      }
    },
  
    methods: {
      formatDateForMySQL(date) {
        if (!date) return null;
        if (typeof date === 'string') {
          return date.split('T')[0];
        }
        return date.toISOString().split('T')[0];
      },
  
      async fetchEquipment() {
        try {
          const response = await api.getEquipment();
          this.equipment = response.data;
          console.log('Fetched equipment:', this.equipment);
        } catch (error) {
          console.error('Error fetching equipment:', error);
        }
      },
  
      async fetchCategories() {
        try {
          const response = await api.getCategories();
          this.categories = response.data;
        } catch (error) {
          console.error('Error fetching categories:', error);
        }
      },
  
      async fetchMaintenanceSchedule() {
        try {
          const response = await api.getMaintenanceSchedule();
          console.log('Fetched maintenance schedule:', response.data);
          this.maintenanceSchedule = response.data;
        } catch (error) {
          console.error('Error fetching maintenance schedule:', error);
        }
      },
  
      getCategoryName(categoryId) {
        const category = this.categories.find(c => c.id === categoryId);
        return category ? category.name : 'N/A';
      },
  
      formatDate(date) {
        if (!date) return 'N/A';
        return new Date(date).toLocaleDateString();
      },
  
      isOverdue(item) {
        if (!item.next_maintenance) return false;
        const nextDate = new Date(item.next_maintenance);
        const today = new Date();
        nextDate.setHours(0, 0, 0, 0);
        today.setHours(0, 0, 0, 0);
        return nextDate < today;
      },
  
      isDueSoon(item) {
        if (!item.next_maintenance) return false;
        const nextDate = new Date(item.next_maintenance);
        const today = new Date();
        nextDate.setHours(0, 0, 0, 0);
        today.setHours(0, 0, 0, 0);
        const daysUntil = Math.ceil((nextDate - today) / (1000 * 60 * 60 * 24));
        return daysUntil > 0 && daysUntil <= 7;
      },
  
      statusClass(status) {
        return {
          'status-available': status === 'Available',
          'status-out': status === 'Out',
          'status-maintenance': status === 'In Progress' || status === 'Scheduled'
        };
      },
  
      async startMaintenance(schedule) {
        try {
          console.log('Starting maintenance for schedule:', schedule);
          
          // Update maintenance schedule status
          await api.updateMaintenanceScheduleStatus(schedule.id, 'In Progress');
          
          // Refresh data
          await Promise.all([
            this.fetchMaintenanceSchedule(),
            this.fetchEquipment()
          ]);
          
          alert('Maintenance started successfully!');
        } catch (error) {
          console.error('Error starting maintenance:', error);
          console.error('Error details:', error.response?.data);
          alert(`Error starting maintenance: ${error.response?.data?.error || 'Please try again.'}`);
        }
      },
  
      async completeMaintenance(schedule) {
        try {
          const completionData = {
            equipment_id: schedule.equipment_id,
            date: new Date().toISOString().split('T')[0],
            type: 'Regular Maintenance',
            performed_by: 'Staff',
            notes: schedule.notes || 'Scheduled maintenance completed'
          };

          console.log('Completing maintenance for schedule:', schedule);
          console.log('Sending completion data:', completionData);
          
          const response = await api.completeMaintenance(schedule.id, completionData);
          console.log('Completion response:', response.data);
          
          // Add a small delay before refreshing to ensure server has processed everything
          await new Promise(resolve => setTimeout(resolve, 500));
          
          // Refresh all relevant data
          await Promise.all([
            this.fetchMaintenanceSchedule(),
            this.fetchEquipment(),
            // If the history modal is open, refresh it too
            this.selectedEquipment ? this.showMaintenanceHistory(this.selectedEquipment) : Promise.resolve()
          ]);
          
          alert('Maintenance completed successfully!');
        } catch (error) {
          console.error('Error completing maintenance:', error);
          console.error('Error response:', error.response?.data);
          throw error;
        }
      },
  
      async showMaintenanceHistory(equipment) {
        this.selectedEquipment = equipment;
        try {
          console.log('Fetching history for equipment:', equipment);
          const response = await api.getMaintenanceHistory(equipment.equipment_id || equipment.id);
          console.log('History response:', response.data);
          this.maintenanceHistory = response.data;
        } catch (error) {
          console.error('Error fetching history:', error);
          console.error('Error response:', error.response?.data);
          throw error;
        }
      },
  
      async scheduleNewMaintenance() {
        try {
          // Get fresh equipment data
          const response = await api.getEquipment();
          const equipment = response.data.find(e => e.id === this.newMaintenance.equipment_id);
          
          console.log('Equipment status check:', equipment);
          
          // Strict status check
          if (!equipment || equipment.status !== 'Available') {
            alert(`Cannot schedule maintenance for equipment that is ${equipment ? equipment.status.toLowerCase() : 'unavailable'}`);
            this.showScheduleModal = false;
            await this.fetchEquipment();
            return;
          }

          // Additional verification that status hasn't changed
          if (equipment.status === 'Out') {
            alert('This equipment is currently checked out and cannot be scheduled for maintenance');
            this.showScheduleModal = false;
            await this.fetchEquipment();
            return;
          }

          const maintenanceData = {
            equipment_id: this.newMaintenance.equipment_id,
            scheduled_date: this.newMaintenance.scheduled_date,
            notes: this.newMaintenance.notes,
            type: 'Regular Maintenance',
            status: 'Scheduled'
          };
          
          await api.scheduleMaintenance(maintenanceData);
          this.showScheduleModal = false;
          this.newMaintenance = {
            equipment_id: '',
            scheduled_date: '',
            notes: ''
          };
          
          await Promise.all([
            this.fetchMaintenanceSchedule(),
            this.fetchEquipment()
          ]);
          
          alert('Maintenance scheduled successfully!');
        } catch (error) {
          console.error('Error scheduling maintenance:', error);
          alert('Error scheduling maintenance. Please try again.');
        }
      },
  
      async scheduleAllMaintenance() {
        try {
          // Filter out equipment that isn't available
          const availableEquipmentIds = this.equipment
            .filter(item => item.status === 'Available')
            .map(item => item.id);

          const response = await api.scheduleAllMaintenance(availableEquipmentIds);
          console.log('Schedule all response:', response.data);
          
          if (response.data.scheduledCount === 0) {
            alert('No available equipment needs scheduling at this time.');
            return;
          }

          await this.fetchMaintenanceSchedule();
          
          alert(`Successfully scheduled maintenance for ${response.data.scheduledCount} equipment items`);
        } catch (error) {
          console.error('Error scheduling all maintenance:', error);
          alert(`Error scheduling maintenance: ${error.response?.data?.error || 'Please try again.'}`);
        }
      },
  
      async removeFromMaintenanceSchedule(item) {
        try {
          if (confirm(`Are you sure you want to remove ${item.name} from the maintenance schedule?`)) {
            await api.deleteMaintenanceSchedule(item.id);
            await this.fetchMaintenanceSchedule();
            alert('Equipment removed from maintenance schedule successfully');
          }
        } catch (error) {
          console.error('Error removing from maintenance schedule:', error);
          alert('Error removing equipment from schedule. Please try again.');
        }
      }
    },
  
    async created() {
      await Promise.all([
        this.fetchEquipment(),
        this.fetchCategories(),
        this.fetchMaintenanceSchedule()
      ]);
    }
  }

  </script>
<style scoped>
.maintenance-tracker {
  max-width: 1200px;
  margin: 20px auto;
  padding: 20px;
}

.maintenance-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

h2 {
  color: #2c3e50;
  margin: 0;
}

.schedule-button {
  background-color: #28a745;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: background-color 0.2s;
}

.schedule-button:hover {
  background-color: #218838;
}

.maintenance-overview {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.overview-card {
  padding: 20px;
  border-radius: 8px;
  color: white;
  text-align: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.overview-card h3 {
  margin: 0;
  font-size: 1.2em;
  opacity: 0.9;
}

.card-count {
  font-size: 2.5em;
  font-weight: bold;
  margin: 10px 0;
}

.overview-card p {
  margin: 0;
  font-size: 0.9em;
  opacity: 0.9;
}

.due-soon { 
  background-color: #ffc107; 
}

.overdue { 
  background-color: #dc3545; 
}

.in-maintenance { 
  background-color: #17a2b8; 
}

.maintenance-table {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  overflow: hidden;
}

.maintenance-table h3 {
  padding: 20px;
  margin: 0;
  background-color: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid #dee2e6;
}

th {
  background-color: #f8f9fa;
  font-weight: 600;
  color: #495057;
}

tr:hover {
  background-color: #f8f9fa;
}

tr.overdue { 
  background-color: #fff3f3; 
}

tr.due-soon { 
  background-color: #fff9e6; 
}

.status-badge {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.9em;
  font-weight: 500;
}

.status-available { 
  background-color: #d4edda; 
  color: #155724; 
}

.status-out { 
  background-color: #f8d7da; 
  color: #721c24; 
}

.status-maintenance { 
  background-color: #fff3cd; 
  color: #856404; 
}

.actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.complete-button, 
.start-button, 
.history-button, 
.remove-button {
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9em;
  transition: opacity 0.2s;
}

.complete-button:hover, 
.start-button:hover, 
.history-button:hover, 
.remove-button:hover {
  opacity: 0.9;
}

.complete-button { 
  background-color: #28a745; 
  color: white; 
}

.start-button { 
  background-color: #007bff; 
  color: white; 
}

.history-button { 
  background-color: #6c757d; 
  color: white; 
}

.remove-button {
  background-color: #dc3545;
  color: white;
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9em;
  transition: opacity 0.2s;
  display: flex;
  align-items: center;
  gap: 4px;
}

.remove-button:hover {
  opacity: 0.9;
}

.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 20px;
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
}

.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
  color: #495057;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 8px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 14px;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  border-color: #80bdff;
  outline: none;
  box-shadow: 0 0 0 0.2rem rgba(0,123,255,.25);
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
  padding-top: 15px;
  border-top: 1px solid #dee2e6;
}

.history-list {
  max-height: 400px;
  overflow-y: auto;
}

.history-item {
  padding: 15px;
  border-bottom: 1px solid #dee2e6;
}

.history-item:last-child {
  border-bottom: none;
}

.history-date {
  font-weight: bold;
  color: #495057;
  margin-bottom: 5px;
}

.history-details {
  font-size: 0.9em;
  color: #6c757d;
}

@media (max-width: 768px) {
  .maintenance-overview {
    grid-template-columns: 1fr;
  }
  
  .actions {
    flex-direction: column;
  }
  
  .modal-content {
    width: 95%;
    margin: 10px;
  }

  table {
    display: block;
    overflow-x: auto;
  }
}

.header-actions {
  display: flex;
  gap: 10px;
}

.schedule-all-button {
  background-color: #28a745;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
}

.schedule-all-button:hover {
  background-color: #218838;
}

.schedule-all-button i {
  font-size: 14px;
}
</style>