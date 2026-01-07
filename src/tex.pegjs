// TODO: parse comments such as % for commenting line
// TODO: Parse MemberExpression
// TODO: sets, { 1,2, ...,3 }
// TODO: tuples, ( 1,2, , , ...,3 )
// TODO: intervals, [1, 2)
// TODO: matrices, \begin{bmatrix} 1 & 2 & 3 \end{bmatrix}
// TODO: IDs decoration: `\vec{F}`,`\dot{a}`
// TODO: IDs decoration: `\vec{F}`,`\dot{a}`
// TODO: 3 dots: `1 + ... + 4` or => `1 + \sdot\sdot\sdot + 4`
/**
 * Pegjs rules of the major significant parts of the exression are __PascalCased__
 * The helper rules are __camelCased__
 */

{
  {
    let defaultLetters = [
      "alpha", "Alpha", "beta", "Beta", "gamma",
      "Gamma", "pi", "Pi", "varpi", "phi", "Phi",
      "varphi", "mu", "theta", "vartheta", "epsilon",
      "varepsilon", "upsilon", "Upsilon", "zeta", "eta",
      "Lambda", "lambda", "kappa","omega", "Omega",
      "psi", "Psi", "chi", "tau", "sigma", "Sigma",
      "varsigma", "rho", "varrho", "Xi", "xi", "nu",
      "imath", "jmath", "ell", "Re", "Im", "wp", "Nabla",
      "infty", "aleph", "beth", "gimel", "comicron", "iota",
      "delta", "thetasym", "omicron", "Delta", "Epsilon",
      "Zeta", "Eta", "Theta", "Iota", "Kappa", "Mu", "Nu",
      "Omicron", "Rho", "Tau", "Chi", "infty", "infin", "nabla",
      "mho", "mathsterling", "surd", "diamonds", "Diamond",
      "hearts", "heartsuit", "spades", "spadesuit", "clubsuit",
      "clubs", "bigstar", "star", "blacklozenge", "lozenge",
      "sharp", "maltese", "blacksquare", "square", "triangle",
      "blacktriangle"
    ];

    // default builtin functions
    let defaultBIFs = [
      "sinh", "cosh", "tanh",
      "sin", "cos", "tan", "sec", "csc", "cot",
      "arcsin", "arccos", "arctan", "arcsec", "arccsc", "arccot",
      "ln"
    ];

    // don't import defaults from a module, because we should clone it deeply
    // so let's create new defaults object every time parse is invoked
    let defaultOptions = {
      // singleCharName: true, // obselete
      /* operatorNames: // this is for something like this: \operatorname{floor} */
      /*   [ */
      /*     "floor", "ceil", "round", "random", "factorial", */
      /*     "sech", "csch", "coth", "abs", "arsinh", "arcosh", */
      /*     "artanh", "arasinh", "aracosh", "aratanh", */
      /*   ], */
      autoMult: true,
      functions: [],
      keepParentheses: false,
      builtinLetters: defaultLetters,
      builtinFunctions: defaultBIFs,
      extra: {
        memberExpressions: true,
        sets: true,
        matrices: true,
        tuples: true,
        intervals: true,
        ellipsis: {
          funcArgs: true,
          sets: true,
          matrices: true,
          tuples: true,
          infixOperators: true
        }
      }
    };

    options = merge(defaultOptions, options); /// override the default options

    if (options.builtinFunctions[0] === '...')
      // replace the three dots with the default things.
      options.builtinFunctions.splice(0, 1, ...defaultBIFs);

    if (options.builtinLetters[0] === '...')
      // replace the three dots with the default things.
      options.builtinLetters.splice(0, 1, ...defaultLetters);
  }

  let rawInput = input,
      // does commaExpression contains ellipsis
      // it has to be LIFO stack, push and pop
      doesContainEllipsis = [];

  // they are static, shouldn't be controlled by options
  let texOperators1 = [
    "neq", "approx", "eqsim", "simeq",
    "ge", "geq", "geqq", "geqslant", "gg", "ggg", "gggtr",
    "le", "leq", "leqq", "leqslant", "ll", "lll", "llless",
    "notin", "ni", "in", "isin"
  ];

  let texPrefixOperators1 = [
    "pm", "mp", "neg", "lnot"
  ];

  /* .forEach(n=> console.log(`    <tr>\n      <td><code>\\${n}</code></td>\n    </tr>`)) */

  text = function() {
    return rawInput.substring(peg$savedPos, peg$currPos);
  }

  input = prepareInput(input, peg$computeLocation, error);

  function createNode(...args){
    let n = new Node(...args);
    let ellipsis = options.extra.ellipsis;
    let __doesContainEllipsis = doesContainEllipsis.length && doesContainEllipsis.pop();
    if(!options.autoMult && n.type === "automult")
      error('invalid syntax, hint: missing * sign');
    if (n.type === "member expression" && !options.extra.memberExpressions)
      error(`tuples syntax is not allowed`);
    if (n.type === "tuple") {
      if (!options.extra.tuples)
        error('tuples syntax is not allowed');
      let ellipsisAllowed = typeof ellipsis === 'object' ? ellipsis.tuples : ellipsis;
      if (__doesContainEllipsis && !ellipsisAllowed)
        error('ellipsis is not allowed to be in tuples');
    }
    if (n.type === "set") {
      if (!options.extra.sets)
        error('sets syntax is not allowed');
      let ellipsisAllowed = typeof ellipsis === 'object' ? ellipsis.sets : ellipsis;
      if (__doesContainEllipsis && !ellipsisAllowed)
        error('ellipsis is not allowed to be in sets');
    }
    if (n.type === "matrix") {
      if (!options.extra.matrices)
        error('matrices syntax is not allowed');
      let ellipsisAllowed = typeof ellipsis === 'object' ? ellipsis.matrices : ellipsis;
      if (__doesContainEllipsis && !ellipsisAllowed)
        error('ellipsis is not allowed to be in matrices');
    }
    if (n.type === "interval") {
      if (!options.extra.intervals)
        error('intervals syntax is not allowed');
      let ellipsisAllowed = typeof ellipsis === 'object' ? ellipsis.intervals : ellipsis;
      if (__doesContainEllipsis && !ellipsisAllowed)
        error('ellipsis is not allowed to be in intervals');
    }
    n.match = {
      location: location(),
      text: text(),
    }
    return n;
  }

  function check(value, rule) {
    if (rule instanceof Array) {
      for (let i=0; i<rule.length; i++) {
        if (check(value, rule[i])) return true;
      }
    } else if (rule instanceof Function) {
      return rule(value);
    } else if (rule instanceof RegExp) {
      return rule.test(value);
    } else {
      return value === rule;
    }
  }

  function handleBlock(node, o, c) {

    // node is expr or 1d array or 2d array
    // validation, [), (], {}, [], () are allowed
    if (
      o === '{' && c !== "}" ||
      o !== '{' && c === "}"
    )
      error(`unexpected brackets: "${o} and "${c}"`);

    // now node is 1d array or expr

    // sets
    if (o === "{") { // c is "}"
      // set with one item
      return createNode("set", Array.isArray(node) ? node: [node]);
    }

    // tuple or interval or set
    if (Array.isArray(node)) {
      if (node.length === 2 && options.extra.intervals) {
        // make sure not have ellpsis
        if (node[0].type !== "ellipsis" && node[1].type !== "ellipsis")
          return createNode("interval", node, { startInclusive: o==="[", endInclusive: c==="]" });
      }
      if (o === "[" || c === "]")
        // all possible expressions for "[]" are consumed here
        error(`unexpected brackets: "${o} and "${c}"`);
      if (node.length === 2 && !options.extra.tuples)
        // we may not throw here, it will throw inside createNode
        // but this message is more informative
        return error("neither tuples nor intervals are allowed");
      return createNode("tuple", node);
    }

    // -----------| now node is expr |-----------
    // all possible expressions for "[]" are consumed here

    // extra validation, we are now dealing with "()"
    if (o === "[" || c === "]")
      error(`unexpected brackets: "${o} and "${c}"`);

    return options.keepParentheses
      ? createNode("parentheses", [node])
      : node;

  }
}

