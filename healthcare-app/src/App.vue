<!-- /App.vue -->
<template>
  <div id="app">
    <h1>Healthcare Equipment Management</h1>
    
    <!-- Navigation Bar with router-link -->
    <nav class="nav-bar">
      <router-link 
        v-for="(tab, index) in tabs" 
        :key="index"
        :to="tab.path"
        class="nav-button"
        active-class="active"
      >
        <i :class="tab.icon"></i> {{ tab.name }}
      </router-link>
    </nav>

    <!-- Content Area with Transition -->
    <transition name="fade" mode="out-in">
      <router-view
        :equipments="equipments"
        @add-equipment="addEquipment"
        @update-equipment="updateEquipment"
        @delete-equipment="deleteEquipment"
      ></router-view>
    </transition>
  </div>
</template>

<script>
import api from './services/api';

export default {
  data() {
    return {
      equipments: [],
      tabs: [
        { path: '/', name: 'Equipment', icon: 'fas fa-list' },
        { path: '/maintenance', name: 'Maintenance', icon: 'fas fa-tools' }
      ]
    };
  },
  methods: {
    async fetchEquipment() {
      try {
        const response = await api.getEquipment();
        this.equipments = response.data;
      } catch (error) {
        console.error('Error fetching equipment:', error);
      }
    },
    async addEquipment(equipment) {
      try {
        await api.createEquipment(equipment);
        await this.fetchEquipment(); // Refresh list after adding
      } catch (error) {
        console.error('Error adding equipment:', error);
      }
    },
    async updateEquipment({ index, status }) {
      try {
        const equipment = this.equipments[index];
        await api.updateEquipment(equipment.id, { status });
        await this.fetchEquipment(); // Refresh list after updating
      } catch (error) {
        console.error('Error updating equipment:', error);
      }
    },
    async deleteEquipment(index) {
      try {
        const equipment = this.equipments[index];
        await api.deleteEquipment(equipment.id);
        await this.fetchEquipment(); // Refresh list after deleting
      } catch (error) {
        console.error('Error deleting equipment:', error);
      }
    }
  },
  async created() {
    console.log('App created, fetching data...');
    await this.fetchEquipment();
    console.log('Data fetched successfully');
  }
};
</script>

<style>
#app {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  font-family: Arial, sans-serif;
}

h1 {
  color: #2c3e50;
  text-align: center;
  margin-bottom: 30px;
}

.nav-bar {
  background: #fff;
  padding: 15px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 20px;
  display: flex;
  gap: 20px;
  justify-content: center;
}

.nav-button {
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  background: none;
  cursor: pointer;
  font-size: 1em;
  color: #2c3e50;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: background-color 0.2s;
  text-decoration: none;
}

.nav-button:hover {
  background: #f8f9fa;
}

.nav-button.active {
  background: #e9ecef;
  font-weight: 500;
}

.content-area {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  min-height: 300px;
}

/* Add transition styles */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(10px);
}

.fade-enter-to,
.fade-leave-from {
  opacity: 1;
  transform: translateY(0);
}

@media (max-width: 768px) {
  .nav-bar {
    flex-direction: column;
    gap: 10px;
  }
}
</style>