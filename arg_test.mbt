///|
test {
  let verbose : Ref[Bool] = Ref(true)
  let keyword : Ref[String] = Ref("")
  let delete_files : Ref[Bool] = Ref(false)
  let usage =
    #| Awesome CLI tool!
    #| usage: 
    #|      mytool [options] <file1> [<file2>] ... -o <output>
    #|
    #|
  let files = []
  let options = [
    ("--no-verbose", "-n", @ArgParser.Clear(verbose), "disable verbose message"),
    ("--search", "-s", Set_string(keyword), "search for files"),
    ("--delete", "-d", Set(delete_files), "delete listed files"),
  ]
  let argv = ["--search", ".mbt", "--delete", "file1", "file2", "-n"]
  @ArgParser.parse(options, file => files.push(file), usage, argv)
  assert_eq(verbose.val, false)
  assert_eq(keyword.val, ".mbt")
  assert_eq(files.length(), 2)
  assert_eq(files[0], "file1")
  assert_eq(files[1], "file2")
}

///|
test "exact option names and duplicate precedence" {
  let seen = []
  let options = [
    ("--mode", "-m", @ArgParser.Unit(() => seen.push("first")), "first"),
    ("--mode", "-M", @ArgParser.Unit(() => seen.push("second")), "second"),
  ]
  @ArgParser.parse(options, x => seen.push(x), "usage", [
    "--mod", "--mode", "-m", "-M",
  ])
  assert_eq(seen, ["--mod", "second", "first", "second"])
}

///|
test "missing argument and callback errors propagate" {
  let options = [("--value", "-v", @ArgParser.String(_ => ()), "value")]
  let result = Ok(@ArgParser.parse(options, _ => (), "usage", ["--value"])) catch {
    e => Err(e)
  }
  assert_true(
    result is Err(@ArgParser.ErrorMsg("missing argument for --value")),
  )
  let callbacks = [
    ("--fail", "-f", @ArgParser.Unit(() => raise CallbackFailure), "fail"),
  ]
  let result = Ok(@ArgParser.parse(callbacks, _ => (), "usage", ["-f"])) catch {
    e => Err(e)
  }
  assert_true(result is Err(CallbackFailure))
}

///|
test "built-in help overrides user aliases" {
  let called = Ref(false)
  let options = [
    ("--help", "-h", @ArgParser.Unit(() => called.val = true), "custom"),
  ]
  let result = Ok(@ArgParser.parse(options, _ => (), "usage", ["--help"])) catch {
    e => Err(e)
  }
  assert_true(
    result
    is Err(@ArgParser.ErrorMsg("usage\n options:\n  --help\t-h\tcustom\n")),
  )
  assert_eq(called.val, false)
}

///|
suberror CallbackFailure
