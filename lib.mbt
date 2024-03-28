pub enum Spec {
  Unit(() -> Unit)
  String((String) -> Unit)
  Set_string(Ref[String])
  Set(Ref[Bool])
  Clear(Ref[Bool])
}

fn interpret(
  trie : @trie.Trie[Spec],
  xs : List[String],
  fallback : (String) -> Unit
) -> Unit {
  loop xs {
    Nil => ()
    Cons(x, xs) =>
      match trie.lookup(x) {
        None => {
          fallback(x)
          continue xs
        }
        Some(spec) =>
          match (spec, xs) {
            (String(f), Cons(y, ys)) => {
              f(y)
              continue ys
            }
            (Set_string(r), Cons(y, ys)) => {
              r.val = y
              continue ys
            }
            (String(_), Nil) | (Set_string(_), Nil) =>
              println("missing argument for \(x)")
            (Set(r), _) => {
              r.val = true
              continue xs
            }
            (Clear(r), _) => {
              r.val = false
              continue xs
            }
            (Unit(f), _) => {
              f()
              continue xs 
            }
          }
      }
  }
}

pub fn parse(
  speclist : Array[(String, String, Spec, String)],
  rest : (String) -> Unit,
  usage_msg : String,
  argv : Array[String]
) -> Unit {
  fn aux {
    (a, b, spec, help), ((trie : @trie.Trie[Spec]), help_msg) => {
      let trie = trie.insert(a, spec).insert(b, spec)
      let help_msg = help_msg + "  \(a)\t\(b)\t" + help + "\n"
      (trie, help_msg)
    }
  }

  let (trie, help_msg) = speclist.fold(aux, (@trie.empty(), usage_msg + "\n options:\n"))
  let help_spec = Spec::Unit(fn() { println(help_msg) })
  let trie = trie.insert("--help", help_spec).insert("-h", help_spec)
  interpret(trie, List::from_array(argv), rest)
}

test {
  let verbose : Ref[Bool] = @ref.ref(true)
  let keyword : Ref[String] = @ref.ref("")
  let delete_files : Ref[Bool] = @ref.ref(false)
  let usage =
    #| Awesome CLI tool!
    #| usage: 
    #|      mytool [options] <file1> [<file2>] ... -o <output>
    #|
    #|

  let files = @vec.new()
  let options = [
    ("--no-verbose", "-n", Spec::Clear(verbose), "disable verbose message"),
    ("--search", "-s", Set_string(keyword), "search for files"),
    ("--delete", "-d", Set(delete_files), "delete listed files"),
  ]
  let fallback = fn { file => files.push(file) }
  let argv = ["--search", ".mbt", "--delete", "file1", "file2", "-n"]
  parse(options, fallback, usage, argv)
  @assertion.assert_eq(verbose.val, false)?
  @assertion.assert_eq(keyword.val, ".mbt")?
  @assertion.assert_eq(files.len, 2)?
  @assertion.assert_eq(files[0], "file1")?
  @assertion.assert_eq(files[1], "file2")?
}