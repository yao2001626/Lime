

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
	:	^(('=='|'!='|'+'|'-'|'*'|'/'|'<'|'>'|'<='|'>=') a=expr b=expr)
		-> bop(reg={getreg()}, op={$start.token}, a={$a.st}, b={$b.st})
  |	call {$call.st.setAttribute("descr", $text);} -> {$call.st}
	|	primary {$type=$primary_expression.type;}
						   -> {$primary_expression.st}
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
