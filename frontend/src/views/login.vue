<template>
  <div class="login">
    <section class="login-visual" aria-label="输电线路智能检测系统">
      <div class="login-brand"><img src="@/assets/logo/grid-mark.svg" alt="" /><div>输电线路智能检测<span>TRANSMISSION INSPECTION</span></div></div>
      <div class="visual-copy"><span class="visual-eyebrow">INTELLIGENT INSPECTION PLATFORM</span><h1>输电线路<br />智能检测系统<span class="heading-dot">.</span></h1><p>从巡检图像到检测结果，<br />让输电线路的状态清晰可见。</p><div class="feature-labels"><span>图像预处理</span><span>缺陷检测</span><span>语义分割</span></div></div>
      <img src="@/assets/images/transmission-line-art.svg" class="tower-illustration" alt="" />
      <div class="visual-caption">复杂背景下输电线路关键部件精准识别与缺陷智能检测</div>
    </section>
    <section class="login-panel">
    <div class="mobile-brand"><img src="@/assets/logo/grid-mark.svg" alt="" />输电线路智能检测</div>
    <el-form ref="loginRef" :model="loginForm" :rules="loginRules" class="login-form" label-position="top">
      <span class="form-eyebrow">欢迎使用</span>
      <h2 class="title">登录工作台</h2>
      <p class="login-subtitle">查看巡检数据，管理您的检测任务。</p>
      <el-form-item label="账号" prop="username">
        <el-input
          v-model="loginForm.username"
          type="text"
          size="large"
          autocomplete="username"
          aria-label="账号"
          placeholder="请输入账号"
        >
          <template #prefix><svg-icon icon-class="user" class="el-input__icon input-icon" /></template>
        </el-input>
      </el-form-item>
      <el-form-item label="密码" prop="password">
        <el-input
          v-model="loginForm.password"
          type="password"
          size="large"
          autocomplete="current-password"
          aria-label="密码"
          placeholder="请输入密码"
          show-password
          @keyup.enter="handleLogin"
        >
          <template #prefix><svg-icon icon-class="password" class="el-input__icon input-icon" /></template>
        </el-input>
      </el-form-item>
      <el-form-item prop="code" v-if="captchaEnabled">
        <el-input
          v-model="loginForm.code"
          size="large"
          auto-complete="off"
          placeholder="验证码"
          style="width: 63%"
          @keyup.enter="handleLogin"
        >
          <template #prefix><svg-icon icon-class="validCode" class="el-input__icon input-icon" /></template>
        </el-input>
        <div class="login-code">
          <img :src="codeUrl" @click="getCode" class="login-code-img"/>
        </div>
      </el-form-item>
      <el-checkbox v-model="loginForm.rememberMe" style="margin:0px 0px 25px 0px;">记住密码</el-checkbox>
      <el-form-item style="width:100%;">
        <el-button
          :loading="loading"
          size="large"
          type="primary"
          style="width:100%;"
          @click.prevent="handleLogin"
        >
          <span v-if="!loading">登录系统</span>
          <span v-else>登 录 中...</span>
        </el-button>
        <div style="float: right;" v-if="register">
          <router-link class="link-type" :to="'/register'">立即注册</router-link>
        </div>
      </el-form-item>
    </el-form>
    </section>
    <!--  底部  -->
    <div class="el-login-footer">
      <span>输电线路缺陷智能检测系统 · V1.2.0</span>
    </div>
  </div>
</template>

<script setup>
import { getCodeImg } from "@/api/login";
import Cookies from "js-cookie";
import { encrypt, decrypt } from "@/utils/jsencrypt";
import useUserStore from '@/store/modules/user'

const userStore = useUserStore()
const route = useRoute();
const router = useRouter();
const { proxy } = getCurrentInstance();

const loginForm = ref({
  username: "",
  password: "",
  rememberMe: false,
  code: "",
  uuid: ""
});

const loginRules = {
  username: [{ required: true, trigger: "blur", message: "请输入您的账号" }],
  password: [{ required: true, trigger: "blur", message: "请输入您的密码" }],
  code: [{ required: true, trigger: "change", message: "请输入验证码" }]
};

const codeUrl = ref("");
const loading = ref(false);
// 验证码开关
const captchaEnabled = ref(true);
// 注册开关
const register = ref(false);
const redirect = ref(undefined);

watch(route, (newRoute) => {
    redirect.value = newRoute.query && newRoute.query.redirect;
}, { immediate: true });

function handleLogin() {
  proxy.$refs.loginRef.validate(valid => {
    if (valid) {
      loading.value = true;
      // 勾选了需要记住密码设置在 cookie 中设置记住用户名和密码
      if (loginForm.value.rememberMe) {
        Cookies.set("username", loginForm.value.username, { expires: 30 });
        Cookies.set("password", encrypt(loginForm.value.password), { expires: 30 });
        Cookies.set("rememberMe", loginForm.value.rememberMe, { expires: 30 });
      } else {
        // 否则移除
        Cookies.remove("username");
        Cookies.remove("password");
        Cookies.remove("rememberMe");
      }
      // 调用action的登录方法
      userStore.login(loginForm.value).then(() => {
        const query = route.query;
        const otherQueryParams = Object.keys(query).reduce((acc, cur) => {
          if (cur !== "redirect") {
            acc[cur] = query[cur];
          }
          return acc;
        }, {});
        router.push({ path: redirect.value || "/", query: otherQueryParams });
      }).catch(() => {
        loading.value = false;
        // 重新获取验证码
        if (captchaEnabled.value) {
          getCode();
        }
      });
    }
  });
}

