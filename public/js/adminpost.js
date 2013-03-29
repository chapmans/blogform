$(document).ready(function(){
  $('#wcount').text($('#text').val().match(/\S+/g).length);
  $('#text').height($('#text')[0].scrollHeight + 100);
  
  $('#text').on('input', function() {
    $('#wcount').text($('#text').val().match(/\S+/g).length);
    $(this).height(0);
    $(this).height(this.scrollHeight);
  });
  
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
  
  $('.switch').click(function(){
    console.log($('#x').prop('checked'));
  });
});
