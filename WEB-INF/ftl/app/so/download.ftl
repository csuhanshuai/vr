<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>查询下载</title>
<script src="${BasePath}/js/jquery-1.7.2.min.js"></script>
<SCRIPT type=text/javascript src="${BasePath}/js/jquery-1.7.2.min.js"></SCRIPT>
<link href='${BasePath}/css/global.css' rel='stylesheet' type='text/css' />
<link href="../css/sostyle.css" rel="stylesheet" type="text/css">
<link rev="stylesheet" rel="stylesheet" type="text/css" href="${BasePath}/css/thickbox.css"  media="screen" />
<script type="text/javascript"  src="${BasePath}/js/common/thickbox/thickbox.js"></script>
<!--[if lte IE 9]><script type='text/javascript' src='${BasePath}/js/jquery.watermark-1.3.js'></script>
<![endif]-->
<LINK rel=stylesheet type=text/css href="${BasePath}/css/lrtk.css">
<style>
.btnTopOut{ }
.btnTopOver{background-color:#FFFFFF;}
.table-set { table-layout: fixed; }
.table-set td { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
</style>


</head>
<script type="text/javascript">
	var BasePath="${BasePath}";
</script>


<link href="${BasePath}/css/sostyle.css" rel="stylesheet" type="text/css">
<body onload="loadAll()">
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
  <form action="" method="post" name="myform">
    <div class="wrapper-c" style="padding:0">
      <ul>
        <li ><span>大类：</span>
          <select class="xiala" id="dalei" >
            <option value="-1">请选择</option>
            <#list bigClassList as bigClass>
         		<option value="${bigClass.code}">${bigClass.name}</option>
         	</#list>
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
    </form>
    <div class="title-lan">
      <p>版本查询列表</p>
    </div>
    <div class="wrapper-c" style="margin:10px 20px;overflow:auto;" id="tableDIV">
      <table width="100%" border="1" id="sonTab" class="table-set">
        <tr class="biaotou">
          <td width="55px">&nbsp;</td>
          <td >大类</td>
          <td >小类</td>
          <td >厂家</td>
          <td >设备型号</td>
          <td >版本号</td>
          <td>上传时间</td>
          <td>文件名</td>
          <td >操作</td>
        </tr>
        
        <#if pageFinder?exists> 
        <#if pageFinder.result?exists>
        <#list pageFinder.result as VersionInformation> 
          <tr >
          <!--<td><input  type="checkbox" name="version" id="${VersionInformation.id}" value="${VersionInformation.id}" onclick="chk(this)" /></td>
          <td>${VersionInformation.classCode}(${VersionInformation.className?default("")})</td>
          <td>${VersionInformation.twoClassCode}(${VersionInformation.twoClassName?default("")})</td>
          <td>${VersionInformation.equitModel?default("")}</td>
          <td>${VersionInformation.supplier?default("")}</td>
          <td>${VersionInformation.versionNo?default("")}</td>
          <td class="xiahua">相关资料</td>-->
          </tr>
		 </#list> 
		</#if>
		</#if> 
      </table>
    </div>
    
    <!-- 翻页标签 
    
    -->

    <div class="title-lan">
      <p>打包文件列表</p>
    </div>
    <div width="100%" class="wrapper-c" style="margin:10px 20px;overflow:auto;" id="tableDIV_1">
      <table width="100%" border="1" id="parentTab" class="table-set">
      <thead>
        <tr  class="biaotou">
          <td width="80px" class="biaotou2">序号</td>
          <td>大类</td>
          <td>小类</td>
          <td>厂家</td>
          <td>设备型号</td>
          <td>版本号</td>
          <td>文件名</td>
          <td>操作</td>
        </tr>
        <thead>
        <tbody id="tBody">
        </tbody>
      </table>
      	<button type="button" style="margin-top:10px" onclick="downLoad_file()" onmouseover="" onmouseout=""><i class="icon icon-3"></i>打包下载</button>
    </div>
  </div>

<script type='text/javascript'>

  //固定div高度
   $(document).ready(function() {
   
          var tableDIV=document.getElementById('tableDIV');
		tableDIV.style.height=(document.body.clientHeight-270)+"px";
		
		var tableDIV_1=document.getElementById('tableDIV_1');
		tableDIV_1.style.height=(document.body.clientHeight-390)+"px";
		
   
   });



 

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


function search_s(){
  	var big=$("#dalei").val();
    var small=$("#xiaolei").val();
    var supplier=$("#changjia").val();
    var equitModel=$("#shebei").val();
    var versionNo=$("#banben").val();
    if(big == -1) {
    
    	alert("请选择大类！");
    }
    else if(small == -1) {
    
    	$.ajax({ 
		        type: 'POST', 
		        url:'${BasePath}/version/searchByBigCode.kq',
		        data:{
		          "bigCode": big
		        },
		        dataType: 'json', 
		        cache: false, 
		        error: function(data){ 
		           alert("系统繁忙，请稍候再试!"); 
		            return false; 
		        }, 
		        success:function(data){ 
		        
					var lines = $("#sonTab tr");
					for (i=1;i<lines.length;i++){
						$(lines[i]).remove();
					}
					
					for(var i=0;i<data.length; i++){
					//alert(data[i].createTime);
			        	var str = "<tr ><td><input  type='checkbox' name='version' id='"+data[i].id+"' value='"+data[i].id
			        	+"' onclick='chk(this)' /></td><td>"+data[i].className+"</td><td>"
			        	+data[i].twoClassName+"</td><td title="+data[i].supplier+">"+data[i].supplier+"</td><td title="+data[i].equitModel+">"+data[i].equitModel+"</td><td>"
			        	+data[i].versionNo+"</td><td>"+data[i].createTime+"</td><td title="+data[i].name+">"+data[i].name+"</td><td class='xiahua'>相关资料</td></tr>";
			        	$("#sonTab").append(str);
					}	
						
		      	}    
		 }); 
    
    }else if(supplier == -1) {
    	$.ajax({ 
		        type: 'POST', 
		        url:'${BasePath}/version/searchByBigCodeSmallCode.kq',
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
		        
					var lines = $("#sonTab tr");
					for (i=1;i<lines.length;i++){
						$(lines[i]).remove();
					}
					
					for(var i=0;i<data.length; i++){
			        	var str = "<tr ><td><input  type='checkbox' name='version' id='"+data[i].id+"' value='"+data[i].id
			        	+"' onclick='chk(this)' /></td><td>"+data[i].className+"</td><td>"
			        	+data[i].twoClassName+"</td><td title="+data[i].supplier+">"+data[i].supplier+"</td><td title="+data[i].equitModel+">"+data[i].equitModel+"</td><td>"
			        	+data[i].versionNo+"</td><td>"+data[i].createTime+"</td><td title="+data[i].name+">"+data[i].name+"</td><td class='xiahua'>相关资料</td></tr>";
			        	$("#sonTab").append(str);
					}	
						
		      	}    
		 }); 
    }else if(equitModel == -1){
    	$.ajax({ 
		        type: 'POST', 
		        url:'${BasePath}/version/searchByBigCodeSmallCodeSupplier.kq',
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
		        
					var lines = $("#sonTab tr");
					for (i=1;i<lines.length;i++){
						$(lines[i]).remove();
					}
					
					for(var i=0;i<data.length; i++){
			        	var str = "<tr ><td><input  type='checkbox' name='version' id='"+data[i].id+"' value='"+data[i].id
			        	+"' onclick='chk(this)' /></td><td>"+data[i].className+"</td><td>"
			        	+data[i].twoClassName+"</td><td title="+data[i].supplier+">"+data[i].supplier+"</td><td title="+data[i].equitModel+">"+data[i].equitModel+"</td><td>"
			        	+data[i].versionNo+"</td><td>"+data[i].createTime+"</td><td title="+data[i].name+">"+data[i].name+"</td><td class='xiahua'>相关资料</td></tr>";
			        	$("#sonTab").append(str);
					}	
						
		      	}    
		 }); 
    }else if(versionNo == -1){
    	$.ajax({ 
		        type: 'POST', 
		        url:'${BasePath}/version/searchByBigCodeSmallCodeSupplierEquitNo.kq',
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
		        
					var lines = $("#sonTab tr");
					for (i=1;i<lines.length;i++){
						$(lines[i]).remove();
					}
					
					for(var i=0;i<data.length; i++){
			        	var str = "<tr ><td><input  type='checkbox' name='version' id='"+data[i].id+"' value='"+data[i].id
			        	+"' onclick='chk(this)' /></td><td>"+data[i].className+"</td><td>"
			        	+data[i].twoClassName+"</td><td title="+data[i].supplier+">"+data[i].supplier+"</td><td title="+data[i].equitModel+">"+data[i].equitModel+"</td><td>"
			        	+data[i].versionNo+"</td><td>"+data[i].createTime+"</td><td title="+data[i].name+">"+data[i].name+"</td><td class='xiahua'>相关资料</td></tr>";
			        	$("#sonTab").append(str);
					}	
						
		      	}    
		 }); 
    }else {
    	$.ajax({ 
		        type: 'POST', 
		        url:'${BasePath}/version/searchService.kq',
		        data:{
		          "bigCode": big,
		          "smallCode":small,
		          "supplier":supplier,
		          "equitModel":equitModel,
		          "versionNo":versionNo
		        },
		        dataType: 'json', 
		        cache: false, 
		        error: function(data){ 
		           alert("系统繁忙，请稍候再试!"); 
		            return false; 
		        }, 
		        success:function(data){ 
		        
					var lines = $("#sonTab tr");
					for (i=1;i<lines.length;i++){
						$(lines[i]).remove();
					}
					
					for(var i=0;i<data.length; i++){
			        	var str = "<tr ><td><input  type='checkbox' name='version' id='"+data[i].id+"' value='"+data[i].id
			        	+"' onclick='chk(this)' /></td><td>"+data[i].className+"</td><td>"
			        	+data[i].twoClassName+"</td><td title="+data[i].supplier+">"+data[i].supplier+"</td><td title="+data[i].equitModel+">"+data[i].equitModel+"</td><td>"
			        	+data[i].versionNo+"</td><td>"+data[i].createTime+"</td><td title="+data[i].name+">"+data[i].name+"</td><td class='xiahua'>相关资料</td></tr>";
			        	$("#sonTab").append(str);
					}	
						
		      	}    
		 }); 
    }
      

}


