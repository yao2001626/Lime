Grammar Lime;

options{
  output = AST;
  ASTLabelType = CTree;
}

r 
  : calss_declaration+ EOF  -> ^(FILE class_declaration+)
  ;
class_declaration
  : Class Indetifier (attribute | initialization | method | action )* End -> ^( CLASS {$Identifier.id} attribute* initialization * method* action*)
  ;
attribute
  : Attribute varList -> varList
  ;
initialization
  : Initialization '(' varList? ')' statement -> ^(INIT varList? statement)
  ;
method
  : Method Identifier ('('varList ')')? (':' typeList)? (When expression Do)? statement
  -> ^(METHOD {$Identifier.id} varList? typeList? expression? statement)
  ;
action
  : Action (Identifier)? (When expression Do)? statement
    ->^(ACTION expression statement)
  ;
statement
  :compound_statement
  |assignment_expression
  |postfix_expression
  |Return expressionRoot  -> ^(RETURN expressionRoot)
  |If expressionRoot Then s1=statement (Else s2=statement)? ->^(IF expressionRoot $s1 $s2?)
  |While expressionRoot Do statement -> ^(WHILE expressionRoot statement)
  ;
  
expressionRoot
  : expression -> ^(EXPR expression)
  ;
expression 
  : conditional_expression 
  ;
condtional_expression
  : relational_expression (('=='|'!=')^ relational_expression)?
  ;
relational_expression
  : additive_expression (('<'|'>'|'<='|'>=')^ additive_expression)*
  ;
additive_expression
  : postfix_expression (('+'|'-')^ postfix_expression)*
  ;
postive_expression
  : (primary_expression -> primary_expression)
    (
      '('argument_expression_list ')' -> ^(CALL $postive_expression argument_expression_list)
    | '('')' -> ^(CALL $postive_expression)
    )
  ;
  
argument_expression_list
  : expression (',' expression )* -> ^(ELIST expression+)
  ;
  
primary_expression
  : Identifier
  |String
  |Int
  |'('expression ')' -> expression
  ;
