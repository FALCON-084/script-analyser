/* Generated By:JavaCC: Do not edit this line. CCJSqlParserDefaultVisitor.java Version 7.0.2 */
package com.ust.lib.jsqlparser.parser;

public class CCJSqlParserDefaultVisitor implements CCJSqlParserVisitor{
  public Object defaultVisit(SimpleNode node, Object data){
    node.childrenAccept(this, data);
    return data;
  }
  public Object visit(SimpleNode node, Object data){
    return defaultVisit(node, data);
  }
}
/* JavaCC - OriginalChecksum=88664d3a23923776a714669df3fe0fcf (do not edit this line) */
