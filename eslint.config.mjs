// @ts-check
import withNuxt from "./.nuxt/eslint.config.mjs";
import prettierPlugin from "eslint-plugin-prettier";
import eslintConfigPrettier from "eslint-config-prettier";
import { globalIgnores } from "eslint/config";

export default withNuxt(
  {
    plugins: {
      prettier: prettierPlugin,
    },
    rules: {
      "prettier/prettier": [
        "error",
        {
          endOfLine: "auto",
        },
      ],
    },
  },
  eslintConfigPrettier,
  globalIgnores([
    ".gitignore",
    ".husky/",
    ".git/",
    ".prettierignore",
    ".prettierrc",
  ]),
);
