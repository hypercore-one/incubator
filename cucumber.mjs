const common = {
  paths: ["features/**/*.feature"],
  format: ["progress"],
};

export default common;

export const automated = {
  ...common,
  tags: "@automated",
};
