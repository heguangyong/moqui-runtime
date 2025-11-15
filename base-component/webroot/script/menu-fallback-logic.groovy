#!/usr/bin/env groovy
/**
 * 菜单故障边界和Fallback机制 - Phase 1 实现
 *
 * 功能：提供菜单加载失败时的降级策略和错误恢复机制
 * 用途：确保即使在页面XML解析错误的情况下，基础导航功能仍可用
 */

// 导入所需类
import org.moqui.context.ExecutionContext
import org.moqui.entity.EntityValue
import org.slf4j.Logger
import org.slf4j.LoggerFactory

class MenuFallbackLogic {

    private static final Logger logger = LoggerFactory.getLogger(MenuFallbackLogic.class)

    // 错误边界配置
    static final Map<String, Object> FALLBACK_CONFIG = [
        maxRetries: 3,
        retryDelayMs: 1000,
        fallbackTimeout: 5000,
        enableLogging: true,
        enableHealthCheck: true
    ]

    // 基础导航保证机制
    static final List<Map> EMERGENCY_MENU_ITEMS = [
        [
            id: "emergency-home",
            title: "返回首页",
            url: "/qapps/AppList",
            icon: "fa fa-home",
            priority: 1,
            description: "安全返回主页"
        ],
        [
            id: "emergency-help",
            title: "系统帮助",
            url: "/qapps/help",
            icon: "fa fa-question-circle",
            priority: 2,
            description: "获取系统帮助"
        ],
        [
            id: "emergency-logout",
            title: "安全退出",
            url: "/Login/logout",
            icon: "fa fa-sign-out-alt",
            priority: 3,
            description: "安全退出系统"
        ]
    ]

    /**
     * 主要Fallback方法：处理菜单加载失败
     *
     * @param ec ExecutionContext
     * @param originalError 原始错误信息
     * @param fallbackType 回退类型 (SERVICE_ERROR, XML_ERROR, TIMEOUT_ERROR)
     * @return 可用的菜单数据
     */
    static Map<String, Object> handleMenuLoadFailure(ExecutionContext ec, String originalError, String fallbackType = "UNKNOWN") {

        long startTime = System.currentTimeMillis()

        try {
            // 日志记录错误
            if (FALLBACK_CONFIG.enableLogging) {
                logger.warn("Menu fallback triggered - Type: ${fallbackType}, Error: ${originalError}")
            }

            // 第一级回退：尝试从缓存获取最后正常的菜单
            Map cachedMenu = tryGetCachedMenu(ec)
            if (cachedMenu?.success) {
                logger.info("Fallback Level 1: Using cached menu successfully")
                return enrichFallbackResponse(cachedMenu, "CACHE_RECOVERY", startTime)
            }

            // 第二级回退：尝试使用简化的菜单服务
            Map simplifiedMenu = trySimplifiedMenuService(ec)
            if (simplifiedMenu?.success) {
                logger.info("Fallback Level 2: Using simplified menu service successfully")
                return enrichFallbackResponse(simplifiedMenu, "SIMPLIFIED_SERVICE", startTime)
            }

            // 第三级回退：使用紧急菜单项
            Map emergencyMenu = getEmergencyMenu(ec)
            logger.warn("Fallback Level 3: Using emergency menu items")
            return enrichFallbackResponse(emergencyMenu, "EMERGENCY_MENU", startTime)

        } catch (Exception fallbackError) {
            logger.error("Critical: Fallback mechanism failed - ${fallbackError.message}", fallbackError)
            return getCriticalFailureResponse(originalError, fallbackError, startTime)
        }
    }

    /**
     * 尝试从缓存获取最后正常的菜单
     */
    static Map tryGetCachedMenu(ExecutionContext ec) {
        try {
            def cache = ec.cache.get("MenuRegistry", "LastKnownGood")
            if (cache != null) {
                return [
                    success: true,
                    menuDataList: cache,
                    source: "cache"
                ]
            }
        } catch (Exception e) {
            logger.debug("Cache fallback failed: ${e.message}")
        }
        return [success: false]
    }

    /**
     * 尝试使用简化的菜单服务（绕过复杂的screen解析）
     */
    static Map trySimplifiedMenuService(ExecutionContext ec) {
        try {
            // 使用简化的组件发现机制
            def simplifiedItems = []

            // 硬编码的核心应用项（确保基础功能可用）
            def coreApps = [
                [title: "应用列表", url: "/qapps/AppList", image: "fa fa-th", imageType: "icon"],
                [title: "智能推荐", url: "/qapps/marketplace", image: "fa fa-chart-line", imageType: "icon"],
                [title: "工具", url: "/qapps/tools", image: "fa fa-tools", imageType: "icon"],
                [title: "对象存储", url: "/qapps/minio", image: "fa fa-database", imageType: "icon"]
            ]

            // 验证每个应用是否可访问（简单检查）
            coreApps.each { app ->
                if (isAppAccessible(ec, app.url)) {
                    simplifiedItems.add(app)
                }
            }

            return [
                success: true,
                menuDataList: simplifiedItems,
                source: "simplified"
            ]

        } catch (Exception e) {
            logger.debug("Simplified menu service failed: ${e.message}")
        }
        return [success: false]
    }

