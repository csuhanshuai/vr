<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
	<html><head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script type="text/javascript">
	var BasePath="${BasePath}";
</script>
<title></title>
<link rev="stylesheet" rel="stylesheet" type="text/css" href="${BasePath}/css/thickbox.css"  media="screen" />
<link href='${BasePath}/css/global.css' rel='stylesheet' type='text/css' />
<link href='${BasePath}/css/main.css' rel='stylesheet' type='text/css' />
<script type='text/javascript' src='${BasePath}/js/jquery-1.7.2.min.js'></script>
<script language="javascript" type="text/javascript" src="${BasePath}/js/My97DatePicker/WdatePicker.js"></script>
<script type='text/javascript' src='${BasePath}/js/jquery.watermark-1.3.js'></script>
<script type="text/javascript"  src="${BasePath}/js/common/thickbox/thickbox.js"></script>

<style type="text/css">
.table tr:hover{background:#E4F1FC;}
.listext th{padding:0px 15px; border:2px solid #ddd; background:#D4ECF8;height:30px; white-space:nowrap;overflow:hidden;word-break:keep-all;}
.listext td{padding:2px 5px 2px 5px; border:2px solid #ddd; text-align:center; empty-cells:show;height:25px; font-size:12px; white-space:nowrap;overflow:hidden;word-break:keep-all;}
.main_content{background:#fff; padding-left:10px; padding-top:12px; padding-bottom:5px;padding-right:5px;}
</style>
</head>

<body>

<input type="hidden" value="${size}" id="size"> 
<input type="hidden" value="${year?default("")}" id="nowyear">
<input type="hidden" value="${month?default("")}" id="nowmonth">


<div id="iframe_page" style="overflow:hidden;">
		<!--页签区域 -->
        <div class="r_nav">
		    <ul>
			<li class="cur"> <a href="${BasePath}/lanterngame/listQuestion.kq">库存编辑</a>
			
			</li>
		   </ul>
		</div>

		<div class="main_content">
		
				<!--功能按钮区域(查询,添加等) -->
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
			        <tr>       
				        <td width="200px">        
				        	<a href="javascript:searchFun()" class="btn_green btn_w_120">查询</a>
				        	<a href="javascript:getTopDetail()" class="btn_green btn_w_120">定制列</a>
						</td>
			        </tr>
			    </table>
		    	<div style="height:10px;"></div>
			    <form action="${BasePath}/material/manager/queryList.kq" id="qcust">
					<table border="0" cellpadding="0" cellspacing="0" >
				        <tr>    
				        	<td> <input style="padding-left:5px;width:80px;text-align:left;"  placeholder="时间" name="selectYearMonth" value="${selectYearMonth?default("")}" class="Wdate" type="text" readonly="readonly" onClick="WdatePicker({lang:'zh-cn',dateFmt:'yyyy-MM'})" >&nbsp;</td>   
							<td ><input type="text" name="item_code" value="${itemcode?default("")}"placeholder="Item Code" style="padding-left:5px;width:80px;">&nbsp;</td>
							<td >&nbsp;<input type="text" name="item_Name" value="${itemName?default("")}" placeholder="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;产品" style="padding-left:5px;width:80px;"></td>
						    <td >&nbsp;<input type="text" name="contract_Code" value="${contractCode?default("")}" placeholder="&nbsp;&nbsp;Contract Code" style="padding-left:5px;width:110px;"></td>
						    <td >&nbsp;<input type="text" name="supplier_Name" value="${supplierName?default("")}" placeholder=" Supplier Name" style="padding-left:5px;width:110px;"></td>
						    <td >&nbsp;<input type="text" name="stock_Age" value="${stockAge?default("")}" placeholder=" &nbsp;&nbsp;&nbsp;&nbsp;货龄" style="padding-left:5px;width:80px;"></td>
				        </tr>
				    </table>
			    </form>
			    
			    
		    	<div style="height:10px;"> </div>
		    	
		    	
		    	<!--数据列表区域 -->
		    	<div id="cloneDIV" style="position:relative;">
					<div id="tableDIV" style="overflow:auto;">
					    <table id="itemTable" cellpadding="0" cellspacing="0" class="table listext"  style=" border-collapse:collapse;">
					        <thead>
					            <tr id="theadTr" >
					            	<th style="padding:3px" nowrap="nowrap">序号</th>
					            </tr>
					        </thead>
					        <tbody>
						       <#if pageFinder?? && (pageFinder.data)?? >
							      	 <#list pageFinder.result as item>		
									 	   <tr id='${item.id}' style="cursor: pointer;">
												 <td align="center" style="padding:0px">${item_index+1}</td>
								           </tr>
								      </#list>	
								<#else>
								     <tr><td colspan="${size+1}"><div class="yt-tb-list-no">没有记录</div></td></tr>
							    </#if>
						   </tbody>
					    </table>
					 </div>
				</div>		
    	</div>
   
<!--分页标签 -->
<#import "../app-common.ftl"  as page>
<@page.queryForm formId="qcust" />   

</div>


<script type='text/javascript' >
	$(document).ready(function() {
	   var iframe_page=document.getElementById('iframe_page');
	   iframe_page.style.height=(parent.document.documentElement.clientHeight-65)+"px";
		
	   var tableDIV=document.getElementById('tableDIV');
	   tableDIV.style.height=(document.body.clientHeight-170)+"px";
		
		//表头固定
		var tableClone="<div id=\"cloneTableDIV\"><table id=\"cloneTable\" cellpadding='0' cellspacing='0' class='table listext'   style=' border-collapse:collapse;'><thead id='testCloneThead'></thead><tbody></tbody></table></div>";
    	$("#cloneDIV").append(tableClone);
    	var theadTr=document.getElementById("theadTr");
    	var theadItemClone=theadTr.cloneNode(true);
    	$("#testCloneThead").append($(theadItemClone));
    	$("#cloneTable").css("width",itemTable.scrollWidth);
    	$("#cloneTableDIV").css("width",tableDIV.clientWidth);
    	$("#cloneTableDIV").css("position","absolute");
    	$("#cloneTableDIV").css("overflow","hidden");
    	$("#cloneTableDIV").css("z-index","2");
    	$("#cloneTableDIV").css("left","0px");
    	$("#cloneTableDIV").css("top","0px");
    	//$("#cloneTableDIV").css("display","none");
		var shangyiciScrollLeft=$("#tableDIV").scrollLeft();
		var width=$("#cloneTableDIV").css("width");
		var iwidth=parseInt(width);
		$("#tableDIV").scroll(function() {
		  	var scrollLeft=$("#tableDIV").scrollLeft();
		  	var rwidth=iwidth+scrollLeft+"px";
		  	$("#cloneTableDIV").css("width",rwidth);
		  	$("#cloneTableDIV").css("left",0-scrollLeft+"px");
		  	$("#cloneTableDIV").css("overflow","hidden");
		  	$("#cloneTableDIV").css("z-index","2");
    		$("#cloneTableDIV").css("top","0px");
		});	
		
	   var itemcode = $("#itemcode");	
	   var codeval=itemcode.attr('value');
	   var contractCode = $("#contractCode");	
	   var contractCodeval=contractCode.attr('value');
	   var myReg = /^[\u4e00-\u9fa5]+$/;
	   if(myReg.test(codeval)||myReg.test(contractCodeval)){
	      alert("itemcode和contracCode不允许为中文");
	      return false;
	   }
	   var itemTable=document.getElementById('itemTable');
	   $("#itemTable th div").each(function(){
		   $(this).css("width",$(this).get(0).clientWidth);
	   });

	});	
	
    	
 
	
	function getTopDetail()
	{	
		var id=1;
		showThickBox("定制列",BasePath+"/material/definecolumn/showCustom/"+id+".kq?TB_iframe=true&height=300&width=800",false);
	}



	function searchFun()
	{	
		  var pageSize=$("#pageSizeInput").val();
		  var pageForm =document.getElementById("qcust");
		  var imgTip="<img id=\"tempImg\" src=\"${BasePath}/images/right.png\"></img>";   
		  var inputHidden="<input type='hidden' name=\"pageSizeInput\" value=\""+pageSize +"\">";
		  $(pageForm).append(inputHidden);
	      pageForm.submit();
	}
	
</script> 
    
</body>
</html>
