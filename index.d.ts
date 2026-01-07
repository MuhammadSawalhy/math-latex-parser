export class Node {
  type: string;
  args: any[];
  name?: string;
  value?: number;
  operatorType?: 'infix' | 'postfix' | 'prefix';
  isBuiltin?: boolean;
  match?: {
    location: any;
    text: string;
  };

  constructor(type: string, args: any[], props?: any);

  checkType(t: string): boolean;
  check(props: any, checkArgs?: boolean): boolean;
  contains(props: any, checkArgs?: boolean): boolean;

  static types: {
    NUMBER: 'number';
    ID: 'id';
    FUNCTION: 'function';
    MEMBER_EXPRESSION: 'member expression';
    OPERATOR: 'operator';
    AUTO_MULT: 'automult';
    BLOCK: 'block';
    FRAC: 'frac';
    PROD: 'prod';
    INT: 'int';
    SUM: 'sum';
    SQRT: 'sqrt';
    OPERATORNAME: 'operatorname';
    PARENTHESES: 'parentheses';
    INTERVAL: 'interval';
    MATRIX: 'matrix';
    TUPLE: 'tuple';
    SET: 'set';
    ABS: 'abs';
    ELLIPSIS: 'ellipsis';
    values: string[];
    operators: {
      infix: ["^", "*", "/", "+", "-", "=", "cdot"];
      postfix: ["!"];
      prefix: ["-", "+", "pm", "mp", "neg", "lnot"];
    };
    blocks: [
      '()', '{}', '[]', '()', '{}', '[]', '||',
    ];
  };
}

export interface ParserOptions {
  autoMult?: boolean;
  keepParentheses?: boolean;
  functions?: string[];
  builtinFunctions?: string[];
  builtinLetters?: string[];
  extra?: {
    memberExpressions?: boolean;
    sets?: boolean;
    matrices?: boolean;
    tuples?: boolean;
    intervals?: boolean;
    ellipsis?: boolean | {
      funcArgs?: boolean;
      sets?: boolean;
      matrices?: boolean;
      tuples?: boolean;
      infixOperators?: boolean;
    };
  };
}

export function parse(tex: string, options?: ParserOptions): Node;

export class SyntaxError extends Error {
  expected: any[];
  found: string | null;
  location: any;
  static buildMessage(expected: any[], found: string | null): string;
}

export const version: string;
