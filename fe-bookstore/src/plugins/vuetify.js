// src/plugins/vuetify.js
import 'vuetify/styles'; // Import Vuetify styles
import { createVuetify } from 'vuetify';

// Import Vuetify components và directives
import * as components from 'vuetify/components';
import * as directives from 'vuetify/directives';

export default createVuetify({
  components,
  directives,
});