function chk(obj)
{
	var id = obj.value;
	if (obj.checked){
	$.ajax({
		        type: 'POST', 
		        url:'${BasePath}/vrdownload/getVrInfoById.kq?id='+id,
		        dataType: 'json', 
		        cache: false, 
		        error: function(data){ 
		           alert("系统繁忙，请稍候再试!"); 
		            return false; 
		        }, 
		        success:function(data)
		        { 
		        	var isRepeat = false;
		        	var lineCount = $("#parentTab tr").length;
		        	var lines = $("#parentTab tr");
		        	for (var i = 1;i<lineCount;i++)
		        	{
		        		if($(lines[i]).attr("id") == id){
							isRepeat = true;
						}
		        	}
		        	
		        	if (!isRepeat)
		        	{
		        		
			        	var str = "<tr id='"+data[0].id+"'><td name='selected1'>"+lineCount+"</td><td>"+data[0].classCode+"("+data[0].className+")</td><td>"+data[0].twoClassCode+"("
			        	+data[0].twoClassName+")</td><td title="+data[0].supplier+">"+data[0].supplier+"</td><td title="+data[0].equitModel+">"+data[0].equitModel+"</td><td>"
			        	+data[0].versionNo+"</td><td title="+data[0].name+">"+data[0].name+"</td><td><img src='${BasePath}/images/remove.png' id='img_"+id+"' onclick='removeLine(this)'></td></tr>";
			        	$("#tBody").append(str);
		        	}
		      	}
		 });
	}
	else{
		var lines = $("#parentTab tr");
		for (i=1;i<lines.length;i++){
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
}

function removeLine(obj){
	var id = $(obj).attr("id");
	id = id.substr(4);
	var lines = $("#parentTab tr");
		for (i=1;i<lines.length;i++){
			if($(lines[i]).attr("id") == id){
				$(lines[i]).remove();//删除本行
				
				$("#sonTab input[id='"+id+"']").attr("checked", false);//删除本行连同勾掉复选框。
                //实现删除行还能排序
				var num=1;
				$('#tBody tr').each(function (){								
					$(this).find('td').eq(0).text(num++);
				})

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
</body>
</html>

