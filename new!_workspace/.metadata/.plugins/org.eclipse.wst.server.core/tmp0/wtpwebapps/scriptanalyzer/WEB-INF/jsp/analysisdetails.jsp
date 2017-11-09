<%@page contentType="text/html" pageEncoding="UTF-8" session="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="f" %>
<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Script Analyser</title>

    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet">
     <link href="https://cdnjs.cloudflare.com/ajax/libs/startbootstrap-sb-admin-2/3.3.7+1/css/sb-admin-2.css" rel="stylesheet"> 
     <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet">  

    <link href="https://fonts.googleapis.com/css?family=Lobster" rel="stylesheet">
   <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.0/jquery.min.js"></script>
     
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
  <!--  <script src="https://cdnjs.cloudflare.com/ajax/libs/startbootstrap-sb-admin-2/3.3.7+1/js/sb-admin-2.js"></script>-->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/metisMenu/2.7.0/metisMenu.js"></script>
    <script language="javascript" type="text/javascript" src="viz.js"></script>
    <script language="javascript" type="text/javascript" src="site.js"> </script>
    <script src="http://code.jquery.com/jquery-1.9.1.js"></script>
  <script src="http://malsup.github.com/jquery.form.js"></script>
    <style type="text/css">

    .h{
        max-height: 100px;
        overflow-y:scroll;
    }
    </style>
 
       <script>
       var arrResponse;
       window.onload = function() {
    	arrResponse=${data};
    	   var obj=arrResponse;
    	  // document.getElementById("hd").innerHTML = "Fileconten"t;
    	      	 //  document.getElementById("hd").sytle.color = "red";

    	   document.getElementById("hd").innerHTML = "FileContent";

    	   document.getElementById("inputTextToSave").innerHTML = arrResponse.fileContent;
            var mainUL=document.getElementById("c");
           // alert( obj.codeBlocks.length);
           // var text=document.getElementById("inputTextToSave");
          //  text.document.createTextNode(arrResponse.fileContent);
       
           for(i=0;i<arrResponse.codeBlocks.length;i++)
        	{
        	   var para = document.createElement("li");
        	   
        	   //var dtext="<a href=# onclick=source("+i+")>Code Block &nbsp"+ arrResponse.codeBlocks[i].cbid +""+ arrResponse.codeBlocks[i].lineno +" </a>";
        	   var a = document.createElement('a');
        	   var linkText = document.createTextNode("Code Block "+ arrResponse.codeBlocks[i].cbid +"  ["+ arrResponse.codeBlocks[i].lineno +"  ]");
        	   a.appendChild(linkText);
        	   a.setAttribute('onclick','source('+i+')');
        	   a.href = "#";
        	   para.appendChild(a);
        	   mainUL.appendChild(para);
        	
        	}
    	 };
    	 function UpdateGraphviz(index) {
    		  var svg_div=document.getElementById("graphviz_svg_div1");
    	        // alert("hello");
    		    var data = arrResponse.codeBlocks[index].graph;
    		    // Generate the Visualization of the Graph into "svg".
    		    var svg = Viz(data, "svg");
    		    svg_div.innerHTML="<hr>"+svg;
    		    document.getElementById("graphviz_svg_div").innerHTML="";
    		  }
    	 function getSVG(){
    		 var e = document.createElement('script');
       		e.setAttribute('src', 'https://nytimes.github.io/svg-crowbar/svg-crowbar.js'); 
       		e.setAttribute('class', 'svg-crowbar');
       		document.body.appendChild(e);
    	 }
    
 	   
    	 function comGraph() {
    		 
    		 document.getElementById('graphviz_svg_div1').style.display = 'none';
    		    document.getElementById('graphviz_svg_div').style.display = 'Block';
      		  var svg_div=document.getElementById("graphviz_svg_div");
      	         //alert("hello");
      	      var data = arrResponse.completeGraph;
      	    document.getElementById("hd").innerHTML = "FileContent";
      	    document.getElementById("inputTextToSave").innerHTML = arrResponse.fileContent;
      		    // Generate the Visualization of the Graph into "svg".
      		   // alert(data);
      		    var svg = Viz(data, "svg");
      		    svg_div.innerHTML="<hr>"+svg;
      		// add these lines in showdata()
      	   		var srctables="",tgttables="",stdalntables="";
      	   		      	  for (i = 0; i < arrResponse.srctableList.length; i++)                             
      	   		          { 
      	   		          srctables += "&nbsp &nbsp &nbsp"+arrResponse.srctableList[i]+ "<br>";
      	   		          }                                
      	   		         document.getElementById("sourcetables").innerHTML = srctables;
      	   		   
      	   		//target tables
      	   				for (i = 0; i < arrResponse.tartableList.length; i++)                             
      	   		          { 
      	   		          tgttables += "&nbsp &nbsp &nbsp"+arrResponse.tartableList[i]+ "<br>";
      	   		          }                                
      	   		         document.getElementById("targettables").innerHTML = tgttables;
      	   		        document.getElementById("stdalonetables").innerHTML = stdalntables;
      	   		   document.getElementById("graphviz_svg_div1").innerHTML="";
      		  }
       	 
       	 
      
    	 
   
    	    function showData()
    	     {
    	    	var arrResponse=${data};
   	    POST('showdata', {"a":"aa"}); 
   	    
    	     }
    	  
