# ArgParser

A simple command-line parser for MoonBit. It uses a declarative style to specify 
the command-line interface.

# Usage 

```moonbit
test {
  let argv = ["-o", "out.mbt", "file1", "file2", "--verbose"]
  let verbose = @ref.new(false)
  let output = @ref.new("output")
  let files = []
  let usage =
    #| Simple CLI tool
    #| usage: 
    #|      mytool [options] <file1> [<file2>] ... -o <output>
    #|
  @ArgParser.parse(
    [
      ("--verbose", "-v", Set(verbose), "enable verbose message"),
      ("--output", "-o", Set_string(output), "output file name"),
    ],
    file => files.push(file),
    usage,
    argv,
  )
  inspect(verbose.val, content="true")
  inspect(output.val, content="out.mbt")
  inspect(files[0], content="file1")
  inspect(files[1], content="file2")
}
```

## `help` options

ArgParser will automatically generate `--help` and `-h` options.

# Related Libraries

Looking for more powerful CLI tool? Check out [clap](https://mooncakes.io/docs/TheWaWaR/clap).
