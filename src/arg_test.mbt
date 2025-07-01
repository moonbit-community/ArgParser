///|
test {
  let verbose : Ref[Bool] = @ref.new(true)
  let keyword : Ref[String] = @ref.new("")
  let delete_files : Ref[Bool] = @ref.new(false)
  let usage =
    #| Awesome CLI tool!
    #| usage: 
    #|      mytool [options] <file1> [<file2>] ... -o <output>
    #|
    #|
  let files = []
  let options = [
    ("--no-verbose", "-n", @arg.Clear(verbose), "disable verbose message"),
    ("--search", "-s", Set_string(keyword), "search for files"),
    ("--delete", "-d", Set(delete_files), "delete listed files"),
  ]
  let fallback = fn { file => files.push(file) }
  let argv = ["--search", ".mbt", "--delete", "file1", "file2", "-n"]
  @arg.parse(options, fallback, usage, argv)
  assert_eq!(verbose.val, false)
  assert_eq!(keyword.val, ".mbt")
  assert_eq!(files.length(), 2)
  assert_eq!(files[0], "file1")
  assert_eq!(files[1], "file2")
}

///| Test String spec handler
test {
  let captured_value : Ref[String] = @ref.new("")
  let options = [
    ("--input", "-i", @arg.String(fn(s) { captured_value.val = s }), "input file"),
  ]
  let files = []
  let fallback = fn { file => files.push(file) }
  let usage = "Test usage"
  let argv = ["--input", "test.mbt", "extra_file"]
  
  @arg.parse(options, fallback, usage, argv)
  
  assert_eq!(captured_value.val, "test.mbt")
  assert_eq!(files.length(), 1)
  assert_eq!(files[0], "extra_file")
}

///| Test Unit spec handler
test {
  let was_called : Ref[Bool] = @ref.new(false)
  let options = [
    ("--version", "-v", @arg.Unit(fn() { was_called.val = true }), "show version"),
  ]
  let files = []
  let fallback = fn { file => files.push(file) }
  let usage = "Test usage"
  let argv = ["--version", "some_file"]
  
  @arg.parse(options, fallback, usage, argv)
  
  assert_eq!(was_called.val, true)
  assert_eq!(files.length(), 1)
  assert_eq!(files[0], "some_file")
}

///| Test help functionality (covers Unit spec and help message generation)
test {
  let options = [
    ("--verbose", "-v", @arg.Set(@ref.new(false)), "enable verbose output"),
  ]
  let files = []
  let fallback = fn { file => files.push(file) }
  let usage = "Test CLI\nusage: test [options]"
  let argv = ["--help"]
  
  // This will trigger the help Unit spec, covering the uncovered line
  @arg.parse(options, fallback, usage, argv)
  
  // The help message is printed but we can't easily capture stdout in tests,
  // so we just verify the test completes without error
  assert_eq!(files.length(), 0)
}

///| Test missing argument error cases
test {
  let captured_value : Ref[String] = @ref.new("")
  let string_ref : Ref[String] = @ref.new("")
  let options = [
    ("--input", "-i", @arg.String(fn(s) { captured_value.val = s }), "input file"),
    ("--output", "-o", @arg.Set_string(string_ref), "output file"),
  ]
  let files = []
  let fallback = fn { file => files.push(file) }
  let usage = "Test usage"
  
  // Test missing argument for String spec
  let argv1 = ["--input"]
  @arg.parse(options, fallback, usage, argv1)
  // This should print "missing argument for --input" but continue execution
  
  // Test missing argument for Set_string spec  
  let argv2 = ["--output"]
  @arg.parse(options, fallback, usage, argv2)
  // This should print "missing argument for --output" but continue execution
  
  // Verify that the missing arguments didn't set any values
  assert_eq!(captured_value.val, "")
  assert_eq!(string_ref.val, "")
}