Expression "expression" = _ expr:EquationsAndInequalities _ { return expr; }

EquationsAndInequalities =
  head:AdditionAndSubtraction tail:(_ ("=" / "\\" a:TexOperatorsTitles { return a }) _ AdditionAndSubtraction)* _ {
    return tail.reduce(function(result, element) {
      return createNode("operator" , [result, element[3]], { name: element[1], operatorType: 'infix' });
    }, head);
  }

TexOperatorsTitles =
  w:Word
  &{ return check(w, texOperators1) }
  { return w }

TexPrefixOperatorsTitles =
  w:Word
  &{ return check(w, texPrefixOperators1) }
  { return w }

AdditionAndSubtraction =
  head:MultiplicationAndDivision tail:(_ ("+" / "-") _ MultiplicationAndDivision)* {
    return tail.reduce(function(result, element) {
      return createNode("operator" , [result, element[3]], { name: element[1], operatorType: 'infix' });
    }, head);
  }

MultiplicationAndDivision =
  head:UnaryPrefixOperation tail:(_ ("*" / "/" / "\\cdot" !Letter { return "cdot"; }) _ UnaryPrefixOperation)* {
    return tail.reduce(function(result, element) {
      return createNode("operator" , [result, element[3]], { name: element[1], operatorType: 'infix' });
    }, head);
  }

