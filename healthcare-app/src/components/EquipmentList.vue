<!-- /components/EquipmentList.vue -->
<template>
  <div class="equipment-list">
    <!-- Header -->
    <div class="header-container">
      <h2>Equipment Inventory</h2>
      <button @click="showAddEquipmentModal = true" class="add-button">
        <i class="fas fa-plus"></i> Add New Equipment
      </button>
    </div>

    <!-- Add Equipment Modal -->
    <div v-if="showAddEquipmentModal" class="modal" @click.self="showAddEquipmentModal = false">
      <div class="modal-content">
        <div class="modal-header">
          <h3>Add New Equipment</h3>
          <button @click="showAddEquipmentModal = false" class="close-button">×</button>
        </div>

        <div class="modal-body">
          <form @submit.prevent="createEquipment" class="add-equipment-form">
            <div class="form-group">
              <label for="name">Equipment Name*</label>
              <input 
                id="name"
                v-model="newEquipment.name"
                type="text"
                required
                placeholder="Enter equipment name"
              />
            </div>

            <div class="form-group">
              <label for="category">Category*</label>
              <select 
                id="category"
                v-model="newEquipment.category_id"
                required
              >
                <option value="">Select a category</option>
                <option 
                  v-for="category in categories" 
                  :key="category.id" 
                  :value="category.id"
                >
                  {{ category.name }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label for="serial">Serial Number</label>
              <input 
                id="serial"
                v-model="newEquipment.serial_number"
                type="text"
                placeholder="Enter serial number"
              />
            </div>

            <div class="form-group">
              <label for="location">Location</label>
              <input 
                id="location"
                v-model="newEquipment.location"
                type="text"
                placeholder="Enter location"
              />
            </div>

            <div class="form-group">
              <label for="purchase_date">Purchase Date</label>
              <input 
                id="purchase_date"
                v-model="newEquipment.purchase_date"
                type="date"
              />
            </div>

            <div class="form-group">
              <label for="notes">Notes</label>
              <textarea 
                id="notes"
                v-model="newEquipment.notes"
                placeholder="Enter any additional notes"
                rows="3"
              ></textarea>
            </div>
          </form>
        </div>

        <div class="modal-footer">
          <button @click="showAddEquipmentModal = false" class="cancel-button">
            <i class="fas fa-times"></i> Cancel
          </button>
          <button 
            @click="createEquipment" 
            class="save-button"
            :disabled="isSaving"
          >
            <i :class="isSaving ? 'fas fa-spinner fa-spin' : 'fas fa-save'"></i>
            {{ isSaving ? 'Saving...' : 'Save Equipment' }}
          </button>
        </div>
      </div>
    </div>
    
    <!-- Search and Filter Bar -->
    <div class="filter-container">
      <div class="search-row">
        <div class="search-box">
          <i class="fas fa-search"></i>
          <input 
            v-model="searchTerm" 
            placeholder="Search equipment..."
            type="text"
          />
        </div>
      </div>
      
      <div class="filter-row">
        <select v-model="categoryFilter">
          <option value="">All Categories</option>
          <option 
            v-for="category in categories" 
            :key="category.id" 
            :value="category.id"
          >
            {{ category.name }}
          </option>
        </select>

        <select v-model="statusFilter">
          <option value="">All Statuses</option>
          <option value="Available">Available</option>
          <option value="Out">Out</option>
          <option value="Maintenance">Maintenance</option>
        </select>

        <button @click="resetFilters" class="reset-filters">
          <i class="fas fa-undo"></i> Reset Filters
        </button>
      </div>
    </div>

    <!-- Equipment Cards -->
    <div v-if="filteredEquipment.length" class="equipment-grid">
      <div 
        v-for="equipment in filteredEquipment" 
        :key="equipment.id" 
        class="equipment-card"
        :class="{ 'maintenance-due': isMaintenanceDue(equipment) }"
      >
        <div class="card-header">
          <h3>{{ equipment.name }}</h3>
          <span :class="['status-badge', statusClass(equipment.status)]">
            {{ equipment.status }}
          </span>
        </div>

        <div class="card-body">
          <div class="info-row">
            <span class="label">Category:</span>
            <span>{{ getCategoryName(equipment.category_id) }}</span>
          </div>
          
          <div class="info-row">
            <span class="label">Location:</span>
            <span>{{ equipment.location || 'N/A' }}</span>
          </div>
          
          <div class="info-row">
            <span class="label">Serial:</span>
            <span>{{ equipment.serial_number || 'N/A' }}</span>
          </div>

          <div class="maintenance-info" v-if="equipment.next_maintenance">
            <i class="fas fa-tools"></i>
            Next Maintenance: {{ formatDate(equipment.next_maintenance) }}
          </div>
        </div>

        <div class="card-actions">
          <button 
            @click="showDetails(equipment)"
            class="action-button details"
          >
            <i class="fas fa-info-circle"></i> Details
          </button>
          
          <!-- Complete Maintenance Button -->
          <button 
            v-if="equipment.status === 'Maintenance'"
            @click="completeMaintenance(equipment)"
            class="action-button complete"
            :disabled="isSaving"
          >
            <i :class="isSaving ? 'fas fa-spinner fa-spin' : 'fas fa-check'"></i>
            Complete
          </button>
          
          <button 
            v-if="equipment.status === 'Available'"
            @click="checkOutEquipment(equipment)"
            class="action-button checkout"
          >
            <i class="fas fa-sign-out-alt"></i> Check Out
          </button>
          
          <button 
            v-if="equipment.status === 'Out'"
            @click="checkInEquipment(equipment)"
            class="action-button checkin"
          >
            <i class="fas fa-sign-in-alt"></i> Check In
          </button>
          
          <button 
            v-if="equipment.status === 'Available'"
            @click="setMaintenance(equipment)"
            class="action-button maintenance"
          >
            <i class="fas fa-tools"></i> Set Maintenance
          </button>
        </div>
      </div>
    </div>
    
    <div v-else class="no-results">
      <i class="fas fa-search"></i>
      <p>No equipment found matching your criteria</p>
    </div>

    <!-- Details Modal -->
    <div v-if="selectedEquipment" class="modal" @click.self="closeModal">
      <div class="modal-content">
        <div class="modal-header">
          <h3>{{ selectedEquipment.name }}</h3>
          <button @click="closeModal" class="close-button">×</button>
        </div>

        <div class="modal-body">
          <div class="detail-section">
            <h4>Basic Information</h4>
            <div class="detail-grid">
              <div class="detail-item">
                <span class="label">Category</span>
                <span>{{ getCategoryName(selectedEquipment.category_id) }}</span>
              </div>
              <div class="detail-item">
                <span class="label">Status</span>
                <span :class="['status-badge', statusClass(selectedEquipment.status)]">
                  {{ selectedEquipment.status }}
                </span>
              </div>
              <div class="detail-item">
                <span class="label">Serial Number</span>
                <span>{{ selectedEquipment.serial_number || 'N/A' }}</span>
              </div>
              <div class="detail-item">
                <span class="label">Location</span>
                <span>{{ selectedEquipment.location || 'N/A' }}</span>
              </div>
              <div class="detail-item">
                <span class="label">Purchase Date</span>
                <span>{{ formatDate(selectedEquipment.purchase_date) }}</span>
              </div>
            </div>
          </div>

          <div class="detail-section">
            <h4>Maintenance Information</h4>
            <div class="detail-grid">
              <div class="detail-item">
                <span class="label">Last Maintenance</span>
                <span>{{ formatDate(selectedEquipment.last_maintenance) }}</span>
              </div>
              <div class="detail-item">
                <span class="label">Next Maintenance</span>
                <span>{{ formatDate(selectedEquipment.next_maintenance) }}</span>
              </div>
            </div>
          </div>

          <div class="detail-section">
            <h4>Notes</h4>
            <div class="notes">
              {{ selectedEquipment.notes || 'No notes available' }}
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <!-- Complete Maintenance Button in Modal -->
          <button 
            v-if="selectedEquipment.status === 'Maintenance'"
            @click="completeMaintenance(selectedEquipment)"
            class="complete-button"
            :disabled="isSaving"
          >
            <i :class="isSaving ? 'fas fa-spinner fa-spin' : 'fas fa-check'"></i>
            {{ isSaving ? 'Completing...' : 'Complete Maintenance' }}
          </button>

          <button @click="editEquipment" class="edit-button">
            <i class="fas fa-edit"></i> Edit
          </button>
          <button @click="deleteEquipment" class="delete-button">
            <i class="fas fa-trash"></i> Delete
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
      searchTerm: '',
      categoryFilter: '',
      statusFilter: '',
      selectedEquipment: null,
      showAddEquipmentModal: false,
      isSaving: false,
      maintenanceThreshold: 7, // Days until maintenance is considered due
      newEquipment: {
        name: '',
        category_id: '',
        serial_number: '',
        location: '',
        purchase_date: '',
        notes: '',
        status: 'Available'
      }
    };
  },

  computed: {
    filteredEquipment() {
      return this.equipment.filter(item => {
        const matchesSearch = item.name.toLowerCase().includes(this.searchTerm.toLowerCase());
        const matchesCategory = !this.categoryFilter || item.category_id === this.categoryFilter;
        const matchesStatus = !this.statusFilter || item.status === this.statusFilter;
        return matchesSearch && matchesCategory && matchesStatus;
      });
    }
  },

  methods: {
    formatDateForMySQL(date) {
      if (!date) return null;
      if (typeof date === 'string') {
        // If it's already a date string, ensure it's in YYYY-MM-DD format
        return date.split('T')[0];
      }
      return date.toISOString().split('T')[0];
    },

    async createEquipment() {
      if (!this.newEquipment.name || !this.newEquipment.category_id) {
        alert('Please fill in all required fields');
        return;
      }

      this.isSaving = true;
      try {
        await api.addEquipment(this.newEquipment);
        await this.fetchEquipment();
        this.showAddEquipmentModal = false;
        this.resetNewEquipmentForm();
        alert('Equipment added successfully!');
      } catch (error) {
        console.error('Error adding equipment:', error);
        alert('Error adding equipment. Please try again.');
      } finally {
        this.isSaving = false;
      }
    },

    async completeMaintenance(equipment) {
      try {
        // Find the active maintenance schedule for this equipment
        const response = await api.getMaintenanceSchedule();
        const maintenanceSchedule = response.data.find(
          schedule => schedule.equipment_id === equipment.id && schedule.status === 'In Progress'
        );

        if (!maintenanceSchedule) {
          console.error('No active maintenance schedule found');
          return;
        }

        const completionData = {
          equipment_id: equipment.id,
          date: new Date().toISOString().split('T')[0],
          type: 'Regular Maintenance',
          performed_by: 'Staff',
          notes: equipment.notes || 'Maintenance completed'
        };

        // Complete the maintenance using the same API endpoint as MaintenanceTracker
        await api.completeMaintenance(maintenanceSchedule.id, completionData);
        
        // Refresh equipment data
        await this.fetchEquipment();
        
        alert('Maintenance completed successfully!');
      } catch (error) {
        console.error('Error completing maintenance:', error);
        alert('Error completing maintenance. Please try again.');
      }
    },

    async checkOutEquipment(equipment) {
      try {
        await api.updateEquipmentStatus(equipment.id, 'Out');
        await this.fetchEquipment();
      } catch (error) {
        console.error('Error checking out equipment:', error);
        alert('Error checking out equipment. Please try again.');
      }
    },

    async checkInEquipment(equipment) {
      try {
        await api.updateEquipmentStatus(equipment.id, 'Available');
        await this.fetchEquipment();
      } catch (error) {
        console.error('Error checking in equipment:', error);
        alert('Error checking in equipment. Please try again.');
      }
    },

    async setMaintenance(equipment) {
      try {
        await api.updateEquipmentStatus(equipment.id, 'Maintenance');
        await this.fetchEquipment();
      } catch (error) {
        console.error('Error setting maintenance status:', error);
        alert('Error setting maintenance status. Please try again.');
      }
    },

    resetNewEquipmentForm() {
      this.newEquipment = {
        name: '',
        category_id: '',
        serial_number: '',
        location: '',
        purchase_date: '',
        notes: '',
        status: 'Available'
      };
    },

    async fetchEquipment() {
      try {
        const response = await api.getEquipment();
        this.equipment = response.data;
      } catch (error) {
        console.error('Error fetching equipment:', error);
        alert('Error loading equipment. Please refresh the page.');
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

    getCategoryName(categoryId) {
      const category = this.categories.find(c => c.id === categoryId);
      return category ? category.name : 'N/A';
    },

    formatDate(date) {
      if (!date) return 'N/A';
      return new Date(date).toLocaleDateString();
    },

    statusClass(status) {
      return {
        'status-available': status === 'Available',
        'status-out': status === 'Out',
        'status-maintenance': status === 'Maintenance'
      };
    },

    isMaintenanceDue(equipment) {
      if (!equipment.next_maintenance) return false;
      try {
        const nextDate = new Date(equipment.next_maintenance);
        if (isNaN(nextDate.getTime())) return false;
        
        const daysUntilMaintenance = Math.ceil(
          (nextDate - new Date()) / (1000 * 60 * 60 * 24)
        );
        return daysUntilMaintenance <= this.maintenanceThreshold;
      } catch (error) {
        console.error('Error calculating maintenance due:', error);
        return false;
      }
    },

    resetFilters() {
      this.searchTerm = '';
      this.categoryFilter = '';
      this.statusFilter = '';
    },

    showDetails(equipment) {
      this.selectedEquipment = equipment;
    },

    closeModal() {
      this.selectedEquipment = null;
    },

    editEquipment() {
      // TODO: Implement edit functionality
      console.log('Edit equipment:', this.selectedEquipment);
    },

    async deleteEquipment() {
      if (!this.selectedEquipment || !this.confirmDeletion()) {
        return;
      }
      
      try {
        await this.deleteMaintenanceSchedules();
        await this.deleteEquipmentRecord();
        await this.handleSuccessfulDeletion();
      } catch (error) {
        this.handleDeletionError(error);
      }
    },

    // Helper methods
    confirmDeletion() {
      return confirm('Are you sure you want to delete this equipment?');
    },

    async deleteMaintenanceSchedules() {
      console.log('Starting deletion process for equipment:', this.selectedEquipment.id);
      
      const scheduleResponse = await api.getMaintenanceSchedule();
      const equipmentSchedules = scheduleResponse.data.filter(
        schedule => schedule.equipment_id === this.selectedEquipment.id
      );
      
      console.log('Found maintenance schedules:', equipmentSchedules);

      for (const schedule of equipmentSchedules) {
        console.log('Deleting maintenance schedule:', schedule.id);
        await api.deleteMaintenanceSchedule(schedule.id);
      }
    },

    async deleteEquipmentRecord() {
      console.log('Deleting equipment:', this.selectedEquipment.id);
      await api.deleteEquipment(this.selectedEquipment.id);
    },

    async handleSuccessfulDeletion() {
      await this.fetchEquipment();
      this.closeModal();
      alert('Equipment deleted successfully!');
    },

    handleDeletionError(error) {
      console.error('Error details:', error);
      console.error('Error response:', error.response?.data);
      alert(`Error deleting equipment: ${error.response?.data?.message || error.message}`);
    }
  },

  async created() {
    await Promise.all([
      this.fetchEquipment(),
      this.fetchCategories()
    ]);
  }
};
</script>

<style scoped>
.equipment-list {
  padding: 20px;
  max-width: 1400px;
  margin: 0 auto;
}

/* Header Styles */
.header-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.header-container h2 {
  font-size: 2em;
  color: #2c3e50;
  margin: 0;
}

.add-button {
  background-color: #28a745;
  color: white;
  border: none;
  border-radius: 6px;
  padding: 10px 20px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 1em;
  transition: all 0.2s ease;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.add-button:hover {
  background-color: #218838;
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.15);
}

/* Filter Styles */
.filter-container {
  margin-bottom: 30px;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.search-row {
  display: flex;
  justify-content: center;
  width: 100%;
}

.search-box {
  position: relative;
  width: 100%;
  max-width: 500px;
}

.search-box i {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: #6c757d;
}

.search-box input {
  width: 100%;
  padding: 12px 12px 12px 40px;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  font-size: 1em;
  transition: border-color 0.2s ease;
}

.search-box input:focus {
  outline: none;
  border-color: #80bdff;
  box-shadow: 0 0 0 0.2rem rgba(0,123,255,.25);
}

.filter-row {
  display: flex;
  gap: 15px;
  justify-content: center;
}

.filter-row select {
  padding: 8px 12px;
  border: 2px solid #e9ecef;
  border-radius: 6px;
  font-size: 1em;
  min-width: 200px;
  cursor: pointer;
}

.reset-filters {
  padding: 8px 16px;
  background: #6c757d;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.2s ease;
}

.reset-filters:hover {
  background: #5a6268;
}

/* Equipment Grid */
.equipment-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.equipment-card {
  background: white;
  border-radius: 10px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  overflow: hidden;
}

.equipment-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

.card-header {
  padding: 15px;
  background: #f8f9fa;
  border-bottom: 1px solid #e9ecef;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h3 {
  margin: 0;
  font-size: 1.2em;
  color: #2c3e50;
}

.status-badge {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.9em;
  font-weight: 500;
}

.status-available { background: #28a745; color: white; }
.status-out { background: #dc3545; color: white; }
.status-maintenance { background: #ffc107; color: black; }

.card-body {
  padding: 15px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 0.95em;
}

.info-row .label {
  color: #6c757d;
  font-weight: 500;
}

.maintenance-info {
  margin-top: 12px;
  padding: 8px;
  background: #f8f9fa;
  border-radius: 4px;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.9em;
  color: #666;
}

.card-actions {
  padding: 15px;
  border-top: 1px solid #e9ecef;
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.action-button {
  padding: 8px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.9em;
  transition: all 0.2s ease;
}

.details { background: #6c757d; color: white; }
.complete { background: #28a745; color: white; }
.checkout { background: #28a745; color: white; }
.checkin { background: #007bff; color: white; }
.maintenance { background: #ffc107; color: black; }

.action-button:hover {
  opacity: 0.9;
  transform: translateY(-1px);
}

/* Modal Styles */
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
  border-radius: 10px;
  width: 90%;
  max-width: 700px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 4px 20px rgba(0,0,0,0.2);
}

.modal-header {
  padding: 20px;
  border-bottom: 1px solid #e9ecef;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h3 {
  margin: 0;
  color: #2c3e50;
}

.close-button {
  background: none;
  border: none;
  font-size: 1.5em;
  cursor: pointer;
  color: #6c757d;
  transition: color 0.2s ease;
}

.close-button:hover {
  color: #343a40;
}

.modal-body {
  padding: 20px;
}

.detail-section {
  margin-bottom: 25px;
}

.detail-section h4 {
  color: #2c3e50;
  margin-bottom: 15px;
  font-size: 1.1em;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.detail-item .label {
  color: #6c757d;
  font-size: 0.9em;
  font-weight: 500;
}

.notes {
  white-space: pre-wrap;
  color: #666;
  background: #f8f9fa;
  padding: 15px;
  border-radius: 6px;
  font-size: 0.95em;
}

.modal-footer {
  padding: 20px;
  border-top: 1px solid #e9ecef;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  flex-wrap: wrap;
}

.complete-button,
.edit-button,
.delete-button {
  padding: 8px 15px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.95em;
  transition: all 0.2s ease;
}

.complete-button {
  background: #28a745;
  color: white;
}

.edit-button {
  background: #007bff;
  color: white;
}

.delete-button {
  background: #dc3545;
  color: white;
}

.complete-button:hover,
.edit-button:hover,
.delete-button:hover {
  opacity: 0.9;
  transform: translateY(-1px);
}

.complete-button:disabled {
  background: #6c757d;
  cursor: not-allowed;
  transform: none;
}

/* Form Styles */
.add-equipment-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  font-weight: 500;
  color: #2c3e50;
  font-size: 0.95em;
}

.form-group input,
.form-group select,
.form-group textarea {
  padding: 10px;
  border: 2px solid #e9ecef;
  border-radius: 6px;
  font-size: 1em;
  transition: border-color 0.2s ease;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #80bdff;
  box-shadow: 0 0 0 0.2rem rgba(0,123,255,.25);
}

.form-group textarea {
  resize: vertical;
  min-height: 100px;
}

/* Responsive Design */
@media (max-width: 768px) {
  .equipment-list {
    padding: 15px;
  }

  .header-container {
    flex-direction: column;
    gap: 15px;
    text-align: center;
  }

  .filter-row {
    flex-direction: column;
  }

  .filter-row select,
  .reset-filters {
    width: 100%;
  }

  .equipment-grid {
    grid-template-columns: 1fr;
  }

  .modal-content {
    width: 95%;
    margin: 10px;
  }

  .detail-grid {
    grid-template-columns: 1fr;
  }

  .card-actions {
    flex-direction: column;
  }

  .action-button {
    width: 100%;
    justify-content: center;
  }
}

.maintenance-due {
  border: 2px solid #ffc107;
}

.no-results {
  text-align: center;
  padding: 40px;
  color: #6c757d;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 15px;
}

.no-results i {
  font-size: 2em;
  opacity: 0.5;
}
</style>