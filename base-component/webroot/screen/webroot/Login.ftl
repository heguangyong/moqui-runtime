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
    "secondFactorRequired": secondFactorRequired?boolean,
    "passwordChangeRequired": passwordChangeRequired?boolean,
    "expiredCredentials": expiredCredentials?boolean,
    "factorTypeDescriptions": factorDescriptionsList,
    "sendableFactors": sendableFactorsList,
    "minLength": minLength!8,
    "minDigits": minDigits!1,
    "minOthers": minOthers!1,
    "hasExistingUsers": hasExistingUsers?boolean,
    "testLoginAvailable": testLoginAvailable?boolean,
    "authFlows": authFlows
}>
<#assign loginContextJson = loginContext?json_string>
<#assign savedMessages = (ec.web?.savedMessages)![]>
<#assign savedErrors = (ec.web?.savedErrors)![]>
<#assign savedValidationErrors = (ec.web?.savedValidationErrors)![]>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${ec.l10n.localize("Sign In")}</title>
    <link rel="apple-touch-icon" href="/MoquiLogo100.png"/>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900|Material+Icons">
    <link rel="stylesheet" href="/libs/quasar/quasar.min.css">
    <link rel="stylesheet" href="/css/WebrootVue.qvt.css">
    <style>
        body.login-body {
            min-height: 100vh;
            margin: 0;
            background: radial-gradient(circle at top, #1d3557 0%, #0b1d2b 60%, #050915 100%);
            font-family: 'Roboto', sans-serif;
        }
        #login-app[v-cloak] { display: none; }
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

                    <template v-if="hasExistingUsers">
                        <q-card-section class="q-pt-sm">
                            <q-tabs v-model="activeTab" dense class="text-primary" indicator-color="primary" align="justify">
                                <q-tab name="login" icon="login" label="${ec.l10n.localize("Login")}"/>
                                <q-tab v-if="showSso" name="sso" icon="cloud" label="SSO"/>
                                <q-tab name="reset" icon="refresh" label="${ec.l10n.localize("Reset Password")}"/>
                                <q-tab name="change" icon="lock_reset" label="${ec.l10n.localize("Change Password")}"/>
                            </q-tabs>
                        </q-card-section>

                        <q-separator inset/>

                        <q-tab-panels v-model="activeTab" animated>
                            <q-tab-panel name="login" class="q-pt-sm">
                                <q-card-section class="q-gutter-md">
                                    <q-banner v-if="passwordChangeRequired" class="bg-warning text-black" dense rounded>
                                        ${ec.l10n.localize("Password change required before continuing.")}
                                    </q-banner>
                                    <q-banner v-if="expiredCredentials" class="bg-negative text-white" dense rounded>
                                        ${ec.l10n.localize("Your password has expired; please change it now.")}
                                    </q-banner>

                                    <form class="q-gutter-md" method="post" action="${sri.buildUrl("login").url}">
                                        <input type="hidden" name="initialTab" :value="activeTab">
                                        <q-input v-model="loginForm.username" name="username" label="${ec.l10n.localize("Username")}" autocomplete="username"
                                                 outlined dense :disable="secondFactorRequired" required/>
                                        <template v-if="secondFactorRequired">
                                            <q-input v-model="loginForm.code" name="code" label="${ec.l10n.localize("Authentication Code")}" autocomplete="one-time-code"
                                                     inputmode="numeric" outlined dense required/>
                                        </template>
                                        <template v-else>
                                            <q-input v-model="loginForm.password" name="password" label="${ec.l10n.localize("Password")}" type="password"
                                                     autocomplete="current-password" outlined dense required/>
                                        </template>
                                        <q-btn type="submit" color="primary" class="full-width" unelevated>
                                            ${ec.l10n.localize("Sign in")}
                                        </q-btn>
                                    </form>

                                    <div v-if="secondFactorRequired" class="q-mt-md">
                                        <div class="text-body2 q-mb-sm">${ec.l10n.localize("An authentication code is required; available methods:")}</div>
                                        <ul class="text-body2 q-pl-lg">
                                            <li v-for="desc in factorTypeDescriptions" :key="desc">{{ desc }}</li>
                                        </ul>
                                        <div class="q-gutter-sm q-mt-sm">
                                            <form v-for="factor in sendableFactors" :key="factor.factorId" method="post" action="${sri.buildUrl("sendOtp").url}">
                                                <input type="hidden" name="factorId" :value="factor.factorId">
                                                <input type="hidden" name="initialTab" :value="activeTab">
                                                <q-btn type="submit" color="primary" outline class="full-width">
                                                    ${ec.l10n.localize("Send code to")} {{ factor.factorOption }}
                                                </q-btn>
                                            </form>
                                        </div>
                                    </div>
                                </q-card-section>
                            </q-tab-panel>

                            <q-tab-panel name="sso" class="q-pt-sm">
                                <q-card-section class="q-gutter-md">
                                    <div v-if="ssoFlows.length === 0" class="text-body2 text-grey-7 text-center q-pt-md">
                                        ${ec.l10n.localize("No SSO providers are configured.")}
                                    </div>
                                    <form v-for="flow in ssoFlows" :key="flow.authFlowId" method="post" action="/sso/login">
                                        <input type="hidden" name="authFlowId" :value="flow.authFlowId">
                                        <q-btn type="submit" color="primary" outline class="full-width">
                                            {{ flow.description }}
                                        </q-btn>
                                    </form>
                                </q-card-section>
                            </q-tab-panel>

                            <q-tab-panel name="reset" class="q-pt-sm">
                                <q-card-section class="q-gutter-md">
                                    <form class="q-gutter-md" method="post" action="${sri.buildUrl("resetPassword").url}">
                                        <input type="hidden" name="initialTab" :value="activeTab">
                                        <q-input v-model="resetForm.username" name="username" label="${ec.l10n.localize("Username")}" autocomplete="username"
                                                 outlined dense required/>
                                        <q-btn type="submit" color="primary" class="full-width" unelevated>
                                            ${ec.l10n.localize("Email Reset Password")}
                                        </q-btn>
                                    </form>
                                </q-card-section>
                            </q-tab-panel>

                            <q-tab-panel name="change" class="q-pt-sm">
                                <q-card-section class="q-gutter-md">
                                    <div class="text-body2 text-grey-7">${ec.l10n.localize("Enter details to change your password")}</div>
                                    <form class="q-gutter-md q-mt-sm" method="post" action="${sri.buildUrl("changePassword").url}">
                                        <input type="hidden" name="initialTab" :value="activeTab">
                                        <q-input v-model="changeForm.username" name="username" label="${ec.l10n.localize("Username")}" autocomplete="username"
                                                 outlined dense :disable="changeRequiresCode" required/>
                                        <template v-if="changeRequiresCode">
                                            <input type="hidden" name="oldPassword" value="ignored">
                                            <q-input v-model="changeForm.code" name="code" label="${ec.l10n.localize("Authentication Code")}" autocomplete="one-time-code"
                                                     inputmode="numeric" outlined dense required/>
                                        </template>
                                        <template v-else>
                                            <q-input v-model="changeForm.oldPassword" name="oldPassword" label="${ec.l10n.localize("Old Password")}" type="password"
                                                     autocomplete="current-password" outlined dense required/>
                                        </template>
                                        <q-input v-model="changeForm.newPassword" name="newPassword" label="${ec.l10n.localize("New Password")}" type="password"
                                                 autocomplete="new-password" outlined dense required/>
                                        <q-input v-model="changeForm.newPasswordVerify" name="newPasswordVerify" label="${ec.l10n.localize("New Password Verify")}" type="password"
                                                 autocomplete="new-password" outlined dense required/>
                                        <div class="text-caption text-grey-7">
                                            ${ec.l10n.localize("Password must be at least")}&nbsp;{{ minLength }}&nbsp;${ec.l10n.localize("characters")},
                                            ${ec.l10n.localize("with at least")}&nbsp;{{ minDigits }}&nbsp;${ec.l10n.localize("number(s)")}
                                            <span v-if="minOthers &gt; 0"> ${ec.l10n.localize("and at least")}&nbsp;{{ minOthers }}&nbsp;${ec.l10n.localize("punctuation character(s)")}</span>
                                        </div>
                                        <q-btn type="submit" color="negative" class="full-width" unelevated>
                                            ${ec.l10n.localize("Change Password")}
                                        </q-btn>
                                    </form>
                                </q-card-section>
                            </q-tab-panel>
                        </q-tab-panels>
                    </template>

                    <template v-else>
                        <q-card-section class="q-pt-lg q-gutter-md">
                            <div class="text-h6 text-primary text-center">${ec.l10n.localize("Welcome to your new system")}</div>
                            <div class="text-body2 text-grey-7 text-center">${ec.l10n.localize("Create the initial administrator account to get started")}</div>
                            <form class="q-gutter-md q-mt-md" method="post" action="${sri.buildUrl("createInitialAdminAccount").url}">
                                <input type="hidden" name="moquiSessionToken" value="${ec.web.sessionToken}">
                                <q-input name="username" label="${ec.l10n.localize("Username")}" outlined dense required
                                         value="${(ec.getWeb().getErrorParameters().get("username"))?if_exists?html}" />
                                <q-input name="newPassword" type="password" label="${ec.l10n.localize("New Password")}" outlined dense required/>
                                <q-input name="newPasswordVerify" type="password" label="${ec.l10n.localize("New Password Verify")}" outlined dense required/>
                                <q-input name="userFullName" label="${ec.l10n.localize("User Full Name")}" outlined dense required
                                         value="${(ec.getWeb().getErrorParameters().get("userFullName"))?if_exists?html}" />
                                <q-input name="emailAddress" label="${ec.l10n.localize("Email Address")}" type="email" outlined dense required
                                         value="${(ec.getWeb().getErrorParameters().get("emailAddress"))?if_exists?html}" />
                                <q-btn type="submit" color="primary" class="full-width" unelevated>
                                    ${ec.l10n.localize("Create Initial Admin Account")}
                                </q-btn>
                            </form>
                        </q-card-section>
                    </template>

                    <q-separator inset class="q-my-md" v-if="testLoginAvailable"></q-separator>

                    <q-card-section v-if="testLoginAvailable" class="q-pt-none">
                        <form method="post" action="${sri.buildUrl("login").url}" class="q-gutter-sm">
                            <input type="hidden" name="username" value="john.doe">
                            <input type="hidden" name="password" value="moqui">
                            <q-btn type="submit" color="secondary" outline class="full-width">
                                ${ec.l10n.localize("Test Login (John Doe)")}
                            </q-btn>
                        </form>
                    </q-card-section>
                </q-card>
            </q-page>
        </q-page-container>
    </q-layout>
</div>

<script src="/libs/vue/vue.min.js"></script>
<script src="/libs/quasar/quasar.umd.min.js"></script>
<script src="/js/MoquiLib.js"></script>
<script src="/includes/JwtAuth.js"></script>
<script>
    const LOGIN_CONTEXT = ${loginContextJson};
    Vue.use(Quasar);
    new Vue({
        el: '#login-app',
        data() {
            return {
                activeTab: LOGIN_CONTEXT.initialTab,
                loginForm: {
                    username: LOGIN_CONTEXT.username,
                    password: '',
                    code: ''
                },
                resetForm: {
                    username: LOGIN_CONTEXT.username
                },
                changeForm: {
                    username: LOGIN_CONTEXT.username,
                    oldPassword: '',
                    newPassword: '',
                    newPasswordVerify: '',
                    code: ''
                },
                secondFactorRequired: LOGIN_CONTEXT.secondFactorRequired,
                passwordChangeRequired: LOGIN_CONTEXT.passwordChangeRequired,
                expiredCredentials: LOGIN_CONTEXT.expiredCredentials,
                factorTypeDescriptions: LOGIN_CONTEXT.factorTypeDescriptions || [],
                sendableFactors: LOGIN_CONTEXT.sendableFactors || [],
                minLength: LOGIN_CONTEXT.minLength,
                minDigits: LOGIN_CONTEXT.minDigits,
                minOthers: LOGIN_CONTEXT.minOthers,
                hasExistingUsers: LOGIN_CONTEXT.hasExistingUsers,
                testLoginAvailable: LOGIN_CONTEXT.testLoginAvailable,
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
</script>
</body>
</html>
