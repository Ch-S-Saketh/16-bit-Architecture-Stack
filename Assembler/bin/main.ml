open Assembler

let () =
  if Array.length Sys.argv < 2 then (
    print_endline "No file given";
    exit 1);
  let input = Sys.argv.(1) in
  let prog, sym_table = Parser.parse input in
  let binary = Machine.assemble prog sym_table in
  List.iter print_endline binary

