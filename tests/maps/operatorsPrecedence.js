const { node } = require("../utils");

module.exports = [

  // ----------------------------------
  //      operators precedence
  // ----------------------------------

  {
    title: "the sign in negative numbers should be considered as negative operator",
    tex: "-1",
    struct: node.preOP("-", [1]),
  },

  {
    title: "prefix operators have higher precedence",
    tex: "-a*b",
    struct: node.op("*", [node.preOP("-", ["a"]), "b"]),
  },

  {
    title: "automult is higher than the prefix operator",
    tex: "-ab",
    struct: node.preOP("-", [node.am(["a", "b"])])
  },


  {
    tex: "x^2!",
    struct: node.pOP("!", [node.op("^", ["x", 2])]),
  },

];