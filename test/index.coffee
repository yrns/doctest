{exec}  = require 'child_process'
pathlib = require 'path'

R       = require 'ramda'
semver  = require 'semver'

doctest = require '../lib/doctest'


gray = green = red = reset = ''
unless process.env.NODE_DISABLE_COLORS or process.platform is 'win32'
  gray  = '\x1B[0;37m'
  green = '\x1B[0;32m'
  red   = '\x1B[0;31m'
  reset = '\x1B[0m'


printResult = (actual, expected, message) ->
  if R.eqDeep actual, expected
    console.log "#{green} \u2714 #{gray} #{message}#{reset}"
  else
    console.warn  "#{red} \u2718 #{gray} #{message}#{reset}"
    console.log  "#{gray}      expected: #{green}#{expected}#{reset}"
    console.log  "#{gray}      received: #{red}#{actual}#{reset}"


testModule = (path, options) ->
  doctest path, R.assoc('silent', yes, options), (results) ->
    for [message, expected], idx in require pathlib.resolve path, '../results'
      printResult results[idx], expected, message


testCommand = (command, expected) ->
  child = exec command, (err, stdout, stderr) ->
    code = if err? then err.code else 0
    switch
      when code isnt expected.code
        printResult code, expected.code, command
      when stdout isnt expected.stdout
        printResult stdout, expected.stdout, command
      when stderr isnt expected.stderr
        printResult stderr, expected.stderr, command
      else
        printResult 0, 0, command


testModule 'test/shared/index.js'
testModule 'test/shared/index.coffee'
testModule 'test/line-endings/CR.js'
testModule 'test/line-endings/CR.coffee'
testModule 'test/line-endings/CR+LF.js'
testModule 'test/line-endings/CR+LF.coffee'
testModule 'test/line-endings/LF.js'
testModule 'test/line-endings/LF.coffee'
testModule 'test/amd/index.js', module: 'amd'
testModule 'test/commonjs/require/index.js', module: 'commonjs'
testModule 'test/commonjs/exports/index.js', module: 'commonjs'
testModule 'test/commonjs/module.exports/index.js', module: 'commonjs'
testModule 'test/commonjs/strict/index.js', module: 'commonjs'
testModule 'test/bin/executable', type: 'js'
testModule 'test/harmony/index.js' if semver.gte process.version, '0.12.0'

testCommand 'bin/doctest --xxx',
  code: 1
  stdout: ''
  stderr: "\n  error: unknown option `--xxx'\n\n"

testCommand 'bin/doctest --type',
  code: 1
  stdout: ''
  stderr: "\n  error: option `-t, --type <type>' argument missing\n\n"

testCommand 'bin/doctest --type xxx',
  code: 1
  stdout: ''
  stderr: "\n  error: invalid type `xxx'\n\n"

testCommand 'bin/doctest test/shared/index.js',
  code: 1
  stdout: '''
    retrieving test/shared/index.js...
    running doctests in index.js...
    ......x.x...........x........x
    FAIL: expected 5 on line 31 (got 4)
    FAIL: expected TypeError on line 38 (got 0)
    FAIL: expected 9.5 on line 97 (got 5)
    FAIL: expected "on automatic semicolon insertion" on line 155 (got "the rewriter should not rely")

  '''
  stderr: ''

testCommand 'bin/doctest test/shared/index.coffee',
  code: 1
  stdout: '''
    retrieving test/shared/index.coffee...
    running doctests in index.coffee...
    ......x.x...........x........x
    FAIL: expected 5 on line 31 (got 4)
    FAIL: expected TypeError on line 38 (got 0)
    FAIL: expected 9.5 on line 97 (got 5)
    FAIL: expected "on automatic semicolon insertion" on line 155 (got "the rewriter should not rely")

  '''
  stderr: ''

testCommand 'bin/doctest test/shared/index.js test/shared/index.coffee',
  code: 1
  stdout: '''
    retrieving test/shared/index.js...
    running doctests in index.js...
    ......x.x...........x........x
    FAIL: expected 5 on line 31 (got 4)
    FAIL: expected TypeError on line 38 (got 0)
    FAIL: expected 9.5 on line 97 (got 5)
    FAIL: expected "on automatic semicolon insertion" on line 155 (got "the rewriter should not rely")
    retrieving test/shared/index.coffee...
    running doctests in index.coffee...
    ......x.x...........x........x
    FAIL: expected 5 on line 31 (got 4)
    FAIL: expected TypeError on line 38 (got 0)
    FAIL: expected 9.5 on line 97 (got 5)
    FAIL: expected "on automatic semicolon insertion" on line 155 (got "the rewriter should not rely")

  '''
  stderr: ''

testCommand 'bin/doctest --silent test/shared/index.js',
  code: 1
  stdout: ''
  stderr: ''

testCommand 'bin/doctest --silent test/bin/executable',
  code: 1
  stdout: ''
  stderr: '\n  error: cannot infer type from extension\n\n'

testCommand 'bin/doctest --type js --silent test/bin/executable',
  code: 0
  stdout: ''
  stderr: ''

testCommand 'bin/doctest --module commonjs --silent src/doctest.coffee',
  code: 0
  stdout: ''
  stderr: ''

testCommand 'bin/doctest --print test/commonjs/exports/index.js',
  code: 0
  stdout: '''
    __doctest.input(function() {
      return exports.identity(42);
    });
    __doctest.output(2, function() {
      return 42;
    });
    exports.identity = function(x) {
      return x;
    };

  '''
  stderr: ''

testCommand 'bin/doctest --print --module amd test/amd/index.js',
  code: 0
  stdout: '''
    define(function() {
      // Convert degrees Celsius to degrees Fahrenheit.
      //
      __doctest.input(function() {
      return toFahrenheit(0);
    });
    __doctest.output(5, function() {
      return 32;
    });
      function toFahrenheit(degreesCelsius) {
        return degreesCelsius * 9 / 5 + 32;
      }
      return toFahrenheit;
    });

    function define() {
      for (var idx = 0; idx < arguments.length; idx += 1) {
        if (typeof arguments[idx] == 'function') {
          arguments[idx]();
          break;
        }
      }
    }

  '''
  stderr: ''

testCommand 'bin/doctest --print --module commonjs test/commonjs/exports/index.js',
  code: 0
  stdout: '''
    void function() {
      var __doctest = {
        queue: [],
        input: function(fn) {
          __doctest.queue.push([fn]);
        },
        output: function(num, fn) {
          __doctest.queue.push([fn, num]);
        }
      };

      void function() {
        __doctest.input(function() {
          return exports.identity(42);
        });
        __doctest.output(2, function() {
          return 42;
        });
        exports.identity = function(x) {
          return x;
        };
      }.call(this);

      (module.exports || exports).__doctest = __doctest;
    }.call(this);

  '''
  stderr: ''
