#!/bin/zsh

rm *.py
rm *.tokens
rm *.interp


antlr4 BSLParser.g4 BSLLexer.g4 BSLMethodDescriptionParser.g4 BSLMethodDescriptionLexer.g4 -Dlanguage=Python3 -visitor


N=8
total_lines=$(wc -l < BSLLexer.py)
lines_to_keep=$((total_lines - N))
head -n $lines_to_keep BSLLexer.py > tempfile && mv tempfile BSLLexer.py

total_lines=$(wc -l < BSLMethodDescriptionLexer.py)
lines_to_keep=$((total_lines - N))
head -n $lines_to_keep BSLMethodDescriptionLexer.py > tempfile && mv tempfile BSLMethodDescriptionLexer.py


echo "from antlr4 import ParserRuleContext as BSLParserRuleContext" > tempfile
cat BSLParser.py >> tempfile
mv tempfile BSLParser.py

echo "from antlr4 import ParserRuleContext as BSLParserRuleContext" > tempfile
cat BSLMethodDescriptionParser.py >> tempfile
mv tempfile BSLMethodDescriptionParser.py

