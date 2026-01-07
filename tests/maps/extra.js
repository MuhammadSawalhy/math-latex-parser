const { node } = require("../utils");

module.exports = [

  // ----------------------------------
  //              sets
  // ----------------------------------

  {
    title: "should parse: simple set",
    tex: "\\{1, 2, 3\\}",
    struct: node.set([1, 2, 3]),
  },

  {
    title: "should parse: set with single element",
    tex: "\\{x\\}",
    struct: node.set(["x"]),
  },

  {
    title: "should parse: set with expressions",
    tex: "\\{a+b, c*d\\}",
    struct: node.set([node.op("+", ["a", "b"]), node.op("*", ["c", "d"])]),
  },

  // ----------------------------------
  //             tuples
  // ----------------------------------

  {
    title: "should parse: simple tuple",
    tex: "(1, 2, 3)",
    struct: node.tuple([1, 2, 3]),
  },

  {
    title: "should parse: tuple with variables",
    tex: "(a, b, c)",
    struct: node.tuple(["a", "b", "c"]),
  },

  // ----------------------------------
  //            intervals
  // ----------------------------------

  {
    title: "should parse: closed interval",
    tex: "[1, 2]",
    struct: node.interval([1, 2], { startInclusive: true, endInclusive: true }),
  },

  {
    title: "should parse: open interval",
    tex: "(1, 2)",
    struct: node.interval([1, 2], { startInclusive: false, endInclusive: false }),
  },

  // ----------------------------------
  //              abs
  // ----------------------------------

  {
    title: "should parse: absolute value",
    tex: "\\left|x\\right|",
    struct: node.abs(["x"]),
  },

  {
    title: "should parse: absolute value with expression",
    tex: "\\left|a+b\\right|",
    struct: node.abs([node.op("+", ["a", "b"])]),
  },

  {
    title: "should parse: absolute value with prefix",
    tex: "\\left|-x\\right|",
    struct: node.abs([node.preOP("-", ["x"])]),
  },

  // ----------------------------------
  //            matrices
  // ----------------------------------

  {
    tex: "\\begin{matrix}",
    error: true, errorType: "syntax"
  },

  {
    tex: "\\begin{matrix} 1 & 2 \\\\ a & b \\end{matrix}",
    parserOptions: { extra: { matrices: false } },
    error: true, errorType: "syntax"
  },

  {
    tex: "\\begin{asdmatrix} 1 & 2 \\\\ a & b \\end{asdmatrix}",
    error: true, errorType: "syntax"
  },

  {
    title: "should throw: different matrix type",
    tex: "\\begin{pmatrix} 1 & 2 \\\\ a & b \\end{bmatrix}",
    error: true, errorType: "syntax"
  },

  {
    tex: "\\begin{matrix} 1 & 2 \\\\ a & b \\end{matrix}",
    struct: node.matrix([[1, 2], ["a", "b"]], { type: "matrix" })
  },

  {
    Title: "should parse: nested matrices",
    tex: String.raw`
      \begin{pmatrix}
        \begin{matrix}
          1 & 2 \\
          a & b
        \end{matrix} & 2 \\
        a & b
      \end{pmatrix}
    `,
    struct: node.matrix([
      [
        node.matrix([
          [1, 2], ["a", "b"]
        ], { matrixType: "matrix" }),
        2
      ],
      ["a", "b"]
    ], { matrixType: "pmatrix" })
  },

  // ----------------------------------
  //            ellipsis
  // ----------------------------------

];