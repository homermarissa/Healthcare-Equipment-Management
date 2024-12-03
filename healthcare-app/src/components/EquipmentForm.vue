<!-- /components/EquipmentForm.vue -->
<template>
  <div class="equipment-form">
    <h2>Add New Equipment</h2>
    <form @submit.prevent="submitForm" class="form-grid">
      <!-- Basic Info Section -->
      <div class="form-section">
        <h3>Basic Information</h3>
        <div class="form-group">
          <label for="name">Equipment Name*</label>
          <input 
            id="name"
            v-model="equipment.name"
            type="text"
            required
            placeholder="Enter equipment name"
          />
        </div>

        <div class="form-group">
          <label for="category">Category*</label>
          <select 
            id="category"
            v-model="equipment.category_id"
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
            v-model="equipment.serial_number"
            type="text"
            placeholder="Enter serial number"
          />
        </div>

        <div class="form-group">
          <label for="status">Status*</label>
          <select 
            id="status"
            v-model="equipment.status"
            required
          >
            <option value="Available">Available</option>
            <option value="Out">Out</option>
            <option value="Maintenance">Maintenance</option>
          </select>
        </div>
      </div>

      <!-- Location Section -->
      <div class="form-section">
        <h3>Location Details</h3>
        <div class="form-group">
          <label for="location">Location</label>
          <input 
            id="location"
            v-model="equipment.location"
            type="text"
            placeholder="Enter equipment location"
          />
        </div>
      </div>

      <!-- Maintenance Section -->
      <div class="form-section">
        <h3>Maintenance Information</h3>
        <div class="form-group">
          <label for="purchase-date">Purchase Date</label>
          <input 
            id="purchase-date"
            v-model="equipment.purchase_date"
            type="date"
          />
        </div>

        <div class="form-group">
          <label for="last-maintenance">Last Maintenance</label>
          <input 
            id="last-maintenance"
            v-model="equipment.last_maintenance"
            type="date"
          />
        </div>

        <div class="form-group">
          <label for="next-maintenance">Next Maintenance</label>
          <input 
            id="next-maintenance"
            v-model="equipment.next_maintenance"
            type="date"
          />
        </div>
      </div>

      <!-- Notes Section -->
      <div class="form-section">
        <h3>Additional Notes</h3>
        <div class="form-group">
          <label for="notes">Notes</label>
          <textarea 
            id="notes"
            v-model="equipment.notes"
            rows="4"
            placeholder="Enter any additional notes"
          ></textarea>
        </div>
      </div>

      <div class="form-actions">
        <button type="submit" class="submit-button">Add Equipment</button>
        <button type="button" @click="resetForm" class="reset-button">Reset Form</button>
      </div>
    </form>
  </div>
</template>

<script>
import api from '@/services/api';

export default {
  data() {
    return {
      categories: [],
      equipment: this.getDefaultEquipment()
    };
  },
  methods: {
    getDefaultEquipment() {
      return {
        name: '',
        category_id: '',
        serial_number: '',
        status: 'Available',
        location: '',
        purchase_date: '',
        last_maintenance: '',
        next_maintenance: '',
        notes: ''
      };
    },
    async submitForm() {
      try {
        await api.addEquipment(this.equipment);
        this.$emit('equipment-added');
        this.resetForm();
        alert('Equipment added successfully!');
      } catch (error) {
        console.error('Error adding equipment:', error);
        alert('Error adding equipment. Please try again.');
      }
    },
    resetForm() {
      this.equipment = this.getDefaultEquipment();
    }
  },
  async created() {
    try {
      const response = await api.getCategories();
      this.categories = response.data;
    } catch (error) {
      console.error('Error fetching categories:', error);
    }
  }
};
</script>

<style scoped>
.equipment-form {
  max-width: 1200px;
  margin: 20px auto;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

h2 {
  color: #2c3e50;
  margin-bottom: 20px;
  text-align: center;
}

h3 {
  color: #34495e;
  margin-bottom: 15px;
  font-size: 1.1em;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.form-section {
  background: white;
  padding: 20px;
  border-radius: 6px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.form-group {
  margin-bottom: 15px;
}

label {
  display: block;
  margin-bottom: 5px;
  color: #495057;
  font-weight: 500;
}

input, select, textarea {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 14px;
}

input:focus, select:focus, textarea:focus {
  outline: none;
  border-color: #80bdff;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

textarea {
  resize: vertical;
  min-height: 100px;
}

.form-actions {
  grid-column: 1 / -1;
  display: flex;
  justify-content: center;
  gap: 10px;
  margin-top: 20px;
}

.submit-button, .reset-button {
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s;
}

.submit-button {
  background-color: #28a745;
  color: white;
}

.submit-button:hover {
  background-color: #218838;
}

.reset-button {
  background-color: #6c757d;
  color: white;
}

.reset-button:hover {
  background-color: #5a6268;
}

@media (max-width: 768px) {
  .form-grid {
    grid-template-columns: 1fr;
  }
}
</style>