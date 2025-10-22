<#assign authFlows = []>
<#if authFlowList?has_content>
    <#list authFlowList as flow>
        <#assign authFlows = authFlows + [{"authFlowId":flow.authFlowId, "description":flow.description!flow.authFlowId}]>
    </#list>
</#if>
<#assign factorDescriptionsList = []>
<#list (factorTypeDescriptions![]) as desc>
    <#assign factorDescriptionsList = factorDescriptionsList + [desc]>
</#list>
<#assign sendableFactorsList = []>
<#list (sendableFactors![]) as factor>
    <#assign sendableFactorsList = sendableFactorsList + [{"factorId":factor.factorId, "factorOption":factor.factorOption!""}]>
</#list>
<#assign initialTabValue = initialTab!"#login">
<#assign normalizedTab = initialTabValue?replace("^#", "", "r")>
<#assign allowedTabs = ["login", "reset", "change"]>
<#if authFlows?size gt 0>
    <#assign allowedTabs = allowedTabs + ["sso"]>
</#if>
<#if !allowedTabs?seq_contains(normalizedTab)>
    <#assign normalizedTab = "login">
</#if>
<#assign loginContext = {
    "initialTab": normalizedTab,
    "username": username!"",
    "secondFactorRequired": (secondFactorRequired!false)?c,
    "passwordChangeRequired": (passwordChangeRequired!false)?c,
    "expiredCredentials": (expiredCredentials!false)?c,
    "factorTypeDescriptions": factorDescriptionsList,
    "sendableFactors": sendableFactorsList,
    "minLength": minLength!8,
    "minDigits": minDigits!1,
    "minOthers": minOthers!1,
    "hasExistingUsers": (hasExistingUsers!false)?c,
    "testLoginAvailable": (testLoginAvailable!false)?c,
    "authFlows": authFlows
}>
<#assign loginContextJson = "{
    \\\"initialTab\\\": \\\"login\\\",
    \\\"username\\\": \\\"\\\",
    \\\"secondFactorRequired\\\": false,
    \\\"passwordChangeRequired\\\": false,
    \\\"expiredCredentials\\\": false,
    \\\"factorTypeDescriptions\\\": [],
    \\\"sendableFactors\\\": [],
    \\\"minLength\\\": 8,
    \\\"minDigits\\\": 1,
    \\\"minOthers\\\": 1,
    \\\"hasExistingUsers\\\": ${(hasExistingUsers!false)?c},
    \\\"testLoginAvailable\\\": ${(testLoginAvailable!false)?c},
    \\\"authFlows\\\": []
}">
<#assign savedMessages = (ec.web.savedMessages)![]>
<#assign savedErrors = (ec.web.savedErrors)![]>
<#assign savedValidationErrors = (ec.web.savedValidationErrors)![]>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${ec.l10n.localize("Sign In")}</title>
    <link rel="apple-touch-icon" href="/MoquiLogo100.png"/>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900|Material+Icons">
    <link rel="stylesheet" href="/libs/quasar2/quasar.min.css">
    <link rel="stylesheet" href="/css/WebrootVue.qvt.css">
    <style>
        body.login-body {
            min-height: 100vh;
            margin: 0;
            background: radial-gradient(circle at top, #1d3557 0%, #0b1d2b 60%, #050915 100%);
            font-family: 'Roboto', sans-serif;
        }
        /* #login-app[v-cloak] { display: none; } */
        .login-page { padding: 24px; }
        .login-card {
            width: 420px;
            max-width: 100%;
            border-radius: 18px;
            box-shadow: 0 20px 45px rgba(13, 43, 80, 0.4);
            backdrop-filter: blur(6px);
        }
        .login-avatar {
            width: 72px;
            height: 72px;
            border-radius: 50%;
            background: linear-gradient(135deg, #1976d2 0%, #42a5f5 100%);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 32px;
        }
        .q-tab-panel form {
            width: 100%;
        }
        .full-width { width: 100%; }
        .text-muted { color: #9e9e9e; }
    </style>
</head>
<body class="login-body">
<div id="login-app" v-cloak>
    <q-layout view="lHh Lpr lFf">
        <q-page-container>
            <q-page class="flex flex-center login-page">
                <q-card class="login-card q-pa-md bg-white text-dark">
                    <q-card-section class="text-center q-pb-none">
                        <div class="login-avatar">
                            <span class="material-icons">lock</span>
                        </div>
                        <div class="text-h5 q-mt-md text-primary">${ec.l10n.localize("Welcome Back")}</div>
                        <div class="text-body2 text-grey-7">${ec.l10n.localize("Sign in to continue")}</div>
                    </q-card-section>

                    <q-card-section class="q-pt-md q-pb-none">
                    <#list savedMessages as message>
                        <q-banner class="bg-positive text-white q-mb-sm" dense rounded>${message?html}</q-banner>
                    </#list>
                    <#list savedErrors as message>
                        <q-banner class="bg-negative text-white q-mb-sm" dense rounded>${message?html}</q-banner>
                    </#list>
                    <#list savedValidationErrors as validationError>
                        <q-banner class="bg-warning text-black q-mb-sm" dense rounded>
                            ${validationError.message?html}<#if validationError.field?? && validationError.field?has_content> (${validationError.field?html})</#if>
                        </q-banner>
                    </#list>
                    </q-card-section>

                    <!-- Simple HTML Login Form -->
                    <q-card-section class="q-pt-sm">
                        <div style="display: flex; justify-content: center; margin-bottom: 20px;">
                            <div style="border-bottom: 2px solid #1976d2; color: #1976d2; padding: 8px 16px; font-weight: 500;">
                                登录 / Login
                            </div>
                        </div>
                    </q-card-section>

                    <q-card-section class="q-gutter-md">
                        <form id="jwt-login-form-page" autocomplete="off" style="display: flex; flex-direction: column; gap: 16px;">

                            <div style="position: relative;">
                                <input type="text" name="username" required
                                       style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px;"
                                       placeholder="用户名 / Username">
                            </div>

                            <div style="position: relative;">
                                <input type="password" name="password" required
                                       style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px;"
                                       placeholder="密码 / Password">
                            </div>

                            <label style="display:flex; align-items:center; gap:8px; font-size: 13px; color:#555;">
                                <input type="checkbox" name="rememberMe" value="Y">
                                ${ec.l10n.localize("Remember Me")}
                            </label>

                            <button type="submit"
                                    style="width: 100%; padding: 12px; background: #1976d2; color: white; border: none; border-radius: 4px; font-size: 16px; cursor: pointer; font-weight: 500;">
                                登录 / Sign In
                            </button>
                            <div id="jwt-login-error" style="color:#c62828; font-size:13px; min-height:18px;"></div>
                        </form>
                    </q-card-section>
                </q-card>
            </q-page>
        </q-page-container>
    </q-layout>
</div>

<script src="/libs/vue3/vue.min.js"></script>
<script src="/libs/quasar2/quasar.umd.min.js"></script>
<script src="/js/MoquiLib.js"></script>
<script src="/includes/JwtAuth.js"></script>
<script>
    const LOGIN_CONTEXT = ${loginContextJson!'{}'};
    const loginApp = Vue.createApp({
        data() {
            return {
                activeTab: LOGIN_CONTEXT.initialTab || 'login',
                loginForm: {
                    username: LOGIN_CONTEXT.username || '',
                    password: '',
                    code: ''
                },
                resetForm: {
                    username: LOGIN_CONTEXT.username || ''
                },
                changeForm: {
                    username: LOGIN_CONTEXT.username || '',
                    oldPassword: '',
                    newPassword: '',
                    newPasswordVerify: '',
                    code: ''
                },
                secondFactorRequired: LOGIN_CONTEXT.secondFactorRequired || false,
                passwordChangeRequired: LOGIN_CONTEXT.passwordChangeRequired || false,
                expiredCredentials: LOGIN_CONTEXT.expiredCredentials || false,
                factorTypeDescriptions: LOGIN_CONTEXT.factorTypeDescriptions || [],
                sendableFactors: LOGIN_CONTEXT.sendableFactors || [],
                minLength: LOGIN_CONTEXT.minLength || 8,
                minDigits: LOGIN_CONTEXT.minDigits || 1,
                minOthers: LOGIN_CONTEXT.minOthers || 1,
                hasExistingUsers: LOGIN_CONTEXT.hasExistingUsers !== undefined ? LOGIN_CONTEXT.hasExistingUsers : false,
                testLoginAvailable: LOGIN_CONTEXT.testLoginAvailable !== undefined ? LOGIN_CONTEXT.testLoginAvailable : false,
                ssoFlows: LOGIN_CONTEXT.authFlows || []
            };
        },
        computed: {
            showSso() {
                return this.ssoFlows.length > 0;
            },
            changeRequiresCode() {
                return this.secondFactorRequired;
            }
        },
        watch: {
            activeTab(val) {
                window.location.hash = '#' + val;
            }
        },
        mounted() {
            window.location.hash = '#' + this.activeTab;
        }
    });
    loginApp.use(Quasar);
    const loginVm = loginApp.mount('#login-app');
    window.loginApp = loginApp;
    window.loginVm = loginVm;
</script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        var loginForm = document.getElementById('jwt-login-form-page');
        if (!loginForm || !window.jwtAuth) { return; }

        loginForm.addEventListener('submit', async function (event) {
            event.preventDefault();
            var errorDiv = document.getElementById('jwt-login-error');
            if (errorDiv) errorDiv.textContent = '';

            var formData = new FormData(loginForm);
            var username = (formData.get('username') || '').trim();
            var password = formData.get('password') || '';
            var remember = !!formData.get('rememberMe');

            if (!username || !password) {
                if (errorDiv) errorDiv.textContent = '${ec.l10n.localize("Username and password are required")}'.trim();
                return;
            }

            try {
                var result = await window.jwtAuth.login(username, password, 'DEMO_MERCHANT', remember);
                if (result && result.success) {
                    window.location.href = '/qapps/AppList';
                    return;
                }

                if (result && result.data && result.data.secondFactorRequired) {
                    window.location.href = '/Login?initialTab=#login';
                    return;
                }

                var message = (result && (result.message || (result.data && result.data.message))) || '${ec.l10n.localize("Login failed")}'.trim();
                if (errorDiv) errorDiv.textContent = message;
            } catch (loginError) {
                console.error('JWT login error', loginError);
                if (errorDiv) errorDiv.textContent = '${ec.l10n.localize("Network error during login")}'.trim();
            }
        });
    });
</script>
</body>
</html>
