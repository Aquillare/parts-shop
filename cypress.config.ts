import { defineConfig } from 'cypress';
import dotenv from 'dotenv';

// Carga las variables de .env.local en process.env
dotenv.config({ path: '.env.local' });

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    specPattern: 'cypress/e2e/**/*.cy.ts',
    screenshotOnRunFailure: false,
    supportFile: false,
    viewportWidth: 1280,
    viewportHeight: 720,
    setupNodeEvents(on, config) {
      
      on('task', {
        log(message) {
          console.log('\n 🔹 [Cypress Log]:', message, '\n');
          return null; // Los tasks siempre deben retornar null si no devuelven un valor
        }
      });
      
      return config;
    },
  },
  env: {
    SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
    ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
    SERVICE_ROLE_KEY: process.env.NEXT_PUBLIC_SUPABASE_SERVICE_ROLE_KEY,
  },
  expose: {
    environment: 'staging', // Public configuration value
  },
});

