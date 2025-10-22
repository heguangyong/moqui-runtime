<#--
This software is in the public domain under CC0 1.0 Universal plus a
Grant of Patent License.

To the extent possible under law, the author(s) have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software (see the LICENSE.md file). If not, see
<http://creativecommons.org/publicdomain/zero/1.0/>.
-->

<div id="apps-root"><#-- NOTE: webrootVue component attaches here, uses this and below for template -->
    <#-- 纯JWT认证模式：移除session token依赖 -->
    <input type="hidden" id="confMoquiSessionToken" value="">
    <#-- JWT优先：从cookie或header获取JWT token -->
    <#assign jwtToken = "">
    <#assign authHeader = ec.web.getRequest().getHeader('Authorization')!"">
    <#if authHeader?starts_with('Bearer ')>
        <#assign jwtToken = authHeader>
    <#else>
        <#-- 检查cookie中的JWT token -->
        <#assign cookies = ec.web.getRequest().getCookies()![]>
        <#list cookies as cookie>
            <#if cookie.getName() == "jwt_token" && cookie.getValue()?starts_with('eyJ')>
                <#assign jwtToken = "Bearer " + cookie.getValue()>
                <#break>
            </#if>
        </#list>
    </#if>
    <input type="hidden" id="confJwtAccessToken" value="${jwtToken}">
    <input type="hidden" id="confAuthMode" value="jwt">
    <input type="hidden" id="confAppHost" value="${(ec.web.getHostName(true))!'localhost'}">
    <input type="hidden" id="confAppRootPath" value="${ec.web.servletContext.contextPath}">
    <input type="hidden" id="confBasePath" value="${ec.web.servletContext.contextPath}/apps">
    <input type="hidden" id="confLinkBasePath" value="${ec.web.servletContext.contextPath}/qapps">
    <input type="hidden" id="confUserId" value="${ec.user.userId!''}">
    <input type="hidden" id="confUsername" value="${(ec.user.username!'')?xml}">
    <#assign userDisplayName = (ec.user.userAccount.userFullName)!''>
    <#if !userDisplayName?has_content && ec.user.username?has_content>
        <#assign userDisplayName = ec.user.username>
    </#if>
    <input type="hidden" id="confUserDisplayName" value="${userDisplayName?xml}">
    <#-- TODO get secondFactorRequired (org.moqui.impl.UserServices.get#UserAuthcFactorRequired with userId) -->
    <#attempt>
        <input type="hidden" id="confLocale" value="${ec.user.locale.toLanguageTag()}">
    <#recover>
        <input type="hidden" id="confLocale" value="en-US">
    </#attempt>
    <#attempt>
        <input type="hidden" id="confDarkMode" value="${ec.user.getPreference("QUASAR_DARK")!"false"}">
        <input type="hidden" id="confLeftOpen" value="${ec.user.getPreference("QUASAR_LEFT_OPEN")!"false"}">
    <#recover>
        <input type="hidden" id="confDarkMode" value="false">
        <input type="hidden" id="confLeftOpen" value="false">
    </#attempt>
    <#assign navbarCompList = sri.getThemeValues("STRT_HEADER_NAVBAR_COMP")>
    <#list navbarCompList! as navbarCompUrl><input type="hidden" class="confNavPluginUrl" value="${navbarCompUrl}"></#list>
    <#assign accountCompList = sri.getThemeValues("STRT_HEADER_ACCOUNT_COMP")>
    <#list accountCompList! as accountCompUrl><input type="hidden" class="confAccountPluginUrl" value="${accountCompUrl}"></#list>

    <#assign headerClass = "bg-black text-white">

    <#-- for layout options see: https://quasar.dev/layout/layout -->
    <#-- to build a layout use the handy Quasar tool: https://quasar.dev/layout-builder -->
    <q-layout view="hHh LpR fFf">
        <q-header reveal bordered class="${headerClass}" id="top">
            <q-toolbar class="q-gutter-sm items-center" style="font-size:15px;">
                <q-btn dense flat icon="menu" @click="toggleLeftOpen()"></q-btn>

                <div class="row items-center no-wrap q-gutter-md">
                    <#assign headerLogoList = sri.getThemeValues("STRT_HEADER_LOGO")>
                    <#if headerLogoList?has_content>
                        <m-link href="/qapps/AppList" class="row items-center no-wrap q-ml-sm">
                            <img src="${sri.buildUrl(headerLogoList?first).getUrl()}" alt="Home" height="32">
                        </m-link>
                    </#if>
                    <#assign headerTitleList = sri.getThemeValues("STRT_HEADER_TITLE")>
                    <#assign resolvedHeaderTitle = "">
                    <#if headerTitleList?has_content>
                        <#assign rawHeaderTitle = headerTitleList?first>
                        <#if rawHeaderTitle?is_string>
                            <#assign resolvedHeaderTitle = ec.resource.expand(rawHeaderTitle, "")>
                        <#elseif rawHeaderTitle?is_hash>
                            <#assign localeKey = ec.user.locale.toLanguageTag()?replace('-', '_')>
                            <#assign resolvedHeaderTitle = rawHeaderTitle[localeKey]!"">
                            <#if !resolvedHeaderTitle?has_content && localeKey?contains('_')>
                                <#assign shortLocale = localeKey?substring(0, localeKey?index_of('_'))>
                                <#assign resolvedHeaderTitle = rawHeaderTitle[shortLocale]!"">
                            </#if>
                            <#if !resolvedHeaderTitle?has_content>
                                <#assign resolvedHeaderTitle = rawHeaderTitle["default"]!"">
                            </#if>
                            <#if resolvedHeaderTitle?has_content>
                                <#assign resolvedHeaderTitle = ec.resource.expand(resolvedHeaderTitle, "")>
                            </#if>
                        <#else>
                            <#assign resolvedHeaderTitle = rawHeaderTitle?string>
                        </#if>
                    </#if>
                    <q-toolbar-title class="ellipsis">
                        <#if resolvedHeaderTitle?has_content>
                            ${resolvedHeaderTitle}
                        <#else>
                                                 {{ navMenuList.length > 0 ? navMenuList[navMenuList.length - 1].title : '${ec.l10n.localize("Applications")}' }}
                        </#if>
                    </q-toolbar-title>
                </div>

                <q-space></q-space>

                <q-circular-progress indeterminate size="20px" color="light-blue" class="q-ma-xs" :class="{ hidden: loading < 1 }"></q-circular-progress>

                <component v-for="(navPlugin, navIdx) in navPlugins" :is="navPlugin" :key="navIdx" class="q-ml-sm"></component>

                <q-btn dense flat icon="notifications">
                    <q-tooltip>${ec.l10n.localize("Notify History")}</q-tooltip>
                    <q-menu><q-list dense style="min-width: 300px">
                        <q-item v-for="histItem in notifyHistoryList" :key="histItem.time + histItem.message"><q-item-section>
                            <q-banner dense rounded class="text-white" :class="'bg-' + getQuasarColor(histItem.type)">
                                <strong>{{histItem.time}}</strong> <span>{{histItem.message}}</span>
                                <template v-slot:action>
                                    <q-btn v-if="histItem.link" :to="histItem.link" flat color="white" label="View"/>
                                </template>
                            </q-banner>
                        </q-item-section></q-item>
                    </q-list></q-menu>
                </q-btn>

                <q-btn dense flat icon="history" :class="{hidden: !navHistoryList.length}">
                    <q-tooltip>${ec.l10n.localize("Screen History")}</q-tooltip>
                    <q-menu><q-list dense style="min-width: 300px">
                        <q-item v-for="histItem in navHistoryList" :key="histItem.pathWithParams" clickable v-close-popup>
                            <q-item-section>
                                <m-link :href="histItem.pathWithParams">
                                    <span v-if="histItem.image" class="q-pr-sm">
                                        <i v-if="histItem.imageType === 'icon'" :class="histItem.image"></i>
                                        <img v-else :src="histItem.image" :alt="histItem.title" width="18" class="invertible">
                                    </span>
                                    {{histItem.displayTitle || safeDisplayValue(histItem.title, locale)}}
                                </m-link>
                            </q-item-section>
                        </q-item>
                    </q-list></q-menu>
                </q-btn>

                <component v-for="(accountPlugin, accountIdx) in accountPlugins" :is="accountPlugin" :key="accountIdx" class="q-ml-sm"></component>

                <q-btn dense flat icon="account_circle">
                    <q-tooltip>${(ec.user.userAccount.userFullName)!ec.l10n.localize("Account")}</q-tooltip>
                    <q-menu><q-card flat bordered>
                        <q-card-section class="column q-gutter-sm">
                            <#if (ec.user.userAccount.userFullName)?has_content><div class="text-subtitle2">${ec.l10n.localize("Welcome")} ${ec.user.userAccount.userFullName}</div></#if>
                            <q-btn flat dense icon="settings_power" color="negative" type="a" href="${sri.buildUrl("/Login/logout").url}" onclick="return confirm('${ec.l10n.localize("Logout")} ${(ec.user.userAccount.userFullName)!''}?')">
                                <q-tooltip>${ec.l10n.localize("Logout")}</q-tooltip>
                            </q-btn>
                            <q-btn flat dense icon="invert_colors" @click.prevent="switchDarkLight()">
                                <q-tooltip>${ec.l10n.localize("Switch Dark/Light")}</q-tooltip>
                            </q-btn>
                            <q-btn flat dense icon="autorenew" color="negative" @click="reLoginShowDialog">
                                <q-tooltip>${ec.l10n.localize("Re-Login")}</q-tooltip>
                            </q-btn>
                        </q-card-section>
                    </q-card></q-menu>
                </q-btn>
            </q-toolbar>
        </q-header>

        <q-drawer v-model="leftOpen" side="left" bordered><#-- no 'overlay', for those who want to keep it open better to compress main area -->
            <q-btn dense flat icon="menu" @click="toggleLeftOpen()" class="lt-sm"></q-btn>
            <q-list dense padding><m-menu-nav-item :menu-index="0"></m-menu-nav-item></q-list>
        </q-drawer>

        <q-page-container class="q-ma-sm"><q-page>
            <m-subscreens-active></m-subscreens-active>
        </q-page></q-page-container>

        <q-footer reveal bordered class="bg-grey-9 text-white row q-pa-xs" id="footer">
            <#assign footerItemList = sri.getThemeValues("STRT_FOOTER_ITEM")>
            <#list footerItemList! as footerItem>
                <#assign footerItemTemplate = footerItem?interpret>
                <@footerItemTemplate/>
            </#list>
        </q-footer>
    </q-layout>
    <#-- re-login dialog -->
    <m-dialog v-model="reLoginShow" width="400" title="${ec.l10n.localize("Re-Login")}">
        <div v-if="reLoginMfaData">
            <div style="text-align:center;padding-bottom:10px">User <strong>{{reLoginUsernameDisplay}}</strong> requires an authentication code, you have these options:</div>
            <div style="text-align:center;padding-bottom:10px">{{reLoginFactorDescriptionText || 'Multi-factor authentication required'}}</div>
            <q-form @submit.prevent="reLoginVerifyOtp" autocapitalize="off" autocomplete="off">
                <q-input v-model="reLoginOtp" name="code" type="password" :autofocus="true" :noPassToggle="false"
                         outlined stack-label label="${ec.l10n.localize("Authentication Code")}"></q-input>
                <q-btn outline no-caps color="primary" type="submit" label="${ec.l10n.localize("Sign in")}"></q-btn>
            </q-form>
            <div v-for="sendableFactor in reLoginMfaData.sendableFactors" style="padding:8px">
                <q-btn outline no-caps dense
                       :label="'${ec.l10n.localize("Send code to")} ' + formatSendableFactorOption(sendableFactor.factorOption)"
                       @click.prevent="reLoginSendOtp(sendableFactor.factorId)"></q-btn>
            </div>
        </div>
        <div v-else>
            <div style="text-align:center;padding-bottom:10px">Please sign in to continue as user <strong>{{reLoginUsernameDisplay}}</strong></div>
            <q-form @submit.prevent="reLoginSubmit" autocapitalize="off" autocomplete="off">
                <q-input v-model="reLoginPassword" name="password" type="password" :autofocus="true"
                         outlined stack-label label="${ec.l10n.localize("Password")}"></q-input>
                <q-btn outline no-caps color="primary" type="submit" label="${ec.l10n.localize("Sign in")}"></q-btn>
                <q-btn outline no-caps color="negative" @click.prevent="reLoginReload" label="${ec.l10n.localize("Reload Page")}"></q-btn>
            </q-form>
        </div>
    </m-dialog>
</div>

<script>
    window.quasarConfig = {
        brand: { // this will NOT work on IE 11
            // primary: '#e46262',
            info:'#1e7b8e'
        },
        notify: { progress:true, closeBtn:'X', position:'top-right' }, // default set of options for Notify Quasar plugin
        // loading: {...}, // default set of options for Loading Quasar plugin
        loadingBar: { color:'primary' }, // settings for LoadingBar Quasar plugin
        // ..and many more (check Installation card on each Quasar component/directive/plugin)
    }
</script>
