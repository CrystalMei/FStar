// Signature file for parser generated by fsyacc
module FStar.Parser.Parse
open FStar.Parser.AST
type token = 
  | WITH
  | WHEN
  | VAL
  | UNOPTEQUALITY
  | UNIV_HASH
  | UNIVAR of (string)
  | UNFOLDABLE
  | UNFOLD
  | UNDERSCORE
  | UINT8 of (string)
  | UINT64 of (string)
  | UINT32 of (string)
  | UINT16 of (string)
  | TYP_APP_LESS
  | TYP_APP_GREATER
  | TYPE
  | TVAR of (string)
  | TRY
  | TRUE
  | TOTAL
  | TILDE of (string)
  | THEN
  | SUB_EFFECT
  | SUBTYPE
  | SUBKIND
  | STRING of (bytes)
  | SQUIGGLY_RARROW
  | SEMICOLON_SEMICOLON
  | SEMICOLON
  | RPAREN
  | REQUIRES
  | REIFY
  | REIFIABLE
  | REFLECTABLE
  | REC
  | RBRACK
  | RBRACE
  | RARROW
  | QMARK_DOT
  | QMARK
  | PRIVATE
  | PRAGMA_SET_OPTIONS
  | PRAGMA_RESET_OPTIONS
  | PRAGMALIGHT
  | PIPE_RIGHT
  | PERCENT_LBRACK
  | OPPREFIX of (string)
  | OPINFIX4 of (string)
  | OPINFIX3 of (string)
  | OPINFIX2 of (string)
  | OPINFIX1 of (string)
  | OPINFIX0d of (string)
  | OPINFIX0c of (string)
  | OPINFIX0b of (string)
  | OPINFIX0a of (string)
  | OPEN
  | OPAQUE
  | OF
  | NOEXTRACT
  | NOEQUALITY
  | NEW_EFFECT_FOR_FREE
  | NEW_EFFECT
  | NEW
  | NAME of (string)
  | MUTABLE
  | MODULE
  | MINUS
  | MATCH
  | L_TRUE
  | L_FALSE
  | LPAREN_RPAREN
  | LPAREN
  | LOGIC
  | LET of (bool)
  | LENS_PAREN_RIGHT
  | LENS_PAREN_LEFT
  | LBRACK_BAR
  | LBRACK_AT
  | LBRACK
  | LBRACE_COLON_PATTERN
  | LBRACE
  | LARROW
  | IRREDUCIBLE
  | INT8 of (string * bool)
  | INT64 of (string * bool)
  | INT32 of (string * bool)
  | INT16 of (string * bool)
  | INT of (string * bool)
  | INLINE_FOR_EXTRACTION
  | INLINE
  | INCLUDE
  | IN
  | IMPLIES
  | IFF
  | IF
  | IEEE64 of (float)
  | IDENT of (string)
  | HASH
  | FUNCTION
  | FUN
  | FSDOC_STANDALONE of (fsdoc)
  | FSDOC of (fsdoc)
  | FORALL
  | FALSE
  | EXISTS
  | EXCEPTION
  | EQUALS
  | EOF
  | ENSURES
  | END
  | ELSE
  | EFFECT
  | DOT_LPAREN
  | DOT_LBRACK
  | DOT
  | DOLLAR
  | DISJUNCTION
  | DEFAULT
  | CONJUNCTION
  | COMMA
  | COLON_EQUALS
  | COLON_COLON
  | COLON
  | CHAR of (char)
  | BYTEARRAY of (bytes)
  | BEGIN
  | BAR_RBRACK
  | BAR
  | BANG_LBRACE
  | BACKTICK
  | ATTRIBUTES
  | ASSUME
  | ASSERT
  | AND
  | AMP
  | ACTIONS
  | ABSTRACT
