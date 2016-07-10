<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>公告详情</title>
<link href="${BasePath}/css/sostyle.css" rel="stylesheet" type="text/css" />
<SCRIPT type=text/javascript src="${BasePath}/js/jquery-1.4.2.min.js"></SCRIPT>
</head>
<body>
<script>

function upload()
{
	var form=document.getElementById("form2");
	var title = form.title;
		if(title.value.trim().length==0)
		{
			var titleClear = document.getElementById("title");
			title.focus();
			alert("请输入标题");
			return;
		}
		
	var content = form.content;
	if(content.value.trim().length==0)
	{
		alert("请输入内容");
		var contentClear = document.getElementById("content");
		content.focus();
		return;
	}
	form.submit();
	window.parent.location.reload();
}

</script>

<form name="form2" id="form2" action="${BasePath}/version/announcement.kq" >
<input type="hidden" name="id" id="id" value="${id?default("")}">
<div class="miniDialog_wrapper" >
  <div class="miniDialog_content">
<ul>
      <li ><span class="label"><b class="ftx04">*</b>标  题：</span>
        <input type="text"  style="width:379px" value="${title?default("")}" readonly/>
      </li>
      <li><span class="label"><b class="ftx04">*</b>内  容：</span>
      	<textarea   style="width:385px; height:118px;border: 1px solid #c9c9c9; " readonly>${content?default("")}</textarea>
      </li>
      <li><span class="label"><b class="ftx04">*</b>创建者：</span>
        <input  readonly type="text" style="width:379px" value="${creater?default("")}"/>
      <li><span class="label"><b class="ftx04">*</b>创建时间：</span>
        <input readonly type="text" value="${createTime?default("")}"  style="width:379px" />
    </ul>

  </div>
</div>
</form>
</body>
</html>
