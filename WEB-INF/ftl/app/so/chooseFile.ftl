<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>选择上传文件</title>
<script src="${BasePath}/js/jquery-1.4.2.min.js"></script>
</head>
<style type="text/css">
*{margin:0;padding:0;} 
a{text-decoration:none;} 
.btn_addPic{ 
display: block; 
position: relative; 
width: 140px; 
height: 39px; 
overflow: hidden; 
border: 1px solid #EBEBEB; 
background: none repeat scroll 0 0 #F3F3F3; 
color: #999999; 
cursor: pointer; 
text-align: center; 
} 
.btn_addPic span{display: block;line-height: 39px;} 
.btn_addPic em { 
background:url(http://p7.qhimg.com/t014ce592c1a0b2d489.png) 0 0; 
display: inline-block; 
width: 18px; 
height: 18px; 
overflow: hidden; 
margin: 10px 5px 10px 0; 
line-height: 20em; 
vertical-align: middle; 
} 
.btn_addPic:hover em{background-position:-19px 0;} 
.filePrew { 
display: block; 
position: absolute; 
top: 0; 
left: 0; 
width: 140px; 
height: 39px; 
font-size: 100px; /* 增大不同浏览器的可点击区域 */ 
opacity: 0; /* 实现的关键点 */ 
filter:alpha(opacity=0);/* 兼容IE */ 
} 

    * {
        margin:0;
        padding:0;
    }
    body {
        font:14px Verdana, Arial, Geneva, sans-serif;
        color:#404040;
        background:#fff;
    }
    img {
        border-style:none;
    }
    .main{
        width:300px;
        height:60px;
        position:absolute;
        left:50%;
        top:50%;
        margin-left:-150px;
        margin-top:-30px;
    }
    .box{
        margin-bottom: 10px;
        overflow: hidden;
       
    }
    input.uploadFile{
        position:absolute;
        float:left;
        opacity:0;
        filter:alpha(opacity=0);
        cursor:pointer;
        width:276px;
        height:36px;
        overflow: hidden;
    }
    input.textbox{
        float:left;
        padding:5px;
        color:#999;
        height:24px;
        line-height:24px;
        border:1px #ccc solid;
        width:200px;
        margin-right:4px;
    }
    a.link{
        float:left;
        display:inline-block;
        padding:4px 16px;
        color:#fff;
        font:14px "Microsoft YaHei", Verdana, Geneva, sans-serif;
        cursor:pointer;
        background-color:#0099ff;
        line-height:28px;
        text-decoration:none;
    }

    .spanChangjiaCheck{
    position:absolute;
    margin-left: 10px;
    margin-top: -10px;  
    
    }
    .bbbb{position: relative;}
    .spanShebeiInput,.spanChangjiaInput{
    position:absolute;
    margin-left: 10px;
    margin-top: -10px;
    }
    .spanShebeiCheck{
    position:absolute;
    margin-left: 10px;
    margin-top: -10px;
    }
     
    .changjia,.shebei{
    width:160px;height:22px;margin:-2px;
    }
    .changjiainput,.shebeiinput{
   width:140px;line-height: 18px;border:0pt;
    }

    .button-input{ 
   
    }
    .button-input table{
    border-collapse: collapse;
    border-spacing: 0;
    margin-bottom: 10px;
    }
    
    .button-input table td{
    border: 1px solid #c9c9c9;
    line-height: 30px;
    text-align: center;
    }
    .button-input button{
    background: #32c16f;
    width: 106px;
    line-height: 30px;
    color: #fff;
    float: right;
    margin-left: 10px;
    cursor: pointer;
    border: none;
    font-size: 14px;
    }
    .button-input button:hover{background:#01af4b;color:#fff}
    .icon{display: inline-block;
    background: url(../images/icon.png) no-repeat;
    vertical-align: middle;
    background-position: 0 -185px;
    width: 22px;
    height: 22px;
    }
    .wrapper-c{margin:10px}
    
</style>

<script>


//检测文件类型
function checkExd(fileName){
if(fileName.lastIndexOf(".")+1>=fileName.length){
 alert("上传文件目标类型不匹配！只支持tar.gz的文件！");//上传文件不存在，或目标类型不匹配！
 	return false;
 }
var tmp = fileName.substring(0,fileName.lastIndexOf("."));
//var tmp2 = tmp.substring(tmp.lastIndexOf(".")+1);//tar
//var tmp3 = tmp.substring(0,tmp.lastIndexOf("."));
//var tmp4 = tmp3.substring(tmp.lastIndexOf("Lib"));//文件名
var tmp4 = tmp.substring(tmp.indexOf("_"));
var type = /^_[a-zA-Z0-9\u4e00-\u9fa5]+_[a-zA-Z0-9\u4e00-\u9fa5]+_[a-zA-Z0-9\u4e00-\u9fa5]+_[a-zA-Z0-9\u4e00-\u9fa5]+_[a-zA-Z0-9\u4e00-\u9fa5]+_[WEB]+[.tar]|[.tar.gz]|[.TAR]|[.TAR.GZ]$/;
var reg = new RegExp(type);
//alert(reg);
//alert(tmp4);
//var exd1=fileName.substring(fileName.lastIndexOf(".")+1).toUpperCase();//GZ
//var exd = (tmp2+"."+exd1).toUpperCase();
 if(!tmp4.match(reg)){
 alert("上传文件命名格式有误！只支持Lib_XXX_YYY_ZZZ_MMM_NNN_WEB.tar.gz的文件！");
   return false;
 }else{
 return true;
 }
} 

function checkFile(){

var form = document.getElementById("form1");
var file = document.getElementById('myfile'); 
    if(file.value == '') {
        alert("上传文件不能为空");
        var lines = $("#parentTr tr");
		for (i=1;i<lines.length;i++){
			$(lines[i]).remove();
		}
    }else {
    if (checkExd(file.value)){
        return true;
    }
}
}

function filechanged(){
if(checkFile()){
//lib_port_other_HUAWEI_101_12.3_WEB.tar.gz
var form = document.getElementById("form1");
var file = document.getElementById('myfile'); 
var filevalue = file.value;
var tmp = filevalue.substring(filevalue.indexOf("_"));//_port_other_HUAWEI_101_12.3_WEB.tar.gz
//var tmp2 = tmp.substring(0,tmp.indexOf("WEB"));
var tmp2 = tmp.substring(0,tmp.lastIndexOf("_"));
var arr = tmp2.split("_");
//alert(arr);//_port_other_HUAWEI_101_12.3


if(arr[1]==null||arr[2]==null||arr[3]==null||arr[4]==null||arr[5]==null){
alert("上传文件命名或格式错误！只支持lib_XXX_YYY_ZZZ_NNN_MMM_WEB.tar.gz的文件！");
var form = document.getElementById("form1");
var file = document.getElementById('myfile');
if (file.outerHTML) {
file.outerHTML = file.outerHTML;
} else { // FF(包括3.5)
file.value = "";
}
}else{
	var lines = $("#parentTr tr");
		for (i=1;i<lines.length;i++){
			$(lines[i]).remove();
		}

	//var id = obj.value;
	var lines = $("#parentTr tr");
	var length = lines.length;
	var id = new Date().getTime();
	//alert(id);
	var str = "<tr><td>"+1+"<td>"+arr[1]+"</td><td>"
	+arr[2]+"</td><td align='center'><div class='bbbb'><div class='spanChangjiaCheck'><select class='changjia' name='changjia' id='changjia"+id+"' onchange='changeChangjia(this)'><option id='1' >请选择</option><#if supplierList?exists><#list supplierList as Supplier>"+"<option value='${Supplier.name?default("")}'>${Supplier.name?default("")}</option>"+"</#list></#if></select></div><div class='spanChangjiaInput'><input maxlength='10' placeholder='请选择或输入' onblur='checkIsRight(this)' class='changjiainput' type='text' name='changjiainput' id='changjiainput"+id+"' /></div></div></td><td align='center'><div class='bbbb'><div class='spanShebeiCheck'><select class='shebei'  name='shebei' id='shebei"+id+"'  onChange='changeShebei(this)'><option id='1' >请选择</option><option id='2' >FFFF</option><#if equitNoList?exists><#list equitNoList as equitNo>"+"<option value='${equitNo.equitModel?default("")}'>${equitNo.equitModel?default("")}</option>"+"</#list></#if></select></div><div onblur='checkIsRight(this)' class='spanShebeiInput'><input maxlength='10' placeholder='请选择或输入' onblur='changeShebeiInput(this)' class='shebeiinput' type='text' name='shebeiinput' id='shebeiinput"+id+"'/></div></div></td><td>"+arr[5]+"</td><td></td></tr>";
	$("#parentTr").append(str);
	}
}


}

    function changeChangjia(obj)  
    {  
       var id = $(obj).attr("id");
       //alert(id);
	   iddate = id.substr(8);
	   //alert(id);
	   var idinput = "changjiainput"+iddate;
	   //alert(idinput);
       document.getElementById(idinput).value= 
       document.getElementById(id).options[document.getElementById(id).selectedIndex].value;
    }  
    
      function changeShebei(obj)  
    {  
       var id = $(obj).attr("id");
       iddate = id.substr(6);
       //alert(id);
       var idinput = "shebeiinput"+iddate;
   	   document.getElementById(idinput).value=  
       document.getElementById(id).options[document.getElementById(id).selectedIndex].value;  
    } 
    
        function changeChangjiaInput(obj)  
    {  
       //alert("厂家");
       var id = $(obj).attr("id");
	   iddate = id.substr(8);
	   var idinput = "changjiainput"+iddate;
	  // alert(document.getElementById(idinput).value!="");
      // if(document.getElementById(idinput).value!=""){ 
      // alert("厂家2");
      // document.getElementById(id).options[document.getElementById(id).selectedIndex].value="";
      // }else{
       //alert("厂家1");}
    }  
    
      function changeShebeiInput(obj)  
    {  
       //alert("设备");
       var id = $(obj).attr("id");
       iddate = id.substr(6);
       var idinput = "shebeiinput"+iddate;
   	   //if(document.getElementById(idinput).value!=""){
   	   // alert("设备2"); 
       //document.getElementById(id).options[document.getElementById(id).selectedIndex].value="";  
       //}else{
       // alert("设备1");
       //}
    } 
    
function addId(){
//var file = document.getElementById('myfile'); 
var file = $('#myfile').val(); 
if(file==''){
alert("请先选择要上传的文件");
}else{
addItem();
}
}

function addItem(){
var form = document.getElementById("form1");
var file = document.getElementById('myfile'); 
var filevalue = file.value;
var tmp = filevalue.substring(filevalue.indexOf("_"));//_port_other_HUAWEI_101_12.3_WEB.tar.gz
//var tmp2 = tmp.substring(0,tmp.indexOf("WEB"));
var tmp2 = tmp.substring(0,tmp.lastIndexOf("_"));
var arr = tmp2.split("_");
var dalei =arr[1];
var xiaolei =arr[2];
var version =arr[5];

	//var id = obj.value;
	var lines = $("#parentTr tr");
	var length = lines.length;
	var id = new Date().getTime();
	//alert(id);

var str = "<tr id='"+id+"'><td name='xuhao'>"+length+"<td>"+dalei+"</td><td>"
	+xiaolei+"</td><td align='center'><div class='bbbb'><div class='spanChangjiaCheck'><select class='changjia' name='changjia' id='changjia"+id+"' onchange='changeChangjia(this)'><option id='1' >请选择</option><#if supplierList?exists><#list supplierList as Supplier>"+"<option value='${Supplier.name?default("")}'>${Supplier.name?default("")}</option>"+"</#list></#if></select></div><div class='spanChangjiaInput'><input maxlength='10' placeholder='请选择或输入' onblur='checkIsRight(this)' class='changjiainput' type='text' name='changjiainput' id='changjiainput"+id+"' /></div></div></td><td align='center'><div><div class='spanShebeiCheck'><select class='shebei'  name='shebei' id='shebei"+id+"'  onChange='changeShebei(this)'><option id='1' >请选择</option><option id='2' >FFFF</option><#if equitNoList?exists><#list equitNoList as equitNo>"+"<option value='${equitNo.equitModel?default("")}'>${equitNo.equitModel?default("")}</option>"+"</#list></#if></select></div><div onblur='checkIsRight(this)' class='spanShebeiInput'><input maxlength='10' placeholder='请选择或输入' onblur='changeShebeiInput(this)' class='shebeiinput' type='text' name='shebeiinput' id='shebeiinput"+id+"'/></div></div></td><td>"+version+"</td><td><img src='${BasePath}/images/remove.png' id='img_"+id+"' onclick='removeLine(this)'/></td></tr>";
	$("#tBody").append(str);
}

function removeLine(obj){
	var id = $(obj).attr("id");
	//alert(id);
	id = id.substr(4);
	var lines = $("#parentTr tr");
	//alert(lines.length);
		for (i=1;i<lines.length;i++){
		//alert($(lines[i]).attr("id"));
			if($(lines[i]).attr("id") == id){
			$(lines[i]).remove();
			//实现删除行还能排序
			   var num=1;
				$('#tBody tr').each(function (){								
					$(this).find('td').eq(0).text(num++);
				})
			
			}
		}
		
}

function checkIsRight(cell){
	var str=cell.value;
	if((str.indexOf("&") >=0) || (str.indexOf("<") >=0) || (str.indexOf(">") >=0)){
		alert('不能输入非法字符,&,<,>等');
	}
}
function fileUpload(){
var form = document.getElementById("form1");
var file = document.getElementById('myfile'); 
var filevalue = file.value;
var tmp = filevalue.substring(filevalue.indexOf("_"));//_port_other_HUAWEI_101_12.3_WEB.tar.gz
//var tmp2 = tmp.substring(0,tmp.indexOf("WEB"));
var tmp2 = tmp.substring(0,tmp.lastIndexOf("_"));
var arr = tmp2.split("_");
var dalei =arr[1];
var xiaolei =arr[2];
var supplierSelect = document.getElementsByName('changjia');
var supplierInput = document.getElementsByName('changjiainput');
var equitSelect = document.getElementsByName('shebei');
var equitInput = document.getElementsByName('shebeiinput');

	var flag = false;
	var flag2 = false;	        		
	var flag3 = false;	        		
	var flag4 = true;
	//文件为空	        		
if(filevalue==""){
alert("请先选择要上传的文件！");
}else{
if(supplierSelect.length>0){
 var flag5=true;	
for(var i=0;i<supplierSelect.length;i++){
//供应商和设备型号判断是否为空
if(supplierSelect[i].value=="请选择"&&supplierInput[i].value.trim()==""||equitSelect[i].value=="请选择"&&equitInput[i].value.trim()==""){
alert("条目选项不能为空！请填写");
flag5=false;
return;
}

}
if(flag5){
	
	
//判断大小类是否存在
$.ajax({ 
		        type: 'POST', 
		        url:'${BasePath}/version/searchAllSmallCode.kq', 
		             data:{
		          "dalei": dalei,
		          "xiaolei":xiaolei
		        },
		        dataType: 'json', 
		        cache: false, 
		        error: function(data){ 
		           alert("系统繁忙，请稍候再试!"); 
		           return false; 
		        }, 
		        success:function(data){ 
		        	if(data==true){
if(flag4){
		        		$.ajax({ 
		        type: 'POST', 
		        url:'${BasePath}/version/searchFileExist.kq?fileUrl='+filevalue, 
		        dataType: 'json', 
		        cache: false, 
		        error: function(data){ 
		           alert("系统繁忙，请稍候再试!"); 
		           return false; 
		        }, 
		        success:function(data){ 
		        	if(data==true){
		        	flag3 = true;
		        	}else{
		        	 alert("上传文件已存在");
		var form = document.getElementById("form1");
					if (file.outerHTML) {
file.outerHTML = file.outerHTML;
} else { // FF(包括3.5)
file.value = "";
}
	var lines = $("#parentTr tr");
		for (i=1;i<lines.length;i++){
			$(lines[i]).remove();
		}
		        	 return;
		        	}
		        	//后台返回值判断为true则将flag3==true
                   if(flag3==true){
						document.getElementById('form1').submit();
                        alert("上传成功");
                        return;
                   }else{
                   }        
                   }
  
                   });
   
   flag4 = false;
   }
		        	}
		        	
		        	else{
		        	}
					

					if(data!=true){
					alert("请按要求命名！");
					var form = document.getElementById("form1");
					if (file.outerHTML) {
					file.outerHTML = file.outerHTML;
					} else { // FF(包括3.5)
					file.value = "";
					}
	var lines = $("#parentTr tr");
		for (i=1;i<lines.length;i++){
			$(lines[i]).remove();
		}
					}
		       else{
					}
		      	}    
		 }); 

	
	
	}


}else{
$.ajax({ 
		        type: 'POST', 
		        url:'${BasePath}/version/searchAllSmallCode.kq', 
		             data:{
		          "dalei": dalei,
		          "xiaolei":xiaolei
		        },
		        dataType: 'json', 
		        cache: false, 
		        error: function(data){ 
		           alert("系统繁忙，请稍候再试!"); 
		           return false; 
		        }, 
		        success:function(data){ 
		        	if(data==true){
if(flag4){
//判断文件是否已经插入数据库
		        		$.ajax({ 
		        type: 'POST', 
		        url:'${BasePath}/version/searchFileExist.kq?fileUrl='+filevalue, 
		        dataType: 'json', 
		        cache: false, 
		        error: function(data){ 
		           alert("系统繁忙，请稍候再试!"); 
		           return false; 
		        }, 
		        success:function(data){ 
		        	if(data==true){
		        	flag3 = true;
		        	}else{
		        	 alert("上传文件已存在");
		var form = document.getElementById("form1");
		if (file.outerHTML) {
		file.outerHTML = file.outerHTML;
		} else { // FF(包括3.5)
		file.value = "";
		}
	var lines = $("#parentTr tr");
		for (i=1;i<lines.length;i++){
			$(lines[i]).remove();
		}
		        	 return;
		        	}
                   if(flag3==true){
						document.getElementById('form1').submit();
                        alert("上传成功");
                        return;
                   }else{
                   }        
                   }
  
                   });
   
   flag4 = false;
   }
		        	}
		        	
		        	else{
		        	}
					if(data!=true){
					alert("请按要求命名！");
					var form = document.getElementById("form1");
					if (file.outerHTML) {
					file.outerHTML = file.outerHTML;
					} else { // FF(包括3.5)
					file.value = "";
					}
	var lines = $("#parentTr tr");
		for (i=1;i<lines.length;i++){
			$(lines[i]).remove();
		}
					}
		       else{
					}
		      	}    
		 });
}

}
}


function toback(){
window.parent.location.reload();
	//parent.window.location.href = '${BasePath}/version/getIndexInformation.kq';
}

</script>  
<body>
<form name="form1" id="form1" method="post" action="${BasePath}/version/uploadFile.kq" enctype="multipart/form-data">
<div  class="wrapper-c ">
<div style="margin-bottom:5px">
<A class=btn_addPic href="javascript:void(0);"><SPAN><EM>+</EM>添加文件</SPAN> <INPUT name="myfile" id="myfile" onchange="javascript:filechanged()" class=filePrew tabIndex=3 type=file size=3 name=pic></A>
</div>
<div class="button-input">
    <table width="100%" border="1" id="parentTr">
      <thead>
        <tr  class="biaotou">
          <td>序号</td>
          <td>大类</td>
          <td>小类</td>
          <td width="185px">厂家</td>
          <td width="185px">设备型号</td>
          <td>版本号</td>
          <td>操作</td>
        </tr>
      </thead>
      <tbody id="tBody">
      </tbody>
	</table> 
	<button type="button" onclick="javascript:toback()">返回</button>
	<button type="button" onclick="javascript:fileUpload()">保存</button>
	<Button type="button" onclick="javascript:addId()"><i class="icon icon-8"></i>增加</Button>
</div>
</div>
</form>
</body>
</html>