type tokenId = 
    | TOKEN_WITH
    | TOKEN_WHEN
    | TOKEN_VAL
    | TOKEN_UNOPTEQUALITY
    | TOKEN_UNIV_HASH
    | TOKEN_UNIVAR
    | TOKEN_UNFOLDABLE
    | TOKEN_UNFOLD
    | TOKEN_UNDERSCORE
    | TOKEN_UINT8
    | TOKEN_UINT64
    | TOKEN_UINT32
    | TOKEN_UINT16
    | TOKEN_TYP_APP_LESS
    | TOKEN_TYP_APP_GREATER
    | TOKEN_TYPE
    | TOKEN_TVAR
    | TOKEN_TRY
    | TOKEN_TRUE
    | TOKEN_TOTAL
    | TOKEN_TILDE
    | TOKEN_THEN
    | TOKEN_SUB_EFFECT
    | TOKEN_SUBTYPE
    | TOKEN_SUBKIND
    | TOKEN_STRING
    | TOKEN_SQUIGGLY_RARROW
    | TOKEN_SEMICOLON_SEMICOLON
    | TOKEN_SEMICOLON
    | TOKEN_RPAREN
    | TOKEN_REQUIRES
    | TOKEN_REIFY
    | TOKEN_REIFIABLE
    | TOKEN_REFLECTABLE
    | TOKEN_REC
    | TOKEN_RBRACK
    | TOKEN_RBRACE
    | TOKEN_RARROW
    | TOKEN_QMARK_DOT
    | TOKEN_QMARK
    | TOKEN_PRIVATE
    | TOKEN_PRAGMA_SET_OPTIONS
    | TOKEN_PRAGMA_RESET_OPTIONS
    | TOKEN_PRAGMALIGHT
    | TOKEN_PIPE_RIGHT
    | TOKEN_PERCENT_LBRACK
    | TOKEN_OPPREFIX
    | TOKEN_OPINFIX4
    | TOKEN_OPINFIX3
    | TOKEN_OPINFIX2
    | TOKEN_OPINFIX1
    | TOKEN_OPINFIX0d
    | TOKEN_OPINFIX0c
    | TOKEN_OPINFIX0b
    | TOKEN_OPINFIX0a
    | TOKEN_OPEN
    | TOKEN_OPAQUE
    | TOKEN_OF
    | TOKEN_NOEXTRACT
    | TOKEN_NOEQUALITY
    | TOKEN_NEW_EFFECT_FOR_FREE
    | TOKEN_NEW_EFFECT
    | TOKEN_NEW
    | TOKEN_NAME
    | TOKEN_MUTABLE
    | TOKEN_MODULE
    | TOKEN_MINUS
    | TOKEN_MATCH
    | TOKEN_L_TRUE
    | TOKEN_L_FALSE
    | TOKEN_LPAREN_RPAREN
    | TOKEN_LPAREN
    | TOKEN_LOGIC
    | TOKEN_LET
    | TOKEN_LENS_PAREN_RIGHT
    | TOKEN_LENS_PAREN_LEFT
    | TOKEN_LBRACK_BAR
    | TOKEN_LBRACK_AT
    | TOKEN_LBRACK
    | TOKEN_LBRACE_COLON_PATTERN
    | TOKEN_LBRACE
    | TOKEN_LARROW
    | TOKEN_IRREDUCIBLE
    | TOKEN_INT8
    | TOKEN_INT64
    | TOKEN_INT32
    | TOKEN_INT16
    | TOKEN_INT
    | TOKEN_INLINE_FOR_EXTRACTION
    | TOKEN_INLINE
    | TOKEN_INCLUDE
    | TOKEN_IN
    | TOKEN_IMPLIES
    | TOKEN_IFF
    | TOKEN_IF
    | TOKEN_IEEE64
    | TOKEN_IDENT
    | TOKEN_HASH
    | TOKEN_FUNCTION
    | TOKEN_FUN
    | TOKEN_FSDOC_STANDALONE
    | TOKEN_FSDOC
    | TOKEN_FORALL
    | TOKEN_FALSE
    | TOKEN_EXISTS
    | TOKEN_EXCEPTION
    | TOKEN_EQUALS
    | TOKEN_EOF
    | TOKEN_ENSURES
    | TOKEN_END
    | TOKEN_ELSE
    | TOKEN_EFFECT
    | TOKEN_DOT_LPAREN
    | TOKEN_DOT_LBRACK
    | TOKEN_DOT
    | TOKEN_DOLLAR
    | TOKEN_DISJUNCTION
    | TOKEN_DEFAULT
    | TOKEN_CONJUNCTION
    | TOKEN_COMMA
    | TOKEN_COLON_EQUALS
    | TOKEN_COLON_COLON
    | TOKEN_COLON
    | TOKEN_CHAR
    | TOKEN_BYTEARRAY
    | TOKEN_BEGIN
    | TOKEN_BAR_RBRACK
    | TOKEN_BAR
    | TOKEN_BANG_LBRACE
    | TOKEN_BACKTICK
    | TOKEN_ATTRIBUTES
    | TOKEN_ASSUME
    | TOKEN_ASSERT
    | TOKEN_AND
    | TOKEN_AMP
    | TOKEN_ACTIONS
    | TOKEN_ABSTRACT
    | TOKEN_end_of_input
    | TOKEN_error
