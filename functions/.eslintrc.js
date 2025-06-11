module.exports = {
  env: {
    node: true,
    es2021: true,
  },
  parserOptions: {
    ecmaVersion: 2021,
    sourceType: 'module',
  },
  extends: [
    'eslint:recommended'
  ],
  rules: {
    'no-console': 'off',
    'require-jsdoc': 'off',
    'max-len': ['warn', {code: 120}],
    'indent': ['error', 2],
    'quotes': ['error', 'single', {allowTemplateLiterals: true}],
    'arrow-parens': ['error', 'as-needed'],
    'object-curly-spacing': ['error', 'never'],

    // 추가: 상수 조건 무한 루프 허용
    'no-constant-condition': 'off',
    // 추가: 불필요한 이스케이프 경고 비활성화
    'no-useless-escape': 'off',
    // 기존 유용한 룰들
    'no-restricted-globals': ['error', 'name', 'length'],
    'prefer-arrow-callback': 'error',
  },
  overrides: [
    {
      files: ['**/*.spec.*'],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
