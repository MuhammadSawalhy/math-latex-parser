const fs = require('fs');
const path = require('path');
const pegjs = require('pegjs');
const rimraf = require('rimraf');

const pkg = require('./package.json');
const versionFilePath = './src/version.js';
const versionFileCode = `
// this file is auto generated
// the current version is:
module.exports = "${pkg.version}";
`;

fs.writeFileSync(path.resolve(__dirname, versionFilePath), versionFileCode);

const pegjsOptions = {
  output: 'source',
  format: 'commonjs'
};

const replacements = [
  {
    text: [
      'module.exports = {',
      '  SyntaxError: peg$SyntaxError,',
      '  parse:       peg$parse',
      '};'
    ].join('\n'),

    replacement: [
      'module.exports = {',
      '  SyntaxError: peg$SyntaxError,',
      '  parse:       peg$parse,',
      '  version,',
      '  Node',
      '};'
    ].join('\n')

  }
];

const grammarFiles = [
  {
    input: './src/tex.pegjs',
    output: './lib/index.js',
    dependencies: {
      Node: './Node.js',
      version: './version.js',
      prepareInput: './prepareInput.js',
      merge: "./merge.js",
    }
  }
];

grammarFiles.forEach(file => {
  pegjsOptions.dependencies = file.dependencies;
  const inputPath = path.resolve(__dirname, file.input);
  const inputDir = path.dirname(inputPath);
  const outputPath = path.resolve(__dirname, file.output);
  const outputDir = path.dirname(outputPath);

  if (outputDir !== inputDir) {
    prepareOutputDir(outputDir);
  }

  console.log('compiling>>>>>>>>>>>>>');
  console.log(inputPath);
  console.log();

  function getParserCode() {
    const grammar = fs.readFileSync(inputPath).toString('utf8');
    let code = pegjs.generate(grammar, pegjsOptions);

    /// some targeted replacments
    for (const r of replacements) {
      code = code.replace(r.text, r.replacement);
    }

    return code;
  }

  fs.writeFileSync(outputPath, getParserCode());

  if (outputDir !== inputDir) {
    // copy depedencies to the output directory
    for (const d of Object.values(file.dependencies)) {
      const p1 = path.resolve(inputDir, d);
      const p2 = path.resolve(outputDir, d);
      const dist = path.dirname(p2);

      if (!fs.existsSync(dist)) {
        fs.mkdirSync(dist, { recursive: true });
      }

      const readable = fs.createReadStream(p1, { encoding: 'utf-8' });
      const writable = fs.createWriteStream(p2);
      readable.pipe(writable);
    }
  }

  console.log('js code:::::::::');
  console.log(outputPath);
  console.log();
});

function prepareOutputDir(outputDir) {
  if (fs.existsSync(outputDir)) {
    /// delete all the output dir content
    rimraf.sync(path.resolve(outputDir, '*'));
  } else {
    fs.mkdirSync(outputDir, { recursive: true });
  }
}