UnaryPrefixOperation =
  sign:("-" / "+" / "\\" name:TexPrefixOperatorsTitles { return name }) _ operand:UnaryPrefixOperation {
    return createNode("operator", [operand], { name: sign, operatorType: 'prefix' });
  } / ImplicitMultiplication

ImplicitMultiplication =
  head:(PowerAndFactorial) tail:(_ PowerAndFactorialWithoutNumber)* {
    return tail.reduce(function(result, element) {
      return createNode("automult" , [result, element[1]]);
    }, head);
  }

PowerAndFactorial =
  base:Factor _ exp:SuperScript? _ fac:"!"? {
    if (exp) base = new Node("operator", [base, exp], { name: '^', operatorType: 'infix' });
    if (fac) base = new Node("operator", [base], { name: '!', operatorType: 'postfix' });
    return base;
  }

PowerAndFactorialWithoutNumber =
  base:FactorNotNumber _ exp:SuperScript? _ fac:"!"? {
    if (exp) base = new Node("operator", [base, exp], { name: '^', operatorType: 'infix' });
    if (fac) base = new Node("operator", [base], { name: '!', operatorType: 'postfix' });
    return base;
  }

Factor
  = FactorNotNumber / Number

FactorNotNumber =
  // member expression may be a name or a function
  MemberExpression /
  TupleOrExprOrParenOrIntervalOrSet /
  Matrix/ Block_VBars / TexEntities

Block_VBars =
  ("\\big"/ "\\Big"/ "\\bigg"/ "\\Bigg"/ "\\left") _ "|"
  e:Expression
  ("\\big"/ "\\Big"/ "\\bigg"/ "\\Bigg"/ "\\right") _ "|"
  {
    return createNode("abs", [e]);
  }

// -----------------------------------
//            functions
// -----------------------------------

Functions "functions" =
  BuiltinFunctions / Operatorname / Function

BuiltinFunctions "builtin functions" =
  "\\" name:BuiltinFuncsTitles
  _ exp:SuperScript? _ args:BuiltinFunctionsArgs
  {
    if (!Array.isArray(args)) args = [args];
    let func = new Node('function', args, {name, isBuiltin:true});
    if(!exp) return func;
    else return createNode("operator", [func, exp], { name: '^', operatorType: 'infix' });
  }

BuiltinFuncsTitles =
  name:Word
  &{ return check(name, options.builtinFunctions) }
  {
    return name;
  }

BuiltinFunctionsArgs = FunctionParentheses / ImplicitMultiplication

Operatorname =
  "\\operatorname"
  name:(
    _ "{" _ name:(Name/SpecialSymbols) _ "}" { return name } /
    Whitespace+ name:(Name/SpecialSymbols) { return name }
  ) _ args:FunctionParentheses
  {
    return createNode("operatorname", args, { name });
  }

Function =
  name:$Name
  &{ return check(name, options.functions) } _
  args:FunctionParentheses
  { return createNode('function', args, { name }); }

