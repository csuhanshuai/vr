
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="title" content="华为FSU产品协议包管理系统">
<meta name="description" content="">
<meta name="keywords" content="">
<title>华为FSU产品协议包管理系统</title>

<#include "base.ftl">
<style>
.demo1 {
margin-left: 0px;
margin-top: 10px;
padding: 0px 0px 0px;
border: 1px solid #DDDDDD;
border-radius: 4px;
position: relative;
word-wrap: break-word;
}



.icon{ width:28px; height:29px; display:inline-block; background:url(${BasePath}/images/icon.png) no-repeat; vertical-align:middle;}
.icon-1{ background-position:0 -1px;}
.icon-2{ background-position:0 -40px;}
.icon-3{ background-position:0 -74px;}
.icon-4{ background-position:0 -103px;}
.icon-5{ background-position:0 -99px; float:left; margin-left:20px; margin-top:14px}
.icon-6{ background-position:0 -134px; width:22px; height:22px }



</style>
<script type='text/javascript' >
	window.onload=function(){
		document.getElementById("iClick").click();
		document.getElementById("estRows").style.display="";
	}
</script>
</head>

<body style="min-height: 660px; cursor: auto;" class="edit">
<#include "navigator.ftl">
<div class="container-fluid">
  <div class="row-fluid">
  <div class="">
  <div class="sidebar-nav">
    
  
  <#if login_system_user_resources?exists>
  <#list login_system_user_resources as item>
      <#if item.isleaf=='0'&&item.id??&&item.id!="">
      <ul class="nav nav-list accordion-group">
          <li class="nav-header">
          <div class="pull-right popover-info">
          <div class="popover fade right">
            <div class="arrow"></div>
          </div>
        </div>
          <i class="icon-plus icon-white"></i>${item.menuName}
          </li>
          <li style="display: none;" class="rows" id="estRows">
               <ul>
                  <#list login_system_user_resources as child>
                  <#if child.id??&&child.id!="">
        
                  <#if child.structure?substring(0,child.structure?last_index_of('-'))==item.structure>
                 	 	 <li>
			                  	<a href="${BasePath}${child.memuUrl}"  target="content" style="color:#fff">
			                  		<#if "上传"=="${child.menuName}">
			                  			<i class="icon icon-2"></i>&nbsp;
			                  		<#elseif "打包下载"=="${child.menuName}">
			                  			<i id="iClick" class="icon icon-3"></i>&nbsp;
			                  		<#elseif "发布公告"=="${child.menuName}">
			                  			<i class="icon icon-4"></i>&nbsp;
			                  		</#if>
			                  		${child.menuName}
			                  	</a>
			             </li>
                  </#if>   
                  </#if>
                  </#list>
              </ul>
          </li>
      </ul>   
      </#if>
  </#list>
  </#if>
   
    
  </div>
</div>
    <!--/span-->
    <iframe id="content" name="content" class="demo1 ui-sortable" style="min-height: 880px;width:100%;"></iframe>

 
    <!--/span-->
    
  </div>
  <!--/row--> 
</div>
<!--/.fluid-container--> 
<div class="modal hide fade" role="dialog" id="editorModal">
  <div class="modal-header"> <a class="close" data-dismiss="modal">×</a>
    <h3>编辑</h3>
  </div>
  <div class="modal-body">
    <p>
      <textarea id="contenteditor"></textarea>
    </p>
  </div>
  <div class="modal-footer"> <a id="savecontent" class="btn btn-primary" data-dismiss="modal">保存</a> <a class="btn" data-dismiss="modal">关闭</a> </div>
</div>
<div class="modal hide fade" role="dialog" id="downloadModal">
  <div class="modal-header"> <a class="close" data-dismiss="modal">×</a>
    <h3>下载</h3>
  </div>
  <div class="modal-body">
    <p>已在下面生成干净的HTML, 可以复制粘贴代码到你的项目.</p>
    <div class="btn-group">
      <button type="button" id="fluidPage" class="active btn btn-info"><i class="icon-fullscreen icon-white"></i> 自适应宽度</button>
      <button type="button" class="btn btn-info" id="fixedPage"><i class="icon-screenshot icon-white"></i> 固定宽度</button>
    </div>
    <br>
    <br>
    <p>
      <textarea></textarea>
    </p>
  </div>
  <div class="modal-footer"> <a class="btn" data-dismiss="modal">关闭</a> </div>
</div>
<div class="modal hide fade" role="dialog" id="shareModal">
  <div class="modal-header"> <a class="close" data-dismiss="modal">×</a>
    <h3>保存</h3>
  </div>
  <div class="modal-body">保存成功</div>
  <div class="modal-footer"> <a class="btn" data-dismiss="modal">Close</a> </div>
</div>

</body>
</html>