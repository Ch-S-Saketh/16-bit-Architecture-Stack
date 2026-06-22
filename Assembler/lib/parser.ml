open Ast

let clean_line l =
	match String.index_opt l '/' with
	| Some i when i+1<String.length l && l.[i+1] = '/' -> String.trim(String.sub l 0 i)
	| _ -> String.trim l

let p_dest = function
	|"M" -> Some Inst.M
	|"D" -> Some Inst.D
	|"A" -> Some Inst.A
	|"MD" -> Some Inst.MD
	|"AD" -> Some Inst.AD
	|"AM" -> Some Inst.AM
	|"AMD" -> Some Inst.AMD
	|_ -> None

let p_jump = function
	|"JMP" -> Some Inst.JMP
	|"JEQ" -> Some Inst.JEQ
	|"JGT" -> Some Inst.JGT
	|"JLT" -> Some Inst.JLT
	|"JGE" -> Some Inst.JGE
	|"JLE" -> Some Inst.JLE
	|"JNE" -> Some Inst.JNE
	|_ -> None

let p_out = function
  |"0" -> Inst.Const Inst.Zero
  |"1" -> Inst.Const Inst.One
  |"-1" -> Inst.Const Inst.MinusOne
  |"D" -> Inst.Unaryop Inst.Id
  |"A" -> Inst.Unaryop Inst.Id
  |"M" -> Inst.Unaryop Inst.Id
  |"D+1" |"1+D" |"A+1" |"1+A" |"M+1" |"1+M" -> Inst.Unaryop Inst.Succ
  |"D-1" |"A-1" |"M-1" -> Inst.Unaryop Inst.Pred
  |"-D" |"-A" |"-M" -> Inst.Unaryop Inst.UMinus
  |"!D" |"!A" |"!M" -> Inst.Unaryop Inst.BNeg
  |"D+A" |"A+D" |"D+M" |"M+D" -> Inst.Binaryop Inst.Add
  |"D-A" |"D-M" -> Inst.Binaryop Inst.Sub
  |"A-D" |"M-D" -> Inst.Binaryop Inst.SubFrom
  |"D&A" |"A&D" |"D&M" |"M&D" -> Inst.Binaryop Inst.And
  |"D|A" |"A|D" |"D|M" |"M|D" -> Inst.Binaryop Inst.Or
  |_ -> failwith "invalid comp"

let parse_c l =
  let parts = String.split_on_char ';' l in
  let (before_jump, jump) =
    match parts with
    | [comp] -> (comp, None)
    | [comp; j] -> (comp, Some j)
    | _ -> failwith "invalid C-instruction"
  in
  let parts2 = String.split_on_char '=' before_jump in
  let (dest, out) =
    match parts2 with
    | [a] -> (None, a)
    | [d; a] -> (Some d, a)
    | _ -> failwith "invalid dest part"
  in
  let dest' = Option.bind dest p_dest in
  let jump' = Option.bind jump p_jump in
  let out' = p_out out in
  Inst.C {destination = dest'; output = out'; jump = jump'}

let parse_a l=
	let value = String.sub l 1 (String.length l - 1) in
	Inst.A value

let parse_label l=
	let name=String.sub l 1 (String.length l - 1) in
	Inst.Ldef name

let p_line line =
  let line = clean_line line in
  if line = "" then None
  else if line.[0] = '@' then Some (parse_a line)
  else if line.[0] = '(' && line.[String.length line - 1] = ')' then
	Some (parse_label line)
  else Some (parse_c line)

module SymTable = Map.Make(String)

let predefined_symbols =
  let open SymTable in
  empty
  |> add "SP" 0
  |> add "LCL" 1
  |> add "ARG" 2
  |> add "THIS" 3
  |> add "THAT" 4
  |> add "SCREEN" 16384
  |> add "KBD" 24576
  |> fun m ->
    List.fold_left (fun acc i -> add ("R" ^ string_of_int i) i acc) m (List.init 16 (fun x -> x))
  
let parse filename =
  let file = open_in filename in
  let rec read_all acc =
    match input_line file with
    | line -> read_all (line :: acc)
    | exception End_of_file -> close_in file; List.rev acc
  in
  let lines = read_all [] in

  let rec first_pass curr_addr table acc = function
    | [] -> (List.rev acc, table)
    | line :: rest -> (
        match p_line line with
        | Some (Inst.Ldef name) ->
            first_pass curr_addr (SymTable.add name curr_addr table) acc rest
        | Some inst -> first_pass (curr_addr + 1) table (inst :: acc) rest
        | None -> first_pass curr_addr table acc rest)
  in

  let prog, table = first_pass 0 predefined_symbols [] lines in

  let rec second_pass next_addr table = function
    | [] -> table
    | Inst.A v :: rest when int_of_string_opt v = None ->
        if SymTable.mem v table then
          second_pass next_addr table rest
        else
          second_pass (next_addr + 1) (SymTable.add v next_addr table) rest
    | _ :: rest -> second_pass next_addr table rest
  in
  let final_table = second_pass 16 table prog in
  (prog, final_table)