function source(index)
{
	//$(".graphviz_svg_div").hide();
	
	document.getElementById('graphviz_svg_div').style.display = 'none';
    document.getElementById('graphviz_svg_div1').style.display = 'Block';
	//arrResponse.codeBlocks[index].cbid.sytle.color="red";
	
			document.getElementById("hd").innerHTML = "CodeBlock"+ arrResponse.codeBlocks[index].cbid;
			 var i,j,k,l,srctables="",tgttables="",stdalntables="",graphdata="";
             
             UpdateGraphviz(index);

			var temp="";
             
             //System.out.println(arrResponse.codeBlocks[index].query.length);
 			for ( i=0;i< arrResponse.codeBlocks[index].query.length; i++){
 			temp = temp + arrResponse.codeBlocks[index].query[i]+ '\n';
 			}
 			//alert(temp);
             //document.getElementById("inputTextToSave").innerHTML = arrResponse.codeBlocks[index].query;
             document.getElementById("inputTextToSave").innerHTML = temp; 
            
            //alert(obj.codeBlocks[index].query);
             
            //alert(obj.codeBlocks[index].dbSrcTables.lsength);
              //source tables
              for (i = 0; i < arrResponse.codeBlocks[index].dbSrcTables.length; i++)                             
               { 
               srctables += "&nbsp &nbsp &nbsp"+arrResponse.codeBlocks[index].dbSrcTables[i]+ "<br>";
               }                                
              document.getElementById("sourcetables").innerHTML = srctables;
        
	//target tables
             for (j = 0; j < arrResponse.codeBlocks[index].dbTargetTables.length; j++)                             
              { 
               if((arrResponse.codeBlocks[index].dbTargetTables)!=""){

                  tgttables += "&nbsp &nbsp &nbsp"+arrResponse.codeBlocks[index].dbTargetTables[j]+"&nbsp &nbsp &nbsp &nbsp"+ "<span class=\"label label-success \">"+arrResponse.codeBlocks[index].action +"</span><br>";
               }
              
              }
             document.getElementById("targettables").innerHTML = tgttables;
	
             document.getElementById("stdalonetables").innerHTML = stdalntables;
             //standalone tables
             for (k = 0; k < arrResponse.codeBlocks[index].dbStAloneTables.length; k++)                             
              { 

               if((arrResponse.codeBlocks[index].dbStAloneTables)!=""){

              stdalntables += "&nbsp &nbsp &nbsp"+arrResponse.codeBlocks[index].dbStAloneTables[k]+"&nbsp &nbsp &nbsp &nbsp <span class=\"label label-success \">"+arrResponse.codeBlocks[index].action +"</span><br>";
              }                                                         
             document.getElementById("stdalonetables").innerHTML = stdalntables;

         }
           
	}
// custom form method

function POST(path, params, method) {
    method = method || "post"; // Set method to post by default if not specified.

    // The rest of this code assumes you are not using a library.
    // It can be made less wordy if you use one.
    var form = document.createElement("form");
    form.setAttribute("method", method);
    form.setAttribute("action", path);

    for(var key in params) {
        if(params.hasOwnProperty(key)) {
            var hiddenField = document.createElement("input");
            hiddenField.setAttribute("type", "hidden");
            hiddenField.setAttribute("name", key);
            hiddenField.setAttribute("value", params[key]);
			//alert( key);

//alert( params[key]);
            form.appendChild(hiddenField);
         }
    }

    document.body.appendChild(form);
    form.submit();
} 

