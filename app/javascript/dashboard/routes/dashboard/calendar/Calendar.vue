<template>
  <div class="flex flex-col h-full bg-white dark:bg-slate-900">
    <div class="flex items-center justify-between px-6 py-4 border-b dark:border-slate-800">
      <h1 class="text-xl font-medium text-slate-800 dark:text-slate-100">
        {{ $t('CALENDAR.TITLE') }}
      </h1>
      <div v-if="isConnected" class="flex items-center gap-2">
        <button
          class="px-3 py-1.5 text-sm font-medium text-slate-600 bg-slate-100 rounded-md hover:bg-slate-200 dark:bg-slate-800 dark:text-slate-300 dark:hover:bg-slate-700"
          @click="fetchEvents"
        >
          {{ $t('CALENDAR.REFRESH') }}
        </button>
      </div>
    </div>

    <div v-if="isLoading" class="flex items-center justify-center flex-1">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-slate-900 dark:border-slate-100"></div>
    </div>

    <div v-else-if="!isConnected" class="flex flex-col items-center justify-center flex-1 p-8 text-center">
      <div class="w-16 h-16 mb-4 text-slate-400 bg-slate-100 rounded-full flex items-center justify-center dark:bg-slate-800">
        <span class="i-lucide-calendar w-8 h-8"></span>
      </div>
      <h2 class="text-lg font-medium text-slate-800 dark:text-slate-100 mb-2">
        {{ $t('CALENDAR.CONNECT_TITLE') }}
      </h2>
      <p class="text-sm text-slate-500 dark:text-slate-400 max-w-md mb-6">
        {{ $t('CALENDAR.CONNECT_DESCRIPTION') }}
      </p>
      <a
        href="/api/v1/accounts/google/authorization"
        class="inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
      >
        <span class="i-lucide-link w-4 h-4 mr-2"></span>
        {{ $t('CALENDAR.CONNECT_BUTTON') }}
      </a>
    </div>

    <div v-else class="flex-1 overflow-y-auto p-6">
      <div v-if="events.length === 0" class="text-center py-10 text-slate-500">
        {{ $t('CALENDAR.NO_EVENTS') }}
      </div>
      <div v-else class="grid gap-4">
        <div
          v-for="event in events"
          :key="event.id"
          class="p-4 bg-white border rounded-lg shadow-sm dark:bg-slate-800 dark:border-slate-700"
        >
          <div class="flex items-start justify-between">
            <div>
              <h3 class="font-medium text-slate-900 dark:text-slate-100">
                {{ event.summary }}
              </h3>
              <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">
                {{ formatEventDate(event) }}
              </p>
            </div>
            <a
              v-if="event.htmlLink"
              :href="event.htmlLink"
              target="_blank"
              class="text-sm text-blue-600 hover:underline dark:text-blue-400"
            >
              {{ $t('CALENDAR.OPEN_LINK') }}
            </a>
          </div>
          <div v-if="event.description" class="mt-2 text-sm text-slate-600 dark:text-slate-300">
            {{ event.description }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { format } from 'date-fns';
import { useAlert } from 'dashboard/composables';

const { t } = useI18n();
const isConnected = ref(false);
const isLoading = ref(true);
const events = ref([]);

const formatEventDate = (event) => {
  const start = event.start.dateTime || event.start.date;
  const end = event.end.dateTime || event.end.date;
  
  // Simple formatting, could be improved with localized date handling
  return `${format(new Date(start), 'PP p')} - ${format(new Date(end), 'p')}`;
};

const fetchEvents = async () => {
  isLoading.value = true;
  try {
    const response = await fetch('/api/v1/accounts/1/google/calendars'); // Note: accountId should be dynamic
    if (response.ok) {
      const data = await response.json();
      events.value = data.items || [];
      isConnected.value = true;
    } else {
      if (response.status === 401 || response.status === 500) {
        isConnected.value = false;
      }
      // throw new Error('Failed to fetch events');
    }
  } catch (error) {
    console.error(error);
    // useAlert(t('CALENDAR.FETCH_ERROR'));
    isConnected.value = false;
  } finally {
    isLoading.value = false;
  }
};

onMounted(() => {
  fetchEvents();
});
</script>
