﻿$(document).ready(function(){$("#urldiv").css("display","none");$("#keydiv").css("display","block");$("#pmenudiv").css("display","none");$("#selecttype2").click(function(){$("#pmenudiv").css("display","block")});$("#selecttype1").click(function(){$("#pmenudiv").css("display","none")});$("#type").change(function(){"1"==$("#type").val()?($("#urldiv").css("display","none"),$("#keydiv").css("display","block")):($("#urldiv").css("display","block"),$("#keydiv").css("display","none"))})});
function toUpdateMenu(a,b,c){$("#question").val(b);$("#answer").val(c);$("#id").val(a)}function removeMessage(a){$("#okbtn").on("click",function(b){window.location.href="removeMessage.kq?id\x3d"+a});$("#deleteModal").modal({keyboard:!0})}
function saveMenu(){var a=$("#id").val(),b=$("#pmenu").val();"none"==$("#pmenudiv").css("display")&&(b="");var c=$("#menuname").val(),e=$("#type").val(),f=$("#key").val(),g=$("#url").val(),d;null!=a&&""!=a?(d="updateMenu.kq",a={id:a,pmenu:b,menuname:c,type:e,key:f,url:g}):(d="addMenu.kq",a={pmenu:b,menuname:c,type:e,key:f,url:g});ajaxRequest(d,a,function(a){a&&(a=a.replace(/(^\s*)|(\s*$)/g,""),"success"==a?($("#pmenu").val(""),$("#smenu").val(""),$("#id").val(""),$("#tips").css("display","block"),
$("#tipcontent").text("\u4fdd\u5b58\u6210\u529f"),$("#myModal").modal({keyboard:!1}),$("#myModal").on("hidden.bs.modal",function(a){window.location.reload()})):($("#tips").css("display","block"),$("#tips").text(a)))})}function submitForm(){var a=document.forms[0];a.target="content";a.submit();window.top.TB_remove()}function ajaxRequest(a,b,c){$.ajax({type:"POST",url:a,data:b,cache:!0,success:c})};