var fs = require('fs');
var args = process.argv.splice(2);
var js_beautify = require('/usr/local/lib/node_modules/js-beautify/js/index.js');
var options = args[1] || '{}';
var options = JSON.parse(args[1] || '{}');
try {
  var homeDirOptions = process.env.HOME + '/.jsbeautifyrc';
  options = JSON.parse(fs.readFileSync(homeDirOptions));
} catch (e) {
  /* Fall back to default behavior */
}
var input = fs.readFileSync('/dev/stdin').toString();
var result = (js_beautify(input, options));
console.log(result);