FunctionParentheses =
  &{ doesContainEllipsis.push(false); return true }
  // open parenthese
  ("\\big"/ "\\Big"/ "\\bigg"/ "\\Bigg"/ "\\left")? _ "("
  // function actual args
  a:CommaExpression // there is spaces around it, not need for _
  // close parenthese
  ("\\big"/ "\\Big"/ "\\bigg"/ "\\Bigg"/ "\\right")? _ ")"
  {
    let __doesContainEllipsis = doesContainEllipsis.pop();
    let ellipsis = options.extra.ellipsis;
    let ellipsisAllowed = typeof ellipsis === 'object' ? ellipsis.funcArgs : ellipsis;
    if (__doesContainEllipsis && !ellipsisAllowed)
      error('ellipsis is not allowed to be an arg in a function');
    return Array.isArray(a) ? a : [a];
  }
  /
  // fallback when the previous grammar doesn't match
  &{ doesContainEllipsis.pop(); return true }
  "(" _ ")" { return [] };

// there is spaces around expressions already no need for _ rule
CommaExpression =
  head:(Expression / CommaExpressionEllipsis)
  tail:("," a:(Expression / CommaExpressionEllipsis) { return a })*
  {
    if (tail.length) {
      tail.unshift(head);
      return tail;
    }
    if (head.type === 'ellipsis')
      error("can't use ellipsis as a stand-alone expression");
    return head;
  }

// put spaces around '...' here, use it directly there
Ellipsis =
  _ type:("..." / "\\" t:DotsRule { return t }) _
  { return createNode("ellipsis", null, { type }) }

// put spaces around '...' here, use it directly there
HorizontalEllipsis =
  _ type:("..." / "\\" t:("dots" / "cdots") { return t }) _
  { return createNode("ellipsis", null, { type }) }

DotsRule = "dots" / "vdots" / "ddots" / "cdots"

CommaExpressionEllipsis = e:Ellipsis {
  doesContainEllipsis[doesContainEllipsis.length - 1] = true;
  return e;
}

// -----------------------------------
//        brackets expression
// -----------------------------------

TupleOrExprOrParenOrIntervalOrSet =
  o:BlockOpenings
  // reset then continue
  &{ doesContainEllipsis.push(false); return true }
  arr1dOrExpr:CommaExpression
  c:BlockClosings
  {
    return handleBlock(arr1dOrExpr, o, c);
  }
  // fallback action, pop the last item
  / &{ doesContainEllipsis.pop(); return false } "a"

BlockOpenings =
  leftPrefixes? _
  a:("(" / "[" / "{" / "\\{{" / "\\{")
  { return a.length > 1 ? a[1] : a; }

BlockClosings =
  rightPrefixes? _
  a:(")" / "]" / "}" / "\\}}" / "\\}")
  { return a.length > 1 ? a[1] : a; }

// -----------------------------------
//        backslash backslash
// -----------------------------------

TexEntities =
    SpecialTexRules / SpecialSymbols

SpecialSymbols = "\\" name:SpecialSymbolsTitles !Letter {
  return createNode('id', null, { name: name, isBuiltin:true })
}

/// this may be operator, if so, don't consider as specialSymbol
SpecialSymbolsTitles =
  // no need to !AnyThingElse such as dots ("ddots", "dots", "cdots", ...)
  // because this is the last checked Factor
  !(TexOperatorsTitles !Letter)
  !(leftPrefixes !Letter)
  name:Word &{
    return !check(name, [
      "begin", "end", "right" /* for rightPrefixes */,
      "cdot", "operatorname"
    ])
  } {
    if(check(name, options.builtinLetters)) return name;
    if (check(name, [
        options.builtinFunctions,
        options.functions,
        ['sqrt', 'int', 'sum', 'prod']
    ])) {
      error(`"${name}" is used with no arguments arguments! it can't be used as variable!`);
    }
    error('undefined control sequence "' + name + '"');
  }

SpecialTexRules = Sqrt / IntSumProd / Frac

Sqrt =
  "\\sqrt" !Letter _
  exp:SquareBrackets? _
  arg:Arg
  {
    // exp = exp || createNode("number", null, {value:2});
    return exp ? createNode("sqrt", [arg, exp]) : createNode("sqrt", [arg]);
  }

