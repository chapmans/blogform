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
  
  var store;
  
  $('.note').click(function() {
    var nt = $(this).children('.notetext');
    console.log(nt);
    if (nt[0]) {
      store = nt.text();
      nt.replaceWith("<input class=\"notedit\" name=\"editnote\" value=\"" + store + "\" type=\"text\">");
      var ne = $(this).children('.notedit');
      ne.focus();
      ne.val(ne.val());
    }
  });
  
  $('.note').focusout(function() {
    var ne = $(this).children('.notedit');
    ne.replaceWith("<div class=\"notetext\">" + store + "</div>");
  });
  
  $('.note').keypress(function(event){
    console.log("x");
    if (event.which == 13) {
      var mval = $(".notedit").val();
      var mid = $(this).attr("id").substring(4);
      $.ajax({
        type: "POST",
        url: "/movement/dash/note/update",
        data: {
          id: mid,
          note:  mval
        },
        success: function(data) {
          store = mval;
          $('.note').focusout();
        }
      });
    }
  });
});
