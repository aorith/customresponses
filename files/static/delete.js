function deleteResponse(btn) {
  var respId = btn.value;

  var xmlhttp = new XMLHttpRequest();

  xmlhttp.onreadystatechange = function () {
    if (this.readyState === XMLHttpRequest.DONE) {
      try {
        var response = JSON.parse(this.responseText);
      } catch (e) {
        var response = { detail: [{ msg: this.responseText }] };
      }

      if (this.status == 200) {
        console.log("OK");
        document.getElementById("tr_" + respId).remove();
        var created =
          '<div class="alert alert-success" role="alert"><h4>Deleted!</h4><code>id: ' +
          respId +
          "</code></div>";
        document.getElementById("messages").innerHTML = created;
      } else {
        console.log("ERROR");
        if (response.detail) {
          var error =
            '<div class="alert alert-danger" role="alert"><h4>Error!</h4>';
          if (typeof response.detail != "string") {
            for (var i = 0; i < response.detail.length; i++) {
              if (response.detail[i].msg) {
                error = error + "<li>" + response.detail[i].msg + "</li>";
              }
            }
          } else {
            error = error + "<li>" + response.detail + "</li>";
          }
          error = error + "</div>";
        } else {
          error = this.responseText;
        }
        document.getElementById("messages").innerHTML = error;
      }
      window.scrollTo(0, 0);
    }
  };

  xmlhttp.open(
    (method = "DELETE"),
    (url = "/v1/customresponse/" + respId),
    (async = true)
  );
  xmlhttp.setRequestHeader("Content-Type", "application/json; charset=UTF-8");
  xmlhttp.send();
}
