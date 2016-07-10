<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>上传</title>
<style>
.table-set { table-layout: fixed; }
.table-set td { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
</style>
</head>
<link href="../css/sostyle.css" rel="stylesheet" type="text/css">
<link href='${BasePath}/css/global.css' rel='stylesheet' type='text/css' />
<link rev="stylesheet" rel="stylesheet" type="text/css" href="${BasePath}/css/thickbox.css"  media="screen" />
<script type="text/javascript"  src="${BasePath}/js/common/thickbox/thickbox.js"></script>
<script type='text/javascript' src='${BasePath}/js/global.js'></script>
<script type='text/javascript' src='${BasePath}/js/wechat.js'></script>

<script src="${BasePath}/js/app/zjmall/qxmall.js"></script>
<LINK rel=stylesheet type=text/css href="${BasePath}/css/lrtk.css">
<SCRIPT type=text/javascript src="${BasePath}/js/jquery-1.4.2.min.js"></SCRIPT>
<script type="text/javascript" src="${BasePath}/js/app/turentable/jQueryRotate.2.2.js"></script>
<body>



<script>

 $(function(){
    $("#dalei").change(function(){
    var big=$("#dalei").val();
      $.ajax({ 
		        type: 'POST', 
		        url:'${BasePath}/version/getClassByBigCode.kq?bigCode='+big, 
		        dataType: 'json', 
		        cache: false, 
		        error: function(data){ 
		           alert("系统繁忙，请稍候再试!"); 
		            return false; 
		        }, 
		        success:function(data){ 
		        
		        $("#xiaolei").empty();
		        $("#changjia").empty();
		        $("#shebei").empty();
		        $("#banben").empty();
		        
		        var str0 = "'<option value='-1'>请选择</option>'";
		        	$("#xiaolei").append(str0);
					for(var i=0;i<data.length; i++){
						var str = "'<option value='"+data[i].code+"'>"+data[i].name+"</option>'";
						$("#xiaolei").append(str);
					}	
		      	}    
		 }); 
});
});



$(function(){
    $("#xiaolei").change(function(){
  	var big=$("#dalei").val();
    var small=$("#xiaolei").val();
      $.ajax({ 
		        type: 'POST', 
		        url:'${BasePath}/version/getSupplierByBigCodeAndSmallCode.kq',
		        data:{
		          "bigCode": big,
		          "smallCode":small
		        },
		        dataType: 'json', 
		        cache: false, 
		        error: function(data){ 
		           alert("系统繁忙，请稍候再试!"); 
		            return false; 
		        }, 
		        success:function(data){ 
		        
		        $("#changjia").empty();
		        $("#shebei").empty();
		        $("#banben").empty();
		        	var str0 = "'<option value='-1'>请选择</option>'";
		        	$("#changjia").append(str0);
					for(var i=0;i<data.length; i++){
						var str = "'<option value='"+data[i].supplier+"'>"+data[i].supplier+"</option>'";
						$("#changjia").append(str);
					}	
		      	}    
		 }); 
});
});



$(function(){
    $("#changjia").change(function(){
  	var big=$("#dalei").val();
    var small=$("#xiaolei").val();
    var supplier=$("#changjia").val();
      $.ajax({ 
		        type: 'POST', 
		        url:'${BasePath}/version/getDeviceByBigClassSmallClassAndSupplier.kq',
		        data:{
		          "bigCode": big,
		          "smallCode":small,
		          "supplier":supplier
		          
		        },
		        dataType: 'json', 
		        cache: false, 
		        error: function(data){ 
		           alert("系统繁忙，请稍候再试!"); 
		            return false; 
		        }, 
		        success:function(data){ 
		        
		        $("#shebei").empty();
		        $("#banben").empty();
		        	var str0 = "'<option value='-1'>请选择</option>'";
		        	$("#shebei").append(str0);
					for(var i=0;i<data.length; i++){
						var str = "'<option value='"+data[i].equitModel+"'>"+data[i].equitModel+"</option>'";
						$("#shebei").append(str);
					}	
		      	}    
		 }); 
});
});



$(function(){
    $("#shebei").change(function(){
  	var big=$("#dalei").val();
    var small=$("#xiaolei").val();
    var supplier=$("#changjia").val();
    var equitModel=$("#shebei").val();
      $.ajax({ 
		        type: 'POST', 
		        url:'${BasePath}/version/getVersionByBigClassSmallClassAndSupplieretc.kq',
		        data:{
		          "bigCode": big,
		          "smallCode":small,
		          "supplier":supplier,
		          "equitModel":equitModel
		        },
		        dataType: 'json', 
		        cache: false, 
		        error: function(data){ 
		           alert("系统繁忙，请稍候再试!"); 
		            return false; 
		        }, 
		        success:function(data){ 
		        
		        $("#banben").empty();
		        var str0 = "'<option value='-1'>请选择</option>'";
		        	$("#banben").append(str0);
					for(var i=0;i<data.length; i++){
						var str = "'<option value='"+data[i].versionNo+"'>"+data[i].versionNo+"</option>'";
						$("#banben").append(str);
					}	
		      	}    
		 }); 
});
});

function test(obj1,obj2){

	if(confirm("你确定要删除？"))
    {
        //删除代码
        document.getElementById("id").value =obj1;
        document.getElementById("attachDir").value =obj2;
		document.getElementById("myFormToDel").submit();
    }else{}

}

//改版条件查询（潘强强）
function search_pan(){

    var big=$("#dalei").val();
    var small=$("#xiaolei").val();
    var supplier=$("#changjia").val();
    var equitModel=$("#shebei").val();
    var versionNo=$("#banben").val();
    
    if(big==-1){
    
        alert("请选择大类");

    }else{
    
       $.ajax({
       
             type:'POST',
             url: '${BasePath}/version/searchCondition.kq?big='+big+'small='+small+'supplier='+supplier+'equitModel='+equitModel+'versionNo='+versionNo,
             data:{
             
             },
             dataType: 'json',
             cache:false,
             error: function(data){ 
		            alert("系统繁忙，请稍候再试!"); 
		            return false; 
		        }, 
		     success:function(data){
		     
		           if(data[0]==null){
		        	alert("暂无内容");
		        	}
					var lines = $("#sonTab tr");
					//先删除所有行
					for (i=1;i<lines.length;i++){
						$(lines[i]).remove();
					}
		     
		            for(var i=0;i<data.length; i++){
			        	 var s = data[i].id;
			        	 var attachDir= data[i].attachDir;
			        	 var t = "<a href='javascript:test("+s+","+attachDir+")'>";//拼串传参数。
			        	  
			        	var str = "<tr ><td>"+(i+1)+"</td><td>"+data[i].className+"</td><td>"
			        	+data[i].twoClassName+"</td><td>"+data[i].supplier+"</td><td>"+data[i].equitModel+"</td><td>"
			        	+data[i].versionNo+"</td><td>"+data[i].createTime+"</td><td>"+data[i].creater+"</td><td>"+data[i].name+"</td><td>"+
			        	t
			        	+"<i class='icon-7'></i></a>"+"</td></tr>";
			        	$("#sonTab").append(str);
					}
		        
		     
		       
		     
		     }
		       
       
       });
    
    }
        

}



function search_s(){
  	var big=$("#dalei").val();
    var small=$("#xiaolei").val();
    var supplier=$("#changjia").val();
    var equitModel=$("#shebei").val();
    var versionNo=$("#banben").val();

    document.getElementById('bigcodeie').value = big;
    document.getElementById('smallcodeie').value = small;
    document.getElementById('suppliercodeie').value = supplier;
    document.getElementById('equitcodeie').value = equitModel;
    document.getElementById('versioncodeie').value = versionNo;
	document.getElementById("searchForm").submit();
}

function removeLine(obj){
	var id = $(obj).attr("id");
	id = id.substr(4);
	var lines = $("#parentTab tr");
		for (i=1;i<lines.length;i++){
			if($(lines[i]).attr("id") == id){
			$(lines[i]).remove();
			}
		}
}


function downLoad_file()
{
	var lines = $("#parentTab tr");
	if (lines.length >1)
	{
		var ids = '';
		for (i=1;i<lines.length;i++)
		{
			ids = ids + $(lines[i]).attr("id") + ",";
		}
		
		var url = "${BasePath}vrdownload/downLoad.kq?ids="+ids;
		
	    if( url){ 
	        jQuery('<form action="'+ url +'" method="'+ ('post') +'"></form>')
	        .appendTo('body').submit().remove();
		}
	}
	else
	{
	   alert("请选择需要打包的文件");
	}
}


</script>

<script type='text/javascript' >



function getTopDetail2()
{	
	showThickBox("选择文件","${BasePath}"+"/version/chooseFileDialog.kq?TB_iframe=false&height=600&width=1000",false);
}

//检测文件类型
function checkExd(fileName){
if(fileName.lastIndexOf(".")+1>=fileName.length){
 alert("上传文件目标类型不匹配！只支持tar或者tar.gz的文件！");//上传文件不存在，或目标类型不匹配！
 	return false;
 }
var tmp = fileName.substring(0,fileName.lastIndexOf("."));
//var tmp2 = tmp.substring(tmp.lastIndexOf(".")+1);//tar
//var tmp3 = tmp.substring(0,tmp.lastIndexOf("."));
//var tmp4 = tmp3.substring(tmp.lastIndexOf("Lib"));//文件名
var tmp4 = tmp.substring(tmp.indexOf("_"));
var type = /^_[a-zA-Z0-9\u4e00-\u9fa5]+_[a-zA-Z0-9\u4e00-\u9fa5]+_[a-zA-Z0-9\u4e00-\u9fa5]+_[a-zA-Z0-9\u4e00-\u9fa5]+_[a-zA-Z0-9\u4e00-\u9fa5]+_[WEB]+[.tar]|[.tar.gz]|[.TAR]|[.TAR.GZ]$/;
var reg = new RegExp(type);
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

var form = document.getElementById("myform");
var file = document.getElementById('myfile'); 
    if(file.value == '') {
        alert("上传文件不能为空");
    }else {
    if (checkExd(file.value)){
        document.getElementById('myform').submit();
    }
}
}
function getTopDetail(bigCode)
	{		
	var strs= new Array(); //定义一数组 
    strs=bigCode.split(","); //字符分割 	
	if(confirm("你确定要删除？"))
    {
        //删除代码
        document.getElementById("id").value = strs[0];
        document.getElementById("attachDir").value = strs[1];
		document.getElementById("myFormToDel").submit();
    }
    else{}
	}
	
	function getTopDetail3(bigCode)
	{		
	//var strs= new Array(); //定义一数组 
    //strs=bigCode.split(","); //字符分割 	
	if(confirm("你确定要删除？"))
    {
        //删除代码
        alert(bigCode);
        document.getElementById("id").value = bigCode;
        //document.getElementById("attachDir").value = strs[1];
		document.getElementById("myFormToDel").submit();
    }
    else{}
	}	
	
$(function() {
    var index = 0;
    var adtimer;
    var _wrap = $("#container ol");
    var len = $("#container ol li").length;
    if (len > 1) {
        $("#container").hover(function() {
            clearInterval(adtimer);
        },
        function() {
            adtimer = setInterval(function() {

                var _field = _wrap.find('li:first'); //此变量不可放置于函数起始处,li:first取值是变化的
                var _h = _field.height(); //取得每次滚动高度(多行滚动情况下,此变量不可置于开始处,否则会有间隔时长延时)
                _field.animate({
                    marginTop: -_h + 'px'
                },
                500,
                function() { //通过取负margin值,隐藏第一行
                    _field.css('marginTop', 0).appendTo(_wrap); //隐藏后,将该行的margin值置零,并插入到最后,实现无缝滚动
                })

            },
            3000);
        }).trigger("mouseleave");
        function showImg(index) {
            var Height = $("#container").height();
            $("#container ol").stop().animate({
                marginTop: -_h + 'px'
            },
            1000);
        }

        $("#container").mouseover(function() {
            $("#container .mouse_direction").css("display", "block");
        });
        $("#container").mouseout(function() {
            $("#container .mouse_direction").css("display", "none");
        });
    }

    $("#container").find(".mouse_top").click(function() {
        var _field = _wrap.find('li:first'); //此变量不可放置于函数起始处,li:first取值是变化的
        var last = _wrap.find('li:last'); //此变量不可放置于函数起始处,li:last取值是变化的
        //last.prependTo(_wrap);
        var _h = last.height();
        $("#container ol").css('marginTop', -_h + "px");
        last.prependTo(_wrap);
        $("#container ol").animate({
            marginTop: 0
        },
        500,
        function() { //通过取负margin值,隐藏第一行
            //$("#container ol").css('marginTop',0).prependTo(_wrap);//隐藏后,将该行的margin值置零,并插入到最后,实现无缝滚动
        })
    });
    $("#container").find(".mouse_bottom").click(function() {
        var _field = _wrap.find('li:first'); //此变量不可放置于函数起始处,li:first取值是变化的
        var _h = _field.height();
        _field.animate({
            marginTop: -_h + 'px'
        },
        500,
        function() { //通过取负margin值,隐藏第一行
            _field.css('marginTop', 0).appendTo(_wrap); //隐藏后,将该行的margin值置零,并插入到最后,实现无缝滚动
        })
    });
});

function showAnnouncement(id)
{	
	showThickBox("公告详情","${BasePath}"+"/version/showAnnouncement/"+id+".kq?TB_iframe=true&height=350&width=750",false);
}

</script>

<form action="${BasePath}/version/delUploadFile.kq" id="myFormToDel" name="myFormToDel">
<input type="hidden" name="bigCode" id="bigCode" />
<input type="hidden" name="id" id="id" />
<input type="hidden" name="attachDir" id="attachDir" />
<input type="hidden" name="bigName" id="bigName" />
<input type="hidden" name="smallCode" id="smallCode" />
<input type="hidden" name="smallName" id="smallName" />
<input type="hidden" name="name" id="name" />
<input type="hidden" name="supplier" id="supplier" />
<input type="hidden" name="versionNo" id="versionNo" />
<input type="hidden" name="creater" id="creater" />
<input type="hidden" name="createTime" id="createTime" />
</form>

<div class="header"> 
<i class="icon icon-5"></i>
  <DIV id=container class=banner style="margin-top:13px">
  <OL>
   <#if resultList2?exists>
         <#list resultList2 as Notice>
          <li><a href="javascript:showAnnouncement('${Notice.id?default("")}')";><font  color="white">${Notice.title?default("")}</font></a></li>
           </#list> 
       <#else>
           <li>暂无公告</li>    
   </#if>
  </OL>
    <DIV class=mouse_direction>
        <DIV class=mouse_top></DIV>
        <DIV class=mouse_bottom></DIV>
    </DIV>
</DIV>
</div>

    <div class="wrapper-c clearfix" style="padding:0">
      <ul>
        <li ><span>大类：</span>
          <select class="xiala" id="dalei" >
            <option value="-1">请选择</option>
            <#if bigClassList?exists> 
            <#list bigClassList as bigClass>
         		<option value="${bigClass.code?default("")}">${bigClass.name?default("")}</option>
         	</#list>
         	</#if>
          </select>
        </li>
        <li ><span>小类：</span>
        
          <select  class="xiala" id="xiaolei">
          	<option value="1"></option>
          </select>
         
        </li>
        <li ><span>厂家：</span>
          <select  class="xiala" id="changjia">
            <option value="1"></option>
          </select>
        </li>
        <li ><span>设备型号：</span>
          <select  class="xiala" id="shebei">
            <option value="1"></option>
          </select>
        </li>
        <li ><span>版本号：</span>
          <select  class="xiala" id="banben">
            <option value="1"></option>
          </select>
        </li>
        <li>
          <button type="button" onclick="search_s()"><i class="icon icon-6"></i> 查询</button>
        </li>
      </ul>
    </div>
    
  
    
<div class="wrapper-c" style="margin:10px 20px">
 
   <FORM name="myform" id="myform" method="post" action="${BasePath}/version/uploadFile.kq" enctype="multipart/form-data">
   <button type="button" style="float:left" onclick="javascript:getTopDetail2()" style="margin-top:10px"><i class="icon icon-2"></i>上传文件</button></FORM>
   
    <form name="qcust" id="qcust" method="post" action="${BasePath}/version/getIndexInformation.kq">
   </form>
   
   <form  name="searchForm" id="searchForm" method="post" action="${BasePath}/version/searchFile.kq">
   <input type="hidden" id="bigcodeie" name="bigcodeie"/>
   <input type="hidden" id="smallcodeie" name="smallcodeie"/>
   <input type="hidden" id="suppliercodeie" name="suppliercodeie"/>
   <input type="hidden" id="equitcodeie" name="equitcodeie"/>
   <input type="hidden" id="versioncodeie" name="versioncodeie"/>
   </form>

   
   
   
      <table style="word-break:break-all" width="100%" border="1" id="sonTab" class="table-set">
        <thead class="biaotou" >
        <td width="80px">序号</td>
          <td>大类</td>
          <td>小类</td>
          <td>厂家</td>
          <td>设备型号</td>
          <td>版本号</td>
          <td>上传时间</td>
          <td>上传人</td>
          <td>文件名</td>
          <td>操作</td>
        </thead>
         <#if pageFinder?exists> 
         <#if pageFinder.result?exists>
         <#list pageFinder.result as VersionInformation> 
         <input type="hidden" value=${VersionInformation.id}>
          <tr>
                  
		  <td>${VersionInformation_index + 1}</td>
		  
          <td>${VersionInformation.classCode}(${VersionInformation.className?default("")})</td>
          
          <td>${VersionInformation.twoClassCode}(${VersionInformation.twoClassName?default("")})</td>
          
          <td title="${VersionInformation.supplier?default("")}">${VersionInformation.supplier?default("")}<input type="hidden" value=${VersionInformation.supplier?default("")}/></td>
          
          <td title="${VersionInformation.equitModel?default("")}">${VersionInformation.equitModel?default("")}<input type="hidden" value=${VersionInformation.equitModel?default("")}/></td>
          
          <td>${VersionInformation.versionNo?default("")}</td>
          
          <td>${VersionInformation.createTime?default("")}</td>
          
          <td>${VersionInformation.creater?default("")}</td>
          <td title="${VersionInformation.name?default("")}">${VersionInformation.name?default("")}</td>
          <td><a href="javascript:getTopDetail('${VersionInformation.id},${VersionInformation.attachDir}');"><i class="icon-7" style="margin-left:40%;"></i></td></a>
        </tr>
 </#list> 
</#if> 
</#if> 
      </table>

    </div>
    </div>  
           <!-- 翻页标签 -->
<#import "../app-common.ftl"  as page>
<@page.queryForm formId="qcust" /> 
  </div>
</div>
</body>
</html>
