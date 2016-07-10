<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>发布公告</title>
<link href="${BasePath}/css/sostyle.css" rel="stylesheet" type="text/css" />
<script src="${BasePath}/js/jquery-1.4.2.min.js"></script>
</head>
<body>
<script type='text/javascript'>
function toback(){
	parent.location.href = '${BasePath}/version/getAnnouncement.kq';
} 

function checkTitle(){
var title = encodeURI($("#title").val(), "UTF-8"); //使用encodeURI进行编码 
var title1 = decodeURI(title, "UTF-8"); //解码为了判断。
if($.trim(title1).length==0){
$("#gradeInfo").html("<font color=\"red\" id=\"tishi\">标题不能为空!</font>");    
 }else if((title1.indexOf("&") >=0)||(title1.indexOf("%") >=0)|| (title1.indexOf("<") >=0) || (title1.indexOf(">") >=0)|| (title1.indexOf("^") >=0)){
   $("#gradeInfo").html("<font color=\"red\" id=\"tishi\">标题请输入合法字符!</font>");  
 }else{
   $.ajax({
            type:"POST",
            url:'${BasePath}/version/judgeTitle.kq?title='+title,
            data: {
            },
          //dataType:'json',
            cache: false,
            success:function(msg){
                if(msg.toString()=="bucunzai")
                {   
                    $("#gradeInfo").html("");
                }
                else{
                    $("#gradeInfo").html("<font color=\"red\" id=\"tishi\">标题存在,请重新输入!</font>"); 
                    }
                
                },
          	error:function()
               {
               alert("出现意外错误，请重试");
               }
            });

}


}

function checkContent(){
     var contentvalue =$("#content").val();
     if($.trim(contentvalue).length==0){
           $("#contentInfo").html("<font color=\"red\" id=\"tishi\">内容不能为空!</font>"); 
          }else{
          
           $("#contentInfo").html(""); 
          
          }

}

function upload(){
var titlevalue =$("#title").val();
var contentvalue =$("#content").val();
var tishi=$("#tishi").html();
var str1="标题不能为空!";
var str2="标题请输入合法字符!";
var str3="标题存在,请重新输入!";

   if(($.trim(contentvalue).length==0)&&($.trim(titlevalue).length==0)){
     $("#contentInfo").html("<font color=\"red\" id=\"tishi\">内容不能为空!</font>"); 
     $("#gradeInfo").html("<font color=\"red\" id=\"tishi\">标题不能为空!</font>");    
     return;
    }
	if($.trim(contentvalue).length==0){
		 $("#contentInfo").html("<font color=\"red\" id=\"tishi\">内容不能为空!</font>"); 
		return;
		}
    if((contentvalue.indexOf("&") >=0)||(contentvalue.indexOf("%") >=0) || (contentvalue.indexOf("<") >=0) || (contentvalue.indexOf(">") >=0)|| (contentvalue.indexOf("^") >=0)){
		  $("#contentInfo").html("<font color=\"red\" id=\"tishi\">内容请输入合法字符！</font>"); 
		 return;
		}
	if(tishi==str1||tishi==str2||tishi==str3){
		   //alert("标题不正确！");
		   return;
		}
	 if($.trim(titlevalue).length==0){
		  $("#gradeInfo").html("<font color=\"red\" id=\"tishi\">标题不能为空!</font>");  
		   return;
		}
		
       $.ajax({
	           cache: true,
	           type: "POST",
	           url:'${BasePath}/version/announcement.kq',
	           data:$('#formId').serialize(),
	           async: false,
	           error: function(request) {
	                    //window.location.reload();
	                },
	          success: function(data) {
	                 parent.window.location.reload();
	                }
	            });
	            
	            


}




</script>

<form name="formId" id="formId">
<input type="hidden" name="id" id="id" value="${id?default("")}">
<div class="miniDialog_wrapper1">
  <div class="miniDialog_content" >
    <ul>

       
      <li ><span class="label"><b class="ftx04">*</b>标  题：</span>
        <input maxlength="20" placeholder="标题不能超过20个字" type="text"  style="width:200px;height:30px;line-height:30px;"  name="title" id="title" onblur="javascript:checkTitle();"/>
        <span id="gradeInfo"></span>       
      </li>
      <li><span class="label"><b class="ftx04">*</b>内  容：</span>
      	<textarea name="content" id="content" placeholder="内容不能超过200字" style="width:385px; height:118px;border: 1px solid #c9c9c9;" maxlength="200" onblur="javascript:checkContent();"></textarea>
      </li>
      <li><span  id="contentInfo" style="margin-left: 150px;"></span></li>
    </ul>
   
    <div class="layer-button" >
      <button type="button" onclick="javascript:upload()">确定</button>
    </div>
  </div>
</div>
</form>
</body>
</html>
