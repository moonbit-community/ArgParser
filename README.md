# ArgParser

Command line parser for MoonBit. It use a declarative style to specify command line interface.

# Usage 

```moonbit
fn main {
  let argv = ["-o", "out.mbt", "file1", "file2", "--verbose"]
  let verbose = @ref.new(false)
  let output = @ref.new("output")
  let files = []
  let usage =
    #| Awesome CLI tool!
    #| usage: 
    #|      mytool [options] <file1> [<file2>] ... -o <output>
    #|

  @ArgParser.parse(
    [
      ("--verbose", "-v", Set(verbose), "enable verbose message"),
      ("--output", "-o", Set_string(output), "output file name"),
    ],
    fn { file => files.push(file) },
    usage,
    argv,
  )
  println(verbose)
  println(output)
  println(files[0]) 
  println(files[1]) 
}
```

output: 

```
{val: true}
{val: out.mbt}
file1
file2
```

## `help` options

ArgParser will automatically generate `--help` and `-h` options.

```moonbit
fn main {
  let argv = ["--help"]
  let verbose = @ref.new(false)
  let output = @ref.new("output")
  let usage =
    #| Awesome CLI tool!
    #| usage: 
    #|      mytool [options] <file1> [<file2>] ... -o <output>
    #|

  @ArgParser.parse(
    [
      ("--verbose", "-v", Set(verbose), "enable verbose message"),
      ("--output", "-o", Set_string(output), "output file name"),
    ],
    ignore,
    usage,
    argv,
  )
}
```

output: 

```bash
Awesome CLI tool!
usage: 
    mytool [options] \<file1\> [<file2>] ... -o \<output\>
options:
  --verbose     -v      enable verbose message
  --output      -o      output file name
```








