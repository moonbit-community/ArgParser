pub enum Spec {
  Unit(() -> Unit)
  String((String) -> Unit)
  Set_string(Ref[String])
  Set(Ref[Bool])
  Clear(Ref[Bool])
}

fn interpret(
  trie : @trie.T[Spec],
  xs : Array[String],
  fallback : (String) -> Unit
) -> Unit {
  loop xs[:] {
    [] => ()
    [x, .. as xs] =>
      match trie.lookup(x) {
        None => {
          fallback(x)
          continue xs
        }
        Some(spec) =>
          match (spec, xs) {
            (String(f), [y, .. as ys]) => {
              f(y)
              continue ys
            }
            (Set_string(r), [y, .. as ys]) => {
              r.val = y
              continue ys
            }
            (String(_), []) | (Set_string(_), []) =>
              println("missing argument for \{x}")
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
    ((trie : @trie.T[Spec]), help_msg), (a, b, spec, help) => {
      let trie = trie.insert(a, spec).insert(b, spec)
      let help_msg = help_msg + "  \{a}\t\{b}\t" + help + "\n"
      (trie, help_msg)
    }
  }

  let (trie, help_msg) = speclist.fold(
    aux,
    init=(@trie.empty(), usage_msg + "\n options:\n"),
  )
  let help_spec = Spec::Unit(fn() { println(help_msg) })
  let trie = trie.insert("--help", help_spec).insert("-h", help_spec)
  interpret(trie, argv, rest)
}
