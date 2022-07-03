package org.vlang.lang;

import com.intellij.lexer.FlexLexer;
import com.intellij.psi.tree.IElementType;
import org.vlang.lang.VlangTypes;
import static com.intellij.psi.TokenType.BAD_CHARACTER;
import static org.vlang.lang.VlangParserDefinition.*;

%%

%{
  public _VlangLexer() {
    this((java.io.Reader)null);
 }
%}

%class _VlangLexer
%implements FlexLexer, VlangTypes
%unicode
%public

%function advance
%type IElementType

NL = \n
WS = [ \t\f]

LINE_COMMENT = "//" [^\r\n]*
LANGUAGE_INJECTION_COMMENT = "#" [^\r\n]*
MULTILINE_COMMENT = "/*" ( ([^"*"]|[\r\n])* ("*"+ [^"*""/"] )? )* ("*" | "*"+"/")?

LETTER = [:letter:] | "_"
DIGIT =  [:digit:]

HEX_DIGIT = [0-9A-Fa-f_]
INT_DIGIT = [0-9_]
OCT_DIGIT = [0-7_]
BIN_DIGIT = [0-1_]

NUM_INT = "0" | ([1-9] {INT_DIGIT}*)
NUM_HEX = ("0x" | "0X") {HEX_DIGIT}+
NUM_OCT = "0o" {OCT_DIGIT}+
NUM_BIN = "0b" {BIN_DIGIT}+

FLOAT_EXPONENT = [eE] [+-]? {INT_DIGIT}+
NUM_FLOAT = ( ( ({INT_DIGIT}+ "." {INT_DIGIT}*) | ({INT_DIGIT}* "." {INT_DIGIT}+) ) {FLOAT_EXPONENT}?) | ({INT_DIGIT}+ {FLOAT_EXPONENT})

IDENT = {LETTER} ({LETTER} | {DIGIT} )*
SPECIAL_IDENT = ("JS." | "C.") {LETTER} ({LETTER} | {DIGIT} | "." )*

