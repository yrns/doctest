// Generated by CoffeeScript 1.6.3
(function() {
  var doctest, options, program, _;

  program = require('commander');

  _ = require('underscore');

  doctest = require('../lib/doctest');

  program.version(doctest.version).usage('[options] path/to/js/or/coffee/module').option('-m, --module [type]', 'specify module system ("amd" or "commonjs")').option('-s, --silent', 'suppress output').parse(process.argv);

  options = _.pick(program, ['module', 'silent']);

  process.exit(_.reduce(program.args, function(failures, path) {
    var results;
    results = doctest(path, options);
    return failures + _.reject(_.map(results, _.first), _.identity).length;
  }, 0));

}).call(this);