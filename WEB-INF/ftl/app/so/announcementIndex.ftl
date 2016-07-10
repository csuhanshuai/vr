<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>公告</title>
<style>
.table-set { table-layout: fixed; }
.table-set td { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
</style>
</head>

<link href="../css/sostyle.css" rel="stylesheet" type="text/css">
<link href='${BasePath}/css/global.css' rel='stylesheet' type='text/css' />
<link rev="stylesheet" rel="stylesheet" type="text/css" href="${BasePath}/css/thickbox.css"  media="screen" />
<script src="${BasePath}/js/jquery-1.11.2.min.js"></script>
<script type="text/javascript"  src="${BasePath}/js/common/thickbox/thickbox.js"></script>
<script type='text/javascript' src='${BasePath}/js/global.js'></script>
<script type='text/javascript' src='${BasePath}/js/plugin/operamasks/operamasks-ui.min.js'></script>
<script type='text/javascript' src='${BasePath}/js/wechat.js'></script>
<script src="${BasePath}/js/app/zjmall/qxmall.js"></script>
<LINK rel=stylesheet type=text/css href="${BasePath}/css/lrtk.css">
<SCRIPT type=text/javascript src="${BasePath}/js/jquery-1.4.2.min.js"></SCRIPT>
<script type="text/javascript" src="${BasePath}/js/app/turentable/jQueryRotate.2.2.js"></script>
<body>



<script type='text/javascript' >

function reload()
{
	window.location.reload();
}

function showAnnouncement(id)
{	
	showThickBox("公告详情","${BasePath}"+"/version/showAnnouncement/"+id+".kq?TB_iframe=true&height=400&width=600",false);
}

function getTopDetail()
{	
	showThickBox("新公告","${BasePath}"+"/version/announcementDialog.kq?TB_iframe=true&height=300&width=600",false);
}
	
function editAnnouncement(id)
{	
	showThickBox("修改公告","${BasePath}"+"/version/announcementDialog/"+id+".kq?TB_iframe=true&height=300&width=600",false);
}
function delAnnouncement(id)
{	
	if(confirm("你确定要删除？"))
    {
        document.getElementById("id").value =id;
		document.getElementById("myFormToDel").submit();
    }
    else{}
}

$(function() 
{
    var index = 0;
    var adtimer;
    var _wrap = $("#container ol"); 
    var len = $("#container ol li").length;
    if (len > 1) {
        $("#container").hover(function() 
        {
            clearInterval(adtimer);
        },
        function() 
        {
            adtimer = setInterval(function() 
            {
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
        function showImg(index) 
        {
            var Height = $("#container").height();
            $("#container ol").stop().animate({
                marginTop: -_h + 'px'
            },
            1000);
        }

        $("#container").mouseover(function() 
        {
            $("#container .mouse_direction").css("display", "block");
        });
        $("#container").mouseout(function() 
        {
            $("#container .mouse_direction").css("display", "none");
        });
    }

    $("#container").find(".mouse_top").click(function() 
    {
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

/*
$(document).ready(function() {
		
	   var tableDIV=document.getElementById('tableDIV');
	   
	   var turn_page=document.getElementById('turn_page');
	   tableDIV.style.height=(parent.document.documentElement.clientHeight-250)+"px";
});
*/

</script>
<form action="${BasePath}/version/delAnnouncement.kq" id="myFormToDel" name="myFormToDel">
<input type="hidden" name="id" id="id" />
</form>
<div class="header"> 
<i class="icon icon-5"></i>
<DIV id=container class=banner style="margin-top:13px">
  <OL>
	<#if resultList?exists> 
	<#list resultList as Notice>
	<li><a href="javascript:showAnnouncement('${Notice.id?default("")}')";><font  color="white">${Notice.title?default("")}</font></a></li>
	</#list> 
	</#if>
  </OL>
    <DIV class=mouse_direction>
        <DIV class=mouse_top></DIV>
        <DIV class=mouse_bottom></DIV>
    </DIV>
</DIV>
</div>
<div class="wrapper-c" id="tableDIV" style="margin:10px 20px; width:95%;">
    <form name="form1" method="post" action="${BasePath}/version/getAnnouncement.kq" id="qcust">
    <button style="float:left;" type="button" onClick="javascript:getTopDetail()"><i class="icon icon-8"></i> 新建</button>
    </form>
	  <table width="100%" border="1" class="table-set">
        <tr class="biaotou" >
        <td width="80px">序号</td>
          <td>标题</td>
          <td>内容</td>
          <td width="150px">发布时间</td>
          <td width="80px">发布人</td>
          <td width="150px">操作</td>
        </tr>       
        <#if pageFinder?exists>
        <#if pageFinder.result?exists>
        <#list pageFinder.result as Notice>      
        <tr>
	 	  <input type="hidden" value=${Notice.id?default("")}>
	 	  <td>${Notice_index + 1}</td>
          <td title="${Notice.title?default("")}" class="limit1">${Notice.title?default("")}</td>
          <td title="${Notice.content?default("")}" class="limit1">${Notice.content?default("")}</td>
          <td>${Notice.releaseTime?default("")}</td>
          <td>${Notice.creater?default("")}</td>
          <td><a href="javascript:editAnnouncement('${Notice.id}');"><img style="margin-top:4px;float:left;margin-left:34%" src="../images/icon_9.png"/></a><a href="javascript:delAnnouncement('${Notice.id}');"><i style="margin-top:10px;margin-left:10px" class="icon-7"></i></td></a>             
        </tr>
        </#list> 
        </#if>  
        </#if>  
      </table>

    </div>  
               <!-- 翻页标签 -->

<#import "../app-common.ftl"  as page>
<@page.queryForm formId="qcust" />  
    </div>
  </div>
</div>
<script type='text/javascript' >
	$(document).ready(function() {
		
	   //var tableDIV=document.getElementById('tableDIV');
	   
	   //var turn_page=document.getElementById('turn_page');
	   //tableDIV.style.height=(parent.document.documentElement.clientHeight-190)+"px";
	   //tableDIV.style.width=(parent.document.documentElement.clientWidth-195)+"px";
	   //turn_page.style.width=(parent.document.documentElement.clientWidth-195)+"px";
	});
</script>
</body>
</html>
