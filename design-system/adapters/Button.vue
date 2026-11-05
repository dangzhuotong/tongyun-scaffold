<script setup lang="ts">
withDefaults(defineProps<{variant?:'primary'|'secondary'|'danger'; busy?:boolean; disabled?:boolean; type?:'button'|'submit'|'reset'}>(), {variant:'secondary',busy:false,disabled:false,type:'button'});
</script>
<template><button class="ty-button" :data-variant="variant" :type="type" :disabled="disabled || busy" :aria-busy="busy || undefined"><template v-if="busy">处理中…</template><slot v-else /></button></template>
