
import { frontendURL } from '../../../helper/URLHelper';

const Calendar = () => import('./Calendar.vue');

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/calendar'),
      name: 'calendar_index',
      roles: ['administrator', 'agent'],
      component: Calendar,
    },
  ],
};
