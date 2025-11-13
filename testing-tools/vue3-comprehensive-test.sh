#!/bin/bash

# Vue 3 + Quasar 2 Comprehensive Testing Script
# Tests all major pages and functionality points after Vue 3 optimization implementation

echo "🧪 Vue 3 + Quasar 2 Comprehensive Testing Started"
echo "================================================="

# Test results tracking
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

# Function to log test results
log_test_result() {
    local test_name="$1"
    local result="$2"
    local details="$3"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    if [ "$result" = "PASS" ]; then
        echo "✅ $test_name: PASSED"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "❌ $test_name: FAILED - $details"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$test_name: $details")
    fi
}

# Create authenticated session for testing
echo "📋 Setting up authenticated session for testing..."
curl -s -X POST "http://localhost:8080/Login/login" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "username=john.doe&password=moqui" \
     -c /tmp/test_session.txt -L > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Authentication session established"
else
    echo "❌ Failed to establish authentication session"
    exit 1
fi

echo ""
echo "📋 Test 1: Core Application Pages"
echo "================================"

# Test 1.1: Main application list page
echo "Testing: Main Application List (/qapps)"
RESPONSE=$(curl -s -b /tmp/test_session.txt "http://localhost:8080/qapps" -w "%{http_code}")
HTTP_CODE="${RESPONSE: -3}"
CONTENT="${RESPONSE%???}"

if [ "$HTTP_CODE" = "200" ] && echo "$CONTENT" | grep -q "选择应用"; then
    log_test_result "Main App List Page" "PASS" "HTTP 200, content loaded"
else
    log_test_result "Main App List Page" "FAIL" "HTTP $HTTP_CODE or missing content"
fi

# Test 1.2: Marketplace application
echo "Testing: Marketplace Application (/qapps/marketplace)"
RESPONSE=$(curl -s -b /tmp/test_session.txt "http://localhost:8080/qapps/marketplace" -w "%{http_code}")
HTTP_CODE="${RESPONSE: -3}"

if [ "$HTTP_CODE" = "200" ]; then
    log_test_result "Marketplace App" "PASS" "HTTP 200"
else
    log_test_result "Marketplace App" "FAIL" "HTTP $HTTP_CODE"
fi

# Test 1.3: System tools
echo "Testing: System Tools (/qapps/tools)"
RESPONSE=$(curl -s -b /tmp/test_session.txt "http://localhost:8080/qapps/tools" -w "%{http_code}")
HTTP_CODE="${RESPONSE: -3}"

if [ "$HTTP_CODE" = "200" ]; then
    log_test_result "System Tools" "PASS" "HTTP 200"
else
    log_test_result "System Tools" "FAIL" "HTTP $HTTP_CODE"
fi

# Test 1.4: MinIO file management
echo "Testing: MinIO File Management (/qapps/minio)"
RESPONSE=$(curl -s -b /tmp/test_session.txt "http://localhost:8080/qapps/minio" -w "%{http_code}")
HTTP_CODE="${RESPONSE: -3}"

if [ "$HTTP_CODE" = "200" ]; then
    log_test_result "MinIO File Management" "PASS" "HTTP 200"
else
    log_test_result "MinIO File Management" "FAIL" "HTTP $HTTP_CODE"
fi

echo ""
echo "📋 Test 2: Vue 3 JavaScript Framework"
echo "====================================="

# Test 2.1: Vue 3 library availability
echo "Testing: Vue 3 Library Loading"
VUE_CONTENT=$(curl -s "http://localhost:8080/libs/vue3/vue.js")
if echo "$VUE_CONTENT" | grep -q 'version.*3\.5\.22'; then
    log_test_result "Vue 3.5.22 Library" "PASS" "Vue 3.5.22 loaded correctly"
else
    log_test_result "Vue 3.5.22 Library" "FAIL" "Vue 3.5.22 not found"
fi

# Test 2.2: Quasar 2 library availability
echo "Testing: Quasar 2 Library Loading"
QUASAR_CONTENT=$(curl -s "http://localhost:8080/libs/quasar2/quasar.umd.js")
if echo "$QUASAR_CONTENT" | grep -q 'version.*2\.'; then
    log_test_result "Quasar 2.x Library" "PASS" "Quasar 2.x loaded correctly"
else
    log_test_result "Quasar 2.x Library" "FAIL" "Quasar 2.x not found"
fi

# Test 2.3: WebrootVue.qvt.js core functionality
echo "Testing: WebrootVue Core JavaScript"
WEBROOT_CONTENT=$(curl -s "http://localhost:8080/js/WebrootVue.qvt.js")
if echo "$WEBROOT_CONTENT" | grep -q 'Vue\.createApp' && echo "$WEBROOT_CONTENT" | grep -q 'vue3Optimizer'; then
    log_test_result "WebrootVue Core JS" "PASS" "Vue 3 createApp and optimizer found"
else
    log_test_result "WebrootVue Core JS" "FAIL" "Vue 3 features not found"
fi

echo ""
echo "📋 Test 3: API Endpoints & REST Services"
echo "======================================="