STR_DOUBLE =   "\""
STR_SINGLE =   "'"
STR_MODIFIER = "r" | "c"
STRING_DOUBLE = {STR_MODIFIER}? {STR_DOUBLE} ( [^\"\\\n\r] | "\\" ("\\" | {STR_DOUBLE} | {ESCAPES} | [0-8xuU] ) )* {STR_DOUBLE}
STRING_SINGLE = {STR_MODIFIER}? {STR_SINGLE} ( [^\'\\\n\r] | "\\" ("\\" | {STR_SINGLE} | {ESCAPES} | [0-8xuU] ) )* {STR_SINGLE}
ESCAPES = [abfnrtve] // TODO: need "e"?

STR_ANGLE_OPEN =   "<"
STR_ANGLE_CLOSE =  ">"
C_STRING_DOUBLE = {STR_DOUBLE} ( [^\"\\\n\r] | "\\" ("\\" | {STR_DOUBLE} | {ESCAPES} | [0-8xuU] ) )* {STR_DOUBLE}
C_STRING_ANGLE = {STR_ANGLE_OPEN} ([^\<\>\\\n\r])* {STR_ANGLE_CLOSE}

%state MAYBE_SEMICOLON
%state C_STRING_LITERAL
%state C_FLAG_VALUE_EXPECTED

%%

<YYINITIAL> {
{WS}                                      { return WS; }
{NL}+                                     { return NLS; }

{LINE_COMMENT}                            { return LINE_COMMENT; }
{MULTILINE_COMMENT}                       { return MULTILINE_COMMENT; }

{STRING_DOUBLE}                           { yybegin(MAYBE_SEMICOLON); return STRING; }
{STRING_SINGLE}                           { yybegin(MAYBE_SEMICOLON); return STRING; }

//"'\\'"                                    { yybegin(MAYBE_SEMICOLON); return BAD_CHARACTER; }
//"'" [^\\] "'"?                            { yybegin(MAYBE_SEMICOLON); return CHAR; }
//"'" \n "'"?                               { yybegin(MAYBE_SEMICOLON); return CHAR; }
//"'\\" [abfnrtv\\\'] "'"?                  { yybegin(MAYBE_SEMICOLON); return CHAR; }
//"'\\"  {OCT_DIGIT} {3} "'"?               { yybegin(MAYBE_SEMICOLON); return CHAR; }
//"'\\x" {HEX_DIGIT} {2} "'"?               { yybegin(MAYBE_SEMICOLON); return CHAR; }
//"'\\u" {HEX_DIGIT} {4} "'"?               { yybegin(MAYBE_SEMICOLON); return CHAR; }
//"'\\U" {HEX_DIGIT} {8} "'"?               { yybegin(MAYBE_SEMICOLON); return CHAR; }

"`" [^`]* "`"?                            { yybegin(MAYBE_SEMICOLON); return RAW_STRING; }
"..."                                     { return TRIPLE_DOT; }
".."                                      { return RANGE; }
"."                                       { return DOT; }
"|"                                       { return BIT_OR; }
"{"                                       { return LBRACE; }
"}"                                       { yybegin(MAYBE_SEMICOLON); return RBRACE; }

"["                                       { return LBRACK; }
"]"                                       { yybegin(MAYBE_SEMICOLON); return RBRACK; }

"("                                       { return LPAREN; }
")"                                       { yybegin(MAYBE_SEMICOLON); return RPAREN; }

":"                                       { return COLON; }
";"                                       { return SEMICOLON; }
","                                       { return COMMA; }

"=="                                      { return EQ; }
"="                                       { return ASSIGN; }

"!="                                      { return NOT_EQ; }
"!"                                       { return NOT; }
"?"                                       { return QUESTION; }

"++"                                      { yybegin(MAYBE_SEMICOLON); return PLUS_PLUS; }
"+="                                      { return PLUS_ASSIGN; }
"+"                                       { return PLUS; }

"--"                                      { yybegin(MAYBE_SEMICOLON); return MINUS_MINUS; }
"-="                                      { return MINUS_ASSIGN; }
"-"                                       { return MINUS; }

"||"                                      { return COND_OR; }
"|="                                      { return BIT_OR_ASSIGN; }

"&^="                                     { return BIT_CLEAR_ASSIGN; }
"&^"                                      { return BIT_CLEAR; }
"&&"                                      { return COND_AND; }

"&="                                      { return BIT_AND_ASSIGN; }
"&"                                       { return BIT_AND; }

"<<="                                     { return SHIFT_LEFT_ASSIGN; }
"<<"                                      { return SHIFT_LEFT; }
"<-"                                      { return SEND_CHANNEL; }
"<="                                      { return LESS_OR_EQUAL; }
"<"                                       { return LESS; }

"^="                                      { return BIT_XOR_ASSIGN; }
"^"                                       { return BIT_XOR; }

"*="                                      { return MUL_ASSIGN; }
"*"                                       { return MUL; }

"/="                                      { return QUOTIENT_ASSIGN; }
"/"                                       { return QUOTIENT; }

"%="                                      { return REMAINDER_ASSIGN; }
"%"                                       { return REMAINDER; }

">>="                                     { return SHIFT_RIGHT_ASSIGN; }
">>"                                      { return SHIFT_RIGHT; }
">="                                      { return GREATER_OR_EQUAL; }
">"                                       { return GREATER; }

":="                                      { return VAR_ASSIGN; }

"#include"                                { yybegin(C_STRING_LITERAL); return C_INCLUDE; }
"#flag"                                   { yybegin(C_FLAG_VALUE_EXPECTED); return C_FLAG; }

"$if"                                     { return IF_COMPILE_TIME ; }
"$else"                                   { return ELSE_COMPILE_TIME ; }

"assert"                                  { return ASSERT; }
"break"                                   { yybegin(MAYBE_SEMICOLON); return BREAK; }
"fallthrough"                             { yybegin(MAYBE_SEMICOLON); return FALLTHROUGH; }
"return"                                  { yybegin(MAYBE_SEMICOLON); return RETURN ; }
"continue"                                { yybegin(MAYBE_SEMICOLON); return CONTINUE ; }

"unsafe"                                  { return UNSAFE; }
"default"                                 { return DEFAULT; }
"module"                                  { return MODULE; }
"pub"                                     { return PUB; }
"fn"                                      { return FN; }
"interface"                               { return INTERFACE; }
"select"                                  { return SELECT; }

"case"                                    { return CASE; }
"defer"                                   { return DEFER; }
"go"                                      { return GO; }

//"chan"                                    { return CHAN; }

"struct"                                  { return STRUCT; }
"enum"                                    { return ENUM; }
"else"                                    { return ELSE; }
"goto"                                    { return GOTO; }
"switch"                                  { return SWITCH; }
"const"                                   { return CONST; }

"match"                                   { return MATCH ; }
"if"                                      { return IF ; }
"for"                                     { return FOR ; }
"import"                                  { return IMPORT ; }
"as"                                      { return AS ; }

"in"                                      { return IN; }
"type"                                    { return TYPE_; }
"mut"                                     { return MUT; }

"__global"                                { return BUILTIN_GLOBAL; }

{LANGUAGE_INJECTION_COMMENT}              { yybegin(MAYBE_SEMICOLON); return LANGUAGE_INJECTION; }

{SPECIAL_IDENT}                           { yybegin(MAYBE_SEMICOLON); return IDENTIFIER; }
{IDENT}                                   { yybegin(MAYBE_SEMICOLON); return IDENTIFIER; }

{NUM_FLOAT}"i"                            { yybegin(MAYBE_SEMICOLON); return FLOATI; }
{NUM_FLOAT}                               { yybegin(MAYBE_SEMICOLON); return FLOAT; }
{DIGIT}+"i"                               { yybegin(MAYBE_SEMICOLON); return DECIMALI; }
{NUM_BIN}                                 { yybegin(MAYBE_SEMICOLON); return BIN; }
{NUM_OCT}                                 { yybegin(MAYBE_SEMICOLON); return OCT; }
{NUM_HEX}                                 { yybegin(MAYBE_SEMICOLON); return HEX; }
{NUM_INT}                                 { yybegin(MAYBE_SEMICOLON); return INT; }

.                                         { return BAD_CHARACTER; }
}

<MAYBE_SEMICOLON> {
{WS}                                      { return WS; }
{NL}                                      { yybegin(YYINITIAL); yypushback(yytext().length()); return SEMICOLON_SYNTHETIC; }
{LINE_COMMENT}                            { return LINE_COMMENT; }
{MULTILINE_COMMENT}                       { return MULTILINE_COMMENT; }
.                                         { yybegin(YYINITIAL); yypushback(yytext().length()); }
}

<C_STRING_LITERAL> {
{NL}+                                     { yybegin(YYINITIAL); return NLS; }
{WS}{NL}                                  { yybegin(YYINITIAL); return WS; }
{WS}                                      { return WS; }
{C_STRING_DOUBLE}                         { yybegin(MAYBE_SEMICOLON); return STRING; }
{C_STRING_ANGLE}                          { yybegin(MAYBE_SEMICOLON); return STRING; }
.                                         { yybegin(YYINITIAL); yypushback(yytext().length()); }
}

<C_FLAG_VALUE_EXPECTED> {
{NL}+                                     { yybegin(YYINITIAL); return NLS; }
{WS}{NL}                                  { yybegin(YYINITIAL); return WS; }
{WS}                                      { return WS; }
[^\r\n]+                                  { yybegin(MAYBE_SEMICOLON); return C_FLAG_VALUE; }
.                                         { yybegin(YYINITIAL); yypushback(yytext().length()); }
}