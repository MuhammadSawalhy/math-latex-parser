const basic = require('./basic');
const functions = require('./functions');
const autoMult = require('./autoMult');
const memExpr = require('./memExpr');
const extra = require('./extra');
const operatorsPrecedence = require('./operatorsPrecedence');
const options = require('./options');

let tests = {
  basic,
  autoMult,
  functions,
  operatorsPrecedence,
  memExpr,
  extra,
  options,
};

module.exports = tests;
