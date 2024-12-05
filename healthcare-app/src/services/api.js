import axios from 'axios';

const apiClient = axios.create({
  baseURL: 'http://localhost:3000/api',
  headers: {
    'Content-Type': 'application/json'
  }
});

// Equipment endpoints
export const equipment = {
  getAll: () => apiClient.get('/equipment'),
  create: (data) => apiClient.post('/equipment', data),
  update: (id, data) => apiClient.put(`/equipment/${id}`, data),
  delete: (id) => apiClient.delete(`/equipment/${id}`),
  updateStatus: (id, status) => apiClient.put(`/equipment/${id}/status`, { status })
};

// Maintenance endpoints
export const maintenance = {
  getSchedule: () => apiClient.get('/maintenance-schedule'),
  delete: (id) => apiClient.delete(`/maintenance-schedule/${id}`),
  getHistory: (equipmentId) => apiClient.get(`/maintenance-history/${equipmentId}`),
  scheduleAll: () => apiClient.post('/maintenance-schedule/schedule-all'),
  schedule: (data) => apiClient.post('/maintenance-schedule', data),
  updateStatus: (id, status) => apiClient.put(`/maintenance-schedule/${id}/status`, { status }),
  complete: (id, data) => apiClient.post(`/maintenance-complete/${id}`, data)
};

// Categories endpoints
export const categories = {
  getAll: () => apiClient.get('/categories')
};

export default {
  getEquipment: equipment.getAll,
  createEquipment: equipment.create,
  updateEquipment: equipment.update,
  deleteEquipment: equipment.delete,
  updateEquipmentStatus: equipment.updateStatus, 
  getMaintenanceSchedule: maintenance.getSchedule,
  deleteMaintenanceSchedule: maintenance.delete,
  getMaintenanceHistory: maintenance.getHistory,
  getCategories: categories.getAll,
  scheduleAllMaintenance: maintenance.scheduleAll,
  scheduleMaintenance: maintenance.schedule,
  updateMaintenanceScheduleStatus: maintenance.updateStatus,
  completeMaintenance: maintenance.complete,
  addEquipment: equipment.create
};