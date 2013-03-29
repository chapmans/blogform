$(document).ready(function(){
  $('#sf').submit(function(){
    var tval = $("#title").val();
    var uval = $("#url").val();
    var dval = $("#text").val();
    $.ajax({
      type: "POST",
      url: "/movement/sidebar/add",
      data: {
        title:  tval,
        url: uval,
        desc: dval
      },
      success: function(data) {
        $("#title").val("");
        $("#url").val("");
        $("#text").val("");
        /* $("#notelist").prepend("<div class=\"note\" id=\"post" + data + "\">" +  
          "<div class=\"notetext\" id=\"text" + data + "\">" + mval + 
          "</div></div>"); */
      }
    });
    return false;
  });
});
