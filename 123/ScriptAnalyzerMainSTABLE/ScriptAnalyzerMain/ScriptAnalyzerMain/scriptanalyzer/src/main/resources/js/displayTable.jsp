@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<style>
table {
    font-family: arial, sans-serif;
    border-collapse: collapse;
    width: 100%;
}
td, th {
    border: 1px solid #dddddd;
    text-align: left;
    padding: 8px;
}

<script language = "javascript" >
      
var   arrResponse=${data};
         var i = 0;
         document.writeln("<table>");
            document.writeln("<tr><td><b>Code Block</b></td>");
    document.writeln("<td><b>Action</b></td>");
            document.writeln("<td><b>Source Table</b></td>");
    document.writeln("<td><b>Target Table</b></td>");
   document.writeln("<td><b>Standalone Table</b></td></tr>");
          <c:forEach var="codeBlocksValue" items="${data.codeBlocks}.length>  
    
document.writeln("<tr><td width = 50>" + arrResponse.codeBlocks[i].cbid+"</td>");
   document.writeln("<td width = 50>" + arrResponse.codeBlocks[i].action +"</td>");
   document.writeln("<td width = 50>" + arrResponse.codeBlocks[i]..dbSrcTables +"</td>");
   document.writeln("<td width = 50>" + arrResponse.codeBlocks[i].dbTargetTables +"</td>");
   document.writeln("<td width = 50>" + arrResponse.codeBlocks[i].dbStAloneTables +"</td></tr>");
</c:forEach>  
      
              document.writeln("</table>");
      </script>
</style>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Displaying JSON as Table</title>
</head>
<body>
</body>
</html>