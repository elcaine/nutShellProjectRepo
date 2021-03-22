%{

}%

DIGIT[0 - 9]
META []

% %

{DIGIT}*		return NUMBER_LITERAL;
true|false		return BOOLEAN_LITERAL;
null			return NULL_LITERAL;
{META}			return META;