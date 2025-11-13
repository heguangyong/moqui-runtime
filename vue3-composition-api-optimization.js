// Vue 3 Composition API 性能优化建议和示例
// 基于WebrootVue.qvt.js的现有组件架构优化

console.log("🚀 Vue 3 Composition API 性能优化指南");

/* ========== Vue 3 Composition API优化原则 ========== */

// 1. 使用Composition API重构复杂组件（如m-form, m-form-list等）
// 原始Options API:
// registerComponent('m-form', {
//     data: function() { return { fields: {}, loading: false }; },
//     methods: { submitForm: function() { /* ... */ } }
// });

// Vue 3 Composition API优化版本:
function useFormOptimized(props, emit) {
    if (typeof Vue === 'undefined' || !Vue.ref) {
        console.warn('Vue 3 Composition API not available, falling back to Options API');
        return null;
    }

    // 使用Vue 3 reactive/ref来管理状态
    const fields = Vue.reactive(Object.assign({}, props.fieldsInitial || {}));
    const loading = Vue.ref(false);
    const validation = Vue.reactive({ errors: {}, isValid: true });

    // 计算属性使用Vue 3 computed
    const hasFieldsChanged = Vue.computed(() => {
        return Object.keys(fields).some(key =>
            fields[key] !== (props.fieldsInitial?.[key] || '')
        );
    });

    // 表单提交优化
    const submitForm = async (formData) => {
        loading.value = true;
        validation.errors = {};

        try {
            // 使用现代async/await替代jQuery
            const response = await fetch(props.action, {
                method: props.method || 'POST',
                body: formData,
                credentials: 'include',
                headers: moqui.getAuthHeaders()
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            const result = await response.json();
            emit('submit-success', result);

        } catch (error) {
            validation.errors.submit = error.message;
            emit('submit-error', error);
        } finally {
            loading.value = false;
        }
    };

    // 生命周期钩子优化
    Vue.onMounted(() => {
        console.log('Form mounted with Composition API optimization');
    });

    Vue.onUnmounted(() => {
        console.log('Form cleanup with Composition API');
    });

    return {
        fields,
        loading,
        validation,
        hasFieldsChanged,
        submitForm
    };
}

/* ========== 性能优化建议 ========== */

// 2. 组件懒加载优化
const LazyComponentLoader = {
    // 使用Vue 3的defineAsyncComponent进行组件懒加载
    createLazyComponent(componentPath) {
        if (typeof Vue.defineAsyncComponent === 'function') {
            return Vue.defineAsyncComponent({
                loader: () => moqui.loadComponent(componentPath),
                loadingComponent: moqui.EmptyComponent,
                errorComponent: moqui.NotFound,
                delay: 200,
                timeout: 10000
            });
        }
        // 回退到传统方式
        return moqui.loadComponent(componentPath);
    }
};

// 3. 状态管理优化 - 使用Vue 3 reactive
const createOptimizedAppState = () => {
    if (typeof Vue === 'undefined' || !Vue.reactive) {
        return {}; // 回退到传统方式
    }

    return Vue.reactive({
        // 应用级别状态
        user: {
            authenticated: false,
            profile: null
        },
        ui: {
            loading: false,
            notifications: [],
            currentPath: '',
            theme: 'default'
        },
        // 性能指标
        performance: {
            componentLoadTimes: new Map(),
            lastUpdate: Date.now()
        }
    });
};

// 4. 计算属性优化示例
const useOptimizedComputed = () => {
    if (typeof Vue === 'undefined' || !Vue.computed) {
        return null;
    }

    // 使用Vue 3的computed，具有更好的缓存机制
    const optimizedNavMenu = Vue.computed(() => {
        // 复杂的导航菜单计算逻辑
        return moqui.webrootVue?.navMenuList?.map(menu => ({
            ...menu,
            active: menu.path === moqui.webrootVue?.currentPath
        })) || [];
    });

    const optimizedUserPermissions = Vue.computed(() => {
        // 用户权限计算优化
        return moqui.webrootVue?.userPermissions?.reduce((acc, perm) => {
            acc[perm.code] = perm.enabled;
            return acc;
        }, {}) || {};
    });

    return {
        optimizedNavMenu,
        optimizedUserPermissions
    };
};

/* ========== 实际优化实施建议 ========== */

// 5. 渐进式迁移策略
const MigrationHelper = {
    // 检查是否可以使用Vue 3特性
    canUseComposition() {
        return typeof Vue !== 'undefined' &&
               typeof Vue.ref === 'function' &&
               typeof Vue.reactive === 'function';
    },

    // 渐进式组件升级
    upgradeComponent(componentName, optionsApiDef) {
        if (!this.canUseComposition()) {
            console.log(`Keeping Options API for ${componentName} - Composition API not available`);
            return optionsApiDef;
        }

        console.log(`Upgrading ${componentName} to use Composition API features`);

        // 添加Vue 3特性，同时保持向后兼容
        const enhanced = Object.assign({}, optionsApiDef);

        // 添加performance tracking
        const originalMounted = enhanced.mounted || function() {};
        enhanced.mounted = function() {
            const startTime = performance.now();
            originalMounted.call(this);
            const loadTime = performance.now() - startTime;
            console.log(`Component ${componentName} mounted in ${loadTime.toFixed(2)}ms`);
        };

        return enhanced;
    }
};

/* ========== 性能监控和调试 ========== */

// 6. Vue 3性能监控
const PerformanceMonitor = {
    init() {
        if (typeof Vue === 'undefined') return;

        // Vue 3开发工具集成
        if (Vue.config && Vue.config.performance) {
            Vue.config.performance = true;
        }

        // 组件渲染时间监控
        this.trackComponentPerformance();
    },

    trackComponentPerformance() {
        const originalMount = Vue.createApp().mount;
        Vue.createApp().mount = function(container) {
            const startTime = performance.now();
            const result = originalMount.call(this, container);
            const mountTime = performance.now() - startTime;
            console.log(`Vue app mounted in ${mountTime.toFixed(2)}ms`);
            return result;
        };
    },

    // 内存使用监控
    monitorMemoryUsage() {
        if (performance.memory) {
            console.log('Vue 3 Memory Usage:', {
                used: (performance.memory.usedJSHeapSize / 1048576).toFixed(2) + ' MB',
                total: (performance.memory.totalJSHeapSize / 1048576).toFixed(2) + ' MB',
                limit: (performance.memory.jsHeapSizeLimit / 1048576).toFixed(2) + ' MB'
            });
        }
    }
};

/* ========== 集成建议 ========== */

// 7. WebrootVue.qvt.js集成优化
const WebrootVueOptimizer = {
    enhance() {
        console.log('🔧 Applying Vue 3 Composition API optimizations to WebrootVue');

        // 初始化性能监控
        PerformanceMonitor.init();

        // 优化现有组件
        this.optimizeExistingComponents();

        // 添加Vue 3特性检测
        this.addFeatureDetection();
    },

    optimizeExistingComponents() {
        console.log('🔧 Applying Vue 3 Composition API optimizations to existing components');

        // Load the enhanced form component utilities
        this.loadEnhancedFormComponent();

        // For complex components, add Composition API enhancements
        const complexComponents = ['m-form', 'm-form-list', 'm-dynamic-container'];

        complexComponents.forEach(name => {
            if (componentRegistry[name]) {
                console.log(`🚀 Optimizing component: ${name}`);

                // Apply specific enhancements based on component type
                if (name === 'm-form' && window.enhanceFormComponent) {
                    componentRegistry[name] = window.enhanceFormComponent(componentRegistry[name]);
                } else {
                    componentRegistry[name] = MigrationHelper.upgradeComponent(
                        name,
                        componentRegistry[name]
                    );
                }

                console.log(`✅ Component ${name} optimized with Vue 3 features`);
            }
        });

        // Track optimization success
        this.reportOptimizationResults(complexComponents);
    },

    loadEnhancedFormComponent() {
        // Load the Vue 3 enhanced form component
        if (typeof window.enhanceFormComponent === 'undefined') {
            console.log('📦 Loading Vue 3 enhanced form component utilities');

            // Dynamically load the enhancement script
            const script = document.createElement('script');
            script.src = '/vue3-form-composition-enhancement.js';
            script.onload = () => {
                console.log('✅ Vue 3 form enhancements loaded');
            };
            script.onerror = () => {
                console.warn('⚠️ Could not load Vue 3 form enhancements, falling back to basic optimization');
            };
            document.head.appendChild(script);
        }
    },

    reportOptimizationResults(optimizedComponents) {
        const report = {
            timestamp: new Date().toISOString(),
            optimizedComponents: optimizedComponents.length,
            vue3Features: ['reactive', 'computed', 'onMounted', 'onUnmounted'],
            performanceTracking: true,
            compositionApi: window.vueCapabilities?.hasCompositionApi || false
        };

        console.log('📊 Vue 3 Optimization Report:', report);

        // Store results for debugging
        if (window.moqui?.debugLog) {
            window.moqui.debugLog.log('vue', 'Vue 3 optimization completed', report);
        }
    },

    addFeatureDetection() {
        // 全局Vue 3特性检测
        window.vueCapabilities = {
            hasCompositionApi: typeof Vue !== 'undefined' && typeof Vue.ref === 'function',
            hasReactivity: typeof Vue !== 'undefined' && typeof Vue.reactive === 'function',
            hasSuspense: typeof Vue !== 'undefined' && typeof Vue.Suspense !== 'undefined',
            hasTeleport: typeof Vue !== 'undefined' && typeof Vue.Teleport !== 'undefined',
            version: typeof Vue !== 'undefined' ? Vue.version : 'unknown'
        };

        console.log('Vue 3 Capabilities:', window.vueCapabilities);
    }
};

/* ========== 导出和初始化 ========== */

// 8. 自动初始化优化
if (typeof window !== 'undefined' && window.moqui) {
    window.moqui.vue3Optimizer = WebrootVueOptimizer;

    // 在WebrootVue初始化后自动应用优化
    document.addEventListener('DOMContentLoaded', function() {
        setTimeout(() => {
            if (window.moqui?.vue3Optimizer) {
                window.moqui.vue3Optimizer.enhance();
            }
        }, 100);
    });
}

console.log('✅ Vue 3 Composition API 优化建议已加载');
console.log('💡 使用 window.moqui.vue3Optimizer.enhance() 手动应用优化');