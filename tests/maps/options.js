const { node } = require('../utils');

module.exports = [
  {
    title: "keepParentheses: false (default)",
    tex: "(a+b)",
    struct: node.op('+', ['a', 'b']),
    parserOptions: { keepParentheses: false }
  },
  {
    title: "keepParentheses: true",
    tex: "(a+b)",
    struct: node.paren([
      node.op('+', ['a', 'b'])
    ]),
    parserOptions: { keepParentheses: true }
  },
  {
    title: "keepParentheses: true (nested)",
    tex: "((a+b))",
    struct: node.paren([
      node.paren([
        node.op('+', ['a', 'b'])
      ])
    ]),
    parserOptions: { keepParentheses: true }
  }
];
