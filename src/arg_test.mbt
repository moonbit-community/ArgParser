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
  let callback = fn(value) { captured_value.val = value }
  
  let options = [
    ("--input", "-i", @arg.String(callback), "input file name"),
  ]
  let fallback = fn(_) { () }
  let argv = ["--input", "test.txt"]
  
  @arg.parse(options, fallback, "Usage:", argv)
  assert_eq(captured_value.val, "test.txt")
}

///| Test Unit spec with callback function
test {
  let was_called : Ref[Bool] = @ref.new(false)
  let callback = fn() { was_called.val = true }
  
  let options = [
    ("--version", "-v", @arg.Unit(callback), "show version"),
  ]
  let fallback = fn(_) { () }
  let argv = ["--version"]
  
  @arg.parse(options, fallback, "Usage:", argv)
  assert_eq(was_called.val, true)
}

///| Test help option functionality
test {
  let options = [
    ("--verbose", "-v", @arg.Set(@ref.new(false)), "enable verbose output"),
  ]
  let fallback = fn(_) { () }
  let usage_msg = "Test CLI tool\nUsage: testcli [options]"
  
  // Test --help option
  let argv_help = ["--help"]
  @arg.parse(options, fallback, usage_msg, argv_help)
  
  // Test -h option  
  let argv_h = ["-h"]
  @arg.parse(options, fallback, usage_msg, argv_h)
}

///| Test missing argument error handling for String spec
test {
  let captured_value : Ref[String] = @ref.new("")
  let callback = fn(value) { captured_value.val = value }
  
  let options = [
    ("--config", "-c", @arg.String(callback), "config file path"),
  ]
  let fallback = fn(_) { () }
  
  // Test missing argument for String spec
  let argv = ["--config"]
  @arg.parse(options, fallback, "Usage:", argv)
  
  // Value should remain unchanged since no argument was provided
  assert_eq(captured_value.val, "")
}

///| Test missing argument error handling for Set_string spec
test {
  let output_file : Ref[String] = @ref.new("")
  
  let options = [
    ("--output", "-o", @arg.Set_string(output_file), "output file path"),
  ]
  let fallback = fn(_) { () }
  
  // Test missing argument for Set_string spec
  let argv = ["--output"]
  @arg.parse(options, fallback, "Usage:", argv)
  
  // Value should remain unchanged since no argument was provided
  assert_eq(output_file.val, "")
}

///| Test combination of multiple spec types
test {
  let verbose : Ref[Bool] = @ref.new(false)
  let config_file : Ref[String] = @ref.new("")
  let called_version : Ref[Bool] = @ref.new(false)
  let input_files = []
  
  let version_callback = fn() { called_version.val = true }
  let file_callback = fn(file) { config_file.val = file }
  
  let options = [
    ("--verbose", "-v", @arg.Set(verbose), "enable verbose output"),
    ("--config", "-c", @arg.String(file_callback), "config file"),
    ("--version", "", @arg.Unit(version_callback), "show version"),
  ]
  let fallback = fn(file) { input_files.push(file) }
  let argv = ["--verbose", "--config", "config.json", "input1.txt", "--version", "input2.txt"]
  
  @arg.parse(options, fallback, "Usage:", argv)
  
  assert_eq(verbose.val, true)
  assert_eq(config_file.val, "config.json")
  assert_eq(called_version.val, true)
  assert_eq(input_files.length(), 2)
  assert_eq(input_files[0], "input1.txt")
  assert_eq(input_files[1], "input2.txt")
}