    /**
     * 获取紧急菜单（最后防线）
     */
    static Map getEmergencyMenu(ExecutionContext ec) {
        def emergencyItems = []

        EMERGENCY_MENU_ITEMS.each { item ->
            emergencyItems.add([
                title: item.title,
                url: item.url,
                image: item.icon,
                imageType: "icon",
                description: item.description
            ])
        }

        return [
            success: true,
            menuDataList: emergencyItems,
            source: "emergency"
        ]
    }

    /**
     * 简单的应用可访问性检查
     */
    static boolean isAppAccessible(ExecutionContext ec, String url) {
        try {
            // 简单检查：验证URL路径是否存在对应的screen配置
            def pathList = url.split("/").findAll { it }
            if (pathList.size() >= 2) {
                // 基础可达性验证（不执行完整渲染）
                return true // 简化实现，实际可以添加更复杂的检查
            }
        } catch (Exception e) {
            logger.debug("Accessibility check failed for ${url}: ${e.message}")
        }
        return false
    }

    /**
     * 丰富Fallback响应数据
     */
    static Map enrichFallbackResponse(Map response, String recoveryMethod, long startTime) {
        long processingTime = System.currentTimeMillis() - startTime

        return response + [
            fallbackInfo: [
                recoveryMethod: recoveryMethod,
                processingTimeMs: processingTime,
                timestamp: new Date(),
                healthStatus: "DEGRADED"
            ]
        ]
    }

    /**
     * 获取关键故障响应（最后手段）
     */
    static Map getCriticalFailureResponse(String originalError, Exception fallbackError, long startTime) {
        long processingTime = System.currentTimeMillis() - startTime

        return [
            success: false,
            menuDataList: [[
                title: "系统维护中",
                url: "/Login",
                image: "fa fa-exclamation-triangle",
                imageType: "icon",
                description: "系统正在维护，请稍后重试"
            ]],
            fallbackInfo: [
                recoveryMethod: "CRITICAL_FAILURE",
                processingTimeMs: processingTime,
                timestamp: new Date(),
                healthStatus: "CRITICAL",
                originalError: originalError,
                fallbackError: fallbackError.message
            ]
        ]
    }

    /**
     * 健康检查和监控方法
     */
    static Map performHealthCheck(ExecutionContext ec) {
        def healthInfo = [
            status: "HEALTHY",
            checks: [],
            recommendations: [],
            timestamp: new Date()
        ]

        // 检查菜单注册表服务可用性
        try {
            Map serviceResult = ec.service.sync().name("load", "MenuRegistry").call()
            if (serviceResult.success) {
                healthInfo.checks.add([name: "MenuRegistryService", status: "PASS"])
            } else {
                healthInfo.checks.add([name: "MenuRegistryService", status: "FAIL", message: serviceResult.message])
                healthInfo.status = "DEGRADED"
            }
        } catch (Exception e) {
            healthInfo.checks.add([name: "MenuRegistryService", status: "ERROR", message: e.message])
            healthInfo.status = "DEGRADED"
        }

        // 检查缓存系统
        try {
            def cache = ec.cache.getCache("MenuRegistry")
            if (cache) {
                healthInfo.checks.add([name: "CacheSystem", status: "PASS", size: cache.size()])
            }
        } catch (Exception e) {
            healthInfo.checks.add([name: "CacheSystem", status: "ERROR", message: e.message])
        }

        // 检查紧急菜单项完整性
        def emergencyCheck = EMERGENCY_MENU_ITEMS.every { it.title && it.url && it.icon }
        healthInfo.checks.add([
            name: "EmergencyMenuItems",
            status: emergencyCheck ? "PASS" : "FAIL",
            count: EMERGENCY_MENU_ITEMS.size()
        ])

        // 生成建议
        if (healthInfo.status == "DEGRADED") {
            healthInfo.recommendations.add("考虑重启菜单服务或清理缓存")
            healthInfo.recommendations.add("检查菜单注册表配置文件完整性")
        }

        return healthInfo
    }
}

/**
 * 使用示例和测试方法
 */
class MenuFallbackTest {

    static void testFallbackMechanism(ExecutionContext ec) {
        println "=== 菜单故障边界测试 ==="

        // 模拟服务错误
        Map result1 = MenuFallbackLogic.handleMenuLoadFailure(ec, "Service timeout", "TIMEOUT_ERROR")
        println "测试1 - 服务超时: ${result1.fallbackInfo.recoveryMethod}"

        // 模拟XML解析错误
        Map result2 = MenuFallbackLogic.handleMenuLoadFailure(ec, "XML parse error", "XML_ERROR")
        println "测试2 - XML错误: ${result2.fallbackInfo.recoveryMethod}"

        // 健康检查
        Map health = MenuFallbackLogic.performHealthCheck(ec)
        println "健康检查: ${health.status} (${health.checks.size()} 项检查)"

        println "=== 测试完成 ==="
    }
}

// 暴露主要方法供Moqui调用
def handleMenuFailure = { ec, error, type ->
    return MenuFallbackLogic.handleMenuLoadFailure(ec, error, type)
}

def checkMenuHealth = { ec ->
    return MenuFallbackLogic.performHealthCheck(ec)
}

def testFallback = { ec ->
    MenuFallbackTest.testFallbackMechanism(ec)
}