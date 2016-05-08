
tree grammar LimeTree;

options {
    tokenVocab=LimeParser;
    ASTLabelType=LimeAST;
    output=template;
}

@header {
    package lime.antlr3;
}

@members {
    SymbolTable symtab;
    Scope currentScope;
    public LimeTree(TreeNodeStream input, SymbolTable symtab) {
        this(input);
        this.symtab = symtab;
        currentScope = symtab.globals;
    }

    int reg = 1;
    public int getreg() { return reg++; }

    List<LimeString> strings = new ArrayList<LimeString>();
    public int getstr(String s) {
    	strings.add(new LimeString(s));
    	return strings.size();
    }
}

translationunit
	:	^(FILE d+=classdecl+) 
		-> file(decls={$d})
	;
classdecl
	: ^(CLASS c=ID (^(INHERIT ID))? ^( MEMBERS m+=classMember+ ))
		-> def_class(sym={$c.symbol}, member={$m} )
	;
classMember
	:	attrDeclaration->{$attrDeclaration.st}
	|	methodDeclaration->{$methodDeclaration.st}
	;
attrDeclaration
	: 	^(ATTR  ID  t=type)
		->def_attr(id={$ID.text}, type= {$t.text})
	;

methodDeclaration
	:	^(METHOD ID (^(ARGS_DECL p+=parameterdecl+))? type expr? block)
		->def_method(sym={$ID.symbol}, args={$p}, block={$block.st})
	;

type
	:	Inttype
    	|	Voidtype
    	|	ID
    	;

vardecl
	:	^(VAR ID type)
		->def_var(id={$ID.text}, type={$type.text})
	;

parameterdecl
	:	^(ARG ID type)
		->def_arg(id={$ID.text}, type={$type.text})
	;

statement
@after {$st.setAttribute("descr", $text.replaceAll("\\n"," "));}
	:	compound
	|	^(ASSIGN ID expression) -> assign(id={$ID.text}, rhs={$expression.st})
	|	call -> {$call.st}
	|	^(Return expression) -> return(v={$expression.st})
	|	^(If expression s1=statement s2=statement?)
		-> if(cond={$expression.st}, stat1={$s1.st}, stat2={$s2.st}, tmp={getreg()})
	|	^(While expression s=statement)
		-> while(cond={$expression.st}, stat={$s.st}, tmp={getreg()})
	;
compound
	:	^(BLOCK s+=statement*) -> block( stats={$s})
	;

expression
	:	^(EXPR expr) -> {$expr.st}
	;

expr returns [Type type]
@after {
//System.out.println("expr: "+$st);
}
	:	^(( Equals | NEquals | Add | Subtract | Multiply | LT |GT ) a=expr b=expr)
		-> bop(reg={getreg()}, op={$start.token}, a={$a.st}, b={$b.st})
  	|	call {$call.st.setAttribute("descr", $text);} -> {$call.st}
	|	primary {$type=$primary_expression.type;} -> {$primary_expression.st}
	;


call
  :	^(CALL ID ( ^(ELIST e+=expr+) )?)
		-> call(reg={getreg()}, sym={$ID.symbol}, args={$e})
	;
primary returns [Type type]
	: ID {$type = $ID.symbol.type;}
				-> loadvar(reg={getreg()}, id={$ID})
	| INT {$type = (Type)symtab.globals.resolve("int");}
				-> int(reg={getreg()}, v={$INT.text})
	;
