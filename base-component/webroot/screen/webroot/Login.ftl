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
        .login-form-section {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        .login-input {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        .action-btn {
            width: 100%;
            padding: 12px;
            background: #1976d2;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            font-weight: 500;
        }
        .action-btn:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }
        .link-muted {
            font-size: 13px;
            color: #555;
        }
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

                    <q-card-section class="q-pt-none">
                        <q-tabs v-model="activeTab" dense class="text-primary" align="justify">
                            <q-tab name="login" label="${ec.l10n.localize("Login")}"></q-tab>
                            <q-tab v-if="showSso" name="sso" label="${ec.l10n.localize("SSO")}"></q-tab>
                            <q-tab name="reset" label="${ec.l10n.localize("Reset Password")}"></q-tab>
                            <q-tab name="change" label="${ec.l10n.localize("Change Password")}"></q-tab>
                        </q-tabs>
                        <q-separator class="q-my-sm"></q-separator>
                        <q-tab-panels v-model="activeTab" animated swipeable>
                            <q-tab-panel name="login">
                                <div class="text-primary text-center q-mb-md" style="font-weight:500;">
                                    ${ec.l10n.localize("Login")}
                                </div>
                                <form id="jwt-login-form-page" autocomplete="off" class="login-form-section">
                                    <input type="hidden" name="initialTab" value="login" class="initial-tab">
                                    <input id="login_form_username" class="login-input" type="text" name="username" required
                                           placeholder="${ec.l10n.localize("Username")}" value="${(username!'')?html}">
                                    <input id="login_form_password" class="login-input" type="password" name="password" required
                                           placeholder="${ec.l10n.localize("Password")}">
                                    <label class="link-muted" style="display:flex;align-items:center;gap:8px;">
                                        <input type="checkbox" name="rememberMe" value="Y">
                                        ${ec.l10n.localize("Remember Me")}
                                    </label>
                                    <button type="submit" class="action-btn">
                                        ${ec.l10n.localize("Sign In")}
                                    </button>
                                    <div id="jwt-login-error" style="color:#c62828; font-size:13px; min-height:18px;"></div>
                                </form>
                            </q-tab-panel>

                            <q-tab-panel v-if="showSso" name="sso">
                                <div class="column q-gutter-sm">
                                    <#list authFlows as flow>
                                        <form method="post" action="/sso/login" class="login-form-section" style="gap:8px;">
                                            <input type="hidden" name="authFlowId" value="${flow.authFlowId?html}">
                                            <input type="hidden" name="initialTab" value="sso" class="initial-tab">
                                            <button class="action-btn" type="submit">${flow.description?html}</button>
                                        </form>
                                    </#list>
                                </div>
                            </q-tab-panel>

                            <q-tab-panel name="reset">
                                <form method="post" action="${sri.buildUrl("resetPassword").url}" class="login-form-section" id="reset_form">
                                    <input type="hidden" name="initialTab" value="reset" class="initial-tab">
                                    <p class="text-muted" style="margin:0;">
                                        ${ec.l10n.localize("Enter your username to receive a password reset link.")}
                                    </p>
                                    <input id="reset_form_username" class="login-input" type="text" name="username" required
                                           value="${(username!'')?html}"
                                           placeholder="${ec.l10n.localize("Username")}">
                                    <button class="action-btn" type="submit">${ec.l10n.localize("Reset Password")}</button>
                                </form>
                            </q-tab-panel>

                            <q-tab-panel name="change">
                                <form method="post" action="${sri.buildUrl("changePassword").url}" class="login-form-section" id="change_form">
                                    <input type="hidden" name="initialTab" value="change" class="initial-tab">
                                    <input id="change_form_username" class="login-input" type="text" name="username"
                                           value="${(username!'')?html}"
                                           placeholder="${ec.l10n.localize("Username")}"
                                           <#if secondFactorRequired>readonly</#if> required>
                                    <#if !secondFactorRequired>
                                        <input class="login-input" type="password" name="oldPassword"
                                               placeholder="${ec.l10n.localize("Current Password")}" required>
                                    </#if>
                                    <input class="login-input" type="password" name="newPassword"
                                           placeholder="${ec.l10n.localize("New Password")} (min ${minLength} ${ec.l10n.localize("characters")})" required>
                                    <input class="login-input" type="password" name="newPasswordVerify"
                                           placeholder="${ec.l10n.localize("Verify Password")}" required>
                                    <#if secondFactorRequired>
                                        <input id="change_form_code" class="login-input" type="text" name="code"
                                               placeholder="${ec.l10n.localize("Authentication Code")}" required>
                                    </#if>
                                    <button class="action-btn" type="submit">${ec.l10n.localize("Change Password")}</button>
                                </form>
                                <#if secondFactorRequired && sendableFactors?has_content>
                                    <div class="q-mt-md">
                                        <div class="text-muted" style="margin-bottom:8px;">
                                            ${ec.l10n.localize("Send authentication code to")}:
                                        </div>
                                        <#list sendableFactors as sendableFactor>
                                            <form method="post" action="${sri.buildUrl("sendOtp").url}" class="login-form-section" style="gap:8px;">
                                                <input type="hidden" name="factorId" value="${sendableFactor.factorId?html}">
                                                <input type="hidden" name="initialTab" value="change" class="initial-tab">
                                                <button class="action-btn" type="submit">
                                                    ${ec.l10n.localize("Send code to")} ${sendableFactor.factorOption?html}
                                                </button>
                                            </form>
                                        </#list>
                                    </div>
                                </#if>
                                <#if (ec.web.sessionAttributes.get("moquiPreAuthcUsername"))?has_content>
                                    <form method="post" action="${sri.buildUrl("removePreAuth").url}" class="login-form-section" style="gap:8px;">
                                        <input type="hidden" name="initialTab" value="change" class="initial-tab">
                                        <button class="action-btn" type="submit">${ec.l10n.localize("Change User")}</button>
                                    </form>
                                </#if>
                                <#if passwordChangeRequired?? && passwordChangeRequired>
                                    <div class="text-negative q-mt-md">${ec.l10n.localize("Password change required")}.</div>
                                </#if>
                                <#if expiredCredentials?? && expiredCredentials>
                                    <div class="text-negative q-mt-xs">${ec.l10n.localize("Your password has expired")}.</div>
                                </#if>
                            </q-tab-panel>
                        </q-tab-panels>
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
    const LOGIN_CONTEXT = {
        initialTab: "${normalizedTab?js_string}",
        username: "${(username!'')?js_string}",
        secondFactorRequired: ${(secondFactorRequired!false)?c},
        passwordChangeRequired: ${(passwordChangeRequired!false)?c},
        expiredCredentials: ${(expiredCredentials!false)?c},
        factorTypeDescriptions: [
            <#list factorDescriptionsList as desc>"${desc?js_string}"<#if desc_has_next>,</#if></#list>
        ],
        sendableFactors: [
            <#list sendableFactorsList as factor>{ "factorId": "${factor.factorId?js_string}", "factorOption": "${factor.factorOption?js_string}" }<#if factor_has_next>,</#if></#list>
        ],
        minLength: ${minLength!8},
        minDigits: ${minDigits!1},
        minOthers: ${minOthers!1},
        hasExistingUsers: ${(hasExistingUsers!false)?c},
        testLoginAvailable: ${(testLoginAvailable!false)?c},
        authFlows: [
            <#list authFlows as flow>{ "authFlowId": "${flow.authFlowId?js_string}", "description": "${(flow.description!flow.authFlowId)?js_string}" }<#if flow_has_next>,</#if></#list>
        ],
        allowedTabs: [<#list allowedTabs as tab>"${tab?js_string}"<#if tab_has_next>,</#if></#list>]
    };
    const loginApp = Vue.createApp({
        data() {
            var allowed = Array.isArray(LOGIN_CONTEXT.allowedTabs) && LOGIN_CONTEXT.allowedTabs.length ? LOGIN_CONTEXT.allowedTabs : ['login', 'reset', 'change'];
            var hashTab = window.location.hash ? window.location.hash.substring(1) : '';
            if (allowed.indexOf(hashTab) === -1) {
                hashTab = LOGIN_CONTEXT.initialTab || 'login';
            }
            if (allowed.indexOf(hashTab) === -1) {
                hashTab = 'login';
            }
            return {
                activeTab: hashTab,
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
                ssoFlows: LOGIN_CONTEXT.authFlows || [],
                allowedTabs: allowed
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
                this.updateInitialTabHiddenFields();
                this.focusActiveField();
            }
        },
        methods: {
            updateInitialTabHiddenFields() {
                var inputs = document.querySelectorAll('.initial-tab');
                inputs.forEach((input) => { input.value = this.activeTab; });
            },
            focusActiveField() {
                var targetId = null;
                if (this.activeTab === 'login') {
                    targetId = 'login_form_username';
                } else if (this.activeTab === 'reset') {
                    targetId = 'reset_form_username';
                } else if (this.activeTab === 'change') {
                    targetId = this.secondFactorRequired ? 'change_form_code' : 'change_form_username';
                }
                if (targetId) {
                    var el = document.getElementById(targetId);
                    if (el) el.focus();
                }
            }
        },
        mounted() {
            window.location.hash = '#' + this.activeTab;
            this.updateInitialTabHiddenFields();
            this.focusActiveField();
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
