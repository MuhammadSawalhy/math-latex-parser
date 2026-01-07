# math-latex-parser

A powerful (La)TeX mathematical expression parser. Unlike simple string-based parsers, it generates a full Abstract Syntax Tree (AST) while respecting mathematical operator precedence and associativity.

## Install

```bash
npm i @scicave/math-latex-parser
```

## Usage

### Node.js / Bundlers

```js
const { parse } = require('@scicave/math-latex-parser');

// Basic arithmetic
const ast = parse('1 + 2 * 3^2');

// Complex LaTeX
const tex = String.raw`\int_{0}^{\pi} \sin(x) dx + \frac{1}{2}`;
const ast2 = parse(tex);
```

For an expression like `12+3^6x \frac 1 {5+3}`, the parser generates a structured tree:

![AST](./assets/AST.png)

### Browser

```html
<script src="https://cdn.jsdelivr.net/npm/@scicave/math-latex-parser/lib/bundle.min.js"></script>
<script>
  const ast = mathLatexParser.parse("x^2 + y^2 = r^2");
</script>
```

---

## Features

- **Arithmetic Operations**: Full support for addition, subtraction, multiplication, division, powers, and factorials.
- **Unary Prefix Operators**: Correct handling of `+`, `-`, `\pm`, `\mp`, `\neg`, and `\lnot`.
- **LaTeX Commands**: Supports `\frac`, `\sqrt`, `\sum`, `\prod`, `\int`, `\operatorname`, and more.
- **Automatic Multiplication**: Intelligently handles implicit multiplication like `2x` or `(a+b)(c+d)`.
- **Extended Math Structures**: Support for:
  - **Matrices**: `\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}`
  - **Sets**: `\{ 1, 2, 3 \}`
  - **Tuples**: `(1, 2, 3)`
  - **Intervals**: `[a, b)`, `(0, \infty)`
  - **Absolute Value**: `|x|` or `\left| x \right|`
- **Ellipsis**: Support for `...`, `\dots`, `\cdots`, etc. inside sets, matrices, and series.

---

## Operator Precedence

| Operator                                   | Type       | Precedence | Associativity |
| :----------------------------------------- | :--------- | :--------- | :------------ |
| `^`                                        | Infix      | 7          | Left-to-Right |
| `!`                                        | Postfix    | 6          | N/A           |
| Implicit Mult                              | Automult   | 5          | Left-to-Right |
| `+`, `-`, `\pm`, `\mp`, `\neg`, `\lnot`    | **Prefix** | 4          | N/A           |
| `*`, `/`, `\cdot`                          | Infix      | 3          | Left-to-Right |
| `+`, `-`                                   | Infix      | 2          | Left-to-Right |
| `=`, `\neq`, `\approx`, `\le`, `\in`, etc. | Infix      | 1          | Left-to-Right |

---

## Parser Options

The `parse(tex, options)` function accepts an optional configuration object.

```js
parse("...", {
  autoMult: true,           // Allow implicit multiplication like 2x
  keepParentheses: false,    // If true, wraps parenthesized expressions in a "parentheses" node
  functions: ["f", "g"],    // Custom function names to prioritize
  builtinFunctions: ["..."], // Override or extend (using "...") default TeX functions
  builtinLetters: ["..."],   // Override or extend (using "...") default TeX Greek letters
  extra: {
    memberExpressions: true, // Allow e.g., p.x
    sets: true,
    matrices: true,
    tuples: true,
    intervals: true,
    ellipsis: true           // Can be object for granular control (sets, matrices, etc.)
  }
});
```

---

## API: The `Node` Class

Every parsed node is an instance of the `Node` class.

### Properties
- `node.type`: The type of the node (e.g., `"number"`, `"id"`, `"operator"`, `"function"`).
- `node.args`: An array of child nodes (if any).
- `node.name`: For identifiers, functions, and operators.
- `node.value`: For numbers.

### Methods

#### `node.check(props, checkArgs = false)`
Checks if the node matches the provided properties.
```js
node.check({ type: "operator", name: "+" });
```

#### `node.contains(props, checkArgs = false)`
Recursively checks if the node or any of its descendants match the properties. This is the recommended way to search the tree.
```js
// Check if an expression contains any variable named "x"
ast.contains({ type: "id", name: "x" });

// Check if there is any addition anywhere in the tree
ast.contains({ type: "operator", name: "+" });
```

#### `node.checkType(type)`
Syntactic sugar for `node.type === type`, but with safety. It will throw an error if the `type` string provided is not one of the valid [Node types](#nodetypes).
```js
node.checkType("operator"); // true or false
node.checkType("invalid_type"); // Throws Error
```

### Node Types

The available types are accessible via `Node.types`:
- `Node.types.NUMBER` (`"number"`)
- `Node.types.ID` (`"id"`)
- `Node.types.OPERATOR` (`"operator"`)
- `Node.types.FUNCTION` (`"function"`)
- `Node.types.FRAC` (`"frac"`)
- ... and more.

---

## Contribute

We love open-source! Feel free to suggest AST improvements or performance enhancements.

```bash
npm install
npm run build:watch   # Watch and build
npm run test:watch    # Run tests on changes
```

## License

MIT
