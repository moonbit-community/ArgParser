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
  let fallback = file => files.push(file)
  let argv = ["--search", ".mbt", "--delete", "file1", "file2", "-n"]
  @arg.parse(options, fallback, usage, argv)
  assert_eq(verbose.val, false)
  assert_eq(keyword.val, ".mbt")
  assert_eq(files.length(), 2)
  assert_eq(files[0], "file1")
  assert_eq(files[1], "file2")
}

///| Test String spec with callback function
test {
  let captured_value : Ref[String] = @ref.new("")
  let callback = fn(s) { captured_value.val = s }
  let options = [
    ("--input", "-i", @arg.String(callback), "input file"),
  ]
  let fallback = fn(_) { () }
  let argv = ["--input", "test.txt"]
  @arg.parse(options, fallback, "Test usage", argv)
  assert_eq(captured_value.val, "test.txt")
}

///| Test Unit spec with callback function
test {
  let callback_called : Ref[Bool] = @ref.new(false)
  let callback = fn() { callback_called.val = true }
  let options = [
    ("--version", "-v", @arg.Unit(callback), "show version"),
  ]
  let fallback = fn(_) { () }
  let argv = ["--version"]
  @arg.parse(options, fallback, "Test usage", argv)
  assert_eq(callback_called.val, true)
}

///| Test missing argument error for String spec
test {
  let callback = fn(_) { () }
  let options = [
    ("--input", "-i", @arg.String(callback), "input file"),
  ]
  let fallback = fn(_) { () }
  let argv = ["--input"] // Missing argument
  // This should print "missing argument for --input" 
  // Note: Since println is used, we can't easily capture the output in tests
  // but we can verify the function doesn't crash
  @arg.parse(options, fallback, "Test usage", argv)
}

///| Test missing argument error for Set_string spec
test {
  let value : Ref[String] = @ref.new("")
  let options = [
    ("--output", "-o", @arg.Set_string(value), "output file"),
  ]
  let fallback = fn(_) { () }
  let argv = ["--output"] // Missing argument
  // This should print "missing argument for --output"
  @arg.parse(options, fallback, "Test usage", argv)
  // Value should remain unchanged
  assert_eq(value.val, "")
}

///| Test help functionality
test {
  let options = [
    ("--verbose", "-v", @arg.Set(@ref.new(false)), "enable verbose mode"),
    ("--input", "-i", @arg.Set_string(@ref.new("")), "input file"),
  ]
  let fallback = fn(_) { () }
  
  // Test --help
  let argv1 = ["--help"]
  @arg.parse(options, fallback, "Test CLI Tool", argv1)
  
  // Test -h
  let argv2 = ["-h"]
  @arg.parse(options, fallback, "Test CLI Tool", argv2)
  
  // Both should print help message (captured by println)
  // We can't easily test the printed output, but we verify no crashes occur
}

///| Test multiple argument types in one run
test {
  let verbose : Ref[Bool] = @ref.new(false)
  let quiet : Ref[Bool] = @ref.new(true)
  let output : Ref[String] = @ref.new("")
  let callback_value : Ref[String] = @ref.new("")
  let unit_called : Ref[Bool] = @ref.new(false)
  
  let string_callback = fn(s) { callback_value.val = s }
  let unit_callback = fn() { unit_called.val = true }
  
  let files = []
  let options = [
    ("--verbose", "-v", @arg.Set(verbose), "enable verbose mode"),
    ("--quiet", "-q", @arg.Clear(quiet), "disable quiet mode"),
    ("--output", "-o", @arg.Set_string(output), "output file"),
    ("--config", "-c", @arg.String(string_callback), "config file"),
    ("--init", "", @arg.Unit(unit_callback), "initialize"),
  ]
  let fallback = fn(file) { files.push(file) }
  
  let argv = ["--verbose", "--quiet", "--output", "result.txt", 
              "--config", "config.json", "--init", "input1.txt", "input2.txt"]
  
  @arg.parse(options, fallback, "Multi-test CLI", argv)
  
  assert_eq(verbose.val, true)
  assert_eq(quiet.val, false)
  assert_eq(output.val, "result.txt")
  assert_eq(callback_value.val, "config.json")
  assert_eq(unit_called.val, true)
  assert_eq(files.length(), 2)
  assert_eq(files[0], "input1.txt")
  assert_eq(files[1], "input2.txt")
}

///| Test edge cases with empty arguments
test {
  let options = [
    ("--test", "-t", @arg.Set(@ref.new(false)), "test option"),
  ]
  let fallback = fn(_) { () }
  let argv = [] // Empty argv
  @arg.parse(options, fallback, "Empty test", argv)
  // Should handle empty arguments gracefully
}

///| Test unrecognized options
test {
  let files = []
  let options = [
    ("--known", "-k", @arg.Set(@ref.new(false)), "known option"),
  ]
  let fallback = fn(arg) { files.push(arg) }
  let argv = ["--unknown", "value", "file.txt"]
  @arg.parse(options, fallback, "Unknown option test", argv)
  
  // Unknown options should be passed to fallback
  assert_eq(files.length(), 3)
  assert_eq(files[0], "--unknown")
  assert_eq(files[1], "value")
  assert_eq(files[2], "file.txt")
}