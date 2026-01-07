const { node } = require('../utils');

module.exports = [
  {
    tex: "1+2",
    struct: node.op('+', [1, 2]),
  },

  {
    tex: "1*2!-5^3",
    struct: node.op('-', [
      node.op('*', [1, node.pOP('!', [2])]),
      node.op("^", [5, 3]),
    ]),
  },

  {
    tex: "- .123*  \n2!+-5.1^.3",
    error: true, // it should be ^{.3} not ^.3
  },

  {
    tex: "- .123*  \n2!+-5.1^{.3} \\cdot\\frac{x}2!",
    struct: node.op('+', [
      node.op("*", [
        node.preOP("-", [0.123]),
        node.pOP('!', [2])
      ]),
      node.op("cdot", [
        node.preOP("-", [node.op("^", [5.1, 0.3])]),
        node.pOP("!", [node.frac(["x", 2])])
      ])
    ]),
  },

  {
    tex: `\\sum _ 1 ^\nx -5.6a+ b`,
    struct: node.sum([1, 'x',
      node.op('+', [node.preOP('-', [node.am([5.6, 'a'])]), 'b'])
    ]),
  },

  {
    tex: `\\sum ^\t   x _ 1 -5.6a+ b`,
    struct: node.sum([1, 'x',
      node.op('+', [node.preOP('-', [node.am([5.6, 'a'])]), 'b'])
    ]),
  },

  // ----------------------------------
  //         prefix operators
  // ----------------------------------

  {
    title: "should parse: prefix unary minus",
    tex: "-x",
    struct: node.preOP("-", ["x"]),
  },

  {
    title: "should parse: prefix unary plus",
    tex: "+x",
    struct: node.preOP("+", ["x"]),
  },

  {
    title: "should parse: prefix minus on parenthesized expression",
    tex: "-(a+b)",
    struct: node.preOP("-", [node.op("+", ["a", "b"])]),
  },

  {
    title: "should parse: prefix minus with multiplication",
    tex: "-x*y",
    struct: node.op("*", [node.preOP("-", ["x"]), "y"]),
  },

  {
    title: "should parse: addition with prefix minus",
    tex: "a+-b",
    struct: node.op("+", ["a", node.preOP("-", ["b"])]),
  },

  {
    title: "should parse: prefix in parentheses then multiply",
    tex: "(-x)*y",
    struct: node.op("*", [node.preOP("-", ["x"]), "y"]),
  },

  {
    title: "should parse: double prefix in parentheses",
    tex: "-(-x)",
    struct: node.preOP("-", [node.preOP("-", ["x"])]),
  },
  {
    title: "should parse: double prefix",
    tex: "--x",
    struct: node.preOP("-", [node.preOP("-", ["x"])]),
  },
];

