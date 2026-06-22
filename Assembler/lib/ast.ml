module Reg=struct
        type t= A
                |D
                |M
end
module Inst=struct
type destinst=M
        |D
        |A
        |MD
        |AD
        |AM
        |AMD
type jinst=JMP
        |JEQ
        |JGT
        |JLT
        |JGE
        |JLE
        |JNE
type unaryop=Id
        |Succ
        |Pred
        |UMinus
        |BNeg
type binaryop=Add
        |Sub
        |SubFrom
        |And
        |Or
type const=Zero
        |One
        |MinusOne
type outinst=Const of const
        |Unaryop of unaryop
        |Binaryop of binaryop
type cinst={destination: destinst option;
                output: outinst;
                jump: jinst option;
}
type 'v t=A of 'v
        |C of cinst
        |Ldef of string

let map f=function
        |A x -> A (f x)
        |C i -> C i
	|Ldef l -> Ldef l
end
module Prog=struct
        type 'v t = ('v Inst.t) list
        let map f ilist = List.map (Inst.map f) ilist
end
