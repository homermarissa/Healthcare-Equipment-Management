import { createRouter, createWebHistory } from 'vue-router'
import EquipmentList from '../components/EquipmentList.vue'
import MaintenanceTracker from '../components/MaintenanceTracker.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'equipment',
      component: EquipmentList
    },
    {
      path: '/maintenance',
      name: 'maintenance',
      component: MaintenanceTracker
    }
  ]
})

export default router