type nonTerminalId = 
    | NONTERM__startterm
    | NONTERM__startinputFragment
    | NONTERM_option_FSDOC_
    | NONTERM_option___anonymous_1_
    | NONTERM_option___anonymous_2_
    | NONTERM_option___anonymous_6_
    | NONTERM_option_ascribeKind_
    | NONTERM_option_ascribeTyp_
    | NONTERM_option_fsTypeArgs_
    | NONTERM_option_mainDecl_
    | NONTERM_option_pair_hasSort_simpleTerm__
    | NONTERM_option_string_
    | NONTERM_boption_SQUIGGLY_RARROW_
    | NONTERM_boption___anonymous_0_
    | NONTERM_loption_separated_nonempty_list_COMMA_appTerm__
    | NONTERM_loption_separated_nonempty_list_SEMICOLON_effectDecl__
    | NONTERM_loption_separated_nonempty_list_SEMICOLON_tuplePattern__
    | NONTERM_list___anonymous_4_
    | NONTERM_list___anonymous_7_
    | NONTERM_list_argTerm_
    | NONTERM_list_atomicTerm_
    | NONTERM_list_atomicUniverse_
    | NONTERM_list_constructorDecl_
    | NONTERM_list_decl_
    | NONTERM_list_decoration_
    | NONTERM_list_multiBinder_
    | NONTERM_nonempty_list_aqualified_lident__
    | NONTERM_nonempty_list_aqualified_lidentOrUnderscore__
    | NONTERM_nonempty_list_atomicPattern_
    | NONTERM_nonempty_list_atomicTerm_
    | NONTERM_nonempty_list_dotOperator_
    | NONTERM_nonempty_list_patternOrMultibinder_
    | NONTERM_separated_nonempty_list_AND_letbinding_
    | NONTERM_separated_nonempty_list_AND_pair_option_FSDOC__typeDecl__
    | NONTERM_separated_nonempty_list_BAR_tuplePattern_
    | NONTERM_separated_nonempty_list_COMMA_appTerm_
    | NONTERM_separated_nonempty_list_COMMA_atomicTerm_
    | NONTERM_separated_nonempty_list_COMMA_constructorPattern_
    | NONTERM_separated_nonempty_list_COMMA_tmEq_
    | NONTERM_separated_nonempty_list_COMMA_tvar_
    | NONTERM_separated_nonempty_list_DISJUNCTION_conjunctivePat_
    | NONTERM_separated_nonempty_list_SEMICOLON_appTerm_
    | NONTERM_separated_nonempty_list_SEMICOLON_effectDecl_
    | NONTERM_separated_nonempty_list_SEMICOLON_separated_pair_qlident_EQUALS_tuplePattern__
    | NONTERM_separated_nonempty_list_SEMICOLON_tuplePattern_
    | NONTERM_inputFragment
    | NONTERM_mainDecl
    | NONTERM_pragma
    | NONTERM_decoration
    | NONTERM_decl
    | NONTERM_rawDecl
    | NONTERM_typeDecl
    | NONTERM_typars
    | NONTERM_tvarinsts
    | NONTERM_typeDefinition
    | NONTERM_recordFieldDecl
    | NONTERM_constructorDecl
    | NONTERM_letbinding
    | NONTERM_newEffect
    | NONTERM_effectRedefinition
    | NONTERM_effectDefinition
    | NONTERM_actionDecls
    | NONTERM_effectDecl
    | NONTERM_subEffect
    | NONTERM_qualifier
    | NONTERM_maybeFocus
    | NONTERM_letqualifier
    | NONTERM_aqual
    | NONTERM_aqualUniverses
    | NONTERM_disjunctivePattern
    | NONTERM_tuplePattern
    | NONTERM_constructorPattern
    | NONTERM_atomicPattern
    | NONTERM_patternOrMultibinder
    | NONTERM_binder
    | NONTERM_multiBinder
    | NONTERM_binders
    | NONTERM_aqualified_lident_
    | NONTERM_aqualified_lidentOrUnderscore_
    | NONTERM_qlident
    | NONTERM_quident
    | NONTERM_path_lident_
    | NONTERM_path_uident_
    | NONTERM_ident
    | NONTERM_lidentOrOperator
    | NONTERM_lidentOrUnderscore
    | NONTERM_lident
    | NONTERM_uident
    | NONTERM_tvar
    | NONTERM_ascribeTyp
    | NONTERM_ascribeKind
    | NONTERM_kind
    | NONTERM_term
    | NONTERM_noSeqTerm
    | NONTERM_typ
    | NONTERM_trigger
    | NONTERM_disjunctivePats
    | NONTERM_conjunctivePat
    | NONTERM_simpleTerm
    | NONTERM_maybeFocusArrow
    | NONTERM_patternBranch
    | NONTERM_tmIff
    | NONTERM_tmImplies
    | NONTERM_tmArrow_tmFormula_
    | NONTERM_tmArrow_tmNoEq_
    | NONTERM_tmFormula
    | NONTERM_tmConjunction
    | NONTERM_tmTuple
    | NONTERM_tmEq
    | NONTERM_tmNoEq
    | NONTERM_refineOpt
    | NONTERM_recordExp
    | NONTERM_simpleDef
    | NONTERM_appTerm
    | NONTERM_argTerm
    | NONTERM_indexingTerm
    | NONTERM_atomicTerm
    | NONTERM_atomicTermQUident
    | NONTERM_atomicTermNotQUident
    | NONTERM_opPrefixTerm_atomicTermNotQUident_
    | NONTERM_opPrefixTerm_atomicTermQUident_
    | NONTERM_projectionLHS
    | NONTERM_fsTypeArgs
    | NONTERM_qidentWithTypeArgs_qlident_option_fsTypeArgs__
    | NONTERM_qidentWithTypeArgs_quident_some_fsTypeArgs__
    | NONTERM_hasSort
    | NONTERM_constant
    | NONTERM_universe
    | NONTERM_universeFrom
    | NONTERM_atomicUniverse
    | NONTERM_univar
    | NONTERM_some_fsTypeArgs_
    | NONTERM_right_flexible_list_SEMICOLON_noSeqTerm_
    | NONTERM_right_flexible_list_SEMICOLON_recordFieldDecl_
    | NONTERM_right_flexible_list_SEMICOLON_simpleDef_
    | NONTERM_right_flexible_nonempty_list_SEMICOLON_recordFieldDecl_
    | NONTERM_right_flexible_nonempty_list_SEMICOLON_simpleDef_
    | NONTERM_reverse_left_flexible_list_BAR___anonymous_5_
    | NONTERM_reverse_left_flexible_nonempty_list_BAR_patternBranch_
/// This function maps tokens to integer indexes
val tagOfToken: token -> int

/// This function maps integer indexes to symbolic token ids
val tokenTagToTokenId: int -> tokenId

/// This function maps production indexes returned in syntax errors to strings representing the non terminal that would be produced by that production
val prodIdxToNonTerminal: int -> nonTerminalId

/// This function gets the name of a token as a string
val token_to_string: token -> string
val term : (Microsoft.FSharp.Text.Lexing.LexBuffer<'cty> -> token) -> Microsoft.FSharp.Text.Lexing.LexBuffer<'cty> -> (term) 
val inputFragment : (Microsoft.FSharp.Text.Lexing.LexBuffer<'cty> -> token) -> Microsoft.FSharp.Text.Lexing.LexBuffer<'cty> -> (inputFragment) 
