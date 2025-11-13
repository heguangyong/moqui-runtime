/* Vue 3 Composition API Enhanced Form Component */
// Enhanced version of m-form with Vue 3 reactive performance optimizations

console.log("🚀 Loading Vue 3 Enhanced Form Component");

// Vue 3 Composition API enhanced form utilities
const Vue3FormEnhancements = {

    // Enhanced form state management using Vue 3 reactive
    useFormState: function(props) {
        if (typeof Vue === 'undefined' || !Vue.reactive) {
            console.warn('Vue 3 Composition API not available for form enhancement');
            return null;
        }

        // Use Vue 3 reactive for better performance
        const formState = Vue.reactive({
            fields: Object.assign({}, props.initialFields || {}),
            loading: false,
            validation: {
                errors: {},
                isValid: true
            },
            submitCount: 0,
            lastSubmitTime: null,
            performanceMetrics: {
                renderTime: 0,
                submitTime: 0,
                validationTime: 0
            }
        });

        // Performance tracking
        const trackPerformance = function(operation, startTime) {
            const endTime = performance.now();
            formState.performanceMetrics[operation] = endTime - startTime;

            if (window.moqui?.debugLog) {
                window.moqui.debugLog.log('vue',
                    `Form ${operation} completed`,
                    {
                        duration: `${(endTime - startTime).toFixed(2)}ms`,
                        operation: operation,
                        formName: props.name
                    }
                );
            }
        };

        return {
            formState,
            trackPerformance
        };
    },

    // Enhanced form validation using Vue 3 computed
    useFormValidation: function(formState) {
        if (typeof Vue === 'undefined' || !Vue.computed) {
            return null;
        }

        // Vue 3 computed properties for validation
        const hasErrors = Vue.computed(() => {
            return Object.keys(formState.validation.errors).length > 0;
        });

        const isSubmitDisabled = Vue.computed(() => {
            return formState.loading || hasErrors.value;
        });

        const fieldsChanged = Vue.computed(() => {
            // Track field changes for better UX
            return Object.keys(formState.fields).some(key =>
                formState.fields[key] !== (formState.initialFields?.[key] || '')
            );
        });

        return {
            hasErrors,
            isSubmitDisabled,
            fieldsChanged
        };
    },

    // Enhanced async form submission with better error handling
    useFormSubmission: function(formState, props, emit) {
        if (typeof Vue === 'undefined' || !Vue.ref) {
            return null;
        }

        const submitForm = async function(formData) {
            const startTime = performance.now();
            formState.loading = true;
            formState.validation.errors = {};

            try {
                // Modern fetch API with proper error handling
                const response = await fetch(props.action || window.location.href, {
                    method: props.method || 'POST',
                    body: formData,
                    credentials: 'include',
                    headers: {
                        ...moqui.getAuthHeaders(),
                        'X-Requested-With': 'XMLHttpRequest'
                    }
                });

                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }

                const result = await response.text();
                formState.submitCount++;
                formState.lastSubmitTime = new Date().toISOString();

                // Track performance
                formState.performanceMetrics.submitTime = performance.now() - startTime;

                // Emit success event with enhanced data
                emit('submit-success', {
                    result: result,
                    submitCount: formState.submitCount,
                    performanceMetrics: formState.performanceMetrics
                });

                return result;

            } catch (error) {
                console.error('Enhanced form submission error:', error);

                formState.validation.errors.submit = error.message;
                formState.validation.isValid = false;

                // Emit error event with context
                emit('submit-error', {
                    error: error,
                    submitCount: formState.submitCount,
                    formName: props.name
                });

                throw error;
            } finally {
                formState.loading = false;
            }
        };

        return {
            submitForm
        };
    }
};

// Vue 3 enhanced lifecycle hooks
const Vue3FormLifecycle = {

    // Enhanced mounted hook with performance tracking
    onFormMounted: function(formName, formState) {
        if (typeof Vue === 'undefined' || !Vue.onMounted) {
            return;
        }

        Vue.onMounted(() => {
            const startTime = performance.now();

            console.log(`🔧 Vue 3 Enhanced Form mounted: ${formName}`);

            // Performance tracking
            Vue.nextTick(() => {
                const mountTime = performance.now() - startTime;
                formState.performanceMetrics.renderTime = mountTime;

                if (window.moqui?.debugLog) {
                    window.moqui.debugLog.log('vue',
                        `Enhanced form ${formName} mounted`,
                        {
                            mountTime: `${mountTime.toFixed(2)}ms`,
                            hasCompositionApi: true,
                            vue3Features: ['reactive', 'computed', 'onMounted']
                        }
                    );
                }
            });
        });
    },

    // Enhanced unmount hook with cleanup
    onFormUnmount: function(formName) {
        if (typeof Vue === 'undefined' || !Vue.onUnmounted) {
            return;
        }

        Vue.onUnmounted(() => {
            console.log(`🧹 Vue 3 Enhanced Form cleanup: ${formName}`);

            // Cleanup any watchers or subscriptions
            if (window.moqui?.debugLog) {
                window.moqui.debugLog.log('vue',
                    `Enhanced form ${formName} cleanup completed`,
                    { vue3Enhancement: true }
                );
            }
        });
    }
};

// Integration with the existing m-form component
const enhanceFormComponent = function(originalComponent) {
    if (!originalComponent || typeof Vue === 'undefined' || !Vue.reactive) {
        return originalComponent;
    }

    // Create enhanced version that extends original
    const enhanced = Object.assign({}, originalComponent);

    // Add Vue 3 Composition API setup function if not present
    if (!enhanced.setup && typeof Vue.reactive === 'function') {
        enhanced.setup = function(props, context) {
            console.log(`🚀 Setting up Vue 3 enhanced form: ${props.name}`);

            // Use enhanced form state
            const { formState, trackPerformance } = Vue3FormEnhancements.useFormState(props);
            const validation = Vue3FormEnhancements.useFormValidation(formState);
            const submission = Vue3FormEnhancements.useFormSubmission(formState, props, context.emit);

            // Enhanced lifecycle
            Vue3FormLifecycle.onFormMounted(props.name, formState);
            Vue3FormLifecycle.onFormUnmount(props.name);

            // Return reactive data for template
            return {
                formState,
                ...validation,
                ...submission,
                trackPerformance
            };
        };
    }

    // Add performance tracking to existing mounted hook
    const originalMounted = enhanced.mounted;
    enhanced.mounted = function() {
        const startTime = performance.now();

        if (originalMounted) {
            originalMounted.call(this);
        }

        // Track component mount performance
        const mountTime = performance.now() - startTime;
        console.log(`📊 Enhanced m-form mounted in ${mountTime.toFixed(2)}ms`);

        if (window.moqui?.debugLog) {
            window.moqui.debugLog.log('vue',
                'Enhanced form component mounted',
                {
                    componentName: 'm-form',
                    mountTime: `${mountTime.toFixed(2)}ms`,
                    enhancement: 'Vue3CompositionAPI',
                    features: ['reactive', 'computed', 'performance-tracking']
                }
            );
        }
    };

    return enhanced;
};

// Export for use by vue3Optimizer
if (typeof window !== 'undefined') {
    window.Vue3FormEnhancements = Vue3FormEnhancements;
    window.enhanceFormComponent = enhanceFormComponent;

    console.log('✅ Vue 3 Enhanced Form Component utilities loaded');
}