open Ast
open Parser

let encode_dest = function
  | None -> "000"
  | Some Inst.M -> "001"
  | Some Inst.D -> "010"
  | Some Inst.MD -> "011"
  | Some Inst.A -> "100"
  | Some Inst.AM -> "101"
  | Some Inst.AD -> "110"
  | Some Inst.AMD -> "111"

let encode_jump = function
  | None -> "000"
  | Some Inst.JGT -> "001"
  | Some Inst.JEQ -> "010"
  | Some Inst.JGE -> "011"
  | Some Inst.JLT -> "100"
  | Some Inst.JNE -> "101"
  | Some Inst.JLE -> "110"
  | Some Inst.JMP -> "111"

let encode_comp = function
  | Inst.Const Inst.Zero -> "0101010"
  | Inst.Const Inst.One -> "0111111"
  | Inst.Const Inst.MinusOne -> "0111010"
  | Inst.Unaryop Inst.Id -> "0110000"
  | Inst.Unaryop Inst.Succ -> "0110111"
  | Inst.Unaryop Inst.Pred -> "0110010"
  | Inst.Unaryop Inst.UMinus -> "0110011"
  | Inst.Unaryop Inst.BNeg -> "0110001"
  | Inst.Binaryop Inst.Add -> "0000010"
  | Inst.Binaryop Inst.Sub -> "0010011"
  | Inst.Binaryop Inst.SubFrom -> "0000111"
  | Inst.Binaryop Inst.And -> "0000000"
  | Inst.Binaryop Inst.Or -> "0010101"

let int_to_bin n =
  let rec aux n acc =
    if n = 0 then acc else aux (n / 2) (string_of_int (n mod 2) ^ acc)
  in
  let s = aux n "" in
  String.make (16 - String.length s) '0' ^ s

let encode_a value sym_table =
  match int_of_string_opt value with
  | Some n -> int_to_bin n
  | None -> (
      match SymTable.find_opt value sym_table with
      | Some addr -> int_to_bin addr
      | None -> failwith ("Undefined symbol: " ^ value))

let encode_c { Inst.destination; output; jump } =
  let comp_bits = encode_comp output in
  let dest_bits = encode_dest destination in
  let jump_bits = encode_jump jump in
  "111" ^ comp_bits ^ dest_bits ^ jump_bits

let encode_instruction sym_table = function
  | Inst.A value -> encode_a value sym_table
  | Inst.C cinst -> encode_c cinst
  | Inst.Ldef _ -> ""

let assemble prog sym_table =
  List.filter (fun x -> x <> "") (List.map (encode_instruction sym_table) prog)