IntSumProd = "\\" n:("int" / "sum" / "prod") !Letter _
        subsup:(
          &(_ "_") sub:SubScript? _ sup:SuperScript? { return [sub, sup]; } /
          sup:SuperScript? _ sub:SubScript? { return [sub, sup]; }
        ) _ arg:EquationsAndInequalities
  {
    subsup.push(arg);
    return createNode(n, subsup);
  }
Frac = "\\frac" !Letter _
  args:(first:Arg _ second:Arg { return [first, second]; })
  { return createNode("frac", args); }

OneCharArg "digit or char" = Alphanumeric {
    let txt = text();
    if(isNaN(txt)){
      return createNode("id", null, { name: txt });
    } else {
      return createNode("number", null, {value:parseFloat(txt)});
    }
  } / SpecialSymbols;

// -----------------------------------
//           matrices
// -----------------------------------

Matrix =
  "\\begin" _ "{" _ t1:Word _ "}" _
  rows:MatrixRows _
  "\\end" _ "{" t2:Word "}"
  {
    if(t1 !== t2)
      error(`different titles: \\begin{${t1}} and \\end{${t2}}`);
    if (!check(t1, [
      "matrix", "pmatrix", "bmatrix",
      "Bmatrix", "smallmatrix", "Bmatrix",
      "vmatrix", "Vmatrix"
    ]))
      error(`invalid matrix type: ${t1}`);
    return createNode("matrix", rows, { matrixType: t1 });
  }

MatrixRows =
  head:MatrixRow tail:(_ "\\\\" _ MatrixRow)* {
    tail = tail.map(n=>n[3])
    tail.unshift(head);
    return tail;
  }

MatrixRow =
  head:EquationsAndInequalities tail:(_ "&" _ EquationsAndInequalities)* {
    tail = tail.map(n=>n[3])
    tail.unshift(head);
    return tail;
  }


// -----------------------------------
//         member expressions
// -----------------------------------

MemberExpression =
  // left to right
  head:(MemberArg / TupleOrExprOrParenOrIntervalOrSet) tail:(_ "."  _ MemberArg)* {
    // reduce from left to right, ltr
    return tail.reduce(function(result, element) {
      return createNode("member expression" , [result, element[3]]);
    }, head);
  }

// not member expression
MemberArg = Functions / Name

// -----------------------------------
//             names
// -----------------------------------

Name "name" =
  name:Letter sub:SubName?
  {
    let n = createNode('id', null, {name})
    if (sub) n.sub = sub;
    return n;
  }

SubName =
  _ "_" _ w:Alphanumeric { return createNode("id", null, { name: w }) } /
  _ "_" _ "{" _ n:Name _ "}" { return n }

Alphanumeric "letter or number"  = [a-zA-Z0-9]

Letter "letter"  = [a-zA-Z]

Word = [a-zA-Z]+ { return text() }

// -----------------------------------
//             numbers
// -----------------------------------

Number "number"
  = sign:Sign? _ $SimpleNumber {
    let value = parseFloat(text().replace(/[ \t\n\r]/g, ''));
    return createNode('number', null, {value});
  }

SimpleNumber "number"
  = (num:[0-9]([0-9]/Whitespace)* DecimalPart? / DecimalPart)

DecimalPart
  = "." _ [0-9]([0-9]/Whitespace)*

Sign
  = '-' / '+'

// -----------------------------------
//              atoms
// -----------------------------------

SquareBrackets = "[" _ expr:EquationsAndInequalities "]" { return expr; }
CurlyBrackets = "{" _ expr:EquationsAndInequalities "}" { return expr; }

SuperScript "superscript" = "^" _ arg:(Arg) {return arg;}
SubScript "subscript" = "_" _ arg:(Arg) {return arg;}

Arg "function argument" = CurlyBrackets / Frac / SpecialSymbols / OneCharArg

leftPrefixes = ("\\left" / "\\Big" / "\\Bigg" / "\\big" / "\\bigg")
rightPrefixes = ("\\right" / "\\Big" / "\\Bigg" / "\\big" / "\\bigg")

// -----------------------------------
//            primitives
// -----------------------------------

Newline "newline"         = "\n" / "\r\n"
Space "space or tab"      = " "  / "\t"
EscapedSpace              = "\\ "
Whitespace "whitespace"   = Newline / Space / EscapedSpace
_ "optional whitespace"   = Whitespace*
