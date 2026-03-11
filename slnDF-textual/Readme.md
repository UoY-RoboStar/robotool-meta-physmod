# Solution DSL EBNF (updated)

<details>
<summary>Solution Structure</summary>

<Solution> ::= "Solution" "{" ["datatypes" <DataTypes>] "state" <State> ["procedures" <Procedures>] ["functions" <Functions>] "computation" <Computation> "}"

<State> ::= "{" { <VariableLine> } "}"

<VariableLine> ::= <Variable> ";"

<Computation> ::= "{" { <Statement> } "}"

</details>

<details>
<summary>DataTypes</summary>

<DataTypes> ::= "{" [ <CustomType> { ";" <CustomType> } ] "}"

<CustomType> ::= <ID> ( <DataType> | <EnumType> )

<DataType> ::= "{" [ <Field> { ";" <Field> } ] "}"

<Field> ::= <ID> ":" <Type>

<EnumType> ::= "{" <ID> { "," <ID> } "}"

</details>

<details>
<summary>Procedures</summary>

<Procedures> ::= "{" { <Procedure> } "}"

<Procedure> ::= "procedure" <ID> "(" [ <ParameterDeclaration> { "," <ParameterDeclaration> } ] ")" "{" { <Statement> } "}"

<ParameterDeclaration> ::= ("val" | "res" | "val-res") <Variable>

</details>

<details>
<summary>Functions</summary>

<Functions> ::= "{" { <Function> } "}"

<Function> ::= "function" <ID> "(" [ <Variable> { "," <Variable> } ] ")" ":" <Type>
               "{" [ <SemExprSeq> ] "}"

<SemanticExpression> ::= <Equality> | <FunctionForLoop> | <FunctionIfThen>

<Equality> ::= <FuncLeftExpr> "==" <Expression>

<FunctionForLoop> ::= "for" "(" <Variable> "in" <RangeExpression> ")" "{" <SemExprSeq> "}"

<FunctionIfThen> ::= "if" "(" <RelationalExpression> ")" "then" <SemExprSeq> "else" <SemExprSeq>

<SemExprSeq> ::= <SemanticExpression> { "/\\" <SemanticExpression> }

</details>

<details>
<summary>Statements</summary>

<Statement> ::= <SKIP> | <Block> | <Assignment> | <VariableLine> | <ForLoop> | <IfThenElse> | <ProcedureCall> ";"

<SKIP> ::= "skip" ";"

<Block> ::= "{" { <Statement> } "}"

<Assignment> ::= <LeftExpr> "=" <Expression> ";"

<ProcedureCall> ::= <ID> "(" [ <Expression> { "," <Expression> } ] ")"

<ForLoop> ::= "for" "(" <Variable> "in" ( <Expression> | <RangeExpression> ) ")" "{" { <Statement> } "}" [";"]

<RangeExpression> ::= "range" "(" <Expression> "," <Expression> "," <Expression> ")"

<IfThenElse> ::= "if" "(" <RelationalExpression> ")" "{" { <Statement> } "}"
                 [ "else" "{" { <Statement> } "}" ] [";"]

</details>

<details>
<summary>Left-expressions (for Assignment and Function Equalities)</summary>

<LeftExpr> ::= <ID>
             | <ID> <Index>
             | <LeftSubmatrix>
             | <LeftSubvector>
             | <LeftRecordField>

<FuncLeftExpr> ::= <ID> [ <Index> ]
                 | <FuncLeftSubmatrix>
                 | <FuncLeftSubvector>
                  | <LeftRecordField>

<LeftRecordField> ::= <ID> "." <ID>

<FuncLeftSubmatrix> ::= "submatrix" "(" <ID> ")" "(" <Expression> "," <Expression> "," <Expression> "," <Expression> ")"

<FuncLeftSubvector> ::= "subvector" "(" <ID> ")" "(" <Expression> "," <Expression> ")"

<LeftSubmatrix> ::= "submatrix" "(" <ID> ")" "(" <Expression> "," <Expression> "," <Expression> "," <Expression> ")"

<LeftSubvector> ::= "subvector" "(" <ID> ")" "(" <Expression> "," <Expression> ")"

<Index> ::= "[" <Expression> [ "," <Expression> ] "]"

</details>

<details>
<summary>Variables</summary>

<Variable> ::= <ID> ":" <Type> [ "=" <Expression> ]

<VariableReference> ::= <ID>

</details>

<details>
<summary>Expressions</summary>

<Expression> ::= <RelationalExpression>

<RelationalExpression> ::= <Addition> { ("=" | "<" | "<=" | ">" | ">=" | "==" | "!=") <Addition> }

<Addition> ::= <Multiplication> { ("+" | "-") <Multiplication> }

<Multiplication> ::= <Unary> { ("*" | "/") <Unary> }

<Unary> ::= "-" <Unary> | <Primary>

<Primary> ::= <PrimaryBase> { <Index> }

<PrimaryBase> ::= <Parenthesized> | <Atomic2>

<Parenthesized> ::= "(" <Expression> ")"

<Atomic2> ::= <SequenceLiteral>
            | <Atomic>
            | <VectorOrMatrix>
            | <BlockMatrix>
            | <Subvector>
            | <Submatrix>
            | <FunctionCall>
            | <RecordField>
            | <RecordExp>

<RecordField> ::= <ID> "." <ID>

<RecordExp> ::= <CustomTypeRef> "{" <FieldDefinition> { "," <FieldDefinition> } "}"

<CustomTypeRef> ::= <ID>

<FieldDefinition> ::= <ID> "=" <Expression>

<FunctionCall> ::= <ID> "(" [ <Expression> { "," <Expression> } ] ")"

<SequenceLiteral> ::= "seq" "(" <Expression> { "," <Expression> } ")"

<Atomic> ::= <VariableReference> | <INT> | <FLOAT> | ("true" | "false")

<VectorOrMatrix> ::= "[" <Row> { ";" <Row> } "]"

<BlockMatrix> ::= "[" <VMBlock> { ";" <VMBlock> } "]"

<Row> ::= <Atomic> { "," <Atomic> }

<Submatrix> ::= "submatrix" "(" <Expression> ")" "(" <Expression> "," <Expression> "," <Expression> "," <Expression> ")"

<Subvector> ::= "subvector" "(" <Expression> ")" "(" <Expression> "," <Expression> ")"

<VMBlock> ::= "(" <Expression> "," <Expression> "," <Expression> "," <Expression> ")" <Expression>

</details>

<details>
<summary>Types</summary>

<Type> ::= <IntType> | <BoolType> | <FloatType> | <VecType> | <MatType> | <SeqType> | <StringType> | <TypeRef>

<TypeRef> ::= <CustomTypeRef>

<IntType> ::= "int"

<BoolType> ::= "bool"

<FloatType> ::= "float"

<VecType> ::= "vec" "(" ")" | "vec" "(" <Expression> ")"

<MatType> ::= "mat" "(" ")" | "mat" "(" <Expression> "," <Expression> ")"

<SeqType> ::= "seq" "(" <Type> ")"

<StringType> ::= "String"

</details>

<details>
<summary>Token Definitions</summary>

<FLOAT> ::= <INT> "." <INT>

<INT> ::= [0-9]+

<ID> ::= [A-Za-z_] [A-ZaZ0-9_]*

</details>
