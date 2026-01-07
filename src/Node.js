
class Node {
  constructor(type, args, props) {
    Object.assign(this, props);

    if (Node.types.values.indexOf(type) === -1)
      throw new Error('invalid type for the node, "' + type + '"');

    else if (["operatorname", "function"].indexOf(type) > -1) {
      if (!args || !Array.isArray(args))
        throw new Error('invalid args for the node, "' + type + '"');
    }

    else if (type === "operator") {
      if (!props.operatorType)
        throw new Error(`operator should have operatorType as well.`);
      if (props.operatorType !== "infix" && props.operatorType !== "postfix" && props.operatorType !== "prefix")
        throw new Error(`invalid operatorType: ${props.operatorType}`);
      if (Node.types.operators[props.operatorType].indexOf(props.name) === -1)
        throw new Error(`invalid operator name: ${props.name}`);
    }

    this.type = type;
    this.args = args;
  }

  checkType(t) {
    if (Node.types.values.indexOf(t) > -1) {
      return this.type === t;
    } else {
      throw new Error("invalid type, can't check for \"" + t + '"');
    }
  }

  /**
   * check every property except args
   */
  check(props, checkArgs = false) {
    for (let p in props) {
      if (p === "type") {
        if (!this.checkType(props.type)) return false;
      }
      // always check args when checkArgs == true
      else if (checkArgs || p !== "args") {
        if (Array.isArray(props[p])) {
          if (!Array.isArray(props[p])) return false;
          else if (props[p].length !== this[p].length) return false;
          if (!this.check.bind(this[p])(props[p])) return false;
        }
        else if (this[p] instanceof Node) {
          if (!this[p].check(props[p])) return false;
        }
        else if (props[p] !== this[p]) return false;
      }
    }
    return true;
  }

  /**
   * Check if this node or any descendant matches the given props
   * @param props properties to check nodes against
   * @param checkArgs whether to also check args property
   * @returns {boolean} true if this node or any descendant matches
   */
  contains(props, checkArgs = false) {
    if (this.check(props, checkArgs))
      return true;
    if (this.args)
      for (let arg of this.args)
        if (arg.contains(props, checkArgs))
          return true;
    return false;
  }

}

Node.types = {

  NUMBER: 'number',
  ID: 'id',
  FUNCTION: 'function',
  MEMBER_EXPRESSION: 'member expression',

  OPERATOR: 'operator',
  AUTO_MULT: 'automult',
  BLOCK: 'block',

  FRAC: 'frac',
  PROD: 'prod',
  INT: 'int',
  SUM: 'sum',
  SQRT: 'sqrt',
  OPERATORNAME: 'operatorname',

  PARENTHESES: "parentheses",
  INTERVAL: "interval",
  MATRIX: "matrix",
  TUPLE: "tuple",
  SET: "set",
  ABS: "abs", // | value |
  ELLIPSIS: "ellipsis",

};

Node.types.values = Object.values(Node.types);

Node.types.operators = {
  infix: ["^", "*", "/", "+", "-", "=", "cdot"],
  postfix: ["!"],
  prefix: ["-", "+", "pm", "mp", "neg", "lnot"],
};

Node.types.blocks = [
  '()', '{}', '[]', '()', '{}', '[]', '||',
];

module.exports = Node;

