// /main.js
import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

const app = createApp(App)
app.use(router)
app.mount('#app')

// Handle any global errors
app.config.errorHandler = (err) => {
  console.error('Vue application error:', err);
};
