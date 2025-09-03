import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: "/incubator/",
  title: "HC1 Incubator",
  description: "HyperCore One Incubator",
  rewrites: {
    "README.md": "index.md",
    "(.*)/README.md": "(.*)/index.md",
  },
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: "Matrix", link: "https://matrix.to/#/#zenon-sigs:zenon.chat" },
      { text: "Forum", link: "https://forum.hypercore.one/" },
    ],

    sidebar: [
      {
        text: "Incubator",
        items: [{ text: "README", link: "/" }],
      },
    ],

    editLink: {
      pattern: "https://github.com/hypercore-one/incubator/edit/master/:path",
      text: "Edit this page on GitHub",
    },

    socialLinks: [
      { icon: "github", link: "https://github.com/hypercore-one/incubator" },
    ],
  },
});
