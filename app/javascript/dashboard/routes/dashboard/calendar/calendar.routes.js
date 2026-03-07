import { frontendURL } from '../../../helper/URLHelper';
import { ROLES } from 'dashboard/constants/permissions.js';

const Calendar = () => import('./Calendar.vue');

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/calendar'),
      name: 'calendar_index',
      component: Calendar,
      meta: {
        permissions: [...ROLES],
      },
    },
  ],
};