</script>
           
    
</head>

<body>
    <div id="wrapper">

        <!-- Navigation -->

             <label class="navbar-brand" href="home.html" style="font-family: 'Lobster', cursive; margin-top:0px;margin-left:0px;font-size:35px; color:#fff;height=20px">
                <span style="color:#000000;">Script Analyzer</span>
            </label>
            <div class="navbar-default sidebar" role="navigation">
               <div class="sidebar-nav navbar-collapse">
                    <ul class="nav" id="side-menu" >
                        <li>
                            <a href="#" style="color:#F44336;"><i class="fa fa-circle-o fa-fw"></i>Code Blocks<span class="fa arrow"></span></a>
                            <ul class="nav nav-second-level collapse in h" id="c">
	                            
                            </ul>
             </li>
                        <li>
                            <a href="#" style="color:#01579B"><i class="fa fa-circle-o fa-fw"></i>Source Tables<span class="fa arrow">                             </span></a>
                            <ul class="nav nav-second-level collapse in h" id="sourcetables">
                      
                     
                
                            </ul>                            
                            <!-- /.nav-second-level -->
                        </li>
                        <li>
                            <a href="#" style="color:#1B5E20"><i class="fa fa-circle-o fa-fw"></i>Target Tables<span class="fa arrow">                             </span></a>
                            <ul class="nav nav-second-level collapse in h" id="targettables"><li id="d"></li>
                            </ul>                            
                        </li>
                        <li>
                            <a href="#" style="color:#BF360C;"><i class="fa fa-circle-o fa-fw"></i>Table Created/Deleted<span class="fa arrow"></span></a>
                            <ul class="nav nav-second-level collapse in h" id="stdalonetables">
                            </ul>
                            <br><br>
           <center>
           <button id="generate_btn1" class="btn btn-primary btn-outline btn-block"  disabled style="font-size: 100%" onclick="comGraph()">name="Show Diagram(Complete)"
           </button>
           </center>  
            <br>
            <form action="/scriptanalyzer" method="post" id="analyzedifffile">
            <center>
            <button type="submit" class="btn btn-primary btn-outline btn-block">Analyze Different File</button>
            
           <!--   <center>
								<a href="index.jsp" class="btn btn-primary btn-outline btn-lg">Analyze
									Differenttt File</a>
						</center> <br>-->
					      </center>      
			</form>
		                  
               			<center><br>
					<button class="btn btn-primary btn-outline btn-block" value="data" onclick="showData()">Consolidated Table List</button> 
					<button class="btn btn-primary btn-outline btn-block" onclick="getSVG()">export image</button> 
                         <!--  <a href="../displayTable.jsp">Consolidated Table List</a>-->
                            
                            <!-- /.nav-second-level -->
                        </li>
                    </ul>
                </div>
                <!-- /.sidebar-collapse -->
            </div>
            <!-- /.navbar-static-side -->
        </nav>

        <div id="page-wrapper"><br>
        <div id="hd" class="row btn-primary" ></div>
        <div class="row">
          <div class="form-group">           
            <textarea id="inputTextToSave" rows="10 " class="form-control" readonly> </textarea>
            </div>
        </div> 
               <!--   <button id="generate_btn" class="btn btn-primary btn-outline btn-lg" name="Show Diagram(Code Block Wise)" disabled style="font-size: 100%"><b>Loading...</b></button>
                &nbsp;&nbsp;
                <button id="generate_btn1" class="btn btn-primary btn-outline btn-lg" name="Show Diagram(Complete)" disabled style="font-size: 100%"><b>Loading...</b>
                </button> 
             <textarea id="graphviz_data" rows="5" cols="80" width="100%" wrap="off" hidden ></textarea>
            <textarea id="graphviz_data1" rows="5" cols="80" width="100%" wrap="off" hidden></textarea>
           	 <script>
            //complete diagram 
			
            </script>-->
    
        <!-- /#page-wrapper --> 
        <div id="graphviz_svg_div">
  <!-- Target for dynamic svg generation -->
        </div>
    <div id="graphviz_svg_div1">
  <!-- Target for dynamic svg generation -->
        </div>
        </div>
    </div>
    <!-- /#wrapper -->
  
  
  

</body>

</html>