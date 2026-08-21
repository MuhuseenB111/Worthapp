const appConfig = Object.freeze({
  name: "Worthapp",
  version: "1.0.0",
  environment: process.env.NODE_ENV || "development",

  server: Object.freeze({
    port: Number(process.env.PORT) || 3000
  }),

  security: Object.freeze({
    trustProxy: false,
    sendDetailedErrors: false
  }),

  privacy: Object.freeze({
    privacyFirst: true,
    userConsentRequired: true
  }),

  platform: Object.freeze({
    global: true,
    multilingual: true,
    aiEnabled: true
  })
});

export default appConfig;