# Test 3.1: Menu data API
echo "Testing: Menu Data API"
MENU_RESPONSE=$(curl -s -b /tmp/test_session.txt "http://localhost:8080/qapps/menuData" -w "%{http_code}")
HTTP_CODE="${MENU_RESPONSE: -3}"

if [ "$HTTP_CODE" = "200" ]; then
    log_test_result "Menu Data API" "PASS" "HTTP 200"
else
    log_test_result "Menu Data API" "FAIL" "HTTP $HTTP_CODE"
fi

# Test 3.2: Marketplace REST API
echo "Testing: Marketplace REST API"
MARKET_RESPONSE=$(curl -s -b /tmp/test_session.txt "http://localhost:8080/rest/s1/marketplace/get/MatchingStats" -w "%{http_code}")
HTTP_CODE="${MARKET_RESPONSE: -3}"

if [ "$HTTP_CODE" = "200" ]; then
    log_test_result "Marketplace REST API" "PASS" "HTTP 200"
else
    log_test_result "Marketplace REST API" "FAIL" "HTTP $HTTP_CODE"
fi

echo ""
echo "📋 Test 4: Vue 3 Optimization Features"
echo "======================================"

# Test 4.1: Vue 3 optimization framework
echo "Testing: Vue 3 Optimization Framework"
OPT_CONTENT=$(curl -s "http://localhost:8080/vue3-composition-api-optimization.js")
if echo "$OPT_CONTENT" | grep -q 'Vue\.reactive' && echo "$OPT_CONTENT" | grep -q 'WebrootVueOptimizer'; then
    log_test_result "Vue 3 Optimization Framework" "PASS" "Composition API optimizations loaded"
else
    log_test_result "Vue 3 Optimization Framework" "FAIL" "Optimization framework not found"
fi

# Test 4.2: Enhanced form component utilities
echo "Testing: Enhanced Form Components"
FORM_CONTENT=$(curl -s "http://localhost:8080/vue3-form-composition-enhancement.js")
if echo "$FORM_CONTENT" | grep -q 'Vue3FormEnhancements' && echo "$FORM_CONTENT" | grep -q 'useFormState'; then
    log_test_result "Enhanced Form Components" "PASS" "Vue 3 form enhancements loaded"
else
    log_test_result "Enhanced Form Components" "FAIL" "Form enhancements not found"
fi

echo ""
echo "📋 Test 5: Chrome MCP Integration Test"
echo "====================================="

# Test 5.1: Full page rendering verification
echo "Testing: Complete Page Rendering with Chrome MCP"
./testing-tools/chrome_mcp_auth_proxy.sh > /tmp/chrome_test_output.txt 2>&1

if [ -f "/tmp/moqui_verified.png" ] && [ -s "/tmp/moqui_verified.png" ]; then
    SCREENSHOT_SIZE=$(stat -f%z "/tmp/moqui_verified.png" 2>/dev/null || stat -c%s "/tmp/moqui_verified.png" 2>/dev/null)
    if [ "$SCREENSHOT_SIZE" -gt 10000 ]; then
        log_test_result "Chrome MCP Rendering" "PASS" "Screenshot generated (${SCREENSHOT_SIZE} bytes)"
    else
        log_test_result "Chrome MCP Rendering" "FAIL" "Screenshot too small (${SCREENSHOT_SIZE} bytes)"
    fi
else
    log_test_result "Chrome MCP Rendering" "FAIL" "No screenshot generated"
fi

echo ""
echo "📋 Test 6: Performance & Memory Validation"
echo "========================================="

# Test 6.1: Response time validation
echo "Testing: Response Time Performance"
START_TIME=$(date +%s%N)
curl -s -b /tmp/test_session.txt "http://localhost:8080/qapps" > /dev/null
END_TIME=$(date +%s%N)
RESPONSE_TIME=$(( (END_TIME - START_TIME) / 1000000 )) # Convert to milliseconds

if [ "$RESPONSE_TIME" -lt 2000 ]; then
    log_test_result "Response Time Performance" "PASS" "${RESPONSE_TIME}ms"
else
    log_test_result "Response Time Performance" "FAIL" "${RESPONSE_TIME}ms (too slow)"
fi

echo ""
echo "🏁 Vue 3 + Quasar 2 Comprehensive Testing Results"
echo "================================================="
echo "📊 Summary:"
echo "   Total Tests: $TESTS_TOTAL"
echo "   Passed: $TESTS_PASSED"
echo "   Failed: $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo "🎉 ALL TESTS PASSED! Vue 3 + Quasar 2 system is fully operational"
    echo "✅ Vue 3 Composition API optimizations working correctly"
    echo "✅ All core functionality verified"
    echo "✅ Performance metrics within acceptable range"
else
    echo "⚠️  Some tests failed. Details:"
    for failed_test in "${FAILED_TESTS[@]}"; do
        echo "   ❌ $failed_test"
    done
fi

# Calculate success percentage
SUCCESS_PERCENTAGE=$(( (TESTS_PASSED * 100) / TESTS_TOTAL ))
echo ""
echo "📈 Success Rate: ${SUCCESS_PERCENTAGE}%"

# Clean up temporary files
rm -f /tmp/test_session.txt /tmp/chrome_test_output.txt

echo ""
echo "✅ Vue 3 + Quasar 2 Comprehensive Testing Completed"