// Generated by CoffeeScript 1.8.0
(function() {
  var R, doctest, failures, keys, options, program, validators;

  program = require('commander');

  R = require('ramda');

  doctest = require('../lib/doctest');

  program.version(doctest.version).usage('[options] path/to/js/or/coffee/module').option('-m, --module <type>', 'specify module system ("amd" or "commonjs")').option('    --nodejs', 'pass options directly to the "node" binary').option('-p, --print', 'output the rewritten source without running tests').option('-s, --silent', 'suppress output').option('-t, --type <type>', 'specify file type ("coffee" or "js")').parse(process.argv);

  validators = {
    module: R.contains(R.__, [void 0, 'amd', 'commonjs']),
    print: R.always(true),
    silent: R.always(true),
    type: R.contains(R.__, [void 0, 'coffee', 'js'])
  };

  keys = R.keys(validators).sort();

  options = R.pick(keys, program);

  keys.forEach(function(key) {
    if (!validators[key](options[key])) {
      process.stderr.write("\n  error: invalid " + key + " `" + options[key] + "'\n\n");
      return process.exit(1);
    }
  });

  failures = R.reduce(function(failures, path) {
    var err, results;
    try {
      results = doctest(path, options);
    } catch (_error) {
      err = _error;
      process.stderr.write("\n  error: " + (err.message[0].toLowerCase()) + err.message.slice(1) + "\n\n");
      process.exit(1);
    }
    return failures + R.length(R.reject(R.identity, R.map(R.head, results)));
  }, 0, program.args);

  process.exit(failures === 0 ? 0 : 1);

}).call(this);
