$(document).ready(function(){
  $('#noteform').submit(function(){
    var mval = $("#inote").val();
    $.ajax({
      type: "POST",
      url: "/movement/dash/note",
      data: {
        note:  mval
      },
      success: function(data) {
        $("#inote").val("");
        $("#notelist").prepend("<div class=\"note\" id=\"post" + data + "\">" +  
          "<div class=\"notetext\" id=\"text" + data + "\">" + mval + 
          "</div></div>");
      }
    });
    return false;
  });
});
