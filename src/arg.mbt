///| Matched option handler that used to interpret options.
/// 
///  Unit - handle with callback  
/// 
///  String - handle associated value with callback
/// 
///  Set_string - set option to associated value 
/// 
///  Set - set reference to true
/// 
///  Clear - set reference to false
pub(all) enum Spec {
  Unit(() -> Unit)
  String((String) -> Unit)
  Set_string(Ref[String])
  Set(Ref[Bool])
  Clear(Ref[Bool])
}

///|
fn interpret(
  trie : @trie.T[Spec],
  xs : Array[String],
  fallback : (String) -> Unit
) -> Unit {
  loop xs[:] {
    [] => ()
    [x, .. xs] =>
      match trie.lookup(x) {
        None => {
          fallback(x)
          continue xs
        }
        Some(spec) =>
          match (spec, xs) {
            (String(f), [y, .. ys]) => {
              f(y)
              continue ys
            }
            (Set_string(r), [y, .. ys]) => {
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

///| Parse argument list for CLI tools
/// 
/// Match `OptionName` or `LongOptionName` then interpret with `Spec` and 
/// use `Description` to generate `-h` or `--help` options message.
/// 
/// speclist - (LongOptionName, OptionName, Spec, Description) of Array 
/// 
/// rest - rest arguments handler
/// 
/// usage_msg - synopsis usage  
/// 
/// argv - input argument list 
/// 
pub fn parse(
  speclist : Array[(String, String, Spec, String)],
  rest : (String) -> Unit,
  usage_msg : String,
  argv : Array[String]
) -> Unit {
  let aux = fn(acc, it) {
    let ((trie : @trie.T[Spec]), help_msg) = acc
    let (a, b, spec, help) = it
    let trie = trie.add(a, spec).add(b, spec)
    let help_msg = help_msg + "  \{a}\t\{b}\t" + help + "\n"
    (trie, help_msg)
  }
  let (trie, help_msg) = speclist.fold(
    aux,
    init=(@trie.empty(), usage_msg + "\n options:\n"),
  )
  let help_spec = Spec::Unit(fn() { println(help_msg) })
  let trie = trie.add("--help", help_spec).add("-h", help_spec)
  interpret(trie, argv, rest)
}