function getCode() {
  getCodeImg().then(res => {
    captchaEnabled.value = res.captchaEnabled === undefined ? true : res.captchaEnabled;
    register.value = res.registerEnabled === undefined ? false : res.registerEnabled;
    if (captchaEnabled.value) {
      codeUrl.value = "data:image/gif;base64," + res.img;
      loginForm.value.uuid = res.uuid;
    }
  });
}

function getCookie() {
  const username = Cookies.get("username");
  const password = Cookies.get("password");
  const rememberMe = Cookies.get("rememberMe");
  loginForm.value = {
    username: username === undefined ? loginForm.value.username : username,
    password: password === undefined ? loginForm.value.password : decrypt(password),
    rememberMe: rememberMe === undefined ? false : Boolean(rememberMe)
  };
}

getCode();
getCookie();
</script>

<style lang="scss" scoped>
.login { position: relative; display: grid; grid-template-columns: minmax(0, 1.15fr) minmax(440px, .85fr); min-height: 100vh; background: #f7f9fc; }
.login-visual { position: relative; overflow: hidden; min-height: 100vh; padding: 44px 9%; background: #0f2038; color: #fff; }
.login-visual::before { content: ''; position: absolute; inset: 0; background-image: linear-gradient(rgba(123,167,214,.035) 1px, transparent 1px), linear-gradient(90deg, rgba(123,167,214,.035) 1px, transparent 1px); background-size: 48px 48px; pointer-events: none; mask-image: linear-gradient(#000, transparent); }
.login-brand { position: relative; display: flex; align-items: center; gap: 12px; font-size: 16px; font-weight: 600; letter-spacing: .5px; img { width: 42px; height: 42px; } span { display: block; font-size: 9px; color: #7f9abd; letter-spacing: 1.8px; margin-top: 6px; } }
.visual-copy { position: relative; z-index: 1; margin-top: clamp(65px, 12vh, 150px); }
.visual-eyebrow { color: #7da9df; font-size: 10px; letter-spacing: 2.4px; font-weight: 500; }
h1 { font-size: clamp(34px, 3.7vw, 56px); line-height: 1.38; font-weight: 600; letter-spacing: 1px; margin: 20px 0; }
.heading-dot { color: #4d94f7; }
.visual-copy p { font-size: 14px; color: #97aecb; line-height: 1.95; margin: 0; }
.feature-labels { display: flex; gap: 18px; margin-top: 32px; color: #9eb7d7; font-size: 11px; span { display: flex; align-items: center; gap: 7px; } span::before { content: ''; width: 4px; height: 4px; background: #5e9ae4; border-radius: 50%; } }
.tower-illustration { position: absolute; left: -10%; width: 125%; bottom: 32px; pointer-events: none; opacity: .8; }
.visual-caption { position: absolute; bottom: 30px; left: 9%; right: 9%; font-size: 10px; letter-spacing: .5px; color: #6d87a9; }
.login-panel { display: flex; justify-content: center; align-items: center; padding: 60px 36px; }
.login-form { width: 100%; max-width: 380px; position: relative; z-index: 1; }
.form-eyebrow { font-size: 12px; color: #2563eb; font-weight: 500; }
.title { font-size: 29px; font-weight: 650; line-height: 1.5; color: #172b4d; margin: 10px 0 8px; text-align: left; letter-spacing: -.5px; }
.login-subtitle { font-size: 13px; color: #8090a7; margin: 0 0 36px; line-height: 1.7; }
.login-form :deep(.el-form-item__label) { font-size: 12px; color: #54657d; font-weight: 500; padding: 0; margin-bottom: 8px; }
.login-form :deep(.el-input__wrapper) { height: 46px; border-radius: 8px; background: #fff; box-shadow: 0 0 0 1px #dfe6ef inset; padding: 0 14px; }
.login-form :deep(.el-input__wrapper.is-focus) { box-shadow: 0 0 0 1px #3b82f6 inset, 0 0 0 3px #e5efff; }
.login-form :deep(.el-input__inner) { color: #172b4d; font-size: 13px; height: 46px; }
.login-form :deep(.el-input__inner::placeholder) { color: #a2afc0; }
.login-form :deep(.el-checkbox__label) { color: #738198; font-size: 12px; }
.login-form :deep(.el-button--primary) { height: 46px; border-radius: 8px; background: #2563eb; border-color: #2563eb; font-size: 14px; letter-spacing: 2px; box-shadow: 0 5px 14px rgba(37,99,235,.12); }
.login-form :deep(.el-button--primary:hover) { background: #1d4ed8; border-color: #1d4ed8; }
.input-icon { color: #8b9bb1; }
.login-code { width: 33%; height: 46px; margin-left: 4%; img { cursor: pointer; vertical-align: middle; height: 46px; width: 100%; border-radius: 8px; } }
.el-login-footer { position: absolute; bottom: 25px; right: 0; width: 42.5%; text-align: center; color: #94a0b2; font-size: 10px; letter-spacing: .5px; }
.mobile-brand { display: none; }
@media (min-height: 1000px) { .tower-illustration { bottom: 70px; } }
@media (max-width: 900px) { .login { display: flex; min-height: 100vh; justify-content: center; background: #f4f7fb; } .login-visual { display: none; } .login-panel { flex-direction: column; width: 100%; padding: 40px 26px 80px; } .mobile-brand { display: flex; align-items: center; gap: 10px; width: 100%; max-width: 380px; margin-bottom: 44px; color: #172b4d; font-size: 15px; font-weight: 600; img { width: 34px; height: 34px; } } .el-login-footer { width: 100%; } }
@media (max-height: 700px) and (min-width: 901px) { .visual-copy { margin-top: 60px; } .tower-illustration { bottom: -70px; opacity: .45; } .login-visual { padding-top: 32px; } }
</style>
